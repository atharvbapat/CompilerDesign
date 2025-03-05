%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include "symbol_table.h"

    extern int yylex();
    void yyerror(const char *s);
    int attribute_count = 0;
%}

%union {
    int ival;
    float fval;
    char cval;
    char *sval;
    void *ptr;  
    struct Data** dt;
}

%token PRINT ASSIGN SEMICOLON COLON COMMA EOL
%token CLASS
%token <ival> INT_VALUE
%token <fval> FLOAT_VALUE
%token <cval> CHAR_VALUE
%token <sval> STRING_VALUE IDENTIFIER
%token DELETE
%type <ptr> expression
%type <dt> attribute_list
%left '+' '-' 
%left '*' '/'

%%

program:
    program statement EOL { }
    | statement EOL { }
    ;

statement:
    class_definition
    | object_instantiation
    | IDENTIFIER ASSIGN expression SEMICOLON {
        insertSymbol($1, $3);
    }
    | IDENTIFIER '^' IDENTIFIER ASSIGN expression SEMICOLON {
        setObjectAttribute($1, $3, $5);
    }
    | PRINT IDENTIFIER SEMICOLON {
        printSymbol($2);
    }
    | PRINT SEMICOLON {
        printSymbolTable();
    }
    | DELETE IDENTIFIER SEMICOLON {
        deleteSymbol($2);
    }
    | /* empty */
    ;

class_definition:
    CLASS IDENTIFIER COLON attribute_list {
        createClass($2, $4);
    }
    ;

attribute_list:
    IDENTIFIER {
        $$ = createAttributeList($1);
        attribute_count = 1;
    }
    | attribute_list COMMA IDENTIFIER {
        $$ = addAttribute($1, attribute_count, $3);
        attribute_count++;
    }
    ;

object_instantiation:
    IDENTIFIER ASSIGN IDENTIFIER '(' ')' SEMICOLON {
        createObject($3, $1);
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
    | IDENTIFIER '.' IDENTIFIER {
        $$ = getObjectAttribute($1, $3);
    }
    ;

%%

void yyerror(const char *s) {
    extern char *yytext;   
    extern int yylineno;
    fprintf(stderr, "Syntax Error at line %d: %s. Unexpected token: '%s'\n", 
            yylineno, s, yytext);
}


int main() {
    yyparse();
    return 0;
}