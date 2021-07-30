%{
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include "y.tab.h"
#include "lib/tsimbolos.h"
#include "lib\util.c"

FILE *yyin;
char *yyltext;

int yyerrorl(void);
int yyerrorm(char*);
void validarString(char*);
void validarFloat(double);
void validarInt(int);
%}

%option noyywrap
%option yylineno

DIGITO [0-9]
LETRA [a-zA-Z]
COM_INI "-/"
COM_FIN "/-"

COMENTARIO {COM_INI}.*{COM_FIN}
ID {LETRA}({LETRA}|{DIGITO})*
CTE_CADENA \"([^\"\\\\]|\\\\.)*\"
CTE_ENTERA {DIGITO}+
CTE_FLOTANTE {DIGITO}+\.{DIGITO}*|\.{DIGITO}+
OP_ASIG "="
OP_TIPO ":"
OP_SUMA "+"
OP_RESTA "-"
OP_MULT "*"
OP_DIV "/"
PAR_OPEN "("
PAR_CLOSE ")"
COR_OPEN "["
COR_CLOSE "]"
COMP_MENOI "<="
COMP_MEN "<"
COMP_MAYOI ">="
COMP_MAY ">"
COMP_IGU "=="
COMP_DIS "!="
COMA ","

%%


"DECVAR" {return DECVAR;}
"ENDDEC" {return ENDDEC;}

"WRITE" {return WRITE;}
"READ" {return READ;}

"AND" {return AND;}
"OR" {return OR;}
"NOT" {return NOT;}

"INTEGER" {
            yylval.tipo_string = yytext;
            return INTEGER;
        }
"FLOAT"   {
            yylval.tipo_string = yytext;
            return FLOAT;
        }
"STRING"  {
            yylval.tipo_string = yytext;
            return STRING;
        }

"IF" {return IF;}
"ELSE" {return ELSE;}
"ENDIF" {return ENDIF;}

"WHILE" {return WHILE;}
"IN" {return IN;}
"DO" {return DO;}
"ENDWHILE" {return ENDWHILE;}

{CTE_ENTERA}       { 
            yylval.tipo_int = atoi(yytext);
            validarInt(yylval.tipo_int);
            insertarEnTablaDeSimbolos(yytext, "CTE_ENTERA", "", yylval.tipo_int, 0);
            return CTE_ENTERA;
            }
{CTE_FLOTANTE}  {
            yylval.tipo_double = atof(yytext);
            validarFloat(yylval.tipo_double);
            insertarEnTablaDeSimbolos(yytext, "CTE_FLOTANTE", "", 0, yylval.tipo_double);
            return CTE_FLOTANTE;
            }
{CTE_CADENA} {
            yylval.tipo_string = yytext;
            char aux[strlen(yytext)];
            strcpy(aux,yytext);
            validarString(yylval.tipo_string);
            insertarEnTablaDeSimbolos(yylval.tipo_string, "CTE_CADENA", aux, 0, 0);
            return CTE_CADENA;
            }
{ID}        {
                yylval.tipo_string = yytext;
                return ID;
            }	

{OP_ASIG} {return OP_ASIG;}
{OP_TIPO} {return OP_TIPO;}
{OP_SUMA} {return OP_SUMA;}
{OP_RESTA} {return OP_RESTA;}
{OP_DIV} {return OP_DIV;}
{OP_MULT} {return OP_MULT;}
{PAR_OPEN} {return PAR_OPEN;}
{PAR_CLOSE} {return PAR_CLOSE;}
{COR_OPEN} {return COR_OPEN;}
{COR_CLOSE} {return COR_CLOSE;}
{COMP_MENOI} {return COMP_MENOI;}
{COMP_MEN} {return COMP_MEN;}
{COMP_MAYOI} {return COMP_MAYOI;}
{COMP_MAY} {return COMP_MAY;}
{COMP_IGU} {return COMP_IGU;}
{COMP_DIS} {return COMP_DIS;}
{COMA} {return COMA;}
{COMENTARIO}

"\n"
"\t"
"\n\t"
"\r\n"
" "
";"
. yyerrorl();
%%

int yyerrorl(void) {
    printf("Error lexico: Caracter invalido: %s", yytext);
    exit(1);
}

int yyerrorm(char* mensaje) {
    printf("\n%s\n", mensaje);
    exit(1);
}

void validarString(char *cadena)
{
    int largo = strlen(cadena);
    if(largo > 33)
    {
        yyerrorm("Error: Rango de String excedido. Se permite un maximo de 32 caracteres");
    }
}

void validarFloat(double numero)
{   
    double max = 3.402823 * pow(10, 38);
    double min = 1.175494 * pow(10, -38);
    if(numero > max || (numero > 0 && numero < min))
    {
        yyerrorm("Error: Rango de Float excedido. Se permite entre [1.175494*10^-38; 3.402823*10^38] o cero.\n");
    }
}

void validarInt(int numero)
{
    if(numero > 65535)
    {
        yyerrorm("Error: Valor de Integer excedido, el mayor posible es 65535");
    }
}
