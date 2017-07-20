CC = gcc
CFLAGS = -I. 
DEPS = tcpsnoop.h
OBJSNOOP = tcpsnoop.o
OBJSHOOT = tcpshoot.o

%.s: %.c $(DEPS)
	$(CC) -S -o $@ $< $(CFLAGS)

%.o: %.c $(DEPS)
	$(CC) -c -o $@ $< $(CFLAGS)

tcpshoot: $(OBJSHOOT)
	$(CC) -o $@ $^ $(CFLAGS)

all: tcpshoot
