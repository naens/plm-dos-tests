.extensions:
.extensions: .obj .asm

all: hello.exe dump.exe

run: .SYMBOLIC
	@./doswin

hello.exe: hello.plm wcl.lnk sys.obj cons.obj makefile
	./dosexec plm86 hello.plm code small xref symbols
	wcl @wcl.lnk -zq -d2 -lr -bc -bcl=dos -fe=hello.exe hello.obj sys.obj cons.obj

run-hello: hello.exe .SYMBOLIC
	@./dosexec hello

dump.exe: dump.plm wcl.lnk sys.obj cons.obj makefile
	./dosexec plm86 dump.plm code small xref symbols
	wcl @wcl.lnk -zq -d2 -lr -bc -bcl=dos -fe=dump.exe dump.obj sys.obj cons.obj

run-dump: dump.exe .SYMBOLIC
	@./doswin dump

.asm.obj: dos.def
	nasm -f obj $< -o $@ -l $^&.lst

clean: .SYMBOLIC
	rm -f *.map *.lst *.obj *.err *.sym hello hello.exe dump dump.exe

docs: .SYMBOLIC
	robodoc --src . --doc ./docs --html --multidoc --sections --tell --toc --index

troff: .SYMBOLIC
	robodoc --src . --doc ./troff --troff --multidoc --sections --tell

tests: sys.obj cons.obj .SYMBOLIC
	./buildtests
