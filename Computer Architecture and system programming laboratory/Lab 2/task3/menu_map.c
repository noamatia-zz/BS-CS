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

struct fun_desc{
	char *name;
	char (*fun)(char);
};

void print_menu(struct fun_desc menu[], size_t num_of_fun_desc){

	int i;

	for(i=0; i<num_of_fun_desc; i++)
		printf("%d%s%s\n", i, ")  ", menu[i].name);
}
 
int main(int argc, char **argv){

	int base_len = 5;
	char* carray = (char*)(malloc(base_len));
	char* tmp = carray;
	struct fun_desc menu[] = {{"Censor", &censor }, {"Encrypt", &encrypt }, {"Decrypt", &decrypt}, {"Print dec", &dprt}, {"Print string", &cprt}, {"Get string", &my_get}, {"Quit", &quit}, {NULL, NULL}};
	size_t num_of_fun_desc = sizeof(menu)/sizeof(struct fun_desc) - 1;
	int c;
	const int ZERO=48, LAST=48+num_of_fun_desc-1, EOL=10;;

	while(1){

		printf("Please choose a function:\n");
		print_menu(menu, num_of_fun_desc);
		printf("Option: ");
		c=getchar();
		getchar(); 

		if(ZERO<=c && c<=LAST){
			printf("Within bounds\n");
			tmp = carray;
			carray = map(carray, base_len, menu[c-ZERO].fun);
			free(tmp);
			printf("DONE.\n\n");
		}	
		else if(c!=EOL){
			free(carray);
			printf("Not within bounds\n");
			exit(0);
		}
	}
}