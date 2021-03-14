section .rodata
     fmthex: db  "%02X", 0 
     fmthex2: db  "%X", 0 
     fmtstr: db "%s", 0
     fmtdebug: db "~ DEBUG - input: %s ~", 10, 0
     msg: db "calc: " , 0
     newLine: db "", 10, 0
     overFlowError: db "Error: Operand Stack Overflow", 10, 0
     underFlowError: db "Error: Insufficient Number of Arguments on Stack", 10, 0
     %macro charToInt 3
          sub %1, %2
          jmp %3
     %endmacro
     %macro printMsg 4
          push %1
          push %2
          call printf
          add esp, %3
          jmp %4
     %endmacro
     %macro checkOperator 2
          cmp byte [buffer], %1
          je %2
     %endmacro
     %macro checkOverflow 0
          mov eax, [capacity]
          cmp eax, [size]
          je overFlow
     %endmacro
     %macro checkUnderflow 1
          cmp dword [size], %1
          jle underFlow
     %endmacro
     %macro decValAndNextChar 2
          inc esi
          cmp %1, 65
          jge %%letter
          charToInt bh, 48, %2
          %%letter:
          charToInt bh, 55, %2
     %endmacro
     %macro createLink 0
          push 5
          call malloc
          add esp, 4
     %endmacro
     %macro popLink 1
          mov ecx, [size]
          mov ebx, [stack]
          mov eax, [ebx+4*ecx]
	     mov dword %1, eax
     %endmacro
     %macro checkEndOfList 2
          cmp dword [%1+1], 0               
          je %2
     %endmacro
     %macro addFmtAndPrint 2
          push %1
          call printf
          add esp, %2
     %endmacro
     %macro takeList 3
          dec dword [size]
          mov %1, [size]        
          mov %2, [%3+4*%1]         
     %endmacro
     %macro getNextLinkAndNumber 2
          mov %1, [%1+1]
          mov %2, [%1]
     %endmacro
     %macro putNumberAndIncPointer 2
          mov byte [eax], %2          
          mov [%1], eax         
          mov %1, eax         
          inc %1
     %endmacro
     %macro getNextLink 1
          mov %1, [%1+1]
     %endmacro
     %macro getTopOfStack 2
          imul %1, 4
          add %2, %1
          inc dword [size]
     %endmacro
     %macro freeLinkAndGetNext 2
          mov %2, %1
          getNextLink %1
          push %2
		call free
		add esp, 4
     %endmacro
     %macro freeLinks 3
          %%loop:
               freeLinkAndGetNext %1, %2
               cmp %1, 0
               je %3
               jmp %%loop
     %endmacro
section .bss   
     buffer: resb 80     
section .data
     stack: dd 0
     debugMode: dd 0     
     numOfCalculations: dd 0 
     size: dd 0     
     capacity: dd 0   
     inputLength: dd 0    
section .text
     align 16
     global main
     extern printf
     extern fflush
     extern malloc
     extern calloc
     extern free
     extern gets
     extern fgets

main:  
     mov ebx, [esp+4]    ;ebx is storing argc
     mov ecx, [esp+8]    ;ecx is storing pinter to argv
     mov ecx, [ecx+4]    ;ecx is storing pointer to begin of the second argument (if exists)
     
     push ebp 
	mov ebp, esp	
	pushad
     
     cmp ebx, 1     ;no arguments
     je defaultSize
     cmp ebx, 2     ;one argument
     je oneArgument
     cmp ebx, 3     ;two arguments
     je twoArguments

     defaultSize:
          mov dword [capacity], 5  
          push dword 20  
          call malloc
          add esp, 4
          mov [stack], dword eax 
          jmp startCalc

     oneArgument:
          cmp [ecx], byte 45
          jne convertSize 
          mov dword [debugMode], 1
          jmp defaultSize

     convertSize:
	     mov eax, 0  	
          convertSizeLoop:
		     cmp [ecx], byte 0
		     je endOfConvertSizeLoop
		     movzx edx, byte[ecx]	
               cmp edx, 65
               jge ABCDEF	
		     sub edx, 48		     		
    	          imul eax, 16       		
   		     add eax, edx	  
		     add ecx, 1
               jmp convertSizeLoop

               ABCDEF:
               sub edx, 55		     		
    	          imul eax, 16       		
   		     add eax, edx	  
		     add ecx, 1	
               jmp convertSizeLoop

          endOfConvertSizeLoop:
               mov [capacity], eax
               imul eax, 4
               push eax
               call malloc
               add esp, 4
               mov [stack], dword eax
               jmp startCalc

     twoArguments:  
          mov dword [debugMode], 1
          jmp convertSize

     startCalc:
          call myCalc
          popad
          mov esp, ebp
          pop ebp
          ret

