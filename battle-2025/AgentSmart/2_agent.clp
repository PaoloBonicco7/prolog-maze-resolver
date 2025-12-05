(defmodule AGENT (export ?ALL))

; ========== TEMPLATES PER STATO INTERNO AGENTE ==========

(deftemplate AGENT::game-state
    (slot phase (allowed-values setup running completed) (default setup))
    (slot fires-used (default 0))
    (slot guesses-used (default 0))
    (slot total-moves (default 0))
)

(deftemplate AGENT::cell-knowledge
    (slot x)
    (slot y)
    (slot content (allowed-values unknown water boat) (default unknown))
    (slot guessed (default FALSE))
    (slot fired (default FALSE))
    (slot certainty (default 0.0))
)

(deftemplate AGENT::ship-info
    (slot type (allowed-values corazzata incrociatore cacciatorpediniere sottomarino))
    (slot size)
    (slot remaining (default 0))
    (slot identified (default FALSE))
)

(deftemplate AGENT::strategy-decision
    (slot type (allowed-values information-gain pattern-completion probability-fire exploration))
    (slot x)
    (slot y)
    (slot action (allowed-values fire guess))
    (slot priority (default 0))
)

(deftemplate AGENT::boat-segment
    (slot x)
    (slot y)
    (slot ship-type)
    (slot orientation (allowed-values unknown horizontal vertical))
)

(deftemplate AGENT::row-col-info
    (slot index)
    (slot type (allowed-values row column))
    (slot boats-expected)
    (slot boats-found (default 0))
    (slot unknowns (default 0))
)

; ========== FATTI INIZIALI AGENTE ==========

(deffacts AGENT::agent-initial-knowledge
    (game-state (phase setup))
    
    ; Informazioni navi conosciute dal problema
    (ship-info (type corazzata) (size 4) (remaining 1))
    (ship-info (type incrociatore) (size 3) (remaining 2))
    (ship-info (type cacciatorpediniere) (size 2) (remaining 3))
    (ship-info (type sottomarino) (size 1) (remaining 4))
    
    ; Inizializza conoscenza celle (verrà aggiornata dalle percezioni)
    (forall (x (range 1 10))
        (forall (y (range 1 10))
            (cell-knowledge (x ?x) (y ?y) (content unknown))
        )
    )
)

; ========== REGOLE PER PROCESSARE INFORMAZIONI AMBIENTE ==========

(defrule AGENT::process-initial-water
    (declare (salience 1000))
    (ENV::water ?x ?y)
    ?cell <- (AGENT::cell-knowledge (x ?x) (y ?y) (content unknown))
=>
    (modify ?cell (content water) (certainty 1.0))
    (printout t "AGENT: Cella [" ?x "," ?y "] marcata come ACQUA" crlf)
)

(defrule AGENT::process-initial-boat
    (declare (salience 1000))
    (ENV::boat ?x ?y)
    ?cell <- (AGENT::cell-knowledge (x ?x) (y ?y) (content unknown))
=>
    (modify ?cell (content boat) (certainty 1.0))
    (printout t "AGENT: Cella [" ?x "," ?y "] marcata come NAVE" crlf)
)

(defrule AGENT::process-row-constraint
    (ENV::row ?row ?boats)
    (not (AGENT::row-col-info (index ?row) (type row)))
=>
    (assert (AGENT::row-col-info (index ?row) (type row) (boats-expected ?boats)))
    (printout t "AGENT: Riga " ?row " deve avere " ?boats " celle nave" crlf)
)

(defrule AGENT::process-col-constraint  
    (ENV::col ?col ?boats)
    (not (AGENT::row-col-info (index ?col) (type column)))
=>
    (assert (AGENT::row-col-info (index ?col) (type column) (boats-expected ?boats)))
    (printout t "AGENT: Colonna " ?col " deve avere " ?boats " celle nave" crlf)
)

; ========== STRATEGIA 1: INFORMATION GAIN ==========

