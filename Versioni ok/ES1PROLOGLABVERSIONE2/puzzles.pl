% ============================================================
% PROGETTO PROLOG / CLINGO 2024-2025
% Modulo: puzzles
% Implementazione puzzle e delle sue euristiche
% Autore: [Nome Cognome]
% ============================================================

:- module(puzzles, [goal/1, h/2, successor/3, manhattan2/2, h_misplaced/2]).

% ------------------------------------------------------------
% Stato obiettivo del puzzle
% ------------------------------------------------------------
goal([1,2,3,4,5,6,7,8,0]).

% ------------------------------------------------------------
% Indici dei vicini
% ------------------------------------------------------------
neighbors_index(0, [1,3]).
neighbors_index(1, [0,2,4]).
neighbors_index(2, [1,5]).
neighbors_index(3, [0,4,6]).
neighbors_index(4, [1,3,5,7]).
neighbors_index(5, [2,4,8]).
neighbors_index(6, [3,7]).
neighbors_index(7, [4,6,8]).
neighbors_index(8, [5,7]).

% ------------------------------------------------------------
% Swap e set_nth0
% ------------------------------------------------------------
swap_positions(List, I, J, Res) :-
    nth0(I, List, ElemI),
    nth0(J, List, ElemJ),
    set_nth0(I, List, ElemJ, Tmp),
    set_nth0(J, Tmp, ElemI, Res).

set_nth0(Index, List, Value, Result) :-
    length(List, Len),
    length(Result, Len),
    set_nth0_helper(0, Index, List, Value, Result).

set_nth0_helper(Index, Index, [_|Tail], Value, [Value|Tail]).
set_nth0_helper(Current, Index, [Head|Tail], Value, [Head|Result]) :-
    Current \= Index,
    Next is Current + 1,
    set_nth0_helper(Next, Index, Tail, Value, Result).

% ------------------------------------------------------------
% Successori
% ------------------------------------------------------------
successor(State, Next, Cost) :-
    nth0(BlankIndex, State, 0),
    neighbors_index(BlankIndex, Neighbors),
    member(NeighborIndex, Neighbors),
    swap_positions(State, BlankIndex, NeighborIndex, Next),
    Cost = 1.

% ------------------------------------------------------------
% Euristica: Tiles fuori posto (non conta il blank)
% ------------------------------------------------------------
h_misplaced(State, H) :-
    goal(Goal),
    misplaced_sum(State, Goal, 0, H).

misplaced_sum([], [], H, H).
misplaced_sum([S|State], [G|Goal], Acc, H) :-
    (   S \= 0, S \= G  % Solo tile numerate, blank non conta
    ->  NewAcc is Acc + 1
    ;   NewAcc = Acc
    ),
    misplaced_sum(State, Goal, NewAcc, H).

% ------------------------------------------------------------
% Euristica: Manhattan distance (NON CONTA IL BLANK)
% ------------------------------------------------------------
manhattan2(State, H) :-
    manhattan_sum(State, 0, 0, H).

manhattan_sum([], _, H, H).
manhattan_sum([Tile|Rest], Index, Acc, Total) :-
    (   Tile \= 0  % SOLO TILE NUMERATE - IL BLANK (0) NON CONTA!
    ->  GoalPos is Tile - 1,          % Tile 1 -> index 0, etc.
        CurrRow is Index // 3,
        CurrCol is Index mod 3,
        GoalRow is GoalPos // 3,
        GoalCol is GoalPos mod 3,
        Dist is abs(GoalRow - CurrRow) + abs(GoalCol - CurrCol),
        NewAcc is Acc + Dist
    ;   NewAcc = Acc  % Blank: distanza 0 (non contiamo il blank)
    ),
    NextIndex is Index + 1,
    manhattan_sum(Rest, NextIndex, NewAcc, Total).

% ------------------------------------------------------------
% Euristica principale (usa Manhattan)
% ------------------------------------------------------------
h(State, H) :-
    manhattan2(State, H).