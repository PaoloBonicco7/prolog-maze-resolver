% ============================================================
% PROGETTO PROLOG / CLINGO 2024-2025
% Modulo: maze
% Rappresentazione e ricerca nel labirinto 4x4
% Autore: [Nome Cognome]
% ============================================================

% ------------------------------------------------------------
% Celle valide (coordinate tra 1 e 4)
% ------------------------------------------------------------
valid(pos(X,Y)) :-
    between(1,4,X),
    between(1,4,Y),
    \+ wall(X,Y).

% ------------------------------------------------------------
% Pareti del labirinto (configurazione di esempio)
% ------------------------------------------------------------
wall(2,2).
wall(3,2).
wall(2,4).
wall(4,3).

% ------------------------------------------------------------
% Stato obiettivo: ALMENO DUE USCITE (richiesta PDF)
% ------------------------------------------------------------
goal_maze(pos(4,4)).  % prima uscita
goal_maze(pos(1,4)).  % seconda uscita (non raggiungibile con muri dati)

% ------------------------------------------------------------
% Mosse possibili (spostamenti cardinali)
% ------------------------------------------------------------
move(pos(X,Y), pos(X1,Y)) :- X1 is X + 1, valid(pos(X1,Y)).
move(pos(X,Y), pos(X1,Y)) :- X1 is X - 1, valid(pos(X1,Y)).
move(pos(X,Y), pos(X,Y1)) :- Y1 is Y + 1, valid(pos(X,Y1)).
move(pos(X,Y), pos(X,Y1)) :- Y1 is Y - 1, valid(pos(X,Y1)).

% ------------------------------------------------------------
% Successori per il labirinto
% ------------------------------------------------------------
successor_maze(State, Next, 1) :-
    move(State, Next).

% ------------------------------------------------------------
% Euristica Manhattan per il labirinto
% ------------------------------------------------------------
h_maze(pos(X,Y), H) :-
    goal_maze(pos(GX,GY)),  % Prende il PRIMO goal trovato
    H is abs(GX - X) + abs(GY - Y).