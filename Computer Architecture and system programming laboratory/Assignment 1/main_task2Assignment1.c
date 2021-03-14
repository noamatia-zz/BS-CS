#include <stdio.h>
#define	MAX_LEN 34				
										
extern int convertor(char* buf);

int main(int argc, char** argv){

	char buf[MAX_LEN ];
	int flag = 1;

	while(flag){

		fgets(buf, MAX_LEN, stdin);		

		if(buf[0]==113 && buf[1]==10 && buf[2]==0)
			flag = 0;
		else
			convertor(buf);
	}					

	return 0;
}