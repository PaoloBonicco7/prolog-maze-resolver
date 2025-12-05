; Template per guess sicure
(deftemplate sure-guess
    (slot x)
    (slot y)
    (slot content (allowed-values boat water))
    (slot reasoning)
)

; Guess sicura barca da riga
(defrule sure-guess-boat-from-row
    (game-state (phase running))
    ?row <- (row-val (row ?x) (boats-present ?bp) (boats-found ?bf) (unknown-cells ?uc))
    (free-cell (x ?x) (y ?y))
    (test (and (= ?uc (- ?bp ?bf)) (> (- ?bp ?bf) 0)))
    (not (sure-guess (x ?x) (y ?y)))
    (not (water (x ?x) (y ?y)))
=>
    (assert (sure-guess (x ?x) (y ?y) (content boat) 
             (reasoning "Tutte celle rimanenti devono contenere barche")))
    (printout t "GUESS SICURA BARCA: [" ?x "," ?y "] - Ragione: riga" crlf)
)

; Guess sicura barca da colonna
(defrule sure-guess-boat-from-column
    (game-state (phase running))
    ?col <- (col-val (col ?y) (boats-present ?bp) (boats-found ?bf) (unknown-cells ?uc))
    (free-cell (x ?x) (y ?y))
    (test (and (= ?uc (- ?bp ?bf)) (> (- ?bp ?bf) 0)))
    (not (sure-guess (x ?x) (y ?y)))
    (not (water (x ?x) (y ?y)))
=>
    (assert (sure-guess (x ?x) (y ?y) (content boat) 
             (reasoning "Tutte celle rimanenti devono contenere barche")))
    (printout t "GUESS SICURA BARCA: [" ?x "," ?y "] - Ragione: colonna" crlf)
)

; Guess sicura acqua
(defrule sure-guess-water
    (water (x ?x) (y ?y) (confirmed TRUE))
    (not (sure-guess (x ?x) (y ?y)))
=>
    (assert (sure-guess (x ?x) (y ?y) (content water) 
             (reasoning "Confermato acqua dai vincoli")))
    (printout t "GUESS SICURA ACQUA: [" ?x "," ?y "]" crlf)
)