% ========================================================
% TORNEO (versione completa e verificata)
% ========================================================

% ----------------------------
% SQUADRE (32 nazionali)
% ----------------------------
squadra(italia). squadra(francia). squadra(germania). squadra(spagna).
squadra(portogallo). squadra(olanda). squadra(belgio). squadra(inghilterra).
squadra(croazia). squadra(svizzera).

squadra(stati_uniti). squadra(messico). squadra(costa_rica). squadra(canada).

squadra(brasile). squadra(argentina). squadra(uruguay). squadra(cile).
squadra(colombia). squadra(peru). squadra(ecuador). squadra(paraguay).

squadra(giappone). squadra(corea_del_sud). squadra(iran). squadra(arabia_saudita).

squadra(senegal). squadra(marocco). squadra(camerun). squadra(nigeria).

squadra(australia). squadra(nuova_zelanda).

% ----------------------------
% CONTINENTI (zone)
% ----------------------------
zone(italia,eu). zone(francia,eu). zone(germania,eu). zone(spagna,eu).
zone(portogallo,eu). zone(olanda,eu). zone(belgio,eu). zone(inghilterra,eu).
zone(croazia,eu). zone(svizzera,eu).

zone(stati_uniti,nc). zone(messico,nc). zone(costa_rica,nc). zone(canada,nc).

zone(brasile,sa). zone(argentina,sa). zone(uruguay,sa). zone(cile,sa).
zone(colombia,sa). zone(peru,sa). zone(ecuador,sa). zone(paraguay,sa).

zone(giappone,as). zone(corea_del_sud,as). zone(iran,as). zone(arabia_saudita,as).

zone(senegal,af). zone(marocco,af). zone(camerun,af). zone(nigeria,af).

zone(australia,oc). zone(nuova_zelanda,oc).

% ----------------------------
% FASCE / PARTIZIONE (4 fasce)
% ----------------------------
idpartizione(1..4).

% Fascia 1
partizione(italia,1). partizione(brasile,1). partizione(francia,1). partizione(argentina,1).
partizione(inghilterra,1). partizione(senegal,1). partizione(giappone,1). partizione(australia,1).

% Fascia 2
partizione(germania,2). partizione(spagna,2). partizione(uruguay,2). partizione(messico,2).
partizione(marocco,2). partizione(corea_del_sud,2). partizione(costa_rica,2). partizione(nuova_zelanda,2).

% Fascia 3
partizione(portogallo,3). partizione(olanda,3). partizione(colombia,3). partizione(canada,3).
partizione(nigeria,3). partizione(iran,3). partizione(peru,3). partizione(camerun,3).

% Fascia 4
partizione(svizzera,4). partizione(croazia,4). partizione(cile,4). partizione(ecuador,4).
partizione(paraguay,4). partizione(stati_uniti,4). partizione(arabia_saudita,4). partizione(belgio,4).

% vincolo: una sola fascia per squadra (ridondante se i dati sono corretti)
:- partizione(T,P1), partizione(T,P2), P1 != P2.

% ----------------------------
% GIRONI, POSIZIONI, GIORNATE
% ----------------------------
idgirone(1..8).
posid(1..4).
day(1..3).

% ----------------------------
% ASSEGNAZIONE: ogni squadra ad un solo girone
% ----------------------------
1 { in_g(T,G) : idgirone(G) } 1 :- squadra(T).

% ogni girone deve avere esattamente 4 squadre
:- idgirone(G), #count { T : in_g(T,G) } != 4.

% ----------------------------
% POSIZIONI: 4 posizioni per girone (1..4)
% ----------------------------
% ogni squadra in un girone riceve esattamente una posizione
1 { pos(G,P,T) : posid(P) } 1 :- in_g(T,G).

% ogni posizione in ogni girone è occupata da esattamente una squadra
1 { pos(G,P,T) : squadra(T), in_g(T,G) } 1 :- idgirone(G), posid(P).

% coerenza posizione <-> appartenenza girone
:- pos(G,P,T), not in_g(T,G).

% ----------------------------
% vincolo: una sola squadra per fascia in ogni girone
% ----------------------------
:- idgirone(G), idpartizione(P),
   #count { T : in_g(T,G), partizione(T,P) } != 1.

% ----------------------------
% vincolo: almeno 3 continenti diversi in ogni girone
% ----------------------------
continent_in(G,Z) :- in_g(T,G), zone(T,Z).
:- idgirone(G), #count { Z : continent_in(G,Z) } < 3.

% ----------------------------
% Definizione coppie di giornata in base alle posizioni
% (giornata 1: pos 1-2 e 3-4; giornata 2: 1-3 e 2-4; giornata 3: 1-4 e 2-3)
% ----------------------------
daypair(1,1,2). daypair(1,3,4).
daypair(2,1,3). daypair(2,2,4).
daypair(3,1,4). daypair(3,2,3).

% definisco la partita come relazione (girone, giornata, squadraA, squadraB)
partita(G,D,A,B) :- idgirone(G), day(D), daypair(D,P1,P2), pos(G,P1,A), pos(G,P2,B).

% Assicuriamoci che per ogni coppia (A,B) nello stesso girone ci sia esattamente una partita
% (uso A < B per considerare coppie non ordinate)
:- in_g(A,G), in_g(B,G), A < B, #count { D : partita(G,D,A,B) } != 1.

% Definisco quando una squadra gioca in un girone e giornata
gioca(T,G,D) :- partita(G,D,T,_).
gioca(T,G,D) :- partita(G,D,_,T).

% ogni squadra gioca esattamente una partita per giornata
:- squadra(T), day(D), #count { G : gioca(T,G,D) } != 1.

% ----------------------------
% OUTPUT utili
% ----------------------------
#show in_g/2.
#show pos/3.
#show partita/4.
