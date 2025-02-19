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
\'.\'                   { yylval.cval = yytext[1]; return CHAR_VALUE; }
\"[^\"]+\"              { yylval.sval = strdup(yytext + 1); yylval.sval[strlen(yylval.sval)-1] = '\0'; return STRING_VALUE; }
[a-zA-Z_][a-zA-Z0-9_]*  { yylval.ptr = strdup(yytext); return IDENTIFIER; }
"="                     { return ASSIGN; }
";"                     { return SEMICOLON; }
\n                      { return EOL; }
.                       { return yytext[0]; }

%%
