% ============================================
% Labirinto - Definizione del problema
% ============================================

% Dimensioni del labirinto
num_col(10).
num_righe(10).

% Posizione iniziale dell'Agente
iniziale(pos(1, 1)).

% Celle occupate (ostacoli)
occupata(pos(1, 7)).
occupata(pos(1, 8)).
occupata(pos(1, 9)).
occupata(pos(1, 10)).
occupata(pos(3, 5)).
occupata(pos(4, 1)).
occupata(pos(4, 2)).
occupata(pos(4, 3)).
occupata(pos(4, 5)).
occupata(pos(5, 5)).
occupata(pos(6, 1)).
occupata(pos(6, 2)).
occupata(pos(6, 3)).
occupata(pos(6, 5)).
occupata(pos(6, 8)).
occupata(pos(6, 9)).
occupata(pos(6, 10)).
occupata(pos(7, 3)).
occupata(pos(7, 5)).
occupata(pos(8, 3)).
occupata(pos(9, 3)).
occupata(pos(9, 4)).
occupata(pos(9, 5)).
occupata(pos(9, 6)).

% Uscite possibili (lista di posizioni finali)
finale([pos(5, 10), pos(7, 1)]).
