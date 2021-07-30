#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <conio.h>

#include "assembler.h"
#include "tercetos.h"

#include "tsimbolos.h"
#include "util.h"

char bufferaux1[20];
char auxS[100];
int yyerror();
int esOperacion(int);

void preparar_assembler()
{
	char etiqueta[20] = "etiqueta_";
	int entero_aux;
    int i;
    int j;
    int indice_terceto = obtenerIndiceTercetos();
	
	for(i=0;i<indice_terceto;i++)
	{

        if(strcmp(vector_tercetos[i].atr1,"ET")==0) {
            //printf("entre aca con i: %d\n", i);
            vector_tercetos[i].esEtiqueta = 1;
        }

		if(strcmp(vector_tercetos[i].atr2,"_")==0 && strcmp(vector_tercetos[i].atr3,"_")==0 && vector_tercetos[i].esEtiqueta!=1 )
		{
			for(j=i+1;j< indice_terceto;j++)
			{
				itoa(i,bufferaux1,10);
                
				if(strcmp(vector_tercetos[j].atr2,bufferaux1)==0)
				{
					strcpy(vector_tercetos[j].atr2,vector_tercetos[i].atr1);
				}
				if(strcmp(vector_tercetos[j].atr3,bufferaux1)==0)
				{
					strcpy(vector_tercetos[j].atr3,vector_tercetos[i].atr1);
				}
			}
		}

        if(esSalto(i))
		{	
            //printf("Entre con i:%d\n",i);
			entero_aux = atoi(vector_tercetos[i].atr2);
            //printf("Entero Aux:%d\n",entero_aux);
			vector_tercetos[entero_aux].esEtiqueta = 1;
			strcat(etiqueta,vector_tercetos[i].atr2);
            //printf("Etiqueta:%s\n",etiqueta);
			strcpy(vector_tercetos[i].atr2,etiqueta);
			strcpy(etiqueta,"etiqueta_");
		}
		
		if(strcmp(vector_tercetos[i].atr2,"_")==0 && strcmp(vector_tercetos[i].atr3,"_")==0 && vector_tercetos[i].esEtiqueta==1 )
		{
			j=i+1;
			itoa(i,bufferaux1,10);
			while(strcmp(vector_tercetos[j].atr2,bufferaux1)!=0 && strcmp(vector_tercetos[j].atr3,bufferaux1)!=0)
				j++;
			
			if(strcmp(vector_tercetos[j].atr2,bufferaux1)==0){
                if(strcmp(vector_tercetos[i].atr1,"ET")!=0)
				    strcpy(vector_tercetos[j].atr2,vector_tercetos[i].atr1);
                else
                    strcpy(vector_tercetos[j].atr2,bufferaux1);
            }
			else
				strcpy(vector_tercetos[j].atr3,vector_tercetos[i].atr1);
			
		}
		
		if(esOperacion(i))
		{
			for(j=i+1;j< indice_terceto;j++)
			{	
				itoa(i,bufferaux1,10);
				if(strcmp(vector_tercetos[j].atr2,bufferaux1)==0)
				{
					strcpy(vector_tercetos[j].atr2,vector_tercetos[i].res_aux);
				}
				
				if(strcmp(vector_tercetos[j].atr3,bufferaux1)==0)
				{
					strcpy(vector_tercetos[j].atr3,vector_tercetos[i].res_aux);
				}
				
			}
			
		}
		
	}

}

int esOperacion(int indice)
{

	if(strcmp(vector_tercetos[indice].atr1,"+")==0)
	    return 1;	
	if(strcmp(vector_tercetos[indice].atr1,"-")==0)
	    return 2;
	if(strcmp(vector_tercetos[indice].atr1,"*")==0)
	    return 3;
	if(strcmp(vector_tercetos[indice].atr1,"/")==0)
	    return 4;
	if(strcmp(vector_tercetos[indice].atr1,"=")==0)
		return 5;
	if(strcmp(vector_tercetos[indice].atr1,"WRITE")==0)
		return 6;											
	if(strcmp(vector_tercetos[indice].atr1,"READ")==0)
		return 7;
	
	return 0;
}

