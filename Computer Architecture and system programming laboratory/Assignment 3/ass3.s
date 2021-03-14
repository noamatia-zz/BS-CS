section .rodata
     fmtdec: db "%d",0
     %macro getArgv 1
          push dword %1
          push dword fmtdec
          push dword [esi]
          call sscanf
          add esp, 12
          add esi, 4
     %endmacro
     %macro generateRandom 1
          mov eax, [seed]
          mov ecx, 16
          %%genLoop:
               dec ecx
               mov ebx, 0x2D
               and ebx, eax
               jp %%even
               shr eax, 1
               add eax, 0x8000
               cmp ecx, 0
               jg %%genLoop
               jmp %%endOfGenLoop
               %%even:
                    shr eax, 1
                    cmp ecx, 0
                    jg %%genLoop
          %%endOfGenLoop:
          mov dword [seed], eax
          finit
          fild dword [seed]
          mov dword [temp], 0xFFFF
          fidiv dword [temp]
          mov dword [temp], %1
          fimul dword [temp]
          fstp dword [temp]
          mov eax, [temp]
          ffree
          mov [edi],eax
          add edi, 4
     %endmacro
     %macro initCo 1
          mov dword [ebx], %1
          add ebx, 4
          mov [ebx], eax
          add eax, STKSIZE
          add ebx, 4
     %endmacro
section .bss
     global N  
     global R
     global K
     global dist
     global seed
     global drones
     global target
     global CORS
     global endCo
     N: resd 1
     R: resd 1
     K: resd 1
     dist: resd 1
     seed: resd 1
     drones: resd 1
     temp: resd 1
     target: resd 1
     CORS: resd 1    
     STK: resd 1
     SPT: resd 1
     SPMAIN: resd 1
     CURR: resd 1
     curr: resq 1
section .data
     STKSIZE equ 16*1024
     SPP equ 0
section .text
     align 16
     global main
     extern printf
     extern fflush
     extern malloc
     extern calloc
     extern free
     extern sscanf
     extern droneFunc
     extern printerFunc
     extern targetFunc
     extern schedulerFunc
     global resume
     global endCo

main:
     push ebp
     mov ebp, esp
     pushfd
     pushad
     ; reading argv
     mov dword esi, [ebp+12]
     add esi, 4
     getArgv N
     getArgv R
     getArgv K
     getArgv dist
     getArgv seed
     ; mov dword [N], 5
     ; mov dword [R], 8
     ; mov dword [K], 10
     ; mov dword [D], 30
     ; mov dword [seed], 15019

     ; target initilazition
     push 8
     call malloc
     add esp, 4
     mov dword [target], eax
     mov edi, [target]
     generateRandom 100
     generateRandom 100

     ;drones initilazition
     mov eax, [N]
     mov ebx, 28
     mul ebx
     push eax
     call malloc
     add esp, 4
     mov dword [drones], eax
     mov esi, 0
     mov edi, [drones]
     initDrones:
          mov dword [edi], 1  ;drone is active
          add edi, 4
          mov dword [edi], 0  ;number of eliminations
          add edi, 4
          generateRandom 100  ;speed
          generateRandom 360  ;angle
          generateRandom 100  ;y
          generateRandom 100  ;x         
          mov [edi], esi      ;index
          inc esi
          add edi, 4                    
          cmp esi, [N]
          jl initDrones

     ;malloc (N+3)*4*2 for cors function and stack pointers
     mov eax, [N]
     add eax, 2
     mov ebx, 8
     mul ebx
     push eax
     call malloc
     add esp, 4
     mov dword [CORS], eax

     ;malloc (N+3)*16*1024 for cors stacks
     mov eax, [N]
     add eax, 2
     mov ebx, STKSIZE
     mul ebx
     push eax
     call malloc
     add esp, 4
     mov dword [STK], eax

     ;coroutines initilazition
     mov eax, [STK]
     mov ebx, [CORS]
     mov ecx, [N]
     initCo schedulerFunc
     initCo printerFunc
     initCosLoop:
          initCo droneFunc
          loop initCosLoop

     mov dword [SPT], esp
     mov ebx, [CORS] 
     mov ecx, [N]
     add ecx, 2
     initStacksLoop:
          mov dword eax, [ebx]
          add ebx, 4
          mov dword esp, [ebx] 
          add esp, STKSIZE
          push eax
          pushfd
          pushad
          mov [ebx], esp 
          add ebx, 4
          loop initStacksLoop
     mov dword esp, [SPT] 
     
     startCo:
          pushad
          mov dword [SPMAIN], esp
          mov ebx, [CORS]
          jmp do_resume

     endCo:
          mov esp, [SPMAIN]
          popad
          push dword [STK]
          call free
          push dword [drones]
          call free
          push dword [CORS]
          call free            
          push dword [target]
          call free
          add esp, 16    
                
          ;exit
          mov eax, 1
          mov ebx, 0
          int 0x80

     resume:
          pushfd
          pushad
          mov edx, [CURR]
          mov [edx+SPP], esp

     do_resume:          
          add ebx, 4
          mov dword esp, [ebx]
          sub ebx, 4
          mov [CURR], ebx
          popad
          popfd
          ret
































