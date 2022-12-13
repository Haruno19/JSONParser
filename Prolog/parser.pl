% Parser formato JSON in Prolog con ricerca
% Marcaccio Riccardo 886023
% Simioni Giorgio 887522
% Gini Stefano 879276

%% {[ jsonparse con stringa JSON Unbound ]}
jsonparse(JSONAtom, JSONObj) :-
    var(JSONAtom),
    parser(JSONAtomTerm, JSONObj),
    term_to_atom(JSONAtomTerm, JSONAtom),
    !.

%% {[ jsonparse con stringa JSON definita ]}
jsonparse(JSONAtom, JSONObj) :-
    atom_string(JSONAtom, JSONString),
    term_string(JSONTerm, JSONString),
    parser(JSONTerm, JSONObj).

%% [] Caso base lista vuota []
parser([], []) :- !.

%% { STRINGA JSON OGGETTO }

%% { Caso base oggetto vuoto }
parser(JSONTerm, jsonobj()) :- 
    JSONTerm =.. ['{}'],
    !.
    
%% { Oggetto con un solo membro 'Field:Value' }
parser(JSONTerm, jsonobj([MemberParsed])) :-
    JSONTerm =.. ['{}' | [Member | []]],
    parser(Member, MemberParsed),
    !.

%% { Oggetto con almeno due membri 'Field:Value'}
parser(JSONTerm, jsonobj(MembersParsed)) :-
    JSONTerm =.. ['{}' | [Members]],
    parser(Members, MembersParsed),
    !.

%% [ STRINGA JSON ARRAY ]

%% [ Caso base array vuoto ]
parser(JSONTerm, jsonarray()) :-
    JSONTerm =.. ['[]'],
    !.

%% [ Array con un elemento ]
parser(JSONTerm, jsonarray([ElementParsed])) :-
    JSONTerm =.. ['[|]', Element , []],
    parserControllo(Element, ElementParsed),
    !.

%% [ Array con elementi > 1 ]
parser(JSONTerm, jsonarray([ElementParsed | ElementsParsed])) :-
    JSONTerm =.. ['[|]' | [Element | [Elements]]],
    parserControllo(Element, ElementParsed),
    %isjsonvalue(A),    
    parserArray(Elements, ElementsParsed),
    !.

%% ( Divisione membri oggetto JSON in base al simbolo ',' )
parser(JSONTerm, [MemberParsed , MembersParsed]) :- 
    JSONTerm =.. [',' | [Member | [Members]]],
    parser(Member, MemberParsed),
    parser(Members, MembersParsed),
    Members \= [],
    !.

%% : Scomposizione di Field e Value in base al simbolo ':' :
parser(JSONTerm, (FieldParsed, ValueParsed)) :-
    JSONTerm =.. [':' | [Field | [Value]]],
    parserControllo(Field, FieldParsed),    
    string(Field),
    parserControllo(Value, ValueParsed),
    !.

%%parserControllo E` UNA parser CHE ANALIZZA I SINGOLI ELEMENTI / FIELD / VALUE

%% Controllo sulla commplesita` dell'atomo
parserControllo(JSONTerm, JSONParsed) :-
    parser(JSONTerm, JSONParsed),
    !.

%%Gestione del simbolo  per stringhe JSON 
parserControllo(JSONTerm, JSONParsed) :-
    nonvar(JSONTerm),
    JSONTerm =.. [JSONParsed | []],
    is_jsonValue(JSONTerm),
    !. 

parserControllo(JSONTerm, JSONParsed) :-
    nonvar(JSONParsed),
    var(JSONTerm),
    JSONParsed =.. [JSONTerm | []],
    is_jsonValue(JSONTerm),
    !.

%% [ Array con 2 elementi da analizzare rimasti ]
parserArray([Element1 | [Element2]], [Element1Parsed, Element2Parsed]) :- 
    parserControllo(Element1, Element1Parsed),
    parserControllo(Element2, Element2Parsed),
    !.

%% [ Array con elementi da analizzare > 2 ] 
parserArray(JSONTerm, [ElementParsed| ElementsParsed]) :-
    JSONTerm =.. ['[|]' | [Element | [Elements]]],
    parserControllo(Element, ElementParsed),
    parserArray(Elements, ElementsParsed).

is_jsonValue(Value) :-
    string(Value),
    !.
is_jsonValue(Value) :-
    number(Value),
    !. 
is_jsonValue('null').
is_jsonValue('false').
is_jsonValue('true').
    
jsonaccess(JSONObj, [], JSONObj) :- !.
jsonaccess(JSONObj, [Field | Fields], Result) :-
    string(Field),
    analizzaObj(JSONObj, Field, Value),
    jsonaccess(Value, Fields, Result),
    !.

jsonaccess(JSONArray, [Index | Fields], Result) :-
    number(Index),
    analizzaArray(JSONArray, Index, Value),
    jsonaccess(Value, Fields, Result).

analizzaObj(jsonobj(JSONObj), Field, Result) :-
    JSONObj =.. ['[|]', Member, _],
    Member =.. [',', Field, Result],
    !.

analizzaObj(jsonobj(JSONObj), Field, Result) :-
    JSONObj =.. ['[|]', _, Members],
    analizzaObj(jsonobj(Members), Field, Result).

analizzaArray(jsonarray([Element | _]), 0, Element) :- !.
analizzaArray(jsonarray([_ | Elements]), Index, Result) :- 
    IndexNew is Index - 1,
    analizzaArray(jsonarray(Elements), IndexNew, Result).

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