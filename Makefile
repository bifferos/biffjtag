

.PHONY: clean release


TOOL_PREFIX:=/home/biff/buildroot/buildroot-2011.11/output/host/usr/bin/i486-unknown-linux-uclibc

RELEASE=../release/

all: at-biffjtag

CC = $(TOOL_PREFIX)-gcc -c -Wall -s -nostdlib
OBJS = start.o fcntl.o jtag.o at-biffjtag.o string.o stdio.o rdc.o

at-biffjtag: $(OBJS) 
	$(TOOL_PREFIX)-gcc -o at-biffjtag.elf -Wall -s -nostdlib $(OBJS)
	objcopy -R .comment at-biffjtag.elf at-biffjtag

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

rdc.o: rdc.c f_bus_control.inc
	$(CC) rdc.c

f_bus_control.inc: bus_control.py
	./bus_control.py > $@

release:
	cp at-biffjtag $(RELEASE)	

clean:
	rm -Rf *.o *~ at-biffjtag *.inc *.bin *.pyc *.elf assembly assembly.S

