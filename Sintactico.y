%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include "y.tab.h"
#include "lib/tercetos.c"
#include "lib/pila.c"
#include "lib/tsimbolos.c"
#include "lib/assembler.c"

int yystopparser = 0;

FILE *yyin;

int yyerror();
int yylex();
int yyerrorAsig(const char*);
void crearPilas();
bool esCompatible(const char*, const char*);
bool verificarListaAsignacion();
bool verificarOperandosAsignacion();

//Indices para tercetos
int Find = 0;
int Tind = 0;
int Eind = 0;
int Lind = 0;
int Auxind = 0;

//Indices en string
char FindString[3];
char TindString[3];
char EindString[3];
char LindString[3];
char AuxindString[3];

//Variable String para los itoa
char varItoa[30];
char varString[30];
char varID[30];
char varReal[30];

//Operacion
int isOR = 0;

//Pila
Pila pilaExpresion;
Pila pilaTermino;
Pila pilaFactor;
Pila pilaIf;
Pila pilaWhile;
Pila pilaLista;

//otros
int contadorIdsAsig=0;
int cantidadOperadores=0;
char arrayIDsAsig[50][32];
int cantidadIdsEnDeclaracion = 0;
int cantidadIdsEnDeclaracionTotal = 0;
int cotaInferiorCantidadIdsEnDeclaracion = 0;
int cantidadDeIdsEnListaDeExpresiones=0;
char arrayIdsDec[50][32];
char arrayIds[50][32];
char tipoDeVariable[50][32];
char elementosDeLista[50][32];
int cotaInferiorWhile = 0;
int cantExpr = -1;
char tipoDatoListaAsignacion[50];
char tipoDatoExpresionAsignacion[50];
char tipoDatoOperadores[50][32];
char arrayOperandosAsig [50][32];

//Auxiliar para ASM
char auxASM[10] = "@aux";
char indiceString[10];

%}

%union {
    int tipo_int;
    double tipo_double;
    char *tipo_string;
}

%token<tipo_string> ID
%token<tipo_string> INTEGER
%token<tipo_string> FLOAT
%token<tipo_string> STRING
%token<tipo_string> CTE_CADENA
%token<tipo_int> CTE_ENTERA
%token<tipo_double> CTE_FLOTANTE
%token DECVAR ENDDEC WRITE READ AND OR NOT IF ELSE ENDIF WHILE IN DO ENDWHILE OP_ASIG OP_TIPO PAR_OPEN PAR_CLOSE COR_OPEN
%token COR_CLOSE COMA

%token COMP_MENOI COMP_MEN COMP_MAYOI COMP_MAY COMP_IGU COMP_DIS
%left OP_SUMA OP_RESTA OP_DIV OP_MULT

%type<tipo_string> tipo_variable


%%
programa:
    sentencias {printf("Regla 1 -> Programa es: sentencias\nCOMPILACION EXITOSA\n");};
sentencias:
    sentencia {printf("Regla 2 -> sentencias es: sentencia\n");}
    | sentencias sentencia {printf("Regla 3 -> sentencias es: sentencias sentencia\n");}
    ;
sentencia:
    declaracion_tipos {printf("Regla 4 -> sentencia es: declaracion_tipos\n");}
    | asignacion {printf("Regla 5 -> sentencia es: asignacion\n");}
    | entrada {printf("Regla 6 -> sentencia es: entrada\n");}
    | salida {printf("Regla 7 -> sentencia es: salida\n");}
    | if {printf("Regla 8 -> sentencia es: if\n");}
    | while {printf("Regla 9 -> sentencia es: while\n");}
    ;
declaracion_tipos:
    DECVAR lista_declaracion_tipos ENDDEC   {
                                                for(int i = 0; i < cantidadIdsEnDeclaracionTotal; i++) {
                                                    insertarEnTablaDeSimbolos(arrayIds[i], tipoDeVariable[i], "CTE_STRING", 0, 0 );
                                                }
                                                printf("Regla 10 -> declaracion_tipos es: DECVAR Lista_declaracion_tipos ENDDEC\n");
                                            };
lista_declaracion_tipos:
    lista_declaraciones {printf("Regla 11 -> lista_declaracion_tipos es: lista_declaraciones\n");}; 
