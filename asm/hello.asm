%include "cons.inc"
%include "sys.inc"
%include "dos.def"

global main

	segment stack stack class=stack
resb 100h

        segment data    class=data
msg1 db 'Hello, World!', 0Dh, 0Ah, 0
msg2 db 'Hello, World!', 0Dh, 0Ah, 0
msg3 db 'Hello, World!', 0Dh, 0Ah, 0

        segment code    class=code
main:

	mov	ax, msg1
	push	ax
	call	prstr

	mov	ax, msg2
	push	ax
	call	prstr

	mov	ax, msg3
	push	ax
	call	prstr

	call	term
