% Marcaccio Riccardo 886023
% Simioni Giorgio 887522
% Gini Stefano 879276

%%%% -*- Mode: Prolog -*-
%%%% jsonparser.pl
:- consult('formatString.pl').

jsonparse(JSONAtom, JSONObj) :-
    var(JSONAtom),
    parser(JSONAtomTerm, JSONObj),
    term_to_atom(JSONAtomTerm, JSONAtom),
    !.

jsonparse(JSONAtom, JSONObj) :-
    atom_string(JSONAtom, JSONString),
    catch(term_string(JSONT, JSONString), error(syntax_error(_), _), false),
    parser(JSONT, JSONObj).

parser('{}', jsonobj([])).
parser([], jsonarray([])).
parser(JSONTerm, jsonobj(Result)) :-
    JSONTerm =.. ['{}' | [Members]],
    formatObj(Members, Result),
    !.
parser(JSONTerm, jsonarray(Result)) :-
    JSONTerm =.. ['[|]' | [Element | [Elements]]],
    formatArray([Element | [Elements]], Result),
    !.

formatObj(Members, [Result1 | Result2]) :-
    Members =.. [',' | [A | [B]]],
    formatMember(A, Result1),
    formatObj(B, Result2),
    !.
formatObj(Members, [Result]) :- formatMember(Members, Result).

formatMember(Member, (Field, ValueDef)) :-
    Member =.. [':' | [Field | [Value]]],
    string(Field),
    isjsonvalue(Value, ValueDef).

formatArray([A | [[]]], [ADef]) :- isjsonvalue(A, ADef), !.
formatArray([A | [B]], [ADef | R]) :-
    isjsonvalue(A, ADef),
    B =.. ['[|]' | [C | [Z]]],
    formatArray([C | [Z]], R).

isjsonvalue(JSONTerm, JSONParsed) :- parser(JSONTerm, JSONParsed), !.
isjsonvalue(JSONTerm, JSONParsed) :-
    JSONTerm =.. [JSONParsed],
    atomicValue(JSONTerm).

atomicValue('true').
atomicValue('false').
atomicValue('null').
atomicValue(Val) :- string(Val).
atomicValue(Val) :- number(Val).


jsonread(Filename, JSONObj) :-
    open(Filename, read, File),
    read_string(File, _, JSONString),
    jsonparse(JSONString, JSONObj),
    close(File).

jsondump(Filename, JSONObj) :-
    jsonparse(JSONString, JSONObj),
    string_chars(JSONString, C),
    formStr(C, Cdef, 0),
    string_chars(JSONStringDef, Cdef),
    open(Filename, write, File),
    write(File, JSONStringDef),
    close(File).

jsonaccess(jsonobj(M), [], jsonobj(M)) :- !.
jsonaccess(JSONObj, [Field | Fields], Result) :-
    analyzeString(JSONObj, Field, Value),
    jsonaccess(Value, Fields, Result), !.

jsonaccess(JSONObj, [Field | []], Result) :-
    analyzeString(JSONObj, Field, Result), !.

jsonaccess(JSONObj, A, Result) :- 
    not(is_list(A)),
    term_to_atom(ADef, A),
    jsonaccess(JSONObj, [ADef], Result), !.

analyzeString(JO, Field, R) :- string(Field), extractObj(JO, Field, R).
analyzeString(JO, Field, R) :- number(Field), extractArray(JO, Field, R).

extractObj(jsonobj(JSONObj), Field, Result) :-
    JSONObj =.. ['[|]', Member, _],
    Member =.. [',', Field, Result],
    !.
    
extractObj(jsonobj(JSONObj), Field, Result) :-
    JSONObj =.. ['[|]', _, Members],
    extractObj(jsonobj(Members), Field, Result).

extractArray(jsonarray([Element | _]), 0, Element) :- !.
extractArray(jsonarray([_ | Elements]), Index, Result) :-
    IndexNew is Index - 1,
    Elements \= [],
    extractArray(jsonarray(Elements), IndexNew, Result).

%%%% end of file -- jsonparser.pl
