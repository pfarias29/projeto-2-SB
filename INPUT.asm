section .data
msg_1       db "Foram lidos ", 0
size_1      EQU $ - msg_1
msg_2       db " byte(s)", 0xA
size_2      EQU $ - msg_2
buffer      db 4 dup(0)         ; Buffer para armazenar os caracteres lidos (máx 4 bytes)
char_buffer db 11 dup(0)        ; Buffer para armazenar até 10 dígitos mais o terminador null
neg_msg     db "-", 0           ; Mensagem para números negativos

%define     res [ebp + 8]       ; Parâmetro da função para devolver o número

global input

section .text
input:

; Guarda registradores a serem usados
    push ebp
    mov  ebp, esp

    push ebx
    push ecx
    push edx
    push edi
    push esi

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

; Checa se o número é negativo
    mov  esi, buffer
    mov  bl, [esi]      ; Carrega o primeiro caractere
    cmp  bl, '-'        ; Verifica se é um sinal de menos
    jne  positive_number ; Se não for, continua normalmente

; Trata número negativo
    inc  esi            ; Avança para o próximo caractere, ignorando o sinal
    mov  ecx, 1         ; Marca que o número é negativo
    jmp  convert_to_number

positive_number:
    xor  ecx, ecx       ; Zera o sinal, ou seja, o número é positivo

; Converte a string em um número
convert_to_number:
    xor  eax, eax        ; Zera EAX para armazenar o resultado
    xor  ebx, ebx        ; Zera EBX para usar como multiplicador de 10

convert_loop:
    mov  bl, [esi]       ; Carrega o próximo caractere
    test bl, bl          ; Verifica se é o terminador null
    jz   done_conversion ; Se for, termina a conversão

    sub  bl, 0x30        ; Converte o caractere ASCII para um valor numérico
    imul eax, eax, 10    ; Multiplica o valor atual em EAX por 10
    add  eax, ebx        ; Adiciona o novo dígito ao valor em EAX

    inc  esi             ; Avança para o próximo caractere
    jmp  convert_loop    ; Repete para o próximo dígito

done_conversion:
    cmp  ecx, 0          ; Verifica se o número é negativo
    je   store_result    ; Se não for, pula para armazenar o resultado
    neg  eax             ; Caso contrário, torna o número negativo

store_result:
    mov  res, eax      ; Armazena o número convertido em res ([ebp + 4])

; Transforma a quantidade de bytes lidos em string
    mov  eax, [esp]                 ; eax recebe o número de bytes lidos na pilha
    lea  edi, [char_buffer + 10]    ; edi aponta para o final do buffer
    mov  byte [edi], 0              ; Adiciona o terminador nulo

convert_to_string:
    mov  edx, 0
    mov  ebx, 10
    div  ebx            ; Divide eax por 10; eax = quociente; edx = resto
    add  dl, 0x30
    dec  edi            ; Move para o próximo espaço no buffer
    mov  [edi], dl
    test eax, eax      ; Se for nulo, acabou
    jnz  convert_to_string


; Printa a mensagem
    mov  eax, 4
    mov  ebx, 1
    mov  ecx, msg_1
    mov  edx, size_1
    int  80h

; Calcula o tamanho da string
    lea  eax, [char_buffer + 10]
    sub  eax, edi
    mov  edx, eax
    
print_number:
    lea  ecx, [edi]
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

    pop  eax
    pop  esi
    pop  edi
    pop  edx
    pop  ecx
    pop  ebx
    pop  ebp
    ret
