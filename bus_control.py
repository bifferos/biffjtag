#!/usr/bin/env python3

import os
import struct


def GetMachineCode(txt):
    open("assembly.S", "w").write(txt)
    # if os.system("nasm assembly.S &> /dev/null"): return None
    if os.system("nasm assembly.S"):
        return None
    return open("assembly", "rb").read()


def Nasm(line):
    """Assemble instructions to op-codes, return one or more 32-bit values"""
    machine = GetMachineCode(line)
    while len(machine) % 4:
        machine += b"\x90"
    return struct.unpack("I"*int(len(machine)/4), machine)


def Exec(script):
    # interpreter for script
    for i in script.split("\n"):
      if i.split("#")[0].strip():
        params = Nasm(i.split("#")[0])
        if params:
          # print "Instruction:",i
          raw = b""
          for j in params:
            raw += struct.pack("<L", j)
          out = "".join(["\\x%02x" % i for i in raw])
          print('if (ret==0)')
          print('  ret = RunCode((unsigned char*)"%s", %d);' % (out, len(raw)))


# Get the machine code.    
Exec("""
       mov dx, 0xcf8         # PCI cfg adr
       mov eax, 0x80003840   # bus control
       out dx, eax
       mov dx, 0xcfc         # PCI cfg data
       mov eax, 0x87ff0600   # bit 16 == FRR 1 (E0000->FFFFF)
       out dx, eax
       """)



