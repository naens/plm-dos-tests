global prchr, prstr, prhexbyte, prhexword, prstr, readkey, readln

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
        push    bp
        mov     bp, sp
        push    si
        mov     si, [bp+4]
.lp:
        lodsb
        cmp     al, 0
        je      .e
        xchg    ax, dx
        mov     ah, conout
        int     dos
        jmp     .lp
.e:
        pop     si
        pop     bp
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

        segment data class=data

        segment code class=code

readln:
