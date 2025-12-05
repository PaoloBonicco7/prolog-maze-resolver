; Template per strategie random
(deftemplate random-strategy
    (slot strategy-id)
    (slot description)
)

(deffacts random-strategies
    (random-strategy (strategy-id 1) (description "Selezione casuale celle libere"))
    (random-strategy (strategy-id 2) (description "Priorità celle con incertezza massima"))
)

; Nel file 5_random.clp, modifica le regole:

; Guess randomica base - UNA SOLA PER VOLTA
(defrule random-guess-basic
    (game-state (phase running) (moves ?m))
    ?free <- (free-cell (x ?x) (y ?y))
    (not (sure-guess (x ?x) (y ?y)))
    (not (water (x ?x) (y ?y)))
    (not (exec (action guess) (x ?x) (y ?y)))
    (random-strategy (strategy-id 1))
    (not (exec (action guess) (result pending))) ; SOLO SE NON C'E' GIA' UNA GUESS IN SOSPESO
=>
    (printout t "RANDOM GUESS: Cella [" ?x "," ?y "]" crlf)
    (assert (exec (step ?m) (action guess) (x ?x) (y ?y) (result pending)))
)

; Priorità celle con incertezza massima - UNA SOLA PER VOLTA
(defrule prioritize-uncertain-cells
    (game-state (phase running) (moves ?m))
    ?free <- (free-cell (x ?x) (y ?y))
    (row-val (row ?x) (unknown-cells ?uc1&:(> ?uc1 0)))
    (col-val (col ?y) (unknown-cells ?uc2&:(> ?uc2 0)))
    (not (sure-guess (x ?x) (y ?y)))
    (not (water (x ?x) (y ?y)))
    (not (exec (action guess) (x ?x) (y ?y)))
    (random-strategy (strategy-id 2))
    (not (exec (action guess) (result pending))) ; SOLO SE NON C'E' GIA' UNA GUESS IN SOSPESO
=>
    (bind ?uncertainty (* ?uc1 ?uc2))
    (printout t "PRIORITY GUESS: Cella [" ?x "," ?y "] Incertezza: " ?uncertainty crlf)
    (assert (exec (step ?m) (action guess) (x ?x) (y ?y) (result pending)))
)
