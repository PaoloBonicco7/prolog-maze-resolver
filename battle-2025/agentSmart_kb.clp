;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; smart_knowledge.clp
; Modulo KNOWLEDGE del giocatore "smart"
; Si occupa SOLO di derivare conoscenza implicita:
;   - celle vietate (adiacenze e diagonali)
;   - celle candidate coerenti con vincoli riga/colonna
;   - nessun if / loop / funzione
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defmodule SMART-KNOWLEDGE (import MAIN ?ALL))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  Se una cella contiene già una barca (da fire o da iniziale),
;    allora tutte le diagonali vengono marcate come impossibili.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule mark-diagonals-impossible (declare (salience 80))
   (cell (x ?x) (y ?y) (content boat))
   ?d1 <- (cell (x =(+ ?x 1)) (y =(+ ?y 1)) (status none))
=>
   (modify ?d1 (status impossible)))

(defrule mark-diagonals-impossible-2 (declare (salience 80))
   (cell (x ?x) (y ?y) (content boat))
   ?d2 <- (cell (x =(+ ?x 1)) (y =(- ?y 1)) (status none))
=>
   (modify ?d2 (status impossible)))

(defrule mark-diagonals-impossible-3 (declare (salience 80))
   (cell (x ?x) (y ?y) (content boat))
   ?d3 <- (cell (x =(- ?x 1)) (y =(+ ?y 1)) (status none))
=>
   (modify ?d3 (status impossible)))

(defrule mark-diagonals-impossible-4 (declare (salience 80))
   (cell (x ?x) (y ?y) (content boat))
   ?d4 <- (cell (x =(- ?x 1)) (y =(- ?y 1)) (status none))
=>
   (modify ?d4 (status impossible)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Se troviamo un sottomarino (size 1), tutte le ortogonali
;    vengono marcate impossibili.
;    Nessuna funzione: 4 regole separate.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule mark-orthogonal-up-sub (declare (salience 75))
   (boat-single (x ?x) (y ?y))
   ?c <- (cell (x =(- ?x 1)) (y ?y) (status none))
=>
   (modify ?c (status impossible)))

(defrule mark-orthogonal-down-sub (declare (salience 75))
   (boat-single (x ?x) (y ?y))
   ?c <- (cell (x =(+ ?x 1)) (y ?y) (status none))
=>
   (modify ?c (status impossible)))

(defrule mark-orthogonal-left-sub (declare (salience 75))
   (boat-single (x ?x) (y ?y))
   ?c <- (cell (x ?x) (y =(- ?y 1)) (status none))
=>
   (modify ?c (status impossible)))

(defrule mark-orthogonal-right-sub (declare (salience 75))
   (boat-single (x ?x) (y ?y))
   ?c <- (cell (x ?x) (y =(+ ?y 1)) (status none))
=>
   (modify ?c (status impossible)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Celle candidate a nave basate sui vincoli riga/colonna
;    Se riga richiede > 0 celle, ogni cella libera diventa candidate-row
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule row-candidate (declare (salience 50))
   (k-per-row (row ?r) (num ?n&:(> ?n 0)))
   (cell (x ?r) (y ?y) (status none))
   (not (candidate-row ?r ?y))
=>
   (assert (candidate-row ?r ?y)))

; stesse per colonna
(defrule col-candidate (declare (salience 50))
   (k-per-col (col ?c) (num ?n&:(> ?n 0)))
   (cell (x ?x) (y ?c) (status none))
   (not (candidate-col ?x ?c))
=>
   (assert (candidate-col ?x ?c)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Una cella diventa "high-potential" se è candidate sia per riga sia per colonna.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule high-potential (declare (salience 40))
   (candidate-row ?x ?y)
   (candidate-col ?x ?y)
   (cell (x ?x) (y ?y) (status none))
   (not (potential ?x ?y))
=>
   (assert (potential ?x ?y)))
