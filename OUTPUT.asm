section .data
msg_1       db 0xA, "Foram escritos ", 0
size_1      EQU $ - msg_1
msg_2       db " byte(s)", 0xA
size_2      EQU $ - msg_2

buffer      db 20 dup(0)

global output

section .text

output:
    ; Guarda os registradores a serem usados
    push ebp
    mov  ebp, esp

    push ebx
    push ecx
    push edx
    push esi
    push edi

    ; Prepara para conversão do número em string
    mov ecx, 0                     ; Contador de bytes
    mov eax, [ebp + 8]             ; Recebe o número a ser transformado em string 
    mov esi, buffer                ; Aponta para o buffer onde a string será armazenada

    call output_number_to_string

    ; Imprime a string do número
    mov eax, 4
    mov ebx, 1
    mov ecx, esi                   ; Buffer com a string do número
    int 80h

    push eax

    ; Imprime a mensagem
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_1
    mov edx, size_1
    int 80h

    ; Converte o tamanho da string (em ecx) para ASCII
    pop  eax
    call output_number_to_string   ; Converte edx para string

    ; Imprime o número de bytes
    mov eax, 4
    mov ebx, 1
    mov ecx, esi                   ; Buffer com o número de bytes
    int 80h

    ; Imprime a segunda mensagem
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_2
    mov edx, size_2
    int 80h

    ; Restaura os registradores e sai da função

    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop ebp
    ret

output_number_to_string:
    ; Esta função converte um número em EAX para uma string em ESI
    ; EAX = número a converter
    ; ESI = buffer onde a string será armazenada
    mov ecx, 0                     ; Contador de bytes
    cmp eax, 0
    je handle_zero

    ; Verifica se o número é negativo
    cmp eax, 0
    jge positive_number            ; Se for positivo, pula
    neg eax                        ; Caso contrário, torna positivo
    mov byte [esi], '-'            ; Armazena o sinal de menos no buffer
    inc ecx                        ; Atualiza o contador

positive_number:
convert_to_string:
    cdq                            ; edx:eax = eax
    mov ebx, 10
    div ebx                        ; eax dividido por 10, edx = resto
    add edx, 0x30                  ; Converte o resto para caractere ASCII
    mov [esi + ecx], dl            ; Armazena o dígito no buffer
    inc ecx                        ; Incrementa o contador
    test eax, eax                  ; Verifica se EAX é 0
    jnz convert_to_string          ; Se não for, continua a conversão

    mov ebx, ecx                   ; EBX = número de dígitos
    dec ebx                        ; Ajusta para indexação zero
    mov edi, esi                   ; EDI = início do buffer

    cmp byte [esi], '-'        ; Checa se o número é negativo
    je skip_minus                  ; Se for, ajusta para não inverter o '-'

reverse_string:
    mov dl, [edi]                  ; DL = caractere à esquerda
    mov dh, [esi + ebx]            ; DH = caractere à direita
    mov [edi], dh                  ; Troca a posição
    mov [esi + ebx], dl

    inc edi                        ; Move para o próximo caractere
    dec ebx                        ; Move para o caractere anterior

    cmp edi, ebx                   ; Compara os índices para parar a inversão
    jl reverse_string              ; Continua se não atingiu o ponto médio
    jmp done_conversion

skip_minus:
    inc edi                        ; Pula o sinal de menos para não inverter
    jmp reverse_string             ; Continua a inversão

handle_zero:
    mov byte [esi], 0x30           ; Se o número é 0, escreve '0' no buffer
    inc ecx                        ; Atualiza o contador

done_conversion:
    mov byte [esi + ecx], 0        ; Adiciona terminador null ao final da string
    mov edx, ecx
    ret