lista_declaraciones:
    lista_declaraciones declaracion {printf("Regla 12 -> lista_declaraciones es: lista_declaraciones declaracion\n");}
    | declaracion  {printf("Regla 13 -> lista_declaraciones es: declaracion\n");}
    ;
declaracion:
    lista_variables OP_TIPO tipo_variable   {
                                                int indice;
                                                for(indice=cotaInferiorCantidadIdsEnDeclaracion; indice<cantidadIdsEnDeclaracionTotal;indice++){
                                                    strcpy(tipoDeVariable[indice], $3);
                                                }
                                                cotaInferiorCantidadIdsEnDeclaracion=cantidadIdsEnDeclaracionTotal;
                                                int i;
                                                for(i=0; i<cantidadIdsEnDeclaracion;i++){
                                                    crear_terceto(":",arrayIdsDec[i],$3);
                                                }
                                                printf("Regla 14 -> declaracion es: lista_variables OP_TIPO tipo_variable\n");
                                               
                                            }
    ;
lista_variables:
    lista_variables COMA ID { 
            strcpy(arrayIdsDec[cantidadIdsEnDeclaracion], $3);
            strcpy(arrayIds[cantidadIdsEnDeclaracionTotal], $3);
            cantidadIdsEnDeclaracion++;
            cantidadIdsEnDeclaracionTotal++;
            printf("Regla 15 -> lista_variables es: lista_variables COMA ID\n");
           
            } 
    | ID { 
            cantidadIdsEnDeclaracion=0;
            strcpy(arrayIdsDec[cantidadIdsEnDeclaracion], $1);
            strcpy(arrayIds[cantidadIdsEnDeclaracionTotal], $1);
            cantidadIdsEnDeclaracion=1;
            cantidadIdsEnDeclaracionTotal++;
            printf("Regla 16 -> lista_variables es: ID\n");
            
            
         } 
    ;
tipo_variable:
    INTEGER {$<tipo_string>$ = $1; printf("Regla 17 -> tipo_variable es: INTEGER\n");}
    | FLOAT {$<tipo_string>$ = $1; printf("Regla 18 -> tipo_variable es: FLOAT\n");}
    | STRING {$<tipo_string>$ = $1; printf("Regla 19 -> tipo_variable es: STRING\n");}
    ;
asignacion:
    lista OP_ASIG expresion     {
                                    
                                    printf("Regla 20 -> asignacion es: lista OP_ASIG expresion\n");
                                    bool resultadoVerificacionLista=verificarListaAsignacion();
                                    if(!resultadoVerificacionLista){
                                        return false;
                                    }
                                    bool resultadoVerificacionExpresion=verificarOperandosAsignacion();
                                    if(!resultadoVerificacionExpresion){
                                        return false;
                                    }
                                    //printf("El tipo de dato de la lista es: %s\n",tipoDatoListaAsignacion);
                                    //printf("El tipo de dato de la expresion es: %s\n",tipoDatoExpresionAsignacion);
                                    if(!esCompatible(tipoDatoListaAsignacion,tipoDatoExpresionAsignacion)){
                                      printf("Error! :(  Se estan asignando tipos incompatibles.\n");
                                      return false;  
                                    }
                                    
                                    int auxEind= desapilar(&pilaExpresion);
                                    itoa(auxEind,EindString,10);
                                    crear_terceto("=","@aux",EindString);
                                    int i;
                                    for(i=0; i<contadorIdsAsig;i++){
                                        crear_terceto("=",arrayIDsAsig[i],"@aux");
                                    }
                                    cantidadOperadores=0;

                                }
    ;
lista:
    lista OP_ASIG ID    {
                            $3[strlen($3)-1] = '\0'; //Remuevo el ultimo caracter que se lee de mas
                            strcpy(arrayIDsAsig[contadorIdsAsig], $3);
                            contadorIdsAsig++;
                            printf("Regla 21 -> lista es: lista OP_ASIG ID\n");
                    
                        }
    | ID    {
                contadorIdsAsig=0;
                strcpy(arrayIDsAsig[contadorIdsAsig], $1);
                contadorIdsAsig=1;
                printf("Regla 22 -> lista es: ID\n");
            }
    ;
