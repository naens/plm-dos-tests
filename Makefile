comma := ,
empty :=
space := $(empty) $(empty)
libs := sys cons
apps := hello dump
libobjs := $(foreach lib,$(libs),$(lib).obj)
commaobj := $(subst $(space),$(comma)$(space),$(libobjs))

%.obj: %.asm
	./assemble.sh $<

%.obj: %.plm
	./dosexec.sh plm86 $< small optimize\(0\) debug code symbols nopaging

%.86:	%.obj $(libobjs)
	./dosexec.sh link86 $<, $(commaobj) to $@ bind

%.exe:	%.86
	./dosexec.sh udi2dos $<

$(apps): %: %.exe
	echo ./dosexec.sh $< > $@
	chmod +x $@

.PHONY: clean
clean:
	@rm -f $(shell find . -name '*.exe' ! -path './disk/*' ! -name 'plm86.exe')
	@rm -f $(shell find . -name '*.lst' ! -path './disk/*')
	@rm -f $(shell find . -name '*.map' ! -path './disk/*')
	@rm -f $(shell find . -name '*.obj' ! -path './disk/*')
	@rm -f $(shell find . -name '*.86' ! -path './disk/*')
	@rm -f $(apps)
