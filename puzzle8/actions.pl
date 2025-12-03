:- dynamic indice_posizione/3, posizione_indice/3.

% ============================================
% AZIONI - Movimento del Vuoto
% ============================================

% trova_vuoto/2
% Trova la posizione (indice) della casella vuota (0) nello stato
% Stato: lista di 9 elementi
% Indice: posizione del vuoto (1-9)
trova_vuoto(Stato, Indice) :-
    nth1(Indice, Stato, 0).   % nth1 - perchè indice parte da 1 e non da 0

% stampa_stato(Stato)
% Stampa lo stato in formato griglia (utile per debug)

stampa_stato(Stato) :-
    nth1(1, Stato, T1), nth1(2, Stato, T2), nth1(3, Stato, T3),
    nth1(4, Stato, T4), nth1(5, Stato, T5), nth1(6, Stato, T6),
    nth1(7, Stato, T7), nth1(8, Stato, T8), nth1(9, Stato, T9),
    format('~w ~w ~w~n', [T1, T2, T3]),
    format('~w ~w ~w~n', [T4, T5, T6]),
    format('~w ~w ~w~n', [T7, T8, T9]).

% applicabile(Azione, Stato)
% Verifica se un'azione può essere eseguita in un dato stato
% Le azioni muovono la casella vuota (0) in una delle 4 direzioni

% su: muove il vuoto verso l'alto (scambia con tessera sopra)
applicabile(su, Stato) :-
    trova_vuoto(Stato, PosVuoto),
    indice_posizione(PosVuoto, Riga, _),
    Riga > 1.

% giu: muove il vuoto verso il basso (scambia con tessera sotto)
applicabile(giu, Stato) :-
    trova_vuoto(Stato, PosVuoto),
    indice_posizione(PosVuoto, Riga, _),
    Riga < 3.

% sinistra: muove il vuoto a sinistra (scambia con tessera a sinistra)
applicabile(sx, Stato) :-
    trova_vuoto(Stato, PosVuoto),
    indice_posizione(PosVuoto, _, Col),
    Col > 1.

% destra: muove il vuoto a destra (scambia con tessera a destra)
applicabile(dx, Stato) :-
    trova_vuoto(Stato, PosVuoto),
    indice_posizione(PosVuoto, _, Col),
    Col < 3.


% sostituisci(Lista, Posizione, NuovoValore, NuovaLista)
% Sostituisce l'elemento in Posizione con NuovoValore
sostituisci(Lista, Pos, Valore, NuovaLista) :-
    nth1(Pos, Lista, _, Resto),           % lista senza elemento in Pos
    nth1(Pos, NuovaLista, Valore, Resto). % lista con nuovo valore

% % alternativa pù elegante presa da documentazione
% replace_nth0(List, Index, OldElem, NewElem, NewList) :-
%    % predicate works forward: Index,List -> OldElem, Transfer
%    nth0(Index,List,OldElem,Transfer),
%    % predicate works backwards: Index,NewElem,Transfer -> NewList
%    nth0(Index,NewList,NewElem,Transfer).


% scambia(Lista, Pos1, Pos2, NuovaLista)
% Scambia gli elementi nelle posizioni Pos1 e Pos2 della Lista
scambia(Lista, Pos1, Pos2, NuovaLista):-
    nth1(Pos1, Lista, Elem1),               % el in posizione 1
    nth1(Pos2, Lista, Elem2),               % el in posizione 2
    sostituisci(Lista, Pos1, Elem2, ListaTemp),
    sostituisci(ListaTemp, Pos2, Elem1, NuovaLista).


% trasforma(Azione, StatoCorrente, StatoNuovo)
% Calcola il nuovo stato dopo aver applicato un'azione
% NOTA: NON verifica se l'azione è applicabile (usa applicabile/2 prima!)

% su: muove il vuoto una riga sopra
trasforma(su, Stato, StatoNuovo) :-
    trova_vuoto(Stato, PosVuoto),
    indice_posizione(PosVuoto, Riga, Col),
    RigaSopra is Riga - 1,                 % Calcola nuova riga
    posizione_indice(RigaSopra, Col, PosSopra),
    scambia(Stato, PosVuoto, PosSopra, StatoNuovo).

% giu: muove il vuoto una riga sotto
trasforma(giu, Stato, StatoNuovo) :-
    trova_vuoto(Stato, PosVuoto),
    indice_posizione(PosVuoto, Riga, Col),
    RigaSotto is Riga + 1,                 % Calcola nuova riga
    posizione_indice(RigaSotto, Col, PosSotto),
    scambia(Stato, PosVuoto, PosSotto, StatoNuovo).

% sinistra: muove il vuoto una colonna a sinistra
trasforma(sx, Stato, StatoNuovo) :-
    trova_vuoto(Stato, PosVuoto),
    indice_posizione(PosVuoto, Riga, Col),
    ColSinistra is Col - 1,                % Calcola nuova colonna
    posizione_indice(Riga, ColSinistra, PosSinistra),
    scambia(Stato, PosVuoto, PosSinistra, StatoNuovo).

% destra: muove il vuoto una colonna a destra
trasforma(dx, Stato, StatoNuovo) :-
    trova_vuoto(Stato, PosVuoto),
    indice_posizione(PosVuoto, Riga, Col),
    ColDestra is Col + 1,                  % Calcola nuova colonna
    posizione_indice(Riga, ColDestra, PosDestra),
    scambia(Stato, PosVuoto, PosDestra, StatoNuovo).
