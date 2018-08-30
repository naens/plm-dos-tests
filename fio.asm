global fopen, fclose, freadchr, freadbuf, feof, fwritechr, fwritebuf, \
    fwritestr, fseekset, fseekcur, fseekend, fgetsize, ftrunc

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
fsize		resw 1		; the size of the file
fhandle		resw 1		; dos file handle
curblk		resw 1		; number of the current block
bufpos		resw 1		; the position in the buffer
buflen		resw 1		; if last block, number of bytes remaining
openmode	resb 1		; 2 bits: open mode: 01:r, 10:w, 11:rw (bits: rw)
bufmodified	resb 1		; boolean: buffer modified or not

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
;     * -1 on error
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
	and	al, 3		; keep only 2 bits
	mov	[openmode], al	; store open mode flags
	dec	al		; convert to dos mode
	int	dos
	jc	.error

	mov	word [fhandle], ax

	; skipping loading first block if file not readable (write-only)
	mov	al, byte [openmode]
	cmp	al, 2		; write-only
	jz	.nold

	; get file size
	mov	ah, seek
	mov	al, 2		; seek from the end
	mov	bx, [fhandle]
	mov	cx, 0
	mov	dx, 0
	int	dos		; dx already set
	jc	.error
	test	dx, dx
	jnz	.error		; file to big
	mov	[fsize], ax
	mov	ah, seek
	mov	al, 0		; seek from the beginning
	int	dos		; go back to the beginning
	jc	.error

	; load first block
	call	rdfstblk
	jc	.error
	jmp	.endld

.nold:
	mov	word [curblk], 0
	mov	word [bufpos], 0
	mov	byte [bufmodified], 0
.endld:
	mov	ax, fbuf	; return value: pfile
	jmp	.end
.error:
	mov	ax, -1

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
	mov	ax, -1
.end:
	pop	bp
	ret	4


;****f* fio/freadbuf
;  NAME
;    freadbuf -- read file into buffer
;  DESCRIPTION
;    Read sz bytes from file and store at location of address pbuf.  Returns
;    the number of bytes read on success and -1 on error.
;  PARAMETERS
;    pfile - pointer to the file data
;    pdest - pointer to the destination buffer
;    sz - number of bytes that can be stored in the destination buffer
;  RETURN VALUE
;    On success returns the number of bytes read.  If an EOF condition
;    occurred during the file read, the return value might be smaller than
;    sz.  On error returns 0, as if couldn't reading anything.
;****
;  VAR
;    length - number a bytes to copy in the current loop iteration
;     count - bytes copied so far, at the end: the return value
;  PSEUDOCODE
;    if not readable then
;        return 0
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

	; if not readable then return -1
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
	mov	ax, 0

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

;****f* fio/fseekset
;  NAME
;    fseekset -- seek in a file
;  DESCRIPTION
;    Sets the position of the file to the value given in argument.  The
;    seek functions can only be used if the file was opened in a
;    readable mode (read-only or read/write).
;  PARAMETERS
;    pfile - pointer to file data
;    pos - position to set
;  RETURN VALUE
;    Returns 0 on success and -1 on error
;****
;  Pseudocode
;    1. get the number of the block where the position is located
;    2. get the position in the block
;    3. read the block from the file
;    4. set the position in the block
;    !! cannot be used for write-only files
fseekset:
	push	bp
	mov	bp, sp	; => pfile=[bp+6], pos=[bp+4]

	mov	ax, [openmode]
	test	ax, 1
	jz	.error

	; curblk := block number: pos div bufsz, bufpos := pos mod bufsz
	mov	dx, 0
	mov	ax, [bp+4]
	mov	cx, bufsz
	mov	bx, ax		; save pos in bx
	div	cx		; div in ax=newblk, mod in dx=newbpos
	mov	[bufpos], dx	; set bufpos

	cmp	ax, [curblk]
	je	.success

	; different blocks => seek	
	sub	bx, dx		; bx=newpos, dx=newbpos => bx: new block start
	mov	dx, bx		; set dx(=bx) to new block start pos

	; set dos file pointer
	mov	ah, seek
	mov	al, 0		; seek from the beginning
	mov	bx, [fhandle]
	mov	cx, 0
	int	dos		; dx already set
	jc	.error

	call	postseek
	jc	.error

.success:
	mov	ax, 0
	jmp	.end

.error:
	mov	ax, -1

.end:
	pop	bp
	ret	4

; set buffer and variables after a successful seek operation
postseek:
	; set curblk and bufpos, curpos in ax
	mov	dx, 0
	mov	cx, bufsz
	div	cx
	mov	[curblk], ax	; pos div bufsz
	mov	[bufpos], dx	; pos mod bufsz
	sub	bx, cx
	mov	dx, bx		; set dx to pos-(pos mod bufsz)

	; read buf
	mov	ah, read
	mov	bx, [fhandle]
	mov	cx, bufsz
	mov	dx, fbuf
	int	dos
	jc	.end
	mov	[buflen], ax
	mov	byte [bufmodified], 0

.end:
	ret


