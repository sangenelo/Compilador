#ifndef ASSEMBLER_H
#define ASSEMBLER_H

static int aux_tiponumerico=0;

void generarAssembler();
void escribir_seccion_datos(FILE*);
void escribir_seccion_codigo(FILE*);

int esOperacion(int);
int esSalto(int);
void preparar_assembler();

#endif