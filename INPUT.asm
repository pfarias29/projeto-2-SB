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
    mov  byte [buffer + eax], 0         ; Substitui '\n' por terminador null
skip_adjustment:

    push eax            ; Guarda na pilha a quantidade de bytes lidos

; Converte a string em um número
    xor  eax, eax        ; Zera EAX para armazenar o resultado
    xor  ebx, ebx        ; Zera EBX para usar como multiplicador de 10
    lea  esi, [buffer]   ; Aponta para o início do buffer

convert_to_number:
    mov  bl, [esi]       ; Carrega o próximo caractere
    test bl, bl          ; Verifica se é o terminador null
    jz   done_conversion ; Se for, termina a conversão

    sub  bl, '0'         ; Converte o caractere ASCII para um valor numérico
    imul eax, eax, 10    ; Multiplica o valor atual em EAX por 10
    add  eax, ebx        ; Adiciona o novo dígito ao valor em EAX

    inc  esi             ; Avança para o próximo caractere
    jmp  convert_to_number ; Repete para o próximo dígito

done_conversion:
    mov  [res], eax      ; Armazena o número convertido em res ([ebp + 4])

; Calcula o comprimento da string para impressão
    lea  eax, [char_buffer + 10]  ; Carrega o endereço final do buffer
    sub  eax, edi                 ; Subtrai o ponteiro atual para obter o tamanho
    mov  edx, eax                 ; Armazena o comprimento em EDX

; Printa a mensagem
    mov  eax, 4
    mov  ebx, 1
    mov  ecx, msg_1
    mov  edx, size_1
    int  80h

; Printa o número convertido
    lea  ecx, [edi]
    mov  edx, eax                 ; Usa o valor calculado anteriormente
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
