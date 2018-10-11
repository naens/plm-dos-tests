global entry, getargs, term

extern main, prchr, prstr, prcrlf, prhexbyte, prhexword, prstr, readkey, readln

;****h* plm-exercises/sys
;  NAME
;    sys -- System library
;  DESCRIPTION
;    Module that contains system-related functions.
;  USES
;    dos.def, cons.asm
;****

%include "dos.def"

;****f* sys/entry
;  NAME
;    entry
;  DESCRIPTION
;    Initialize the system, must be called on program start.  The entry
;    function is the starting point, called before the program.  After
;    initialization it jumps to the real beginning of the program at
;    cs:0000h.
;  PARAMETERS
;    No parameters.
;  RETURN VALUE
;    Doesn't return anything.
;****

        segment data class=data
psp		resw	1
tail		resb	0ffh
tlen		resb	1

        segment code class=code
entry:
..start:
	; save psp
	push	ds		; push psp value
	mov	ax, data
	mov	ds, ax
	pop	ax
	mov	[psp], ax	; store psp

	; copy tail
	mov	es, ax
	mov	cl, [es:80h]
	mov	[tlen], cl
	mov	si, 81h
	mov	di, tail
.l:
	cmp	cl, 0
	je	.e
	mov	al, [es:si]
	mov	[di], al

	inc	di
	inc	si
	dec	cl
	jmp	.l
.e:
	mov	byte [di], 0

	; jump to the code
	jmp	main


;****f* sys/getargs
;  NAME
;    getargs -- get command line arguments vector
;  DESCRIPTION
;    Allocates the vector of pointers to the command line arguments.
;  PARAMETERS
;    pargc - pointer to a word value, for the count of arguments
;    pargv - pointer to an address value, that will contain the address of
;            the allocated array of adresses of command line arguments.
;  RETURN VALUE
;    Doesn't return a value.
;****
        segment data
max_argv	equ	15		; TODO: replace with alloc/freemem
argv		resw	max_argv+1
teststr		db      'test', 0
hellostr	db      'HELLO!', 0
tmpstr		resb	100

        segment code
getargs:
	push	bp
	mov	bp, sp

	call	getname

; copy the program name from es:bx to local variable
	mov	di, tmpstr
.l:
	je	.m
	mov	al, [es:bx]
	mov	[ds:di], al
	cmp	al, 0
	je	.m
	inc	bx
	inc	di
	jmp	.l
.m:
	mov	word [argv], tmpstr

; put cli argument addresses into argv
	mov	si, tail
	mov	di, 2		; second item of argv
	mov	dx, 1		; is_space in dx=true
	mov	cx, 1		; count of arguments

.tl:
	mov	al, [si]
	cmp	al, 0
	je	.te

	; from space to word => store word
	cmp	dx, 1
	jne	.tw
	cmp	al, ' '
	je	.tc
	mov	[argv+di], si
	add	di, 2
	mov	dx, 0
	inc	cx
	jmp	.tc

	; from word to space => store null
.tw:
	cmp	al, ' '
	jne	.tc
	mov	byte [si], 0
	cmp	cx, max_argv	; if maximum reached, stop here
	je	.te
	mov	dx, 1
.tc:
	inc	si
	jmp	.tl
.te:

	; terminate argv with null
	mov	word [argv+di], 0

	mov	bx, [bp+6]	; set argc value
	mov	word [bx], cx

	mov	bx, [bp+4]	; set pointer to argv
	mov	word [bx], argv

	pop	bp
	ret	4

; return the program name string in es:bx (private)
getname:
	mov	ax, [psp]
	mov	es, ax
	mov	ax, [es:2ch]
	mov	es, ax
	mov	bx, 0

.lp:
	mov	al, [es:bx]
	cmp	al, 0
	je	.e

.strlp:
	mov	al, [es:bx]
	cmp	al, 0
	je	.stre
	inc	bx
	jmp	.strlp
.stre:
	inc	bx
	dec	cx
	jmp	.lp
.e:

	add	bx, 3
	ret

;****f* sys/term
;  NAME
;    term -- Terminate the program
;  DESCRIPTION
;    Terminate the program.
;  PARAMETERS
;    No parameters.
;  RETURN VALUE
;    Doesn't return anything.
;****
term:
	mov	al, 0
	mov	ah, dosexit
	int	dos
