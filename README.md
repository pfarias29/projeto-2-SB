# projeto-2-SB
O projeto consiste em um tradutor de assembly inventado, que foi estudado na disciplina de Software Básico, para o assembly IA-32.

## Alunos
- Mateus Lúcio Silva Mariano - 170151727
- Pedro Farias de Oliveira - 211055577

## Tradutor
Recebe um arquivo contendo o código de máquina do assembly inventado. Ao ler o código de input e output, ele adiciona uma chamada para as funções externas, implementadas diretamente em IA-32.

## Funções externas
As funções de input e output foram implementadas diretamente em assembly IA-32. Ao identificar o uso dessas funções, o tradutor declara as funções como externas e faz uma chamada.

## Como rodar
O projeto foi desenvolvido em Linux, então é recomendável que o mesmo SO seja utilizado para compilar e rodar o programa. Para compilar o programa, basta escrever a seguinte linha no terminal do diretório onde o programa está armazenado:
```bash
gcc tradutor.c -o tradutor
```
Após isso, basta rodar o código com as entradas necessárias
```bash
./tradutor <arquivo com código em assembly inventado> <arquivo de saída>
```

