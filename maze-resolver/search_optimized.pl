% ============================================
% PROGETTO: Algoritmi di Ricerca Informata
% Implementazione di IDA* e A* per labirinto
% ============================================

% Dichiarazione predicati dinamici
:- dynamic trasforma/3, applicabile/2, finale/1, iniziale/1.
:- dynamic current_depth/1, next_depth/1.

% ============================================
% EURISTICA - Distanza di Manhattan
% ============================================

% manhattan(+Pos1, +Pos2, -Distanza)
% Calcola la distanza di Manhattan tra due posizioni (euristica ammissibile)
% La distanza Manhattan è la somma delle differenze assolute delle coordinate
manhattan(pos(X1, Y1), pos(X2, Y2), Dist) :-
    DiffX is abs(X1 - X2),
    DiffY is abs(Y1 - Y2),
    Dist is DiffX + DiffY.

% stato_finale_migliore(+Stato, -UscitaMigliore, -Distanza)
% Trova l'uscita più vicina da Stato usando la distanza di Manhattan
% Utilizza il pattern \+(...) per trovare il minimo: "non esiste un'uscita più vicina"
stato_finale_migliore(Stato, UscitaMigliore, Distanza) :-
    finale(ListaUscite),
    member(UscitaMigliore, ListaUscite),
    manhattan(Stato, UscitaMigliore, Distanza),
    \+ (
        member(AltraUscita, ListaUscite),
        manhattan(Stato, AltraUscita, AltraDistanza),
        AltraDistanza < Distanza
    ).

% azioni_ordinate(+Stato, -AzioniOrdinate)
% Restituisce le azioni applicabili ordinate per distanza euristica dall'uscita migliore
% Formato output: [(Azione1, Distanza1), (Azione2, Distanza2), ...]
azioni_ordinate(Stato, AzioniOrdinate) :-
    stato_finale_migliore(Stato, UscitaMigliore, _),
    findall(Az, applicabile(Az, Stato), AzioniDisponibili),
    valuta_azioni(AzioniDisponibili, Stato, UscitaMigliore, AzioniConDistanza),
    sort(2, @=<, AzioniConDistanza, AzioniOrdinate).

% valuta_azioni(+Azioni, +Stato, +Uscita, -AzioniConDistanza)
% Associa a ogni azione la distanza Manhattan del nuovo stato dall'uscita
valuta_azioni([], _, _, []).
valuta_azioni([Az|AltreAzioni], Stato, Uscita, [(Az, Dist)|Resto]) :-
    trasforma(Az, Stato, SNuovo),
    manhattan(SNuovo, Uscita, Dist),
    valuta_azioni(AltreAzioni, Stato, Uscita, Resto).

% ============================================
% IDA* - ITERATIVE DEEPENING A*
% ============================================
% Algoritmo che combina ricerca in profondità con euristica A*
% Usa memoria O(bd) ma garantisce ottimalità
% Funziona con soglie incrementali basate su f(n) = g(n) + h(n)

