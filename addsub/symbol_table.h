#ifndef SYMBOL_TABLE_H
#define SYMBOL_TABLE_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef enum { INT_TYPE, FLOAT_TYPE, CHAR_TYPE, STRING_TYPE } DataType;

typedef struct {
    DataType type;
    void* value;
} Data;

typedef struct Symbol {
    char name[50];  
    Data* data;     
    struct Symbol* next;  
} Symbol;

extern Symbol* symbolTable;

void insertSymbol(char *name, void *value);
void setAttributeValue(char *object, char *attribute, void *value);
void printSymbol(char *name);
void printSymbolTable();
void createAttributes(char *className, struct Data** attributes);
void createClass(char *className);
struct Data** createAttributeList(char *attribute);
struct Data** addAttribute(struct Data** list, char *attribute);
void createObject(char *className, char *objectName);
void* createData(void *value, int type);
void* getSymbolValue(char *name);

#endif // SYMBOL_TABLE_H
