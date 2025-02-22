#include "symbol_table.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

Symbol* symbolTable = NULL;

void* createData(void* value, DataType type) {
    Data* data = malloc(sizeof(Data));
    data->type = type;
    data->value = value;
    return data;
}

void insertSymbol(char* name, Data* data) {
    Symbol* sym = malloc(sizeof(Symbol));
    strcpy(sym->name, name);
    sym->data = data;
    sym->next = symbolTable;
    symbolTable = sym;
}

Data* getSymbolValue(char* name) {
    Symbol* sym = symbolTable;
    while (sym) {
        if (strcmp(sym->name, name) == 0) {
            return sym->data;
        }
        sym = sym->next;
    }
    printf("Error: Undefined variable %s\n", name);
    return NULL;
}

void printSymbol(char* name) {
    Data* data = getSymbolValue(name);
    if (!data) return;

    printf("%s = ", name);
    switch (data->type) {
        case INT_TYPE: printf("%d\n", *(int*)data->value); break;
        case FLOAT_TYPE: printf("%f\n", *(float*)data->value); break;
        case CHAR_TYPE: printf("'%c'\n", *(char*)data->value); break;
        case STRING_TYPE: printf("\"%s\"\n", (char*)data->value); break;
    }
}

void printSymbolTable() {
    printf("\n--- Symbol Table ---\n");
    Symbol* sym = symbolTable;
    while (sym) {
        printf("%s = ", sym->name);
        switch (sym->data->type) {
            case INT_TYPE: printf("%d\n", *(int*)sym->data->value); break;
            case FLOAT_TYPE: printf("%f\n", *(float*)sym->data->value); break;
            case CHAR_TYPE: printf("'%c'\n", *(char*)sym->data->value); break;
            case STRING_TYPE: printf("\"%s\"\n", (char*)sym->data->value); break;
        }
        sym = sym->next;
    }
    printf("--------------------\n");
}
