#!/usr/bin/env python
import struct, os, time, sys, gen

# Get the machine code.    
gen.Exec("""
       mov dx, 0xcf8         # PCI cfg adr
       mov eax, 0x80003840   # bus control
       out dx, eax
       mov dx, 0xcfc         # PCI cfg data
       mov eax, 0x87ff0600   # bit 16 == FRR 1 (E0000->FFFFF)
       out dx, eax
       """)

#gen.Exec("""
#       mov ax, 0x42   # bus control
#       """)


