        name    cons

        cgroup  group   code
        dgroup  group   stack

        assume  cs:cgroup, ds:dgroup, ss:dgroup


stack   segment stack   'STACK'
        dw      1024 dup(0)
stack   ends

code    segment public  'CODE'

        public  term

conout          equ     02h
dosexit         equ     4ch
dos             equ     21h


term            proc    near
        mov     al, 0
        mov     ah, dosexit
        int     dos
term            endp

code    ends


        end
