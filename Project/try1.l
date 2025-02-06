%{
    #include "parser.tab.h"
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>

    typedef struct Symbol {
        char name[50];
        int value;
        struct Symbol *next;
    }Symbol;

    Symbol* symbolTable = NULL;


    void insertSymbol(char* name,int value){
        Symbol* current = symbolTable;

        while(current){
            if(strcmp(current->name,name) == 0){
                current->value = value;
                return;
            }
            current = current->next;
        }

        Symbol* newSymbol= (Symbol*)malloc(sizeof(Symbol));
        strcpy(newSymbol->name,name);
        newSymbol->value = value;
        newSymbol->next = symbolTable;
        symbolTable = newSymbol;
    }



    int getSymbolValue(char* name){
        Symbol* current = symbolTable;
        while(current){
        if(strcmp(current->name,name) == 0){
            return current->value;
        }
        current = current->next;
    }
    return -1;
    }

    void printSymbolTable() {
    printf("\nSYMBOL TABLE:\n");
    Symbol *current = symbolTable;
    while (current) {
        printf("%s = %d\n", current->name, current->value);
        current = current->next;
        }
    }



%}


%option noyywrap



%%

[ \t]+      ;  
[0-9]+      { yylval.num = atoi(yytext); return NUMBER; }
"print"    { return PRINT; }
[a-zA-Z_][a-zA-Z0-9_]* { yylval.var = strdup(yytext); return IDENTIFIER; }
"="         { return ASSIGN; }
";"         { return SEMICOLON; }
\n          { return EOL; }
.           { return yytext[0]; }  

%%