int esSalto(int indice)
{	
	if(strcmp(vector_tercetos[indice].atr1,"JNA")==0)		// >
	    return 1;
	
	if(strcmp(vector_tercetos[indice].atr1,"JAE")==0)		// <
	    return 2;
	
	if(strcmp(vector_tercetos[indice].atr1,"JNAE")==0)		// >=
	    return 3;
	
	if(strcmp(vector_tercetos[indice].atr1,"JA")==0)			// <=
	    return 4;
	
	if(strcmp(vector_tercetos[indice].atr1,"JNE")==0)		// ==
	    return 5;
	
	if(strcmp(vector_tercetos[indice].atr1,"JE")==0)			// !=
	    return 6;
	
	if(strcmp(vector_tercetos[indice].atr1,"JMP")==0)		// salto incondicional
	    return 7;
	
	return 0;
}


void generarAssembler()
{
    preparar_assembler();

    FILE *archivo;

    if((archivo = fopen("Final.asm", "w"))==NULL){
        printf("No se puede crear el archivo \"Final.asm\"\n");
        exit(1);
    }

    fprintf(archivo, "include macros2.asm\ninclude number.asm\n.MODEL LARGE\n.386\n.STACK 200h\n\n");

    escribir_seccion_datos(archivo);

    fprintf(archivo, ".CODE\n\nSTART:\n\nMOV AX,@DATA\nMOV DS, AX\nMOV ES, AX\n\n");

    escribir_seccion_codigo(archivo);

    fprintf(archivo, "MOV EAX, 4C00h\nINT 21h\n\nEND START\n");

    fclose(archivo);
}

void escribir_seccion_datos(FILE *archivoAssembler) {
    int i;
	char valorAux[100];
    char buffer[10];

	fprintf(archivoAssembler, ".DATA\n");
    	
    t_nodo *aux;
    t_nodo *tabla = tablaSimbolos.primero;
    char linea[100];

	while(tabla)
	{
        aux = tabla;
        //printf("Aux data.nombre: %s\n", aux->data.nombre);
		
        if(strcmp(aux->data.tipo, "INTEGER") == 0 || strcmp(aux->data.tipo, "FLOAT") ==0 || strcmp(aux->data.tipo, "STRING") == 0) 
        {
            sprintf(linea, "%s dd ?\n", aux->data.nombre);
        }
        else if(strcmp(aux->data.tipo, "CTE_ENTERA") == 0)
        {
            strcpy(buffer,".0");
            itoa(aux->data.valor.valor_int,valorAux,10);
            strcat(valorAux,buffer);
            sprintf(linea, "%s dd %s\n", aux->data.nombre, valorAux);        
        } 
        else if(strcmp(aux->data.tipo, "CTE_FLOTANTE") == 0)
        {
            sprintf(valorAux,"%g",aux->data.valor.valor_double);
            replace_char(aux->data.nombre,'.', '_');
            sprintf(linea, "%s dd %s\n", aux->data.nombre, valorAux);         
        }
        else if(strcmp(aux->data.tipo, "CTE_CADENA") == 0)
        {
            strcpy(valorAux,aux->data.valor.valor_string);
            removeChar(aux->data.nombre,'!');
            removeChar(aux->data.nombre,':');
            removeChar(aux->data.nombre,'\"');
            removeChar(aux->data.nombre,'#');
            replace_char(aux->data.nombre,'.', '_');
            replace_char(aux->data.nombre,' ', '_');
            replace_char(aux->data.nombre,'@', 'a');
            replace_char(aux->data.nombre,'$', 'S');
            sprintf(linea, "%s db %s , '$', %d dup (?)\n", aux->data.nombre, valorAux, aux->data.longitud);         
        }
        
        else if(strcmp(aux->data.tipo, "auxCode") == 0)
        {
            sprintf(linea, "%s dd ?\n", aux->data.nombre);
        }

        fprintf(archivoAssembler, "%s",linea);
        tabla = tabla->siguiente;
	}
    sprintf(linea,"@aux dd ?\n");  
    fprintf(archivoAssembler, "%s",linea);    
	fprintf(archivoAssembler, "\n");	
}