expresion:
    expresion OP_SUMA termino   {
                                    itoa(desapilar(&pilaExpresion),EindString,10);
                                    itoa(desapilar(&pilaTermino),TindString,10);
                                    Eind=crear_terceto("+",EindString,TindString);
                                    //Auxiliar
                                    itoa(Eind,indiceString,10);
                                    strcat(auxASM,indiceString);
                                    strcpy(vector_tercetos[Eind].res_aux,auxASM);
                                    insertarEnTablaDeSimbolos(auxASM,"auxCode","",0,0);
                                    strcpy(auxASM,"@aux");
                                    //--------------------
                                    apilar(&pilaExpresion,Eind);
                                    printf("Regla 23 -> expresion es:  expresion OP_SUMA termino\n");
                                }
    | expresion OP_RESTA termino    {
                                        itoa(desapilar(&pilaExpresion),EindString,10);
                                        itoa(desapilar(&pilaTermino),TindString,10);
                                        Eind=crear_terceto("-",EindString,TindString);
                                        //Auxiliar
                                        itoa(Eind,indiceString,10);
                                        strcat(auxASM,indiceString);
                                        strcpy(vector_tercetos[Eind].res_aux,auxASM);
                                        insertarEnTablaDeSimbolos(auxASM,"auxCode","",0,0);
                                        strcpy(auxASM,"@aux");
                                        //--------------------
                                        apilar(&pilaExpresion,Eind);
                                        printf("Regla 24 -> expresion es:  expresion OP_RESTA termino\n");
                                    }
    | termino   {
                    Eind=desapilar(&pilaTermino); 
                    apilar(&pilaExpresion,Eind) ;
                    printf("Regla 25 -> expresion es: termino\n");
                }
    ;
termino:
    termino OP_MULT factor  {
                                itoa(desapilar(&pilaTermino),TindString,10);
                                itoa(desapilar(&pilaFactor),FindString,10);
                                Tind=crear_terceto("*",TindString,FindString);
                                //Auxiliar
                                itoa(Tind,indiceString,10);
                                strcat(auxASM,indiceString);
                                strcpy(vector_tercetos[Tind].res_aux,auxASM);
                                insertarEnTablaDeSimbolos(auxASM,"auxCode","",0,0);
                                strcpy(auxASM,"@aux");
                                //---------
                                apilar(&pilaTermino,Tind) ;
                                printf("Regla 26 -> termino es: termino OP_MULT factor\n");
                            }
    | termino OP_DIV factor     {
                                    itoa(desapilar(&pilaTermino),TindString,10);
                                    itoa(desapilar(&pilaFactor),FindString,10);
                                    Tind=crear_terceto("/",TindString,FindString);
                                    //Auxiliar
                                    itoa(Tind,indiceString,10);
                                    strcat(auxASM,indiceString);
                                    strcpy(vector_tercetos[Tind].res_aux,auxASM);
                                    insertarEnTablaDeSimbolos(auxASM,"auxCode","",0,0);
                                    strcpy(auxASM,"@aux");
                                    //---------
                                    apilar(&pilaTermino,Tind) ;
                                    printf("Regla 27 -> termino es: termino OP_DIV factor\n");
                                }
    | factor    {
                    Tind = desapilar(&pilaFactor);
                    apilar(&pilaTermino,Tind) ;
                    printf("Regla 28 -> termino es: factor\n");
                }
    ;
factor:
    ID {
            printf("Regla 29 -> factor es: ID\n");
            char ultimoCaracter =$1[strlen($1)-1];
            if(ultimoCaracter == '+' || ultimoCaracter == '-' || ultimoCaracter == '*' || ultimoCaracter == '/'){
                $1[strlen($1)-1] = '\0'; //Remuevo el ultimo caracter que se lee de mas
            }
            Find = crear_terceto($1,"_","_");
            apilar(&pilaFactor,Find);
            t_nodo* lex = getLexema($1);
            char *tipo = lex->data.tipo;
            strcpy(tipoDatoOperadores[cantidadOperadores],tipo);
            cantidadOperadores++;
            
        }
    | constante {printf("Regla 30 -> factor es: constante\n");}
    ;
