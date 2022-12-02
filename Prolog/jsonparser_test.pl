% Marcaccio Riccardo 886023
% Gini Stefano 879276
% Simioni Giorgio 887522

%% jsonparse 2

%% Object Parse

jsonparse(JSONString, jsonobj(Members)) :-
    is_JSONObj(JSONString, MembersString),
    members(MembersString, Members),
    !.

jsonparse(JSONString, jsonobj()) :-
    is_JSONObj(JSONString, MembersString),
    normalize_space(atom(C), MembersString),
    C = '',
    !.

%% Array Parse

jsonparse(JSONString, jsonarray(Elements)) :-
    is_JSONArray(JSONString, ElementsString),
    elements(ElementsString, Elements),
    !.

jsonparse(JSONString, jsonarray()) :-
    is_JSONArray(JSONString, ElementsString),
    normalize_space(atom(C), ElementsString),
    C = '',
    !.

%% Array elements formatting

elements(ElementsString, FormattedElements) :-
    string_chars(ElementsString, ElementsCharList),
    spotElements(ElementsCharList, FormattedElements).

spotElements([], []) :- !.
spotElements(ElementsCharList, [Element | FormattedElements]) :-
    valueIsolator(ElementsCharList, ElementTempChars, Tail),
    string_chars(ElementTemp, ElementTempChars),
    is_JSONValue(ElementTemp, Element),
    spotElements(Tail, FormattedElements).

%% Object members formatting

members(MembersString, FormattedMembers) :-
    string_chars(MembersString, MembersCharList),
    spotMembers(MembersCharList, FormattedMembers).

spotMembers([], []) :- !.
spotMembers(MembersCharList, [Member | FormattedMembers]) :-
    splitPairs(':', MembersCharList, FieldChars, JSONChars),
    string_chars(FieldTempString, FieldChars),
    is_JSONField(FieldTempString, Field),
    valueIsolator(JSONChars, ValueTempChars, Tail),
    string_chars(ValueTempString, ValueTempChars),
    is_JSONValue(ValueTempString, Value),
    Member =.. [',', Field, Value],
    spotMembers(Tail, FormattedMembers).   

%% Recognize Value type

valueIsolator(JSONChars, ValueTempChars, Tail) :-
    recognize(JSONChars, ValueTempChars, Tail),
    !.

valueIsolator(JSONChars, ValueTempChars, Tail) :-
    splitPairs(',', JSONChars, ValueTempChars, Tail),
    !.

%% PDA for complex JSON terms (Array/Object)

recognize(JSONChars, ValueTempChars, Tail) :- 
    initial(Q), 
    accept(JSONChars, Q, [], ValueTempChars, Tail).
initial(q0).
final(q1).
accept([], Q, [], [], []) :- final(Q), !.
accept([',' | Cs], Q, [], [], Cs) :- final(Q), !.
accept([C | Cs], Q, S, [C | Result], Tail) :-
      delta(Q, C, S, Q1, S1),
      accept(Cs, Q1, S1, Result, Tail).

delta(q0, ' ', S, q0, S).
delta(q0, '{', S, q1, ['{' | S]).
delta(q0, '[', S, q1, ['[' | S]).
delta(q0, '(', S, q1, ['(' | S]).
delta(q0, _, S, q2, S) :- false.

delta(q1, '{', S, q1, ['{' | S]).
delta(q1, '}', ['{' | S], q1, S).
delta(q1, '[', S, q1, ['[' | S]).
delta(q1, ']', ['[' | S], q1, S).
delta(q1, '(', S, q1, ['(' | S]).
delta(q1, ')', ['(' | S], q1, S).
delta(q1, _, S, q1, S).

%%is_JSONType Section

is_JSONObj(JSONString, MembersStringTemp) :-
    normalize_space(string(JSONStringNorm), JSONString),
    string_chars(JSONStringNorm, ['{' | Tail]),
    check_LastChar('}', Tail, MembersCharList),
    string_chars(MembersStringTemp, MembersCharList).
    
is_JSONArray(JSONString, ElementsStringTemp) :-
    normalize_space(string(JSONStringNorm), JSONString),
    string_chars(JSONStringNorm, ['[' | Tail]),
    check_LastChar(']', Tail, ElementsCharList),
    string_chars(ElementsStringTemp, ElementsCharList).

is_JSONField(FieldTempString, Field) :-
    is_JSONString(FieldTempString, FieldString),
    atom_string(FieldString, Field).

is_JSONValue(ValueTempString, Value) :-
    jsonparse(ValueTempString, Value),
    !.

is_JSONValue(ValueTempString, Value) :-
    is_JSONField(ValueTempString, Value), 
    !.

is_JSONValue(ValueTempString, Value) :-
    is_JSONumber(ValueTempString, Value),
    !.

is_JSONString(JSONString, String) :- 
    normalize_space(string(JSONStringNorm), JSONString),
    string_chars(JSONStringNorm, ['\"' | Tail]),
    check_LastChar('\"', Tail, StringCharList),
    string_chars(String, StringCharList).

