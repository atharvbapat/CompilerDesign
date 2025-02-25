#include <stdio.h>
#include <stdlib.h>
#include "parser.tab.h"

extern int yyparse();
extern FILE *yyin;     

int main() {

    yyin = stdin;  
    yyparse();     

    return 0;
}
