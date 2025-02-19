%{
    #include "parser.tab.h"  // Include parser header for YYSTYPE
    #include <stdlib.h>
    #include <string.h>
%}

%option noyywrap

%%

[ \t]+                  ;  // Ignore spaces 
\n                      { return EOL; }  // Single newline rule
"print"                 { return PRINT; }
[0-9]+\.[0-9]+          { yylval.fval = atof(yytext); return FLOAT_VALUE; }  
[0-9]+                  { yylval.ival = atoi(yytext); return INT_VALUE; }
"'"[^\']"'"             { yylval.cval = yytext[1]; return CHAR_VALUE; }  // Proper character handling
\"[^\"]+\"              { yylval.sval = strdup(yytext + 1); yylval.sval[strlen(yylval.sval) - 1] = '\0'; return STRING_VALUE; }  
[a-zA-Z_][a-zA-Z0-9_]*  { yylval.sval = strdup(yytext); return IDENTIFIER; }
"="                     { return ASSIGN; }
";"                     { return SEMICOLON; }
.                       { printf("Unknown token: %s\n", yytext); return yytext[0]; }  // Catch unknown tokens

%% 
