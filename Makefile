libs := sys cons str fio

%.obj: %.asm
	@nasm -g -f obj $< -o $@

%.obj: %.plm
	./dosexec plm86 $< small symbols optimize\(0\) debug code xref

%.exe: %.plm %.obj $(foreach lib,$(libs),$(lib).obj)
	echo plm-file
	wcl @wcl.lnk -zq -d2 -lr -bc -bcl=dos -fe=$@  $(filter %.obj,$^)

%.exe: %.asm %.obj $(foreach lib,$(libs),$(lib).obj)
	./dosexec tlink /v $(subst /,\\, "$(filter %.obj,$^), $@")

.PHONY: clean
clean:
	@rm -f $(shell find . -name '*.exe' ! -path './disk/*' ! -name 'plm86.exe')
	@rm -f $(shell find . -name '*.lst' ! -path './disk/*')
	@rm -f $(shell find . -name '*.map' ! -path './disk/*')
