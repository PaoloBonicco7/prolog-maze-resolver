#const n_weeks = 24.
#const n_days  = 6.

% --- Settimane e giorni ---
week(1..n_weeks).
day(1..n_days).

% Settimane full-time
isFullWeek(7;16).

% --- Ore per giorno ---
% lun-ven → 8 ore
weekday_hour(D,H) :- D = 1..5, H = 1..8.
% sabato → 6 ore
saturday_hour(D,H) :- D = 6, H = 1..6.

% --- SLOT INDEX (ID univoco) ---
% Settimane full-time: lun-ven
slot_index(W,D,H,I) :-
    isFullWeek(W),
    D = 1..5, weekday_hour(D,H),
    I = W*100 + D*10 + H.

% Settimane full-time: sabato
slot_index(W,6,H,I) :-
    isFullWeek(W),
    H = 1..6,
    I = W*100 + 60 + H.

% Tutte le settimane (normali) venerdì
slot_index(W,5,H,I) :-
    week(W),
    not isFullWeek(W),
    H = 1..8,
    I = W*100 + 50 + H.

% Tutte le settimane (normali) sabato
slot_index(W,6,H,I) :-
    week(W),
    not isFullWeek(W),
    H = 1..6,
    I = W*100 + 60 + H.

% --- GENERAZIONE CALENDAR ---
% Ogni slot può contenere al massimo una lezione

% Settimane full-time → lun-sab
0 { calendar(W,D,H,I,S,P) } 1 :-
    isFullWeek(W),
    D = 1..5,
    weekday_hour(D,H),
    slot_index(W,D,H,I),
    subject(S,P,_).

0 { calendar(W,6,H,I,S,P) } 1 :-
    isFullWeek(W),
    H = 1..6,
    slot_index(W,6,H,I),
    subject(S,P,_).

% Settimane normali → venerdì e sabato
0 { calendar(W,5,H,I,S,P) } 1 :-
    week(W),
    not isFullWeek(W),
    H = 1..8,
    slot_index(W,5,H,I),
    subject(S,P,_).

0 { calendar(W,6,H,I,S,P) } 1 :-
    week(W),
    not isFullWeek(W),
    H = 1..6,
    slot_index(W,6,H,I),
    subject(S,P,_).

%% Prodotto cartesiano con possibilità nullable (#10528)
test1(W, X) :- X = #count{D : calendar(W, D, _, _, _, _)}, week(W), not isFullWeek(W). % conta il numero di giorni nelle settimane non piene
test2(W, X) :- X = #count{D : calendar(W, D, _, _, _, _)}, isFullWeek(W). % conta il numero di giorni delle settimane piene
test3(W, X) :- X = #count{I : calendar(W, D, _, I, _, _)}, week(W), day(D), not weekday_hour(D, _). % il sabato, della settimana W, ha 4 o 5 ore
test4(W, D, X) :- X = #count{I : calendar(W, D, _, I, _, _)}, week(W), day(D). % cont il numero di ore nel giorno D della settimana W
#show calendar/6.
#show slot_index/4.
