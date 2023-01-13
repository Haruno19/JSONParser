README - JSONParse.lisp

JSONPARSE\1
this fuction's argument is a lisp string, it returns the parsed string
calling the StringAnalyzer function with the trimmed string as argument. 

STRINGANALYZER\1
this function checks if the argument is a JSON object or JSON array, 
and calls the respective parser function.
if the string is neither a JSON object nor a JSON array, it exits 
with a Syntax Error.

OBJANALYZER\1
this function returns a cons containing as first value a cons containing
the first parsed JSON member, and as second value the result of the
recursive call with the rest of the members. 

ARRAYANALIZER\1
this fuction returns a list containing as head the first parsed element,
and as tail  the result of the recursive call with the rest of the elements

ISVALUE\1
this function returns the parsed JSON value upon checking if its syntax is correct
(if not, it exits with a Syntax Error).

ISNUMBER\1
this fuction returns the parsed JSON number (intager or float)
upon checking if its syntax is correct.

ISFIELD\1
this fuction returns the parsed JSON field upon checking if its syntax is correct
(if not, it exits with a Syntax Error).

STRINGSPLITTER\3
this fuction returns a cons containing as the first value, an unparsed string
containing the JSON field of the first member, and as second value the return
of the fuction TailSplitter with the rest of the string as argument.

TAILSPLITTER\1
this function returns a cons containing as the first value, an unparsed string
containing the JSON value of the first member, and as second argument the rest
of the string.

VALUESPLITTER\4
this funtion's first argument is a string; this function returns the index of
the first character after the JSON value of the first member. 

JSONREAD\1
this function parses the json string contained in the file at the specified
path using the JSONParse function, and returns it.

JSONACCESS\2+
this function returns the return of the getFields function with the given first
argument (Obj) and a finite list of its remaining arguments as arguments.

GETFIELDS\2
this function returns the value in the given parsed JSON object which position
is specified by a series of arguments (Fields).

FIELDFINDER\2
this function returns the JSON value which field is specified in the
last field contained in the second argument (Fields).

INDEXFINDER\2
this function returns the JSON value which position is specified in the
last index contained in the second argument (Fields).

JSONDUMP\2
this function parses back to a JSON string its first argument with the
ReverseParse function, writes the string to the output file which path
is specified as second argument, and returns the path to the file.

PARSEREVERSE\1
