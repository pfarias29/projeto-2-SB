#include <stdio.h>
#include <stdlib.h>

// CÓDIGO DE INPUT EM ASSEMBLY
/**
 * section .data
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
 * 
 */

// CÓDIGO DE OUTPUT EM ASSEMBLY
/**
 * section .data
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
 */

// Função para traduzir código de máquina para IA-32 Assembly
void translate(int *instructions, int size, FILE *outputFile) {
    fprintf(outputFile, "section .text\n");
    fprintf(outputFile, "global _start\n");
    fprintf(outputFile, "_start:\n");

    for (int i = 0; i < size; i++) {
        int opcode = instructions[i];
        switch (opcode) {
            case 1: // ADD
                if (i + 1 < size) {
                    fprintf(outputFile, "    add eax, [mem + %d]\n", instructions[++i]);
                } else {
                    fprintf(outputFile, "    ; Error: Missing operand for ADD\n");
                }
                break;
            case 2: // SUB
                if (i + 1 < size) {
                    fprintf(outputFile, "    sub eax, [mem + %d]\n", instructions[++i]);
                } else {
                    fprintf(outputFile, "    ; Error: Missing operand for SUB\n");
                }
                break;
            case 3: // MUL
                if (i + 1 < size) {
                    fprintf(outputFile, "    cdq\n");
                    fprintf(outputFile, "    imul eax, [mem + %d]\n", instructions[++i]);
                    fprintf(outputFile, "    jo overflow_handler\n");
                } else {
                    fprintf(outputFile, "    ; Error: Missing operand for MUL\n");
                }
                break;
            case 5: // JMP
                if (i + 1 < size) {
                    fprintf(outputFile, "    jmp label_%d\n", instructions[++i]);
                } else {
                    fprintf(outputFile, "    ; Error: Missing operand for JMP\n");
                }
                break;
            case 6: // JMPN
                if (i + 1 < size) {
                    fprintf(outputFile, "    js label_%d\n", instructions[++i]);
                } else {
                    fprintf(outputFile, "    ; Error: Missing operand for JMPN\n");
                }
                break;
            case 7: // JMPP
                if (i + 1 < size) {
                    fprintf(outputFile, "    jns label_%d\n", instructions[++i]);
                } else {
                    fprintf(outputFile, "    ; Error: Missing operand for JMPP\n");
                }
                break;
            case 8: // JMPZ
                if (i + 1 < size) {
                    fprintf(outputFile, "    jz label_%d\n", instructions[++i]);
                } else {
                    fprintf(outputFile, "    ; Error: Missing operand for JMPZ\n");
                }
                break;
            case 9: // COPY
                if (i + 2 < size) {
                    fprintf(outputFile, "    mov eax, [mem + %d]\n", instructions[++i]);
                    fprintf(outputFile, "    mov [mem + %d], eax\n", instructions[++i]);
                } else {
                    fprintf(outputFile, "    ; Error: Missing operands for COPY\n");
                }
                break;
            case 10: // LOAD
                if (i + 1 < size) {
                    fprintf(outputFile, "    mov eax, [mem + %d]\n", instructions[++i]);
                } else {
                    fprintf(outputFile, "    ; Error: Missing operand for LOAD\n");
                }
                break;
            case 11: // STORE
                if (i + 1 < size) {
                    fprintf(outputFile, "    mov [mem + %d], eax\n", instructions[++i]);
                } else {
                    fprintf(outputFile, "    ; Error: Missing operand for STORE\n");
                }
                break;
            case 12: // INPUT
                if (i + 1 < size) {
                    fprintf(outputFile, "    extern input\n");
                    fprintf(outputFile, "    push dword [mem + %d]\n", instructions[++i]);
                    fprintf(outputFile, "    call input\n");
                    fprintf(outputFile, "    add esp, 4\n");
                } else {
                    fprintf(outputFile, "    ; Error: Missing operand for INPUT\n");
                }
                break;
            case 13: // OUTPUT
                if (i + 1 < size) {
                    fprintf(outputFile, "    extern output\n");
                    fprintf(outputFile, "    push dword [mem + %d]\n", instructions[++i]);
                    fprintf(outputFile, "    call output\n");
                    fprintf(outputFile, "    add esp, 4\n");
                } else {
                    fprintf(outputFile, "    ; Error: Missing operand for OUTPUT\n");
                }
                break;
            case 14: // STOP
                fprintf(outputFile, "    mov eax, 1\n");
                fprintf(outputFile, "    int 0x80\n");
                break;
            default:
                fprintf(outputFile, "    ; Unknown opcode %d\n", opcode);
                break;
        }
    }

    // Adicionando manipulador de overflow
    fprintf(outputFile, "\noverflow_handler:\n");
    fprintf(outputFile, "    mov eax, 1\n");
    fprintf(outputFile, "    int 0x80\n");


}

int main(int argc, char *argv[]) {
    if (argc < 3) {
        fprintf(stderr, "Uso: %s <arquivo de entrada> <arquivo de saída>\n", argv[0]);
        return 1;
    }

    FILE *inputFile = fopen(argv[1], "r");
    if (!inputFile) {
        perror("Erro ao abrir arquivo de entrada");
        return 1;
    }

    FILE *outputFile = fopen(argv[2], "w");
    if (!outputFile) {
        perror("Erro ao abrir arquivo de saída");
        fclose(inputFile);
        return 1;
    }

    int instructions[1000];
    int size = 0;

    while (fscanf(inputFile, "%d", &instructions[size]) != EOF && size < 1000) {
        size++;
    }

    fclose(inputFile);

    translate(instructions, size, outputFile);

    fclose(outputFile);

    return 0;
}
