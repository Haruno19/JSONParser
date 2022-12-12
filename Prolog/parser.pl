% Parser formato JSON in Prolog con ricerca
% Marcaccio Riccardo 886023
% Gini Stefano 879276
% Simioni Giorgio 887522

%% {[ jsonparse con stringa JSON Unbound ]}
jsonparse(JSONAtom, JSONObj) :-
    var(JSONAtom),
    funzione(JSONAtom, JSONObj),
    !.

%% {[ jsonparse con stringa JSON definita ]}
jsonparse(JSONAtom, JSONObj) :-
    atom_string(JSONAtom, JSONString),
    term_string(JSONTerm, JSONString),
    funzione(JSONTerm, JSONObj).

%% [] Caso base lista vuota []
funzione([], []) :- !.

%% { STRINGA JSON OGGETTO }

%% { Caso base oggetto vuoto }
funzione(X, jsonobj()) :- 
    X =.. ['{}'],
    !.

%% { Oggetto con almeno un membro 'Field:Value'}
funzione(X, jsonobj(Result)) :-
    X =.. ['{}' | [Ls]],
    funzione(Ls, Result),
    !.

%% [ STRINGA JSON ARRAY ]

%% [ Caso base array vuoto ]
funzione(X, jsonarray()) :-
    X =.. ['[]'],
    !.

%% [ Array con un elemento ]
funzione(X, jsonarray([Ares])) :-
    X =.. ['[|]', A , []],
    funzioneControllo(A, Ares),
    !.

%% [ Array con elementi > 1 ]
funzione(X, jsonarray([Ares | Lres])) :-
    X =.. ['[|]' | [A | [Ls]]],
    funzioneControllo(A, Ares),
    %isjsonvalue(A),
    %Ls =.. [_ | [Y, [Z]]],
    %funzione([',' | [Y, Z]], Lres),
    funzioneArray(Ls, Lres),
    !.

%% ( Divisione membri oggetto JSON in base al simbolo ',' )
funzione(X, [Ares , Lres]) :- 
    X =.. [',' | [A | [Ls]]],
    funzione(A, Ares),
    funzione(Ls, Lres),
    Ls \= [],      
    !.

%% : Scomposizione di Field e Value in base al simbolo ':' :
funzione(X, (Ares, Bres)) :-
    X =.. [':' | [A | [B]]],

    %is_jsonfield(A),
    funzioneControllo(A, Ares),
    %isjsonvalue(B)
    funzioneControllo(B, Bres),
    !.

%%FUNZIONE CONTROLLO E` UNA FUNZIONE FINALE CHE ANALIZZA I SINGOLI ELEMENTI / FIELD / VALUE

%% Controllo sulla commplesita` dell'atomo
funzioneControllo(A, B) :-
    funzione(A, B),
    !.

%% " Gestione del simbolo "" per stringhe JSON "
funzioneControllo(A, B) :-
    nonvar(A),
    var(B),
    A =.. [B | []],
    %term_string(A, B),
    !. 

funzioneControllo(A, B) :-
    nonvar(B),
    var(A),
    B =.. [A | []],
    %term_string(B, A),
    !.

funzioneControllo(A, B) :-
    nonvar(B),
    nonvar(A),
    A =.. [B | []],
    %term_string(A, B),
    !.

%% [ Array con 2 elementi da analizzare rimasti ]
funzioneArray([A | [B]], [Ares, Bres]) :- 
    funzioneControllo(A, Ares),
    funzioneControllo(B, Bres),
    !.

%% [ Array con elementi da analizzare > 2 ] 
funzioneArray(X, [Ares | Lres]) :-
    X =.. ['[|]' | [A | [Ls]]],
    funzioneControllo(A, Ares),
    funzioneArray(Ls, Lres).

%funzione(A, Result1) :-
 %   funzione(A, Result1).

% ZAOSHANG HAO ZHONGGUO XIANZAI WO YOU BINGQILIN WO HEN XIUHAN BINGQILIN