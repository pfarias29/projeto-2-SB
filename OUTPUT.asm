section .data

msg_1       db "Foram escritos ", 0
size_1      EQU $ - msg_1
msg_2       db " byte(s)", 0xA
size_2      EQU $ - msg_2

%define     res [ebp + 8]  ; O número a ser convertido está no parâmetro 1 da função

global output

section .text
output:

; Guarda os registradores a serem usados
    push ebp
    mov  ebp, esp

    push ebx
    push ecx
    push edx

; Prepara para conversão do número em string
    mov  ecx, 0                ; Contador de bytes
    mov  eax, [ebp + 8]        ; Recebe o número a ser transformado em string (res)
    mov  esi, res              ; Aponta para o buffer onde a string será armazenada

; Trata caso especial para 0
    cmp  eax, 0
    je   handle_zero

convert_to_string:
    cdq                       ; EDX:EAX = EAX (divisão de 32 bits)
    mov  esi, 10              ; Divisor
    div  esi                  ; EAX dividido por 10, EDX = resto
    add  edx, '0'             ; Converte o resto para caractere ASCII
    mov  [esi + ecx], dl      ; Armazena o dígito no buffer
    inc  ecx                  ; Incrementa o contador
    test eax, eax             ; Verifica se EAX é 0
    jnz  convert_to_string    ; Se não for, continua a conversão

    jmp  done_conversion      ; Pular o tratamento especial para zero

handle_zero:
    mov  byte [esi], '0'      ; Se o número é 0, escreve '0' no buffer
    inc  ecx                  ; Atualiza o contador

done_conversion:
    mov  byte [esi + ecx], 0  ; Adiciona terminador null ao final da string
    mov  edx, ecx             ; O tamanho da string está em ECX

; Imprime o número em string
    mov  eax, 4
    mov  ebx, 1
    mov  ecx, esi             ; Buffer com a string do número
    int  80h

; Imprime a mensagem "Foram escritos"
    mov  eax, 4
    mov  ebx, 1
    mov  ecx, msg_1
    mov  edx, size_1
    int  80h

; Imprime a quantidade de bytes escritos
    mov  eax, 4
    mov  ebx, 1
    mov  ecx, [ebp + 8]       ; Número de bytes a ser impresso
    add  ecx, '0'             ; Converte para caractere ASCII
    mov  [esi + edx], cl      ; Adiciona o número de bytes ao final da string
    mov  byte [esi + edx + 1], 0  ; Adiciona terminador null
    mov  edx, ecx             ; Atualiza o tamanho da string para incluir o número de bytes

    mov  eax, 4
    mov  ebx, 1
    mov  ecx, esi
    int  80h

; Imprime a mensagem "byte(s)"
    mov  eax, 4
    mov  ebx, 1
    mov  ecx, msg_2
    mov  edx, size_2
    int  80h

; Restaura os registradores e sai da função
    pop  edx
    pop  ecx
    pop  ebx
    mov  esp, ebp
    pop  ebp
    ret
