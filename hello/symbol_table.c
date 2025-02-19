#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "symbol_table.h"

Symbol *symbolTable = NULL;

void insertSymbol(char* name, void* value, DataType type) {
    Symbol *sym = symbolTable;

    while (sym) {
        if (strcmp(sym->name, name) == 0) {
            free(sym->value);
            break;
        }
        sym = sym->next;
    }

    if (!sym) {
        sym = (Symbol*)malloc(sizeof(Symbol));
        strcpy(sym->name, name);
        sym->next = symbolTable;
        symbolTable = sym;
    }

    switch (type) {
        case INT_TYPE:
            sym->value = malloc(sizeof(int));
            *(int*)(sym->value) = *(int*)value;
            break;
        case FLOAT_TYPE:
            sym->value = malloc(sizeof(float));
            *(float*)(sym->value) = *(float*)value;
            break;
        case CHAR_TYPE:
            sym->value = malloc(sizeof(char));
            *(char*)(sym->value) = *(char*)value;
            break;
        case STRING_TYPE:
            sym->value = strdup((char*)value);
            break;
    }

    sym->type = type;
}

void printSymbol(char *name) {
    Symbol *sym = symbolTable;

    while (sym) {
        if (strcmp(sym->name, name) == 0) {
            printf("%s = ", name);
            switch (sym->type) {
                case INT_TYPE:
                    printf("%d (int)\n", *(int *)(sym->value));
                    break;
                case FLOAT_TYPE:
                    printf("%f (float)\n", *(float *)(sym->value));
                    break;
                case CHAR_TYPE:
                    printf("'%c' (char)\n", *(char *)(sym->value));
                    break;
                case STRING_TYPE:
                    printf("\"%s\" (string)\n", (char *)(sym->value));
                    break;
            }
            return;
        }
        sym = sym->next;
    }

    printf("Variable %s not found!\n", name);
}

void* getSymbolValue(char* name) {
    Symbol *sym = symbolTable;
    while (sym) {
        if (strcmp(sym->name, name) == 0) {
            return sym->value;
        }
        sym = sym->next;
    }
    return NULL;
}

void* createData(void* value, DataType type) {
    void* data = malloc(sizeof(DataType) + sizeof(void*));
    *(DataType*)data = type;
    *(void**)(data + sizeof(DataType)) = value;
    return data;
}
