:- dynamic trasforma/3, applicabile/2, iniziale/1, finale/1, indice_posizione/3.

% ============================================
% EURISTICA - Distanza di Manhattan per Puzzle
% ============================================

% manhattan_puzzle(Stato, StatoFinale, Distanza)
% Calcola la somma delle distanze Manhattan di tutte le tessere
% (escluso il vuoto) dalla loro posizione target

% L'euristica è AMMISSIBILE: non sovrastima mai il numero minimo
% di mosse necessarie (ogni mossa sposta solo una tessera di 1 passo)

manhattan_puzzle(Stato, StatoFinale, Distanza) :-
    manhattan_totale(Stato, StatoFinale, 1, 0, Distanza).


% manhattan_totale(Stato, StatoFinale, Indice, Accumulatore, Risultato)
% Helper ricorsivo che scorre tutte le posizioni della griglia
%
% Parametri:
%   Stato: configurazione corrente
%   StatoFinale: configurazione target
%   Indice: posizione corrente (1-9)
%   Accumulatore: somma parziale delle distanze
%   Risultato: distanza totale finale

% Caso base: finito di scorrere tutte le 9 posizioni
manhattan_totale(_, _, 10, Acc, Acc) :- !.

% Caso ricorsivo: calcola contributo della tessera nella posizione corrente
manhattan_totale(Stato, StatoFinale, Indice, Acc, Risultato) :-
    nth1(Indice, Stato, Tessera),
    
    (   Tessera =:= 0
    ->  % Il vuoto non contribuisce all'euristica
        AccNuovo = Acc
    ;   % Calcola distanza Manhattan per questa tessera
        nth1(PosizioneTarget, StatoFinale, Tessera), % Determino la posizione corretta della tessera
        indice_posizione(Indice, R1, C1),
        indice_posizione(PosizioneTarget, R2, C2),
        Dist is abs(R1 - R2) + abs(C1 - C2),
        AccNuovo is Acc + Dist
    ),
    
    IndiceProssimo is Indice + 1,
    manhattan_totale(Stato, StatoFinale, IndiceProssimo, AccNuovo, Risultato).



% ============================================
% IDA* - ITERATIVE DEEPENING A* PER PUZZLE DELL'8
% ============================================

% Dichiarazione dei predicati dinamici che useremo per salvare
% la soglia corrente (current_depth/1) e la soglia candidata
% per l'iterazione successiva (next_depth/1).
:- dynamic current_depth/1.
:- dynamic next_depth/1.


% ------------------------------------------------------------
% calcola_fn_puzzle/3
% ------------------------------------------------------------
% calcola_fn_puzzle(+Stato, +Visitati, -Fn)
%
% Questo predicato calcola il valore f(n) = g(n) + h(n)
% per un certo stato del puzzle.
%
% - Stato:    configurazione corrente (lista di 9 elementi)
% - Visitati: lista degli stati già visitati lungo il cammino
%             (ci serve solo per contare la lunghezza del percorso)
% - Fn:       valore f(n) calcolato
%
% g(n) = costo reale dal nodo iniziale
%      = numero di passi fatti
%      = lunghezza della lista Visitati
%
% h(n) = euristica (distanza di Manhattan rispetto allo stato finale)

calcola_fn_puzzle(Stato, Visitati, Fn) :-
    finale(Target),                    % Prendo lo stato finale definito in puzzle.pl
    length(Visitati, Gn),              % g(n): numero di stati nel cammino (passi fatti)
    manhattan_puzzle(Stato, Target, Hn), % h(n): distanza euristica dallo stato finale
    Fn is Gn + Hn.                     % f(n) = g(n) + h(n)


% ------------------------------------------------------------
% ida_limitata_puzzle/4
% ------------------------------------------------------------
% ida_limitata_puzzle(+Stato, +Visitati, -Cammino, +Soglia)
%
% Esegue una ricerca in profondità (DFS) partendo da Stato,
% ma limitando l'esplorazione ai nodi che rispettano la condizione
% f(n) <= Soglia.
%
% - Stato:    stato corrente del puzzle
% - Visitati: lista degli stati già visitati lungo il cammino
% - Cammino:  lista di azioni da eseguire per arrivare a un goal
% - Soglia:   valore massimo consentito per f(n) in questa iterazione

% CASO BASE: se lo stato corrente è quello finale, abbiamo finito.
ida_limitata_puzzle(S, _, [], _) :-
    finale(S),                          % Controllo se S è esattamente lo stato finale
    !.                                  % Taglio (!) per evitare altre soluzioni (ci basta una)

