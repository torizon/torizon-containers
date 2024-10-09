all: simple-gtk3-test.o

simple-gtk3-test.o: simple-gtk3-test.c
	${CC} -o simple-gtk3-test simple-gtk3-test.c $(shell pkgconf --cflags --libs gtk+-3.0)

clean:
	rm -f simple-gtk3-test

PHONY: clean
