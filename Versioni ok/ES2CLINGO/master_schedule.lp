% Definizione temporale
week(1..24).
day(1..6). % 1=lun, 2=mar, 3=mer, 4=gio, 5=ven, 6=sab
slot(1..8). % slot orari: 1=8-9, 2=9-10, ..., 8=15-16

% Definizione corsi (esempio - completare con tutti i corsi dal PDF)
course(pm, muzzetto, 14, 2, 4).      % Project Management
course(tct, pozzato, 14, 2, 4).      % Tecnologie per il Cloud e IoT
course(lm, schifanella_r, 20, 2, 4). % Laboratorio di Multimedialità
course(ict, bonis, 16, 2, 4).        % ICT and Innovation
course(adw, femur, 16, 2, 4).        % Advanced Web Applications
course(dm, femur, 20, 2, 4).         % Data Mining
course(se, femur, 20, 2, 4).         % Search Engines
course(ai, pozzato, 20, 2, 4).       % Artificial Intelligence

% Settimane full-time (tutti i giorni disponibili)
full_week(7;16).

% Disponibilità slot
slot_available(W, D, S) :- week(W), day(D), slot(S).

% Vincolo: sabato solo prime 6 ore
:- block(_, W, 6, S, _), S > 6.

% Definizione blocchi di lezione
{ block(C, W, D, Start, Len) : week(W), day(D), Start=1..8, Len=2..4, 
  Start+Len-1 <= 8, course(C, _, _, MinLen, MaxLen), Len>=MinLen, Len<=MaxLen }.

% Ogni blocco deve rispettare la lunghezza minima e massima
:- block(C, W, D, Start, Len), course(C, _, _, MinLen, MaxLen), (Len < MinLen; Len > MaxLen).

% Un blocco non può sovrapporsi con altri dello stesso corso
:- block(C, W, D, Start1, Len1), block(C, W, D, Start2, Len2), 
   Start1 <= Start2, Start2 < Start1 + Len1.

% Calcolo delle ore effettive per corso
occurs(C, W, D, S) :- block(C, W, D, Start, Len), S >= Start, S < Start + Len.
total_hours(C, Total) :- course(C, _, Total, _, _), Total = #count { W,D,S : occurs(C, W, D, S) }.

% Vincolo ore totali per corso
:- course(C, Expected, _, _, _), #count { W,D,S : occurs(C, W, D, S) } != Expected.

% Vincolo docente: massimo 4 ore al giorno
teacher(Teacher) :- course(_, Teacher, _, _, _).
daily_hours(Teacher, W, D, Hours) :- 
    teacher(Teacher), week(W), day(D), 
    Hours = #count { C,S : occurs(C, W, D, S), course(C, Teacher, _, _, _) }.
:- daily_hours(Teacher, W, D, Hours), Hours > 4.

% Vincolo: Project Management deve finire entro la settimana 7
last_week(C, LastWeek) :- course(C, _, _, _, _), LastWeek = #max { W : block(C, W, _, _, _) }.
:- last_week(pm, LastWeek), LastWeek > 7.

% Propedeuticità
precedes(ict, adw). % ICT deve finire prima che inizi Advanced Web Applications

first_week(C, FirstWeek) :- course(C, _, _, _, _), FirstWeek = #min { W : block(C, W, _, _, _) }.
:- precedes(A, B), last_week(A, LastA), first_week(B, FirstB), FirstB <= LastA.

% Vincolo: almeno 6 blocchi liberi di 2 ore consecutivi
free_block(W, D, Start) :- 
    week(W), day(D), Start=1..7, 
    not exists_block(W, D, Start),
    slot_available(W, D, Start),
    slot_available(W, D, Start+1).

exists_block(W, D, S) :- block(_, W, D, BlockStart, Len), S >= BlockStart, S < BlockStart + Len.

:- #count { W,D,Start : free_block(W, D, Start) } < 6.

% Ottimizzazione: distribuzione uniforme delle lezioni
course_weeks(C, WeekCount) :- course(C, _, _, _, _), WeekCount = #count { W : block(C, W, _, _, _) }.
:~ course_weeks(C, WeekCount). [WeekCount@1, C]

% Output
#show block/5.
#show total_hours/2.