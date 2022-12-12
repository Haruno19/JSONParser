%%% Object %%%

jsonparse(JSONString, jsonobj()) :-
    is_JSONObj(JSONString, MembersString),
    normalize_space(atom(C), MembersString),
    C = '',
    !.
jsonparse(JSONString, jsonobj(Members)) :-
    is_JSONObj(JSONString, MembersString),
    members_in_JSONObj(MembersString, Members).
 
members_in_JSONObj(MembersStringTemp, Members) :- 
    atomic_list_concat(UnformattedMembers, ',', MembersStringTemp),
    formatMembers(UnformattedMembers, Members).

formatMembers([], []). 
formatMembers([X | Xs], [MemberString | Result]) :- 
    atomic_list_concat([A | [B | []]], ':', X),  %%nel caso in cui siano presenti piu` % nello stesso membro crasha.
    
    checkField(A, Field),
    checkValue(B, Value),
    MemberString =.. [',', Field, Value],

    %riconosciMembri(A, B, MemberString),
    %MemberString =.. [',', A, B],
    formatMembers(Xs, Result).

reverseList([], X, X).
reverseList([Testa | Coda], X, Result) :-
    reverseList(Coda, [Testa | X],Result).

checkWhiteSpaces([N | A], [N | A]) :-
    atom_number(N, _).
checkWhiteSpaces([' ' | A], L) :-
    checkWhiteSpaces(A, L).


checkField(A, Field) :-
    is_JSONString(A, B),
    atom_string(B, Field).
    %%Controllo sui caratteri presenti all'interno della stringa (tutti ascii)


checkValue(B, Value) :-
    is_JSONumber(B, Value),
    !.

checkValue(B, Value) :-
    jsonparse(B, Value),
    !.

checkValue(B, Value) :-
    checkField(B, Value), 
    !.


%%% Array %%%

%jsonparse(JSONString, Object) :-
%    is_JSONArray(JSONString, CharList).

%%% JSONString Classifcation %%%

is_JSONObj(JSONString, MembersStringTemp) :-
    string_chars(JSONString, ['{' | Tail]),
    check_LastChar('}' ,Tail, CharList),
    string_chars(MembersStringTemp, CharList).
    
is_JSONArray(JSONString, MembersStringTemp) :-
    string_chars(JSONString, ['[' | Tail]),
    check_LastChar(']' ,Tail, CharList),
    string_chars(MembersStringTemp, CharList).

is_JSONString(JSONString, MembersStringTemp) :- 
    string_chars(JSONString, ['\"' | Tail]),
    check_LastChar('\"' ,Tail, CharList),
    string_chars(MembersStringTemp, CharList).

is_JSONumber(B, Number) :-
    normalize_space(atom(ListNoWhite), B),
    string_chars(ListNoWhite, C),
    %checkWhiteSpaces(List, ListNew),
    %reverseList(ListNew, [], ReversedList),
    %checkWhiteSpaces(ReversedList, ListNoWhiteReversed),
    
    checkNumber(C),
    %reverseList(ListNoWhiteReversed, [], ValueNumberList),
    number_chars(Number, C),
    number(Number).

checkNumber([]).
checkNumber([A | B] ) :-
    char_code(A, C),
    char_code(' ', D),
    C \= D,
    checkNumber(B).

%%% LastChar - Check %%%

check_LastChar(C, [C|[]], []) :- !.
check_LastChar(C, [X | Xs], [X | CharsBack]) :-
    check_LastChar(C, Xs, CharsBack).