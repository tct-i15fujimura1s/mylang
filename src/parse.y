
%token INDENT UNINDENT '{' '}'

%%

block       : INDENT lines DEDENT
            | '{' lines '}'
            ;

assign      : lexpr '=' rexpr
            | lexpr ':' texpr '=' rexpr
            | lexpr ':' texpr
            ;
            
vardef      : tVAR assign
            ;
            
valdef      : tVAL assign
            ;
