#
#
#

CC = gcc
LD = ld

UDPTUN_FILES   = udptun.c ttools.c 
UDPTUN_OBJ     = $(UDPTUN_FILES:%.c=%.o)
UDPTUN_CFLAGS  = -g -Wall -pthread -save-temps  
UDPTUN_LDFLAGS = -L. -lpthread

PATHMTU_FILES   = pathmtu.c ttools.c 
PATHMTU_OBJ     = $(PATHMTU_FILES:%.c=%.o)
PATHMTU_CFLAGS  = -g -Wall -pthread -save-temps 
PATHMTU_LDFLAGS = -L. -lpthread


all: udptun pathmtu

udptun: $(UDPTUN_OBJ) ttools.h 
	$(CC) -o $@ $+ $(UDPTUN_LDFLAGS)

pathmtu: $(PATHMTU_OBJ) ttools.h 
	$(CC) -o $@ $+ $(PATHMTU_LDFLAGS)

%.o: %.c $(UDPTUN_HEADERS) Makefile
	$(CC) $(UDPTUN_CFLAGS) -c $< -o $@


.IGNORE: clean
clean:
	rm udptun pathmtu *.o *.i *.s core*


backup: clean
	#rm -rf /media/disk/vpn/*
	cd .. && cp -pR vpn /media/disk/
	sync
	ls -l /media/disk/vpn/*

refresh: 
	cp -pR /media/disk/vpn/* . 
