:- dynamic num_col/1, occupata/1, num_righe/1.
% ============================================
% AZIONI - Movimento dell'Agente
% ============================================

% applicabile(Azione, Stato)
% Verifica se un'azione può essere eseguita in un dato stato

applicabile(nord, pos(Riga, Colonna)) :-
    Riga > 1,                              % Non posso andare a nord dalla riga 1
    RigaNord is Riga - 1,                  % Calcolo la nuova riga
    \+ occupata(pos(RigaNord, Colonna)).   % Verifico che non sia occupata

applicabile(sud, pos(Riga, Colonna)) :-
    num_righe(NR),                         % Prendo il numero totale di righe
    Riga < NR,                             % Non posso andare oltre l'ultima riga
    RigaSud is Riga + 1,
    \+ occupata(pos(RigaSud, Colonna)).

applicabile(ovest, pos(Riga, Colonna)) :-
    Colonna > 1,                           % Non posso andare a ovest dalla colonna 1
    ColonnaOvest is Colonna - 1,
    \+ occupata(pos(Riga, ColonnaOvest)).

applicabile(est, pos(Riga, Colonna)) :-
    num_col(NC),                           % Prendo il numero totale di colonne
    Colonna < NC,                          % Non posso andare oltre l'ultima colonna
    ColonnaEst is Colonna + 1,
    \+ occupata(pos(Riga, ColonnaEst)).


% trasforma(Azione, StatoCorrente, StatoNuovo)
% Calcola il nuovo stato dopo aver applicato un'azione

trasforma(nord, pos(Riga, Colonna), pos(RigaNord, Colonna)) :-
    RigaNord is Riga - 1.

trasforma(sud, pos(Riga, Colonna), pos(RigaSud, Colonna)) :-
    RigaSud is Riga + 1.

trasforma(ovest, pos(Riga, Colonna), pos(Riga, ColonnaOvest)) :-
    ColonnaOvest is Colonna - 1.

trasforma(est, pos(Riga, Colonna), pos(Riga, ColonnaEst)) :-
    ColonnaEst is Colonna + 1.