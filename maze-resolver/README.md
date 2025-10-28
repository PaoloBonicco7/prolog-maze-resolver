# Qua riportiamo alcuni frammenti di codice Prolog utili alla comprensione del progetto.


## Funzionamento Labirinto (maze.pl)

```prolog
  ?- finale(Lista), member(pos(5, 10), Lista).
  Lista = [pos(5, 10), pos(7, 1)].
```

In questo caso member è operatore build-in di prolog che ci aiuta a verificare se un elemento è memebro di una lista.

Un altro banale esempio è il seguente:

```prolog
  ?- iniziale(S), finale(LF), member(S, LF).
  false.
```

### Contare celle occupate

```prolog
   ?- findall(X, occupata(X), Lista), length(Lista, N).
```

### Verificare se una cella è libera

Per farlo serve verificare che non sia occupata:

```prolog
   ?- \+ occupata(pos(3,4)).
   true.
```

