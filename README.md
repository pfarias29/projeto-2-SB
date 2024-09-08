# projeto-2-SB
O projeto consiste em um tradutor de assembly inventado, que foi estudado na disciplina de Software Básico, para o assembly IA-32.

## Tradutor
Recebe um arquivo contendo o código de máquina do assembly inventado. Ao ler o código de input e output, ele adiciona uma chamada para as funções externas, implementadas diretamente em IA-32.

## Funções externas
As funções de input e output foram implementadas diretamente em assembly IA-32. Ao identificar o uso dessas funções, o tradutor declara as funções como externas e faz uma chamada.

## Como rodar
O projeto foi desenvolvido em Linux, então é recomendável que o mesmo SO seja utilizado para compilar e rodar o programa. Além disso, para que o programa compilasse para Linux 64 bits (que era o que estava sendo usado para o desenvolvimento), foi necessário instalar o pacote gcc-multilib
```bash
sudo apt install gcc-multilib
```
Após isso, é necessário compilar cada um dos programas (output, input e tradutor)
```bash
nasm -f elf32 OUTPUT.asm -o output.o
nasm -f elf32 INPUT.asm -o input.o
gcc -m32 -c tradutor.c -o tradutor.o
```
Após compilados, é necessário que seja feita a ligação
```bash
gcc -m32 tradutor.o input.o output.o tradutor
```
Depois de tudo isso, basta rodar o código com as entradas necessárias
```bash
./tradutor <arquivo com código em assembly inventado> <arquivo de saída>
```

