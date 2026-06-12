/*
 * 004_arrays_structs.c - Arrays, structs, and pointers
 * Tests: array indexing, struct members, pointer dereference, loops
 */
#include <8051.h>

struct point {
	unsigned char x;
	unsigned char y;
};

unsigned char buffer[8];

void fill_buffer(unsigned char start)
{
	unsigned char i;
	for (i = 0; i < 8; i++) {
		buffer[i] = start + i;
	}
}

unsigned char sum_buffer(void)
{
	unsigned char i;
	unsigned char total = 0;
	for (i = 0; i < 8; i++) {
		total += buffer[i];
	}
	return total;
}

void main(void)
{
	struct point p;
	unsigned char *ptr;

	fill_buffer(1);
	P1 = sum_buffer();

	p.x = 0x12;
	p.y = 0x34;

	ptr = buffer;
	P2 = *ptr;
	P3 = p.x + p.y;

	while (1) {
		;
	}
}
