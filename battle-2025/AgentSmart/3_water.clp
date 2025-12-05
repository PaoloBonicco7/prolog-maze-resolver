; =============================================
; MODULO IDENTIFICAZIONE ACQUA - RAGIONAMENTO AVANZATO
; =============================================

(defmodule WATER (import AGENT ?ALL) (export ?ALL))

; ========== IDENTIFICAZIONE ACQUA BASE ==========

(defrule identify-water-from-completed-rows
    (game-state (phase running))
    ?row <- (row-val (row ?x) (boats-present ?bp) (boats-found ?bf))
    (free-cell (x ?x) (y ?y))
    (test (= ?bp ?bf))
    (not (water (x ?x) (y ?y)))
=>
    (assert (water (x ?x) (y ?y) (confirmed TRUE)))
    (printout t "ACQUA BASE: [" ?x "," ?y "] - Righe completate" crlf)
)

(defrule identify-water-from-completed-columns
    (game-state (phase running))
    ?col <- (col-val (col ?y) (boats-present ?bp) (boats-found ?bf))
    (free-cell (x ?x) (y ?y))
    (test (= ?bp ?bf))
    (not (water (x ?x) (y ?y)))
=>
    (assert (water (x ?x) (y ?y) (confirmed TRUE)))
    (printout t "ACQUA BASE: [" ?x "," ?y "] - Colonne completate" crlf)
)

; ========== IDENTIFICAZIONE ACQUA AVANZATA ==========

(defrule advanced-water-cross-constraints
    (game-state (phase running))
    ?row <- (row-val (row ?x) (boats-present ?rbp) (boats-found ?rbf))
    ?col <- (col-val (col ?y) (boats-present ?cbp) (boats-found ?cbf))
    (free-cell (x ?x) (y ?y))
    (test (and (= (- ?rbp ?rbf) 0) (= (- ?cbp ?cbf) 0)))
    (not (water (x ?x) (y ?y)))
=>
    (assert (water (x ?x) (y ?y) (confirmed TRUE)))
    (printout t "ACQUA AVANZATA: [" ?x "," ?y "] - Vincoli incrociati completi" crlf)
)

(defrule water-by-zero-remaining-boats
    (game-state (phase running))
    ?row <- (row-val (row ?x) (boats-present ?rbp) (boats-found ?rbf))
    ?col <- (col-val (col ?y) (boats-present ?cbp) (boats-found ?cbf))
    (free-cell (x ?x) (y ?y))
    (test (or (= (- ?rbp ?rbf) 0) (= (- ?cbp ?cbf) 0)))
    (not (water (x ?x) (y ?y)))
=>
    (assert (water (x ?x) (y ?y) (confirmed TRUE)))
    (printout t "ACQUA DEDUTTIVA: [" ?x "," ?y "] - Nessuna barca rimanente" crlf)
)

; ========== CLEANUP CELLE ACQUA ==========

(defrule remove-water-from-free-cells
    (game-state (phase running))
    ?fc <- (free-cell (x ?x) (y ?y))
    (water (x ?x) (y ?y) (confirmed TRUE))
=>
    (retract ?fc)
    (printout t "RIMOSSA ACQUA: [" ?x "," ?y "] da celle libere" crlf)
)