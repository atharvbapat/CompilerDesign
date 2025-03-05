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

void createClass(char* name, Data** attrList) {
    Symbol* temp = (Symbol*)malloc(sizeof(Symbol));
    
    Data* data = (Data*)malloc(sizeof(Data));
    data->type = CLASS_TYPE;
    data->value = (void*)attrList;
    
    insertSymbol(name,data);
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
                        // case OBJECT_TYPE:
                        //     Data** dta = (Data**)data->value;
                            
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
        Data* data = sym->data;

        for (int i = 0; i < data->name_count; i++) {
            printf("| %-15s | ", data->names[i]);

            
            if (data->value == NULL) {
                printf("%-10s | ", "NULL");
            } else {
                switch (data->type) {
                    case INT_TYPE: printf("%-10d | ", *(int*)data->value); break;
                    case FLOAT_TYPE: printf("%-10.2f | ", *(float*)data->value); break;
                    case CHAR_TYPE: printf("'%c'        | ", *(char*)data->value); break;
                    case STRING_TYPE: printf("\"%-8s\" | ", (char*)data->value); break;
                    case CLASS_TYPE: printf("%-10s | ", "Class"); break;
                    case OBJECT_TYPE: printf("%-10s | ", "Object"); break;
                    default: printf("%-10s | ", "Unknown");
                }
            }

            printf("%-9d | ", data->ref_count);

            // Print type as string
            switch (data->type) {
                case INT_TYPE: printf("Integer     |\n"); break;
                case FLOAT_TYPE: printf("Float       |\n"); break;
                case CHAR_TYPE: printf("Character   |\n"); break;
                case STRING_TYPE: printf("String      |\n"); break;
                case CLASS_TYPE: printf("Class       |\n"); break;
                case OBJECT_TYPE: printf("Object      |\n"); break;
                default: printf("Unknown     |\n");
            }
        }

        sym = sym->next;
    }

    printf("+-----------------+------------+-----------+-------------+\n");
}





Data** createAttributeList(char* attrName) {
    Data** attrList = (Data**)malloc(sizeof(Data*));  
    Data* attrData = (Data*)malloc(sizeof(Data));

    attrData->type = -1;  
    attrData->value = NULL;
    attrData->names = (char**)malloc(sizeof(char*)); 
    attrData->names[0] = (char*)malloc(sizeof(char)); 
    attrData->names[0]=strdup(attrName);
    attrData->classSym = NULL;
    attrData->size = 1;
    attrList[0] = attrData;
    return attrList;
}   





Data** addAttribute(Data** attrList,char* attrName) {
    attrList = (Data**)realloc(attrList, sizeof(Data*) * 15); 

    Data* attrData = (Data*)malloc(sizeof(Data));
    attrData->type = -1;  
    attrData->value = NULL;
    attrData->names = (char**)malloc(sizeof(char*)); 
    attrData->names[0] = (char*)malloc(sizeof(char)); 
    attrData->names[0]=strdup(attrName);
    attrData->classSym = NULL;
    attrData->size = attrData->size + 1;
    attrList[attrData->size] = attrData;  
    return attrList;
}



//myone
// void createObject(char* className,int count,char* objectName){
//     Symbol *sym = symbolTable;
//     while (sym != NULL) {
//         if(strcmp(sym->data->names[0],className) == 0){
//             Data** temp = (Data**)sym->data->value;
//         }
//         sym= sym->next;
//     }

//     Data* objdata = (Data*)malloc(sizeof(Data));
//     objdata->type = OBJECT_TYPE;
//     objdata->classSym = (Symbol*)malloc(sizeof(Symbol)* count);
//     for(int i = 0; i < count;i++){
//         Symbol* s = objdata->classSym;
//         s[i].data = (Data*)malloc(sizeof(Data));
//         s[i].data->type = INT_TYPE;
//         s[i].data->value = NULL;
//     }

//     struct Symbol* i;
//     i.type = OBJECT_TYPE;
//     i.data = objdata;
//     i.next = symbolTable;
// }


void createObject(char* className, char* objectName) {
    Symbol* sym = symbolTable;
    Data** classAttributes = NULL;

    while (sym != NULL) {
        if (strcmp(sym->data->names[0], className) == 0) {
            classAttributes = (Data**)sym->data->value;
            break;
        }
        sym = sym->next;
    }

    if (classAttributes == NULL) {
        printf("Error: Class '%s' not found!\n", className);
        return;
    }

    Data* objData = (Data*)malloc(sizeof(Data));
    objData->type = OBJECT_TYPE;
    objData->classSym = (Symbol*)malloc(sizeof(Symbol) * 15);

    for (int i = 0; i < 2; i++) {
        Symbol* attr = &objData->classSym[i];
        attr->data = (Data*)malloc(sizeof(Data));
        // attr->data->type = OBJECT_TYPE;
        // attr->data->value = (void*)0;

    }
    insertSymbol(objectName, objData);
    printf("Object '%s' created from class '%s'!\n", objectName, className);
}



// void setObjectAttribute(char* objName,char* attrName,void* value){
//     Symbol* sym = symbolTable;
//     while (sym) {
//         if (strcmp(sym->data->names[0], objName) == 0 ){
//             Symbol *tmp = sym->data->classSym;
//             Data** attrs = (Data**)sym->data->value;
//             Data** temp = attrs;
//             while (*temp) {
//                 if (strcmp((*temp)->names[0], attrName) == 0) {
//                     (*temp)->value = value;
//                 }
//                 temp++;
//             }
//         }
//     }
// }


void setObjectAttribute(char* objName,char* attrName,Data* newData){
    Symbol* sym = symbolTable;
    // printf("first");
    while (sym) {
        if (strcmp(sym->data->names[0], objName) == 0 ){
            Symbol *tmp = sym->data->classSym;
            
            while(tmp){
                printf("%s",tmp->data->names[0]);
                if(strcmp("hello",attrName) == 0){
                    printf("second");
                    // tmp->data->value = newData->value;
                    // tmp->data->type = newData->type;
                    break;
                }

                tmp = tmp->next;
            }
        }
        sym = sym->next;
    }
}



Data* getObjectAttribute(char* objName, char* attrName) {
    Symbol* sym = symbolTable;
    while (sym) {
        if (sym->data->type == CLASS_TYPE) {
            Symbol* objSym = sym->data->classSym;
            while (objSym) {
                if (strcmp(objSym->data->names[0], objName) == 0) {
                    Data** attrs = (Data**)objSym->data->value;
                    while (*attrs) {
                        if (strcmp((*attrs)->names[0], attrName) == 0) {
                            return (*attrs)->value;
                        }
                        attrs++;
                    }
                }
                objSym = objSym->next;
            }
        }
        sym = sym->next;
    }
    printf("Error: Attribute '%s' not found in object '%s'.\n", attrName, objName);
    return NULL;
}