% calcola_fn(+Stato, +UscitaTarget, +Visitati, -Fn)
% Calcola f(n) = g(n) + h(n)
% - g(n): costo reale dal nodo iniziale (= numero di passi = length(Visitati))
% - h(n): stima euristica (distanza Manhattan all'uscita)
% - f(n): stima del costo totale del cammino passante per questo stato
calcola_fn(Stato, UscitaTarget, Visitati, Fn) :-
    length(Visitati, Gn),
    manhattan(Stato, UscitaTarget, Hn),
    Fn is Gn + Hn.

% ida_limitata_track(+Stato, +Visitati, -Cammino, +Soglia)
% Ricerca in profondità limitata dalla soglia f(n)
% - Se f(n) <= Soglia: esplora il nodo
% - Se f(n) > Soglia: pota il ramo e salva f(n) per la prossima iterazione

% CASO BASE: Stato è un'uscita
ida_limitata_track(S, _, [], _) :-
    finale(LF),
    member(S, LF),
    !.

% CASO RICORSIVO: Esplora se f(n) rispetta la soglia
ida_limitata_track(S, Visitati, [Az|Resto], Soglia) :-
    stato_finale_migliore(S, UscitaMigliore, _),
    calcola_fn(S, UscitaMigliore, Visitati, Fn),
    (   Fn =< Soglia
    ->  % f(n) rispetta la soglia: esplora questo ramo
        azioni_ordinate(S, AzioniOrd),
        member((Az, _), AzioniOrd),
        trasforma(Az, S, SNuovo),
        \+ member(SNuovo, Visitati),
        ida_limitata_track(SNuovo, [S|Visitati], Resto, Soglia)
    ;   % f(n) supera la soglia: pota e salva f(n) per prossima iterazione
        trova_next_depth(Fn),
        fail
    ).

% trova_next_depth(+Fn)
% Aggiorna next_depth mantenendo il minimo f(n) che ha superato la soglia corrente
% Questo diventerà la soglia della prossima iterazione
trova_next_depth(Fn) :-
    current_depth(SogliaAttuale),
    Fn > SogliaAttuale,
    (   next_depth(NextAttuale)
    ->  (   Fn < NextAttuale
        ->  retract(next_depth(NextAttuale)),
            assert(next_depth(Fn))
        ;   true
        )
    ;   assert(next_depth(Fn))
    ).

% initialize_ida/0
% Inizializza le soglie per IDA*
% Soglia iniziale = h(stato_iniziale) = distanza Manhattan dall'uscita più vicina
initialize_ida :-
    retractall(current_depth(_)),
    retractall(next_depth(_)),
    iniziale(S),
    stato_finale_migliore(S, UscitaMigliore, _),
    calcola_fn(S, UscitaMigliore, [], SogliaIniziale),
    assert(current_depth(SogliaIniziale)).

% ida_star(-Cammino)
% Entry point principale di IDA*
% Restituisce il cammino ottimo (lista di azioni)
ida_star(Cammino) :-
    initialize_ida,
    ida_star_loop(Cammino).

% ida_star_loop(-Cammino)
% Loop di iterative deepening
% Incrementa la soglia fino a trovare una soluzione
ida_star_loop(Cammino) :-
    iniziale(S),
    current_depth(Soglia),
    retractall(next_depth(_)),
    write('IDA*: Iterazione con soglia f(n) = '), write(Soglia), nl,
    (   ida_limitata_track(S, [], Cammino, Soglia)
    ->  write('IDA*: Soluzione trovata!'), nl, true
    ;   (   next_depth(NuovaSoglia)
        ->  (   NuovaSoglia > Soglia
            ->  retract(current_depth(_)),
                assert(current_depth(NuovaSoglia)),
                ida_star_loop(Cammino)
            ;   write('IDA*: Nessun progresso possibile.'), nl, fail
            )
        ;   write('IDA*: Nessuna soluzione trovata.'), nl, fail
        )
    ).

% ============================================
% A* - RICERCA CON CODA DI PRIORITÀ
% ============================================
% Algoritmo che mantiene frontiera OPEN e lista CLOSED
% Usa memoria O(b^d) ma non re-espande nodi già visitati
% Garantisce ottimalità ed è più veloce di IDA* in tempo

% Nodo: nodo(Stato, Cammino, Gn, Hn, Fn)
% - Stato: posizione corrente
% - Cammino: lista di azioni per arrivarci (costruita al contrario)
% - Gn: g(n) = costo reale dal nodo iniziale
% - Hn: h(n) = euristica
% - Fn: f(n) = g(n) + h(n)

% crea_nodo_iniziale(-Nodo)
% Crea il nodo iniziale per A*
crea_nodo_iniziale(nodo(S, [], 0, Hn, Fn)) :-
    iniziale(S),
    stato_finale_migliore(S, Uscita, _),
    manhattan(S, Uscita, Hn),
    Fn is 0 + Hn.

% genera_successori(+Nodo, -Successori)
% Genera tutti i nodi successori validi applicando le azioni disponibili
genera_successori(nodo(S, Cammino, Gn, _, _), Successori) :-
    stato_finale_migliore(S, Uscita, _),
    findall(
        nodo(SNuovo, [Az|Cammino], GnNuovo, HnNuovo, FnNuovo),
        (
            applicabile(Az, S),
            trasforma(Az, S, SNuovo),
            GnNuovo is Gn + 1,
            manhattan(SNuovo, Uscita, HnNuovo),
            FnNuovo is GnNuovo + HnNuovo
        ),
        Successori
    ).

% inserisci_ordinato(+Nodo, +Coda, -NuovaCoda)
% Inserisce un nodo nella coda mantenendo l'ordine crescente per f(n)
% Implementa una coda di priorità come lista ordinata
inserisci_ordinato(Nodo, [], [Nodo]).
inserisci_ordinato(nodo(S, C, G, H, F), [nodo(S1, C1, G1, H1, F1)|Resto], 
                   [nodo(S, C, G, H, F), nodo(S1, C1, G1, H1, F1)|Resto]) :-
    F =< F1, !.
inserisci_ordinato(Nodo, [Primo|Resto], [Primo|NuovaCoda]) :-
    inserisci_ordinato(Nodo, Resto, NuovaCoda).

% inserisci_lista_ordinata(+ListaNodi, +Coda, -NuovaCoda)
% Inserisce una lista di nodi nella coda mantenendo l'ordine
inserisci_lista_ordinata([], Coda, Coda).
inserisci_lista_ordinata([N|Resto], Coda, NuovaCoda) :-
    inserisci_ordinato(N, Coda, CodaTemp),
    inserisci_lista_ordinata(Resto, CodaTemp, NuovaCoda).

% stato_in_closed(+Stato, +Closed)
% Verifica se uno stato è già nella lista CLOSED (nodi già espansi)
stato_in_closed(Stato, Closed) :-
    member(nodo(Stato, _, _, _, _), Closed).

% stato_in_open(+Stato, +Open)
% Verifica se uno stato è già nella coda OPEN (frontiera)
stato_in_open(Stato, Open) :-
    member(nodo(Stato, _, _, _, _), Open).

% rimuovi_stato_peggiore(+Stato, +FnNuovo, +Open, -OpenAggiornata)
% Se lo stato è in OPEN con f(n) peggiore, lo rimuove
% (per sostituirlo con il percorso migliore appena trovato)
rimuovi_stato_peggiore(_, _, [], []).
rimuovi_stato_peggiore(Stato, FnNuovo, [nodo(Stato, _, _, _, FnVecchio)|Resto], Resto) :-
    FnNuovo < FnVecchio, !.
rimuovi_stato_peggiore(Stato, FnNuovo, [Primo|Resto], [Primo|RestoAggiornato]) :-
    rimuovi_stato_peggiore(Stato, FnNuovo, Resto, RestoAggiornato).

% filtra_successori(+Successori, +Open, +Closed, -SuccessoriFiltrati, -OpenAggiornata)
% Filtra i successori in base alle regole di A*:
% - Se in CLOSED: scarta (già espanso con percorso ottimo)
% - Se in OPEN con f(n) peggiore: sostituisci
% - Altrimenti: mantieni
filtra_successori([], Open, _, [], Open).
filtra_successori([nodo(S, C, G, H, F)|Resto], Open, Closed, Filtrati, OpenFinale) :-
    (   stato_in_closed(S, Closed)
    ->  filtra_successori(Resto, Open, Closed, Filtrati, OpenFinale)
    ;   stato_in_open(S, Open)
    ->  rimuovi_stato_peggiore(S, F, Open, OpenTemp),
        filtra_successori(Resto, OpenTemp, Closed, FiltriResto, OpenFinale),
        Filtrati = [nodo(S, C, G, H, F)|FiltriResto]
    ;   filtra_successori(Resto, Open, Closed, FiltriResto, OpenFinale),
        Filtrati = [nodo(S, C, G, H, F)|FiltriResto]
    ).

% a_star(-Cammino)
% Entry point di A* (con output di debug)
a_star(Cammino) :-
    crea_nodo_iniziale(NodoIniziale),
    write('A*: Inizializzazione completata'), nl,
    a_star_loop([NodoIniziale], [], Cammino).

% a_star_loop(+Open, +Closed, -Cammino)
% Loop principale di A*
% - Estrae nodo con minimo f(n) da OPEN
% - Se è goal: successo
% - Altrimenti: espande, filtra successori, aggiorna OPEN e CLOSED

% CASO BASE: OPEN vuota - nessuna soluzione
a_star_loop([], _, _) :-
    write('A*: Nessuna soluzione trovata!'), nl, fail.

% CASO BASE: Primo nodo in OPEN è il goal
a_star_loop([nodo(S, Cammino, _, _, _)|_], _, CamminoFinale) :-
    finale(LF),
    member(S, LF),
    !,
    reverse(Cammino, CamminoFinale),
    write('A*: Soluzione trovata!'), nl.

% CASO RICORSIVO: Espandi nodo con minimo f(n)
a_star_loop([NodoCorrente|RestoOpen], Closed, Cammino) :-
    NodoCorrente = nodo(S, _, _, _, Fn),
    write('A*: Espando '), write(S), write(' [f(n)='), write(Fn), write(']'), nl,
    genera_successori(NodoCorrente, Successori),
    filtra_successori(Successori, RestoOpen, Closed, SuccessoriFiltrati, OpenAggiornata),
    inserisci_lista_ordinata(SuccessoriFiltrati, OpenAggiornata, NuovaOpen),
    a_star_loop(NuovaOpen, [NodoCorrente|Closed], Cammino).

% a_star_silent(-Cammino)
% Versione silenziosa di A* (senza output di debug)
a_star_silent(Cammino) :-
    crea_nodo_iniziale(NodoIniziale),
    a_star_loop_silent([NodoIniziale], [], Cammino).

a_star_loop_silent([], _, _) :- fail.
a_star_loop_silent([nodo(S, Cammino, _, _, _)|_], _, CamminoFinale) :-
    finale(LF),
    member(S, LF),
    !,
    reverse(Cammino, CamminoFinale).
a_star_loop_silent([NodoCorrente|RestoOpen], Closed, Cammino) :-
    genera_successori(NodoCorrente, Successori),
    filtra_successori(Successori, RestoOpen, Closed, SuccessoriFiltrati, OpenAggiornata),
    inserisci_lista_ordinata(SuccessoriFiltrati, OpenAggiornata, NuovaOpen),
    a_star_loop_silent(NuovaOpen, [NodoCorrente|Closed], Cammino).

% ============================================
% UTILITY - Confronto e Benchmarking
% ============================================

% confronta_algoritmi/0
% Confronta le prestazioni di IDA* e A*
confronta_algoritmi :-
    write('=== CONFRONTO ALGORITMI ==='), nl, nl,
    
    % Test IDA*
    write('--- IDA* ---'), nl,
    statistics(walltime, [_|_]),
    ida_star(C1),
    statistics(walltime, [_|T1]),
    length(C1, L1),
    write('Tempo: '), write(T1), write(' ms'), nl,
    write('Lunghezza cammino: '), write(L1), nl,
    write('Cammino: '), write(C1), nl, nl,
    
    % Test A*
    write('--- A* ---'), nl,
    statistics(walltime, [_|_]),
    a_star_silent(C2),
    statistics(walltime, [_|T2]),
    length(C2, L2),
    write('Tempo: '), write(T2), write(' ms'), nl,
    write('Lunghezza cammino: '), write(L2), nl,
    write('Cammino: '), write(C2), nl, nl,
    
    % Riepilogo
    write('=== RIEPILOGO ==='), nl,
    write('Entrambi trovano cammini ottimi: '),
    (L1 =:= L2 -> write('SI') ; write('NO')), nl,
    write('A* è più veloce: '),
    (T2 < T1 -> write('SI') ; write('NO')), nl.

% ============================================
% NOTE IMPLEMENTATIVE
% ============================================
% 
% DIFFERENZE CHIAVE TRA IDA* E A*:
% 
% IDA*:
% - Memoria: O(bd) - lineare nella profondità
% - Tempo: Re-espande nodi in iterazioni successive
% - Ideale per: Problemi con memoria limitata
% - Implementazione: Ricorsione + assert/retract per soglie
% 
% A*:
% - Memoria: O(b^d) - esponenziale nel fattore di branching
% - Tempo: Ogni nodo espanso una sola volta
% - Ideale per: Quando velocità è prioritaria
% - Implementazione: Coda priorità + lista chiusi
% 
% OTTIMALITÀ:
% Entrambi garantiscono ottimalità perché:
% - h(n) è ammissibile (Manhattan non sovrastima mai)
% - f(n) = g(n) + h(n) viene usato correttamente
% 
% COMPLETEZZA:
% Entrambi sono completi (trovano soluzione se esiste)
% grazie al controllo degli stati visitati
% 
% ============================================


% % Caricamento file
% ?- [maze].    % File con num_righe, num_col, iniziale, occupata, finale
% ?- [actions].       % File con applicabile/2 e trasforma/3
% ?- [search_optimized].    % Questo file

% % Test IDA*
% ?- ida_star(Cammino).

% % Test A* (verbose)
% ?- a_star(Cammino).

% % Test A* (silent)
% ?- a_star_silent(Cammino).

% % Confronto
% ?- confronta_algoritmi.