
TARGET := stepper
WARN   := -W -Wall
INCLUDE:= /usr/src/linux-2.4/include
#INCLUDE:= -isystem /usr/src/`uname -r`/include
CFLAGS := -O2 -DMODULE -D__KERNEL__ ${WARN} -I${INCLUDE}
all : stepper.o
#${TARGET}.o : ${TARGET}.c
clean:
	rm -rf *.o


