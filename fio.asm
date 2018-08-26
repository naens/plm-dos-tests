global fopen, fclose, freadchr, freadbuf, feof, fwritechr, fwritebuf, \
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

bufsz		equ	128	; the size of the buffer and of the block

; TODO: add dynamic file data and buffer allocation on open, free on close

	segment	data	class=data
fbuf		resb bufsz	; buffer for read and write
fhandle		resw 1		; dos file handle
curblk		resw 1		; number of the current block
bufpos		resw 1		; the position in the buffer
buflen		resw 1		; if last block, number of bytes remaining
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
	shl	bl, 1		; bl=2*w
	or	al, bl		; al=2*w+r
	mov	[openmode], al	; store open mode flags
	dec	al		; convert to dos mode
	int	dos
	jc .error

	mov	word [fhandle], ax

	; skipping loading first block if file not readable (write-only)
	test	byte [openmode], 1
	jz	.nold

	; load first block
	call	rdfstblk
	jc	.error
	jmp	.endld
.nold:
	mov	word [curblk], 0
	mov	word [bufpos], 0
	mov	byte [bufmodified], 0
	mov	byte [bufloaded], 0

.endld:

	mov	ax, fbuf	; return value: pfile
	jmp	.end
.error:
	mov	ax, 0ffffh

.end:
	pop	bp
	ret	6

; subroutine: read first block (private)
; updates buffer and variables: buflen, bufpos, curblk, bufmodified
; can be used to read the first block, but not the rest
rdfstblk:
	mov	ah, read
	mov	bx, [fhandle]
	mov	cx, bufsz
	mov	dx, fbuf
	int	dos
	jc	.error
	mov	[buflen], ax
	mov	word [bufpos], 0
	mov	word [curblk], 0
	mov	byte [bufmodified], 0
	mov	byte [bufloaded], 1
.error:
	ret
	

; subroutine: read next block (private)
; updates buffer and variables: buflen, bufpos, curblk, bufmodified
; can be used to read after the first block
rdnxtblk:
	mov	ah, read
	mov	bx, [fhandle]
	mov	cx, bufsz
	mov	dx, fbuf
	int	dos
	jc	.error
	mov	[buflen], ax
	mov	word [bufpos], 0
	inc	word [curblk]
	mov	byte [bufmodified], 0
.error:
	ret

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

	; TODO: write current block if writable and block modified

	mov	ah, close
	mov	bx, [fhandle]
	int	dos

	pop	bp
	ret	2

;****f* fio/freadchr
;  NAME
;    freadchr -- read a character from a file
;  DESCRIPTION
;    Reads a character from a file that has been opened previously in
;    read-only or read/write mode.
;  PARAMETERS
;    pfile - pointer to file data
;    pchar - pointer to the character to set
;  RETURN VALUE
;    0 on success
;    -1 on error
;****
;  freadchr (pfile, pchar)
;    if not readable then
;      return -1
;    end if
;    if buflen < bufsz and bufpos = buflen then
;      return -1
;    end if
;    *pchar = fbuf[bufpos]
;    inc pos
;    if bufpos = bufsz then
;      pos := 0
;      inc curblk
;      dos read next block
;    end if
;    return 0
;  end freadchr

freadchr:
	push	bp
	mov	bp, sp

;	mov	ax, [bp+6]	; pfile

	; if not readable, return -1
	mov	al, [openmode]
	test	al, 1
	jz	.error

        ; if buflen < bufsz and bufpos = buflen then
	mov	ax, [buflen]	; buflen in ax
	cmp	ax, bufsz
	jge	.noteof
	mov	bx, [bufpos]	; bufpos in bx
	cmp	ax, bx
	je	.error
.noteof:

	; set *pchar = fbuf[bufpos]
	mov	si, [bufpos]
	mov	bx, fbuf
	mov	al, [bx+si]	; al = fbuf[bufpos]
	mov	bx, [bp+4]	; bx = pchar
	mov	[bx], al
	inc	word [bufpos]

	; if bufpos = bufsz then read next block
	mov	ax, [bufpos]
	cmp	ax, bufsz
	jne	.done

	; load block
	call	rdnxtblk
	jc	.error
