CC = gcc
CFLAGS = -O2 -pthread

.PHONY: all clean

all: membw

membw: membw.c
	$(CC) $(CFLAGS) -o membw membw.c

clean:
	rm -f membw
