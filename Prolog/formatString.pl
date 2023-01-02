formStr([], [], _).
formStr(['{' | ['}' | A]], ['{' | ['}' | R]], Ntab) :- 
    formStr(A, R, Ntab), 
    !.
formStr(['[' | [']' | A]], ['[' | [']' | R]], Ntab) :- 
    formStr(A, R, Ntab), 
    !.
formStr(['{' | A], ['{' | ['\n' | Rdef]], Ntab) :- 
    NtabNew is Ntab+1, 
    formStr(A, R, NtabNew), 
    formTab(R, NtabNew, Rdef),
    !.
formStr(['[' | A], ['[' | ['\n' | Rdef]], Ntab) :- 
    NtabNew is Ntab+1, 
    formStr(A, R, NtabNew), 
    formTab(R, NtabNew, Rdef),
    !.
formStr([',' | A], [',' | ['\n' | Rdef]], Ntab) :- 
    formStr(A, R, Ntab), 
    formTab(R, Ntab, Rdef),
    !.
formStr(['}' | A], ['\n' | Rdef], Ntab) :- 
    NtabNew is Ntab-1, 
    formStr(A, R, NtabNew), 
    formTab(['}' | R], NtabNew, Rdef),
    !.
formStr([']' | A], ['\n' | Rdef], Ntab) :- 
    NtabNew is Ntab-1, 
    formStr(A, R, NtabNew), 
    formTab([']' | R], NtabNew, Rdef),
    !.
formStr([A | B], [A | R], Ntab) :- formStr(B, R, Ntab), !.


formTab(R, 0, R).
formTab(R, Ntab, ['\t' | Result]) :-
    NtabNew is Ntab - 1,
    formTab(R, NtabNew, Result).