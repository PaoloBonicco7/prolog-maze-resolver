; Esegue guess sicure
(defrule execute-sure-guesses
    (game-state (phase running) (moves ?m))
    ?guess <- (sure-guess (x ?x) (y ?y) (content ?c))
    ?free <- (free-cell (x ?x) (y ?y))
    (not (exec (action guess) (x ?x) (y ?y)))
=>
    (printout t "ESECUZIONE GUESS SICURA: [" ?x "," ?y "] = " ?c crlf)
    (assert (exec (step ?m) (action guess) (x ?x) (y ?y) (result success) (content ?c)))
    (retract ?free)
    (retract ?guess)
)

; Esegue guess randomiche
(defrule execute-random-guesses
    (game-state (phase running) (moves ?m))
    ?exec <- (exec (action guess) (x ?x) (y ?y) (result pending))
    ?free <- (free-cell (x ?x) (y ?y))
=>
    (retract ?exec)
    (retract ?free)
    (assert (exec (step ?m) (action guess) (x ?x) (y ?y) (result success) (content unknown)))
    (printout t "ESEGUITA RANDOM GUESS: [" ?x "," ?y "]" crlf)
)

; Aggiorna statistiche dopo qualsiasi guess
(defrule update-after-guess
    ?exec <- (exec (step ?m) (action guess) (x ?x) (y ?y) (result success) (content ?content))
    ?row <- (row-val (row ?x) (boats-found ?rbf) (unknown-cells ?ruc))
    ?col <- (col-val (col ?y) (boats-found ?cbf) (unknown-cells ?cuc))
    ?state <- (game-state (moves ?current) (score ?score))
=>
    ; Aggiorna celle sconosciute
    (modify ?row (unknown-cells (- ?ruc 1)))
    (modify ?col (unknown-cells (- ?cuc 1)))
    
    ; Aggiorna barche trovate se content = boat
    (if (eq ?content boat) then
        (modify ?row (boats-found (+ ?rbf 1)))
        (modify ?col (boats-found (+ ?cbf 1)))
        (modify ?state (score (+ ?score 10)))
        (printout t "BARCA TROVATA! +10 punti" crlf)
    else
        (modify ?state (score (+ ?score 1)))
        (printout t "ACQUA/CASUALE: +1 punto" crlf)
    )
    
    ; Aggiorna mosse
    (modify ?state (moves (+ ?current 1)))
    (retract ?exec)
    
    (printout t "Mossa " (+ ?current 1) " completata - Punteggio: " 
              (if (eq ?content boat) then (+ ?score 10) else (+ ?score 1)) crlf)
    (printout t "Riga " ?x ": barche=" (if (eq ?content boat) then (+ ?rbf 1) else ?rbf) 
              " unknown=" (- ?ruc 1) crlf)
    (printout t "Colonna " ?y ": barche=" (if (eq ?content boat) then (+ ?cbf 1) else ?cbf) 
              " unknown=" (- ?cuc 1) crlf crlf)
)

; Verifica completamento
(defrule check-solution-complete
    (game-state (phase running) (moves ?m))
    (not (free-cell (x ?x) (y ?y)))
=>
    (printout t "*** SOLUZIONE COMPLETATA! ***" crlf)
    (assert (exec (step ?m) (action complete) (result success)))
)

; Report finale
(defrule final-solve-report
    ?exec <- (exec (action complete) (result success))
    ?s <- (game-state (phase running) (score ?score) (moves ?moves))
=>
    (modify ?s (phase completed))
    (retract ?exec)
    (printout t crlf "=== SOLVE COMPLETATO ===" crlf)
    (printout t "Mosse Effettuate: " ?moves crlf)
    (printout t "Punteggio Finale: " ?score crlf)
    (printout t "==========================" crlf)
)

; Timeout per sicurezza
(defrule solve-timeout
    (game-state (phase running) (moves ?m) (max-moves ?max))
    (test (>= ?m ?max))
=>
    (printout t "*** TIMEOUT - LIMITE MOSSE RAGGIUNTO ***" crlf)
    (assert (exec (step ?m) (action complete) (result success)))
)