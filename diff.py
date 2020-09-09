#!/usr/bin/env python

import os, sys


def Run(cmnd):
  ret = os.system(cmnd)
  if ret:
    raise OSError("Error executing system (%d)" % ret)


def Execute():
  Run("rm -f out.bin")
  Run("./main program")
  Run("./main dump")


def Diff(f1, f2):
  d1 = file(f1,"rb").read()
  d2 = file(f2,"rb").read()
  
  for i in xrange(0,len(d1)):
    if d1[i] != d2[i]:
      raise ValueError("Byte mismatch at %d"%i)


if __name__ == "__main__":

  for i in xrange(0,10):
    Run("cp random.bin biffboot.bin")
    Execute()
    Diff("random.bin", "out.bin")
    Run("cp ffff.bin biffboot.bin")
    Execute()
    Diff("ffff.bin", "out.bin")
