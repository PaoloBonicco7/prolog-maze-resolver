; =============================================
; MODULO STRATEGIE AVANZATE - CUORE DELL'AGENTE INTELLIGENTE
; =============================================

(defmodule STRATEGY (import AGENT GUESS ?ALL) (export ?ALL))

; ========== STRATEGIA 1: MASSIMO INFORMATION GAIN ==========

; Calcola priorità delle celle basata sull'information gain
(defrule calculate-information-gain-positive-row
    (game-state (phase running))
    (free-cell (x ?x) (y ?y))
    (not (cell-priority (x ?x) (y ?y)))
    ?row <- (row-val (row ?x) (boats-present ?rbp) (boats-found ?rbf) (unknown-cells ?ruc))
    ?col <- (col-val (col ?y) (boats-present ?cbp) (boats-found ?cbf) (unknown-cells ?cuc))
    (test (and (> ?ruc 0) (> (- ?rbp ?rbf) 0) (> ?cuc 0) (> (- ?cbp ?cbf) 0)))
=>
    (bind ?row-info (/ (- ?rbp ?rbf) ?ruc))
    (bind ?col-info (/ (- ?cbp ?cbf) ?cuc))
    (bind ?priority-score (* (+ ?row-info ?col-info) 100.0))
    
    (assert (cell-priority (x ?x) (y ?y) (priority-score ?priority-score)
             (reasoning "Information Gain")))
    (printout t "INFO GAIN: [" ?x "," ?y "] score=" (format nil "%.2f" ?priority-score) 
              " (row:" (format nil "%.2f" ?row-info) " col:" (format nil "%.2f" ?col-info) ")" crlf)
)

; Information gain solo per riga
(defrule calculate-information-gain-row-only
    (game-state (phase running))
    (free-cell (x ?x) (y ?y))
    (not (cell-priority (x ?x) (y ?y)))
    ?row <- (row-val (row ?x) (boats-present ?rbp) (boats-found ?rbf) (unknown-cells ?ruc))
    ?col <- (col-val (col ?y) (boats-present ?cbp) (boats-found ?cbf) (unknown-cells ?cuc))
    (test (and (> ?ruc 0) (> (- ?rbp ?rbf) 0)))
    (test (or (<= ?cuc 0) (<= (- ?cbp ?cbf) 0)))
=>
    (bind ?row-info (/ (- ?rbp ?rbf) ?ruc))
    (bind ?priority-score (* ?row-info 100.0))
    
    (assert (cell-priority (x ?x) (y ?y) (priority-score ?priority-score)
             (reasoning "Information Gain (solo riga)")))
    (printout t "INFO GAIN: [" ?x "," ?y "] score=" (format nil "%.2f" ?priority-score) 
              " (row:" (format nil "%.2f" ?row-info) " col:0.00)" crlf)
)

; Information gain solo per colonna
(defrule calculate-information-gain-col-only
    (game-state (phase running))
    (free-cell (x ?x) (y ?y))
    (not (cell-priority (x ?x) (y ?y)))
    ?row <- (row-val (row ?x) (boats-present ?rbp) (boats-found ?rbf) (unknown-cells ?ruc))
    ?col <- (col-val (col ?y) (boats-present ?cbp) (boats-found ?cbf) (unknown-cells ?cuc))
    (test (and (> ?cuc 0) (> (- ?cbp ?cbf) 0)))
    (test (or (<= ?ruc 0) (<= (- ?rbp ?rbf) 0)))
=>
    (bind ?col-info (/ (- ?cbp ?cbf) ?cuc))
    (bind ?priority-score (* ?col-info 100.0))
    
    (assert (cell-priority (x ?x) (y ?y) (priority-score ?priority-score)
             (reasoning "Information Gain (solo colonna)")))
    (printout t "INFO GAIN: [" ?x "," ?y "] score=" (format nil "%.2f" ?priority-score) 
              " (row:0.00 col:" (format nil "%.2f" ?col-info) ")" crlf)
)

