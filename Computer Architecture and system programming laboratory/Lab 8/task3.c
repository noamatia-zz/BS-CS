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
Elf32_Sym *symboltable = NULL;
Elf32_Sym *dynamicsymboltable = NULL;
Elf32_Shdr *sym_strtable = NULL;
Elf32_Rel *relocationtable = NULL;
int Currentfd = -1;
void *map_start = NULL;
struct stat fd_stat;
char str[10000];
const unsigned char magic[] = { 0x7f, 0x45, 0x4c, 0x46 };
const char * str_p =NULL;

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

int map_to_file(){

	map_start = mmap(NULL, fd_stat.st_size, PROT_READ | PROT_WRITE , MAP_SHARED, Currentfd, 0);

	if (map_start == MAP_FAILED) {
    	perror("mmap failed");
    	exit(-4);
	}

	header = (Elf32_Ehdr *) map_start;

	if(memcmp(header->e_ident, magic, sizeof(magic))!= 0){
		printf("\nverifying magic number failed\n\n");
		munmap(map_start, fd_stat.st_size);
		return -1;
	}

	if(debug_mode)
		printf("*****\nDebug: magic number was verifying\n*****\n");

	return 0;
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

	if(map_to_file()==-1)
		return;

	print_elf_header();

	munmap(map_start, fd_stat.st_size);
}

void print_section_names(){

	int i;

	if(Currentfd<0){
		printf("no open file\n");
		return;
	}

	if(map_to_file()==-1)
		return;

	printf("\nThere are %d section headers, starting at offset 0x%x:\n\n", header->e_shnum, header->e_shoff);

	sheader = (Elf32_Shdr *) (map_start + header->e_shoff);
	strtable = (Elf32_Shdr *) &sheader[header->e_shstrndx];
	const char *const  strtable_string = map_start + strtable->sh_offset;

	printf("Section Headers:\n");
	printf("   [Nr]\tName\t\tAddr\t\tOff\t\tSize\t\tType\n");

	for (i = 0; i < header->e_shnum; ++i)
		strlen(strtable_string+sheader[i].sh_name) < 8 ?
    	printf("   [%2d]\t%s\t\t%08x\t%06x\t\t%06x\t\t0x%08x\n", i, strtable_string+sheader[i].sh_name, sheader[i].sh_addr, sheader[i].sh_offset, sheader[i].sh_size, sheader[i].sh_type) :
		printf("   [%2d]\t%s\t%08x\t%06x\t\t%06x\t\t0x%08x\n", i, strtable_string+sheader[i].sh_name, sheader[i].sh_addr, sheader[i].sh_offset, sheader[i].sh_size, sheader[i].sh_type);

	printf("\n");

	munmap(map_start, fd_stat.st_size);
}

void print_symbols_loop(int num_of_symbols, const char *const  strtable_string){
	int i, section_index;
	const char *const sym_strtable_string = map_start + sym_strtable->sh_offset;

	printf("\nSymbol table '.symtab' contains %d entries:\n", num_of_symbols);
	printf("   Num:\tValue\t\tSecNdx\t\tSecName\t\t\t\tSymName\n");

	for (i=0; i<num_of_symbols; i++){
		section_index = symboltable[i].st_shndx;
		section_index==SHN_UNDEF ? printf("   %2d:\t%08x\tUND\t\t%s\n", 
											i, 
											symboltable[i].st_value,
											sym_strtable_string+symboltable[i].st_name) :
		section_index==SHN_ABS ? printf("   %2d:\t%08x\tABS\t\t%s\n", 
											i, 
											symboltable[i].st_value,
											sym_strtable_string+symboltable[i].st_name) :

		(strlen(strtable_string+sheader[section_index].sh_name) < 8 ?
		printf("   %2d:\t%08x\t%02d\t\t%s\t\t\t\t%s\n", 
											i, 
											symboltable[i].st_value,
											section_index,  
											strtable_string+sheader[section_index].sh_name,
											sym_strtable_string+symboltable[i].st_name) :
		printf("   %2d:\t%08x\t%02d\t\t%s\t\t\t%s\n", 
											i, 
											symboltable[i].st_value,
											section_index,  
											strtable_string+sheader[section_index].sh_name,
											sym_strtable_string+symboltable[i].st_name));				
	}
	printf("\n");									
}

