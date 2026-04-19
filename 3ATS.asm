.model small
.stack 100h

.data
  msg_error db "Erroras $"
  msg_test db "Test $"
  endl db 0dh, 0ah, 24h

  filename db 128 dup(0)   
  fileBlockBuff db 256 dup(0)
  blockBuffSize equ 256
  cleanbuff db 256 dup(0)
  bytesRead dw ?  

  msg_cs db 'cs:$'

  msg_poslinkis db '+Poslinkis$'
  msg_direct_adress db 'Direct adress$'
  
  handle dw ?
  linenum dw 0
  charcount dw 0

  hex_digits db '0123456789ABCDEF'
  hex_output db '00$'

  instructionBuffer db 64 dup("$")
  instructionBufferSize db 64

  msg_word_ptr db 'WORD PTR $'
  msg_byte_ptr db 'BYTE PTR $'

  regAL db 'AL$'
  regCL db 'CL$'
  regDL db 'DL$'
  regBL db 'BL$'
  regAH db 'AH$'
  regCH db 'CH$'
  regDH db 'DH$'
  regBH db 'BH$'

  regAX db 'AX$'
  regCX db 'CX$'
  regDX db 'DX$'
  regBX db 'BX$'
  regSP db 'SP$'
  regBP db 'BP$'
  regSI db 'SI$'
  regDI db 'DI$'

  regES db 'ES$'
  regSS db 'SS$'
  regCS db 'CS$'
  regDS db 'DS$'

  regBXSI db 'BX+SI$'
  regBXDI db 'BX+DI$'
  regBPSI db 'BP+SI$'
  regBPDI db 'BP+DI$'
  regSIx db 'SI$'
  regDIx db 'DI$'
  regBPx db 'BP$'
  regBXx db 'BX$'
  rmTable dw regBXSI, regBXDI, regBPSI, regBPDI, regSIx, regDIx, regBPx, regBXx

  regALptr dw regAL
  regCLptr dw regCL
  regDLptr dw regDL
  regBLptr dw regBL
  regAHptr dw regAH
  regCHptr dw regCH
  regDHptr dw regDH
  regBHptr dw regBH

  regAXptr dw regAX
  regCXptr dw regCX
  regDXptr dw regDX
  regBXptr dw regBX
  regSPptr dw regSP
  regBPptr dw regBP
  regSIptr dw regSI
  regDIptr dw regDI

  regESptr dw regES
  regCSptr dw regCS
  regSSptr dw regSS
  regDSptr dw regDS

  ; regBXSIptr dw regBXSI
  ; regBXDIptr dw regBXDI
  ; regBPSIptr dw regBPSI
  ; regBPDIptr dw regBPDI
  ; regSIxptr dw regSIx
  ; regDIxptr dw regDIx 
  ; regBXxptr dw regBXx 

  opAAS equ 3Fh
  opDAS equ 2Fh
  opAAA equ 37h
  opDAA equ 27h

  opINC_firstAND equ 0F8h
  opINC_firstCMP equ 040h
  opINC_secondAMP equ 038h
  opINC_secondCMP equ 00h

  opPUSH_firstAND equ 0E7h
  opPush_firstCMP equ 06h
  opPUSH_secondAND equ 0F8h
  opPUSH_secondCMP equ 050h
  opPUSH_third equ 0FFh
  opPUSH_thirdAND equ 038h
  opPUSH_thirdCMP equ 030h

  opSUB_firstAND equ 0FCh
  opSUB_firstCMP equ 28h
  opSUB_secondAND equ 0FEh
  opSUB_secondCMP equ 02Ch
  opSUB_thirdAND equ 0FCh
  opSUB_thirdCMP equ 080h

  opSHR_AND equ 0FCh
  opSHR_CMP equ 0D0h
  opSHR_AND_two equ 038h
  opSHR_CMP_two equ 028h

  opROR_AND equ 038h
  opROR_CMP equ 08h

  opER_AND equ 0E7h
  opER_CMP equ 026h

  textDAS db 'DAS$'
  textDAA db 'DAA$'
  textAAS db 'AAS$'
  textAAA db 'AAA$'
  normal_operator_text_ptr dw textDAA, textDAS, textAAA, textAAS

  textINC db 'INC $'
  textPUSH db 'PUSH $'
  textSUB db 'SUB $'
  textSHR db 'SHR $'
  textROR db 'ROR $'

  has_SR db 0
  sr_bits db 0

