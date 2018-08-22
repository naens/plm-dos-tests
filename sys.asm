global entry, getargs, term

;****h* plm-exercises/sys
;  NAME
;    sys -- System library
;  DESCRIPTION
;    Module that contains system-related functions.
;  USES
;    dos.def
;****

%include "dos.def"

;****f* sys/entry
;  NAME
;    entry
;  DESCRIPTION
;    Initialize the system, must be called on program start.  The entry
;    function is the starting point, called before the program.  After
;    initialization it jumps to the real beginning of the program at
;    cs:0000h.
;  PARAMETERS
;    No parameters.
;  RETURN VALUE
;    Doesn't return anything.
;****

        segment data class=data

        segment code class=code

entry:	mov	ax, data
	mov	ds, ax
	mov	ax, 0
	jmp	ax

;****f* sys/getargs
;  NAME
;    getargs -- get command line arguments vector
;  DESCRIPTION
;    Allocates the vector of pointers to the command line arguments.
;  PARAMETERS
;    pargc - pointer to a word value, for the count of arguments
;    pargv - pointer to an address value, that will contain the address of
;            the allocated array of adresses of command line arguments.
;  RETURN VALUE
;    Doesn't return a value.
;****

        segment data class=data

        segment code class=code

getargs:

;****f* sys/term
;  NAME
;    term -- Terminate the program
;  DESCRIPTION
;    Terminate the program.
;  PARAMETERS
;    No parameters.
;  RETURN VALUE
;    Doesn't return anything.
;****
term:
	mov	al, 0
	mov	ah, dosexit
	int	dos
