#!/usr/bin/env python

import struct, os, time,sys


def GetMachineCode(txt):
  file("assembly.S","wb").write(txt)
  #if os.system("nasm assembly.S &> /dev/null"): return None
  if os.system("nasm assembly.S"): return None
  return file("assembly","rb").read()


def Nasm(line):
  "Assemble instructions to op-codes, return one or more 32-bit values"
  machine = GetMachineCode(line)
  while len(machine)%4: machine += "\x90"
  return struct.unpack("I"*(len(machine)/4), machine)


def Exec(script):
  # interpreter for script
  for i in script.split("\n"):
    if i.split("#")[0].strip():
      params = Nasm(i.split("#")[0])
      if params:
        #print "Instruction:",i
        raw = ""
        for j in params:
          raw += struct.pack("<L", j)
        out = "".join([ "\\x%02x" % ord(i) for i in raw ])
        print 'if (ret==0)'
        print '  ret = RunCode((unsigned char*)"%s", %d);' % (out, len(raw))



