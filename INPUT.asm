    section .data

msg_1       db "Foram lidos ", 0
size_1      EQU $ - msg_1
msg_2       db " byte(s)", 0xA
size_2      EQU $ - msg_2

global _start
global input

    section .bss

response    resb 4

    section .text

_start:

input:

;guarda registradores a serem usados
    push ebp
    mov  ebp, esp

    push ebx
    push ecx
    push edx

;recebe entrada do número
    mov  eax, 3
    mov  ebx, 0
    mov  ecx, response
    mov  edx, 4
    int  80h

    push eax    ;aqui guarda na pilha a quantidade de bytes lidos

;printa quantos bytes foram lidos
    mov  eax, 4
    mov  ebx, 1
    mov  ecx, msg_1
    mov  edx, size_1
    int  80h

    pop  edx    ;aqui recebe a quantidade de bytes lidos

    mov  eax, 4
    mov  ebx, 1
    mov  ecx, response
    int  80h

    mov  eax, 4
    mov  ebx, 1
    mov  ecx, msg_2
    mov  edx, size_2
    int  80h

;transforma o número bara binário








    pop  edx
    pop  ecx
    pop  ebx
    pop  ebp
    ret         ;coloca ret 12? acho que não


