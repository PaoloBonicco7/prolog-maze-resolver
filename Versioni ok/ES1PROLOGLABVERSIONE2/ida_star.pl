% PROGETTO PROLOG/CLINGO 2024-2025
% Implementazione algoritmo IDA* - VERSIONE UNIVERSALE
% Autore: [Inserire Nome Cognome]

:- use_module(puzzles, [goal/1, h/2]).
:- consult('maze.pl').

% IDA* - Implementazione principale
ida_star(Start, Path, Cost) :-
    get_heuristic(Start, H0),
    between(H0, 50, Bound),
    depth_limited([Start], 0, Bound, Path, Cost).

% Ricerca depth-limited
depth_limited([State|Path], G, Bound, FinalPath, Cost) :-
    get_heuristic(State, H),
    F is G + H,
    (F > Bound -> fail        % Supera bound, fallisce
    ; get_goal(State) ->      % Trovato goal
        reverse([State|Path], FinalPath),
        Cost = G
    ;                        % Espandi
        get_successor(State, Next),
        \+ member(Next, [State|Path]),
        G1 is G + 1,
        depth_limited([Next, State|Path], G1, Bound, FinalPath, Cost)
    ).

% Successore per puzzle o maze
get_successor(State, Next) :-
    (is_list(State) -> 
        puzzles:successor(State, Next, 1)
    ; 
        successor_maze(State, Next, 1)
    ).

% Euristica per puzzle o maze
get_heuristic(State, H) :-
    (is_list(State) -> 
        puzzles:h(State, H)
    ; 
        h_maze(State, H)
    ).

% Goal per puzzle o maze
get_goal(State) :-
    (is_list(State) -> 
        puzzles:goal(State)
    ; 
        goal_maze(State)
    ).