;---------------------------------------------------------------------------------------------

myCalc:
     push ebp 
	mov ebp, esp	
	pushad

     getInput:
          printMsg msg, fmtstr, 8, getInput2         
     getInput2:
          push dword 80
          push dword buffer
          call gets
          add esp, 8
          cmp byte [debugMode], 1
          jne checkInput
          printMsg buffer, fmtdebug, 8, checkInput

          checkInput:
               checkOperator 'q', quit
               checkOperator '+', unsignedAddition
               checkOperator 'p', popAndPrint
               checkOperator 'd', duplicate
               checkOperator '&', bitwiseAnd
               checkOperator '|', bitwiseOr
               checkOperator 'n', numOfHexDigits
               jmp number

     endOfMyCalc:
          popad
		mov esp, ebp
		pop ebp
		ret 

; ---------------------------------------------------------------------------------------------

     number:
          checkOverflow
          mov edi, 0                              ;edi: pointer to the next link, initialized with null
          mov esi, buffer                         ;esi: next char
          skipLeadingZeros:
               cmp byte [esi], 48
		     jne endOfSkipLeadingZeros
		     inc esi
		     jmp skipLeadingZeros
          endOfSkipLeadingZeros:
               cmp byte [esi], 0
               jne notSingleZero
               dec esi
          notSingleZero:
               mov dword [inputLength], 0
               mov ebx, esi                       ;ebx: will count the length of the input
          getInputLength:
               cmp byte [ebx], 0
               je endOfGetInputLength
               inc ebx
               inc dword [inputLength]
               jmp getInputLength
          endOfGetInputLength:
               mov eax, [inputLength]			     
		     mov ebx, 2
               mov edx, 0	
		     div ebx
		     cmp edx, 0
		     je createNodes                     ;the input length is even
               mov bh, [esi]                      ;bh: first char of the input
               decValAndNextChar bh, createLastNode
          createLastNode:
               createLink
			mov byte [eax], bh                 ;eax: pointer to the last node, [eax]: numerical value
			mov dword [eax+1], edi             ;[eax+1]: next link=null
			mov edi, eax                       ;edi: pointer to the next link=last node
          createNodes:
               mov bh, [esi]                      ;bh: first char of next link
               cmp bh, 0
               je endOfCreateNodes                ;end of input string
               decValAndNextChar bh, multiply16
          multiply16:
               shl bh, 4                          ;bh=bh*16
               mov bl, [esi]                      ;bl: second char of next link
               decValAndNextChar bl, getFinalNumber
          getFinalNumber:
               add bh, bl                         ;bh=second+first
               createLink
			mov byte [eax], bh                 ;eax: pointer to the last node, [eax]: numerical value
			mov dword [eax+1], edi             ;[eax+1]: next link=prev last node
			mov edi, eax                       ;edi: pointer to the next link=last node
			jmp createNodes
          endOfCreateNodes:
               mov ebx, [size]
               mov eax, [stack]
		     mov [eax+4*ebx], edi               ;put the link at top of the stack
               inc dword [size]
               jmp getInput

