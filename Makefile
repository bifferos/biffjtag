
.PHONY: clean release

CROSS:=/home/biff/buildroot-2011.11/output/host/usr

AS_PATH:=$(CROSS)/i486-unknown-linux-uclibc/bin/as
CC_PATH:=$(CROSS)/i486-unknown-linux-uclibc/bin/gcc
OBJCOPY:=$(CROSS)/i486-unknown-linux-uclibc/bin/objcopy
INCLUDE1:=$(CROSS)/i486-unknown-linux-uclibc/sysroot/usr/include
INCLUDE2:=$(CROSS)/i486-unknown-linux-uclibc/sysroot/usr/include/linux
INCLUDE3:=$(CROSS)/lib/gcc/i486-unknown-linux-uclibc/4.3.6/include

LIB1:=$(CROSS)/i486-unknown-linux-uclibc/sysroot
LIB2:=$(CROSS)/i486-unknown-linux-uclibc/sysroot/lib
LIB3:=$(CROSS)/i486-unknown-linux-uclibc/sysroot/usr/lib
LIB4:=$(CROSS)/lib/gcc/i486-unknown-linux-uclibc/4.3.6

CRT:=$(CROSS)/i486-unknown-linux-uclibc/sysroot/usr/lib/crti.o

SYSROOT:=/home/biff/buildroot-2011.11/output/host/usr/i486-unknown-linux-uclibc/sysroot

TOOLS_PATH:=$(CROSS)/i486-unknown-linux-uclibc/bin
CC1_PATH:=$(CROSS)/libexec/gcc/i486-unknown-linux-uclibc/4.3.6
export PATH := $(CC1_PATH):$(TOOLS_PATH):$(PATH)

RELEASE=release/

all: at-biffjtag


CC = $(CC_PATH) -c -Wall -static -I$(INCLUDE1) -I$(INCLUDE3)
LINK = $(CC_PATH) -Wall -static -L$(LIB1) -L$(LIB4)  -L$(LIB2) -L$(LIB3)
OBJS = jtag.o at-biffjtag.o rdc.o

at-biffjtag: $(OBJS) 
	$(LINK) -o at-biffjtag -Wall $(OBJS)

jtag.o: jtag.S
	$(AS_PATH) -o jtag.o jtag.S

at-biffjtag.o: at-biffjtag.c
	$(CC) at-biffjtag.c

rdc.o: rdc.c
	$(CC) rdc.c

bus_control.h: bus_control.bin
	xxd -i $< > $@

bus_control.bin: rdc_assemble.py bus_control.S
	./rdc_assemble.py bus_control.S $@

release:
	cp at-biffjtag $(RELEASE)	

clean:
	rm -Rf *.o *~ at-biffjtag *.inc *.bin *.pyc *.elf assembly assembly.S

