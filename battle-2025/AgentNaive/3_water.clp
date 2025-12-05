; Template per celle d'acqua
(deftemplate water
    (slot x)
    (slot y)
    (slot confirmed (default FALSE))
)

; Identifica acqua da righe completate
(defrule identify-water-from-completed-rows
    (game-state (phase running))
    ?row <- (row-val (row ?x) (boats-present ?bp) (boats-found ?bf))
    (free-cell (x ?x) (y ?y))
    (test (= ?bp ?bf))
    (not (water (x ?x) (y ?y)))
=>
    (assert (water (x ?x) (y ?y) (confirmed TRUE)))
    (printout t "ACQUA IDENTIFICATA: [" ?x "," ?y "] - Ragione: riga completata" crlf)
)

; Identifica acqua da colonne completate
(defrule identify-water-from-completed-columns
    (game-state (phase running))
    ?col <- (col-val (col ?y) (boats-present ?bp) (boats-found ?bf))
    (free-cell (x ?x) (y ?y))
    (test (= ?bp ?bf))
    (not (water (x ?x) (y ?y)))
=>
    (assert (water (x ?x) (y ?y) (confirmed TRUE)))
    (printout t "ACQUA IDENTIFICATA: [" ?x "," ?y "] - Ragione: colonna completata" crlf)
)