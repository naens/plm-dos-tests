        name    cons

        cgroup  group   code
        dgroup  group   stack

        assume  cs:cgroup, ds:dgroup, ss:dgroup


stack   segment stack   'STACK'
        dw      1024 dup(0)
stack   ends

code    segment public  'CODE'

        public  prstr

conout          equ     02h
dosexit         equ     4ch
dos             equ     21h

prstr           proc    near
        push    bp
        mov     bp, sp
        push    si
        mov     si, [bp+4]
pslp:
        lodsb
        cmp     al, 0
        je      pslpe
        xchg    ax, dx
        mov     ah, conout
        int     dos
        jmp     pslp
pslpe:
        pop     si
        pop     bp
        ret     2
prstr           endp

code    ends


        end
