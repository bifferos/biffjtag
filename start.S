BITS 32
global _start, _exit, exit

extern main

section .text

  
_start:
	pop ebp		    ; argc
	mov [argc], ebp
	mov eax, argv

arg:
	pop ecx
	mov [eax], ecx
	add eax, 4
	test ecx,ecx
	jnz arg

	push argv
	push ebp

	call main
	mov ebx, eax	    ; return code
	xor eax, eax
	inc eax             ; int #1, quit
	int 0x80            ; make the call



exit:
_exit:
	mov ebx, [esp+4]	; filename (null term)
	xor eax, eax
	inc eax             ; int #1, quit
	int 0x80            ; make the call



section .data
;
;
argc:    dd 0
argv:    times 50 dd 0

;argc:   resd 1
;argv:   resd 50		    ; up to 50 slots


