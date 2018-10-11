%.obj: %.asm
	nasm -g -f obj $< -o $@

asm/hello.exe: sys.obj cons.obj asm/hello.obj
	./dosexec tlink /v $(subst /,\\, "$^, $@")
