        name    cons

$include(dos.def)

        cgroup  group   code
        dgroup  group   stack

        assume  cs:cgroup, ds:dgroup, ss:dgroup


stack   segment stack   'STACK'
        dw      1024 dup(0)
stack   ends

code    segment public  'CODE'

        public  prstr

prstr:
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

code    ends

        end
