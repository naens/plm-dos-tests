.extensions:
.extensions: .obj .asm

ex.exe: ex.plm wcl.lnk sys.obj cons.obj makefile
!ifdef __UNIX__
	./dosexec plm86 ex.plm code small xref symbols
!else ifdef __MSDOS__
	plm86 ex.plm code small xref symbols
!endif
	wcl @wcl.lnk -zq -d2 -lr -bc -bcl=dos -fe=ex.exe ex.obj sys.obj cons.obj

!ifdef __UNIX__
run-ex: ex.exe .SYMBOLIC
	@./dosexec ex
!endif

.asm.obj: dos.def
	nasm -f obj $< -o $@ -l $^&.lst

clean: .SYMBOLIC
	rm -f *.map *.lst *.obj ex ex.exe

docs: .SYMBOLIC
	naturaldocs -i . -p nd-project -o HTML docs
