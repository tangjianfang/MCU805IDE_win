/*
 * 003_functions.c - Function calls and arithmetic
 * Tests: function definitions, parameters, return values, arithmetic
 */
#include <8051.h>

unsigned char add(unsigned char a, unsigned char b)
{
	return a + b;
}

unsigned int multiply(unsigned char a, unsigned char b)
{
	return (unsigned int)a * b;
}

unsigned char factorial(unsigned char n)
{
	unsigned char result = 1;
	unsigned char i;
	for (i = 2; i <= n; i++) {
		result *= i;
	}
	return result;
}

void main(void)
{
	unsigned char sum;
	unsigned int product;
	unsigned char fact;

	sum = add(10, 20);
	product = multiply(12, 12);
	fact = factorial(5);

	P1 = sum;
	P2 = (unsigned char)(product & 0xFF);
	P3 = fact;

	while (1) {
		;
	}
}