.code
start:
  mov ax, @data
  mov ds, ax

  xor cx, cx
  mov cl, es:[80h]
  jcxz pabaiga
  mov si, 82h
  mov di, offset filename
get_file_name:
  mov al, es:[si]
  cmp al, ' '
  je found_filename
  cmp al, 0dh
  je found_filename
  mov [di], al 
  inc si 
  inc di
  loop get_file_name
  jmp pabaiga

found_filename:
  mov byte ptr [di], '$'

  call proccess_file
  ; mov byte ptr [di], '$'
  ; xor ax, ax
  ; mov ah, 09h
  ; mov dx, offset filename
  ; int 21h
  ; mov ah, 09h
  ; mov dx, offset endl
  ; int 21h

  mov di, offset filename
  inc si
  dec cx
  jcxz pabaiga
  ;jmp get_file_name

pabaiga:
  mov ax, 4C00h
  int 21h

proccess_file proc

open_file:
  mov ah, 3Dh
  mov al, 0
  mov dx, offset filename
  int 21h
  jc file_error
  mov handle, ax
read_file_loop:
  mov cx, blockBuffSize
  mov dx, offset fileBlockBuff
  mov bx, handle
  mov ah, 3Fh
  int 21h
  jc file_error

  mov bytesRead, ax
  cmp ax, 0
  je done_read

  call read_from_block

  jmp read_file_loop

file_error:
  mov ah, 09h
  mov dx, offset msg_error
  int 21h
done_read:
  mov ah, 3Eh
  mov bx, handle
  int 21h
  RET

proccess_file endp

read_from_block proc
  ;loop for bytesRead
  ;bx has handle, dx fileBlockBuff, al has byte, cx bytesRead
  xor cx, cx
  mov cx, bytesRead
  xor si, si
read_block_loop:

  mov al, [fileBlockBuff + si]
  call proccess_byte

loop_end:

  inc si
  loop read_block_loop

end_reading:

  RET

read_from_block endp

proccess_byte proc
  ;al has byte  bl will hold temp value for modification  others are free to use  
  PUSH bx
  PUSH cx
  PUSH dx

check_prefix:

  mov bl, al
  and bl, opER_AND
  cmp bl, opER_CMP
  jne no_prefix
  
  mov bl, al
  shr bl, 3
  and bl, 03h
  mov sr_bits, bl
  mov has_SR, 1
  
  inc si
  mov al, [fileBlockBuff + SI]
  jmp no_prefix_skip
  
no_prefix:
  mov has_SR, 0
no_prefix_skip:
  ; compare al to possible variants

  cmp al, opAAA
  jne skipAAA
  jmp operationAAA
  skipAAA:

  cmp al, opAAS
  jne skipAAS
  jmp operationAAS
  skipAAS:

  cmp al, opDAA
  jne skipDAA
  jmp operationDAA
  skipDAA:

  cmp al, opDAS
  jne skipDAS
  jmp operationDAS
  skipDAS:

  mov bl, al
  and bl, opINC_firstAND
  cmp bl, opINC_firstCMP
  jne skipINC
  jmp operationINC
  skipINC:

  mov bl, al
  and bl, opSUB_firstAND
  cmp bl, opSUB_firstCMP
  jne skipSUB
  jmp operationSUB
  skipSUB:

  mov bl, al
  and bl, opPUSH_secondAND
  cmp bl, opPUSH_secondCMP
  jne skipSecPush
  jmp operationPUSH_second
  skipSecPush:

  mov bl, al
  and bl, opPUSH_firstAND
  cmp bl, opPush_firstCMP
  jne skipPush
  jmp operationPUSH
  skipPush:

  mov bl, al
  and bl, opSUB_secondAND
  cmp bl, opSUB_secondCMP
  jne skipSUB_two
  jmp operationSUB_second
  skipSUB_two:

  mov bl, al
  and bl, opSUB_thirdAND
  cmp bl, opSUB_thirdCMP
  jne skipSUB_three
  jmp operationSUB_third
  skipSUB_three:

  ;when first byte checks fail
  mov bh, al
  inc si
  mov al, [fileBlockBuff + SI] 

  mov bl, al
  and bh, opSHR_AND
  cmp bh, opSHR_CMP
  jne skipSHR
  and bl, opSHR_AND_two
  cmp bl, opSHR_CMP_two
  jne skipSHR
  jmp operationSHR
  skipSHR:
  cmp bl, opROR_CMP
  jne skipROR
  jmp operationROR
  skipROR:

  mov bl, al
  mov bh, [fileBlockBuff + SI - 1]
  cmp bh, 0FEh
  je check_fe_ff
  cmp bh, 0FFh
  je check_fe_ff
  jmp skip_fe_ff

