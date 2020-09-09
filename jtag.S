BITS 32

section .text

; Offset by one byte off oxcfc - so OP uses fewer instructions
%define PORT 0xcfd

%define BIT_TDO_POS 1      ; to make it '1' or '0'
%define BIT_TDI_POS 5      ; to make it '1' or '0'

%define BIT_TDI  (1<<BIT_TDI_POS)
%define BIT_TCK  (1<<(12-8))
%define BIT_TMS  (1<<(11-8))
%define BIT_TDO  (1<<BIT_TDO_POS)


%macro delay 1
%rep %1
	in al, dx
%endrep
%endmacro

 

%macro  set_state 1
	mov	dx, PORT
        mov     al, BIT_TDO|%1    ; keep TDO high at all times for input.
        out     dx, al
        mov     al, BIT_TDO|%1|BIT_TCK    ; bring clock high
        out     dx, al
%endmacro



%macro set_state_0_1 0  ; tms, tdi
	set_state BIT_TDI
%endmacro

%macro set_state_1_0 0  ; tms, tdi
	set_state BIT_TMS
%endmacro

%macro set_state_0_0 0  ; tms, tdi
	set_state 0
%endmacro

%macro any_to_reset 0  ; tms, tdi
	; Return to tlr, from any state.  Do this at the start!
	set_state_1_0
	set_state_1_0
	set_state_1_0
	set_state_1_0
	set_state_1_0
%endmacro

%macro idle_to_shift_ir 0
    set_state_1_0;  ; SELECT_DR_SCAN
    set_state_1_0;  ; SELECT_IR_SCAN
    set_state_0_0;  ; CAPTURE_IR
    set_state_0_0;  ; SHIFT_IR
%endmacro

%macro idle_to_reset 0
    set_state_1_0  ; SELECT_DR_SCAN
    set_state_1_0  ; SELECT_IR_SCAN
    set_state_1_0  ; RESET
%endmacro

%macro idle_to_shift_dr 0
    set_state_1_0  ; SELECT_DR_SCAN
    set_state_0_0  ; CAPTURE_DR
    set_state_0_0  ; SHIFT_DR
%endmacro

%macro reset_to_idle 0
    ; keep in reset for a few cycles - sometimes RDC loader software does only one 
    ; of these, sometimes two.  Two shouldn't hurt
    set_state_1_0
    set_state_1_0  
    set_state_0_0  ; RUN_TEST_IDLE
%endmacro

%macro shift_to_update 0
    ; The same for both IR and DR - the most common transition
    set_state_1_0  ; EXIT_[DR|IR]
    set_state_1_0  ; UPDATE_[DR|IR]
%endmacro

%macro update_to_shift_dr 0
    ; Round the loop to read another value
    set_state_1_0  ; select DR
    set_state_0_0  ; capture DR
    set_state_0_0  ; shift
%endmacro

%macro update_to_idle 0
    set_state_0_0  ; IDLE
%endmacro

%macro shift_to_idle 0
    ; The same for both IR and DR - the most common transition
    shift_to_update
    set_state_0_0  ; IDLE
%endmacro


;==================================================
;
; Write values out
;
;==================================================


; ebx = out value
; arg = number of bits
; eax, ebx, ecx, edx trashed on return.
%macro shift_in 1
	mov dx, PORT
%rep %1
	mov  al, bl
	and  al, 1
	shl  al, BIT_TDI_POS
	or   al, BIT_TDO
        out  dx, al
	or   al, BIT_TCK
        out  dx, al
	shr  ebx, 1		; shift right, trash lsb
%endrep
%endmacro


;==================================================
;
; Read in values (sampling in), value returned in eax
;
;==================================================


; pass number of bits to this macro
%macro sample 1
	shr ebx, 1
	mov al, BIT_TDO|BIT_TCK
	out dx, al
	mov al, BIT_TDO  ; clock low
	out dx, al
	in  al, dx
	and eax, BIT_TDO  ; remove other bits
	shl eax, %1 - BIT_TDO_POS -1    ; shift it up to fill point
	or ebx, eax
