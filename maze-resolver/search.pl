:- dynamic trasforma/3, applicabile/2, finale/1, iniziale/1.
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
    Fn =< Soglia,                                   % PRUNING: si interrompe se superiamo la solgia
    azioni_ordinate(S, AzioniOrd),                  % Ordina azioni per euristica
    member((Az, _), AzioniOrd),                     % Prova azioni in ordine
    trasforma(Az, S, SNuovo),
    \+ member(SNuovo, Visitati),                    % Non rivisitare
    ida_limitata(SNuovo, [S|Visitati], Resto, Soglia).


% Considerazioni: 
% Trova tante soluzioni, sempre che rispettino la solgia. Questo perchè anche solo cambiando un 
% piccolo passo del percorso si ottine un cammino diverso, seppur con la stessa lunghezza. Quindi se vado prima
% a nord e poi ad est, o prima ad est e poi a nord, mi trovo praticamente nella stessa posizione, anche se il 
% cammino è diverso.



% ============================================
% IDA* - Gestione next_depth
% ============================================

% Predicati dinamici per salvare le soglie
:- dynamic current_depth/1.
:- dynamic next_depth/1.

% trova_next_depth(Fn)
% Aggiorna next_depth se Fn è il nuovo minimo oltre la soglia corrente

trova_next_depth(Fn) :-
    current_depth(SogliaAttuale),
    Fn > SogliaAttuale,                         % Fn ha superato la soglia
    (   next_depth(NextAttuale)
    ->  (   Fn < NextAttuale                       % Se è minore del next corrente
        ->  retract(next_depth(NextAttuale)),
            assert(next_depth(Fn))              % Aggiorna next_depth
        ;   true                                  
        )                                       % Altrimenti lascia com'è
    ;   assert(next_depth(Fn))                  % Prima volta, crea next_depth
    ).


% ida_limitata_track(Stato, Visitati, Cammino, Soglia)
% Versione che traccia i valori f(n) che superano la soglia

ida_limitata_track(S, _, [], _) :-
    finale(LF),
    member(S, LF),
    !.

ida_limitata_track(S, Visitati, [Az|Resto], Soglia) :-
    stato_finale_migliore(S, UscitaMigliore, _),
    calcola_fn(S, UscitaMigliore, Visitati, Fn),
    (   Fn =< Soglia
    ->  azioni_ordinate(S, AzioniOrd),                              % f(n) rispetta la soglia, esplora
        
        member((Az, _), AzioniOrd),
        trasforma(Az, S, SNuovo),
        \+ member(SNuovo, Visitati),
        ida_limitata_track(SNuovo, [S|Visitati], Resto, Soglia)
    ;   trova_next_depth(Fn),                                       % f(n) supera la soglia, salva per prossima iterazione     
        fail                                                        % Forza backtracking
    ).



% ============================================
% IDA* - Wrapper Principale
% ============================================

% initialize_ida/0
% Pulisce e inizializza le soglie

initialize_ida :-
    retractall(current_depth(_)),
    retractall(next_depth(_)),
    iniziale(S),
    stato_finale_migliore(S, UscitaMigliore, _),
    calcola_fn(S, UscitaMigliore, [], SogliaIniziale),
    assert(current_depth(SogliaIniziale)).

% ida_star(Cammino)
% Entry point principale di IDA*

ida_star(Cammino) :-
    initialize_ida,
    ida_star_loop(Cammino).

% ida_star_loop(Cammino)
% Loop di iterative deepening

ida_star_loop(Cammino) :-
    iniziale(S),
    current_depth(Soglia),
    retractall(next_depth(_)),                          % Pulisce next_depth per la nuova iterazione
    write('Iterazione con soglia: '), write(Soglia), nl,
    (   ida_limitata_track(S, [], Cammino, Soglia)
    ->  true                                            % Trovata soluzione entro soglia
    ;                                                   % Nessuna soluzione entro soglia: prova ad aumentarla
        (   next_depth(NuovaSoglia)
        ->  (   NuovaSoglia > Soglia
            ->  retract(current_depth(_)),
                assert(current_depth(NuovaSoglia)),
                ida_star_loop(Cammino)
            ;   % Protezione: next_depth non è aumentata (anomalia)
                write('Nessun progresso possibile.'), nl, fail
            )
        ;   % Non esiste un next_depth: nessun nodo oltre la soglia → fallisce (o impossibile)
            write('Nessun next_depth trovato: problema insolubile entro lo spazio di ricerca.'), nl, fail
        )
    ).