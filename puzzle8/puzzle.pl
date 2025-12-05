% Stato = lista di 9 elementi
% 0 rappresenta la casella vuota
% Esempio: [1,2,3,4,5,6,7,8,0]
%   1 2 3
%   4 5 6
%   7 8 0

% iniziale([0,1,2,3,4,5,6,7,8]). % iniziale semplice
% iniziale([1,2,3,4,5,6,0,7,8]). % 2 mosse
% iniziale([1,2,3,5,0,6,4,7,8]). % 4 mosse
% iniziale([0,1,3,7,2,4,8,6,5]). % 10 mosse
% iniziale([2,5,7,1,4,3,8,0,6]). % 15 mosse
% iniziale([2,8,0,7,4,3,5,1,6]). % 20 mosse
% iniziale([7,3,5,4,2,1,6,0,8]). % 25 mosse
% iniziale([7,8,0,4,5,6,3,2,1]). % 30 mosse
iniziale([6,4,7,8,5,0,3,2,1]). % 31 mosse


finale([1,2,3,4,5,6,7,8,0]).

% posizione_indice/3
% Converte una posizione (Riga, Colonna) in un Indice (posizione numerata lo schema base riportato all'inizio)
posizione_indice(Riga, Col, Indice):-
    Riga >= 1, Riga =< 3,
    Col >= 1, Col =< 3,
    Indice is (Riga - 1) * 3 + Col.

% indice_posizione/3
% Predicato inverso a quella precedente
indice_posizione(Indice, Riga, Col) :-
    Indice >= 1, Indice =< 9,           % Guardia: Indice valido
    Riga is ((Indice - 1) // 3) + 1,    % Divisione intera
    Col is ((Indice - 1) mod 3) + 1.    % Resto della divisione