(defrule AGENT::information-gain-high-uncertainty
    (game-state (phase running))
    (not (strategy-decision))
    ?cell <- (cell-knowledge (x ?x) (y ?y) (content unknown) (certainty 0.0))
    (row-col-info (index ?x) (type column) (boats-expected ?col-boats) (boats-found ?col-found))
    (row-col-info (index ?y) (type row) (boats-expected ?row-boats) (boats-found ?row-found))
    (test (> (+ ?col-boats ?row-boats) (+ ?col-found ?row-found)))
=>
    (assert (strategy-decision (type information-gain) (x ?x) (y ?y) (action fire) (priority 90)))
    (printout t "STRATEGIA Information-Gain: Cella [" ?x "," ?y "] - alta incertezza" crlf)
)

; ========== STRATEGIA 2: PATTERN COMPLETION ==========

(defrule AGENT::pattern-completion-horizontal
    (game-state (phase running))
    (not (strategy-decision))
    (cell-knowledge (x ?x) (y ?y) (content boat) (guessed FALSE))
    (cell-knowledge (x ?x2) (y ?y) (content boat) (guessed FALSE))
    (test (or (= ?x2 (- ?x 1)) (= ?x2 (+ ?x 1))))
    (cell-knowledge (x ?x3) (y ?y) (content unknown))
    (test (or (= ?x3 (- ?x 1)) (= ?x3 (+ ?x 1)) (= ?x3 (- ?x 2)) (= ?x3 (+ ?x 2))))
=>
    (assert (strategy-decision (type pattern-completion) (x ?x3) (y ?y) (action guess) (priority 95)))
    (printout t "STRATEGIA Pattern-Completion: Cella [" ?x3 "," ?y "] - completamento orizzontale" crlf)
)

(defrule AGENT::pattern-completion-vertical
    (game-state (phase running))
    (not (strategy-decision))
    (cell-knowledge (x ?x) (y ?y) (content boat) (guessed FALSE))
    (cell-knowledge (x ?x) (y ?y2) (content boat) (guessed FALSE))
    (test (or (= ?y2 (- ?y 1)) (= ?y2 (+ ?y 1))))
    (cell-knowledge (x ?x) (y ?y3) (content unknown))
    (test (or (= ?y3 (- ?y 1)) (= ?y3 (+ ?y 1)) (= ?y3 (- ?y 2)) (= ?y3 (+ ?y 2))))
=>
    (assert (strategy-decision (type pattern-completion) (x ?x) (y ?y3) (action guess) (priority 95)))
    (printout t "STRATEGIA Pattern-Completion: Cella [" ?x "," ?y3 "] - completamento verticale" crlf)
)

; ========== STRATEGIA 3: PROBABILITY FIRE ==========

(defrule AGENT::probability-fire-high-chance
    (game-state (phase running))
    (not (strategy-decision))
    ?cell <- (cell-knowledge (x ?x) (y ?y) (content unknown) (certainty ?c))
    (row-col-info (index ?x) (type column) (boats-expected ?col-exp) (boats-found ?col-found))
    (row-col-info (index ?y) (type row) (boats-expected ?row-exp) (boats-found ?row-found))
    (test (and (> ?col-exp ?col-found) (> ?row-exp ?row-found)))
    (fires-used ?used)
    (test (< ?used 5))
=>
    (bind ?priority (+ (* (- ?col-exp ?col-found) 10) (* (- ?row-exp ?row-found) 10)))
    (assert (strategy-decision (type probability-fire) (x ?x) (y ?y) (action fire) (priority ?priority)))
    (printout t "STRATEGIA Probability-Fire: Cella [" ?x "," ?y "] - probabilità alta" crlf)
)

; ========== STRATEGIA 4: EXPLORATION (FALLBACK) ==========

(defrule AGENT::exploration-fallback
    (game-state (phase running))
    (not (strategy-decision))
    ?cell <- (cell-knowledge (x ?x) (y ?y) (content unknown))
    (test (and (>= ?x 4) (<= ?x 7) (>= ?y 4) (<= ?y 7))) ; area centrale
=>
    (assert (strategy-decision (type exploration) (x ?x) (y ?y) (action fire) (priority 70)))
    (printout t "STRATEGIA Exploration: Cella [" ?x "," ?y "] - area centrale" crlf)
)

