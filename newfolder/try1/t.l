%{
    #include "p.tab.h"
    #include <stdlib.h>
    #include <string.h>
%}

%option noyywrap

%%

[ \t]+                  ;  
[0-9]+                  { int *n = malloc(sizeof(int)); *n = atoi(yytext); yylval.ptr = n; return INT_VALUE; }
"print"                 { return PRINT; }
[0-9]+\.[0-9]+          { float *f = malloc(sizeof(float)); *f = atof(yytext); yylval.ptr = f; return FLOAT_VALUE; }
'.'                     { char *c = malloc(sizeof(char)); *c = yytext[1]; yylval.ptr = c; return CHAR_VALUE; }
\"[^\"]+\"              { yylval.ptr = strdup(yytext + 1); ((char*)yylval.ptr)[strlen(yytext)-2] = '\0'; return STRING_VALUE; }
[a-zA-Z_][a-zA-Z0-9_]*  { yylval.ptr = strdup(yytext); return IDENTIFIER; }
"="                     { return ASSIGN; }
";"                     { return SEMICOLON; }
\n                      { return EOL; }
.                       { return yytext[0]; }

%%
