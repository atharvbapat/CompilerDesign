%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include "p.tab.h"

    extern int yylex();
    extern int yyparse();
    extern FILE* yyin;

    void yyerror(const char *s);

    // Define Data Types
    typedef enum { INT_TYPE, FLOAT_TYPE, CHAR_TYPE, STRING_TYPE } DataType;

    // Define Symbol Structure
    typedef struct Symbol {
        char name[50];
        void* value;
        DataType type;
        struct Symbol *next;
    } Symbol;

    // Global Symbol Table
    Symbol* symbolTable = NULL;

    // Function Prototypes
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
%token <ptr> INT_VALUE FLOAT_VALUE CHAR_VALUE STRING_VALUE IDENTIFIER

%type <ptr> expression
%type <ptr> statement

%%

program:
    program statement EOL { }
    | statement EOL { }
    ;

statement:
    IDENTIFIER ASSIGN expression SEMICOLON {
        Symbol *sym = getSymbol($1);
        if (sym) {
            free(sym->value);
            sym->value = $3;
            sym->type = *((DataType*)($3 - sizeof(DataType)));
        } else {
            insertSymbol($1, $3, *((DataType*)($3 - sizeof(DataType))));
        }
    }
    | PRINT IDENTIFIER SEMICOLON { printSymbol($2); }
    ;

expression:
    INT_VALUE {
        void* val = malloc(sizeof(int) + sizeof(DataType));
        *((DataType*)val) = INT_TYPE;
        val += sizeof(DataType);
        *((int*)val) = *(int*)$1;
        $$ = val;
    }
    | FLOAT_VALUE {
        void* val = malloc(sizeof(float) + sizeof(DataType));
        *((DataType*)val) = FLOAT_TYPE;
        val += sizeof(DataType);
        *((float*)val) = *(float*)$1;
        $$ = val;
    }
    | CHAR_VALUE {
        void* val = malloc(sizeof(char) + sizeof(DataType));
        *((DataType*)val) = CHAR_TYPE;
        val += sizeof(DataType);
        *((char*)val) = *(char*)$1;
        $$ = val;
    }
    | STRING_VALUE {
        int len = strlen((char*)$1) + 1;
        void* val = malloc(len + sizeof(DataType));
        *((DataType*)val) = STRING_TYPE;
        val += sizeof(DataType);
        strcpy((char*)val, (char*)$1);
        $$ = val;
    }
    | IDENTIFIER {
        Symbol *sym = getSymbol($1);
        if (sym) {
            $$ = sym->value;
        } else {
            yyerror("Undefined variable");
            $$ = NULL;
        }
    }
    ;

%%

// Error Handler
void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}

// Function to Insert Symbol in Table
void insertSymbol(char* name, void* value, DataType type) {
    Symbol *newSymbol = (Symbol*)malloc(sizeof(Symbol));
    strcpy(newSymbol->name, name);

    switch(type) {
        case INT_TYPE:
            newSymbol->value = malloc(sizeof(int));
            *(int*)(newSymbol->value) = *(int*)value;
            break;
        case FLOAT_TYPE:
            newSymbol->value = malloc(sizeof(float));
            *(float*)(newSymbol->value) = *(float*)value;
            break;
        case CHAR_TYPE:
            newSymbol->value = malloc(sizeof(char));
            *(char*)(newSymbol->value) = *(char*)value;
            break;
        case STRING_TYPE:
            newSymbol->value = malloc(strlen((char*)value) + 1);
            strcpy((char*)newSymbol->value, (char*)value);
            break;
    }

    newSymbol->type = type;
    newSymbol->next = symbolTable;
    symbolTable = newSymbol;
}

// Function to Retrieve Symbol from Table
Symbol* getSymbol(char* name) {
    Symbol* current = symbolTable;
    while (current) {
        if (strcmp(current->name, name) == 0) {
            return current;
        }
        current = current->next;
    }
    return NULL;
}

// Function to Print Symbol Value
void printSymbol(char *name) {
    Symbol *symbol = getSymbol(name);
    if (!symbol) {
        printf("Variable %s not found!\n", name);
        return;
    }

    printf("Variable %s = ", name);
    switch (symbol->type) {
        case INT_TYPE:
            printf("%d (int)\n", *(int *)(symbol->value));
            break;
        case FLOAT_TYPE:
            printf("%f (float)\n", *(float *)(symbol->value));
            break;
        case CHAR_TYPE:
            printf("'%c' (char)\n", *(char *)(symbol->value));
            break;
        case STRING_TYPE:
            printf("\"%s\" (string)\n", (char *)(symbol->value));
            break;
    }
}

// Main Function
int main() {
    yyparse();
    return 0;
}
