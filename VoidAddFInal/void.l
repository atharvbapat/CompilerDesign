%{
    #include "parser.tab.h"
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>




typedef enum { INT_TYPE, FLOAT_TYPE, CHAR_TYPE, STRING_TYPE } DataType;

typedef struct Symbol {
        char name[50];
        void* value;
        DataType type;
        struct Symbol *next;
    } Symbol;


Symbol* symbolTable = NULL;





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
