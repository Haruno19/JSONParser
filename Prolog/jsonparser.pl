%%% Object %%%

jsonparse(JSONString, jsonobj(Members)) :-
    is_JSONObj(JSONString, MembersString),
    members_in_JSONObj(MembersString, Members).
 
members_in_JSONObj(MembersStringTemp, Members) :- 
    atomic_list_concat(UnformattedMembers, ',', MembersStringTemp),
    formatMembers(UnformattedMembers, Members).


formatMembers([], []). 
formatMembers([X | Xs], [MemberString | Result]) :- % X , Xs, scomponi lista nomi da cambiare
    atomic_list_concat([A | [B | []]], ':', X),
    is_JSONString(A, Z),    %%Controllo del porcodio (ispair)
    is_JSONString(B, Y),
    atom_string(Z, XA),
    atom_string(Y, YA),
    MemberString =.. [',', XA, YA],

    %riconosciMembri(A, B, MemberString),
    %MemberString =.. [',', A, B],
    formatMembers(Xs, Result).

%riconosciMembri(A, B, Risultato) :-
%   jsonparse(B, StringaValue). %%% jsonparse analizza sia Array che Obj
    %% Analizza A,
    %% Concatena StrignaValue e StringaField

%riconosciMembri(A, B, Risultato) :-
    %% Analizza A e B come Stirghe
 %   is_JSONString(B, _),
  %  is_JSONString(A, _),
   % atomic_list_concat([A | [B | []]], ', ', Risultato).
    %% Concatena StrignaValue e StringaField


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

is_JSONString(JSONString, MembersStringTemp) :- %%Controlla Se serve il ritorno della stringa senza apici
    string_chars(JSONString, ['\"' | Tail]),
    check_LastChar('\"' ,Tail, CharList),
    string_chars(MembersStringTemp, CharList).


%%% LastChar - Check %%%

check_LastChar(C, [C|[]], []) :- !.
check_LastChar(C, [X | Xs], [X | CharsBack]) :-
    check_LastChar(C, Xs, CharsBack).