constante:
    CTE_ENTERA  {
                    itoa($1,varItoa,10);
                    strcpy(varString,"_");
                    strcat(varString, varItoa);
                    Find = crear_terceto(varString,"_","_");
                    apilar(&pilaFactor,Find);
                    strcpy(tipoDatoOperadores[cantidadOperadores],"INTEGER");
                    cantidadOperadores++;
                    printf("Regla 31 -> constante es: CTE_ENTERA\n");
                }
    | CTE_FLOTANTE  {
                        sprintf(varString,"%g",$1);
                        strcpy(varReal,"_");
                        strcat(varReal, varString);
                        Find = crear_terceto(varReal,"_","_");
                        apilar(&pilaFactor,Find);
                        strcpy(tipoDatoOperadores[cantidadOperadores],"FLOAT");
                        cantidadOperadores++;
                        printf("Regla 32 -> constante es: CTE_FLOTANTE\n");
                    }
    | CTE_CADENA    {
                        Find = crear_terceto($1,"_","_");
                        apilar(&pilaFactor,Find);
                        strcpy(varString,"_");
                        strcpy(tipoDatoOperadores[cantidadOperadores],"STRING");
                        cantidadOperadores++;
                        printf("Regla 33 -> constante es: CTE_CADENA\n");
                    }
    ;
entrada:
    READ ID     {
                    crear_terceto("READ",$2,"_");
                    printf("Regla 34 -> entrada es: READ ID\n");
                };
salida:
    WRITE valor     {
                        crear_terceto("WRITE",varID,"_");
                        printf("Regla 35 -> salida es: WRITE valor\n");
                    };
valor:
    ID  {
            strcpy(varID,$1);
            printf("Regla 36 -> valor es: ID\n");
        }
    | CTE_CADENA    {
                        strcpy(varID,$1);
                        printf("Regla 37 -> valor es: CTE_CADENA\n");
                    }
    ;
if:
    IF PAR_OPEN condicion_simple PAR_CLOSE sentencias {
                                        int bi=crear_terceto("JMP","_","_");
                                        char valorActual[4];
                                        int pivote=desapilar(&pilaIf);
                                        itoa(obtenerIndiceTercetos(),valorActual,10);
                                        strcpy(vector_tercetos[pivote].atr2,valorActual);
                                        apilar(&pilaIf,bi);
                                    } else ENDIF { printf("Regla 38 -> if es: IF PAR_OPEN condicion_simple PAR_CLOSE sentencias else ENDIF\n");}

    | IF PAR_OPEN condicion_simple PAR_CLOSE sentencias ENDIF {
                                        char valorActual[4];
                                        int pivote = desapilar(&pilaIf);
                                        itoa(obtenerIndiceTercetos(),valorActual,10);
                                        strcpy(vector_tercetos[pivote].atr2,valorActual);
                                        printf("Regla 39 -> if es: IF PAR_OPEN condicion_simple PAR_CLOSE sentencias ENDIF\n");
                                    } 
    |
    IF PAR_OPEN condicion PAR_CLOSE sentencias {
                                        int bi=crear_terceto("JMP","_","_");
                                        char valorActual[4];
                                        int pivote=desapilar(&pilaIf);
                                        int tercetoActual=obtenerIndiceTercetos();
                                        itoa(tercetoActual,valorActual,10);
                                        strcpy(vector_tercetos[pivote].atr2,valorActual);
                                        if(isOR == 1) {
                                            itoa(pivote+1,valorActual,10);
                                            isOR = 0;
                                        }
                                        pivote=desapilar(&pilaIf);
                                        strcpy(vector_tercetos[pivote].atr2,valorActual);
                                        apilar(&pilaIf,bi);
                                    } else ENDIF {printf("Regla 40 -> if es: IF PAR_OPEN condicion PAR_CLOSE sentencias else ENDIF\n");}

    | IF PAR_OPEN condicion PAR_CLOSE sentencias ENDIF  {
                                        char valorActual[4];
                                        int pivote = desapilar(&pilaIf);
                                        int tercetoActual=obtenerIndiceTercetos();
                                        itoa(tercetoActual,valorActual,10);
                                        strcpy(vector_tercetos[pivote].atr2,valorActual);
                                        if(isOR == 1) {
                                            itoa(pivote+1,valorActual,10);
                                            isOR = 0;
                                        }
                                        pivote=desapilar(&pilaIf);
                                        strcpy(vector_tercetos[pivote].atr2,valorActual);
                                        printf("Regla 41 -> if es: IF PAR_OPEN condicion PAR_CLOSE sentencias ENDIF\n");
                                    }
