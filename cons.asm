global prstr

;****h* plm-exercises/cons
;  NAME
;    cons -- Console Input and Output
;  DESCRIPTION
;    Module for Console Input and Output.
;  USES
;    dos.def
;****

%include "dos.def"

;****f* cons/prstr
;  NAME
;    prstr -- Prints a null-terminated 7-bit ASCII string.
;  DESCRIPTION
;    Print the string on the console.
;  PARAMETERS
;     $1 - address of the first character of the string
;  RETURN VALUE
;     Doesn't return anything
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