check_fe_ff:
  mov bl, al
  and bl, opINC_secondAMP
  cmp bl, opINC_secondCMP
  jne skip_check_two
  jmp operationINC_second
  skip_check_two:
  
  ; Check for PUSH (FF /6)
  cmp bh, 0FFh
  jne skip_fe_ff
  mov bl, al
  and bl, opPUSH_thirdAND
  cmp bl, opPUSH_thirdCMP
  jne skip_PushThird
  jmp operationPUSH_third
  skip_PushThird:
  
skip_fe_ff:
  
  jmp proccess_byte_finis

operationAAA:
  call print_cs
  xor ah, ah
  call print_op_hex

  mov dl, ' '
  call copy_char_to_buff

  mov dx, offset textAAA
  call copy_string_to_buff
  
  jmp proccess_byte_end

operationAAS:
  call print_cs
  xor ah, ah
  call print_op_hex

  mov dl, ' '
  call copy_char_to_buff
  
  mov dx, offset textAAS
  call copy_string_to_buff

  jmp proccess_byte_end

operationDAA:
  call print_cs
  xor ah, ah
  call print_op_hex

  mov dl, ' '
  call copy_char_to_buff

  mov dx, offset textDAA
  call copy_string_to_buff

  jmp proccess_byte_end

operationDAS:
  call print_cs
  xor ah, ah
  call print_op_hex
  
  mov dl, ' '
  call copy_char_to_buff
  
  mov dx, offset textDAS
  call copy_string_to_buff
  
  jmp proccess_byte_end

operationINC:
  call print_cs
  xor ah, ah
  call print_op_hex
  ; get reg from 3 last bytes, al has byte
  
  mov dl, ' '
  call copy_char_to_buff

  mov dx, offset textINC
  call copy_string_to_buff

  and al, 07h
  mov bl, 01h
  call print_reg
  jmp proccess_byte_end

operationSUB_second:
  call print_cs

  xor ah, ah
  call print_op_hex

  mov dl, ' '
  call copy_char_to_buff

  mov dx, offset textSUB
  call copy_string_to_buff

  mov bl, al
  and bl, 01h
  mov al, 00h
  call print_reg

  mov dl, ','
  call copy_char_to_buff

  inc si
  mov al, [fileBlockBuff + SI]
  call print_op_hex

  cmp bl, 00h
  je w_zero
w_one:
  inc si
  
  mov al, [fileBlockBuff + SI]
  call print_op_hex
  call print_hex

  mov al, [fileBlockBuff + SI - 1]
  call print_hex

  jmp proccess_byte_end
w_zero:
  call print_hex
  jmp proccess_byte_end

  jmp proccess_byte_end

operationSUB_third:
  call print_cs
  call print_op_hex

  mov dl, ' '
  call copy_char_to_buff

  mov dx, offset textSUB
  call copy_string_to_buff

  mov bl, al
  and bl, 01h

  inc si
  mov al, [fileBlockBuff + SI]
  call print_op_hex

  mov dl, al
  shr dl, 6
  and al, 07h

  call print_rm

  mov dl, ','
  call copy_char_to_buff

  inc si
  mov al, [fileBlockBuff + SI]
  call print_op_hex
  call print_hex

  jmp proccess_byte_end