;****f* fio/fseekset
;  NAME
;    fseekset -- seek in a file
;  DESCRIPTION
;    Sets the position of the file by moving the current position by
;    offset bytes.  The offset is a signed integer value, and it is
;    possible forward and backwards.
;  PARAMETERS
;    pfile - pointer to file data
;    offset - distance to move the pointer.  A positive value moves
;             towards the end and a negative value moves backwards.
;  RETURN VALUE
;    Returns 0 on success and -1 on error
;****
fseekcur:
	push	bp
	mov	bp, sp	; => pfile=[bp+6], offset=[bp+4]

	; test that the file is readable
	mov	ax, [openmode]
	test	ax, 1
	jz	.error

	mov	ax, bufsz
	mov	cx, [curblk]
	mul	cx
	add	ax, [bufpos]	; curpos = bufsz * curblk + bufpos
	mov	cx, ax		; curpos in cx
	add	ax, [bp+4]	; newpos in ax
	mov	cx, ax		; save newpos in cx
	mov	bx, bufsz	; bufsz in bx
	div	bx		; div=newblk in ax, mod=newbpos in dx
	mov	[bufpos], dx	; set bufpos
	cmp	ax, [curblk]
	je	.success	; done if it's the same block
	jb	.negative

	; offset > 0
	sub	ax, [curblk]	; ax = newblk - curblk
	mov	bx, bufsz
	mul	bx
	mov	dx, ax		; dx = bufsz * (newblk - curblk)

	mov	ah, seek
	mov	al, 1		; seek from current
	mov	bx, [fhandle]
	mov	cx, 0
	int	dos		; dx already set
	jc	.error

	jmp	.postseek

	; offset < 0
.negative:
	sub	cx, dx
	mov	dx, cx		; new beginning of block in dx

	mov	ah, seek
	mov	al, 0		; seek from the beginning
	mov	bx, [fhandle]
	mov	cx, 0
	int	dos		; dx already set
	jc	.error

.postseek:
	call	postseek
	jc	.error

.success:
	mov	ax, 0
	jmp	.end

.error:
	mov	ax, -1

.end:
	pop	bp
	ret	4


;****f* fio/fseekset
;  NAME
;    fseekset -- seek in a file
;  DESCRIPTION
;    Sets the position in the file counting from the end of the file.
;  PARAMETERS
;    pfile - pointer to file data
;    pos - position to set from the end of the file
;  RETURN VALUE
;    Returns 0 on success and -1 on error
;****
;  dos seek end pos => newpos
;  newblk = newpos div bufsz
;  newbpos = newpos mod bufsz
;  if newbpos <> 0 then
;    dos seek set newpos - newbpos
;  if newblk = curblk then
;    bufpos := newbpos
;  else
;    postseek
fseekend:
	push	bp
	mov	bp, sp	; => pfile=[bp+6], pos=[bp+4]

	; dos seek end pos => newpos
	mov	ah, seek
	mov	al, 2		; seek from end
	mov	bx, [fhandle]
	mov	cx, 0
	mov	dx, [bp+4]
	int	dos
	jc	.error

	; newblk = newpos div bufsz, newbpos = newpos mod bufsz
	mov	dx, 0
	mov	cx, bufsz
	div	cx		; ax=div, dx=mod

	; if newbpos <> 0 then dos seek set newpos - newbpos
	cmp	dx, 0
	je	.skipseek
	sub	bx, cx
	mov	dx, bx		; set dx to pos-(pos mod bufsz)
	mov	ah, seek
	mov	al, 0		; seek set
	mov	bx, [fhandle]
	mov	cx, 0
	int	dos		; dx already set
	jc	.error
	mov	dx, 0
	mov	cx, bufsz
	div	cx		; ax=div, dx=mod
.skipseek:

	; if newblk = curblk then
	; bufpos := newbpos
	; else postseek

	mov	ax, 0
	jmp	.end

.error:
	mov	ax, -1

.end:
	pop	bp
	ret	4


;****f* fio/fgetsize
;  NAME
;    fgetsize -- get the size of the file
;  DESCRPTION
;    Returns the current size of the file.  The file should be open
;    in any mode.  In write mode data can be appended and file can be
;    truncated, which would change its size.
;  PARMETERS
;    pfile - pointer to file data
;  RETURN VALUE
;    Returns the size of the file.
;****
fgetsize:
	push	bp
	mov	bp, sp
	mov	ax, [fsize]
	pop	bp
	ret	2


;****f* fio/ftrunc
;  NAME
;    ftrunc -- truncate the file
;  DESCRIPTION
;    Truncates the file at the current position.  The file should be in
;    opened writable mode.
;  PARAMETERS
;    pfile - pointer to file data
;  RETURN VALUE
;    Returns 0 on success and -1 on error.
;****
ftrunc:
	push	bp
	mov	bp, sp

	mov	al, [openmode]
	test	al, 2
	jz	.error

	; calculate current position = new value for fsize
	mov	ax, bufsz
	mov	bx, [curblk]
	mul	bx
	add	bx, [bufpos]	; bx = bufsz * curblk + bufpos

	; set file size to value in bx
	mov	ah, write
	mov	cx, 0		; bytes to write
	mov	dx, 0		; buffer to write
	int	dos
	jc	.error

	mov	[fsize], bx

	mov	ax, 0
	jmp	.end
.error:
	mov	ax, -1
.end:
	pop	bp
	ret	2

