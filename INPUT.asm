    section .data

msg_1       db "Foram lidos ", 0
size_1      EQU $ - msg_1
msg_2       db " byte(s)", 0xA
size_2      EQU $ - msg_2

%define     res [ebp + 4]   ;parâmetro da função para devolver o número

global _start
global input

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
    mov  ecx, res
    mov  edx, 4
    int  80h

    push eax            ;aqui guarda na pilha a quantidade de bytes lidos

;printa quantos bytes foram lidos
    mov  eax, 4
    mov  ebx, 1
    mov  ecx, msg_1
    mov  edx, size_1
    int  80h

    mov  edx, [esp]     ;aqui recebe a quantidade de bytes lidos
    mov  ecx, edx
    add  ecx, 0x30
    mov  [ecx + 1], 0

    mov  eax, 4
    mov  ebx, 1
    int  80h

    mov  eax, 4
    mov  ebx, 1
    mov  ecx, msg_2
    mov  edx, size_2
    int  80h

;transforma o número bara binário
    mov  ecx, [esp]        ;ecx recebe a quantidade de bytes lidos para fazer um loop
    mov  ebx, 0

parse_int:

    mov  al, [res + ebx]
    sub  al, 0x30
    mov  [res + ebx], al

    inc  ebx
    loop parse_int

    pop  eax               ; eax recebe a quantidade de bytes lidos para retornar a função

    pop  edx
    pop  ecx
    pop  ebx
    pop  ebp
    ret