%endmacro


; bit count in ecx
; returns value in eax
%macro shift_out 1
	mov dx, PORT
	xor ebx, ebx	       ; holds our result.
%rep %1
	sample %1              ; sample in bit position 16.
%endrep
	mov eax, ebx
%endmacro




; arg1 - command to send
%macro write_ir 1
    ;IR writes always come from and go to idle state
    idle_to_shift_ir
    mov bl, %1		; Always 8-bit, fits in bl
    shift_in 8
    shift_to_idle
%endmacro


; Arg 1 - bit count
; Return value in eax
%macro read_dr 1
    ; dr reads always go to update state
    shift_out %1
    mov ebx, eax
    shift_to_update
    mov eax, ebx
%endmacro




; ebx has the value to write
%macro write_dr 1
    shift_in %1
    shift_to_update
%endmacro


; in all cases ebx has value to write
%macro write_dr8 0
	write_dr 8
%endmacro
%macro write_dr16 0
	write_dr 16
%endmacro
%macro write_dr32 0
	write_dr 32
%endmacro



global jtag_init
jtag_init:
    mov dx, PORT
    any_to_reset         ; Put into test-logic reset from wherever it is now.



;%rep 30
;    reset_to_idle
;    write_ir 0x01        ; back to idle
;    idle_to_reset
;%endrep



.loop:  
    reset_to_idle

    write_ir 0x01        ; back to idle
;    idle_to_reset
;    reset_to_idle

    delay 60

    write_ir 0x0f        ; back to idle

    delay 60

    idle_to_shift_dr
    shift_out 16
    ; store eax
    mov ebx, eax
    shift_to_idle

    test ebx, 0xffff
    jz .cont
    mov eax, ebx
    ret
.cont:
    idle_to_reset
    jmp .loop




%macro MemAccess_impl 2
	write_ir 0x11
	idle_to_shift_dr
	mov ebx, %1
	write_dr32
	update_to_shift_dr    ;  more to go
	mov ebx, %2
	write_dr8
%endmacro 



; Arg1 addr
; Arg2 code
global jtag_MemAccess
jtag_MemAccess:
	mov dx, PORT
	MemAccess_impl [esp+4],[esp+8]

	ret


; Arg 1 addr
global jtag_ReadMem16
jtag_ReadMem16:
	mov dx, PORT
	MemAccess_impl [esp+4],0x19

	update_to_shift_dr
	read_dr 16
	mov ebx, eax
	update_to_idle
	mov eax, ebx
	ret


; Arg 1 addr
; Arg 2 val
global jtag_WriteMem16
jtag_WriteMem16:
	mov dx, PORT
	MemAccess_impl [esp+4],0x1d

	update_to_shift_dr
	mov ebx, [esp+8]
	write_dr16
	update_to_idle
	ret


; Arg 1 val
global jtag_write_ir
jtag_write_ir:
	write_ir [esp+4]
;	delay 400
	ret

global jtag_idle_to_shift_dr
jtag_idle_to_shift_dr:
	idle_to_shift_dr
	ret

global jtag_read_dr8
jtag_read_dr8:
;	delay 400
	read_dr 8
	ret

global jtag_read_dr16
jtag_read_dr16:
;        delay 200
	read_dr 16
	ret

global jtag_read_dr32
jtag_read_dr32:
;	delay 400
	read_dr 32
;	delay 400
	ret

global jtag_update_to_idle
jtag_update_to_idle:
	update_to_idle
	ret

global jtag_update_to_shift_dr
jtag_update_to_shift_dr:
	update_to_shift_dr
	ret

global jtag_write_dr32
jtag_write_dr32:
	mov ebx, [esp+4]
	write_dr32
	ret


