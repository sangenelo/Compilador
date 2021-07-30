flex Lexico.l
bison -dyv Sintactico.y
gcc lex.yy.c y.tab.c -o compilador
gcc lex.yy.c y.tab.c -o Final.exe
Final.exe prueba.txt
del lex.yy.c y.tab.c y.tab.h y.output compilador.exe Final.exe
pause

