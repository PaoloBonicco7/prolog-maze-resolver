;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; smart_fire.clp - Modulo 3: SMART-FIRE
; Decide dove usare FIRE in modo intelligente.
; Usa solo pattern matching e salience, nessun if/loop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defmodule SMART-FIRE (import MAIN ?ALL))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Fire su celle ortogonalmente adiacenti a hit-boat
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule sf-fire-adj-up (declare (salience 100))
   ?st <- (status (step ?s) (currently running))
   (moves (fires ?f &:(> ?f 0)))
   (cell (x ?x0) (y ?y0) (content hit-boat))
   ?c <- (cell (x =(- ?x0 1)) (y ?y0) (status none))
   (not (exec (step ?s)))
=>
   (assert (exec (step ?s) (action fire) (x (- ?x0 1)) (y ?y0)))
   (printout t "[SMART-FIRE] fire above hit-boat " (- ?x0 1) "," ?y0 crlf)
)

(defrule sf-fire-adj-down (declare (salience 100))
   ?st <- (status (step ?s) (currently running))
   (moves (fires ?f &:(> ?f 0)))
   (cell (x ?x0) (y ?y0) (content hit-boat))
   ?c <- (cell (x =(+ ?x0 1)) (y ?y0) (status none))
   (not (exec (step ?s)))
=>
   (assert (exec (step ?s) (action fire) (x (+ ?x0 1)) (y ?y0)))
   (printout t "[SMART-FIRE] fire below hit-boat " (+ ?x0 1) "," ?y0 crlf)
)

(defrule sf-fire-adj-left (declare (salience 100))
   ?st <- (status (step ?s) (currently running))
   (moves (fires ?f &:(> ?f 0)))
   (cell (x ?x0) (y ?y0) (content hit-boat))
   ?c <- (cell (x ?x0) (y =(- ?y0 1)) (status none))
   (not (exec (step ?s)))
=>
   (assert (exec (step ?s) (action fire) (x ?x0) (y (- ?y0 1))))
   (printout t "[SMART-FIRE] fire left of hit-boat " ?x0 "," (- ?y0 1) crlf)
)

(defrule sf-fire-adj-right (declare (salience 100))
   ?st <- (status (step ?s) (currently running))
   (moves (fires ?f &:(> ?f 0)))
   (cell (x ?x0) (y ?y0) (content hit-boat))
   ?c <- (cell (x ?x0) (y =(+ ?y0 1)) (status none))
   (not (exec (step ?s)))
=>
   (assert (exec (step ?s) (action fire) (x ?x0) (y (+ ?y0 1))))
   (printout t "[SMART-FIRE] fire right of hit-boat " ?x0 "," (+ ?y0 1) crlf)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Fire su celle 'potential' se ci sono ancora fires
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule sf-fire-potential (declare (salience 50))
   ?st <- (status (step ?s) (currently running))
   (moves (fires ?f &:(> ?f 0)))
   ?p <- (potential ?x ?y)
   (cell (x ?x) (y ?y) (status none))
   (not (exec (step ?s)))
=>
   (assert (exec (step ?s) (action fire) (x ?x) (y ?y)))
   (printout t "[SMART-FIRE] fire potential " ?x "," ?y crlf)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Fire su candidate-row (se ci sono ancora fires)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule sf-fire-candidate-row (declare (salience 40))
   ?st <- (status (step ?s) (currently running))
   (moves (fires ?f &:(> ?f 0)))
   ?c <- (candidate-row ?x ?y)
   (cell (x ?x) (y ?y) (status none))
   (not (potential ?x ?y))
   (not (exec (step ?s)))
=>
   (assert (exec (step ?s) (action fire) (x ?x) (y ?y)))
   (printout t "[SMART-FIRE] fire candidate-row " ?x "," ?y crlf)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Fire su candidate-col (se ci sono ancora fires)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule sf-fire-candidate-col (declare (salience 30))
   ?st <- (status (step ?s) (currently running))
   (moves (fires ?f &:(> ?f 0)))
   ?c <- (candidate-col ?x ?y)
   (cell (x ?x) (y ?y) (status none))
   (not (candidate-row ?x ?y))
   (not (potential ?x ?y))
   (not (exec (step ?s)))
=>
   (assert (exec (step ?s) (action fire) (x ?x) (y ?y)))
   (printout t "[SMART-FIRE] fire candidate-col " ?x "," ?y crlf)
)
