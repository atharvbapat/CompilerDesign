#ifndef SYMBOL_TABLE_H
#define SYMBOL_TABLE_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef enum { INT_TYPE, FLOAT_TYPE, CHAR_TYPE, STRING_TYPE, CLASS_TYPE, OBJECT_TYPE } DataType;

typedef struct Data {
    DataType type;
    void* value;
    int ref_count;
    char** names;
    int name_count;
    int size;  
    struct Symbol* classSym; 
    struct Attribute* attributes; 
} Data;

typedef struct Symbol {
    Data* data;
    struct Symbol* next;
} Symbol;

typedef struct Attribute {
    char* name;
    Data* value;
} Attribute;

extern Symbol* symbolTable;

void* createData(void* value, DataType type);
void insertSymbol(char* name, Data* newData);
Data* getSymbolValue(char* name);
void deleteSymbol(char* name);
void addRef(Data* data, char* name);
void removeRef(Data* data, char* name);
void printSymbol(char* name);
void printSymbolTable();
Data** createAttributeList(char* attrName);
Data** addAttribute(Data** attrList, int count, char* attrName);
void createClass(char* name, Data** attrList);
void createObject(char* className, char* objectName);
void setObjectAttribute(char* objName, char* attrName, void* value);
Data* getObjectAttribute(char* objName, char* attrName);

#endif