;

else:
    ELSE sentencias {   int pivote=desapilar(&pilaIf);
                            char valorActual[4];
                            itoa(obtenerIndiceTercetos(),valorActual,10);
                            strcpy(vector_tercetos[pivote].atr2,valorActual);
                            printf("Regla 42 -> else es:  ELSE sentencias\n");
                        }
;

condicion_simple:
            expresion COMP_MEN expresion {
                    char auxEind1[4];
                    itoa(desapilar(&pilaExpresion),auxEind1,10);
                    char auxEind2[4];
                    itoa(desapilar(&pilaExpresion),auxEind2,10);
                    crear_terceto("CMP",auxEind2,auxEind1);
                    int numTerceto=crear_terceto("JAE","_","_");
                    apilar(&pilaIf,numTerceto);
                    cantidadOperadores=0;
                    printf("Regla 43 -> condicion_simple es: expresion COMP_MEN expresion\n");}

        |
            expresion COMP_MAY expresion {
                    char auxEind1[4];
                    itoa(desapilar(&pilaExpresion),auxEind1,10);
                    char auxEind2[4];
                    itoa(desapilar(&pilaExpresion),auxEind2,10);
                    crear_terceto("CMP",auxEind2,auxEind1);
                    int numTerceto=crear_terceto("JNA","_","_");
                    apilar(&pilaIf,numTerceto);
                    cantidadOperadores=0;
                    printf("Regla 44 -> condicion_simple es: expresion COMP_MAY expresion\n");}
                    
        |   expresion COMP_MENOI expresion {
                    char auxEind1[4];
                    itoa(desapilar(&pilaExpresion),auxEind1,10);
                    char auxEind2[4];
                    itoa(desapilar(&pilaExpresion),auxEind2,10);
                    crear_terceto("CMP",auxEind2,auxEind1);
                    int numTerceto=crear_terceto("JA","_","_");
                    apilar(&pilaIf,numTerceto);
                    cantidadOperadores=0;
                    printf("Regla 45 -> condicion_simple es: expresion COMP_MENOI expresion\n");
        } 

        |   expresion COMP_MAYOI expresion {
                    char auxEind1[4];
                    itoa(desapilar(&pilaExpresion),auxEind1,10);
                    char auxEind2[4];
                    itoa(desapilar(&pilaExpresion),auxEind2,10);
                    crear_terceto("CMP",auxEind2,auxEind1);
                    int numTerceto=crear_terceto("JNAE","_","_");
                    apilar(&pilaIf,numTerceto);
                    cantidadOperadores=0;
                    printf("Regla 46 -> condicion_simple es: expresion COMP_MAYOI expresion\n");
        }

        |   expresion COMP_IGU expresion {
                    char auxEind1[4];
                    itoa(desapilar(&pilaExpresion),auxEind1,10);
                    char auxEind2[4];
                    itoa(desapilar(&pilaExpresion),auxEind2,10);
                    crear_terceto("CMP",auxEind2,auxEind1);
                    int numTerceto=crear_terceto("JNE","_","_");
                    apilar(&pilaIf,numTerceto);
                    cantidadOperadores=0;
                    printf("Regla 47 -> condicion_simple es: expresion COMP_IGU expresion\n");
        }

        |   expresion COMP_DIS expresion {
                    char auxEind1[4];
                    itoa(desapilar(&pilaExpresion),auxEind1,10);
                    char auxEind2[4];
                    itoa(desapilar(&pilaExpresion),auxEind2,10);
                    crear_terceto("CMP",auxEind2,auxEind1);
                    int numTerceto=crear_terceto("JE","_","_");
                    apilar(&pilaIf,numTerceto);
                    cantidadOperadores=0;
                    printf("Regla 48 -> condicion_simple es: expresion COMP_DIS expresion\n");
                          
        }     

        | NOT condicion_simple  { 
                                    /*Reescribo el terceto cambiando el comparador por su opuesto*/
                                    int pivote=desapilar(&pilaIf);
                                    char comparadorUtilizado[30];
                                    strcpy(comparadorUtilizado,vector_tercetos[pivote].atr1);
                                    char contarioDelComparador[5];
                                    if (strcmp(comparadorUtilizado, "JNAE") == 0) 
                                    {
                                    strcpy(contarioDelComparador,"JAE");
                                    } 
                                    else if (strcmp(comparadorUtilizado, "JNA") == 0)
                                    {
                                    strcpy(contarioDelComparador,"JA");
                                    }
                                    else if (strcmp(comparadorUtilizado, "JA") == 0)
                                    {
                                    strcpy(contarioDelComparador,"JNA");
                                    }
                                    else if (strcmp(comparadorUtilizado, "JAE") == 0)
                                    {
                                    strcpy(contarioDelComparador,"JNAE");
                                    }
                                    else if (strcmp(comparadorUtilizado, "JE") == 0)
                                    {
                                    strcpy(contarioDelComparador,"JNE");
                                    }
                                    else if (strcmp(comparadorUtilizado, "JNE") == 0)
                                    {
                                    strcpy(contarioDelComparador,"JE");
                                    }
                                    strcpy(vector_tercetos[pivote].atr1,contarioDelComparador);
                                    apilar(&pilaIf,pivote);
                                    printf("Regla 49 -> condicion_simple es: NOT condicion_simple\n"); 
                                }
