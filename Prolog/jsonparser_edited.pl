%%% Object %%%

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
    atom_number(B, Number),
    integer(Number).



%%% LastChar - Check %%%

check_LastChar(C, [C|[]], []) :- !.
check_LastChar(C, [X | Xs], [X | CharsBack]) :-
    check_LastChar(C, Xs, CharsBack).
