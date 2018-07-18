global entry, term

        segment data class=data
;tmp     resw 1

        segment code class=code

entry:   mov     ax, data
        mov     ds, ax
        xor     ax, ax
        jmp     ax

term:
        mov     al, 0
        mov     ah, 4ch
        int     21h