;

condicion:
    condicion_simple AND condicion_simple { printf("Regla 50 -> condicion es: condicion_simple AND condicion_simple\n");}
    | condicion_simple OR {
            int num = crear_terceto("JMP","_","_");
            char valorActual[4];
            int pivote = desapilar(&pilaIf);
            int tercetoActual=obtenerIndiceTercetos();
            itoa(tercetoActual,valorActual,10);
            strcpy(vector_tercetos[pivote].atr2,valorActual);
            isOR = 1;
            apilar(&pilaIf, num);
        } condicion_simple { printf("Regla 51 -> condicion es: condicion_simple OR condicion_simple\n");}
;
while:
    WHILE   {
                apilar(&pilaWhile,obtenerIndiceTercetos());
                crear_terceto("ET","_","_");
            } 
    var IN COR_OPEN lista_de_expresiones COR_CLOSE {
                
                int indiceTercetoActual;
                int sigTerceto;
                int cantLineas=cantidadDeIdsEnListaDeExpresiones*3;
                
                int comienzoWhile=desapilar(&pilaWhile);
                int saltoFinal=comienzoWhile+cantLineas+1;
                char saltoFinalString[4];
                apilar(&pilaWhile,comienzoWhile);
                itoa(saltoFinal,saltoFinalString,10);
                int i;
                for(i = cotaInferiorWhile; i < cantidadDeIdsEnListaDeExpresiones-1; i++) {
                    indiceTercetoActual=crear_terceto("CMP",varID,elementosDeLista[i]);
                    sigTerceto=indiceTercetoActual+3;
                    char valorActual[4];
                    itoa(sigTerceto,valorActual,10);
                    crear_terceto("JNE",valorActual,"_");
                    crear_terceto("JMP",saltoFinalString,"_");
                }
                crear_terceto("CMP",varID,elementosDeLista[i]);
                apilar(&pilaWhile,obtenerIndiceTercetos());
                crear_terceto("JNE","_","_");
                crear_terceto("JMP",saltoFinalString,"_");
                cotaInferiorWhile=cantidadDeIdsEnListaDeExpresiones;
            }
    
    DO sentencias ENDWHILE   {
                        int biInd = crear_terceto("JMP","_","_");
                        char valorActual[4];
                        int pivote=desapilar(&pilaIf);
                        itoa(obtenerIndiceTercetos(),valorActual,10);
                        strcpy(vector_tercetos[pivote].atr2,valorActual);

                        pivote=desapilar(&pilaWhile);
                        itoa(obtenerIndiceTercetos(),valorActual,10);
                        strcpy(vector_tercetos[pivote].atr2,valorActual);
                        
                        pivote=desapilar(&pilaWhile);
                        itoa(pivote,valorActual,10);
                        strcpy(vector_tercetos[biInd].atr2,valorActual);
                        
                        printf("Regla 52 -> while es: WHILE ID IN COR_OPEN lista_de_expresiones COR_CLOSE DO sentencias ENDWHILE\n");
                        
                        };
