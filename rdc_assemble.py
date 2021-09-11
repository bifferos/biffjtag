#!/usr/bin/env python3

"""
    Generate assembler in a form suitable for execution by JTAG on RDC processors.

    You must use JTAG to feed instructions and execute them.  But they can only be executed
    one instruction at a time.  Each x86 instruction can vary in length.  The JTAG requires that
    you pad using NOPs to a 32-bit boundary.  That's what this script does.  It generates the padded
    sets of instructions.

"""

import os
import sys
import struct
import tempfile
from argparse import ArgumentParser
from subprocess import check_call
from pathlib import Path


def nasm(txt):
    assemble_dir = Path(tempfile.mkdtemp(prefix="tmp_rdc_assemble", dir="."))
    src_path = assemble_dir / "assemble.S"
    bin_path = assemble_dir / "assemble"
    src_path.open("w").write(txt)
    check_call(f"nasm {src_path.name}", shell=True, cwd=assemble_dir)
    block = bin_path.open("rb").read()
    check_call(f"rm -rf {assemble_dir}", shell=True)
    if not block:
        return block
    while len(block) % 4:
        block += b"\x90"
    length = len(block)
    print(repr(block))
    return struct.pack("B", length) + block


def assemble(input_file, output_file):
    if not input_file.exists():
        sys.exit(f"Can't open input file {input_file}")
    with input_file.open() as fp_in:
        bin_out = b"".join([nasm(_) for _ in fp_in.readlines()])
    with output_file.open("wb") as fp_out:
        fp_out.write(bin_out)


def main():
    parser = ArgumentParser()
    parser.add_argument("input", help="Assembler input file")
    parser.add_argument("output", help="Binary output file")
    args = parser.parse_args()
    assemble(Path(args.input), Path(args.output))


if __name__ == "__main__":
    main()
