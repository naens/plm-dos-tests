global entry, getargs, term

;****h* plm-exercises/sys
;  NAME
;    sys -- System library
;  DESCRIPTION
;    Module that contains system-related functions.
;  USES
;    dos.def
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

        segment code class=code
entry:	
	push	ds		; push psp value
	mov	ax, data
	mov	ds, ax
	pop	ax
	mov	[psp], ax	; store psp
	mov	ax, 0
	jmp	ax

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
        segment data class=data
argv		resw	10
teststr		db      'test', 0
hellostr	db      'HELLO!', 0
tmpstr		resb	100

        segment code class=code
getargs:
	push	bp
	mov	bp, sp

	mov	di, tmpstr
	call	getname

; copy the program name from es:bx to local variable
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

; TODO copy cli arguments into argv while counting arguments

	mov	ax, [psp]
	mov	es, ax
	mov	ax, [es:80h]
	mov	es, ax		; set es:0000 to the cli tail


	mov	word [argv], teststr
	mov	word [argv+2], hellostr
	mov	word [argv+4], tmpstr
	mov	word [argv+6], 0

	mov	bx, [bp+6]	; set argc value
	mov	word [bx], 1
	mov	bx, [bp+4]	; set pointer to argv
	mov	word [bx], argv

	pop	bp
	ret

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