void print_symbols(){

	int i, num_of_symbols, sym_strtable_index;

	if(Currentfd<0){
		printf("no open file\n");
		return;
	}

	if(map_to_file()==-1)
		return;

	sheader = (Elf32_Shdr *) (map_start + header->e_shoff);
	strtable = (Elf32_Shdr *) &sheader[header->e_shstrndx];
	const char *const  strtable_string = map_start + strtable->sh_offset;

	for (i=0; i<header->e_shnum; i++){
    	if (sheader[i].sh_type == SHT_SYMTAB){
        	symboltable = (Elf32_Sym *)(map_start + sheader[i].sh_offset);
			num_of_symbols = sheader[i].sh_size/sizeof(Elf32_Sym);
		}
		else if(sheader[i].sh_type == SHT_STRTAB && i!=header->e_shstrndx)
			sym_strtable_index = i;
	}

	sym_strtable = (Elf32_Shdr *) &sheader[sym_strtable_index];

	print_symbols_loop(num_of_symbols, strtable_string);
	munmap(map_start, fd_stat.st_size);
}

void print_relocation_table(int num_of_relocations, int offset, const char *const  relocation_table_name){

	int i, dyn_sum_indx;

	printf("\nRelocation section '%s' at offset 0x%x contains %d entries:\n", relocation_table_name, offset, num_of_relocations);
	printf("Offset\t\tInfo\t\tType\tSym.Value\tSym. Name\n");

	for(i=0; i<num_of_relocations; i++){
		dyn_sum_indx = ELF32_R_SYM(relocationtable[i].r_info);
		printf("%08x\t%08x\t%x\t%08x\t%s\n", 
				relocationtable[i].r_offset,
				relocationtable[i].r_info,
				ELF32_R_TYPE(relocationtable[i].r_info),
				dynamicsymboltable[dyn_sum_indx].st_value,
				(char *) ((int)map_start+ (int)str_p + dynamicsymboltable[dyn_sum_indx].st_name));
	}	
}

void relocation_tables(){

	int i, num_of_relocations, sym_strtable_index;

	if(Currentfd<0){
		printf("no open file\n");
		return;
	}

	if(map_to_file()==-1)
		return;

	sheader = (Elf32_Shdr *) (map_start + header->e_shoff);
	strtable = (Elf32_Shdr *) &sheader[header->e_shstrndx];
	const char *const  strtable_string = map_start + strtable->sh_offset;

	for (i=0; i<header->e_shnum; i++){
		if(sheader[i].sh_type == SHT_STRTAB && i!=header->e_shstrndx)
			sym_strtable_index = i;
		else if (sheader[i].sh_type == SHT_DYNSYM){
        	dynamicsymboltable = (Elf32_Sym *)(map_start + sheader[i].sh_offset);
			str_p =(char *) sheader[sheader[i].sh_link].sh_offset;
		}
	}

	sym_strtable = (Elf32_Shdr *) &sheader[sym_strtable_index];

	for (i=0; i<header->e_shnum; i++){
    	if (sheader[i].sh_type == SHT_REL){
        	relocationtable = (Elf32_Rel *)(map_start + sheader[i].sh_offset);
			num_of_relocations = sheader[i].sh_size/sizeof(Elf32_Rel);
			print_relocation_table(num_of_relocations, sheader[i].sh_offset, strtable_string+sheader[i].sh_name);
		}			
	}
	munmap(map_start, fd_stat.st_size);
}

// for (i = 0; i < shnum; ++i) {
//        if ((shdr[i].sh_type == SHT_SYMTAB)||(shdr[i].sh_type==SHT_DYNSYM)){
//           str_p =(char *) shdr[shdr[i].sh_link].sh_offset;
//           Elf32_Sym *symboler =(Elf32_Sym *)(map_start + shdr[i].sh_offset);
//           for(j=0;j<(shdr[i].sh_size/shdr[i].sh_entsize);j++){
//               printf("%u ", symboler->st_size); 
//               printf("%x ", symboler->st_value); 
//               printf("%u ", symboler->st_shndx);
//               printf("%s\n",(char *) ((int)map_start+ (int)str_p + symboler->st_name));
//               symboler++;
//           }




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
	{"Print Symbols", &print_symbols},
	{"Relocation Tables", &relocation_tables},
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