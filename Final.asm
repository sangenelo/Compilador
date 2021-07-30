include macros2.asm
include number.asm
.MODEL LARGE
.386
.STACK 200h

.DATA
numero dd ?
numero2 dd ?
numero3 dd ?
centena dd ?
saldo dd ?
bandera dd ?
suma dd ?
deudor dd ?
flotante dd ?
pi dd ?
uncuarto dd ?
cadena dd ?
teclado dd ?
mensaje dd ?
texto dd ?
_2_5 dd 2.5
_3_14 dd 3.14
_0_25 dd 0.25
_Ingrese_el_saldo db "Ingrese el saldo" , '$', 18 dup (?)
_100 dd 100.0
_2 dd 2.0
@aux32 dd ?
@aux33 dd ?
_10 dd 10.0
_Saldo_casi_en_0 db "Saldo casi en 0" , '$', 17 dup (?)
_1 dd 1.0
_0 dd 0.0
_1000 dd 1000.0
_Le_queda_poco_saldo db "Le queda poco saldo" , '$', 21 dup (?)
_101 dd 101.0
@aux66 dd ?
_Entraste_a_un_bucle db "Entraste a un bucle" , '$', 21 dup (?)
@aux85 dd ?
_3 dd 3.0
@aux120 dd ?
_Estas_en_otro_bucle db "Estas en otro bucle" , '$', 21 dup (?)
_5 dd 5.0
@aux140 dd ?
@aux145 dd ?
@aux147 dd ?
_15 dd 15.0
@aux153 dd ?
_8 dd 8.0
@aux158 dd ?
_ENTRASTE_a_un_IF_anidado db "ENTRASTE a un IF anidado" , '$', 26 dup (?)
_9999 dd 9999.0
_6000 dd 6000.0
_Suma_Ingrese_operando_1 db "Suma: Ingrese operando 1" , '$', 26 dup (?)
_Suma_Ingrese_operando_2 db "Suma: Ingrese operando 2" , '$', 26 dup (?)
@aux191 dd ?
_Resultado_cuenta db "Resultado cuenta" , '$', 18 dup (?)
@aux204 dd ?
@aux205 dd ?
@aux dd ?

.CODE

START:

MOV AX,@DATA
MOV DS, AX
MOV ES, AX

fld _2.5
fstp @aux
fld @aux
fstp flotante
fld _3.14
fstp @aux
fld @aux
fstp pi
fld _0.25
fstp @aux
fld @aux
fstp uncuarto
mov dx,OFFSET _Ingrese_el_saldo
mov ah,9
int 21h
newline 1

GetFloat saldo 

fld _100
fstp @aux
fld @aux
fstp centena
fld saldo
fld _2
fmul
fstp @aux32
fld centena
fld @aux32
fadd
fstp @aux33
fld @aux33
fstp @aux
fld @aux
fstp numero
fld @aux
fstp numero2
fld @aux
fstp numero3
fld saldo
fld _10
fxch
fcomp
fstsw ax
sahf
JA etiqueta_46

mov dx,OFFSET _Saldo_casi_en_0
mov ah,9
int 21h
newline 1

fld _1
fstp @aux
fld @aux
fstp bandera

etiqueta_46:
fld saldo
fld _0
fxch
fcomp
fstsw ax
sahf
JNA etiqueta_55

fld saldo
fld _1000
fxch
fcomp
fstsw ax
sahf
JAE etiqueta_55

mov dx,OFFSET _Le_queda_poco_saldo
mov ah,9
int 21h
newline 1


etiqueta_55:
fld _100
fstp @aux
fld @aux
fstp suma
fld _100
fstp @aux
fld @aux
fstp numero
fld _101
fstp @aux
fld @aux
fstp numero2
fld numero2
fld _1
fadd
fstp @aux66
fld @aux66
fstp @aux
fld @aux
fstp numero3

etiqueta_69:
fld suma
fld saldo
fxch
fcomp
fstsw ax
sahf
JNE etiqueta_73

JMP etiqueta_82


etiqueta_73:
fld suma
fld numero
fxch
fcomp
fstsw ax
sahf
JNE etiqueta_76

JMP etiqueta_82


etiqueta_76:
fld suma
fld numero2
fxch
fcomp
fstsw ax
sahf
JNE etiqueta_79

JMP etiqueta_82


