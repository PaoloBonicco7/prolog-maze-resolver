(defmodule AGENT (export ?ALL))

; Templates principali
(deftemplate game-state
    (slot phase (allowed-values setup running completed) (default setup))
    (slot score (default 0))
    (slot moves (default 0))
    (slot max-moves (default 100))
    (slot resources (default 50))
)

(deftemplate project-cell
    (slot x)
    (slot y)
    (slot content (allowed-values empty resource obstacle target optimized deprecated))
)

(deftemplate row-val
    (slot row)
    (slot boats-present)
    (slot boats-found (default 0))
    (slot unknown-cells)
)

(deftemplate col-val
    (slot col)
    (slot boats-present)
    (slot boats-found (default 0))
    (slot unknown-cells)
)

(deftemplate agent-guess
    (slot x)
    (slot y)
    (slot type (allowed-values boat water unknown))
    (slot confidence (default 0.0))
)

(deftemplate processed-cell
    (slot x)
    (slot y)
)

(deftemplate free-cell
    (slot x)
    (slot y)
)
; Template per esecuzioni (AGGIORNATO)
(deftemplate exec
    (slot step)
    (slot action (allowed-values guess fire analyze complete))
    (slot x (default -1))
    (slot y (default -1))
    (slot result (allowed-values success failure pending) (default pending))
    (slot content (allowed-values boat water unknown) (default unknown))
)

; Fatti iniziali
(deffacts agent-initialization
    (game-state (phase setup) (score 0) (moves 0) (max-moves 100) (resources 50))
    
    ; Griglia 10x10 completa
    (free-cell (x 0) (y 0)) (free-cell (x 0) (y 1)) (free-cell (x 0) (y 2)) (free-cell (x 0) (y 3)) (free-cell (x 0) (y 4))
    (free-cell (x 0) (y 5)) (free-cell (x 0) (y 6)) (free-cell (x 0) (y 7)) (free-cell (x 0) (y 8)) (free-cell (x 0) (y 9))
    (free-cell (x 1) (y 0)) (free-cell (x 1) (y 1)) (free-cell (x 1) (y 2)) (free-cell (x 1) (y 3)) (free-cell (x 1) (y 4))
    (free-cell (x 1) (y 5)) (free-cell (x 1) (y 6)) (free-cell (x 1) (y 7)) (free-cell (x 1) (y 8)) (free-cell (x 1) (y 9))
    (free-cell (x 2) (y 0)) (free-cell (x 2) (y 1)) (free-cell (x 2) (y 2)) (free-cell (x 2) (y 3)) (free-cell (x 2) (y 4))
    (free-cell (x 2) (y 5)) (free-cell (x 2) (y 6)) (free-cell (x 2) (y 7)) (free-cell (x 2) (y 8)) (free-cell (x 2) (y 9))
    (free-cell (x 3) (y 0)) (free-cell (x 3) (y 1)) (free-cell (x 3) (y 2)) (free-cell (x 3) (y 3)) (free-cell (x 3) (y 4))
    (free-cell (x 3) (y 5)) (free-cell (x 3) (y 6)) (free-cell (x 3) (y 7)) (free-cell (x 3) (y 8)) (free-cell (x 3) (y 9))
    (free-cell (x 4) (y 0)) (free-cell (x 4) (y 1)) (free-cell (x 4) (y 2)) (free-cell (x 4) (y 3)) (free-cell (x 4) (y 4))
    (free-cell (x 4) (y 5)) (free-cell (x 4) (y 6)) (free-cell (x 4) (y 7)) (free-cell (x 4) (y 8)) (free-cell (x 4) (y 9))
    (free-cell (x 5) (y 0)) (free-cell (x 5) (y 1)) (free-cell (x 5) (y 2)) (free-cell (x 5) (y 3)) (free-cell (x 5) (y 4))
    (free-cell (x 5) (y 5)) (free-cell (x 5) (y 6)) (free-cell (x 5) (y 7)) (free-cell (x 5) (y 8)) (free-cell (x 5) (y 9))
    (free-cell (x 6) (y 0)) (free-cell (x 6) (y 1)) (free-cell (x 6) (y 2)) (free-cell (x 6) (y 3)) (free-cell (x 6) (y 4))
    (free-cell (x 6) (y 5)) (free-cell (x 6) (y 6)) (free-cell (x 6) (y 7)) (free-cell (x 6) (y 8)) (free-cell (x 6) (y 9))
    (free-cell (x 7) (y 0)) (free-cell (x 7) (y 1)) (free-cell (x 7) (y 2)) (free-cell (x 7) (y 3)) (free-cell (x 7) (y 4))
    (free-cell (x 7) (y 5)) (free-cell (x 7) (y 6)) (free-cell (x 7) (y 7)) (free-cell (x 7) (y 8)) (free-cell (x 7) (y 9))
    (free-cell (x 8) (y 0)) (free-cell (x 8) (y 1)) (free-cell (x 8) (y 2)) (free-cell (x 8) (y 3)) (free-cell (x 8) (y 4))
    (free-cell (x 8) (y 5)) (free-cell (x 8) (y 6)) (free-cell (x 8) (y 7)) (free-cell (x 8) (y 8)) (free-cell (x 8) (y 9))
    (free-cell (x 9) (y 0)) (free-cell (x 9) (y 1)) (free-cell (x 9) (y 2)) (free-cell (x 9) (y 3)) (free-cell (x 9) (y 4))
    (free-cell (x 9) (y 5)) (free-cell (x 9) (y 6)) (free-cell (x 9) (y 7)) (free-cell (x 9) (y 8)) (free-cell (x 9) (y 9))
    
    ; Valori per righe
    (row-val (row 0) (boats-present 2) (unknown-cells 10))
    (row-val (row 1) (boats-present 1) (unknown-cells 10))
    (row-val (row 2) (boats-present 3) (unknown-cells 10))
    (row-val (row 3) (boats-present 2) (unknown-cells 10))
    (row-val (row 4) (boats-present 1) (unknown-cells 10))
    (row-val (row 5) (boats-present 2) (unknown-cells 10))
    (row-val (row 6) (boats-present 3) (unknown-cells 10))
    (row-val (row 7) (boats-present 1) (unknown-cells 10))
    (row-val (row 8) (boats-present 2) (unknown-cells 10))
    (row-val (row 9) (boats-present 1) (unknown-cells 10))
    
    ; Valori per colonne
    (col-val (col 0) (boats-present 2) (unknown-cells 10))
    (col-val (col 1) (boats-present 1) (unknown-cells 10))
    (col-val (col 2) (boats-present 3) (unknown-cells 10))
    (col-val (col 3) (boats-present 2) (unknown-cells 10))
    (col-val (col 4) (boats-present 1) (unknown-cells 10))
    (col-val (col 5) (boats-present 2) (unknown-cells 10))
    (col-val (col 6) (boats-present 3) (unknown-cells 10))
    (col-val (col 7) (boats-present 1) (unknown-cells 10))
    (col-val (col 8) (boats-present 2) (unknown-cells 10))
    (col-val (col 9) (boats-present 1) (unknown-cells 10))
    
    (flag to-be-printed)
)

; Regola di inizializzazione
(defrule start-agent
    ?f <- (flag to-be-printed)
    ?s <- (game-state (phase setup))
=>
    (retract ?f)
    (modify ?s (phase running))
    (printout t "=== AGENT INIZIALIZZATO ===" crlf)
)