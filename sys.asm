	name	sys

$include(dos.def)

        cgroup  group   code
        dgroup  group   stack

        assume  cs:cgroup, ds:dgroup, ss:dgroup

stack   segment stack   'STACK'
        dw      1024 dup(0)
stack   ends

code    segment public  'CODE'

        public  term

term:
        mov     al, 0
        mov     ah, dosexit
        int     dos

code    ends

        end