;----------------------------------------------------------------------------------------------------------

     popAndPrint:
          inc dword [numOfCalculations]
          checkUnderflow 0
          
          dec dword [size]
          popLink edi
          mov ebx, 0                              ;ebx: counting the number of the links of the poped list
          pushLinks:
               mov ecx, 0
               mov cl, [edi]                      ;cl: number to print   
               push ecx                           ;pushing to the stack and than poping and print right order
               inc ebx
               freeLinkAndGetNext edi, esi
               cmp edi, 0
               je printFirstLink
               jmp pushLinks
          printFirstLink:
               addFmtAndPrint fmthex2, 8               
               dec ebx
          printLinksLoop:
               cmp ebx, 0
               je endOfPopAndPrint
               addFmtAndPrint fmthex, 8               
               dec ebx
               jmp printLinksLoop
          endOfPopAndPrint:
               printMsg newLine, fmtstr, 8, getInput

;--------------------------------------------------------------------------------------------------------

     unsignedAddition:
          inc dword [numOfCalculations]
          checkUnderflow 1

          mov ebx, [stack]                        ;ebx: pointing to the begining of the stack
          takeList eax, edi, ebx
          mov ch, [edi]                           ;ch: first number of first list
          takeList eax, esi, ebx
          mov cl, [esi]                           ;cl: first number of second list
          getTopOfStack eax, ebx
          push esi
          push edi

          adderLoop:
               adc ch, cl                         ;add links with carry
               pushfd                             ; save carry flag
               push ecx
               createLink
               pop ecx
               putNumberAndIncPointer ebx, ch
               checkEndOfList edi, endOfFirst
               checkEndOfList esi, endOfSecond
               getNextLinkAndNumber edi, ch
               getNextLinkAndNumber esi, cl
               popfd                              ;restore carry flag
               jmp adderLoop
          endOfFirst:
               checkEndOfList esi, endOfAdderLoop
               mov ch, 0                          ;will sum only second list
               getNextLinkAndNumber esi, cl  
               popfd                              ;restore carry flag
               jmp adderLoop
          endOfSecond:
               mov cl, 0                          ;will sum only first list
               getNextLinkAndNumber edi, ch
               popfd                              ;restore carry flag
               jmp adderLoop
          endOfAdderLoop:
               popfd                              ;restore carry flag
               jnc cleanAdd                       ;no carry
               createLink
               mov byte [eax], 1                  ;putting one on last node   
               mov [ebx], eax
          cleanAdd:
               pop edi
               freeLinks edi, esi, cleanAdd2
          cleanAdd2: 
               pop esi
               freeLinks esi, edi, getInput    

;---------------------------------------------------------------------------------------------------------

     numOfHexDigits:
          inc dword [numOfCalculations]
          checkUnderflow 0

          mov ebx, [stack]                             ;ebx: pointing to the begining of the stack
          takeList ecx, edi, ebx 
          mov esi, edi
          mov ecx, 0                                   ;ecx: counter of number of links

          countDigitsLoop:
               checkEndOfList edi, endOfCountDigitsLoop
               inc ecx
               inc ecx  
               getNextLink edi            
               jmp countDigitsLoop
          endOfCountDigitsLoop:
               shr byte [edi], 4
               cmp byte [edi], 0
               je oneInc                              ;last link has single digit
               inc ecx
          oneInc:
               inc ecx
               mov ebx, [stack]
               mov eax, [size]
               getTopOfStack eax, ebx
          digitsCounterLoop:
               cmp ecx, 0
               je endOfDigitsCounterLoop                           ;no more remainder
               mov edx, 0
		     mov byte dl, cl                         ;get 2 first digits
		     shr ecx, 8                              ;dividing by 256
		     push ecx
               push edx
               createLink
		     pop edx
		     pop ecx
               putNumberAndIncPointer ebx, dl
               jmp digitsCounterLoop
          endOfDigitsCounterLoop:
               freeLinks esi, edi, getInput

