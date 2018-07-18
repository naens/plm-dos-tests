global cons_prstr

; Module: cons
;
;     Console Input and Output
;
; Dependencies: dos.def
;

%include "dos.def"

; Function: cons_prstr
;
;     Prints a null-terminated 7-bit ASCII string.
;
; Parameters:
;
;     $1 - address of the first character of the string
;
        segment data class=data
;tmp     resw 1

        segment code class=code

cons_prstr:
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

