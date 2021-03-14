section .rodata
    zero: dd 0.0
    hundred: dd 100.0
    oneEighty: dd 180.0
    threeSixty: dd 360.0
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
            add edi, 4 
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
    %endmacro
    %macro findDelta 2
        finit
        fld dword [temp]
        mov dword [temp], %1
        fild dword [temp]
        fsubp
        fstp dword [%2]
        ffree
    %endmacro
    %macro rangeCheck 2
        finit
        fld dword [%1]
        fld dword [%2]
        fcomip
        ja %%lessThan
        fld dword [%2]
        fsubp
        jmp %%inRange
        %%lessThan:
            fld dword [zero]
            fcomip
            jb %%inRange
            fld dword [%2]
            faddp
        %%inRange:
            fstp dword [%1]
            ffree
            mov dword eax, [%1]
            mov dword [esi], eax
    %endmacro
    %macro rangeCheckSpeed 0
        finit
        fld dword [speed]
        fld dword [deltaSpeed]
        faddp
        fld dword [hundred]
        fcomip
        ja %%lessThan100
        fld dword [hundred]
        jmp %%speedInRange
        %%lessThan100:
            fld dword [zero]
            fcomip
            jb %%speedInRange
            fld dword [zero]
        %%speedInRange:
            fstp dword [newSpeed]
            ffree
            mov dword eax, [newSpeed]
            mov dword [esi], eax
    %endmacro
section .bss
    temp: resd 1
    deltaAlpha: resd 1
    deltaSpeed: resd 1
    newAlpha: resd 1
    newSpeed: resd 1
    newX: resd 1
    newY: resd 1
    alphaRadians: resd 1
    speed: resd 1
    alpha: resd 1
    y: resd 1
    x: resd 1
    destroyed: resd 1
    yTarget: resd 1
    xTarget: resd 1
    deltaY: resd 1
    deltaX: resd 1
section .data
section .text
    global droneFunc
    extern resume
    extern drones
    extern CORS
    extern dist
    extern seed
    extern currId
    extern target
    extern targetFunc

droneFunc:
    ;put drone at esi
    mov eax, [currId]
    mov ebx, 28
    mul ebx
    mov esi, [drones]
    add esi, eax

    ;put fields at labels
    add esi, 8
    mov dword eax, [esi]
    mov dword [speed], eax
    add esi, 4
    mov dword eax, [esi]
    mov dword [alpha], eax
    add esi, 4
    mov dword eax, [esi]
    mov dword [y], eax
    add esi, 4
    mov dword eax, [esi]
    mov dword [x], eax

    ;generate deltas
    generateRandom 120
    findDelta 60, deltaAlpha
    generateRandom 20
    findDelta 10, deltaSpeed

    ;convert alpha to radians   
    finit
    fld dword [alpha]
    fldpi
    fmulp
    fld	dword [oneEighty]
    fdivp
    fst dword [alphaRadians]

    ;sin(a)
    fsin
    
    ;speed*sin(a)
    fld dword [speed]
    fmulp

    ;y+speed*sin(a)
    fld dword [y]
    faddp
    fstp dword [newY]

    ;cos(a)
    fld dword [alphaRadians]
    fcos

    ;speed*cos(a)
    fld dword [speed]
    fmulp

    ;x+speed*cos(a)
    fld dword [x]
    faddp
    fstp dword [newX]
    ffree

    ;update y and check range
    sub esi, 4
    rangeCheck newY, hundred

    ;update x and check rangev
    add esi, 4
    rangeCheck newX, hundred

    ;update alpha and check range
    sub esi, 8
    finit
    fld dword [alpha]
    fld dword [deltaAlpha]
    faddp
    fstp dword [newAlpha]
    ffree
    rangeCheck newAlpha, threeSixty

    ;update speed and check range
    sub esi, 4
    rangeCheckSpeed

    call mayDestroy
    cmp dword [destroyed], 0
    jz targetNotDestroyed

    ;put drone at esi
    mov eax, [currId]
    mov ebx, 28
    mul ebx
    mov esi, [drones]
    add esi, eax

    ;inc number of kills
    add esi, 4
    mov dword eax, [esi]
    inc eax
    mov dword [esi], eax

    call targetFunc

    targetNotDestroyed:
    ;back to scheduler
    mov ebx, [CORS] 
    call resume
    jmp droneFunc

mayDestroy:
    ;take target position
    mov dword edi, [target]   
    mov dword eax, [edi]
    mov dword [xTarget], eax
    add edi, 4
    mov dword eax, [edi]
    mov dword [yTarget], eax

    finit
    fld dword [yTarget]
    fld dword [newY]
    fsubp
    fstp dword [deltaY]         ;yTarget-newY
    fld dword [xTarget]
    fld dword [newX]
    fsubp
    fstp dword [deltaX]         ;xTarget-newX
    fld dword [deltaY]
    fld dword [deltaY]
    fmulp                       ;(yTarget-newY)^2
    fld dword [deltaX]
    fld dword [deltaX]
    fmulp                       ;(xTarget-newX)^2
    faddp                       ;(yTarget-newY)^2 + (xTarget-newX)^2
    fsqrt                       ;sqrt[(yTarget-newY)^2 + (xTarget-newX)^2]
    fild dword [dist] 
    fcomip
    ja canDestroy               ;sqrt[(yTarget-newY)^2 + (xTarget-newX)^2] < dist
    mov dword [destroyed], 0
    jmp return
    canDestroy:
    mov dword [destroyed], 1
    return:
    ret












    


