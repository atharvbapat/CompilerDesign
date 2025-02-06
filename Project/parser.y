%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void yyerror(const char *s);
int yylex();
extern int yylineno;
extern int getSymbolValue(char *name);
extern void insertSymbol(char *name, int value);
extern void printSymbolTable();

%}

%union {
    int num;
    char *var;
}

%token ASSIGN PRINT SEMICOLON EOL
%token <num> NUMBER
%token <var> IDENTIFIER

%%

program:
    program statement
    | /* empty */
    ;

statement:
    IDENTIFIER ASSIGN NUMBER SEMICOLON { 
        insertSymbol($1, $3);
        printf("Assigned: %s = %d\n", $1, $3);
    }
    | PRINT IDENTIFIER SEMICOLON {
        int value = getSymbolValue($2);
        if (value != -1)
            printf("Variable %s = %d\n", $2, value);
        else
            printf("Error: Undefined variable %s\n", $2);
    }
    | PRINT SEMICOLON {
        printSymbolTable();
    }
    | EOL { }
    ;

%%

int main() {
    printf("Enter your commands ");
    yyparse();
    return 0;
}

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s at line %d\n", s, yylineno);
}
