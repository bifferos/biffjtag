
.PHONY: clean release

CROSS:=$(HOME)/bifferboard/buildroot-2011.11/output/host/usr

CC_PATH:=$(CROSS)/i486-unknown-linux-uclibc/bin/gcc
OBJCOPY:=$(CROSS)/i486-unknown-linux-uclibc/bin/objcopy
INCLUDE1:=$(CROSS)/i486-unknown-linux-uclibc/sysroot/usr/include
INCLUDE2:=$(CROSS)/i486-unknown-linux-uclibc/sysroot/usr/include/linux
INCLUDE3:=$(CROSS)/lib/gcc/i486-unknown-linux-uclibc/4.3.6/include

TOOLS_PATH:=$(CROSS)/i486-unknown-linux-uclibc/bin
CC1_PATH:=$(CROSS)/libexec/gcc/i486-unknown-linux-uclibc/4.3.6
export PATH := $(CC1_PATH):$(TOOLS_PATH):$(PATH)

RELEASE=release/

all: at-biffjtag

CC = $(CC_PATH) -c -Wall -s -nostdlib -I$(INCLUDE1) -I$(INCLUDE3)
LINK = $(CC_PATH) -Wall -s -nostdlib -I$(INCLUDE1) -I$(INCLUDE3)
OBJS = start.o fcntl.o jtag.o at-biffjtag.o string.o stdio.o rdc.o

at-biffjtag: $(OBJS) 
	$(LINK) -o at-biffjtag.elf -Wall -s -nostdlib $(OBJS)
	$(OBJCOPY) -R .comment at-biffjtag.elf at-biffjtag

start.o: start.S
	nasm -f elf start.S

fcntl.o: fcntl.S
	nasm -f elf fcntl.S

jtag.o: jtag.S
	nasm -f elf jtag.S

at-biffjtag.o: at-biffjtag.c
	$(CC) at-biffjtag.c

string.o: string.c
	$(CC) string.c

stdio.o: stdio.c
	$(CC) stdio.c

rdc.o: rdc.c bus_control.h
	$(CC) rdc.c

bus_control.h: bus_control.bin
	xxd -i $< > $@

bus_control.bin: rdc_assemble.py bus_control.S
	./rdc_assemble.py bus_control.S $@

release:
	cp at-biffjtag $(RELEASE)	

clean:
	rm -Rf *.o *~ at-biffjtag *.inc *.bin *.pyc *.elf assembly assembly.S

