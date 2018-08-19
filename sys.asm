global entry, term

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
