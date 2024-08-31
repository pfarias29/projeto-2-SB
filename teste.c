#include <stdio.h>


int main(void) {
    int value, res;

    extern int input(int);
    value = input(res);

    printf("%d", value);
    return 0;

}