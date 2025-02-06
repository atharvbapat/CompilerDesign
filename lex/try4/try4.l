%{
#include "try4.tab.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define LOOKUP 0 

int state = LOOKUP;

struct word {
    char *word_name;
    int word_type;
    struct word *next;
};

struct word *word_list = NULL;

int add_word(int type, char* word);
int lookup_word(char *word);

int yywrap(void);

%}

%%

\n { state = LOOKUP; }

^verb { state = VERB; printf("Setting state to VERB %s\n",yytext); }
^adj { state = ADJECTIVE; printf("Setting state to ADJECTIVE\n"); }
^adv { state = ADVERB; printf("Setting state to ADVERB\n"); }
^noun { state = NOUN; printf("Setting state to NOUN\n"); }
^pron { state = PRONOUN; printf("Setting state to PRONOUN\n"); }
^prep { state = PREPOSITION; printf("Setting state to PREPOSITION\n"); }
^conj { state = CONJUNCTION; printf("Setting state to CONJUNCTION\n"); }

[a-zA-Z]+ {
    if (state != LOOKUP) {
        printf("Adding word: %s to category %d\n", yytext, state);
        add_word(state, yytext);
    } else {
        int type = lookup_word(yytext);
        if (type == LOOKUP) {
            printf("%s: don't recognize\n", yytext);
        } else {
            switch (type) {
                case VERB: return VERB;
                case ADJECTIVE: return ADJECTIVE;
                case ADVERB: return ADVERB;
                case NOUN: return NOUN;
                case PREPOSITION: return PREPOSITION;
                case PRONOUN: return PRONOUN;
                case CONJUNCTION: return CONJUNCTION;
            }
        }
    }
}
. 
%%

int add_word(int type, char* word) {
    struct word *wp;

    if (lookup_word(word) != LOOKUP) {
        printf("!!! Warning: word %s already defined\n", word);
        return 0;
    }

    wp = (struct word*) malloc(sizeof(struct word));
    wp->next = word_list;
    wp->word_name = strdup(word);
    wp->word_type = type;
    word_list = wp;
    return 1;
}

int lookup_word(char *word) {
    struct word *wp = word_list;
    while (wp) {
        if (strcmp(wp->word_name, word) == 0) {
            return wp->word_type;
        }
        wp = wp->next;
    }
    return LOOKUP;
}

int yywrap(void) {
    return 1;
}
