%{
#include <stdio.h>
%}

%%

[\t\n ]+  /* Ignore whitespace and newlines */ ;

is |
am |
are |
were |
was |
be |
being |
been |
do |
does |
did |
will |
would |
should |
can |
could |
has |
have |
had |
go  { printf("%s: is a verb\n", yytext); }

[a-zA-Z]+ { printf("%s: is not a verb\n", yytext); }

. { ECHO; } /* Print unexpected characters */

%%

int main() {
    printf("Enter words (Ctrl+D to exit):\n");
    yylex();  // Start lexical analysis
    return 0;
}

int yywrap() {
    return 1;
}
