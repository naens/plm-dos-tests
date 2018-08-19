.extensions:
.extensions: .obj .asm

hello.exe: hello.plm wcl.lnk sys.obj cons.obj makefile
!ifdef __UNIX__
	./dosexec plm86 hello.plm code small xref symbols
!else ifdef __MSDOS__
	plm86 hello.plm code small xref symbols
!endif
	wcl @wcl.lnk -zq -d2 -lr -bc -bcl=dos -fe=hello.exe hello.obj sys.obj cons.obj

!ifdef __UNIX__
run-hello: hello.exe .SYMBOLIC
	@./dosexec hello
!endif

.asm.obj: dos.def
	nasm -f obj $< -o $@ -l $^&.lst

clean: .SYMBOLIC
	rm -f *.map *.lst *.obj *.err *.sym hello hello.exe

docs: .SYMBOLIC
	robodoc --src . --doc ./docs --html --multidoc --sections --tell --toc --index

troff: .SYMBOLIC
	robodoc --src . --doc ./troff --troff --multidoc --sections --tell