lista_de_expresiones:
    lista_de_expresiones COMA ID    {
                                        strcpy(elementosDeLista[cantidadDeIdsEnListaDeExpresiones], $3);
                                        cantidadDeIdsEnListaDeExpresiones++;
                                        printf("Regla 53 -> lista_de_expresiones es: lista_de_expresiones COMA ID\n");
                                    }
    | ID    {
                strcpy(elementosDeLista[cantidadDeIdsEnListaDeExpresiones], $1);
                cantidadDeIdsEnListaDeExpresiones++;
                printf("Regla 54 -> lista_de_expresiones es: ID\n");
            }
    ;
var:
    ID {strcpy(varID,$1);};

%%

int main(int argc, char *argv[]) {
    if((yyin = fopen(argv[1], "rt")) == NULL)
    {
        printf("\nNo se puede abrir el archivo de prueba: %s\n", argv[1]);
    }
    else {
        crearPilas();
        crearTablaSimbolos();
        yyparse();
        guardarTablaDeSimbolos();
        escribir_tercetos();
        generarAssembler();
        escribir_tercetosAssembler();
    }
    fclose(yyin);
    return 0;
}

int yyerror(void) {
    printf("Error sintactico \n");
    exit(1);
}



bool verificarListaAsignacion(){
    bool verificacion = true;
    t_nodo* lex = getLexema(arrayIDsAsig[0]);
    char *tipo = lex->data.tipo;
    //Comparo los siguientes ids y sus tipos con el tipo del primero
    for(int i=1;i<contadorIdsAsig;i++){
        lex = getLexema(arrayIDsAsig[i]);
        verificacion = esCompatible(tipo,lex->data.tipo);
        if(!verificacion){
           printf("Error! Se estan asignando IDs con tipos incompatibles.\n"); 
           return false;
        }
    }
    strcpy((char *)tipoDatoListaAsignacion,tipo);
    return true;
}

bool verificarOperandosAsignacion(){
    bool verificacion = true;
    //Comparo los siguientes ids y sus tipos con el tipo del primero
    for(int i=1;i<cantidadOperadores;i++){
        verificacion = esCompatible(tipoDatoOperadores[0],tipoDatoOperadores[i]);
        if(!verificacion){
           printf("Error! Se esta operando con operandos con tipos incompatibles.\n"); 
           return false;
        }
    }
    strcpy((char *)tipoDatoExpresionAsignacion,tipoDatoOperadores[0]);
    return true;
}

bool esCompatible(const char* tipo1, const char* tipo2)
{
    if(strcmp("INTEGER", tipo1) == 0){
        return (strcmp("INTEGER", tipo2) == 0 || strcmp("CTE_ENTERA", tipo2) == 0 );
    }
    else if(strcmp("FLOAT", tipo1) == 0){
        return (strcmp("FLOAT", tipo2) == 0 || strcmp("CTE_ENTERA", tipo2) == 0 || strcmp("CTE_FLOTANTE", tipo2) == 0 
        || strcmp("Integer", tipo2) == 0);
    }
    else if(strcmp("STRING", tipo1) == 0){
        return (strcmp("STRING", tipo2) == 0 || strcmp("CTE_CADENA", tipo2) == 0);
    }
}


void crearPilas() {
    pilaExpresion = crearPila();
    pilaTermino = crearPila();
    pilaFactor = crearPila();
    pilaIf = crearPila();
    pilaWhile = crearPila();
    pilaLista = crearPila();
}

int yyerrorAsig(const char* id) {
    printf("\nError: se hacen asignaciones de distinto tipo de datos para el id: %s", id);
    exit(1);
}


