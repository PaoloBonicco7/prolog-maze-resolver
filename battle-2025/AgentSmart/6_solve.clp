; =============================================
; MODULO ESECUZIONE E COORDINAMENTO - GESTIONE AVANZATA
; =============================================

(defmodule SOLVE (import AGENT STRATEGY ?ALL) (export ?ALL))

; ========== ESECUZIONE GUESS SICURE ==========

; Esegue guess sicure per barche
(defrule execute-sure-boat-guesses
    (game-state (phase running))
    ?guess <- (sure-guess (x ?x) (y ?y) (content boat))
    ?free <- (free-cell (x ?x) (y ?y))
    (not (exec (step ?s)))
    (not (action-planned))
=>
    (printout t "ESECUZIONE GUESS SICURA: [" ?x "," ?y "] = boat" crlf)
    (assert (exec (step ?s) (action guess) (x ?x) (y ?y)))
    (assert (action-planned))
    (retract ?free)
    (retract ?guess)
)

; Esegue guess sicure per acqua
(defrule execute-sure-water-guesses
    (game-state (phase running))
    ?guess <- (sure-guess (x ?x) (y ?y) (content water))
    ?free <- (free-cell (x ?x) (y ?y))
    (not (exec (step ?s)))
    (not (action-planned))
=>
    (printout t "ESECUZIONE GUESS SICURA: [" ?x "," ?y "] = water" crlf)
    (assert (exec (step ?s) (action guess) (x ?x) (y ?y)))
    (assert (action-planned))
    (retract ?free)
    (retract ?guess)
)

; ========== ESECUZIONE STRATEGIE AVANZATE ==========

; Esegue strategia information gain
(defrule execute-information-gain-strategy
    (game-state (phase running))
    (cell-priority (x ?x) (y ?y) (priority-score ?score&:(> ?score 50)))
    (free-cell (x ?x) (y ?y))
    (not (sure-guess (x ?x) (y ?y)))
    (not (water (x ?x) (y ?y)))
    (not (exec (step ?s)))
    (not (action-planned))
=>
    (printout t "STRATEGIA INFORMATION GAIN: [" ?x "," ?y "] - Score: " ?score crlf)
    (assert (exec (step ?s) (action guess) (x ?x) (y ?y)))
    (assert (action-planned))
)

; ========== GESTIONE RISULTATI E APPRENDIMENTO ==========

; Gestisce risultato guess di barca
(defrule handle-boat-result
    ?exec <- (exec (step ?s) (action guess) (x ?x) (y ?y))
    (cell (x ?x) (y ?y) (content boat))
    ?row <- (row-val (row ?x) (boats-found ?rbf) (unknown-cells ?ruc))
    ?col <- (col-val (col ?y) (boats-found ?cbf) (unknown-cells ?cuc))
    ?state <- (game-state (moves ?current) (score ?score))
=>
    ; Aggiorna statistiche
    (modify ?row (boats-found (+ ?rbf 1)) (unknown-cells (- ?ruc 1)))
    (modify ?col (boats-found (+ ?cbf 1)) (unknown-cells (- ?cuc 1)))
    (modify ?state (moves (+ ?current 1)) (score (+ ?score 10)))
    (retract ?exec)
    
    (printout t "SUCCESSO: BARCA TROVATA! [" ?x "," ?y "]" crlf)
    (printout t "Mossa " (+ ?current 1) " - Punteggio: " (+ ?score 10) crlf)
    (printout t "Aggiornamento - Riga " ?x ": barche=" (+ ?rbf 1) " unknown=" (- ?ruc 1) crlf)
    (printout t "Aggiornamento - Colonna " ?y ": barche=" (+ ?cbf 1) " unknown=" (- ?cuc 1) crlf crlf)
)

; Gestisce risultato guess d'acqua
(defrule handle-water-result
    ?exec <- (exec (step ?s) (action guess) (x ?x) (y ?y))
    (cell (x ?x) (y ?y) (content water))
    ?row <- (row-val (row ?x) (unknown-cells ?ruc))
    ?col <- (col-val (col ?y) (unknown-cells ?cuc))
    ?state <- (game-state (moves ?current) (score ?score))
=>
    (modify ?row (unknown-cells (- ?ruc 1)))
    (modify ?col (unknown-cells (- ?cuc 1)))
    (modify ?state (moves (+ ?current 1)) (score (+ ?score 1)))
    (retract ?exec)
    
    (printout t "SUCCESSO: ACQUA CONFERMATA [" ?x "," ?y "]" crlf)
    (printout t "Mossa " (+ ?current 1) " - Punteggio: " (+ ?score 1) crlf crlf)
)

; ========== STRATEGIA FIRE INTELLIGENTE ==========

; Fire per confermare pattern critici
(defrule strategic-fire-for-pattern-confirmation
    (game-state (phase running))
    (moves (fires ?nf&:(> ?nf 0)))
    (boat-pattern (type ?type) (x ?px) (y ?py) (size ?s) (confidence ?c&:(> ?c 0.8)))
    (free-cell (x ?x) (y ?y))
    ; Cella che completa la nave
    (test (case ?type
        (horizontal (and (= ?x ?px) (= ?y (+ ?py ?s))))
        (vertical (and (= ?y ?py) (= ?x (+ ?px ?s))))
        (else FALSE)
    ))
    (not (exec (step ?s)))
    (not (action-planned))
=>
    (assert (exec (step ?s) (action fire) (x ?x) (y ?y)))
    (assert (action-planned))
    (printout t "STRATEGIA FIRE: [" ?x "," ?y "] per confermare pattern " ?type crlf)
)

