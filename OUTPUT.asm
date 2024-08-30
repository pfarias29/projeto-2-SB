    section .data

msg_1       db "Foram escritos ", 0
size_1      EQU $ - msg_1
msg_2       db " byte(s)", 0xA
size_2      EQU $ - msg_2


%define     res [ebp + 4]   ;parâmetro da função para pegar o número

global output

    section .text
output:

;guarda registradores a serem usados
    push ebp
    mov  ebp, esp

    push ebx
    push ecx
    push edx

    mov  ecx, 0
    mov  eax, [res]     ;eax recebe o número a ser transformado em string

div_num:

    cdq                 ;edx recebe o sinal extendido de eax
    div  10             ;quociente = eax, resto = edx

    add  edx, 0x30
    mov  [res + ecx], edx
    
    inc  ecx

    cmp  eax, 0         ;faz eax - 0, se for 0 são iguais, se não, eax != 0
    jne  div_num

    inc  ecx            ;as linhas seguintes colocam o 0 no final da string
    mov  [res + ecx], 0

    ;printar o número em string

    mov  eax, 4
    mov  ebx, 1
    mov  edx, ecx       ;ecx era o contador e está com a quantidade de bytes
    mov  ecx, res
    int  80h


    ;printar quantos bytes foram escritos

    push eax           ;coloca a quantidade de bytes escritos na pilha

    mov  eax, 4
    mov  ebx, 1
    mov  ecx, msg_1
    mov  edx, size_1
    int  80h

    mov  edx, [esp]
    mov  ecx, edx
    add  ecx, 0x30      ;transforma o tamanho em string
    mov  [ecx + 1], 0

    mov  eax, 4
    mov  ebx, 1
    int  80h
    
    mov  eax, 4
    mov  ebx, 1
    mov  ecx, msg_2
    mov  edx, size_2
    int  80h


    pop  eax
    pop  edx
    pop  ecx
    pop  ebx
    pop  ebp
    ret