
%token INDENT DEDENT '{' '}'

%%

block       : INDENT lines DEDENT
            | '{' lines '}'
            ;
