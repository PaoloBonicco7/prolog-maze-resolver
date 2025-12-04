:- module(puzzles, [goal/1, h/2, successor/3, manhattan2/2, h_misplaced/2]).

% ------------------------------------------------------------
% Stato obiettivo del puzzle
goal([1,2,3,4,5,6,7,8,0]).

% ------------------------------------------------------------
% Indici dei vicini
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
% Swap e set_nth0 (utilità che modificano el in liste ad un dato indice)
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
successor(State, Next, Cost) :-
    nth0(BlankIndex, State, 0),
    neighbors_index(BlankIndex, Neighbors),
    member(NeighborIndex, Neighbors),
    swap_positions(State, BlankIndex, NeighborIndex, Next),
    Cost = 1.

% ------------------------------------------------------------
% Euristica:  (non conta il blank, ossia lo spazio vuoto)
% conta il numero di pezzi fuori posto; gli passo in input lo stato corrente e in output euristica
% ------------------------------------------------------------
h_misplaced(State, H) :-
    goal(Goal),
    misplaced_sum(State, Goal, 0, H).

misplaced_sum([], [], H, H). % Caso base: liste vuote
%   [S|State]: Stato corrente (elemento per elemento)
%   [G|Goal]: Stato goal corrispondente
%   Acc: Accumulatore (contatore tessere fuori posto)
%   H: Risultato finale
misplaced_sum([S|State], [G|Goal], Acc, H) :- % Ricorsione
    (   S \= 0, S \= G  % no contare il blank (0), non è nella posizione giusta il goal
    ->  NewAcc is Acc + 1 % incremento per tessera fuoriposto
    ;   NewAcc = Acc
    ),
    misplaced_sum(State, Goal, NewAcc, H).

% ------------------------------------------------------------
% Euristica: Manhattan distance (NON CONTA IL BLANK)
% ------------------------------------------------------------
% ------------------------------------------------------------
% Euristica: Distanza di Manhattan (NON CONTA IL BLANK)
% ------------------------------------------------------------

% manhattan2/2: Calcola la somma delle distanze Manhattan delle tessere
% Parametri:
%   State: Stato corrente 8-puzzle (lista di 9 elementi)
%   H: Valore euristico (somma distanze Manhattan)
manhattan2(State, H) :-
    manhattan_sum(State, 0, 0, H).  % Inizia ricorsione con indice=0, accumulatore=0

% manhattan_sum/4: Predicato ricorsivo helper per calcolare la somma Manhattan
% Parametri:
%   [Tile|Rest]: Lista tessere da processare (corrente + resto)
%   Index: Indice corrente nella lista (0-based) → posizione attuale della tessera
%   Acc: Accumulatore (somma parziale delle distanze)
%   Total: Risultato finale (somma totale)

% Caso base: lista vuota, restituisce accumulatore
manhattan_sum([], _, H, H).

% Caso ricorsivo: processa una tessera alla volta
manhattan_sum([Tile|Rest], Index, Acc, Total) :-
    % Controlla se la tessera corrente è NUMERATA (non blank)
    (   Tile \= 0  % SOLO TILE NUMERATE - IL BLANK (0) NON CONTA!
      % CALCOLO DISTANZA MANHATTAN per questa tessera:
        
        % 1. Determina POSIZIONE GOAL della tessera:
        %    Tile=1 → GoalPos=0, Tile=2 → GoalPos=1, ..., Tile=8 → GoalPos=7
        GoalPos is Tile - 1,
        
        % 2. Calcola COORDINATE ATTUALI dalla posizione nella lista:
        %    Converti indice lineare in coordinate di griglia 3x3
        %    Es: Index=4 → (row=1, col=1) centro
        CurrRow is Index // 3,  % Divisione intera → riga (0,1,2)
        CurrCol is Index mod 3, % Modulo → colonna (0,1,2)
        
        % 3. Calcola COORDINATE GOAL dalla posizione goal:
        GoalRow is GoalPos // 3,
        GoalCol is GoalPos mod 3,
        
        % 4. Calcola DISTANZA MANHATTAN:
        %    |Δriga| + |Δcolonna|
        Dist is abs(GoalRow - CurrRow) + abs(GoalCol - CurrCol),
        
        % 5. Aggiorna accumulatore
        NewAcc is Acc + Dist
    
    ;   % SE è il BLANK (Tile = 0):
        NewAcc = Acc  % Blank: distanza 0 % NON CONTRIBUISCE euristica!
    ),
    
    % Prepara per la prossima iterazione:
    NextIndex is Index + 1,  % Incrementa indice per prossima tessera
    
    % Chiamata ricorsiva per le tessere rimanenti
    manhattan_sum(Rest, NextIndex, NewAcc, Total).

% ------------------------------------------------------------
% Euristica principale (usa Manhattan)
% ------------------------------------------------------------
h(State, H) :-
    manhattan2(State, H).