% CASO RICORSIVO:
% 1. Calcolo f(n) sullo stato corrente.
% 2. Se f(n) <= Soglia, provo ad applicare un'azione e mi sposto
%    nello stato successivo.
% 3. Se f(n) > Soglia, non espando questo nodo e aggiorno next_depth.

ida_limitata_puzzle(S, Visitati, [Az|RestoAzioni], Soglia) :-
    calcola_fn_puzzle(S, Visitati, Fn),    % Calcolo f(n) sul nodo corrente
    (   Fn =< Soglia                       % Se f(n) è entro la soglia...
    ->  applicabile(Az, S),                % ...cerco un'azione Az applicabile allo stato S
        trasforma(Az, S, SNuovo),          % calcolo il nuovo stato SNuovo applicando Az
        \+ member(SNuovo, Visitati),       % evito di tornare in uno stato già visitato (niente cicli)
        ida_limitata_puzzle(
            SNuovo,                        % nuovo stato
            [S|Visitati],                  % aggiungo S alla lista degli stati visitati
            RestoAzioni,                   % RestoAzioni conterrà le mosse successive
            Soglia                         % la soglia resta la stessa in questa iterazione
        )
    ;   % Se f(n) supera la soglia, non esploro i successori di questo nodo
        aggiorna_next_depth(Fn),           % salvo Fn come candidato per la soglia della prossima iterazione
        fail                               % fallisco per forzare il backtracking su altri rami
    ).


% ------------------------------------------------------------
% aggiorna_next_depth/1
% ------------------------------------------------------------
% aggiorna_next_depth(+Fn)
%
% Questo predicato mantiene in next_depth/1 il MINIMO valore di f(n)
% che ha superato la soglia corrente. Questo valore diventerà
% la nuova soglia nella prossima iterazione di IDA*.

aggiorna_next_depth(Fn) :-
    current_depth(Soglia),             % leggo la soglia corrente
    Fn > Soglia,                       % considero solo i Fn che la superano
    (   next_depth(Old)                % se esiste già un candidato next_depth
    ->  (   Fn < Old                   % prendo il minimo tra Fn e Old
        ->  retract(next_depth(Old)),  % rimuovo il vecchio valore
            assert(next_depth(Fn))     % e salvo quello nuovo (più piccolo)
        ;   true                       % altrimenti tengo il vecchio (già minore)
        )
    ;   assert(next_depth(Fn))         % se non c'era nessun candidato, salvo direttamente Fn
    ).


% ------------------------------------------------------------
% initialize_ida_puzzle/0
% ------------------------------------------------------------
% initialize_ida_puzzle
%
% Inizializza la soglia per IDA* prima di partire con il loop:
% - ripulisce eventuali valori memorizzati in precedenza
% - legge lo stato iniziale
% - calcola h(stato iniziale)
% - usa questo valore come soglia iniziale (current_depth/1)

initialize_ida_puzzle :-
    retractall(current_depth(_)),          % cancello tutte le vecchie soglie
    retractall(next_depth(_)),             % cancello anche eventuali next_depth rimasti
    iniziale(S),                           % leggo lo stato iniziale del puzzle
    finale(Target),                        % leggo lo stato finale
    manhattan_puzzle(S, Target, H0),       % calcolo h(n) sullo stato iniziale
    assert(current_depth(H0)).             % salvo H0 come soglia iniziale di IDA*


% ------------------------------------------------------------
% ida_star_puzzle/1
% ------------------------------------------------------------
% ida_star_puzzle(-Cammino)
%
% Predicato principale da chiamare per eseguire IDA* sul puzzle.
% Restituisce in Cammino la lista di azioni ottima trovata.

ida_star_puzzle(Cammino) :-
    initialize_ida_puzzle,                 % preparo soglia iniziale e ripulisco lo stato
    ida_star_puzzle_loop(Cammino).         % avvio il loop delle iterazioni


% ------------------------------------------------------------
% ida_star_puzzle_loop/1
% ------------------------------------------------------------
% ida_star_puzzle_loop(-Cammino)
%
% Esegue una singola iterazione di IDA* con la soglia corrente.
% Se non trova una soluzione:
%   - usa next_depth/1 per impostare la nuova soglia
%   - ripete il processo ricorsivamente

