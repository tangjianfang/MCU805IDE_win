/*
 * 002_io_ports.c - I/O port manipulation
 * Tests: SFR access, bit operations, port read/write
 */
#include <8051.h>

void main(void)
{
	unsigned char value;

	/* Write to port */
	P1 = 0x00;

	/* Read from port */
	value = P0;

	/* Bit manipulation */
	P1 = value & 0x0F;
	P2 = value | 0xF0;
	P3 = value ^ 0xFF;

	while (1) {
		P1++;
	}
}