.done:
	mov	ax, 0
	jmp	.end
.error:
	mov	ax, 0ffffh
.end:
	pop	bp
	ret	4


;****f* fio/freadbuf
;  NAME
;    freadbuf -- read file into buffer
;  DESCRIPTION
;    Read sz bytes from file and store at location of address pbuf.  Returns
;    the number of bytes read on success and 0ffffh on error.
;  PARAMETERS
;    pfile - pointer to the file data
;    pdest - pointer to the destination buffer
;    sz - number of bytes that can be stored in the destination buffer
;  RETURN VALUE
;    On success returns the number of bytes read.  If an EOF condition
;    occurred during the file read, the return value might be smaller than
;    sz.
;****
;  VAR
;    length - number a bytes to copy in the current loop iteration
;     count - bytes copied so far, at the end: the return value
;  PSEUDOCODE
;    if not readable then
;        return -1
;    count := 0
;    loop
;        let tmp1 = buflen - bufpos
;        let tmp2 = sz - count
;        if tmp1 < tmp2 then
;            length := tmp1
;        else
;            length := tmp2
;        do while length > 0
;            pdest[count] := fbuf[bufpos]
;            inc count
;            inc bufpos
;            dec length
;        end
;        if bufpos = bufsz then
;            dos read next block => buflen (on error return -1)
;            bufpos := 0
;        else
;           exit loop
;    end loop
;    return count
freadbuf:
	push	bp
	mov	bp, sp

	; if not readable then return 0ffffh
	mov	ax, [openmode]
	test	ax, 1
	jz	.error

	; count := 0
	mov	di, 0
.loop:
	mov	cx, [buflen]
	sub	cx, [bufpos]		; tmp1 in cx
	mov	ax, [bp+4]
	sub	ax, di			; tmp2 in ax
	cmp	cx, ax
	jb	.l1			; if not tmp1 < tmp then
	mov	cx, ax			;     length = tmp2
.l1:
	mov	si, [bufpos]		; bufpos in si
	mov	bx, [bp+6]		; pdest in bx

	; do-while loop
.copyloop:
	cmp	cx, 0
	je	.copyend
	mov	al, [fbuf+si]
	mov	[bx+di], al
	inc	si
	inc	di
	dec	cx
	jmp	.copyloop
.copyend:

	; if bufpos = bufsz then dos read next block
	cmp	si, bufsz
	jne	.loopexit
	call	rdnxtblk
	jc	.error
	jmp	.loop

.loopexit:
	mov	[bufpos], si		; update bufpos from si
	mov	ax, di			; return count in ax
	jmp	.end

.error:
	mov	ax, 0ffffh

.end:
	pop	bp
	ret	6



fwritechr:

fwritebuf:

;****f* fio/feof
;  NAME
;    feof -- check if at the end of file
;  DESCRIPTION
;    Check if the current position is at the end of file.  End of file means
;    that no more characters can be read.  The false value indicates that
;    there is at least one byte in the file that can be read at the current
;    position.
;  PARAMETERS
;    pfile - pointer to file data
;  RETURN VALUE
;    Boolean value telling whether the file position is at the end of file.
;****
; The end of file condition means that the length of the current buffer is
; less than maximum (bufsz) and that the current position in the buffer has
; is after the last byte: no more bytes can be read.

feof:
	push	bp
	mov	bp, sp

        ; if buflen < bufsz and bufpos = buflen then return 1 else return 0
	mov	ax, [buflen]	; buflen in ax
	cmp	ax, bufsz
	jge	.noteof
	mov	bx, [bufpos]	; bufpos in bx
	cmp	ax, bx
	jne	.noteof
.eof:
	mov	ax, 1
	jmp	.end
.noteof:
	mov	ax, 0
.end:
	pop	bp
	ret	2

fwritestr:
fseek:
ftrunc:
