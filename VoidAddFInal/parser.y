%{

    #include<stdio.h>
    #include<stdlib.h>
    #include<string.h>

    extern int yylex();
    extern int yyparse();
    extern FILE* yyin;

    void yyerror(const char *s);

    extern void insertSymbol(char* name, void* value, DataType type);
    extern Symbol* getSymbol(char* name);
    extern void printSymbol(char *name);
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


void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}



int main() {
    yyparse();
    return 0;
}