(defrule AGENT::exploration-any-unknown
    (game-state (phase running))
    (not (strategy-decision))
    ?cell <- (cell-knowledge (x ?x) (y ?y) (content unknown))
=>
    (assert (strategy-decision (type exploration) (x ?x) (y ?y) (action fire) (priority 50)))
    (printout t "STRATEGIA Exploration: Cella [" ?x "," ?y "] - qualsiasi unknown" crlf)
)

; ========== SELEZIONE MIGLIORE STRATEGIA ==========

(defrule AGENT::select-best-strategy
    (declare (salience 100))
    (game-state (phase running))
    ?strat1 <- (strategy-decision (type ?t1) (x ?x1) (y ?y1) (action ?a1) (priority ?p1))
    (not (strategy-decision (priority ?p2&:(> ?p2 ?p1))))
=>
    (printout t "SELEZIONATA Strategia " ?t1 " per [" ?x1 "," ?y1 "] - Priorità: " ?p1 crlf)
)

; ========== ESECUZIONE AZIONI ==========

(defrule AGENT::execute-fire-action
    (game-state (phase running))
    ?strat <- (strategy-decision (x ?x) (y ?y) (action fire))
    (fires-used ?used)
    (test (< ?used 5))
=>
    (retract ?strat)
    (printout t "ACTION: fire " ?x " " ?y crlf)
    (assert (ENV::action (type fire) (x ?x) (y ?y)))
)

(defrule AGENT::execute-guess-action
    (game-state (phase running))
    ?strat <- (strategy-decision (x ?x) (y ?y) (action guess))
    (guesses-used ?used)
    (test (< ?used 20))
=>
    (retract ?strat)
    (printout t "ACTION: guess " ?x " " ?y crlf)
    (assert (ENV::action (type guess) (x ?x) (y ?y)))
)

(defrule AGENT::execute-solve-when-certain
    (game-state (phase running))
    (cell-knowledge (content boat) (guessed FALSE))
    (not (cell-knowledge (content boat) (guessed FALSE)))
=>
    (printout t "ACTION: solve" crlf)
    (assert (ENV::action (type solve)))
)

; ========== GESTIONE RISPOSTE AMBIENTE ==========

(defrule AGENT::process-fire-result-water
    (ENV::percept (type fire-result) (x ?x) (y ?y) (content water))
    ?cell <- (cell-knowledge (x ?x) (y ?y) (content unknown))
    ?state <- (game-state (fires-used ?used))
=>
    (modify ?cell (content water) (fired TRUE) (certainty 1.0))
    (modify ?state (fires-used (+ ?used 1)) (total-moves (+ ?total-moves 1)))
    (printout t "AGENT: Fire su [" ?x "," ?y "] = ACQUA" crlf)
)

(defrule AGENT::process-fire-result-boat
    (ENV::percept (type fire-result) (x ?x) (y ?y) (content boat))
    ?cell <- (cell-knowledge (x ?x) (y ?y) (content unknown))
    ?state <- (game-state (fires-used ?used))
=>
    (modify ?cell (content boat) (fired TRUE) (certainty 1.0))
    (modify ?state (fires-used (+ ?used 1)) (total-moves (+ ?total-moves 1)))
    (printout t "AGENT: Fire su [" ?x "," ?y "] = NAVE" crlf)
)

(defrule AGENT::process-guess-result
    (ENV::percept (type guess-result) (x ?x) (y ?y) (correct ?correct))
    ?cell <- (cell-knowledge (x ?x) (y ?y))
    ?state <- (game-state (guesses-used ?used))
=>
    (modify ?cell (guessed TRUE))
    (modify ?state (guesses-used (+ ?used 1)) (total-moves (+ ?total-moves 1)))
    (printout t "AGENT: Guess su [" ?x "," ?y "] = " (if ?correct then "CORRETTO" else "ERRATO") crlf)
)

; ========== INIZIALIZZAZIONE ==========

(defrule AGENT::start-agent
    ?state <- (game-state (phase setup))
=>
    (modify ?state (phase running))
    (printout t "=== AGENTE BATTAGLIA NAVALE INIZIALIZZATO ===" crlf)
    (printout t "Strategie attive: Information-Gain, Pattern-Completion, Probability-Fire, Exploration" crlf)
)