#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <linux/limits.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>
#include "LineParser.h"

int debugMode = 0;

void execute(cmdLine *line){

	pid_t pid, w;
	int status;

	if(line==NULL){
		perror("CAN NOT EXECUTE CMD LINE!");
		exit(EXIT_FAILURE);
	}
	else if(line->argCount==2 && strcmp(line->arguments[0], "cd")==0){
		if(chdir(line->arguments[1]) != 0){
			perror("CAN NOT CHANGE CWD!");
			exit(EXIT_FAILURE);
		}
		printf("Current Working Directory: %s\n", line->arguments[1]);
	}
	else{
		pid = fork();

		if(pid==0){
			if(execvp(line->arguments[0], line->arguments)==-1){
				perror("CAN NOT EXECUTE CMD LINE!");
				exit(EXIT_FAILURE);
			}
		}
		else{
			if(line->blocking){
				w = waitpid(pid, &status, 0);
				if (w == -1) {
                	perror("WAITPID FAILED!: ");
                	exit(EXIT_FAILURE);
            	}
			}
			if(debugMode)
				fprintf(stderr, "PID: %d EXECUTING COMMAND: %s\n", pid, line->arguments[0]);
		}
	}
}

int main(int argc, char **argv) {

	char cwd[PATH_MAX];
	char input[2048];
	cmdLine *line = NULL;
	int i;

	for(i=1; i<argc; i++){
    	if(strcmp("-d", argv[i])==0)
			debugMode=1;
	}

	getcwd(cwd, PATH_MAX);
	printf("Current Working Directory: %s\n", cwd); 

	while(1){

		fgets(input, 2048, stdin);

		if(strncmp("quit", input, 4)==0)
			exit(0);
		
		line = parseCmdLines(input);
		execute(line);
		freeCmdLines(line);
	}
	return 0;
}
