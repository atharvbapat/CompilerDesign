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
%token DELETE;
%type <ptr> expression
%left '+' '-' 
%left '*' '/'

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
    | "del" IDENTIFIER SEMICOLON{
        deleteSymbol($2);
    }
    ;

expression:
    INT_VALUE {
        int* val = malloc(sizeof(int));
        if (!val) {
            fprintf(stderr, "Memory allocation failed\n");
            exit(1);
        }
        *val = $1;
        $$ = createData(val, INT_TYPE);
    }
    | FLOAT_VALUE {
        float* val = malloc(sizeof(float));
        if (!val) {
            fprintf(stderr, "Memory allocation failed\n");
            exit(1);
        }
        *val = $1;
        $$ = createData(val, FLOAT_TYPE);
    }
    | CHAR_VALUE {
        char* val = malloc(sizeof(char));
        if (!val) {
            fprintf(stderr, "Memory allocation failed\n");
            exit(1);
        }
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
    | expression '+' expression {
        Data* data1 = (Data*)$1;
        Data* data2 = (Data*)$3;

        if (data1->type == INT_TYPE && data2->type == INT_TYPE) {
            int* val = malloc(sizeof(int));
            if (!val) {
                fprintf(stderr, "Memory allocation failed\n");
                exit(1);
            }
            *val = *(int*)data1->value + *(int*)data2->value;
            $$ = createData(val, INT_TYPE);
        } else if (data1->type == FLOAT_TYPE && data2->type == FLOAT_TYPE) {
            float* fval = malloc(sizeof(float));
            if (!fval) {
                fprintf(stderr, "Memory allocation failed\n");
                exit(1);
            }
            *fval = *(float*)data1->value + *(float*)data2->value;
            $$ = createData(fval, FLOAT_TYPE);
        } else {
            yyerror("Type mismatch in addition");
        }
    }
    | expression '-' expression {
        Data* data1 = (Data*)$1;
        Data* data2 = (Data*)$3;

        if (data1->type == INT_TYPE && data2->type == INT_TYPE) {
            int* val = malloc(sizeof(int));
            if (!val) {
                fprintf(stderr, "Memory allocation failed\n");
                exit(1);
            }
            *val = *(int*)data1->value - *(int*)data2->value;
            $$ = createData(val, INT_TYPE);

        } else if(data1->type == FLOAT_TYPE && data2->type == FLOAT_TYPE){
             float* fval = malloc(sizeof(float));
            if (!fval) {
                fprintf(stderr, "Memory allocation failed\n");
                exit(1);
            }
            *fval = *(float*)data1->value - *(float*)data2->value;
            $$ = createData(fval, FLOAT_TYPE);

        } else {
            yyerror("Type mismatch in subtraction");
        }
    }
    | expression '*' expression {
        Data* data1 = (Data*)$1;
        Data* data2 = (Data*)$3;

        if (data1->type == INT_TYPE && data2->type == INT_TYPE) {
            int* val = malloc(sizeof(int));
            if (!val) {
                fprintf(stderr, "Memory allocation failed\n");
                exit(1);
            }
            *val = *(int*)data1->value * *(int*)data2->value;
            $$ = createData(val, INT_TYPE);
        } else if(data1->type == FLOAT_TYPE && data2->type == FLOAT_TYPE){
            float* fval = malloc(sizeof(float));
            if (!fval) {
                fprintf(stderr, "Memory allocation failed\n");
                exit(1);
            }
            *fval = *(float*)data1->value * *(float*)data2->value;
            $$ = createData(fval, FLOAT_TYPE);
        } else {
            yyerror("Type mismatch in multiplication");
        }
    }
    | expression '/' expression {
        Data* data1 = (Data*)$1;
        Data* data2 = (Data*)$3;

        if (data1->type == INT_TYPE && data2->type == INT_TYPE) {
            if (*(int*)data2->value == 0) {
                yyerror("Division by zero error");
            }
            int* val = malloc(sizeof(int));
            if (!val) {
                fprintf(stderr, "Memory allocation failed\n");
                exit(1);
            }
            *val = *(int*)data1->value / *(int*)data2->value;
            $$ = createData(val, INT_TYPE);
        } else if(data1->type == FLOAT_TYPE && data2->type == FLOAT_TYPE){
            if (*(float*)data2->value == 0.0f) {
                yyerror("Division by zero error");
            }
            float* fval = malloc(sizeof(float));
            if (!fval) {
                fprintf(stderr, "Memory allocation failed\n");
                exit(1);
            }
            *fval = *(float*)data1->value / *(float*)data2->value;
            $$ = createData(fval, FLOAT_TYPE);
        } else {
            yyerror("Type mismatch in division");
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


