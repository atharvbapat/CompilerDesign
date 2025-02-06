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

    }Symbol;

    Symbol* symbolTable = NULL;


    void insertSymbol(char* name,void* value,DataType type){
        Symbol *newSymbol =(Symbol*)malloc(sizeof(Symbol));
        newSymbol->name = strdup(name);

        switch(type){
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
                break
            case STRING_TYPE:
                newSymbol->value = malloc(strlen((char*)value) + 1); 
                strcpy((char*)newSymbol->value, (char*)value);     
                break;  
        }

        newSymbol->next = symbolTable;
        symbolTable = newSymbol;
    }


    Symbol* getSymbol(char* name){
        Symbol* current = symbolTable;
        while(current){
            if(strcmp(current->name,name) == 0){
                return current;
            }
            current = current->next;
        }
        return NULL;
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