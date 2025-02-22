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

void* createData(void* value, DataType type);
void insertSymbol(char* name, Data* data);
Data* getSymbolValue(char* name);
void printSymbol(char* name);
void printSymbolTable();  

#endif // SYMBOL_TABLE_H
