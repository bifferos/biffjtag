BITS 32
global _start

extern main
section .text

; open <filename>, <filename len>
global open
open:
	push	ebp
	mov	ebp, esp
	push	edx
	push	ecx
	push 	ebx
	mov edx, [ebp+16]	; mode
	mov ecx, [ebp+12]	; flags
	mov ebx, [ebp+8]	; filename (null term)
	xor eax, eax
	mov al, 5	; syscall for open (unistd_32)
	int 0x80
	pop	ebx
	pop	ecx
	pop	edx
	leave
	ret


; C library, print function
global write
write:
	push	ebp
	mov	ebp, esp
	push	edx
	push	ecx
	push 	ebx
	mov edx, [ebp+16]	
	mov ecx, [ebp+12]	
	mov ebx, [ebp+8]	; STDOUT==1
	xor eax, eax
	mov al, 4		; syscall for write (unistd_32)
	int 0x80	    	; write to stdout.
	pop	ebx
	pop	ecx
	pop	edx
	leave
	ret


global read
read:
	push	ebp
	mov	ebp, esp
	push	edx
	push	ecx
	push 	ebx
	mov edx, [ebp+16]	
	mov ecx, [ebp+12]	
	mov ebx, [ebp+8]	
	xor eax, eax
	mov al, 3		; syscall for write (unistd_32)
	int 0x80	    	; write to stdout.
	pop	ebx
	pop	ecx
	pop	edx
	leave
	ret



global ioperm
ioperm:
	push	ebp
	mov	ebp, esp
	push	edx
	push	ecx
	push 	ebx
	mov edx, [ebp+16]	
	mov ecx, [ebp+12]	
	mov ebx, [ebp+8]	
	xor eax, eax
	mov al, 101		; syscall for ioperm (unistd_32)
	int 0x80	    	; write to stdout.
	pop	ebx
	pop	ecx
	pop	edx
	leave
	ret

  
