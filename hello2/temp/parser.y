%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include "symbol_table.h"

    extern int yylex();
    void yyerror(const char *s);
%}

%union {
    int ival;
    float fval;
    char cval;
    char *sval;
    void *ptr;  
}

%token PRINT ASSIGN SEMICOLON EOL
%token <ival> INT_VALUE
%token <fval> FLOAT_VALUE
%token <cval> CHAR_VALUE
%token <sval> STRING_VALUE IDENTIFIER
%type <ptr> expression

%%

program:
    program statement EOL { }
    | statement EOL { }
    ;

statement:
    IDENTIFIER ASSIGN expression SEMICOLON {
        insertSymbol($1, $3);  
    }
    | PRINT IDENTIFIER SEMICOLON {
        printSymbol($2);
    }
    | PRINT SEMICOLON{
        printSymbolTable();
    }
    ;

expression:
    INT_VALUE {
        int* val = malloc(sizeof(int));
        *val = $1;
        $$ = createData(val, INT_TYPE);
    }
    | FLOAT_VALUE {
        float* val = malloc(sizeof(float));
        *val = $1;
        $$ = createData(val, FLOAT_TYPE);
    }
    | CHAR_VALUE {
        char* val = malloc(sizeof(char));
        *val = $1;
        $$ = createData(val, CHAR_TYPE);
    }
    | STRING_VALUE {
        char* val = strdup($1);
        $$ = createData(val, STRING_TYPE);
    }
    | IDENTIFIER {
        $$ = getSymbolValue($1);
    }
    ;


%%

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}

int main() {
    yyparse();
    return 0;
}