ida_star_puzzle_loop(Cammino) :-
    iniziale(S),                           % stato iniziale da cui partire a ogni iterazione
    current_depth(Soglia),                 % leggo la soglia corrente
    retractall(next_depth(_)),             % azzero i candidati per la prossima soglia
    % messaggio di debug per capire l'andamento dell'algoritmo
    write('IDA* Puzzle: iterazione con soglia f(n) = '),
    write(Soglia), nl,
    (
        % Provo a trovare una soluzione con la soglia corrente
        ida_limitata_puzzle(S, [], Cammino, Soglia)
    ->  % CASO: successo, è stata trovata una soluzione
        write('IDA* Puzzle: soluzione trovata!'), nl,
        length(Cammino, Lunghezza),        % calcolo la lunghezza del cammino
        write('Lunghezza cammino: '),
        write(Lunghezza),
        write(' mosse'), nl
    ;   % CASO: nessuna soluzione con questa soglia
        (
            % Se esiste un next_depth, posso tentare un'altra iterazione
            next_depth(NuovaSoglia)
        ->  (
                NuovaSoglia > Soglia       % controllo che la soglia sia realmente cresciuta
            ->  retract(current_depth(_)), % sostituisco la vecchia soglia...
                assert(current_depth(NuovaSoglia)), % ...con la nuova
                ida_star_puzzle_loop(Cammino)       % e ripeto l'algoritmo con la nuova soglia
            ;   % Se la nuova soglia non è maggiore, significa che non c'è più progresso possibile
                write('IDA* Puzzle: nessun progresso possibile.'), nl,
                fail
            )
        ;   % Se non esiste next_depth, non ci sono nodi oltre la soglia → nessuna soluzione
            write('IDA* Puzzle: nessuna soluzione trovata.'), nl,
            fail
        )
    ).


% ============================================
% A* - RICERCA INFORMATA PER PUZZLE DELL'8
% ============================================
%
% Implementiamo ora l'algoritmo A* per il puzzle 8.
% A* mantiene:
%   - una lista OPEN (frontiera) di nodi da espandere, ordinata per f(n)
%   - una lista CLOSED di nodi già espansi
%
% Ogni nodo è rappresentato come:
%   nodo(Stato, Cammino, Gn, Hn, Fn)
% dove:
%   - Stato:   configurazione attuale (lista di 9 elementi)
%   - Cammino: lista di azioni per arrivare a Stato (in ordine inverso)
%   - Gn:      costo reale dal nodo iniziale (lunghezza del cammino)
%   - Hn:      euristica (distanza Manhattan dallo stato finale)
%   - Fn:      Fn = Gn + Hn (stima del costo totale)


% ------------------------------------------------------------
% crea_nodo_iniziale_puzzle/1
% ------------------------------------------------------------
% crea_nodo_iniziale_puzzle(-Nodo)
%
% Costruisce il nodo iniziale per A* sul puzzle:
% - lo stato iniziale S
% - cammino vuoto []
% - costo reale Gn = 0
% - euristica Hn calcolata con Manhattan
% - f(n) = Gn + Hn

crea_nodo_iniziale_puzzle(nodo(S, [], 0, Hn, Fn)) :-
    iniziale(S),                          % leggo lo stato iniziale del puzzle
    finale(Target),                       % leggo lo stato finale
    manhattan_puzzle(S, Target, Hn),      % calcolo l'euristica h(n) sullo stato iniziale
    Fn is 0 + Hn.                         % f(n) = g(n) + h(n) = 0 + Hn


% ------------------------------------------------------------
% genera_successori_puzzle/2
% ------------------------------------------------------------
% genera_successori_puzzle(+Nodo, -Successori)
%
% Genera tutti i nodi successori validi applicando le azioni
% possibili allo stato corrente S.

genera_successori_puzzle(nodo(S, Cammino, Gn, _, _), Successori) :-
    finale(Target),                       % lo stato finale è sempre lo stesso
    findall(
        nodo(SNuovo, [Az|Cammino], GnNuovo, HnNuovo, FnNuovo),
        (
            applicabile(Az, S),           % prendo un'azione Az applicabile allo stato S
            trasforma(Az, S, SNuovo),     % calcolo il nuovo stato SNuovo applicando Az
            GnNuovo is Gn + 1,            % il costo reale aumenta di 1 (una mossa in più)
            manhattan_puzzle(SNuovo, Target, HnNuovo), % ricalcolo h(n) sul nuovo stato
            FnNuovo is GnNuovo + HnNuovo  % f(n) = g(n) + h(n) per il successore
        ),
        Successori                        % lista di tutti i nodi successori generati
    ).


