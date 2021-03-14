#include <stdlib.h>
#include <stdio.h>
#include <string.h>

char encrypt(char c){

	if(0x20<=c && c<=0x7E)
		return c+3;

	return c;
}

char decrypt(char c){

	if(0x20<=c && c<=0x7E)
		return c-3;

	return c;
}

char dprt(char c){

	printf("%d\n", c);	
	return c;
}

char cprt(char c){

	if(0x20<=c && c<=0x7E){
		printf("%c\n", c);
		return c;
	}

	printf("%c\n", '.');
	return c;
}

char my_get(char c){

	return getchar();
}

char quit(char c){

	if(c=='q')
		exit(0);
	else
		return c;
}
 
char censor(char c) {

	if(c == '!')
		return '.';
	else
		return c;
}
 
char* map(char *array, int array_length, char (*f) (char)){

	int i;
	char* mapped_array = (char*)(malloc(array_length*sizeof(char)));

	for(i=0; i<array_length; i++)
		mapped_array[i] = (*f)(array[i]);
  
	return mapped_array;
}
 
int main(int argc, char **argv){

	int base_len = 5;
	char arr1[base_len];
	char* arr2 = map(arr1, base_len, my_get);
	char* arr3 = map(arr2, base_len, encrypt);
	char* arr4 = map(arr3, base_len, dprt);
	char* arr5 = map(arr4, base_len, decrypt);
	char* arr6 = map(arr5, base_len, cprt);
	free(arr2);
	free(arr3);
	free(arr4);
	free(arr5);
	free(arr6);
}