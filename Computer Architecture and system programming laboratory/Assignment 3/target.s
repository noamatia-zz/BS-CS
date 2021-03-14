section .rodata
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
section .bss
    temp: resd 1
section .text
    align 16
    global targetFunc
    extern resume
    extern seed
    extern target
    extern CORS

targetFunc:
    ;target re-initilazition
    mov edi, [target]
    generateRandom 100
    generateRandom 100
    ret