operationINC_second:
  ;al - r/m, b - w, cl - d, ch - v, dl - mod, ah - prev bit
  ; mod 000 r/m [poslinkis]
  call print_cs

  mov al, [fileBlockBuff + SI -1]
  call print_op_hex
  mov ah, al
  mov al, [fileBlockBuff + SI]
  call print_op_hex

  mov dl, ' '
  call copy_char_to_buff

  
  mov dx, offset textINC
  call copy_string_to_buff


  mov bl, [fileBlockBuff + SI - 1]
  and bl, 01h
  mov dl, al
  shr dl, 6
  and al, 07h

  call print_rm

  jmp proccess_byte_end

operationPUSH_second:
  call print_cs
  xor ah, ah
  call print_op_hex

  mov dl, ' '
  call copy_char_to_buff

  mov dx, offset textPUSH
  call copy_string_to_buff

  and al, 07h
  mov bl, 01h
  call print_reg
  jmp proccess_byte_end

operationPUSH:
  call print_cs
  xor ah, ah
  call print_op_hex

  mov dl, ' '
  call copy_char_to_buff

  mov bl, al
  
  mov dx, offset textPUSH
  call copy_string_to_buff

  xor ah, ah
  mov al, bl

  shr al, 3
  call print_sr
  jmp proccess_byte_end

operationPUSH_third:
  ;1111 1111 mod 110 r/m [poslinkis]

  call print_cs

  mov al, [fileBlockBuff + SI -1]
  call print_op_hex
  mov ah, al
  mov al, [fileBlockBuff + SI]
  call print_op_hex

  mov dl, ' '
  call copy_char_to_buff

  mov dx, offset textPUSH
  call copy_string_to_buff

  mov bl, 1
  mov dl, al
  shr dl, 6

  cmp dl, 03h
  je push_third_reg

  ; PUSH AX
  ; PUSH DX
  ; mov ah, 09h
  ; mov dx, offset msg_word_ptr
  ; int 21h
  ; POP DX
  ; POP AX

push_third_reg:
  mov al, [fileBlockBuff + SI]
  and al, 07h
  call print_rm

  jmp proccess_byte_end
operationSUB:
  ;0010 10dw mod reg r/m  bl - w, cl - d
  PUSH ax
  call print_cs

  PUSH ax
  mov al, [fileBlockBuff + SI]
  call print_op_hex
  mov ah, al
  mov al, [fileBlockBuff + SI + 1]
  call print_op_hex
  POP ax

  mov dl, ' '
  call copy_char_to_buff

  mov dx, offset textSUB
  call copy_string_to_buff
  POP ax

  mov bl, al
  and bl, 01h
  mov cl, al
  shr cl, 1
  and cl, 01h

  inc si
  mov al, [fileBlockBuff + SI]

  mov dh, al
  mov dl, al
  shr dl, 6

  mov ch, dh
  shr ch, 3
  and ch, 07h

  and dh, 07h
  
  cmp cl, 1
  je SUB_clone
  jmp SUB_clzero

SUB_clzero:
  
  mov al, dh
  call print_rm
  
  PUSH dx
  mov dl, ','
  call copy_char_to_buff
  POP dx

  mov al, ch
  call print_reg
  jmp proccess_byte_end

SUB_clone:
  mov al, ch
  call print_reg

  PUSH dx
  mov dl, ','
  call copy_char_to_buff
  POP dx

  mov al, dh
  call print_rm

  jmp proccess_byte_end


