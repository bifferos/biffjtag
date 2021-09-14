#!/usr/bin/env python3

"""
    Generate assembler in a form suitable for execution by JTAG on RDC processors.

    You must use JTAG to feed instructions and execute them.  But they can only be executed
    one instruction at a time.  Each x86 instruction can vary in length.  The JTAG requires that
    you pad using NOPs to a 32-bit boundary.  That's what this script does.  It generates the padded
    sets of instructions.

    Example:
        Assembler:
            mov dx, 0xcf8
        Binary:
            ba f8 0c
        RDC JTAG only accepts queued instructions in multiples of 4 bytes, so we must pad this.  We pad with nop (0x90).
            ba f8 0c 90
        But we prefix a 'header' to indicate the length.
            04 ba f8 0c 90
        In practise the length will be 4 or 8 bytes.  Could be 12 for some instructions.
        The output of this program would be run through xxd to convert to a form suitable for inclusion in a C program,
        or the binary data could be loaded by a C program to execute a series of instructions, looping through reading
        the header, and then the 4,8, or 12 bytes of instruction data.

"""


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
