
%% Vincoli ore corso (modificato) ---------------------------------------------------------------------------------------
%%:- X != #count{I : calendar(_, _, _, I, S, _)}, subject(S, _, X).
required_hours(S,P,H) :- subject(S,P,H).

:- required_hours(S,P,H), H != #count{W,D,Hh,I : calendar(W,D,Hh,I,S,P)}.
%% Vincolo no due corsi nello stesso slot (modificato) ---------------------------------------------------------------------------------------
%%:- calendar(_, _, _, I, S1, _), calendar(_, _, _, I, S2, _), S1 != S2.
:- calendar(W,D,H,I,_,P), calendar(W,D,H,I2,_,P), I != I2.

% Vincoli Rigidi -------------------------------------------------------------------------------------------------------

%% 1. lo stesso docente non può svolgere più di 4 ore di lezione in un giorno;
:- #count{I : calendar(W, D, _, I, _, P)} > 4, week(W), day(D), prof(P).

%% 2. a ciascun insegnamento vengono assegnate 2, 3 o 4 ore nello stesso giorno
:- 1 = #count{I : calendar(W, D, _, I, S, _)}, week(W), day(D), subject(S, _, _).
:- C = #count{I : calendar(W, D, _, I, S, _)}, C > 4, week(W), day(D), subject(S, _, _).
% Lezione di un corso nello stesso giorno deve essere in blocchi consecutivi di 2-4 ore (aggiunta)
%:- calendar(W,D,H1,_,S,_), calendar(W,D,H2,_,S,_), H2 > H1+1, H1 != 0, H2 != 0.
% Le ore di uno stesso corso nello stesso giorno devono essere consecutive (2-4 ore al giorno)
:- calendar(W,D,H1,_,S,_), calendar(W,D,H2,_,S,_), H2 > H1+1, not calendar(W,D,H1+1,_,S,_).


%% 3.  il primo giorno di lezione prevede che, nelle prime due ore, vi sia la presentazione del master
:- calendar(_, _, _, I1, "Introduzione al Master", _),
   calendar(_, _, _, I2, S, _), subject(S, _, _), I1 > I2, S != "Introduzione al Master".

%% 4.  il calendario deve prevedere almeno 6 blocchi liberi di 2 ore ciascuno per eventuali recuperi di lezioni annullate o rinviate;
free_block(W, D, H) :- slot_index(W, D, H, I1), slot_index(W, D, H+1, I2),
                        not calendar(W, D, H, I1, _, _),
                        not calendar(W, D, H+1, I2, _, _).
:- #count{W,D,H : free_block(W,D,H)} < 6.

%% 5.  l’insegnamento “Project Management” deve concludersi non oltre la prima settimana full-time
:- calendar(W, _, _, _, "Project Management", _), W > 7.

%% 6.  la prima lezione dell’insegnamento “Accessibilità e usabilità nella progettazione multimediale” deve essere collocata prima che siano terminate le lezioni dell’insegnamento “Linguaggi di markup”;
:- calendar(_, _, _, I1, "Accessibilità e usabilità nella progettazione multimediale", _),
   calendar(_, _, _, I2, "Linguaggi di markup", _),
   period(I1, _, "Accessibilità e usabilità nella progettazione multimediale"),
   period(_, I2, "Linguaggi di markup"), I1 > I2.

%% 7.  la distanza tra la prima e l’ultima lezione di ciascun insegnamento non deve superare le 8 settimane;
week_length(L/100-F/100, S) :- period(F, L, S), subject(S, _, _), L != #inf, F != #sup.
:- week_length(X, S), subject(S, _, _), X > 8.
% La prima e l'ultima lezione di ciascun corso non possono essere a più di 8 settimane di distanza
%period(F,L,S) :- F = #min{I : calendar(W,_,_,I,S,_)}, 
  %               L = #max{I : calendar(W,_,_,I,S,_)}, 
 %                subject(S,_,_).

%:- period(F,L,S), F != #inf, L != #sup, L/100 - F/100 > 8.

%% 8.  le ore dell’insegnamento di “Tecnologie server-side per il web” devono essere organizzate in 5 blocchi da 4 ore ciascuno
block4(W,D,H) :- slot_index(W,D,H,I1),
                 slot_index(W,D,H+1,I2),
                 slot_index(W,D,H+2,I3),
                 slot_index(W,D,H+3,I4),
                 calendar(W,D,H,I1,"Tecnologie server-side per il web",_),
                 calendar(W,D,H+1,I2,"Tecnologie server-side per il web",_),
                 calendar(W,D,H+2,I3,"Tecnologie server-side per il web",_),
                 calendar(W,D,H+3,I4,"Tecnologie server-side per il web",_).
:- #count{W,D,H : block4(W,D,H)} != 5.

%% 9.  le prime lezioni degli insegnamenti “Crossmedia: articolazione delle scritture multimediali” e “Introduzione al social media management” devono essere collocate nella seconda settimana full-time
first_lesson(W,S) :- W = #min{W1 : calendar(W1,_,_,_,S,_)}, subject(S,_,_).

:- first_lesson(W, "Crossmedia: articolazione delle scritture multimediali"), W != 16.
:- first_lesson(W, "Introduzione al social media management"), W != 16.


%% 10. le lezioni dei vari insegnamenti devono rispettare le seguenti propedeuticità, in particolare la prima lezione dell’insegnamento della colonna di destra deve essere successiva all’ultima lezione del corrispondente insegnamento della colonna di sinistra
:- calendar(_, _, _, I1, S1, _), calendar(_, _, _, I2, S2, _), propaedeutic(S1, S2), I1 > I2.

% Predicati ausiliari --------------------------------------------------------------------------------------------------
period(F, L, S) :- F = #min{I: calendar(_, _, _, I, S, _)}, L = #max{I: calendar(_, _, _, I, S, _)}, subject(S, _, _).

#show calendar/6.
%%#show period/3.
%%#show week_length/2.
%%#show week_distance_4/3.
%%#show free_block/3.
%%#show block4/3.