;-------------------------------------------------------------------------------------------------------

     duplicate:
          checkOverflow
          checkUnderflow 0

          mov ebx, [stack]                             ;ebx: pointing to the begining of the stack
          takeList ecx, esi, ebx
          inc dword [size]                             ;place for new list
          mov eax, [size]
          getTopOfStack eax, ebx
     
          dupLoop:
               mov cl, [esi]                           ;cl: next 2 digits of curr link
               push ecx
               createLink
               pop ecx
               putNumberAndIncPointer ebx, cl
               checkEndOfList esi, getInput
               getNextLink esi
               jmp dupLoop

;--------------------------------------------------------------------------------------------------------
    
     quit:
          mov eax, [numOfCalculations]
          printMsg eax, fmthex2, 8, freeLists
          freeLists:
               cmp dword [size], 0
               je endOfFreeLists
               mov ebx, [stack]                             ;ebx: pointing to the begining of the stack
               takeList ecx, esi, ebx
               freeLinks esi, edi, freeLists
          endOfFreeLists:
               mov ebx, [stack]
               push ebx
               call free
               add esp, 4
               printMsg newLine, fmtstr, 8, endOfMyCalc
                  
;--------------------------------------------------------------------------------------------------------

     bitwiseAnd:
          inc dword [numOfCalculations]
          checkUnderflow 1

          mov ebx, [stack]                        ;ebx: pointing to the begining of the stack
          takeList eax, edi, ebx
          mov ch, [edi]                           ;ch: first number of first list
          takeList eax, esi, ebx
          mov cl, [esi]                           ;cl: first number of second list
          getTopOfStack eax, ebx
          push esi
          push edi

          andLoop:
               and ch, cl                         ;add links with carry
               push ecx
               createLink
               pop ecx
               putNumberAndIncPointer ebx, ch
               checkEndOfList edi, endOfFirst2
               checkEndOfList esi, endOfSecond2
               getNextLinkAndNumber edi, ch
               getNextLinkAndNumber esi, cl
               jmp andLoop
          endOfFirst2:
               checkEndOfList esi, endOfAndLoop
               mov ch, 0                          ;will sum only second list
               getNextLinkAndNumber esi, cl  
               jmp andLoop
          endOfSecond2:
               mov cl, 0                          ;will sum only first list
               getNextLinkAndNumber edi, ch
               jmp andLoop
          endOfAndLoop:
               pop edi
               freeLinks edi, esi, cleanAnd
          cleanAnd: 
               pop esi
               freeLinks esi, edi, getInput        

;---------------------------------------------------------------------------------------------------------

     bitwiseOr:
          inc dword [numOfCalculations]
          checkUnderflow 1

          mov ebx, [stack]                        ;ebx: pointing to the begining of the stack
          takeList eax, edi, ebx
          mov ch, [edi]                           ;ch: first number of first list
          takeList eax, esi, ebx
          mov cl, [esi]                           ;cl: first number of second list
          getTopOfStack eax, ebx
          push esi
          push edi

          orLoop:
               or ch, cl                         ;add links with carry
               push ecx
               createLink
               pop ecx
               putNumberAndIncPointer ebx, ch
               checkEndOfList edi, endOfFirst3
               checkEndOfList esi, endOfSecond3
               getNextLinkAndNumber edi, ch
               getNextLinkAndNumber esi, cl
               jmp orLoop
          endOfFirst3:
               checkEndOfList esi, endOfOrLoop
               mov ch, 0                          ;will sum only second list
               getNextLinkAndNumber esi, cl  
               jmp orLoop
          endOfSecond3:
               mov cl, 0                          ;will sum only first list
               getNextLinkAndNumber edi, ch
               jmp orLoop
          endOfOrLoop:
               pop edi
               freeLinks edi, esi, cleanOr
          cleanOr: 
               pop esi
               freeLinks esi, edi, getInput          

;---------------------------------------------------------------------------------------------------------

     overFlow:
          printMsg overFlowError, fmtstr, 8, getInput
          
     underFlow:
          printMsg underFlowError, fmtstr, 8, getInput
          
     




          
