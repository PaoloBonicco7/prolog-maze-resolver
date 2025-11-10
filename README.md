# prolog-maze-resolver
Implementation of A* and IDA* search algorithms in Prolog, tested and compared on two problem domains: a maze with multiple exits and the classic 8-puzzle (3×3 sliding puzzle). Project for the Artificial Intelligence and Laboratory course.


## Load a file

### Start the Prolog Engine

```bash
swipl
```

### Loading a file

```bash
[file_name].
```

### Loading Multiple Files

```bash
[file_name1, file_name2].
```

## Usefull commands

### Findall

Sintassi: findall(Cosa_Cercare, Condizione, Lista_Risultati)

Esempio:

```prolog
  ?- iniziale(S), findall(A, applicabile(A, S), Azioni).
  S = pos(5, 1),
  Azioni = [nord, sud, est].
```

