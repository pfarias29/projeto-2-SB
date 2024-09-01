section .data

msg_1       db "Foram lidos ", 0
size_1      EQU $ - msg_1
msg_2       db " byte(s)", 0xA
size_2      EQU $ - msg_2
buffer      db 4 dup(0)         ; Buffer para armazenar os caracteres lidos (máx 4 bytes)
char_buffer db 11 dup(0)        ; Buffer para armazenar até 10 dígitos mais o terminador null

%define     res [ebp + 4]       ; Parâmetro da função para devolver o número

global input

section .text

input:

; Guarda registradores a serem usados
    push ebp
    mov  ebp, esp

    push ebx
    push ecx
    push edx

; Recebe entrada do número
    mov  eax, 3
    mov  ebx, 0
    lea  ecx, [buffer]          ; Aloca o buffer para a entrada
    mov  edx, 4                 ; Lê até 4 bytes
    int  80h

    cmp  byte [buffer + eax - 1], 0x0A  ; Verifica se o último byte é '\n'
    jne  skip_adjustment                ; Se não for, pula o ajuste
    dec  eax                            ; Subtrai 1 byte da contagem
skip_adjustment:

    push eax            ; Guarda na pilha a quantidade de bytes lidos

; Converte o número de bytes lidos para string
    mov  eax, [esp]     ; Carrega o número de bytes lidos
    lea  edi, [char_buffer + 10] ; Aponta para o final do buffer
    mov  byte [edi], 0  ; Adiciona terminador null

convert_to_string:
    mov  edx, 0
    mov  ebx, 10
    div  ebx            ; Divide EAX por 10, EAX = quociente, EDX = resto
    add  dl, '0'        ; Converte o resto para caractere ASCII
    dec  edi            ; Move para o próximo espaço no buffer
    mov  [edi], dl      ; Armazena o caractere
    test eax, eax       ; Verifica se o quociente é 0
    jnz  convert_to_string

; Printa a mensagem
    mov  eax, 4
    mov  ebx, 1
    mov  ecx, msg_1
    mov  edx, size_1
    int  80h

; Printa o número convertido
    lea  ecx, [edi]
    mov  edx, char_buffer + 10 - edi
    mov  eax, 4
    mov  ebx, 1
    int  80h

; Printa a mensagem final
    mov  eax, 4
    mov  ebx, 1
    mov  ecx, msg_2
    mov  edx, size_2
    int  80h

; Restaura registradores e sai da função
    pop  edx
    pop  ecx
    pop  ebx
    mov  esp, ebp
    pop  ebp
    ret
