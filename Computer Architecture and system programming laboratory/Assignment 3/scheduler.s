section .rodata
    winnerMessage: db "The Winner is drone: %d",10,0
section .bss
    global currId
    currId: resd 1
    activeDrones: resd 1
    losingId: resd 1
    minKills: resd 1
section .data
    cycles: dd 0
    droneSteps: dd 0
section .text
    global schedulerFunc
    extern printf
    extern resume
    extern N
    extern R
    extern K
    extern drones
    extern CORS
    extern endCo

schedulerFunc:
    mov eax, [N]
    mov [activeDrones], eax
    mov edi, 0
    whileTrue:
        mov dword [currId], edi
        ;validate drone is not eliminated
        mov eax, edi
        mov ebx, 28
        mul ebx
        mov esi, [drones]
        add esi, eax
        cmp dword [esi], 1
        je notEliminated
        inc edi
        jmp checkCycle

        notEliminated:
            ;call drone co-routine
            mov eax, edi
            add eax, 2
            mov ebx, 8
            mul ebx
            mov ebx, [CORS]
            add ebx, eax
            call resume
            ;check if needs to print
            inc edi
            inc dword [droneSteps]            
            mov eax, [droneSteps]
            cmp eax, [K]
            jne checkCycle           
            mov dword [droneSteps], 0
            mov ebx, [CORS]
            add ebx, 8
            call resume
        
        checkCycle:
            ;check if it is end of scheduler cycle
            cmp edi, [N]
            jl whileTrue
            mov edi, 0
            inc dword [cycles]
            mov eax, [cycles]
            cmp eax, [R]
            jne whileTrue

        ;eliminate drone
            mov dword [cycles], 0
            mov esi, [drones]
        findFirstAllive:           
            cmp dword [esi], 1
            je endOfFindFirstAllive
            add esi, 28
            jmp findFirstAllive
        endOfFindFirstAllive:
            add esi, 4
            mov eax, [esi]
            mov [minKills], eax
            add esi, 20
            mov eax, [esi]
            mov [losingId], eax

        findMin:
            mov eax, [esi]
            mov ebx, [N]
            dec ebx
            cmp eax, ebx
            je endOfFindMin
            add esi, 4
            cmp dword [esi], 1
            je alliveDrone
            add esi, 24
            jmp findMin
            alliveDrone:
                add esi, 4
                mov eax, [esi]
                cmp eax, [minKills]
                jl newMin
                add esi, 20
                jmp findMin
                newMin:
                    mov eax, [esi]
                    mov [minKills], eax
                    add esi, 20
                    mov eax, [esi]
                    mov [losingId], eax
                    jmp findMin
        endOfFindMin:
            mov eax, [losingId]
            mov ebx, 28
            mul ebx
            mov esi, [drones]
            add esi, eax
            mov dword [esi], 0
            dec dword [activeDrones]
            cmp dword [activeDrones], 1
            jg whileTrue

        mov esi, [drones]
        findWinner:            
            cmp dword [esi], 1
            je endOfFindWinner
            add esi, 28
            jmp findWinner
        endOfFindWinner:
            add esi, 24
            push dword [esi]
            push winnerMessage
            call printf
            add esp, 8
            jmp endCo







        


