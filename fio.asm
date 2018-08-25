global fopen, fclose, freadchr, freadbuf, fwritechr, fwritebuf, \
    fwritestr, fseek, ftrunc

extern prchr, prstr, prcrlf, prhexbyte, prhexword, prstr, readkey, readln

;****h* plm-exercises/fio
;  NAME
;    fio -- File Input and Output
;  DESCRIPTION
;    Module for reading and writing to files.
;  USES
;     dos.def, cons.asm
;****

%include "dos.def"

bufsz		equ	512	; the size of the buffer and of the block

; TODO: add dynamic file data and buffer allocation on open, free on close

	segment	data	class=data
fbuf		resb bufsz	; buffer for read and write
fhandle		resw 1		; dos file handle
ncurblk		resw 1		; number of the current block
bufpos		resw 1		; the position in the buffer
openmode	resb 1		; 2 bits: open mode: 01:r, 10:w, 11:rw (bits: rw)
bufmodified	resb 1		; boolean: buffer modified or not
bufloaded	resb 1		; boolean: buffer loaded or not

	segment code	class=code

;****f* fio/fopen
;  NAME
;    fopen -- open a file
;  DESCRIPTION
;    Opens a file or create if it does not exist.
;      * r opens the file as read-only
;      * w opens the file as write-only: its contents are erased if it
;          exists, if not it's created
;      * rw opens the file in read/write mode: if it does not exist, it is
;           created
;  PARAMETERS
;    fname - address: pointer to null-terminated string, representing
;            the location of the file
;    r - boolean: open as readable
;    w - boolean: open as writable, create if does not exist
;  RETURN VALUE
;     * pfile on success: pointer to file data to use for other calls
;       returned in ax: not to be treated as a pointer
;     * 0ffffh on error
;****

	segment data
	segment code
fopen:
	push	bp
	mov	bp, sp

	mov	ah, open
	mov	dx, [bp+8]	; dx=filename
	mov	al, [bp+6] 	; al=r
	mov	bl, [bp+4]	; bl=w
	shl	al, 1		; al=2*r
	or	al, bl		; al=2*r+w
	mov	[openmode], al	; store open mode flags
	dec	al		; convert to dos mode
	int	dos

; TODO error handling
	jc .error

	mov	word [fhandle], ax
	mov	word [ncurblk], 0
	mov	word [bufpos], 0
	mov	byte [bufmodified], 0
	mov	byte [bufloaded], 0

	mov	ax, fbuf	; return value: pfile
	jmp	.end
.error:
	mov	ax, 0

.end:
	pop	bp
	ret	6

;****f* fio/fclose
;  NAME
;    fclose -- close a file
;  DESCRIPTION
;    Closes a file.
;  PARAMETERS
;    pfile - pointer to file data
;  RETURN VALUE
;    Doesn't return anything.
;****

	segment data
	segment code

fclose:
	push	bp
	mov	bp, sp

	mov	ah, close
	mov	bx, [fhandle]
	int	dos

	pop	bp
	ret	2


freadchr:
freadbuf:
fwritechr:
fwritebuf:
fwritestr:
fseek:
ftrunc:
