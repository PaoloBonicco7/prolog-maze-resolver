;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; smart_guess.clp  - Modulo 2: SMART-GUESS
; Decide dove fare GUESS usando solo pattern matching e salience.
; Non usa if, loop, deffunction ecc.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defmodule SMART-GUESS (import MAIN ?ALL))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Priorità massima: se esiste una cella 'potential' (row+col) -> guess
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defrule sg-guess-potential (declare (salience 100))
   ?st <- (status (step ?s) (currently running))
   (moves (guesses ?g &:(> ?g 0)))
   ?p <- (potential ?x ?y)
   (cell (x ?x) (y ?y) (status none))
   (not (exec (step ?s)))
   (not (guess ?x ?y))
=>
   (assert (exec (step ?s) (action guess) (x ?x) (y ?y)))
   (printout t "[SMART-GUESS] guess POTENTIAL " ?x "," ?y crlf)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Se esiste una cella che è sia candidate-row sia candidate-col (ma non marcata potential) -> guess
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defrule sg-guess-row-col (declare (salience 90))
   ?st <- (status (step ?s) (currently running))
   (moves (guesses ?g &:(> ?g 0)))
   (candidate-row ?x ?y)
   (candidate-col ?x ?y)
   (cell (x ?x) (y ?y) (status none))
   (not (potential ?x ?y))
   (not (exec (step ?s)))
   (not (guess ?x ?y))
=>
   (assert (exec (step ?s) (action guess) (x ?x) (y ?y)))
   (printout t "[SMART-GUESS] guess ROW+COL " ?x "," ?y crlf)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Candidate-row (prefer cells in rows that need ships)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defrule sg-guess-candidate-row (declare (salience 70))
   ?st <- (status (step ?s) (currently running))
   (moves (guesses ?g &:(> ?g 0)))
   ?cr <- (candidate-row ?x ?y)
   (cell (x ?x) (y ?y) (status none))
   (not (exec (step ?s)))
   (not (guess ?x ?y))
=>
   (assert (exec (step ?s) (action guess) (x ?x) (y ?y)))
   (printout t "[SMART-GUESS] guess candidate-row " ?x "," ?y crlf)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Candidate-col (prefer cells in cols that need ships)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defrule sg-guess-candidate-col (declare (salience 60))
   ?st <- (status (step ?s) (currently running))
   (moves (guesses ?g &:(> ?g 0)))
   ?cc <- (candidate-col ?x ?y)
   (cell (x ?x) (y ?y) (status none))
   (not (candidate-row ?x ?y))  ; evitare duplicati se già presa da rule superiore
   (not (exec (step ?s)))
   (not (guess ?x ?y))
=>
   (assert (exec (step ?s) (action guess) (x ?x) (y ?y)))
   (printout t "[SMART-GUESS] guess candidate-col " ?x "," ?y crlf)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Fallback: guess su qualsiasi cella ancora 'none' (se abbiamo guesses)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defrule sg-guess-fallback (declare (salience 10))
   ?st <- (status (step ?s) (currently running))
   (moves (guesses ?g &:(> ?g 0)))
   ?c <- (cell (x ?x) (y ?y) (status none))
   (not (candidate-row ?x ?y))
   (not (candidate-col ?x ?y))
   (not (potential ?x ?y))
   (not (exec (step ?s)))
   (not (guess ?x ?y))
=>
   (assert (exec (step ?s) (action guess) (x ?x) (y ?y)))
   (printout t "[SMART-GUESS] guess fallback " ?x "," ?y crlf)
)
