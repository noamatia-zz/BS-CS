#include "util.h"

#define EXIT_CODE 0x55
#define SYS_CLOSE 6
#define SYS_OPEN 5
#define SYS_WRITE 4
#define SYS_READ 3
#define SYS_EXIT 1
#define O_WRONLY 1
#define O_RDONLY 0
#define O_CREAT 64
#define OPEN_PREMISSION 0666
#define ACTIVE 1
#define DELTA -32
#define CHARSIZE 1
#define STDOUT_DEFAULT 1

int stdin = 0;
int stdout = 1;
int stderr = 2;
int debugMode = 0;

void reportSysCall (int returnCode, int sysID){
	if(!debugMode)
		return;
	system_call(SYS_WRITE,stderr, "SYS_ID: ", strlen("SYS_ID: "));
	system_call(SYS_WRITE,stderr, itoa(sysID), strlen(itoa(sysID)));
	system_call(SYS_WRITE,stderr, ", RETURN_CODE: ", strlen(", RETURN_CODE: "));
	system_call(SYS_WRITE,stderr, itoa(returnCode), strlen(itoa(returnCode)));
	system_call(SYS_WRITE,stderr, "\n", CHARSIZE);
}

void checkErrors (int returnCode){
	if(returnCode<0){
		reportSysCall(system_call(SYS_WRITE, STDOUT_DEFAULT, "ERROR - CAN NOT OPEN FILE!\n", strlen("ERROR - CAN NOT OPEN FILE!\n")), SYS_WRITE);
		
		if(stdin!=0 && stdin>=0)
			reportSysCall(system_call(SYS_CLOSE, stdin), SYS_CLOSE);

		if(stdout!=1 && stdout>=0)
			reportSysCall(system_call(SYS_CLOSE, stdout), SYS_CLOSE);

		if(stderr!=2 && stderr>=0)
			reportSysCall(system_call(SYS_CLOSE, stderr), SYS_CLOSE);

		system_call(SYS_EXIT, EXIT_CODE, 0, 0);
	}
}

int main (int argc , char* argv[], char* envp[]) {
	
	int c, i, inputIndx, outputIndex, returnCode1, returnCode2;
	
	for(i=1; i<argc; i++){
    	if(strcmp("-D", argv[i])==0){
			stderr = system_call(SYS_OPEN, "Debug", O_WRONLY | O_CREAT, OPEN_PREMISSION);
			checkErrors(stderr);
			debugMode=ACTIVE;
			reportSysCall(stderr, SYS_OPEN);
			
		}
	}

	for(i=1; i<argc; i++){
		if(strncmp("-o", argv[i], 2)==0){
			stdout = system_call(SYS_OPEN, argv[i]+2, O_WRONLY | O_CREAT, OPEN_PREMISSION);
			reportSysCall(stdout, SYS_OPEN);
			checkErrors(stdout);
			outputIndex = i;
		}
		else if(strncmp("-i", argv[i], 2)==0){
			stdin = system_call(SYS_OPEN, argv[i]+2, O_RDONLY);
			reportSysCall(stdin, SYS_OPEN);
			checkErrors(stdin);
			inputIndx = i;
		}
	}

	if(debugMode){
		if(stdin==0)
			reportSysCall(system_call(SYS_WRITE, stderr, "stdin\n", strlen("stdin\n")), SYS_WRITE);
		else{
			returnCode1 = system_call(SYS_WRITE, stderr, argv[inputIndx]+2, strlen(argv[inputIndx]+2));
			returnCode2 = system_call(SYS_WRITE, stderr, "\n", strlen("\n"));
			reportSysCall(returnCode1, SYS_WRITE);
			reportSysCall(returnCode2, SYS_WRITE);
		}

		if(stdout==1)
			reportSysCall(system_call(SYS_WRITE, stderr, "stdout\n", strlen("stdout\n")), SYS_WRITE);
		else{
			returnCode1 = system_call(SYS_WRITE, stderr, argv[outputIndex]+2, strlen(argv[outputIndex]+2));
			returnCode2 = system_call(SYS_WRITE, stderr, "\n", strlen("\n"));
			reportSysCall(returnCode1, SYS_WRITE);
			reportSysCall(returnCode2, SYS_WRITE);
		}
	}
		
	returnCode1 = system_call(SYS_READ, stdin, &c, CHARSIZE);
	reportSysCall(returnCode1, SYS_READ);
	
	while (returnCode1>0){

		if('a' <=c && c <='z')
			c=c+DELTA;
		
		reportSysCall(system_call(SYS_WRITE,stdout, &c, CHARSIZE), SYS_WRITE);
		returnCode1 = system_call(SYS_READ, stdin, &c, CHARSIZE);
		reportSysCall(returnCode1, SYS_READ);
	}

	reportSysCall(system_call(SYS_WRITE,stdout, "\n", CHARSIZE), SYS_WRITE);

	if(stdin!=0)
		reportSysCall(system_call(SYS_CLOSE, stdin), SYS_CLOSE);

	if(stdout!=1)
		reportSysCall(system_call(SYS_CLOSE, stdout), SYS_CLOSE);

	if(stderr!=2)
		reportSysCall(system_call(SYS_CLOSE, stderr), SYS_CLOSE);

	return 0;
}