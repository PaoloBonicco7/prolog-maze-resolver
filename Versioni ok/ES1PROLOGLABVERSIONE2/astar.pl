:- use_module(puzzles, [goal/1, h/2]).
:- consult('maze.pl').

% ------------------------------------------------------------
% Predicato principale: A* generico (funziona su puzzle e labirinto)
% ------------------------------------------------------------

% astar/3: Implementazione generica algoritmo A*
% Parametri:
%   Start: Stato iniziale (lista per puzzle, pos(X,Y) per labirinto)
%   Path: Percorso soluzione (lista di stati dal goal a Start, invertita)
%   Cost: Costo totale del percorso (numero di mosse)

astar(Start, Path, Cost) :-
    % --------------------------------------------------------
    % 1. DETERMINA IL TIPO DI PROBLEMA E CALCOLA EURISTICA INIZIALE
    % --------------------------------------------------------
    (   is_list(Start)          % Controlla se Start è una lista
    ->  puzzles:h(Start, H)     % SE VERO: è un 8-puzzle
                                  % - Usa il modulo puzzles
                                  % - Calcola euristica h(Start, H)
    ;   h_maze(Start, H)        % SE FALSO: è un labirinto
                                  % - Usa predicato h_maze/2
                                  % - Calcola euristica Manhattan per labirinto
    ),
    
    % --------------------------------------------------------
    % 2. INIZIALIZZA LA RICERCA A*
    % --------------------------------------------------------
    % Crea nodo iniziale e chiama astar_open/4
    astar_open([node(Start, [], 0, H)], [], Path, Cost).
    %                    ↑       ↑   ↑    ↑
    %                    stato  path g    h   f = g + h (calcolato dopo)
    %
    % node/4 rappresenta: node(State, PathToHere, Gcost, Heuristic)
    %
    % Parametri per astar_open/4:
    %   [node(...)]: Lista OPEN (frontiera) - inizialmente solo nodo iniziale
    %   []: Lista CLOSED (visitati) - inizialmente vuota
    %   Path: Variabile per il percorso soluzione (output)
    %   Cost: Variabile per il costo (output)



% ------------------------------------------------------------
% CASO BASE di astar_open/4: RAGGIUNTO IL GOAL
% ------------------------------------------------------------

% astar_open (caso base): Gestisce il raggiungimento dello stato goal
% Parametri:
%   [node(State, Path, G, _)|_]: Pattern matching sul primo nodo in OPEN
%   _: Lista CLOSED (ignorata in questo caso)
%   FinalPath: Percorso soluzione finale (output)
%   Cost: Costo totale della soluzione (output)

astar_open([node(State, Path, G, _)|_], _, FinalPath, Cost) :-
    % --------------------------------------------------------
    % 1. CONTROLLA SE LO STATO CORRENTE È UN GOAL
    % --------------------------------------------------------
    (   is_list(State)           % Stato è una lista? (8-puzzle)
    ->  puzzles:goal(State)      % TRUE: controlla goal del puzzle
    ;   goal_maze(State)         % FALSE: controlla goal del labirinto
    ),
    
    % --------------------------------------------------------
    % 2. COSTRUISCI IL PERCORSO SOLUZIONE
    % --------------------------------------------------------
    % Path contiene: [Stato_precedente, Stato_pre_precedente, ..., Start]
    % (percorso INVERTO dal goal allo start)
    reverse([State|Path], FinalPath),
    % [State|Path] = [Goal, Stato_n-1, Stato_n-2, ..., Start]
    % reverse/2 inverte: [Start, ..., Stato_n-2, Stato_n-1, Goal]
    
    % --------------------------------------------------------
    % 3. IMPOSTA IL COSTO DELLA SOLUZIONE
    % --------------------------------------------------------
    Cost = G.  % G è il costo accumulato per raggiungere questo stato


% ------------------------------------------------------------
% CASO RICORSIVO di astar_open/4: ESPANSIONE DEI NODI
% ------------------------------------------------------------

% astar_open/4 (caso ricorsivo): Espande il nodo corrente e continua la ricerca
% Parametri:
%   [node(State, Path, G, _)|RestOpen]: Nodo corrente + resto della frontiera
%   Visited: Lista degli stati già visitati (CLOSED set)
%   FinalPath: Percorso soluzione (output)
%   Cost: Costo totale (output)

