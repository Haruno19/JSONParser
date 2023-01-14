README - JSONParse.pl

-- Predicates & Functioning --

JSONPARSE\2
this predicate has 2 rules, one for converting the JSON String (the first argument) to a Parsed
JSON Ojbect (the second argument), meanwhile the other rule converts from an already Parsed
JSON Object to a JSON String.
Both of theese rules utilize the "parser" predicate.

PARSER\2
this predicate has 2 rules, one for parsing JSONobjects, and the other one for parsing
JSONarrays, both of this rules utilize the UNIV operator and have base cases for when the 
respective JSON Structure is empty.

FORMATOBJ\2
this predicate receives as first argument a term containing the object's members, 
parses them one by one and uses them to build a prolog list to return.

FORMATMEMBER\2
this predicate receives as first argument a term containing only one member from the 
JSON object and upon checking the field's and value's correct syntax, returns 
both as a parsed compound term.

FORMATARRAY\2
this predicate receives as first argument a prolog list of the array's elements, 
checks the correct syntax of the first element and parses it, and recusively builds a 
list with that element as the head and as the tail, the recursive call on the rest of the elements

ISJASONVALUE\2
this predicate receives as first argument a term and checks if its JSON syntax is correct, 
and "returns" its parsed version as the second argument.

ATOMICVALUE\1
this predicate receives as argument an atomic value, and checks if it's a valid JSON value.

JSONREAD\2
this predicate receives as first argument a path to a text file which it reads the contents of and
tries to parse them through the JSONParse predicate, and unifies the parsed value as its second argument.
If it fails to open the file, it exits with an I/O error.

JSONDUMP\2
this predicate receives as second argument a parsed JSON object, using the JSONParse predicate, parses 
it back to a string in JSON sytanx, and outputs it to the file which path is specified as the first argument.
If the outfile doesn't exits, it's created at the specified path. 

JSONACCESS\3
this predicate receives as the first two arguments respectively: a parsed JSON object and a list of
terms or a singluar term.
It tries to unify the third argument (Result) with the JSON value which's field or index is
specified in the second argument.

ANALYZESTRING\3
this predicate checks wheter the Object it receives as first argument is a JSON Array or 
a JSON Object, and uses a different predicate for each one.

EXTRACTOBJ\3
this predicates unifies its third argument (Result) with the object's value which's 
field unifies with the field specified in the second argument.

EXTRACTARRAY\3
this predicate unifies its third argument (Result) with the array's element which is in
the position specified in the second argument (Index).


-- Usage --

?- jsonparse(JSONString, Object).
?- jsonaccess(JSONObj, Fields, Result).

I/O:

?- jsonread(FileName, JSON).
?- jsondump(JSON, FileName).