operationSHR:
  ;ch - v, bl - w, dl-mod
  PUSH ax
  call print_cs

  PUSH ax
  mov al, [fileBlockBuff + SI]
  call print_op_hex
  mov ah, al
  mov al, [fileBlockBuff + SI + 1]
  call print_op_hex
  POP ax
  
  mov dl, ' '
  call copy_char_to_buff

  mov dx, offset textSHR
  call copy_string_to_buff
  POP ax

  mov ch, [fileBlockBuff + si - 1]
  shr ch, 1
  and ch, 01h

  mov bl, [fileBlockBuff + SI - 1]
  and bl, 01h
  mov dl, al
  shr dl, 6
  and al, 07h

  call print_rm

  PUSH dx
  PUSH ax
  mov dl, ','
  call copy_char_to_buff
  POP ax
  POP dx

  cmp ch, 00h
  jne SHR_clone
SHR_clz:
  mov dl, '1'
  call copy_char_to_buff

  jmp proccess_byte_end
SHR_clone:
  mov dx, offset regCL
  call copy_string_to_buff

  jmp proccess_byte_end

operationROR:
  PUSH ax
  call print_cs

  PUSH ax
  mov al, [fileBlockBuff + SI]
  call print_op_hex
  mov ah, al
  mov al, [fileBlockBuff + SI + 1]
  call print_op_hex
  POP ax

  mov dl, ' '
  call copy_char_to_buff

  mov dx, offset textROR
  call copy_string_to_buff
  POP ax

  mov ch, [fileBlockBuff + si - 1]
  shr ch, 1
  and ch, 01h

  mov bl, [fileBlockBuff + SI - 1]
  and bl, 01h
  mov dl, al
  shr dl, 6
  and al, 07h

  call print_rm

  PUSH dx
  PUSH ax
  mov dl, ','
  call copy_char_to_buff
  POP ax
  POP dx

  cmp ch, 00h
  jne ROR_clone
ROR_clz:
  mov dl, '1'
  call copy_char_to_buff
  jmp proccess_byte_end
ROR_clone:
  mov dx, offset regCL
  call copy_string_to_buff
  jmp proccess_byte_end

proccess_byte_end:
  mov has_SR, 0

  mov ah, 09h
  mov dx, offset instructionBuffer
  int 21h

  call erase_buff

  mov ah, 09h
  mov dx, offset endl
  int 21h

proccess_byte_finis:
  POP dx
  POP cx
  POP bx

  RET
proccess_byte endp

print_reg proc
  PUSH ax
  PUSH bx
  PUSH cx
  PUSH dx
  ;al has reg, bl has w
  cmp bl, 01h
  je reg_x
  jmp reg_l

reg_x:
  xor ah, ah
  shl al, 1
  lea bx, regAXptr
  add bx, ax

  mov dx, [bx]
  call copy_string_to_buff

  jmp print_reg_end

reg_l:
  xor ah, ah
  shl al, 1
  lea bx, regALptr
  add bx, ax

  mov dx, [bx]
  call copy_string_to_buff

print_reg_end:
  POP dx
  POP cx
  POP bx
  POP ax
  RET
print_reg endp

print_sr proc
;al has sr
  xor ah, ah
  shl al, 1
  lea bx, regESptr
  add bx, ax

  mov dx, [bx]
  call copy_string_to_buff

  RET
print_sr endp

print_rm proc
  PUSH ax
  PUSH bx
  PUSH cx
  PUSH dx
;if mod == 11 then print reg  bl is w
;if mod == 00 nera poslinkio
;al - r/m,  bl - w, cl - d, ch - v,  dl - mod dh - s
  cmp dl, 03h
  jne skip_rm_smth
  jmp rm_reg
  skip_rm_smth:

  cmp bl, 01h
  jne rm_print_byte


rm_word:
  PUSH dx
  mov dx, offset msg_word_ptr
  call copy_string_to_buff
  jmp rm_skip
rm_print_byte:
  PUSH dx
  mov dx, offset msg_byte_ptr
  call copy_string_to_buff
  jmp rm_skip
rm_skip:
  POP dx

  PUSH dx
  PUSH ax

  cmp has_SR, 0
  je skip_SR
  mov al, sr_bits
  call print_sr

  mov dl, ':'
  call copy_char_to_buff

skip_SR:
  mov dl, '['
  call copy_char_to_buff

  POP ax
  POP dx