% ------------------------------------------------------------
% inserisci_ordinato_puzzle/3
% ------------------------------------------------------------
% inserisci_ordinato_puzzle(+Nodo, +Coda, -NuovaCoda)
%
% Inserisce un nodo nella coda (lista) OPEN mantenendo
% l'ordine crescente rispetto a f(n).

% Caso base: coda vuota, il nuovo nodo diventa l'unico elemento.
inserisci_ordinato_puzzle(Nodo, [], [Nodo]).

% Se il nuovo nodo ha f(n) <= f(n) del primo elemento,
% lo inserisco in testa e mantengo il resto invariato.
inserisci_ordinato_puzzle(
    nodo(S, C, G, H, F),
    [nodo(S1, C1, G1, H1, F1)|Resto],
    [nodo(S, C, G, H, F), nodo(S1, C1, G1, H1, F1)|Resto]
) :-
    F =< F1,
    !.  % taglio: non cerco altre possibilità, questa è la posizione giusta

% Altrimenti lascio il primo elemento dov'è e provo a inserire nel resto.
inserisci_ordinato_puzzle(Nodo, [Primo|Resto], [Primo|NuovaCoda]) :-
    inserisci_ordinato_puzzle(Nodo, Resto, NuovaCoda).


% ------------------------------------------------------------
% inserisci_lista_ordinata_puzzle/3
% ------------------------------------------------------------
% inserisci_lista_ordinata_puzzle(+ListaNodi, +Coda, -NuovaCoda)
%
% Inserisce una lista di nodi nella coda OPEN, uno alla volta,
% mantenendo l'ordinamento per f(n).

inserisci_lista_ordinata_puzzle([], Coda, Coda).  % nessun nodo da inserire

inserisci_lista_ordinata_puzzle([N|Resto], Coda, NuovaCoda) :-
    inserisci_ordinato_puzzle(N, Coda, CodaTemp),        % inserisco N nella coda
    inserisci_lista_ordinata_puzzle(Resto, CodaTemp, NuovaCoda).


% ------------------------------------------------------------
% stato_in_closed_puzzle/2
% ------------------------------------------------------------
% stato_in_closed_puzzle(+Stato, +Closed)
%
% Verifica se uno stato è già nella lista CLOSED
% (cioè se è già stato espanso).

stato_in_closed_puzzle(Stato, Closed) :-
    member(nodo(Stato, _, _, _, _), Closed).


% ------------------------------------------------------------
% stato_in_open_puzzle/2
% ------------------------------------------------------------
% stato_in_open_puzzle(+Stato, +Open)
%
% Verifica se uno stato è già presente nella coda OPEN.

stato_in_open_puzzle(Stato, Open) :-
    member(nodo(Stato, _, _, _, _), Open).


% ------------------------------------------------------------
% rimuovi_stato_peggiore_puzzle/4
% ------------------------------------------------------------
% rimuovi_stato_peggiore_puzzle(+Stato, +FnNuovo, +Open, -OpenAggiornata)
%
% Se lo stato appare già in OPEN con un valore di f(n) peggiore
% (maggiore) di FnNuovo, lo rimuove. In questo modo possiamo
% sostituirlo con un percorso migliore che porta allo stesso stato.

% Caso base: coda vuota, non c'è nulla da rimuovere.
rimuovi_stato_peggiore_puzzle(_, _, [], []).

% Se il primo elemento della coda ha lo stesso Stato e f(n) peggiore,
% lo elimino (ritornando solo il resto).
rimuovi_stato_peggiore_puzzle(
    Stato,
    FnNuovo,
    [nodo(Stato, _, _, _, FnVecchio)|Resto],
    Resto
) :-
    FnNuovo < FnVecchio,
    !.

% Altrimenti mantengo il primo elemento e continuo a cercare nel resto.
rimuovi_stato_peggiore_puzzle(Stato, FnNuovo, [Primo|Resto], [Primo|RestoAgg]) :-
    rimuovi_stato_peggiore_puzzle(Stato, FnNuovo, Resto, RestoAgg).


% ------------------------------------------------------------
% filtra_successori_puzzle/5
% ------------------------------------------------------------
% filtra_successori_puzzle(+Successori, +Open, +Closed,
%                          -SuccessoriFiltrati, -OpenAggiornata)
%
% Applica le regole tipiche di A* per gestire i successori:
%   - se un successore è in CLOSED: lo scarto
%   - se è in OPEN con f(n) peggiore: rimuovo la versione peggiore
%     da OPEN e tengo il nuovo
%   - altrimenti: tengo il successore così com'è

