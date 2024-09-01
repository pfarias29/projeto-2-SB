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

; Zera registradores usados para conversão
    xor  eax, eax        ; Zera EAX para armazenar o resultado
    xor  ebx, ebx        ; Zera EBX para usar como multiplicador de 10
    lea  esi, [buffer]   ; Aponta para o início do buffer

; Verifica se o número é negativo
    mov  bl, [esi]       ; Carrega o primeiro caractere
    cmp  bl, '-'         ; Verifica se é um sinal de menos
    jne  continue_conversion ; Se não for, continua a conversão normal

; Se for um sinal de menos, prepara para número negativo
    inc  esi             ; Pula o caractere '-'
    mov  ecx, 1          ; Marca que o número é negativo
    jmp  start_conversion

continue_conversion:
    xor  ecx, ecx        ; Marca que o número é positivo

start_conversion:
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
    test ecx, ecx        ; Verifica se o número era negativo
    jz   store_result    ; Se não era, pula a inversão de sinal
    neg  eax             ; Inverte o sinal de EAX para tornar o número negativo

store_result:
    mov  [res], eax      ; Armazena o número convertido em res ([ebp + 4])

; Printa a mensagem de quantos bytes foram lidos
    mov  eax, 4
    mov  ebx, 1
    mov  ecx, msg_1
    mov  edx, size_1
    int  80h

    pop  eax             ; Recupera a quantidade de bytes lidos
    add  eax, '0'        ; Converte o número de bytes para caractere ASCII

    mov  ecx, eax        ; Prepara o caractere ASCII para impressão
    mov  eax, 4
    mov  ebx, 1
    mov  edx, 1          ; O caractere é de 1 byte
    int  80h

; Printa a mensagem final " byte(s)"
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
