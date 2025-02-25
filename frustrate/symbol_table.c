#include "symbol_table.h"

Symbol* symbolTable = NULL;


Data** createAttributeList(char* attrName) {
    Data** attrList = (Data**)malloc(sizeof(Data*));  // Allocate space for 1 attribute
    attrList[0] = (Data*)malloc(sizeof(Data));       // Allocate space for Data struct
    attrList[0]->value = strdup(attrName);           // Copy attribute name
    return attrList;
}

Data** addAttribute(Data** attrList, int count, char* attrName) {
    attrList = (Data**)realloc(attrList, (count + 1) * sizeof(Data*)); // Increase size
    attrList[count] = (Data*)malloc(sizeof(Data));  // Allocate space for new attribute
    attrList[count]->value = strdup(attrName);      
    return attrList;
}

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
    data->classSym = NULL;
    data->attributes = NULL;
    data->size = 0;

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

void createClass(char* name, Data** attrList) {
    Data* data = malloc(sizeof(Data));
    data->type = CLASS_TYPE;
    data->value = attrList;
    data->attributes = (Attribute*)attrList;
    data->size = 0;
    insertSymbol(name, data);
}

void createObject(char* className, char* objectName) {
    Symbol* classSym = symbolTable;
    
    // Find the symbol associated with the class
    while (classSym) {
        for (int i = 0; i < classSym->data->name_count; i++) {
            if (strcmp(classSym->data->names[i], className) == 0) {
                goto found;
            }
        }
        classSym = classSym->next;
    }

    printf("Error: '%s' is not a class.\n", className);
    return;

found:
    Data* classData = classSym->data;

    if (!classData || classData->type != CLASS_TYPE) {
        printf("Error: '%s' is not a valid class.\n", className);
        return;
    }

    // Allocate memory for new object
    Data* objData = malloc(sizeof(Data));
    objData->type = OBJECT_TYPE;
    objData->classSym = classSym;  // Store the class symbol, not Data*
    objData->size = classData->size;
    objData->attributes = malloc(sizeof(Attribute) * objData->size);

    // Copy attributes from class to object
    for (int i = 0; i < classData->size; i++) {
        objData->attributes[i].name = strdup(classData->attributes[i].name);
        objData->attributes[i].value = NULL;
    }

    // Insert object into symbol table
    insertSymbol(objectName, objData);
}


void setObjectAttribute(char* objName, char* attrName, void* value) {
    Data* objData = getSymbolValue(objName);
    if (!objData || objData->type != OBJECT_TYPE) {
        printf("Error: '%s' is not an object.\n", objName);
        return;
    }

    for (int i = 0; i < objData->size; i++) {
        if (strcmp(objData->attributes[i].name, attrName) == 0) {
            objData->attributes[i].value = value;
            return;
        }
    }

    printf("Error: Attribute '%s' not found in object '%s'.\n", attrName, objName);
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


Data* getObjectAttribute(char* objName, char* attrName) {
    Data* objData = getSymbolValue(objName);
    if (!objData || objData->type != OBJECT_TYPE) {
        printf("Error: '%s' is not an object.\n", objName);
        return NULL;
    }

    for (int i = 0; i < objData->size; i++) {
        if (strcmp(objData->attributes[i].name, attrName) == 0) {
            return objData->attributes[i].value;
        }
    }

    printf("Error: Attribute '%s' not found in object '%s'.\n", attrName, objName);
    return NULL;
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
        free(data->attributes);
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



void printSymbolTable() {
    Symbol* sym = symbolTable;
    
    printf("\n================ SYMBOL TABLE =================\n");
    printf("| %-15s | %-10s | %-10s | %-5s |\n", "Name", "Type", "Value", "Refs");
    printf("-------------------------------------------------\n");

    while (sym) {
        for (int i = 0; i < sym->data->name_count; i++) {
            // Extract name, type, and reference count
            char* name = sym->data->names[i];
            char* typeStr;
            char valueStr[50];

            switch (sym->data->type) {
                case INT_TYPE:
                    typeStr = "INT";
                    sprintf(valueStr, "%d", *(int*)sym->data->value);
                    break;
                case FLOAT_TYPE:
                    typeStr = "FLOAT";
                    sprintf(valueStr, "%.2f", *(float*)sym->data->value);
                    break;
                case STRING_TYPE:
                    typeStr = "STRING";
                    sprintf(valueStr, "\"%s\"", (char*)sym->data->value);
                    break;
                case CLASS_TYPE:
                    typeStr = "CLASS";
                    sprintf(valueStr, "-");
                    break;
                case OBJECT_TYPE:
                    typeStr = "OBJECT";
                    sprintf(valueStr, "-");
                    break;
                default:
                    typeStr = "UNKNOWN";
                    sprintf(valueStr, "?");
            }

            // Print formatted row
            printf("| %-15s | %-10s | %-10s | %-5d |\n", name, typeStr, valueStr, sym->data->ref_count);

            // If this is a CLASS or OBJECT, print attributes
            if (sym->data->type == CLASS_TYPE || sym->data->type == OBJECT_TYPE) {
                printf("  Attributes:\n");
                for (int j = 0; j < sym->data->size; j++) {
                    printf("    - %s\n", sym->data->attributes[j].name);
                }
            }
        }
        sym = sym->next;
    }

    printf("=================================================\n");
}

