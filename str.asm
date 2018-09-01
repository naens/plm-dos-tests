global strcmp, strlen, xstr2word, dstr2int, int2xstr, int2dstr

%include "cons.inc"

;****h* plm-exercises/str
;  NAME
;    str -- String functions
;  DESCRIPTION
;    Module for string comparison and transformation.
;  USES
;    dos.def, cons.asm
;****

%include "dos.def"

;****f* plm-exercises/strcmp
;  NAME
;    strcmp -- compare two strings
;  DESCRIPTION
;    Returns a boolean value telling whether two strings are equal.  String
;    can be of length zero.
;  PARAMETERS
;    pstr1 - first string
;    pstr2 = second string
;  RETURN VALUE
;    Returns a boolean true if strings are equal and false otherwise.
;****
strcmp:
	push	bp
	mov	bp, sp

	mov	si, [bp+6]
	mov	di, [bp+4]

.l:
	mov	al, [si]
	cmp	al, [di]
	jne	.f		; if different then return false
	test	al, al
	jz	.t		; if both at end then return true
	inc	si
	inc	di
	jmp	.l

.f:
	mov	ax, 0
	jmp	.e

.t:
	mov	ax, -1

.e:
	pop	bp
	ret	4


;****f* plm-exercises/strlen
;  NAME
;    strlen -- get the length of a string
;  DESCRIPTION
;    Returns the number of characters in a null-terminated string before the
;    null character.
;  PARAMETERS
;    pstr - string
;  RETURN VALUE
;    Returns the length of the string.
;****
strlen:
	push	bp
	mov	bp, sp

	mov	bx, [bp+4]
	mov	ax, 0

.l:
	mov	cl, [bx]
	cmp	cl, 0
	jz	.e
	inc	ax
	inc	bx
	jmp	.l

.e:
	pop	bp
	ret	2

;****f* str/xstr2word
;  NAME
;    xtr2int -- convert a string containing a hexadecimal number to word
;  DESCRIPTION
;    Converts a null-terminated string containing a hexadecimal integer to
;    word (unsigned 16-bit integer type).  Reads as long as the string
;    contains legal hexadecimal characters, stops when other character is
;    detected (can overflow).  Returns the resulting word.
;  PARAMETERS
;    pstr - pointer to string to read
;  RETURN VALUE
;    Returns the value of the integer represented by the string.
;****
;  bx := pstr
;  res := 0
;  do while [bx] matches [0-9a-fA-F]
;    if [bx] matches [0-9] then
;      add res, [bx] - '0'
;    else if [bx] matches [a-f]
;      add res, [bx] - 'a' + 10
;    else
;      add res, [bx] - 'A' + 10
;  end
;  return res
xstr2word:
	push	bp
	mov	bp, sp

	mov	bx, [bp+4]
	mov	ax, 0

	mov	dh, 0

.l:
	mov	dl, [bx]
	cmp	dl, '0'
	jb	.c2
	cmp	dl, '9'
	ja	.c2
	sub	dl, '0'
	jmp	.cont
.c2:
	cmp	dl, 'a'
	jb	.c3
	cmp	dl, 'f'
	ja	.c3
	sub	dl, 'a' - 10
	jmp	.cont
.c3:
	cmp	dl, 'A'
	jb	.e
	cmp	dl, 'F'
	ja	.e
	sub	dl, 'A' - 10
.cont:
	mov	cl, 4
	shl	ax, cl
	add	ax, dx
	inc	bx
	jmp	.l

.e:
	pop	bp
	ret	2

; convert decimal string to integer
dstr2int:

; convert integer to hexadecimal string
int2xstr:

; convert integer to decimal string
int2dstr:
