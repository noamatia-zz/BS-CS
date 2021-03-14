#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <fcntl.h>
#include <sys/types.h>
#include <unistd.h>

typedef struct {
  int debug_mode;
  char file_name[128];
  int unit_size;
  unsigned char mem_buf[10000];
  size_t mem_count;
  int display_flag;
} state;

typedef struct{
	char *name;
	void (*fun)();
} fun_desc;

void print_menu(fun_desc menu[], size_t num_of_fun_desc){
	int i;
	for(i=0; i<num_of_fun_desc; i++)
		printf("%d%s%s\n", i, ")  ", menu[i].name);
}

state *initializeS(){
	state *s = (state*)malloc(sizeof(state));
	s->debug_mode = 0;
	s->unit_size = 1;
	s->mem_count = 0;
	s->display_flag = 0;
	return s;
}

void toggle_debug_mode(state* s){
	if(s->debug_mode){
		printf("Debug flag now off\n");
		s->debug_mode = 0;
	}
	else{
		printf("Debug flag now on\n");
		s->debug_mode = 1;
	}
}

void print_vars(state* s){
	printf("*****\nDebug:\nunit_size: %d\nfile_name: %s\nmem_count: %d\n*****\n", s->unit_size, s->file_name, s->mem_count);
}

void set_file_name(state* s){
	printf("Please enter a file name:\n");
	fgets(s->file_name, 128, stdin);
	strtok(s->file_name, "\n");
	if(s->debug_mode)
		printf("*****\nDebug: file name set to %s\n*****\n", s->file_name);
}

void set_unit_size(state* s){
	char str[10000];
	int input;

	printf("Please enter a number:\n");
	fgets(str, 10000, stdin);
	input = atoi(str);

	if(input==1 || input==2 || input==4){
		s->unit_size = input;
		if(s->debug_mode)
			printf("*****\nDebug: set size to %d\n*****\n", s->unit_size);
	}
	else
		printf("Invalid input!\n");
}

void quit(state* s){
	printf("quitting\n");
	free(s);
	exit(0);
}

int read_write_file(char *str, state* s, int length, int location, int status){
	int fd;

	if(s->file_name[0]=='\0'){
		printf("No File Name Was Set!\n");
		return -1;
	}
	fd = open(s->file_name, status);
	if(fd==-1){
		printf("Could Not Open File!\n");
		return -1;
	}
	if(lseek(fd, location, SEEK_SET)==-1){
		printf("Could Not Find Location!\n");
		close(fd);
		return -1;
	}
	if(status==O_RDONLY)
		read(fd, str, (length*s->unit_size));
	else
		write(fd, str, (length*s->unit_size));
	return 0;
}

void load_into_memory(state* s){	
	char str[10000];
	int location, length;

	printf("Please enter <location> <length>\n");
	fgets(str, 10000, stdin);
	sscanf(str, "%X %d", &location, &length);
	if(s->debug_mode)
		printf("*****\nDebug:\nfile_name: %s\nlocation: %X\nlength: %d\n*****\n", s->file_name, location, length);	
	if(read_write_file((char*)s->mem_buf, s, length, location, O_RDONLY)==-1)
		return;
	s->mem_count+=(length*s->unit_size);
	printf("Loaded %d units into memory\n", length);	
}

void toggle_display_mode(state* s){
	if(s->display_flag){
		printf("Display flag now off, decimal representation\n");
		s->display_flag = 0;
	}
	else{
		printf("Display flag now on, hexadecimal representation\n");
		s->display_flag = 1;
	}
}

char* unit_to_format(int unit, int flag) {
    static char* formats_hex[] = {"%hhX\n", "%hX\n", "No such unit", "%X\n"};
	if(flag)
		return formats_hex[unit-1];
	else
		return "%u\n";    
}

void print_memory(state* s, int u, int addr){
	char *start, *end;
	int i;
	// char str[100];

	if(addr)
	// {
		// if(read_write_file(str, s, u, addr, O_RDONLY)==-1)
		// 	return;
		start = (char*)addr;
	// }	 
	else
		start = (char*)s->mem_buf;

	end = start + (u*s->unit_size);
	
	while(start<end){
		i = *((int*)(start));
		printf(unit_to_format(s->unit_size, s->display_flag), i);
		start+=s->unit_size;
	}
}

void memory_display(state* s){
	char str[10000];
	int u, addr;

	(s->display_flag) ? printf("Hexadecimal\n=======\n") : printf("Decimal\n=======\n");
	printf("Please enter <units> <address>\n");
	fgets(str, 10000, stdin);
	sscanf(str, "%d %X", &u, &addr);
	if(s->debug_mode)
		printf("*****\nDebug:\nnumber_of_units: %d\naddress: %X\n*****\n", u, addr);
	print_memory(s, u, addr);
}

void change_memory(state* s, int source_address, int target_location, int length){
	if(source_address)
		read_write_file((char*)source_address, s, length, target_location, O_WRONLY);
	else
		read_write_file((char*)s->mem_buf, s, length, target_location, O_WRONLY);
}

void save_into_file(state* s){
	char str[10000];
	int source_address, target_location, length;
	printf("Please enter <source-address> <target-location> <length>\n");
	fgets(str, 10000, stdin);
	sscanf(str, "%X %X %d", &source_address, &target_location, &length);
	if(s->debug_mode)
		printf("*****\nDebug:\nsource_address: %X\ntarget_location: %X\nlength: %d\n*****\n", source_address, target_location, length);
	change_memory(s, source_address, target_location, length);
}

void memory_modify(state* s){
	char str[10000];
	int location, val, i=0;
	printf("Please enter <location> <val>\n");
	fgets(str, 10000, stdin);
	sscanf(str, "%X %X", &location, &val);
	if(s->debug_mode)
		printf("*****\nDebug:\nlocation: %X\nval: %X\n*****\n", location, val);
	while(val>0){
		s->mem_buf[location+i] = val;
		val=val/256;
		i++;
	}
}
 
int main(int argc, char **argv){

	state *s = initializeS();	
	fun_desc menu[] = {{"Toggle Debug Mode", &toggle_debug_mode}, 
	{"Set File Name", &set_file_name}, 
	{"Set Unit Size", &set_unit_size}, 
	{"Load Into Memory", &load_into_memory}, 
	{"Toggle Display Mode", &toggle_display_mode}, 
	{"Memory Display", &memory_display}, 
	{"Save Into File", &save_into_file},
	{"Memory Modify", &memory_modify},
	{"Quit", &quit}, 
	{NULL, NULL}};
	size_t num_of_fun_desc = sizeof(menu)/sizeof(fun_desc) - 1;
	char str[100000];
	int input;

	while(1){
		if(s->debug_mode)
			print_vars(s);
		printf("Please choose a function:\n");
		print_menu(menu, num_of_fun_desc);
		printf("Option: ");
		fgets(str, 10000, stdin);
		sscanf(str ,"%d", &input);

		if(0<=input && input<=(num_of_fun_desc-1)){
			printf("Within bounds\n");
			(*menu[input].fun)(s);
			printf("DONE.\n\n");
		}	
		else
			printf("Not within bounds\n");
	}
}