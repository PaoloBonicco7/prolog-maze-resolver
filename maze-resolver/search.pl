:- dynamic trasforma/3, applicabile/2, finale/1.
% ============================================
% RICERCA IN PROFONDITÀ - Versione Naive
% ============================================

% cerca_prof(Stato, Cammino)
% Trova un cammino (lista di azioni) dallo Stato a un'uscita

% CASO BASE: Se sono già a un'uscita, il cammino è vuoto
cerca_prof(S, []) :- 
    finale(LF),           % Prendo la lista delle uscite
    member(S, LF),        % Verifico se S è un'uscita
    !.                    % Cut: ferma il backtracking qui

% CASO RICORSIVO: Faccio un'azione e cerco dal nuovo stato
cerca_prof(S, [Az|Resto]) :-
    applicabile(Az, S),        % Scelgo un'azione applicabile
    trasforma(Az, S, SNuovo),  % Calcolo il nuovo stato
    cerca_prof(SNuovo, Resto). % Ricorsione sul nuovo stato



% ============================================
% RICERCA IN PROFONDITÀ - Con Lista Visitati
% ============================================

% cerca_prof_safe(Stato, Cammino)
% Wrapper che inizializza la lista visitati vuota
cerca_prof_safe(S, Cammino) :-
    cerca_prof_safe(S, [], Cammino).

% cerca_prof_safe(Stato, Visitati, Cammino)
% Versione con lista dei nodi già visitati

% CASO BASE: Sono a un'uscita
cerca_prof_safe(S, _, []) :- 
    finale(LF),
    member(S, LF),
    !.

% CASO RICORSIVO: Esploro con controllo dei visitati
cerca_prof_safe(S, Visitati, [Az|Resto]) :-
    applicabile(Az, S),
    trasforma(Az, S, SNuovo),
    \+ member(SNuovo, Visitati),  % ← Non revisito stati
    cerca_prof_safe(SNuovo, [S|Visitati], Resto).



% ============================================
% EURISTICA - Distanza di Manhattan
% ============================================

% manhattan(Pos1, Pos2, Distanza)
% Calcola la distanza di Manhattan tra due posizioni

manhattan(pos(X1, Y1), pos(X2, Y2), Dist) :-
    DiffX is abs(X1 - X2),  % Valore assoluto della differenza X
    DiffY is abs(Y1 - Y2),  % Valore assoluto della differenza Y
    Dist is DiffX + DiffY.  % Somma delle differenze


% ============================================
% SELEZIONE USCITA MIGLIORE
% ============================================

% stato_finale_migliore(Stato, UscitaMigliore, Distanza)
% Trova l'uscita più vicina da Stato usando Manhattan

stato_finale_migliore(Stato, UscitaMigliore, Distanza) :-
    finale(ListaUscite),                                % Prende tutte le uscite
    member(UscitaMigliore, ListaUscite),                % Seleziona un'uscita
    manhattan(Stato, UscitaMigliore, Distanza),         % Calcola la distanza
    \+ (                                                % Negazione - Non esiste...
        member(AltraUscita, ListaUscite),               % ...un'altra uscita
        manhattan(Stato, AltraUscita, AltraDistanza),   % con distanza
        AltraDistanza < Distanza                        % minore
    ).



% ============================================
% ORDINAMENTO AZIONI PER EURISTICA
% ============================================

% azioni_ordinate(Stato, AzioniOrdinate)
% Restituisce le azioni applicabili ordinate per distanza dall'uscita

azioni_ordinate(Stato, AzioniOrdinate) :-
    stato_finale_migliore(Stato, UscitaMigliore, _),
    findall(Az, applicabile(Az, Stato), AzioniDisponibili),
    valuta_azioni(AzioniDisponibili, Stato, UscitaMigliore, AzioniConDistanza),
    ordina_per_distanza(AzioniConDistanza, AzioniOrdinate).


