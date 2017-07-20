CC = gcc
CFLAGS = -I. -g
DEPS = tcpsnoop.h
OBJ = tcpsnoop.o

%.s: %.c $(DEPS)
	$(CC) -S -o $@ $< $(CFLAGS)

%.o: %.c $(DEPS)
	$(CC) -c -o $@ $< $(CFLAGS)

tcpsnoop: $(OBJ)
	$(CC) -o $@ $^ $(CFLAGS)
