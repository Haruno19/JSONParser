jsonparse(JSONString, jsonobj(Members)) :-
    is_JSONObj(JSONString, MembersString),
    members(MembersString, Members),
    !.

jsonparse(JSONString, jsonarray(Members)) :-
    is_JSONArray(JSONString, MembersString),
    elements(MembersString, Members),
    !.

jsonparse(JSONString, jsonobj()) :-
    is_JSONObj(JSONString, MembersString),
    normalize_space(atom(C), MembersString),
    C = '',
    !.

jsonparse(JSONString, jsonarray()) :-
    is_JSONArray(JSONString, MembersString),
    normalize_space(atom(C), MembersString),
    C = '',
    !.

elements(String, FormattedMembers) :-
    string_chars(String, CharList),
    spotElements(CharList, FormattedMembers).    

members(String, FormattedMembers) :-
    string_chars(String, CharList),
    spotMembers(CharList, FormattedMembers).

spotElements([],[]) :- !.
spotElements(CharList, [Value | Result]) :-
    searchCompositeElements(CharList, ValueTempChars, Tail),
    string_chars(ValueTemp, ValueTempChars),
    normalize_space(string(ValueTempNorm), ValueTemp),
    is_JSONValue(ValueTempNorm, Value),
    spotElements(Tail, Result).

spotMembers([], []) :- !.
spotMembers(CharList, [Member | Result]) :-
    splitPairs(':', CharList, AChar, B),
    string_chars(A, AChar),
    is_JSONField(A, Field),
    searchCompositeElements(B, ValueTempChars, Tail),
    string_chars(ValueTemp, ValueTempChars),
    normalize_space(string(ValueTempNorm), ValueTemp),
    is_JSONValue(ValueTempNorm, Value),
    Member =.. [',', Field, Value],
    spotMembers(Tail, Result).

is_JSONField(A, Field) :-
    is_JSONString(A, B),
    atom_string(B, Field).

is_JSONValue(B, Value) :-
    jsonparse(B, Value),
    !.

is_JSONValue(B, Value) :-
    is_JSONField(B, Value), 
    !.

is_JSONValue(B, Value) :-
    is_JSONumber(B, Value),
    !.


is_JSONObj(JSONString, MembersStringTemp) :-
    string_chars(JSONString, ['{' | Tail]),
    check_LastChar('}' ,Tail, CharList),
    string_chars(MembersStringTemp, CharList).
    
is_JSONArray(JSONString, MembersStringTemp) :-
    string_chars(JSONString, ['[' | Tail]),
    check_LastChar(']' ,Tail, CharList),
    string_chars(MembersStringTemp, CharList).

is_JSONString(JSONString, MembersStringTemp) :- 
    normalize_space(string(JSONStringNorm), JSONString),
    string_chars(JSONStringNorm, ['\"' | Tail]),
    check_LastChar('\"' ,Tail, CharList),
    string_chars(MembersStringTemp, CharList).

is_JSONumber(NumberString, Number) :-
    normalize_space(atom(AtomNOSpaces), NumberString),
    string_chars(AtomNOSpaces, CharList),
    checkNumber(CharList),
    number_chars(Number, CharList),
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

%analyzeValue(B, V, T) :-
   % searchCompositeElements(B, V, T),
    %!.

%analyzeValue(B, V, T) :-
    %splitti per virgola.


searchCompositeElements([], [], []).
searchCompositeElements(['{' | Xs],['{' | V], T) :-
    saveCompositeElements(Xs, V, Z),
    searchCompositeElements(Z, _, T),
    !.
searchCompositeElements(['[' | Xs], ['[' | V], T ) :-
    saveCompositeElements(Xs, V, Z),
    searchCompositeElements(Z, V, T),
    !.
searchCompositeElements([',' | Xs], [], Xs).

searchCompositeElements([A | As], [A | V], T) :-
    searchCompositeElements(As, V, T),
    !.

saveCompositeElements([']' | Xs], [']'], Xs).
saveCompositeElements(['}' | Xs], ['}'], Xs).
saveCompositeElements(['{' | Xs], ['{' | V], Xs) :-
    searchCompositeElements(['{' | Xs], V, T),
    saveCompositeElements(T, V, Xs),
    !.
saveCompositeElements(['[' | Xs], ['[' | V], Xs) :-
    searchCompositeElements(['[' | Xs], V, T),
    saveCompositeElements(T, V, Xs),
    !.
    
saveCompositeElements([A | As], [A | C], Xs) :-
    saveCompositeElements(As, C, Xs),
    !.



%%Caso doppio oggetto%%
%saveCompositeElements(['{'| Xs], V, T) :-
 %   searchCompositeElements(['{'| Xs], V, T),
  %  !.

%saveCompositeElements(['[' | Xs], V, T) :-
 %   searchCompositeElements(['['| Xs], V, T),
  %  !.



splitPairs(_, [], [], []).
splitPairs(Var, [Var | Xs], [], Xs) :- !.
splitPairs(Var, [X | Xs], [X | A], B) :-
    splitPairs(Var, Xs, A, B).
    