; ========== STRATEGIA 2: RICONOSCIMENTO PATTERN BARCHE ==========

; Rileva barche orizzontali
(defrule detect-horizontal-pattern
    (game-state (phase running))
    ?exec1 <- (exec (action guess) (x ?x) (y ?y) (result success) (content boat))
    ?exec2 <- (exec (action guess) (x ?x) (y ?y2) (result success) (content boat))
    (test (= ?y2 (+ ?y 1)))  ; Celle consecutive orizzontalmente
    (not (boat-pattern (type horizontal) (x ?x) (y ?y)))
=>
    (assert (boat-pattern (type horizontal) (x ?x) (y ?y) (size 2) (confidence 0.8)))
    (retract ?exec1 ?exec2)
    (printout t "PATTERN: Barca orizzontale 2 celle a [" ?x "," ?y "]" crlf)
)

; Rileva barche verticali
(defrule detect-vertical-pattern
    (game-state (phase running))
    ?exec1 <- (exec (action guess) (x ?x) (y ?y) (result success) (content boat))
    ?exec2 <- (exec (action guess) (x ?x2) (y ?y) (result success) (content boat))
    (test (= ?x2 (+ ?x 1)))  ; Celle consecutive verticalmente
    (not (boat-pattern (type vertical) (x ?x) (y ?y)))
=>
    (assert (boat-pattern (type vertical) (x ?x) (y ?y) (size 2) (confidence 0.8)))
    (retract ?exec1 ?exec2)
    (printout t "PATTERN: Barca verticale 2 celle a [" ?x "," ?y "]" crlf)
)

; Estende pattern orizzontale esistente
(defrule extend-horizontal-pattern
    (game-state (phase running))
    ?pattern <- (boat-pattern (type horizontal) (x ?px) (y ?py) (size ?size) (confidence ?conf))
    ?exec <- (exec (action guess) (x ?px) (y ?y) (result success) (content boat))
    (test (= ?y (+ ?py ?size)))  ; Estensione del pattern
=>
    (modify ?pattern (size (+ ?size 1)) (confidence (+ ?conf 0.1)))
    (retract ?exec)
    (printout t "PATTERN EXTEND: Barca orizzontale ora " (+ ?size 1) " celle" crlf)
)

; ========== STRATEGIA 3: ANALISI PROBABILISTICA ==========

; Calcola probabilità per celle con entrambi i vincoli positivi
(defrule calculate-probabilities-both
    (game-state (phase running))
    (free-cell (x ?x) (y ?y))
    (not (probability-cell (x ?x) (y ?y)))
    ?row <- (row-val (row ?x) (boats-present ?rbp) (boats-found ?rbf) (unknown-cells ?ruc))
    ?col <- (col-val (col ?y) (boats-present ?cbp) (boats-found ?cbf) (unknown-cells ?cuc))
    (test (and (> ?ruc 0) (> ?cuc 0)))
=>
    (bind ?row-prob (/ (- ?rbp ?rbf) ?ruc))
    (bind ?col-prob (/ (- ?cbp ?cbf) ?cuc))
    (bind ?combined-prob (/ (+ ?row-prob ?col-prob) 2.0))
    
    (assert (probability-cell (x ?x) (y ?y) 
             (boat-probability ?combined-prob)
             (water-probability (- 1.0 ?combined-prob))))
    (printout t "PROBABILITY: [" ?x "," ?y "] barca=" (format nil "%.2f" ?combined-prob) 
              " acqua=" (format nil "%.2f" (- 1.0 ?combined-prob)) crlf)
)

