% ============================================================
% PROGETTO PROLOG / CLINGO 2024-2025
% Implementazione dell'algoritmo A* (versione universale)
% Autore: [Nome Cognome]
% ============================================================

:- use_module(puzzles, [goal/1, h/2]).
:- consult('maze.pl').

% ------------------------------------------------------------
% Predicato principale: A* generico (funziona su puzzle e maze)
% ------------------------------------------------------------
astar(Start, Path, Cost) :-
    (   is_list(Start)
    ->  puzzles:h(Start, H)       % Se è lista, è l'8-puzzle
    ;   h_maze(Start, H)          % Se è pos(X,Y), è il labirinto
    ),
    astar_open([node(Start, [], 0, H)], [], Path, Cost).

% ------------------------------------------------------------
% Caso base: raggiunto il goal
% ------------------------------------------------------------
astar_open([node(State, Path, G, _)|_], _, FinalPath, Cost) :-
    (   is_list(State)
    ->  puzzles:goal(State)
    ;   goal_maze(State)
    ),
    reverse([State|Path], FinalPath),
    Cost = G.

% ------------------------------------------------------------
% Caso ricorsivo: espansione dei nodi (VERSIONE CORRETTA)
% ------------------------------------------------------------
astar_open([node(State, Path, G, _)|RestOpen], Visited, FinalPath, Cost) :-
    findall(
        node(Next, [State|Path], G1, H1),
        (
            get_successor(State, Next),
            \+ member(Next, Visited),
            \+ member_state_open(Next, RestOpen),  % EVITA DOPPIONI IN OPEN
            G1 is G + 1,
            get_heuristic(Next, H1)
        ),
        Children
    ),
    append(RestOpen, Children, Unsorted),
    sort_by_f(Unsorted, SortedOpen),
    astar_open(SortedOpen, [State|Visited], FinalPath, Cost).

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
% Utility per la gestione delle coppie chiave-valore
% ------------------------------------------------------------
map_list_to_pairs(_, [], []).
map_list_to_pairs(Pred, [X|Xs], [K-X|Pairs]) :-
    Goal =.. [Pred, X, K],
    call(Goal),
    map_list_to_pairs(Pred, Xs, Pairs).

pairs_values([], []).
pairs_values([_-V|Pairs], [V|Values]) :-
    pairs_values(Pairs, Values).