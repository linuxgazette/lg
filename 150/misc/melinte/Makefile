#
#
#

CC = gcc
LD = ld

DEADLOCK_FILES   = deadlock.c
DEADLOCK_OBJ     = $(DEADLOCK_FILES:%.c=%.o)
DEADLOCK_CFLAGS  = -g -Wall -pthread   
DEADLOCK_LDFLAGS = -L. -lpthread

LIBLOCKPICK_HEADERS = lp_hooks.h lp_check.h lp_data.h lp_bitset.h 
LIBLOCKPICK_FILES   = lp_hooks.c lp_check.c lp_data.c lp_bitset.c 
LIBLOCKPICK_OBJ     = $(LIBLOCKPICK_FILES:%.c=%.o)
LIBLOCKPICK_CFLAGS  = -g -Wall -fPIC -I. 
LIBLOCKPICK_LDFLAGS = -shared -ldl 



all: deadlock liblockpick.so 

deadlock: $(DEADLOCK_OBJ)
	$(CC) -o $@ $+ $(DEADLOCK_LDFLAGS)

deadlock.o: deadlock.c $(LIBLOCKPICK_HEADERS) Makefile
	$(CC) $(DEADLOCK_CFLAGS) -c $< -o $@

liblockpick.so: $(LIBLOCKPICK_OBJ)
	$(LD) -o $@ $+ $(LIBLOCKPICK_LDFLAGS)

%.o: %.c $(LIBLOCKPICK_HEADERS) Makefile
	$(CC) $(LIBLOCKPICK_CFLAGS) -c $< -o $@


.IGNORE: clean
clean:
	rm deadlock liblockpick.so *.o core*


test: all 
	LD_PRELOAD=./liblockpick.so ./deadlock

backup: clean
	#rm -rf /media/disk/lockpick/*
	cd .. && cp -pR lockpick /media/disk/
	sync
	ls -l /media/disk/lockpick/*

refresh: 
	cp -pR /media/disk/lockpick/* . 
