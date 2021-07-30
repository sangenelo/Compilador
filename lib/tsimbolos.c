#include "tsimbolos.h"

void crearTablaSimbolos() {
    tablaSimbolos.primero = NULL;
}

int insertarEnTablaDeSimbolos(const char *nombre,const char *tipo, const char* valString, int valInt, double valDouble)
{   
    t_nodo *tabla = tablaSimbolos.primero;
    char nombreCTE[32] = "_";
    strcat(nombreCTE, nombre);
    
    while(tabla)
    {
        if(strcmp(tabla->data.nombre, nombre) == 0 || strcmp(tabla->data.nombre, nombreCTE) == 0)
        {
            return 1;
        }
        
        if(tabla->siguiente == NULL)
        {
            break;
        }
        tabla = tabla->siguiente;
    }

    t_data *data = (t_data*)malloc(sizeof(t_data));
    data = crearDatos(nombre, tipo, valString, valInt, valDouble);

    if(data == NULL)
    {
        return 1;
    }

    t_nodo* nuevo = (t_nodo*)malloc(sizeof(t_nodo));

    if(nuevo == NULL)
    {
        return 2;
    }

    nuevo->data = *data;
    nuevo->siguiente = NULL;

    if(tablaSimbolos.primero == NULL)
    {
        tablaSimbolos.primero = nuevo;
    }
    else
    {
        tabla->siguiente = nuevo;
    }

    return 0;
}

t_data* crearDatos(const char *nombre, const char *tipo, const char* valString, int valInt, double valDouble)
{
    char full[32] = "_";
    char aux[20];

    t_data *data = (t_data*)calloc(1, sizeof(t_data));
    if(data == NULL)
    {
        return NULL;
    }

    data->tipo = (char*)malloc(sizeof(char) * (strlen(tipo) + 1));
    strcpy(data->tipo, tipo);


    //Es una variable
    if(strcmp(tipo, "STRING")==0 || strcmp(tipo, "INTEGER")==0 
        || strcmp(tipo, "FLOAT")==0 || strcmp(tipo, "auxCode") == 0)
    {
        //al nombre lo dejo aca porque no lleva 
        data->nombre = (char*)malloc(sizeof(char) * (strlen(nombre) + 1));
        strcpy(data->nombre, nombre);
        return data;
    }
    else
    {      //Son constantes: tenemos que agregarlos a la tabla con "_" al comienzo del nombre, hay que agregarle el valor
        if(strcmp(tipo, "CTE_CADENA") == 0)
        {
            data->valor.valor_string = (char*)malloc(sizeof(char) * strlen(valString) +1);
            data->nombre = (char*)malloc(sizeof(char) * (strlen(valString) + 1));
            strcat(full, valString);
            data->longitud = strlen(valString);
            strcpy(data->nombre, full);    
            strcpy(data->valor.valor_string, valString);
        }
        if(strcmp(tipo, "CTE_FLOTANTE") == 0)
        {
            sprintf(aux, "%g", valDouble);
            strcat(full, aux);
            data->nombre = (char*)malloc(sizeof(char) * strlen(full));

            strcpy(data->nombre, full);
            data->valor.valor_double = valDouble;
        }
        if(strcmp(tipo, "CTE_ENTERA") == 0)
        {
            sprintf(aux, "%d", valInt);
            strcat(full, aux);
            data->nombre = (char*)malloc(sizeof(char) * strlen(full));
            strcpy(data->nombre, full);
            data->valor.valor_int = valInt;
        }
        return data;
    }
    return NULL;
}

void guardarTablaDeSimbolos()
{
    FILE* archivo;
    if((archivo = fopen("ts.txt", "wt")) == NULL)
    {
            printf("\nNo se pudo crear la tabla de simbolos.\n\n");
            return;
    }
    else if(tablaSimbolos.primero == NULL)
            return;
    
    fprintf(archivo, "%-30s%-30s%-30s%-30s\n", "NOMBRE", "TIPO", "VALOR", "LONGITUD");

    t_nodo *aux;
    t_nodo *tabla = tablaSimbolos.primero;
    char linea[100];

    while(tabla)
    {
        aux = tabla;
        tabla = tabla->siguiente;
        
        if(strcmp(aux->data.tipo, "INTEGER") == 0) //variable int
        {
            sprintf(linea, "%-30s%-30s%-30s%s\n", aux->data.nombre, aux->data.tipo, "--", "");
        }
        else if(strcmp(aux->data.tipo, "CTE_ENTERA") == 0)
        {
            sprintf(linea, "%-30s%-30s%-30d%s\n", aux->data.nombre, aux->data.tipo, aux->data.valor.valor_int, "");
        } 
        else if(strcmp(aux->data.tipo, "FLOAT") ==0)
        {
            sprintf(linea, "%-30s%-30s%-30s%s\n", aux->data.nombre, aux->data.tipo, "--", "");
        }
        else if(strcmp(aux->data.tipo, "CTE_FLOTANTE") == 0)
        {
            sprintf(linea, "%-30s%-30s%-30g%s\n", aux->data.nombre, aux->data.tipo, aux->data.valor.valor_double, "");
        }
        else if(strcmp(aux->data.tipo, "STRING") == 0)
        {
            sprintf(linea, "%-30s%-30s%-30s%lu\n", aux->data.nombre, aux->data.tipo, "--", strlen(aux->data.nombre));
        }
        else if(strcmp(aux->data.tipo, "CTE_CADENA") == 0)
        {
            sprintf(linea, "%-30s%-30s%-30s%d\n", aux->data.nombre, aux->data.tipo, aux->data.valor.valor_string, aux->data.longitud);
        }
        else if(strcmp(aux->data.tipo, "auxCode") == 0)
        {
            sprintf(linea, "%-30s%-30s%-30s%s\n", aux->data.nombre, "", "--", "");
        }
        fprintf(archivo, "%s", linea);
    }
    fclose(archivo); 
}


t_nodo * getLexema(const char *valor){
    t_nodo *lexema;
    t_nodo *tablaSimb = tablaSimbolos.primero;

    //int esID = -1;
    //int esCTE = -1;
    //int esASM;
    int encontro = -1;

    while(tablaSimb){ 
        encontro = strcmp(tablaSimb->data.nombre, valor);
        //esASM = strcmp(tablaSimb->data.nombreASM, valor);
        /*if(strcmp(tablaSimb->data.tipo, "CONST_STR") == 0)
        {
            encontro = strcmp(valor, tablaSimb->data.valor.valor_string);
        }*/

        if(encontro == 0) //|| esASM == 0 || esValor == 0)
        { 
            lexema = tablaSimb;
            return lexema;
        }
        tablaSimb = tablaSimb->siguiente;
    }
    return NULL;
}