filtra_successori_puzzle([], Open, _, [], Open).  % nessun successore da gestire

filtra_successori_puzzle(
    [nodo(S, C, G, H, F)|Resto],
    Open,
    Closed,
    Filtrati,
    OpenFinale
) :-
    (   stato_in_closed_puzzle(S, Closed)        % se lo stato è già stato espanso
    ->  % lo scarto e passo ai successori rimanenti
        filtra_successori_puzzle(Resto, Open, Closed, Filtrati, OpenFinale)
    ;   stato_in_open_puzzle(S, Open)           % se è già presente in OPEN
    ->  rimuovi_stato_peggiore_puzzle(S, F, Open, OpenTemp),
        filtra_successori_puzzle(Resto, OpenTemp, Closed, FiltratiResto, OpenFinale),
        Filtrati = [nodo(S, C, G, H, F)|FiltratiResto]
    ;   % stato nuovo: non è né in OPEN né in CLOSED
        filtra_successori_puzzle(Resto, Open, Closed, FiltratiResto, OpenFinale),
        Filtrati = [nodo(S, C, G, H, F)|FiltratiResto]
    ).


% ------------------------------------------------------------
% a_star_puzzle/1
% ------------------------------------------------------------
% a_star_puzzle(-Cammino)
%
% Predicato principale per eseguire A* sul puzzle dell'8.
% Restituisce in Cammino la lista di azioni ottima.

a_star_puzzle(Cammino) :-
    crea_nodo_iniziale_puzzle(NodoIniziale),    % costruisco il nodo iniziale
    write('A* Puzzle: inizializzazione completata'), nl,
    % chiamo il loop principale con:
    %   OPEN   = [NodoIniziale]
    %   CLOSED = []
    a_star_puzzle_loop([NodoIniziale], [], Cammino).


% ------------------------------------------------------------
% a_star_puzzle_loop/3
% ------------------------------------------------------------
% a_star_puzzle_loop(+Open, +Closed, -Cammino)
%
% Ciclo principale di A*:
% - Estrae il nodo con f(n) minimo da OPEN
% - Se è goal: restituisce il cammino
% - Altrimenti: genera e filtra i successori, aggiorna OPEN e CLOSED,
%   e continua ricorsivamente.

% CASO BASE 1: se OPEN è vuota, non ci sono più nodi da espandere
% → non esiste soluzione.
a_star_puzzle_loop([], _, _) :-
    write('A* Puzzle: nessuna soluzione trovata!'), nl,
    fail.

% CASO BASE 2: il primo nodo in OPEN è già lo stato finale.
% Grazie all'ordinamento per f(n), il cammino trovato è ottimo.
a_star_puzzle_loop([nodo(S, Cammino, _, _, Fn)|_], _, CamminoFinale) :-
    finale(Target),
    S = Target,                                % controllo se S coincide con lo stato finale
    !,                                         % taglio: non cerco altre soluzioni
    reverse(Cammino, CamminoFinale),           % Cammino è costruito al contrario, lo inverto
    write('A* Puzzle: soluzione trovata! '),
    write('[f(n)='), write(Fn), write(']'), nl.

% CASO RICORSIVO:
% - prendo il nodo con f(n) minimo da OPEN (NodoCorrente)
% - genero i suoi successori
% - filtro i successori in base a OPEN e CLOSED
% - inserisco i successori filtrati in OPEN (mantenendo l'ordine)
% - aggiungo NodoCorrente a CLOSED e continuo.

a_star_puzzle_loop([NodoCorrente|RestoOpen], Closed, Cammino) :-
    NodoCorrente = nodo(S, _, _, _, Fn),
    write('A* Puzzle: espando stato '), write(S),
    write(' [f(n)='), write(Fn), write(']'), nl,
    genera_successori_puzzle(NodoCorrente, Successori),        % genero successori di S
    filtra_successori_puzzle(Successori, RestoOpen, Closed,    % applico regole A* sui successori
                             SuccessoriFiltrati, OpenAggiornata),
    inserisci_lista_ordinata_puzzle(SuccessoriFiltrati,        % inserisco i successori in OPEN
                                    OpenAggiornata,
                                    NuovaOpen),
    a_star_puzzle_loop(NuovaOpen, [NodoCorrente|Closed], Cammino).
