.model tiny
.code
org 100h
start:
    AAA
    AAS
    DAA
    DAS
    INC BX
    INC DI
    INC BYTE PTR [BX+SI]
    INC WORD PTR [BX+DI+10h]
    INC AL
    PUSH ES
    PUSH BP
    PUSH WORD PTR [BX]
    PUSH WORD PTR [SI+8]
    PUSH WORD PTR ES:[DI]
    SUB DX, AX
    SUB WORD PTR [BX], AX
    SUB AL, [SI+10h]
    SUB BYTE PTR [BX], 10h
    SUB WORD PTR [SI], 5
    SHR AX, CL
    SHR BYTE PTR [BX+SI], 1
end start