% Marcaccio Riccardo 886023
% Simioni Giorgio 887522
% Gini Stefano 879276

%%%% -*- Mode: Prolog -*-
%%%% jsonparser.pl

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
    funzioneObj(Members, Result),
    !.
parser(JSONTerm, jsonarray(Result)) :-
    JSONTerm =.. ['[|]' | [Element | [Elements]]],
    funzioneArray([Element | [Elements]], Result),
    !.

funzioneObj(Members, [Result1 | Result2]) :-
    Members =.. [',' | [A | [B]]],
    funzioneAsdrubale(A, Result1),
    funzioneObj(B, Result2),
    !.
funzioneObj(Members, [Result]) :- funzioneAsdrubale(Members, Result).

funzioneAsdrubale(Member, (Field, ValueDef)) :-
    Member =.. [':' | [Field | [Value]]],
    string(Field),
    isjsonvalue(Value, ValueDef).

funzioneArray([A | [[]]], [ADef]) :- isjsonvalue(A, ADef), !.
funzioneArray([A | [B]], [ADef | R]) :-
    isjsonvalue(A, ADef),
    B =.. ['[|]' | [C | [Z]]],
    funzioneArray([C | [Z]], R).

isjsonvalue(JSONTerm, JSONParsed) :- parser(JSONTerm, JSONParsed), !.
isjsonvalue(JSONTerm, JSONParsed) :-
    JSONTerm =.. [JSONParsed],
    is_jsonValue(JSONTerm).

is_jsonValue('true').
is_jsonValue('false').
is_jsonValue('null').
is_jsonValue(Val) :- string(Val).
is_jsonValue(Val) :- number(Val).


jsonread(Filename, JSONObj) :-
    open(Filename, read, File),
    read_string(File, _, JSONString),
    jsonparse(JSONString, JSONObj),
    close(File).

jsondump(Filename, JSONObj) :-
    jsonparse(JSONString, JSONObj),
    open(Filename, write, File),
    write(File, JSONString),
    close(File).

jsonaccess(jsonobj(M), [], jsonobj(M)) :- !.
jsonaccess(JSONObj, [Field | Fields], Result) :-
    analizza(JSONObj, Field, Value),
    jsonaccess(Value, Fields, Result), !.

jsonaccess(JSONObj, [Field | []], Result) :-
    analizza(JSONObj, Field, Result), !.

jsonaccess(JSONObj, A, Result) :- 
    not(is_list(A)),
    term_to_atom(ADef, A),
    jsonaccess(JSONObj, [ADef], Result), !.

analizza(JO, Field, R) :- string(Field), estraiObj(JO, Field, R).
analizza(JO, Field, R) :- number(Field), estraiArray(JO, Field, R).

estraiObj(jsonobj(JSONObj), Field, Result) :-
    JSONObj =.. ['[|]', Member, _],
    Member =.. [',', Field, Result],
    !.
    
estraiObj(jsonobj(JSONObj), Field, Result) :-
    JSONObj =.. ['[|]', _, Members],
    estraiObj(jsonobj(Members), Field, Result).

estraiArray(jsonarray([Element | _]), 0, Element) :- !.
estraiArray(jsonarray([_ | Elements]), Index, Result) :-
    IndexNew is Index - 1,
    Elements \= [],
    estraiArray(jsonarray(Elements), IndexNew, Result).

%%%% end of file -- jsonparser.pl