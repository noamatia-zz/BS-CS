section .data                   					 	
	format: dd "%d"      					 

section .text
	global  assFunc
	extern c_checkValidity
	extern printf


assFunc:
	push ebp 				
  	mov ebp, esp
	pushad
	pushfd			
        mov ebx, [ebp+8]		
        mov ecx, [ebp+12]
	push ecx
	push ebx
	call c_checkValidity
	cmp byte eax, 49
	jnz notOne
	sub ebx, ecx			
	jmp toPrint

	notOne:
		add ebx,ecx
	
	toPrint:
		push ebx				
        	push dword format
		call printf
	
	add esp, 16
	popfd
	popad
        mov esp,ebp
        pop ebp

	ret