etiqueta_79:
fld suma
fld numero3
fxch
fcomp
fstsw ax
sahf
JNE etiqueta_89

JMP etiqueta_82


etiqueta_82:
mov dx,OFFSET _Entraste_a_un_bucle
mov ah,9
int 21h
newline 1

fld suma
fld _1
fadd
fstp @aux85
fld @aux85
fstp @aux
fld @aux
fstp suma
JMP etiqueta_69


etiqueta_89:
fld _1
fstp @aux
fld @aux
fstp suma
fld _1
fstp @aux
fld @aux
fstp numero
fld _2
fstp @aux
fld @aux
fstp numero2
fld _3
fstp @aux
fld @aux
fstp numero3

etiqueta_101:
fld suma
fld numero
fxch
fcomp
fstsw ax
sahf
JNE etiqueta_105

JMP etiqueta_123


etiqueta_105:
fld suma
fld numero2
fxch
fcomp
fstsw ax
sahf
JNE etiqueta_108

JMP etiqueta_123


etiqueta_108:
fld suma
fld numero3
fxch
fcomp
fstsw ax
sahf
JNE etiqueta_126

JMP etiqueta_123


etiqueta_111:
fld suma
fld numero
fxch
fcomp
fstsw ax
sahf
JNE etiqueta_115

JMP etiqueta_139


etiqueta_115:
fld suma
fld numero2
fxch
fcomp
fstsw ax
sahf
JNE etiqueta_125

JMP etiqueta_139

fld suma
fld _1
fadd
fstp @aux120
fld @aux120
fstp @aux
fld @aux
fstp suma

etiqueta_123:
mov dx,OFFSET _Estas_en_otro_bucle
mov ah,9
int 21h
newline 1

JMP etiqueta_111


etiqueta_125:
JMP etiqueta_101


etiqueta_126:
fld _10
fstp @aux
fld @aux
fstp numero
fld _10
fstp @aux
fld @aux
fstp numero2
fld _5
fstp @aux
fld @aux
fstp numero3
fld _10
fstp @aux
fld @aux
fstp suma

etiqueta_139:
fld _10
fld _1
fadd
fstp @aux140
fld @aux140
fstp @aux
fld @aux
fstp centena
fld _10
fld _1
fadd
fstp @aux145
fld @aux145
fld _1
fadd
fstp @aux147
fld @aux147
fstp @aux
fld @aux
fstp saldo
fld numero2
fld _1
fsub
fstp @aux153
fld _15
fld @aux153
fxch
fcomp
fstsw ax
sahf
JNA etiqueta_163

fld numero
fld _8
fsub
fstp @aux158
fld @aux158
fld numero3
fxch
fcomp
fstsw ax
sahf
JA etiqueta_163

mov dx,OFFSET _ENTRASTE_a_un_IF_anidado
mov ah,9
int 21h
newline 1


etiqueta_163:
fld saldo
fld _1000
fxch
fcomp
fstsw ax
sahf
JNA etiqueta_171

fld _1
fstp @aux
fld @aux
fstp bandera
JMP etiqueta_185


etiqueta_171:
fld saldo
fld _9999
fxch
fcomp
fstsw ax
sahf
JA etiqueta_179

fld _6000
fstp @aux
fld @aux
fstp saldo
JMP etiqueta_182


etiqueta_179:
fld _0
fstp @aux
fld @aux
fstp bandera

etiqueta_182:
fld _0
fstp @aux
fld @aux
fstp saldo

etiqueta_185:
mov dx,OFFSET _Suma_Ingrese_operando_1
mov ah,9
int 21h
newline 1

GetFloat numero 

mov dx,OFFSET _Suma_Ingrese_operando_2
mov ah,9
int 21h
newline 1

GetFloat numero2 

fld numero
fld numero2
fadd
fstp @aux191
fld @aux191
fstp @aux
fld @aux
fstp numero3
mov dx,OFFSET _Resultado_cuenta
mov ah,9
int 21h
newline 1

DisplayFloat numero3,1 

fld _1
fstp @aux
fld @aux
fstp numero
fld @aux
fstp numero2
fld @aux
fstp numero3
fld _1
fld saldo
fmul
fstp @aux204
fld suma
fld @aux204
fadd
fstp @aux205
fld @aux205
fstp @aux
fld @aux
fstp numero
fld @aux
fstp numero2
fld @aux
fstp numero3
MOV EAX, 4C00h
INT 21h

END START
