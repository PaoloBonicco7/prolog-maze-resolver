# Puzzle 8 – IDA* e A*

Breve descrizione del modello e delle strategie di ricerca usate per risolvere il puzzle dell’8 in Prolog. I dettagli implementativi sono nei file `.pl`.

## Rappresentazione del puzzle (`puzzle.pl`)

- Lo stato è una lista di 9 interi, con `0` che rappresenta la casella vuota, ad esempio:
  ```prolog
  [1,2,3,4,5,6,7,8,0]
  ```
- `iniziale/1` e `finale/1` definiscono rispettivamente la configurazione di partenza e quella obiettivo.
- I predicati `posizione_indice/3` e `indice_posizione/3` convertono tra:
  - indice nella lista (1–9)
  - coppia (riga, colonna) su griglia 3×3.

Assunzioni:
- tutte le mosse hanno costo 1;
- non viene fatto un controllo di “solvibilità” del puzzle (numero di inversioni).

## Azioni di movimento (`actions.pl`)

- `trova_vuoto/2` trova la posizione della casella vuota (`0`).
- `applicabile/2` verifica se è possibile muovere il vuoto `su/giu/sx/dx` senza uscire dalla griglia.
- `trasforma/3` applica un’azione e restituisce il nuovo stato scambiando il vuoto con la tessera adiacente.
- `scambia/4` e `sostituisci/4` incapsulano le operazioni di aggiornamento della lista.

L’idea è sempre “muovere il vuoto” all’interno della griglia; le tessere si spostano di conseguenza.

## Euristica Manhattan (`search.pl`)

- `manhattan_puzzle/3` calcola la somma, per ogni tessera (escluso il vuoto), della distanza Manhattan tra:
  - posizione corrente nella lista
  - posizione target nella lista finale.
- L’euristica è **ammissibile**:
  - ogni mossa sposta al massimo di 1 passo una tessera;
  - quindi la somma delle distanze non sovrastima mai il numero minimo di mosse.

Questa stessa euristica è usata sia da IDA* sia da A*.

## IDA* per il puzzle

- Predicati principali:
  - `ida_star_puzzle/1`: entry point;
  - `ida_star_puzzle_loop/1`: gestisce le iterazioni con soglia crescente;
  - `ida_limitata_puzzle/4`: DFS limitata dalla soglia su `f(n)`.
- `f(n) = g(n) + h(n)`:
  - `g(n)` = lunghezza del cammino (numero di stati visitati);
  - `h(n)` = Manhattan sullo stato corrente.
- `current_depth/1` memorizza la soglia corrente;  
  `next_depth/1` tiene il **minimo** `f(n)` che ha superato la soglia, per l’iterazione successiva.

Prestazioni (qualitative):
- memoria lineare nella profondità (solo il cammino corrente);
- tempo potenzialmente alto: gli stessi stati possono essere ri-espansi in iterazioni successive;
- utile quando la memoria è limitata e si vuole comunque un cammino ottimo con euristica ammissibile.

## A* per il puzzle

- Predicati principali:
  - `a_star_puzzle/1`: entry point;
  - `a_star_puzzle_loop/3`: gestisce OPEN e CLOSED.
- Nodo: `nodo(Stato, Cammino, Gn, Hn, Fn)` con:
  - `Stato` = configurazione;
  - `Cammino` = azioni (in ordine inverso);
  - `Gn` = costo reale (numero di mosse);
  - `Hn` = Manhattan;
  - `Fn` = `Gn + Hn`.
- OPEN è una lista ordinata per `Fn`; CLOSED contiene gli stati già espansi.
- I successori vengono filtrati per:
  - scartare stati già in CLOSED;
  - sostituire in OPEN eventuali percorsi peggiori verso lo stesso stato.

Prestazioni (qualitative):
- in genere più veloce di IDA* in termini di nodi espansi;
- garantisce anch’esso cammini ottimi (grazie all’euristica ammissibile);
- richiede più memoria (mantiene entire OPEN e CLOSED).

## Uso rapido

- Caricamento:
  ```prolog
  ?- [puzzle, actions, search].
  ```
- IDA*:
  ```prolog
  ?- ida_star_puzzle(Cammino).
  ```
- A*:
  ```prolog
  ?- a_star_puzzle(Cammino).
  ```
