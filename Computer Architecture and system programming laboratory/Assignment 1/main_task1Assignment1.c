#include <stdlib.h>
#include <stdio.h>
#include <string.h>

extern void assFunc(int x, int y);

char c_checkValidity(int x, int y){

	if (x >= y)
		return '1';
	else
		return '0';
}

int main(int argc, char **argv){

	char num1[32];
	char num2[32];
	int x, y;

	fgets(num1, sizeof(num1), stdin);
	fgets(num2, sizeof(num2), stdin);
	sscanf(num1, "%d", &x);
	sscanf(num2, "%d", &y);
	assFunc(x, y);
	printf("\n");
	
	return 0;
}
