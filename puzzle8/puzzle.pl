% Stato = lista di 9 elementi
% 0 rappresenta la casella vuota
% Esempio: [1,2,3,4,5,6,7,8,0]
%   1 2 3
%   4 5 6
%   7 8 0

iniziale([2,8,3,1,6,4,7,0,5]).
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