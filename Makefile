OS := $(shell uname)

all: docs

%:
ifeq ($(OS),Linux)
	$(MAKE) -f makefile.lin $@
endif
