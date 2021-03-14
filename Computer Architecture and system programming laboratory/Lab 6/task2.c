#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <linux/limits.h>
#include <sys/wait.h>
#include <sys/types.h>
#include <signal.h>
#include <unistd.h>
#include "LineParser.h"
#define TERMINATED  -1
#define RUNNING 1
#define SUSPENDED 0
#define O_WRONLY 1
#define O_RDONLY 0
#define O_CREAT 64
#define WCONTINUED 8

typedef struct process{
    cmdLine* cmd;                         
    pid_t pid; 		                  
    int status;                           
    struct process *next;	                  
} process;

void freeProcessList(process** process_list){
	process *curr = NULL;
	process *tmp = NULL;

	if(*process_list==NULL)
		return;

	curr = (*process_list);

	while(curr != NULL){
		tmp = curr;
		curr = curr->next;
		freeCmdLines(tmp->cmd);
		free(tmp);
	}
	free(process_list);
}

void catchErrors(int rc, char* str, process** process_list){
	if(rc==-1){
		freeProcessList(process_list);
		perror(str);
		exit(EXIT_FAILURE);
	}
}

void updateProcessStatus(process *process_list, int pid, int status){

	// if(process_list == NULL)
	// 	return;

	// process *curr = *process_list;

	// while(curr!=NULL && curr->pid!=pid)
	// 	curr = curr->next;

	// if(curr!=NULL)
	// 	curr->status=status;
}

void updateProcessList(process **process_list){
	process *curr = NULL;
	pid_t w;
	int status;	
	int pid;

	if(*process_list==NULL)
		return;

	curr = (*process_list);

	while(curr != NULL){
		pid = curr->pid;
		w = waitpid(pid, &status, WNOHANG | WUNTRACED | WCONTINUED);

		if(w==-1)
			curr->status = TERMINATED;
		else if(WIFSIGNALED(status) && w==pid)
			curr->status = TERMINATED;
		else if(WIFSTOPPED(status) && w==pid)
			curr->status = SUSPENDED;
		else if(WIFCONTINUED(status) && w==pid)
			curr->status = RUNNING;
		
		curr=curr->next;
	}	
}

void printprocess(process *proc, int index){
	int i = 0;

	printf("%d\t%d\t", index, proc->pid);

	proc->status==TERMINATED ? printf("TERMINATED\t"):
	proc->status==SUSPENDED ? printf("SUSPENDED\t"):
	printf("RUNNING\t");

	while(i < proc->cmd->argCount){
		printf("%s ",proc->cmd->arguments[i]);
		i++;
	}
	printf("\n");
}

void printProcessList(process** process_list){
	process *curr = NULL;
	process *prev = NULL;
	int index = 0;
	
	updateProcessList(process_list);

	printf("INDEX\tPID\tSTATUS\tCOMMAND\n");

	if(*process_list==NULL){
		printf("NO PROCESSES!!!\n");
		return;
	}

	curr = (*process_list);
	prev = curr;

	while(curr != NULL){
		printprocess(curr, index);
		index++;

		if(curr->status==TERMINATED){
			if(prev==curr){				
				*process_list = curr->next;
				curr = curr->next;
				freeCmdLines(prev->cmd);
				free(prev);
				prev = curr;
			}
			else{
				prev->next=curr->next;
				freeCmdLines(curr->cmd);
				free(curr);
				curr = prev->next;
			}
		}
		else{
			if(prev==curr)
				curr=curr->next;
			else{
				prev = curr;
				curr = curr->next;	
			}
		}		
	}
}

void addProcess(process** process_list, cmdLine* cmd, pid_t pid){

	process *newProcess = malloc(sizeof(process));
	process *curr = NULL;
	newProcess->cmd = cmd;
	newProcess->pid=pid;
	newProcess->status=RUNNING;
	newProcess->next=NULL;	

	if(*process_list==NULL)
		*process_list = newProcess;
	else{
		curr = *process_list;
		while(curr->next!=NULL)
			curr=curr->next;
		curr->next=newProcess;
	}
}

void execute(cmdLine *line){
	if(execvp(line->arguments[0], line->arguments)==-1){
		perror("CAN NOT EXECUTE CMD LINE!");
		exit(EXIT_FAILURE);
	}	
}

int main(int argc, char **argv) {

	char cwd[PATH_MAX];
	char input[2048];
	cmdLine *line = NULL;
	int i;
	int debugMode = 0;
	process** process_list = (process**)malloc(sizeof(process*));
	pid_t pid, w;
	int status;	

	for(i=1; i<argc; i++){
    	if(strcmp("-d", argv[i])==0)
			debugMode=1;
	}

	getcwd(cwd, PATH_MAX);
	printf("Current Working Directory: %s\n", cwd); 

	while(1){

		fgets(input, 2048, stdin);

		if(strncmp("quit", input, 4)==0){
			freeProcessList(process_list);
			exit(0);
		}
		
		line = parseCmdLines(input);

		//while(line!=NULL){
			if(line->argCount==2 && strcmp(line->arguments[0], "cd")==0){
				catchErrors(chdir(line->arguments[1]), "CAN NOT CHANGE CWD!", process_list);
				printf("Current Working Directory: %s\n", line->arguments[1]);
				freeCmdLines(line);
			}
			else if(line->argCount==1 && strcmp(line->arguments[0], "procs")==0){
				printProcessList(process_list);
				freeCmdLines(line);
			}
			else if(line->argCount==2 && strcmp(line->arguments[0], "suspend")==0){
				catchErrors(kill(atoi(line->arguments[1]), SIGTSTP), "SUSPEND FAILED!", process_list);
				freeCmdLines(line);
			}
			else if(line->argCount==2 && strcmp(line->arguments[0], "kill")==0){
				catchErrors(kill(atoi(line->arguments[1]), SIGINT), "KILL FAILED!", process_list);
				freeCmdLines(line);
			}
			else if(line->argCount==2 && strcmp(line->arguments[0], "wake")==0){
				catchErrors(kill(atoi(line->arguments[1]), SIGCONT), "WAKE FAILED!", process_list);
				freeCmdLines(line);
			}
			else{
				pid = fork();
			
				if(pid==0)
					execute(line);
				else{
					addProcess(process_list, line, pid);
					if(line->blocking)
						waitpid(pid, &status, 0);	
					if(debugMode)
						fprintf(stderr, "PID: %d EXECUTING COMMAND: %s\n", pid, line->arguments[0]);					
				}
				//line=line->next;		
			}			
		//}		
	}
	freeProcessList(process_list);
	return 0;
}


/*for check if child suspend we have to use wiftraced what is blocking*/