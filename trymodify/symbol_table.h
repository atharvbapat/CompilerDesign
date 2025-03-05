#ifndef SYMBOL_TABLE_H
#define SYMBOL_TABLE_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef enum { INT_TYPE, FLOAT_TYPE, CHAR_TYPE, STRING_TYPE } DataType;

typedef struct Data {
    DataType type;
    void* value;
    int ref_count;
    char** names;   
    int name_count; 
} Data;

typedef struct Symbol {
    struct Symbol* next;
    Data* data;
} Symbol;

extern Symbol* symbolTable;

void* createData(void* value, DataType type);
void insertSymbol(char* name, Data* data);
Data* getSymbolValue(char* name);
void printSymbolTable();
void printSymbol(char* name);
void addRef(Data* data, char* name);
void removeRef(Data* data, char* name);
void deleteSymbol(char* name);

#endif // SYMBOL_TABLE_H
