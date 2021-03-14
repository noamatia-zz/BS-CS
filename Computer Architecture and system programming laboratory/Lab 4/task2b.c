#include "util.h"

#define OFFSET 28
#define BUF_SIZE 8192
#define EXIT_CODE 0x55
#define SYS_GETDENTS 141
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
#define CHARSIZE 1
#define STDOUT 1
# define DT_REG 8
# define DT_DIR 4
# define DT_FIFO 1
# define DT_SOCK 12
# define DT_LNK 10
# define DT_BLK 6
# define DT_CHR 2

int stderr = 2;
int debugMode = 0;
int prefixMode = 0;

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
		reportSysCall(system_call(SYS_WRITE, STDOUT, "ERROR - CAN NOT OPEN FILE!\n", strlen("ERROR - CAN NOT OPEN FILE!\n")), SYS_WRITE);
		
		if(stderr!=2 && stderr>=0)
			reportSysCall(system_call(SYS_CLOSE, stderr), SYS_CLOSE);

		system_call(SYS_EXIT, EXIT_CODE, 0, 0);
	}
}

typedef struct ent{
	int ino;
	int off;
	unsigned short len;
	char name[];
} ent;

void reportDirent (int len, char* name){
	int rc1, rc2, rc3, rc4, rc5;
	rc1 = system_call(SYS_WRITE, stderr, "DIRENT LENGTH: ", strlen("DIRENT LENGTH: "));
	rc2 = system_call(SYS_WRITE, stderr, itoa(len), strlen(itoa(len)));
	rc3 = system_call(SYS_WRITE, stderr, ", DIRENT NAME: ", strlen(", DIRENT NAME: "));
	rc4 = system_call(SYS_WRITE, stderr, name, strlen(name));
	rc5 = system_call(SYS_WRITE, stderr, "\n", strlen("\n"));
	reportSysCall(rc1, SYS_WRITE);
	reportSysCall(rc2, SYS_WRITE);
	reportSysCall(rc3, SYS_WRITE);
	reportSysCall(rc4, SYS_WRITE);
	reportSysCall(rc5, SYS_WRITE);
}

void printDirentType (char type){
	(type == DT_REG) ?  reportSysCall(system_call(SYS_WRITE, STDOUT, "DIRENT TYPE: regular, DIRENT NAME: ", strlen("DIRENT TYPE: regular, DIRENT NAME: ")), SYS_WRITE) :
	(type == DT_DIR) ?  reportSysCall(system_call(SYS_WRITE, STDOUT, "DIRENT TYPE: directory, DIRENT NAME: ", strlen("DIRENT TYPE: directory, DIRENT NAME: ")), SYS_WRITE) :
    (type == DT_FIFO) ? reportSysCall(system_call(SYS_WRITE, STDOUT, "DIRENT TYPE: FIFO, DIRENT NAME: ", strlen("DIRENT TYPE: FIFO, DIRENT NAME: ")), SYS_WRITE) :
    (type == DT_SOCK) ? reportSysCall(system_call(SYS_WRITE, STDOUT, "DIRENT TYPE: socket, DIRENT NAME: ", strlen("DIRENT TYPE: socket, DIRENT NAME: ")), SYS_WRITE) :
    (type == DT_LNK) ?  reportSysCall(system_call(SYS_WRITE, STDOUT, "DIRENT TYPE: symlink, DIRENT NAME: ", strlen("DIRENT TYPE: symlink, DIRENT NAME: ")), SYS_WRITE) :
    (type == DT_BLK) ?  reportSysCall(system_call(SYS_WRITE, STDOUT, "DIRENT TYPE: block dev, DIRENT NAME: ", strlen("DIRENT TYPE: blockdev, DIRENT NAME: ")), SYS_WRITE) :
    (type == DT_CHR) ?  reportSysCall(system_call(SYS_WRITE, STDOUT, "DIRENT TYPE: char dev, DIRENT NAME: ", strlen("DIRENT TYPE: char dev, DIRENT NAME: ")), SYS_WRITE) :
	reportSysCall(system_call(SYS_WRITE, STDOUT, "DIRENT TYPE: ???, DIRENT NAME: ", strlen("DIRENT TYPE: ???, DIRENT NAME: ")), SYS_WRITE);
}

int main (int argc , char* argv[], char* envp[]) {
	
	int i, fd, count, prefIndex;
	ent *entp;
	char buf[BUF_SIZE];
	char type;
	
	for(i=1; i<argc; i++){
    	if(strcmp("-D", argv[i])==0){
			stderr = system_call(SYS_OPEN, "Debug", O_WRONLY | O_CREAT, OPEN_PREMISSION);
			checkErrors(stderr);
			debugMode=ACTIVE;
			reportSysCall(stderr, SYS_OPEN);
			
		}
	}

	for(i=1; i<argc; i++){
    	if(strncmp("-p", argv[i], 2)==0){			
			prefixMode=ACTIVE;
			prefIndex=i;		
		}
	}

	fd = system_call(SYS_OPEN, ".", O_RDONLY);
	reportSysCall(fd, SYS_OPEN);
	checkErrors(fd);

	count = system_call(SYS_GETDENTS, fd, buf, BUF_SIZE);
	reportSysCall(count, SYS_GETDENTS);
	checkErrors(count);
	i=0;

	reportSysCall(system_call(SYS_WRITE, STDOUT, "DENNIS RODMAN IS ON FIRE!!!\n", strlen("DENNIS RODMAN IS ON FIRE!!!\n")), SYS_WRITE);
	while(i<count){

		entp = (ent*) (buf+i);
		type = *(buf + i + entp->len - 1);

		if(debugMode)
			reportDirent(entp->len, entp->name);

		if(!prefixMode || strncmp(entp->name, argv[prefIndex]+2, strlen(argv[prefIndex]+2))==0){
			printDirentType(type);
			reportSysCall(system_call(SYS_WRITE, STDOUT, entp->name, strlen(entp->name)), SYS_WRITE);
			reportSysCall(system_call(SYS_WRITE, STDOUT, "\n", CHARSIZE), SYS_WRITE);
		}
		i = i + entp->len;
	}

	/*I used the man page of getdents(2)*/

	reportSysCall(system_call(SYS_CLOSE, fd), SYS_CLOSE);
	if(stderr!=2)
		reportSysCall(system_call(SYS_CLOSE, stderr), SYS_CLOSE);

	return 0;
}