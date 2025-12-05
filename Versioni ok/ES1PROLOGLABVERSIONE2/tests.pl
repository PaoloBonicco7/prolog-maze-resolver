
:- use_module(puzzles, [goal/1, h/2]).
:- consult('astar.pl').
:- consult('ida_star.pl').
:- consult('maze.pl').

% Stati iniziali per test
start1([1,2,3,4,0,6,7,5,8]). % Media difficoltà
start2([0,1,3,4,2,5,7,8,6]). % Difficile
start3([1,0,3,4,2,5,7,8,6]). % Intermedio
start4([8,6,7,2,5,4,3,0,1]).

% Test A* per 8-puzzle
test_astar_puzzle :-
    writeln('=== TEST A* 8-PUZZLE ==='),
    start4(S),
    statistics(runtime,[Start|_]),
    (astar(S,Path,Cost) -> 
        statistics(runtime,[End|_]),
        Time is End - Start,
        write('Stato iniziale: '), writeln(S),
        write('Costo: '), writeln(Cost),
        write('Lunghezza percorso: '), length(Path,Len), writeln(Len),
        write('Tempo esecuzione: '), write(Time), writeln(' ms')
    ;
        writeln('A* non ha trovato soluzione')
    ),
    writeln('=== FINE TEST ==='), nl.

% Test IDA* per 8-puzzle
test_ida_puzzle :-
    writeln('=== TEST IDA* 8-PUZZLE ==='),
    start4(S),
    statistics(runtime,[Start|_]),
    (ida_star(S,Path,Cost) ->
        statistics(runtime,[End|_]),
        Time is End - Start,
        write('Stato iniziale: '), writeln(S),
        write('Costo: '), writeln(Cost),
        write('Lunghezza percorso: '), length(Path,Len), writeln(Len),
        write('Tempo esecuzione: '), write(Time), writeln(' ms')
    ;
        writeln('IDA* non ha trovato soluzione')
    ),
    writeln('=== FINE TEST ==='), nl.

% Test A* per labirinto
test_astar_maze :-
    writeln('=== TEST A* LABIRINTO ==='),
    h_maze(pos(1,1),H),
    statistics(runtime,[Start|_]),
    (astar(pos(1,1),Path,Cost) ->
        statistics(runtime,[End|_]),
        Time is End - Start,
        write('Start: pos(1,1)'), nl,
        write('Goal: pos(4,4)'), nl,
        write('Euristica iniziale: '), writeln(H),
        write('Costo: '), writeln(Cost),
        write('Percorso: '), writeln(Path),
        write('Tempo esecuzione: '), write(Time), writeln(' ms')
    ;
        writeln('A* labirinto non ha trovato soluzione')
    ),
    writeln('=== FINE TEST ==='), nl.

% Test IDA* per labirinto
test_ida_maze :-
    writeln('=== TEST IDA* LABIRINTO ==='),
    h_maze(pos(1,1),H),
    statistics(runtime,[Start|_]),
    (ida_star(pos(1,1),Path,Cost) ->
        statistics(runtime,[End|_]),
        Time is End - Start,
        write('Start: pos(1,1)'), nl,
        write('Goal: pos(4,4)'), nl,
        write('Euristica iniziale: '), writeln(H),
        write('Costo: '), writeln(Cost),
        write('Percorso: '), writeln(Path),
        write('Tempo esecuzione: '), write(Time), writeln(' ms')
    ;
        writeln('IDA* labirinto non ha trovato soluzione')
    ),
    writeln('=== FINE TEST ==='), nl.


run_all_tests :-
    test_ida_puzzle,
    test_astar_puzzle,
    test_astar_maze,
    test_ida_maze.  
