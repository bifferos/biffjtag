#pragma once


unsigned long jtag_init();
void jtag_MemAccess(unsigned long addr, unsigned long cmnd);
unsigned long jtag_ReadMem16(unsigned long addr);
void jtag_WriteMem16(unsigned long addr, unsigned long val);

void jtag_write_ir(unsigned long val);
void jtag_idle_to_shift_dr();
unsigned long jtag_read_dr8();
unsigned long jtag_read_dr16();
unsigned long jtag_read_dr32();
void jtag_update_to_idle();
void jtag_update_to_shift_dr();
void jtag_write_dr32(unsigned long val);

