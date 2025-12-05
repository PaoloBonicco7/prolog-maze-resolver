; =============================================
; MODULO ESECUZIONE E COORDINAMENTO
; =============================================

(defrule handle-guess-result
    ?exec <- (exec (step ?s) (action guess) (x ?x) (y ?y))
    ?state <- (game-state (moves ?current) (score ?score))
=>
    (modify ?state (moves (+ ?current 1)))
    (printout t "ESEGUITA GUESS: [" ?x "," ?y "]" crlf)
    (printout t "Mossa " (+ ?current 1) " - Punteggio: " ?score crlf)
    (retract ?exec)
)

(defrule cleanup-action-planned
    ?action <- (action-planned)
    (exec (step ?s))
=>
    (retract ?action)
)

(defrule check-solution-complete
    (game-state (phase running))
    (not (free-cell (x ?x) (y ?y)))
    (not (exec (step ?s)))
=>
    (printout t "*** COMPLETATO! TUTTE LE CELLE ESPLORATE ***" crlf)
    (assert (exec (step ?s) (action solve)))
)