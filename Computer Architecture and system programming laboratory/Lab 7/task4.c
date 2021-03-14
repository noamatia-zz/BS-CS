#include <stdlib.h>
#include <stdio.h>
#include <string.h>

int get_num_of_digits(char* s){
	int output = 0, i=0;
	
	while(s[i]!='\0'){
		if(s[i]>='0' && s[i]<='9')
			output++;
		i++;
	}
	return output;
}

int main(int argc, char **argv) {
	int num_of_digits = get_num_of_digits(argv[1]);
	printf("%d\n", num_of_digits);
}
	
	
