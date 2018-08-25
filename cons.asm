global prchr, prstr, prcrlf, prhexbyte, prhexword, readkey, readln

;****h* plm-exercises/cons
;  NAME
;    cons -- Console Input and Output
;  DESCRIPTION
;    Module for Console Input and Output.
;  USES
;    dos.def
;****

%include "dos.def"

;****f* cons/prchr
;  NAME
;    prchr -- print single ASCII character
;  DESCRIPTION
;    Prints a single character givan as argument of type byte.
;  PARAMETERS
;    chr - character to print
;  RETURN VALUE
;    Doesn't return anything.
;****
prchr:
	push	bp
	mov	bp, sp
	mov	dl, [bp+4]
	mov	ah, conout
	int	dos
	pop	bp
	ret	2

;****f* cons/prhexbyte
;  NAME
;    prhexbyte -- print a byte in hexadecimal form
;  DESCRIPTION
;    Prints a byte in hexadecimal lowercase form.
;  PARAMETERS
;    b - byte to print
;  RETURN VALUE
;    Doesn't return anything.
;****
prhexbyte:
	push	bp
	mov	bp, sp
	mov	dl, [bp+4]

	call	pxbyte

	pop	bp
	ret	2

; prints byte in dl in hex format (private)
pxbyte:
	mov	bl, dl
	mov	cl, 4
	shr	dl, cl
	call	pxnib

	mov	dl, bl
	and	dl, 0fh
	call	pxnib
	ret

; prints nibble in dl in hex format (private)
pxnib:
	cmp	dl, 10
	jb	.pr
	add	dl, 'a'-'0'-10
.pr:
	add	dl, '0'
	mov	ah, conout
	int	dos
	ret


;****f* cons/prhexword
;  NAME
;    prhexword -- print a word (16-bits) in hexadecimal form
;  DESCRIPTION
;    Prints a word in hexadecimal lowercase form, without spaces, using 4
;    characters, zeros are added if needed so that the total of printed
;    characters be always four.
;  PARAMETERS
;    w - word to print
;  RETURN VALUE
;    Doesn't return anything.
;****
prhexword:
	push	bp
	mov	bp, sp
	mov	dx, [bp+4]
	xchg	dl, dh
	call	pxbyte
	mov	dl, dh
	call	pxbyte
	pop	bp
	ret	2


;****f* cons/prstr
;  NAME
;    prstr -- Prints a null-terminated 7-bit ASCII string.
;  DESCRIPTION
;    Print the string on the console.
;  PARAMETERS
;     pstr - address of the first character of the string
;  RETURN VALUE
;     Doesn't return anything.
;****

	segment data class=data

	segment code class=code

prstr:
	push	bp
	mov	bp, sp
	push	si
	mov	si, [bp+4]
.lp:
	lodsb
	cmp	al, 0
	je	.e
	xchg	ax, dx
	mov	ah, conout
	int	dos
	jmp	.lp
.e:
	pop	si
	pop	bp
	ret	2

;****f* cons/prcrlf
;  NAME
;    prstr -- Prints CRLF
;  DESCRIPTION
;    Prints CRLF.
;  PARAMETERS
;     no parameters
;  RETURN VALUE
;     Doesn't return anything.
;****
prcrlf:
	mov	dl, 0dh
	mov	ah, conout
	int	dos
	mov	dl, 0ah
	mov	ah, conout
	int	dos
	ret


;****f* cons/readkey
;  NAME
;    readkey -- Read a single keypress (modifiers not included)
;  DESCRPTION
;    Reads a single key and stores it at the address pointed by the pkey
;    parameter.
;  PARAMETERS
;    pkey - address of the word value which has to be filled with data from
;           the key press
;  RETURN VALUE
;    Doesn't return a value.
;****
readkey:
	push	bp
	mov	bp, sp

	mov	ah, coninq
	int	dos
        cmp	al, 32
        jae	.l
	add	al, 'A'-1
.l:
	mov	bl, al
	mov	ah, 2
	int	kbserv
	mov	ah, al
	mov	al, bl

	mov	bx, [bp+4]
	mov	[bx], ax
	pop	bp
	ret	2

;****f* cons/readln
;  NAME
;    readln -- Read one line from standard input
;  DESCRIPTION
;    Reads one line from the standard input and stores at the address
;    indicated by the first parameter.  The string is null-terminated.
;  PARAMETERS
;    pstr - address of the destination where to write the string.
;    len - maximum length of the string to read (last null byte included.
;  RETURN VALUE
;    Doesn't return a value.
;****

readln:
	push	bp
	mov	bp, sp

	mov	bx, [bp+6]
	push	bx
	mov	ax, [bp+4]
	dec	ax
	mov	[bx], ax
	mov	dx, bx

	mov	ah, rdstr
	int	dos

	pop	bx
	mov	bx, dx
	mov	al, [bx+1]
	mov	ah, 0
	mov	si, ax
	mov	byte [bx+si+2], 0

	mov	di, 0
.l:
	cmp	di, si
	ja	.e
	mov	al, [bx+di+2]
	mov	[bx+di], al
	inc	di
	jmp	.l
.e:
	call	prcrlf
	pop	bp
	ret	4
