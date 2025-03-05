%{
#include <stdio.h>
#include <stdlib.h>

void yyerror(const char *s);
extern int yylex();
extern FILE *yyin;
%}

%token NOUN PRONOUN VERB ADVERB ADJECTIVE PREPOSITION CONJUNCTION

%%

sentences: 
    sentence{printf("Done");}
    ;

sentence: subject VERB object{ printf("Sentence is valid.\n"); }
    ;

subject: NOUN
        | PRONOUN
        ;

object: NOUN
        ;

%%

int main() {
    // Change yyin to use stdin to read from the terminal
    yyin = stdin;
    printf("Enter a sentence (e.g., 'he runs dog.'): ");
    yyparse();
    return 0;
}

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}