rm:
  ;print rm if mod 00 and check if mod != 00

  cmp dl, 06h
  je print_direct
  jmp skip_direct
print_direct:
  mov al, [fileBlockBuff + SI]
  call print_hex
  jmp print_rm_end
skip_direct:

  xor ah, ah
  shl al, 1
  lea bx, rmTable
  add bx, ax
  PUSH dx

  mov dx, [bx]
  call copy_string_to_buff

  POP dx

  cmp dl, 0h
  je print_rm_end
rm_extra:
  PUSH dx
  PUSH ax
  mov dl, '+'
  call copy_char_to_buff
  POP ax
  POP dx

  inc si
  mov al, [fileBlockBuff + SI]

  cmp dl, 01h
  je rm_oneByte
  jmp rm_twoBytes

rm_oneByte:
  xor ah, ah
  call print_op_hex
  call print_hex
  jmp print_rm_end
rm_twoBytes:
  inc si
  mov al, [fileBlockBuff + SI]
  call print_op_hex
  call print_hex
  mov al, [fileBlockBuff + SI - 1]
  call print_op_hex
  call print_hex

  jmp print_rm_end

rm_reg:
  call print_reg
  jmp print_rm_finish
  RET

print_rm_end:
  mov dl, ']'
  call copy_char_to_buff

print_rm_finish:
  POP dx
  POP cx
  POP bx
  POP ax
  RET
print_rm endp

print_hex proc
  PUSH ax
  PUSH bx
  PUSH cx
  PUSH dx

  mov cl, al
  
  mov al, cl
  shr al, 4
  and al, 0Fh
  call print_nibble
  
  mov al, cl
  and al, 0Fh
  call print_nibble

  POP dx
  POP cx
  POP bx
  POP ax
  RET
print_hex endp

print_nibble proc
  cmp al, 9
  jle digit
  add al, 7
digit:
  add al, '0'
  mov dl, al
  call copy_char_to_buff
  RET
print_nibble endp

print_cs proc
PUSH ax
PUSH dx
PUSH cx

  mov dx, offset msg_cs
  mov ah, 09h
  int 21h

  mov cx, si
  mov al, ch
  call print_op_hex
  mov al, cl
  call print_op_hex

  mov dl, ' '
  mov ah, 02h
  int 21h
  
  mov ah, 09h
  mov dx, offset instructionBuffer
  int 21h

  call erase_buff
  
  POP cx
  POP dx
  POP ax
  RET
print_cs endp

print_op_hex proc
  PUSH ax
  PUSH bx
  PUSH cx
  PUSH dx

  mov cl, al
  
  mov al, cl
  shr al, 4
  and al, 0Fh
  call print_op_nibble
  
  mov al, cl
  and al, 0Fh
  call print_op_nibble

  POP dx
  POP cx
  POP bx
  POP ax
  RET
print_op_hex endp

print_op_nibble proc
  cmp al, 9
  jle op_digit
  add al, 7
op_digit:
  add al, '0'
  mov dl, al
  mov ah, 02h
  int 21h
  RET
print_op_nibble endp

copy_char_to_buff proc
    push di

    lea di, instructionbuffer

find_end:
    cmp byte ptr [di], '$'
    je store_char
    inc di
    jmp find_end

store_char:
    mov byte ptr [di], dl

    pop di
    ret
copy_char_to_buff endp

copy_string_to_buff proc
    push ax
    push si
    push di

    mov si, dx
    lea di, instructionbuffer

find_dst_end:
    cmp byte ptr [di], '$'
    je copy_loop
    inc di
    jmp find_dst_end

copy_loop:
    mov al, byte ptr [si]
    cmp al, '$'
    je done

    mov byte ptr [di], al
    inc si
    inc di
    jmp copy_loop

done:
    pop di
    pop si
    pop ax
    ret
copy_string_to_buff endp

erase_buff proc
    push cx
    push di

    lea di, instructionbuffer
    xor ch, ch
    mov cl, instructionbuffersize

clear_loop:
    mov byte ptr [di], '$'
    inc di
    loop clear_loop

    pop di
    pop cx
    ret
erase_buff endp

end start