is_JSONumber(NumberString, Number) :-
    normalize_space(atom(AtomNorm), NumberString),
    string_chars(AtomNorm, NumberCharList),
    checkNumberSyntax(NumberCharList),
    number_chars(Number, NumberCharList),
    number(Number).

%% Utility rules
 
checkNumberSyntax([]).
checkNumberSyntax([C | Cs] ) :-
    char_code(C, CCode),
    char_code(' ', D),
    CCode \= D,
    checkNumberSyntax(Cs).

splitPairs(_, [], [], []).
splitPairs(Char, [Char | Xs], [], Xs) :- !.
splitPairs(Char, [X | Xs], [X | A], B) :-
    splitPairs(Char, Xs, A, B).

check_LastChar(Char, [Char|[]], []) :- !.
check_LastChar(Char, [X | Xs], [X | CharsBack]) :-
    check_LastChar(Char, Xs, CharsBack).

%% IO Read

jsonread(Filename, JSON) :-
    open(Filename, read, File),
    read_string(File, _, JSONString),
    jsonParse(JSONString, JSON).

%% Man At Work 

%% Qua la stringa che ricevi è sicuramente una jsonobj(qualcosa) o jsonarray(qualcosa) 
jsonaccess(JSONObject, FieldList, Result) :-
    string_chars(JSONObject, JSONObjectChars),
    check_LastChar(')', JSONObjectChars, JSONObjectCharsNew), %%tolgo la ')' finale che altrimenti sarebbe ridondante farlo in due volte mmmmmmmhhhhhhh?????????????????????????????
    verificaOBJ(JSONObjectCharsNew, FieldList, Result). 

%%caso base in cui la lista è vuota
verificaOBJ(Object, [], Object).
%% mi serve qualcuno che faccia il debug
%% io su linux non vedo il codice mentre debuggo e non capisco un cazzo 
%% entro su disc mutato
%% va bene campione
%%caso in cui la stringa sia un obj (il sub_string funziona ho già controllato)
verificaOBJ(JSONObjectChars, [Field | OtherFields], Result) :-
    string_chars(JSONObjectString, JSONObjectChars),
    sub_string(JSONObjectString, 0, _, _, 'jsonobj'), %%da vedere 👀 <- emojicon
    %is_JSONString(Field, _),X
    splitPairs('[', JSONObjectChars, _, MembersCharListTemp),
    check_LastChar(']', MembersCharListTemp, MembersCharList),
    membersToList(MembersCharList, Result),
    %atom_chars(MembersString, MembersCharList), 
    %is_JSONString(MembersString, Result),
    %MembersString =.. [_, Member, OtherMembers], %% scompone il risultato tipo cosi - viene -> (bar, sasso) =.. [',', bar, sasso]
    %extractObjectValue([Member | OtherMembers], [Field | OtherFields], Result),
    !.

membersToList([], []) :- !.
membersToList(CharList, [Member | Result]) :-
    recognize(CharList, MemberChars, OtherMembers),
    string_chars(MemberTemp, MemberChars),
    normalize_space(string(Member), MemberTemp),
    membersToList(OtherMembers, Result).

%verificaOBJ(JSONObjectChars, FieldList, Result) :-
%%    sub_string(JSONObjectChars, 0, _, _, 'jsonarray'), 
%    splitPairs('(', JSONObjectChars, _, MembersCharList),
%    extractArrayValue(),
%    !. %zhenshao hoo zhongguo xian hao woio bingquilin
%    salmone 
%    tonno
%    germogli di soia
%    tantanmen ramen 
%    corda
%    sgabello

extractObjectValue([], _, _) :- false, !. %%brother in christ il cut non serve se c'e il false prima
extractObjectValue([Member | _], [Field | OtherFields], Result) :-
    string_chars(Member, ['(' | MemberTempChars]), 
    check_LastChar(')', MemberTempChars, MemberChars),
    splitPairs(',', MemberChars, FieldCurrentChars, ValueCurrentChars),
    string_chars(FieldCurrent, FieldCurrentChars),
    normalize_space(string(NormField), Field),
    normalize_space(string(NormField), FieldCurrent),
    string_chars(ValueCurrent, ValueCurrentChars),
    verificaOBJ(ValueCurrent, OtherFields, Result), 
    !.

extractObjectValue([_ | OtherMembers], [_ | OtherFields], Result) :-
    extractObjectValue(OtherMembers, OtherFields, Result).
    


%% ricorsivamente controllo gli elementi di FieldList
%% quando trovo una stringa "a" allora cerco un jsonobj 
%% trovato il jsonobj cerco il field, trovato il field 
%% leggo il secondo elemento di FieldList e vado avanti
%% invece quando trovo un numero 2 in FieldList
%% cerco un jsonarray e vado a quella posizione
%% e ricorsivamente controllo FieldList
%% quando fieldList è vuota ritorno il value che sto guardando in qel momento 
%% fatto


