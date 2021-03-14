#include <stdlib.h>
#include <stdio.h>
#include <string.h>

//structs definition:

typedef struct virus{
	unsigned short SigSize;
	char virusName[16];
	unsigned char *sig;
}virus;

typedef struct link link;
 
struct link{
	link *nextVirus;
	virus *vir;
};

//global variables:

unsigned char bufferN[2];
size_t size;
link *listOfViruses = NULL;
char str[128];
char bufOfSuspectedFile[10000];
size_t sizeOfSuspectedFile;
char *nameOfSuspectedFile = NULL;

virus *readVirus(FILE *input){

	virus *v =  (virus*)malloc(sizeof(virus));

	size = fread(v, 1, 18, input);

	if(size==0){
		free(v);
		return NULL;
	}

	v->sig = (unsigned char*)malloc(v->SigSize);
	fread(v->sig, 1, v->SigSize, input);

	return v;
}

void printVirus(virus *virus, FILE *output){

	if(virus==NULL)
		return;

	fprintf(output , "Virus name: %s\n", virus->virusName);	
	fprintf(output , "Virus size: %d\n", virus->SigSize);
	fprintf(output , "signature:\n");

	for(int i=0; i<virus->SigSize; i++)
		fprintf(output , "%02X ", virus->sig[i]);

	fprintf(output , "\n\n");	
}

void list_print(link *virus_list, FILE *output){

	if(virus_list == NULL)
		return;

	printVirus(virus_list->vir, output);

	if(virus_list->nextVirus != NULL)
		list_print(virus_list->nextVirus, output);
}

link *list_append(link *virus_list, virus* data){
	
	if(virus_list ==NULL){	
		
		link *newLink = (link*)malloc(sizeof(link));
		newLink->nextVirus = NULL;
		newLink->vir = data;	
		return newLink;
	}
	else{
		virus_list->nextVirus = list_append(virus_list->nextVirus, data);
		return virus_list;
	}
}

void list_free(link *virus_list){

	if(virus_list == NULL)
		return;

	if(virus_list->nextVirus != NULL)
		list_free(virus_list->nextVirus);

	free(virus_list->vir->sig);
	free(virus_list->vir);
	free(virus_list);
}

struct fun_desc{
	char *name;
	void (*fun)();
};

void print_menu(struct fun_desc menu[], size_t num_of_fun_desc){

	int i;

	for(i=1; i<=num_of_fun_desc; i++)
		printf("%d%s%s\n", i, ") ", menu[i-1].name);
}

void quit(){

	list_free(listOfViruses);
	exit(0);
}

void load_signatures(){

	virus *v = NULL;
	FILE *input = NULL;
	char fileName[128];


	if(fgets(str, sizeof(str) ,stdin)!=NULL){

		sscanf(str, "%s", fileName);
		input = fopen(fileName , "rb");

		if(input==NULL){
			printf("ERROR - Can Not Read Signatures From File!\n");
			quit();
		}

		v = readVirus(input);

		while(v!=NULL){
			listOfViruses = list_append(listOfViruses , v);
			v = readVirus(input);
		}
	}

	fclose(input);
}

void print_signatures(){
	list_print(listOfViruses , stdout);
}

void detect_virus(char *buffer, unsigned int size, link *virus_list){

	int ret;

	if(virus_list == NULL)
		return;

	for(int i=0; i<=size-virus_list->vir->SigSize; i++){

		ret = memcmp(buffer+i, virus_list->vir->sig, virus_list->vir->SigSize);

		if (ret==0){
			printf("%d\n" , i);
			printf("%s\n" , virus_list->vir->virusName);
			printf("%d\n\n" , virus_list->vir->SigSize);
		}
	}

	if(virus_list->nextVirus!=NULL)
		detect_virus(buffer, size, virus_list->nextVirus);
}

void detect_viruses(){

	FILE *suspected = fopen(nameOfSuspectedFile , "rb");

	if(suspected==NULL){
		printf("ERROR - Can Not Read From The Suspected File!\n");
		quit();
	}

	sizeOfSuspectedFile = fread(bufOfSuspectedFile, 1, 10000, suspected);
	detect_virus(bufOfSuspectedFile, sizeOfSuspectedFile, listOfViruses);
	fclose(suspected);
}
	
int main(int argc, char **argv) {

	struct fun_desc menu[] = {{"Load signatures", &load_signatures}, {"Print signatures", &print_signatures },{"Detect viruses", &detect_viruses}, {"Quit", &quit}, {NULL, NULL}};
	size_t num_of_fun_desc = sizeof(menu)/sizeof(struct fun_desc) - 1;
	const int ONE=49, LAST=49+num_of_fun_desc-1, EOL=10;
	char c;

	nameOfSuspectedFile = argv[1];

	while(1){

		printf("Please choose a function:\n");
		print_menu(menu, num_of_fun_desc);
		printf("Option: ");
		fgets(str, 3, stdin);
		sscanf(str, "%c", &c); 

		if(ONE<=c && c<=LAST){
			printf("Within bounds\n\n");
			(*menu[c-ONE].fun)();
			printf("DONE.\n\n");
		}	
		else if(c!=EOL){
			printf("Not within bounds\n");
			quit();
		}
	}
}