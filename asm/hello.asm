%include "cons.inc"
%include "sys.inc"
%include "dos.def"

global main

	segment stack stack class=stack
resb 100h

        segment data    class=data
msg db 'Hello, World!', 0Dh, 0Ah, 0

        segment code    class=code
main:
;	mov	ax, data
;	mov	ds, ax

	mov	ax, msg
	push	ax
	call	prstr
	call	term
