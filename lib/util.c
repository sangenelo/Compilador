#include "util.h"

void replace_char(char* str, char find, char replace){
	char *current_pos = strchr(str,find);
	while (current_pos){
		*current_pos = replace;
		current_pos = strchr(current_pos,find);
	}
}

void quitarCaracter(char* cadena, char caracter) {
	int i = 0;
	while(i<strlen(cadena)) {
        if(cadena[i+1] != caracter)
		    cadena[i] = cadena[i+1];
		i++;
	}
	cadena[i] = '\0';
}

void removeChar(char *str, char garbage) {
    char *src, *dst;
    for (src = dst = str; *src != '\0'; src++) {
        *dst = *src;
        if (*dst != garbage) dst++;
    }
    *dst = '\0';
}