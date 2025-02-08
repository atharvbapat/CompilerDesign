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
    void* ptr;
}

%token <ptr> IDENTIFIER INT_VALUE FLOAT_VALUE CHAR_VALUE STRING_VALUE
%token ASSIGN PRINT SEMICOLON EOL


%%
assignment:
    IDENTIFIER ASSIGN expression SEMICOLON{
        Symbol* var= getSymbol($1);
        insertSymbol($1,(void*)$3,$3_type);
    }
    ;

expression:
    INT_VALUE { $$ = $1 ; $$type = INT_TYPE; }
    | FLOAT_VALUE { $$ = $1; $$.type = FLOAT_TYPE; }
    | CHAR_VALUE { $$ = $1; $$.type = CHAR_TYPE; }
    | STRING_VALUE { $$ = $1; $$.type = STRING_TYPE; }
    | IDENTIFIER {
        Symbol* var = getSymbol($1);
        if(!var){
            YYABORT;
        }
        $$ = var->value;
        $$.type = var->type;
    }
    ;

printstatement:
    PRINT IDENTIFIER SEMICOLON{
        printSymbol($2);
    }
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


