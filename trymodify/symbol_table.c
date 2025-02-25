#include "symbol_table.h"

Symbol* symbolTable = NULL;

void* createData(void* value, DataType type) {
    Symbol* sym = symbolTable;

    while (sym) {
        if (sym->data->type == type) {
            if ((type == INT_TYPE && *((int*)sym->data->value) == *((int*)value)) ||
                (type == FLOAT_TYPE && *((float*)sym->data->value) == *((float*)value)) ||
                (type == STRING_TYPE && strcmp((char*)sym->data->value, (char*)value) == 0)) {
                
                return sym->data;
            }
        }
        sym = sym->next;
    }

    Data* data = malloc(sizeof(Data));
    data->type = type;
    data->value = malloc(sizeof(value));
    memcpy(data->value, value, sizeof(value));
    data->ref_count = 0;
    data->names = NULL;
    data->name_count = 0;

    return data;
}

void insertSymbol(char* name, Data* newData) {
    Symbol* sym = symbolTable;
    Data* oldData = NULL;

    while (sym) {
        for (int i = 0; i < sym->data->name_count; i++) {
            if (strcmp(sym->data->names[i], name) == 0) {
                oldData = sym->data;
                break;
            }
        }
        sym = sym->next;
    }

    if (oldData) {
        removeRef(oldData, name);
    }

    addRef(newData, name);
}

Data* getSymbolValue(char* name) {
    Symbol* sym = symbolTable;
    while (sym) {
        for (int i = 0; i < sym->data->name_count; i++) {
            if (strcmp(sym->data->names[i], name) == 0) {
                return sym->data;
            }
        }
        sym = sym->next;
    }
    printf("Error: Undefined variable %s\n", name);
    return NULL;
}

void addRef(Data* data, char* name) {
    data->names = realloc(data->names, (data->name_count + 1) * sizeof(char*));
    data->names[data->name_count] = strdup(name);
    data->name_count++;
    data->ref_count++;

    Symbol* sym = symbolTable;
    while (sym) {
        if (sym->data == data) return;
        sym = sym->next;
    }

    Symbol* newSymbol = malloc(sizeof(Symbol));
    newSymbol->data = data;
    newSymbol->next = symbolTable;
    symbolTable = newSymbol;
}

void removeRef(Data* data, char* name) {
    if (!data || data->name_count == 0) return;

    int found = 0;
    for (int i = 0; i < data->name_count; i++) {
        if (strcmp(data->names[i], name) == 0) {
            found = 1;
            free(data->names[i]);
            for (int j = i; j < data->name_count - 1; j++) {
                data->names[j] = data->names[j + 1];
            }
            data->name_count--;
            break;
        }
    }

    if (!found) return;

    data->ref_count--;

    if (data->ref_count == 0) {
        free(data->value);
        free(data->names);
        free(data);

        Symbol** sym = &symbolTable;
        while (*sym) {
            if ((*sym)->data == data) {
                Symbol* temp = *sym;
                *sym = (*sym)->next;
                free(temp);
                return;
            }
            sym = &(*sym)->next;
        }
    }
}

void deleteSymbol(char* name) {
    insertSymbol(name, NULL);
}


void printSymbol(char* name) {
    Symbol* current = symbolTable;

    while (current) {
        Data* data = current->data;
        if (data) {
            for (int i = 0; i < data->name_count; i++) {
                if (strcmp(data->names[i], name) == 0) {
                    printf("%s = ", name);
                    switch (data->type) {
                        case INT_TYPE:
                            printf("%d\n", *(int*)data->value);
                            break;
                        case FLOAT_TYPE:
                            printf("%f\n", *(float*)data->value);
                            break;
                        case CHAR_TYPE:
                            printf("'%c'\n", *(char*)data->value);
                            break;
                        case STRING_TYPE:
                            printf("\"%s\"\n", (char*)data->value);
                            break;
                    }
                    return; 
                }
            }
        }
        current = current->next;
    }
    
    printf("Error: Variable '%s' not found in the symbol table.\n", name);
}


void printSymbolTable() {
    printf("\n+-----------------+------------+-----------+-------------+\n");
    printf("| %-15s | %-10s | %-9s | %-11s |\n", "Variables", "Value", "Ref Count", "Type");
    printf("+-----------------+------------+-----------+-------------+\n");

    Symbol* sym = symbolTable;
    while (sym) {
        for (int i = 0; i < sym->data->name_count; i++) {
            printf("| %-15s | ", sym->data->names[i]);

            switch (sym->data->type) {
                case INT_TYPE: printf("%-10d | ", *(int*)sym->data->value); break;
                case FLOAT_TYPE: printf("%-10.2f | ", *(float*)sym->data->value); break;
                case CHAR_TYPE: printf("'%c'        | ", *(char*)sym->data->value); break;
                case STRING_TYPE: printf("\"%-8s\" | ", (char*)sym->data->value); break;
            }

            printf("%-9d | ", sym->data->ref_count);

            switch (sym->data->type) {
                case INT_TYPE: printf("Integer     |\n"); break;
                case FLOAT_TYPE: printf("Float       |\n"); break;
                case CHAR_TYPE: printf("Character   |\n"); break;
                case STRING_TYPE: printf("String      |\n"); break;
            }
        }
        sym = sym->next;
    }

    printf("+-----------------+------------+-----------+-------------+\n");
}