; Fire per celle ad alto information gain
(defrule strategic-fire-high-information
    (game-state (phase running))
    (moves (fires ?nf&:(> ?nf 0)))
    (cell-priority (x ?x) (y ?y) (priority-score ?score&:(> ?score 80)))
    (free-cell (x ?x) (y ?y))
    (not (sure-guess (x ?x) (y ?y)))
    (not (water (x ?x) (y ?y)))
    (not (exec (step ?s)))
    (not (action-planned))
=>
    (assert (exec (step ?s) (action fire) (x ?x) (y ?y)))
    (assert (action-planned))
    (printout t "FIRE STRATEGICO: [" ?x "," ?y "] - Score: " ?score crlf)
)

; ========== PULIZIA E AGGIORNAMENTO STATO ==========

; Pulisce le priorità dopo l'uso
(defrule cleanup-priorities
    ?exec <- (exec (step ?s) (action guess) (x ?x) (y ?y))
    ?priority <- (cell-priority (x ?x) (y ?y))
=>
    (retract ?priority)
)

; Pulisce le probabilità dopo l'uso
(defrule cleanup-probabilities
    ?exec <- (exec (step ?s) (action guess) (x ?x) (y ?y))
    ?prob <- (probability-cell (x ?x) (y ?y))
=>
    (retract ?prob)
)

; Pulisce action-planned dopo esecuzione
(defrule cleanup-action-planned
    ?action <- (action-planned)
    (exec (step ?s))
=>
    (retract ?action)
)

; ========== VERIFICA COMPLETAMENTO ==========

(defrule check-solution-complete
    (game-state (phase running))
    (not (free-cell (x ?x) (y ?y)))
    (not (exec (step ?s)))
=>
    (printout t "*** COMPLETATO! TUTTE LE CELLE ESPLORATE ***" crlf)
    (assert (exec (step ?s) (action solve)))
)

; ========== GESTIONE ERRORI E TIMEOUT ==========

(defrule handle-no-actions
    (game-state (phase running))
    (not (exec (step ?s)))
    (not (action-planned))
    (free-cell (x ?x) (y ?y))
=>
    (printout t "ATTENZIONE: Nessuna azione pianificata per celle libere" crlf)
    (assert (strategy-selected (type advanced-exploration) (x ?x) (y ?y) (priority 10)))
)

; ========== STATISTICHE E REPORT ==========

(defrule update-move-count
    ?exec <- (exec (step ?s))
    ?state <- (game-state (moves ?m))
=>
    (modify ?state (moves (+ ?m 1)))
)

(defrule final-solve-report
    ?exec <- (exec (action solve))
    ?s <- (game-state (phase running) (score ?score) (moves ?moves))
=>
    (modify ?s (phase completed))
    (retract ?exec)
    
    (bind ?total-boats-found 0)
    (do-for-all-facts ((?f row-val)) TRUE
        (bind ?total-boats-found (+ ?total-boats-found (fact-slot-value ?f boats-found)))
    )
    
    (bind ?total-boats 0)
    (do-for-all-facts ((?f row-val)) TRUE
        (bind ?total-boats (+ ?total-boats (fact-slot-value ?f boats-present)))
    )
    
    (bind ?sure-guesses 0)
    (do-for-all-facts ((?f sure-guess)) TRUE
        (bind ?sure-guesses (+ ?sure-guesses 1))
    )
    
    (printout t crlf "=== RAPPORTO FINALE AGENTE AVANZATO ===" crlf)
    (printout t "Mosse Totali Effettuate: " ?moves crlf)
    (printout t "Punteggio Finale: " ?score crlf)
    (printout t "Efficienza: " (format nil "%.2f" (/ ?score (* ?moves 1.0))) " punti/mossa" crlf)
    (printout t "Barche Trovate: " ?total-boats-found "/" ?total-boats crlf)
    (printout t "Guess Sicure: " ?sure-guesses crlf)
    (printout t "Strategie Attive: 4" crlf)
    (printout t "========================================" crlf crlf)
)

; ========== GESTIONE FIRE RESULTS ==========

(defrule handle-fire-boat-result
    ?exec <- (exec (step ?s) (action fire) (x ?x) (y ?y))
    (cell (x ?x) (y ?y) (content boat))
    ?state <- (game-state (moves ?current) (score ?score))
=>
    (modify ?state (moves (+ ?current 1)) (score (+ ?score 5)))
    (retract ?exec)
    (printout t "FIRE SUCCESS: Barca colpita [" ?x "," ?y "]" crlf)
)

(defrule handle-fire-water-result
    ?exec <- (exec (step ?s) (action fire) (x ?x) (y ?y))
    (cell (x ?x) (y ?y) (content water))
    ?state <- (game-state (moves ?current) (score ?score))
=>
    (modify ?state (moves (+ ?current 1)) (score (+ ?score 1)))
    (retract ?exec)
    (printout t "FIRE: Acqua [" ?x "," ?y "]" crlf)
)