void escribir_seccion_codigo(FILE *archivoAssembler)
{
	int i;
    int indice_terceto = obtenerIndiceTercetos();

	for(i=0;i <= indice_terceto;i++)
	{		        

		if(vector_tercetos[i].esEtiqueta == 1)
		{   
			fprintf(archivoAssembler,"\netiqueta_%d:\n",i);
		}
		
		switch(esOperacion(i))
		{
		    case 1:
                fprintf(archivoAssembler,"fld %s\nfld %s\nfadd\nfstp %s\n",vector_tercetos[i].atr2,vector_tercetos[i].atr3, vector_tercetos[i].res_aux);
                break;
			
            case 2:
                fprintf(archivoAssembler,"fld %s\nfld %s\nfsub\nfstp %s\n", vector_tercetos[i].atr2,vector_tercetos[i].atr3, vector_tercetos[i].res_aux);
                break;
			
            case 3:
                fprintf(archivoAssembler,"fld %s\nfld %s\nfmul\nfstp %s\n", vector_tercetos[i].atr2,vector_tercetos[i].atr3, vector_tercetos[i].res_aux);
                break;
			
            case 4:
                fprintf(archivoAssembler,"fld %s\nfld %s\nfdiv\nfstp %s\n", vector_tercetos[i].atr2,vector_tercetos[i].atr3, vector_tercetos[i].res_aux);
                break;
                
            case 5:
                //Si es cadena remuevo las comillas y agrego _
                if(vector_tercetos[i].atr3[0]=='"'){
                    vector_tercetos[i].atr3[0]='_';
                    int ultima_pos = strlen(vector_tercetos[i].atr3)-1;
                    vector_tercetos[i].atr3[ultima_pos]='\0';
                    removeChar(vector_tercetos[i].atr3,'!');
                    removeChar(vector_tercetos[i].atr3,':');
                    removeChar(vector_tercetos[i].atr3,'\"');
                    removeChar(vector_tercetos[i].atr3,'#');
                    replace_char(vector_tercetos[i].atr3,'@', 'a');
                    replace_char(vector_tercetos[i].atr3,'$', 'S');
                    replace_char(vector_tercetos[i].atr3,'.', '_');
                    replace_char(vector_tercetos[i].atr3,' ', '_');
                }
                fprintf(archivoAssembler,"fld %s\nfstp %s\n", vector_tercetos[i].atr3, vector_tercetos[i].atr2);
                break;
                
            case 6:
                //Si es cadena remuevo las comillas y agrego _
                if(vector_tercetos[i].atr2[0]=='"'){
                    vector_tercetos[i].atr2[0]='_';
                    int ultima_pos = strlen(vector_tercetos[i].atr2)-1;
                    vector_tercetos[i].atr2[ultima_pos]='\0';
                    removeChar(vector_tercetos[i].atr2,'!');
                    removeChar(vector_tercetos[i].atr2,':');
                    removeChar(vector_tercetos[i].atr2,'\"');
                    removeChar(vector_tercetos[i].atr2,'#');
                    replace_char(vector_tercetos[i].atr2,'@', 'a');
                    replace_char(vector_tercetos[i].atr2,'$', 'S');
                    replace_char(vector_tercetos[i].atr2,'.', '_');
                    replace_char(vector_tercetos[i].atr2,' ', '_');
                    fprintf(archivoAssembler,"mov dx,OFFSET %s\nmov ah,9\nint 21h\nnewline 1\n\n", vector_tercetos[i].atr2);
                }else{
                    fprintf(archivoAssembler,"DisplayFloat %s,1 \n\n",vector_tercetos[i].atr2);
                }
                //fprintf(archivoAssembler,"mov dx,OFFSET %s\nmov ah,9\nint 21h\nnewline 1\n\n", vector_tercetos[i].atr2);
                break;
                
            case 7: //GET por consola
                fprintf(archivoAssembler,"GetFloat %s \n\n",vector_tercetos[i].atr2);
                break;
		}
		
		
		if(strcmp(vector_tercetos[i].atr1,"CMP")==0) {
		    fprintf(archivoAssembler,"fld %s\nfld %s\nfxch\nfcomp\nfstsw ax\nsahf\n", vector_tercetos[i].atr2,vector_tercetos[i].atr3);
        }
		
		switch(esSalto(i))
		{		
            case 1:
                fprintf(archivoAssembler,"JNA %s\n\n", vector_tercetos[i].atr2);//  >
                break;
                
            case 2:
                fprintf(archivoAssembler,"JAE %s\n\n", vector_tercetos[i].atr2);//  <
                break;
                
            case 3:
                fprintf(archivoAssembler,"JNAE %s\n\n", vector_tercetos[i].atr2);// >=
                break;
                
            case 4:
                fprintf(archivoAssembler,"JA %s\n\n", vector_tercetos[i].atr2);// <=
                break;
                
            case 5:
                fprintf(archivoAssembler,"JNE %s\n\n", vector_tercetos[i].atr2);// ==
                break;
                
            case 6:
                fprintf(archivoAssembler,"JE %s\n\n", vector_tercetos[i].atr2);// !=
                break;
                
            case 7:
                fprintf(archivoAssembler,"JMP %s\n\n", vector_tercetos[i].atr2);// salto incondicional
                break;
		}
		
		
	}
}
