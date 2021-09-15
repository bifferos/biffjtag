
.PHONY: clean release


CROSS_PATH:=/home/biff/buildroot-2011.11/output/host/usr/bin
PREFIX:=i486-unknown-linux-uclibc-

export PATH := $(CROSS_PATH):$(PATH)

RELEASE=release/

all: biffjtag

CC = $(PREFIX)gcc -c -Wall -static 
AS = $(PREFIX)as
LINK = $(PREFIX)gcc -Wall -static
OBJS = jtag.o biffjtag.o rdc.o


flash: biffjtag
	./upload.py

biffjtag: $(OBJS)
	$(LINK) -o biffjtag -Wall $(OBJS)

jtag.o: jtag.S
	$(AS) -o jtag.o jtag.S

biffjtag.o: biffjtag.c
	$(CC) biffjtag.c

rdc.o: rdc.c
	$(CC) rdc.c

bus_control.h: bus_control.bin
	xxd -i $< > $@

bus_control.bin: rdc_assemble.py bus_control.S
	./rdc_assemble.py bus_control.S $@

clean:
	rm -Rf *.o *~ biffjtag *.inc *.bin *.pyc *.elf
