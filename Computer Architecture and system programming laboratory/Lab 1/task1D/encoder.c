#include <stdlib.h>
#include <stdio.h>
#include <string.h>

int main(int argc, char **argv) {
	
	const int ACTIVE=1;
	const int DELTA=-32;
	const int INT=48;
	const char EOL='\n';
	const char SPACE=' ';
	FILE *outputStream=stdout;
	FILE *inputStream=stdin;
	FILE *errorStream=stderr;
	int debugMode=0, encryptionAdd=0, encryptionSub=0, keyLength=0, index=0;
	char *key;
	int c, oldC;
	
	for(int i=1; i<argc; i++){
		
    		if(strcmp(argv[i],"-D")==0){
			debugMode=ACTIVE;
   		 }
	
		else if (strncmp(argv[i], "+e", 2)==0){
    			encryptionAdd=ACTIVE;
			key=argv[i]+2;
			keyLength=strlen(key);
		}
	
		else if (strncmp(argv[i], "-e", 2)==0){
			encryptionSub=ACTIVE;
			key=argv[i]+2;
			keyLength=strlen(key);
		}
	
		else if (strncmp(argv[i], "-o", 2)==0){
			outputStream= fopen(argv[i]+2, "w");
		}
	}

	if(debugMode){

		for(int i=1; i<argc; i++){
			fputs(argv[i], errorStream);
			fputc(SPACE, errorStream);
		}

		fputc(EOL, errorStream);
	}

	c=fgetc(inputStream);
	oldC=c;
	
	while (c!=EOF){
		
		if(encryptionAdd){
			if( c!=EOL){
				c=c+(key[index%keyLength]-INT);
				index++;
			}
			else{
				index=0;
			}
		}
		else if(encryptionSub){
			if( c!=EOL){
				c=c-(key[index%keyLength]-INT);
				index++;
			}
			else{
				index=0;
			}
		}
		else if('a' <=c && c <='z'){
				c=c+DELTA;
		}
		
		if(debugMode && c!=EOL ){
			fprintf(errorStream, "%d\t%d\n", oldC, c);
		}
		
		fputc(c, outputStream);
		c=fgetc(inputStream);
		oldC=c;
	}
	
	if(outputStream!=stdout){
		fclose(outputStream);
	}
}
	
	