; Calcola probabilità solo per riga
(defrule calculate-probabilities-row-only
    (game-state (phase running))
    (free-cell (x ?x) (y ?y))
    (not (probability-cell (x ?x) (y ?y)))
    ?row <- (row-val (row ?x) (boats-present ?rbp) (boats-found ?rbf) (unknown-cells ?ruc))
    ?col <- (col-val (col ?y) (boats-present ?cbp) (boats-found ?cbf) (unknown-cells ?cuc))
    (test (and (> ?ruc 0) (<= ?cuc 0)))
=>
    (bind ?combined-prob (/ (- ?rbp ?rbf) ?ruc))
    
    (assert (probability-cell (x ?x) (y ?y) 
             (boat-probability ?combined-prob)
             (water-probability (- 1.0 ?combined-prob))))
    (printout t "PROBABILITY: [" ?x "," ?y "] barca=" (format nil "%.2f" ?combined-prob) 
              " acqua=" (format nil "%.2f" (- 1.0 ?combined-prob)) crlf)
)

; ========== STRATEGIA 4: PROPAGAZIONE VINCOLI ==========

; Propaga vincoli tra righe e colonne
(defrule constraint-propagation
    (game-state (phase running))
    ?row <- (row-val (row ?x) (boats-present ?rbp) (boats-found ?rbf) (unknown-cells ?ruc))
    ?col <- (col-val (col ?y) (boats-present ?cbp) (boats-found ?cbf) (unknown-cells ?cuc))
    (free-cell (x ?x) (y ?y))
    ; Se una cella è critica per entrambi i vincoli
    (test (and (= ?ruc (- ?rbp ?rbf)) (= ?cuc (- ?cbp ?cbf)) (> (- ?rbp ?rbf) 0)))
    (not (sure-guess (x ?x) (y ?y)))
=>
    (assert (sure-guess (x ?x) (y ?y) (content boat) 
             (reasoning "Propagazione vincoli incrociati")))
    (printout t "CONSTRAINT PROPAGATION: [" ?x "," ?y "] = BARCA (vincoli critici)" crlf)
)

; ========== SELEZIONE STRATEGIA OTTIMALE ==========

; Seleziona la cella con massima priorità per l'azione successiva
(defrule select-best-strategy-cell
    (game-state (phase running))
    (free-cell (x ?x) (y ?y))
    (not (sure-guess (x ?x) (y ?y)))
    (not (water (x ?x) (y ?y)))
    (not (exec (action guess) (x ?x) (y ?y)))
    ; Trova la cella con priorità massima
    (cell-priority (x ?x) (y ?y) (priority-score ?score))
    (not (cell-priority (x ?x2) (y ?y2) (priority-score ?score2&:(> ?score2 ?score))))
    ; Solo se score > 0 per evitare celle inutili
    (test (> ?score 0))
    (not (action-planned))
=>
    (printout t "STRATEGIA AVANZATA: Selezionata [" ?x "," ?y "] - Score: " 
              (format nil "%.2f" ?score) crlf)
    (assert (exec (step ?m) (action guess) (x ?x) (y ?y)))
    (assert (action-planned))
)

; Strategia di fallback per celle senza priorità calcolata
(defrule fallback-strategy
    (game-state (phase running))
    (free-cell (x ?x) (y ?y))
    (not (sure-guess (x ?x) (y ?y)))
    (not (water (x ?x) (y ?y)))
    (not (exec (action guess) (x ?x) (y ?y)))
    (not (cell-priority (x ?x) (y ?y)))
    (not (action-planned))
=>
    (printout t "FALLBACK STRATEGY: Cella [" ?x "," ?y "]" crlf)
    (assert (exec (step ?m) (action guess) (x ?x) (y ?y)))
    (assert (action-planned))
)

; ========== GESTIONE DINAMICA STRATEGIE ==========

; Forza uso strategie avanzate prima delle guess sicure
(defrule force-advanced-strategies
    (game-state (phase running) (moves ?m&:(< ?m 20))) ; Solo prime 20 mosse
    (free-cell (x ?x) (y ?y))
    (not (sure-guess (x ?x) (y ?y)))
    (not (water (x ?x) (y ?y)))
    (not (exec (action guess) (x ?x) (y ?y)))
    (not (action-planned))
=>
    (printout t "FORZATURA STRATEGIA: Esplorazione avanzata [" ?x "," ?y "]" crlf)
    (assert (exec (step ?m) (action guess) (x ?x) (y ?y)))
    (assert (action-planned))
)