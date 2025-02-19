%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include "p.tab.h"

    extern int yylex();
    extern int yyparse();
    extern FILE* yyin;

    void yyerror(const char *s);

    
    typedef enum { INT_TYPE, FLOAT_TYPE, CHAR_TYPE, STRING_TYPE } DataType;

    
    typedef struct Symbol {
        char name[50];
        void* value;
        DataType type;
        int refCount;
        struct Symbol *next;
    } Symbol;

    
    Symbol* symbolTable = NULL;

    
    void insertSymbol(char* name, void* value, DataType type);
    Symbol* getSymbol(char* name);
    void printSymbol(char *name);

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
%token <sval> STRING_VALUE


type <ptr> statement
type <ptr> expression

%%
program:
    program statement EOL {}
    | statement EOL{}
    ;

statement: 
    IDENTIFIER ASSIGN expression SEMICOLON {
        Symbol *sym = getSymbol($1);
        if (sym) {
            if(sym->type == INT_TYPE) 
        } 
    }



%%
