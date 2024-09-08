#include <stdio.h>
#include <stdlib.h>

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
                    fprintf(outputFile, "    push dword mem + %d\n", instructions[++i]);
                    fprintf(outputFile, "    call input\n");
                    fprintf(outputFile, "    add esp, 4\n");
                } else {
                    fprintf(outputFile, "    ; Error: Missing operand for INPUT\n");
                }
                break;
            case 13: // OUTPUT
                if (i + 1 < size) {
                    fprintf(outputFile, "    extern output\n");
                    fprintf(outputFile, "    push dword mem + %d\n", instructions[++i]);
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