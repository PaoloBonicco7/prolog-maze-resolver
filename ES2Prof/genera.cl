% =============================================================
% generaCalendarioSlot.cl — VERSIONE COMPLETA E CORRETTA
% =============================================================
% Questo file implementa TUTTI i vincoli richiesti dal PDF.
% Deve essere usato insieme a master.cl (dove ci sono i fatti).
% -------------------------------------------------------------

% -------------------------------------------------------------
% 1. SETTIMANE
% -------------------------------------------------------------
week(1..24).
full_week(7).
full_week(16).

% -------------------------------------------------------------
% 2. GIORNI SETTIMANALI
% -------------------------------------------------------------
day(mon; tue; wed; thu; fri; sat).

% Giorni attivi: 
% - settimane full-time: lun→sab
% - settimane normali: solo ven, sab
active_day(W,D) :- full_week(W), day(D).
active_day(W,fri) :- week(W), not full_week(W).
active_day(W,sat) :- week(W), not full_week(W).

% -------------------------------------------------------------
% 3. ORE DISPONIBILI
% -------------------------------------------------------------
% Settimane full: lun–ven 8h, sab 6h
hour(W,D,H) :- full_week(W), D!=sat, H=1..8.
hour(W,sat,H) :- full_week(W), H=1..6.

% Settimane normali: ven 8h, sab 6h
hour(W,fri,H) :- week(W), not full_week(W), H=1..8.
hour(W,sat,H) :- week(W), not full_week(W), H=1..6.

% -------------------------------------------------------------
% 4. SLOT ENGINE (opzionale, utile per debug)
% -------------------------------------------------------------
% Non usato nei vincoli, solo per osservazione.
slot_index(W,D,H,I) :- hour(W,D,H), I = (W*10000) + (H*10) + (D==mon*1 + D==tue*2 + D==wed*3 + D==thu*4 + D==fri*5 + D==sat*6).

% -------------------------------------------------------------
% 5. SCELTA DELLE LEZIONI (ogni slot: un corso o libero)
% -------------------------------------------------------------
{ calendar(W,D,H,S,P) : subject(S,P,_) } 1 :- hour(W,D,H).
free_block(W,D,H) :- hour(W,D,H), not calendar(W,D,H,_,_).

% -------------------------------------------------------------
% 6. MATCH PROFESSORI E INSEGNAMENTI
% -------------------------------------------------------------
:- calendar(W,D,H,S,P), not subject(S,P,_).

% -------------------------------------------------------------
% 7. VINCOLO: un professore non può fare >4 ore al giorno
% -------------------------------------------------------------
:- prof(P), week(W), active_day(W,D), C=#count{H : calendar(W,D,H,_,P)}, C>4.

% -------------------------------------------------------------
% 8. BLOCCHI GIORNALIERI: devono essere consecutivi e 2–4 ore
% -------------------------------------------------------------
% Evita gap (es: ora 1 e 3 senza 2)
:- calendar(W,D,H,S,_), calendar(W,D,H2,S,_), H2>H+1, not calendar(W,D,H+1,S,_).

% Conteggio ore giornaliere per corso
% --- Fix Clingo 5.4 compatible subject_day_hours ---
subject_day_hours(W,D,S,C) :- #count{H : calendar(W,D,H,S,_)} = C.(W,D,S,C) :- C=#count{H : calendar(W,D,H,S,_)}, C>0.
:- subject_day_hours(W,D,S,C), C<2.
:- subject_day_hours(W,D,S,C), C>4.

% -------------------------------------------------------------
% 9. ORE TOTALI PER INSEGNAMENTO
% -------------------------------------------------------------
:- subject(S,_,Total), Htot=#count{W,D,H : calendar(W,D,H,S,_)}, Htot != Total.

% -------------------------------------------------------------
% 10. ALMENO 6 BLOCCHI LIBERI DI 2 ORE
% -------------------------------------------------------------
free2(W,D,H) :- free_block(W,D,H), free_block(W,D,H+1), hour(W,D,H), hour(W,D,H+1).
:- N=#count{W,D,H : free2(W,D,H)}, N < 6.

% -------------------------------------------------------------
% 11. PRESENTAZIONE DEL MASTER
%     Deve essere nelle prime due ore del PRIMO GIORNO DI LEZIONE:
%     = settimana 1, venerdì, ore 1 e 2
% -------------------------------------------------------------
:- not calendar(1,fri,1,"Introduzione al Master",_).
:- not calendar(1,fri,2,"Introduzione al Master",_).

% -------------------------------------------------------------
% 12. PRIMA E ULTIMA SETTIMANA DI OGNI INSEGNAMENTO
% -------------------------------------------------------------
first_week(S,F) :- F = #min{W : calendar(W,_,_,S,_)}, subject(S,_,_).
last_week(S,L)  :- L = #max{W : calendar(W,_,_,S,_)}, subject(S,_,_).

% -------------------------------------------------------------
% 13. DISTANZA MAX 8 SETTIMANE TRA PRIMA E ULTIMA LEZIONE
% -------------------------------------------------------------
:- subject(S,_,_), first_week(S,F), last_week(S,L), L - F > 8.

% -------------------------------------------------------------
% 14. PROJECT MANAGEMENT deve finire ENTRO settimana 7
% -------------------------------------------------------------
:- last_week("Project Management", L), L > 7.

% -------------------------------------------------------------
% 15. ACCESSIBILITÀ PRIMA CHE FINISCA LINGUAGGI DI MARKUP
% -------------------------------------------------------------
:- first_week("Accessibilità e usabilità nella progettazione multimediale", FWacc),
   last_week("Linguaggi di markup", LWmark),
   FWacc >= LWmark.

% -------------------------------------------------------------
% 16. TECNOLOGIE SERVER-SIDE IN 5 BLOCCHI DA 4 ORE
% -------------------------------------------------------------
block4(W,D,S,H) :- calendar(W,D,H,S,_), calendar(W,D,H+1,S,_), calendar(W,D,H+2,S,_), calendar(W,D,H+3,S,_), hour(W,D,H+3).
:- subject("Tecnologie server-side per il web",_,_), B=#count{W,D,H : block4(W,D,"Tecnologie server-side per il web",H)}, B != 5.

% -------------------------------------------------------------
% 17. PRIME LEZIONI DI:
%     - CROSSMEDIA → settimana 16
%     - INTRODUZIONE SOCIAL MEDIA MGMT → settimana 16
% -------------------------------------------------------------
:- first_week("Crossmedia: articolazione delle scritture multimediali", F), F != 16.
:- first_week("Introduzione al social media management", F), F != 16.

% -------------------------------------------------------------
% 18. PROPEDUTICITÀ (tabella PDF)
% -------------------------------------------------------------
:- propaedeutic(A,B), first_week(B,FB), last_week(A,LA), FB <= LA.

% -------------------------------------------------------------
% 19. NESSUN PROFESSORE PUÒ AVERE DUE CORSI NELLO STESSO SLOT
% -------------------------------------------------------------
:- calendar(W,D,H,S1,P), calendar(W,D,H,S2,P), S1!=S2.

% -------------------------------------------------------------
% 20. SHOW PER debug (disattivabili)
% -------------------------------------------------------------
#show calendar/5.
#show free2/3.
#show block4/4.
#show first_week/2.
#show last_week/2.
