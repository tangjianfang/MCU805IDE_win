/*
 * 005_interrupts.c - Interrupt service routines and timers
 * Tests: __interrupt keyword, SFR bit access, volatile, timer setup
 */
#include <8051.h>

volatile unsigned char tick_count = 0;
volatile unsigned int seconds = 0;

/* Timer 0 interrupt service routine (interrupt vector 1) */
void timer0_isr(void) __interrupt(1)
{
	tick_count++;
	if (tick_count >= 20) {
		tick_count = 0;
		seconds++;
	}
}

void timer0_init(void)
{
	TMOD = 0x01;	/* Timer 0, mode 1 (16-bit) */
	TH0 = 0x3C;	/* Reload value high byte */
	TL0 = 0xB0;	/* Reload value low byte */
	ET0 = 1;	/* Enable Timer 0 interrupt */
	EA = 1;		/* Enable global interrupts */
	TR0 = 1;	/* Start Timer 0 */
}

void main(void)
{
	timer0_init();

	while (1) {
		P1 = (unsigned char)(seconds & 0xFF);
		P2 = (unsigned char)(seconds >> 8);
	}
}