% valuta_azioni(Azioni, StatoCorrente, Uscita, AzioniConDistanza)
% Associa a ogni azione la distanza del nuovo stato dall'uscita

valuta_azioni([], _, _, []).

valuta_azioni([Az|AltreAzioni], Stato, Uscita, [(Az, Dist)|Resto]) :-
    trasforma(Az, Stato, SNuovo),
    manhattan(SNuovo, Uscita, Dist),
    valuta_azioni(AltreAzioni, Stato, Uscita, Resto).

% ordina_per_distanza(AzioniConDistanza, AzioniOrdinate)
% Ordina le azioni dalla distanza minore alla maggiore

ordina_per_distanza(Lista, ListaOrdinata) :-
    sort(2, @=<, Lista, ListaOrdinata).  % Ordina sul secondo elemento (distanza)



% ============================================
% RICERCA GUIDATA DA EURISTICA
% ============================================

% cerca_euristica(Stato, Cammino)
% Ricerca che prova prima le azioni più promettenti

cerca_euristica(S, Cammino) :-
    cerca_euristica(S, [], Cammino).

cerca_euristica(S, _, []) :-
    finale(LF),
    member(S, LF),
    !.

cerca_euristica(S, Visitati, [Az|Resto]) :-
    azioni_ordinate(S, AzioniOrd),  % Usa azioni ordinate
    member((Az, _), AzioniOrd),     % Prova le azioni in ordine (member seleziona la prima che trova)
    trasforma(Az, S, SNuovo),
    \+ member(SNuovo, Visitati),
    cerca_euristica(SNuovo, [S|Visitati], Resto).


% ----- TEST THE SOLUTION ---
% iniziale(S), cerca_prof_safe(S, C1), length(C1, L1),
%    iniziale(S), cerca_euristica(S, C2), length(C2, L2).
% ---------------------------------------------

% ============================================
% IDA* - Calcolare f(n)
% ============================================

% 1. Soglia iniziale = h(stato_iniziale)
% 2. Fai ricerca in profondità limitata dalla soglia:
%    - Se f(n) > soglia → POTA (non espandere)
%    - Se raggiungi goal → SUCCESSO!
%    - Altrimenti, salva il minimo f(n) che ha superato la soglia
% 3. Nuova soglia = minimo f(n) salvato
% 4. Ripeti dal punto 2

% calcola_fn(Stato, UscitaTarget, Visitati, Fn)
% Calcola f(n) = g(n) + h(n)
% g(n) = lunghezza del cammino finora (length(Visitati))
% h(n) = distanza Manhattan

calcola_fn(Stato, UscitaTarget, Visitati, Fn) :-
    length(Visitati, Gn),               % g(n) = numero di stati visitati
    manhattan(Stato, UscitaTarget, Hn), % h(n) = euristica
    Fn is Gn + Hn.                      % f(n) = g(n) + h(n)



% ============================================
% IDA* - Ricerca Limitata
% ============================================

% ida_limitata(Stato, Visitati, Cammino, Soglia)
% Ricerca in profondità con pruning basato su f(n)

% CASO BASE: Raggiunto il goal
ida_limitata(S, _, [], _) :-
    finale(LF),
    member(S, LF),
    !.

% CASO RICORSIVO: Esplora se f(n) <= soglia
ida_limitata(S, Visitati, [Az|Resto], Soglia) :-
    Soglia > 0,                                     % Controllo di sicurezza
    stato_finale_migliore(S, UscitaMigliore, _),    % Trova uscita migliore
    calcola_fn(S, UscitaMigliore, Visitati, Fn),    % Calcola f(n)
    Fn =< Soglia,                                   % PRUNING: rispetta soglia
    azioni_ordinate(S, AzioniOrd),                  % Ordina azioni per euristica
    member((Az, _), AzioniOrd),                     % Prova azioni in ordine
    trasforma(Az, S, SNuovo),
    \+ member(SNuovo, Visitati),                    % Non revisitare
    ida_limitata(SNuovo, [S|Visitati], Resto, Soglia).