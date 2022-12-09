# Build support utilties used in dot files

PROG_TAGS?=etags
SOURCES=$(wildcard *.c)

all: shell_util

shell_util: shell_util.c
	$(CC) -g -O0 -o shell_util shell_util.c

test:
	./shell_util_test.sh

.phony: TAGS
TAGS: $(SOURCES)
	$(PROG_TAGS) $(SOURCES)

clean:
	rm *~ TAGS shell_util
