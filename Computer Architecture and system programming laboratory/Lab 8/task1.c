#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <fcntl.h>
#include <sys/types.h>
#include <unistd.h>
#include <elf.h>
#include <sys/mman.h>
#include <sys/stat.h>

typedef struct{
	char *name;
	void (*fun)();
} fun_desc;

//global variables:

int debug_mode = 0;
Elf32_Ehdr *header = NULL;
Elf32_Shdr *sheader = NULL;
Elf32_Shdr *strtable = NULL;
Elf32_Phdr *pheader = NULL;
int Currentfd = -1;
void *map_start = NULL;
struct stat fd_stat;
char str[10000];
const unsigned char magic[] = { 0x7f, 0x45, 0x4c, 0x46 };

//functions:

void print_menu(fun_desc menu[], size_t num_of_fun_desc){
	int i;
	for(i=0; i<num_of_fun_desc; i++)
		printf("%d%s%s\n", i, ")  ", menu[i].name);
}

void toggle_debug_mode(){
	if(debug_mode){
		printf("Debug flag now off\n");
		debug_mode = 0;
	}
	else{
		printf("Debug flag now on\n");
		debug_mode = 1;
	}
}

void print_elf_header(){

	printf("\nELF Header:\n");
	printf("   First 3 of magic:\t\t%x %x %x\n", header->e_ident[0], header->e_ident[1], header->e_ident[2]);
	header->e_ident[5] == 0x01 ? printf("   Data:\t\t\t2's complement, little endian\n") : printf("   Data:\t\t\t2's complement, big endian\n");
	printf("   Entry point address:\t\t0x%x\n", header->e_entry);
	printf("   Start of section headers:\t%d (bytes into file)\n", header->e_shoff);
	printf("   Number of section headers:\t%d\n", header->e_shnum);
	printf("   Size of section headers:\t%d (bytes)\n", header->e_shentsize);
	printf("   Start of program headers:\t%d (bytes into file)\n", header->e_phoff);
	printf("   Number of program headers:\t%d\n", header->e_phnum);
	printf("   Size of program headers:\t%d (bytes)\n", header->e_phentsize);
	printf("\n");
}

void examine_elf_file(){

	printf("Please enter a file name:\n");
	fgets(str, sizeof(str), stdin);
	strtok(str, "\n");

	if(debug_mode)
		printf("*****\nDebug: file name is: %s\n*****\n", str);

	if(Currentfd != -1 && close(Currentfd) < 0){
    	perror("error in close");
    	exit(-1);
	}

	Currentfd = open(str, O_RDWR);

	if(Currentfd < 0){
    	perror("error in open");
    	exit(-1);
	}

	if( fstat(Currentfd, &fd_stat) != 0 ){
		close(Currentfd);
    	perror("stat failed");
    	exit(-1);
	}

	map_start = mmap(NULL, fd_stat.st_size, PROT_READ | PROT_WRITE , MAP_SHARED, Currentfd, 0);

	if (map_start == MAP_FAILED) {
    	perror("mmap failed");
    	exit(-4);
	}

	header = (Elf32_Ehdr *) map_start;

	if(memcmp(header->e_ident, magic, sizeof(magic))!= 0){
		printf("\nverifying magic number failed\n\n");
		munmap(map_start, fd_stat.st_size);
		return;
	}

	if(debug_mode)
		printf("*****\nDebug: magic number was verifying\n*****\n");

	print_elf_header();

	munmap(map_start, fd_stat.st_size);
}

void print_section_names(){

	int i;

	if(Currentfd<0){
		printf("no open file\n");
		return;
	}

	map_start = mmap(NULL, fd_stat.st_size, PROT_READ | PROT_WRITE , MAP_SHARED, Currentfd, 0);

	if (map_start == MAP_FAILED) {
    	perror("mmap failed");
    	exit(-4);
	}

	header = (Elf32_Ehdr *) map_start;

	if(memcmp(header->e_ident, magic, sizeof(magic))!= 0){
		printf("\nverifying magic number failed\n\n");
		munmap(map_start, fd_stat.st_size);
		return;
	}

	if(debug_mode)
		printf("*****\nDebug: magic number was verifying\n*****\n");

	printf("There are %d section headers, starting at offset 0x%x:\n\n", header->e_shnum, header->e_shoff);

	sheader = (Elf32_Shdr *) (map_start + header->e_shoff);
	strtable = (Elf32_Shdr *) &sheader[header->e_shstrndx];
	const char *const  strtable_string = map_start + strtable->sh_offset;

	printf("\nSection Headers:\n");
	printf("   [Nr]\tName\t\tAddr\t\tOff\t\tSize\t\tType\n");

	for (i = 0; i < header->e_shnum; ++i)
		strlen(strtable_string+sheader[i].sh_name) < 8 ?
    	printf("   [%2d]\t%s\t\t%08x\t%06x\t\t%06x\t\t0x%08x\n", i, strtable_string+sheader[i].sh_name, sheader[i].sh_addr, sheader[i].sh_offset, sheader[i].sh_size, sheader[i].sh_type) :
		printf("   [%2d]\t%s\t%08x\t%06x\t\t%06x\t\t0x%08x\n", i, strtable_string+sheader[i].sh_name, sheader[i].sh_addr, sheader[i].sh_offset, sheader[i].sh_size, sheader[i].sh_type);

	printf("\n");

	munmap(map_start, fd_stat.st_size);
}

void quit(){

	if(Currentfd != -1 && close(Currentfd) < 0){
    	perror("error in close");
    	exit(-1);
	}

	printf("quitting\n");
	exit(0);
}

int main(int argc, char **argv){
	
	fun_desc menu[] = {{"Toggle Debug Mode", &toggle_debug_mode}, 
	{"Examine ELF File", &examine_elf_file}, 
	{"Print Section Names", &print_section_names},
	{"Quit", &quit}, 
	{NULL, NULL}};
	size_t num_of_fun_desc = sizeof(menu)/sizeof(fun_desc) - 1;
	char str[100000];
	int input;

	while(1){
		printf("Please choose a function:\n");
		print_menu(menu, num_of_fun_desc);
		printf("Option: ");
		fgets(str, 10000, stdin);
		sscanf(str ,"%d", &input);

		if(0<=input && input<=(num_of_fun_desc-1)){
			printf("Within bounds\n");
			(*menu[input].fun)();
			printf("DONE.\n\n");
		}	
		else
			printf("Not within bounds\n");
	}
}