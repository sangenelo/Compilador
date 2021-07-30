#ifndef TSIMBOLOS_H
#define TSIMBOLOS_H

#include <string.h>
#include <stdio.h>

typedef struct
{
        char *nombre;
        char *tipo;
        union Valor{
                int valor_int;
                double valor_double;
                char *valor_string;
        }valor;
        int longitud;
}t_data;

typedef struct simbolo
{
        t_data data;
        struct simbolo *siguiente;
}t_nodo;


typedef struct
{
        t_nodo *primero;
}t_tabla;

t_tabla tablaSimbolos;

void crearTablaSimbolos();

t_data* crearDatos(const char *, const char *, const char*, int, double);

int insertarEnTablaDeSimbolos(const char *, const char *, const char*, int, double );

void guardarTablaDeSimbolos();

t_nodo * getLexema(const char *);

#endif