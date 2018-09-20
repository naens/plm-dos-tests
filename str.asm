global strcmp, strlen, xstr2word, xstr2byte, dstr2int, word2xstr, byte2xstr, int2dstr

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
;    Compares two strings and returns 0 if they are equal, -1 or 1 if the
;    first string is before or after in code-point order.
;  PARAMETERS
;    pstr1 - first string
;    pstr2 = second string
;  RETURN VALUE
;    Returns an integer telling if the first string is before, equal or
;    after in code-point ordering the second string.
;****
strcmp:
	push	bp
	mov	bp, sp

	mov	si, [bp+6]
	mov	di, [bp+4]

.l:
	mov	al, [si]
	cmp	al, [di]
	jb	.b		; if different then return false
	ja	.a
	test	al, al
	jz	.eq		; if both at end then return true
	inc	si
	inc	di
	jmp	.l

.b:
	mov	ax, -1
	jmp	.e

.a:
	mov	ax, 1
	jmp	.e

.eq:
	mov	ax, 0
	jmp	.e

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

;****f* str/xstr2byte
;  NAME
;    xstr2byte -- convert a string to number and return a byte
;  DESCRIPTION
;    Converts a hexadecimal representation of a number to a number and
;    returns it as a single byte.
;  PARAMETERS
;    pstr -- pointer to the string to read
;  RETURN VALUE
;    Returns the value represented by the string.
;****
xstr2byte:
	jmp	xstr2word

;****f* str/dstr2int
;  NAME
;    dstr2int -- convert a decimal string to signed integer
;  DESCRIPTION
;    Converts a null terminated string, positive or negative to a 16-bit
;    signed integer.  If the string is empty 0 is returned.
;  PARAMETERS
;    pstr - pointer to string representing the integer that has to be
;    converted.
;  RETURN VALUE
;    Returns a signed integer corresponding to the input string.
;****
;  Pseudocode:
;    res := 0
;    ptr := pstr
;    while [ptr] >= '0' and [ptr] <= '9' do
;      res = res * 10
;      res += [ptr] - '0'
dstr2int:
	push	bp
	mov	bp, sp

	mov	bx, [bp+4]
	mov	cx, 10
	mov	ax, 0
	mov	dh, 0
.l:
	mov	dl, [bx]
	cmp	dl, '0'
	jb	.e
	cmp	dl, '9'
	ja	.e
	mul	cx
	sub	dl, 10
	add	ax, dx
	inc	bx
	jmp	.l
.e:
	pop	bp
	ret

;****f* str/word2xstr
;  NAME
;    word2xstr -- convert integer to hexadecimal string
;  DESCRIPTION
;    Creates a hexadecimal string representation of an integer.  The string
;    is null-terminated and should be big enough to contain the resulting
;    string.  The number is read as unsigned.  The string will be of length
;    4, with leading zeros if needed.
;  PARAMETERS
;    w - the word to convert
;    pbuf - the address where the string will be stored
;  RETURN VALUE
;    There is no return value
;****
	segment	data	class=data
digits		db 	'0123456789abcdef'

	segment code	class=code
word2xstr:
	push	bp
	mov	bp, sp
	mov	ax, [bp+6]
	mov	di, [bp+4]
	mov	si, digits
	mov	bh, 0
	mov	dx, ax
	and	dx, 0f0fh
	mov	bl, dh
	mov	cl, [bx+si]
	mov	[di+3], cl
	mov	bl, dl
	mov	cl, [bx+si]
	mov	[di+1], cl
	and	ax, 0f0f0h	; playing with ax from here
	mov	cl, 4
	shr	ax, cl
	mov	bl, ah
	mov	cl, [bx+si]
	mov	[di+2], cl
	mov	bl, al
	mov	cl, [bx+si]
	mov	[di+0], cl
	mov	byte [di+4], 0
	pop	bp
	ret

;****f* str/byte2xstr
;  NAME
;    byte2xstr -- create a hexadecimal string representation of a byte
;  DESCRIPTION
;    Writes a null-terminated hexadecimal string representation of the byte
;    given as parameter.  The string can contain a leading zero in order to
;    have the length of 2.
;  PARAMETERS
;    b - the byte to create the string from
;    pbuf - buffer where to write the string
;  RETURN VALUE
;    Does not return anything
;****
byte2xstr:
	push	bp
	mov	bp, sp
	mov	al, [bp+6]
	mov	di, [bp+4]
	mov	si, digits
	mov	bh, 0
	mov	dl, al
	and	dl, 0fh
	mov	bl, dl
	mov	cl, [bx+si]
	mov	[di+1], cl
	and	al, 0f0h
	mov	cl, 4
	shr	dx, cl
	mov	bl, al
	mov	cl, [bx+si]
	mov	[di+0], cl
	mov	byte [di+2], 0
	pop	bp
	ret


; convert integer to decimal string
int2dstr:
