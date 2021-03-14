section	.rodata		; we define (global) read-only variables in .rodata section
	format_string: db "%s", 10, 0	; format string

section .bss	; we define (global) uninitialized variables in .bss section
	an: resb 12		; enough to store integer in [-2,147,483,648 (-2^31) : 2,147,483,647 (2^31-1)]

section .text
	global convertor
	extern printf

convertor:
	push ebp
	mov ebp, esp	
	pushad			
								
	mov ecx, dword [ebp+8]	; get function argument (pointer to string)
	mov eax, 0	;accumulator of input string
	mov ebx, 16		;hex base

	readInputLoop:
		cmp [ecx], byte 10
		jz endOfReadInputString	;end of the input string
		movzx edx, byte[ecx]	;edx is saving next char	
		sub edx, 48		;char to int        		
    	imul eax, 10       ;accumulator*10 		
   		add eax, edx	;accumulator+next char  
		add ecx, 1	;go to next char of input string     		
		jmp readInputLoop
		
	endOfReadInputString:
		mov ecx, dword an	;now ecx is pointing to the begin of the ouput
		;before getting inside the decToHex loop, we have to do one unconditional deviding for the case the input is 0
		cdq
		idiv ebx	;devide accumulator by 16
		cmp edx, 10
		jge ABCDEF	;remainder between 10-15
		add edx, 48	;remainder between 0-9, char to int
		mov [ecx], edx	;put remainder to the output
		add ecx, 1	;next char of the output

	decToHex:
		cmp eax, 0
		je endOfDecToHex	;stop deviding
		cdq
		idiv ebx	;devide accumulator by 16
		cmp edx, 10
		jge ABCDEF	;remainder between 10-15
		add edx, 48	;remainder between 0-9, char to int
		mov [ecx], edx	;put remainder to the output
		add ecx, 1	;next char of the output
		jmp decToHex

	ABCDEF:	
		add edx, 55		;char to int
		mov [ecx], edx	;put remainder to the output
		add ecx, 1		;next char of the output
		jmp decToHex
	
	endOfDecToHex:
		mov eax, dword an	;now eax is pointing to the begin of the ouput
		mov [ecx], byte 0	;put null at the end, now we have to reverse the output
		sub ecx, 1	;now eax is pointing to the end of the ouput, one char before null
	
	reverse:
		cmp eax, ecx
		jge endOfReverse	;eax and ecx "met" eachother
		mov bl, [eax]	;bl is saving he char eax is pointing on
		mov bh, [ecx]	;bh is saving he char ecx is pointing on
		mov [eax], bh	;eax is taking the char of ecx
		mov [ecx], bl	;ecx is taking the char of eax
		sub ecx, 1	;ecx to the previous char
		add eax, 1	;eax to the next char
		jmp reverse
		
	endOfReverse:
		push an	; call printf with 2 arguments -  
		push format_string	; pointer to str and pointer to format string
		call printf
		add esp, 8	; clean up stack after call

	popad			
	mov esp, ebp	
	pop ebp
	ret
