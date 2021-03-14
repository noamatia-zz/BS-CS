section .rodata
    fmttarget: db "%.2f, %.2f", 10, 0
    fmtdrone: db "%d, %.2f, %.2f, %.2f, %.2f, %d", 10, 0
    %macro pushFloat 0
        mov dword [temp], eax
        finit
        fld dword [temp]
        fstp qword [curr]
        ffree
        push dword [curr+4]
        push dword [curr]
    %endmacro
section .bss
    temp: resd 1
    curr: resq 1
section .text
    align 16
    global printerFunc
    extern target
    extern printf
    extern resume
    extern N
    extern drones
    extern CORS

printerFunc:
    ;prints target
    mov eax, [target]
    add eax, 4
    mov eax, [eax]
    pushFloat
    mov eax, [target]  
    mov eax, [eax]
    pushFloat
    push fmttarget
    call printf
    add esp, 20

    ;prints drones
    mov esi, 0
    mov edi, [drones]
    printDrones:
        add edi, 4
        push dword [edi]    ;number of eliminations
        add edi, 4
        mov eax, [edi]
        pushFloat           ;speed
        add edi, 4
        mov eax, [edi]
        pushFloat           ;angle
        add edi, 4
        mov eax, [edi]
        pushFloat           ;y
        add edi, 4
        mov eax, [edi]
        pushFloat           ;x
        add edi, 4
        push dword [edi]    ;index
        add edi, 4
        push fmtdrone
        call printf
        add esp, 44
        inc esi
        cmp esi, [N]
        jl printDrones

    ;back to scheduler
    mov ebx, [CORS]
    call resume
    jmp printerFunc