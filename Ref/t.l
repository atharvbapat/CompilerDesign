%{
    #include "parser.tab.h"
    #include <stdlib.h>
    #include <string.h>
%}

%option noyywrap

%%

[ \t]+                  ;  
[0-9]+                  { yylval.ival = atoi(yytext); return INT_VALUE; }
"print"                 { return PRINT; }
[0-9]+\.[0-9]+          { yylval.fval = atof(yytext); return FLOAT_VALUE; }
'.'                     { yyval.cval= yytext; return CHAR_VALUE; }
\"[^\"]+\"              { yylval.sval = strdup(yytext); return STRING_VALUE; }
[a-zA-Z_][a-zA-Z0-9_]*  { yylval.ptr = strdup(yytext); return IDENTIFIER; }
"="                     { return ASSIGN; }
";"                     { return SEMICOLON; }
\n                      { return EOL; }
.                       { return yytext[0]; }

%%