astar_open([node(State, Path, G, _)|RestOpen], Visited, FinalPath, Cost) :-
    % --------------------------------------------------------
    % 1. GENERAZIONE DEI FIGLI (successori validi)
    % --------------------------------------------------------
    % findall/3: Raccoglie TUTTI i nodi figli che soddisfano le condizioni
    findall(
        % Template: struttura del nodo figlio
        node(Next, [State|Path], G1, H1),
        
        % Condizioni per generare un figlio:
        (
            get_successor(State, Next),      % A. Genera un successore
            \+ member(Next, Visited),        % B. Non già visitato (CLOSED)
            \+ member_state_open(Next, RestOpen), % C. Non già in OPEN
            G1 is G + 1,                     % D. Calcola costo g(n)
            get_heuristic(Next, H1)          % E. Calcola euristica h(n)
        ),
        
        % Risultato: lista di nodi figli
        Children
    ),
    
    % --------------------------------------------------------
    % 2. AGGIORNAMENTO DELLA FRONTIERA (OPEN LIST)
    % --------------------------------------------------------
    % Combina nodi non ancora espansi con i nuovi figli
    append(RestOpen, Children, Unsorted),
    % RestOpen: nodi dalla vecchia OPEN (escluso quello corrente)
    % Children: nuovi nodi generati
    % Unsorted: OPEN temporanea non ordinata
    
    % Ordina la frontiera per f = g + h (crescente)
    sort_by_f(Unsorted, SortedOpen),
    
    % --------------------------------------------------------
    % 3. CHIAMATA RICORSIVA
    % --------------------------------------------------------
    % Continua la ricerca con:
    astar_open(SortedOpen,               % Nuova OPEN (ordinata)
               [State|Visited],          % Nuovo CLOSED (aggiungi stato corrente)
               FinalPath, Cost).         % Output





% Controlla se uno stato è già nella lista open
member_state_open(State, [node(S,_,_,_)|Rest]) :- 
    (State == S -> true ; member_state_open(State, Rest)).

% ------------------------------------------------------------
% Gestione dei domini (puzzle / labirinto)
% ------------------------------------------------------------
get_successor(State, Next) :-
    (   is_list(State)
    ->  puzzles:successor(State, Next, 1)
    ;   successor_maze(State, Next, 1)
    ).

get_heuristic(State, H) :-
    (   is_list(State)
    ->  puzzles:h(State, H)
    ;   h_maze(State, H)
    ).

% ------------------------------------------------------------
% Ordinamento dei nodi in base al costo f = g + h
% ------------------------------------------------------------
sort_by_f(Nodes, Sorted) :-
    map_list_to_pairs(node_f, Nodes, Pairs),
    keysort(Pairs, SortedPairs),
    pairs_values(SortedPairs, Sorted).

node_f(node(_, _, G, H), F) :-
    F is G + H.

% ------------------------------------------------------------
% UTILITY PER LA GESTIONE DELLE COPPIE CHIAVE-VALORE
% (Implementazione di una map in Prolog)
% ------------------------------------------------------------

% map_list_to_pairs/3: Trasforma una lista in lista di coppie chiave-valore
% Parametri:
%   Pred: Nome del predicato che calcola la chiave per un elemento
%   [X|Xs]: Lista di input da trasformare
%   [K-X|Pairs]: Lista di output di coppie chiave-valore

% Caso base: lista vuota
map_list_to_pairs(_, [], []).

% Caso ricorsivo: processa un elemento alla volta
map_list_to_pairs(Pred, [X|Xs], [K-X|Pairs]) :-
    % --------------------------------------------------------
    % 1. COSTRUISCI E CHIAMA IL GOAL DINAMICAMENTE
    % --------------------------------------------------------
    % Goal =.. [Pred, X, K]  Crea un termine da lista
    % Es: Se Pred = node_f, X = node(...), K = F
    %     Diventa: node_f(node(...), F)
    Goal =.. [Pred, X, K],  % Univ operator: univoca lista in termine
    
    % Esegue il predicato: calcola K per elemento X
    call(Goal),  % Equivalente a: node_f(X, K)
    
    % --------------------------------------------------------
    % 2. CHIAMATA RICORSIVA PER GLI ALTRI ELEMENTI
    % --------------------------------------------------------
    map_list_to_pairs(Pred, Xs, Pairs).

% pairs_values/2: Estrae solo i valori da una lista di coppie chiave-valore
% Parametri:
%   [_-V|Pairs]: Lista di coppie (chiave ignorata, valore V)
%   [V|Values]: Lista di soli valori

% Caso base: lista vuota
pairs_values([], []).

% Caso ricorsivo: estrai valore dalla coppia corrente
pairs_values([_-V|Pairs], [V|Values]) :-
    % _: Ignora la chiave (usa variabile anonima)
    % V: Prendi il valore
    pairs_values(Pairs, Values).  % Ricorsione sulla coda