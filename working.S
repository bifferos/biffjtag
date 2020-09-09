BITS 32

section .text

%define BIT_TDI  1
%define BIT_TCK  2
%define BIT_TMS  4

%define BIT_ENABLE 0x10
%define BIT_CABLE 0x40


; assem_outb(value)
global xilinx_outb
xilinx_outb:
	mov dx, 0x378
	mov al, [esp+4]		; filename (null term)
	and al, 0x7	
	or  al, BIT_ENABLE|BIT_CABLE
	out dx, al
	ret


global xilinx_set_state_0_1  ; tms, tdi
xilinx_set_state_0_1:
	mov dx, 0x378
	mov al, BIT_TDI|BIT_ENABLE|BIT_CABLE
	out dx, al
	; CLK high
	mov al, BIT_TDI|BIT_ENABLE|BIT_CABLE|BIT_TCK
	out dx, al
	ret


global xilinx_set_state_1_0  ; tms, tdi
xilinx_set_state_1_0:
	mov dx, 0x378
	mov al, BIT_TMS|BIT_ENABLE|BIT_CABLE
	out dx, al
	; CLK high
	or  al, BIT_TCK
	out dx, al
	ret


global xilinx_set_state_0_0  ; tms, tdi
xilinx_set_state_0_0:
	mov dx, 0x378
	mov al, BIT_ENABLE|BIT_CABLE
	out dx, al
	; CLK high
	or  al, BIT_TCK
	out dx, al
	ret


global xilinx_sample
xilinx_sample:
	; Clock high
	mov dx, 0x378
	mov al, BIT_TCK|BIT_ENABLE|BIT_CABLE
	out dx, al
	; clock low
	and al, ~BIT_TCK
	out dx, al
	; sample
	mov dx, 0x379
	xor eax, eax
	in  al, dx
	and al, 16
	ret


global xilinx_shift_out
xilinx_shift_out:
	; Clear our tmp storage
	xor eax, eax
	mov [tmp], eax

	mov ecx, [esp+4]	; number of bits
	xor ebx, ebx
	inc bl			; Index==1
loop1:	
	call xilinx_sample
	and  al, 16
	jz   skip
	mov  eax, [tmp]
	or   eax, ebx
	mov  [tmp], eax
skip:
	shl  ebx, 1		; inc the mask
	loop loop1
	mov eax, [tmp]
	ret	

section .data
tmp	dd	0	

;    unsigned long index = 1;
;    unsigned long out = 0;
;    unsigned int i;
;    for (i=0;i<bits;i++) 
;    {
;      if (assem_sample())
;        out |= index;
;      index <<= 1;
;    }


