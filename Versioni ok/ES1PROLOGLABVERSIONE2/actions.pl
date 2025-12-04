% Utility functions per 8-puzzle (se non sono già in puzzles)
swap_positions(List, I, J, Res) :-
    nth0(I, List, ElemI),
    nth0(J, List, ElemJ),
    set_nth0(I, List, ElemJ, Tmp),
    set_nth0(J, Tmp, ElemI, Res).

set_nth0(Index, List, Value, Result) :-
    length(List, Len),
    length(Result, Len),
    set_nth0_helper(0, Index, List, Value, Result).

set_nth0_helper(Index, Index, [_|Tail], Value, [Value|Tail]).
set_nth0_helper(Current, Index, [Head|Tail], Value, [Head|Result]) :-
    Current \= Index,
    Next is Current + 1,
    set_nth0_helper(Next, Index, Tail, Value, Result).