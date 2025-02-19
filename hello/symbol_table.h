#ifndef SYMBOL_TABLE_H
#define SYMBOL_TABLE_H

typedef enum { INT_TYPE, FLOAT_TYPE, CHAR_TYPE, STRING_TYPE } DataType;

typedef struct Symbol {
    char name[50];
    void* value;
    DataType type;
    struct Symbol *next;
} Symbol;

void insertSymbol(char* name, void* value, DataType type);
void printSymbol(char* name);
void* getSymbolValue(char* name);
void* createData(void* value, DataType type);

#endif
