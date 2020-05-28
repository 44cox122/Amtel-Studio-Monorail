;
; Lab03b.asm
;
; Created: 9/3/2018 6:17:54 PM
; Author : lakew
;

.include "m2560def.inc"

.def temp = r16

.equ four = 0b00001111
.equ over = 0b00010000
.equ under = 0b00000000

.cseg

.org 0x0


jmp RESET		;interrupt vector for RESET

.org INT0addr	;address of external interrupt 0
jmp EXT_INT0	; interrupt vector for external interrupt 0

.org INT1addr	; address of external interrrup 1
jmp EXT_INT1

RESET:
	ldi temp, low(RAMEND)		;initialize stack pointer to high end of SRAM
	out SPL, temp
	ldi temp, high(RAMEND)
	out SPH, temp

	ser temp

	out DDRC, temp		;PORTC is all outputs

	ldi temp, four		;turning on the first four lights
	out PORTC, temp

	clr temp

	out DDRD, temp		;Port D is all inputs
	out PORTD, temp

	ldi temp, (2<<ISC10)|(2<<ISC00)		;Built in constants EICRA register
	sts EICRA, temp

	in temp, EIMSK
	ori temp, (1<<INT0)|(1<<INT1)	; INT0=0 & INT1=1
	out EIMSK, temp ; Enable External Interrupts 0 and 1
	
	sei		; Enable the global interrupt
	jmp main

EXT_INT0:
	push temp		;save temps value on stack
	in temp, SREG	;read SREG
	push temp		;save sreg on stack

	in temp, PORTC		;read input from portc
	cpi temp, four		
	breq skip1			;checking for case of 00001111 if not it continues and increases

	inc temp			;increase temp
	rjmp cont
	
	skip1:
		ldi temp, under
		rjmp cont
	
	cont:
 		out PORTC, temp
		pop temp
		out SREG, temp
		pop temp
	
	sbi EIFR, 0
	rcall delay
	
	reti

EXT_INT1:
	push temp
	in temp, SREG
	push temp

	in temp, PORTC
	cpi temp, under		;compares temp to under var above
	breq skip2			;breaks if equal (can't keep subtracting)

	dec temp
	rjmp cont2

	skip2:
		ldi temp, four
		rjmp cont2

	cont2:
		out PORTC, temp
		pop temp
		out SREG, temp
		pop temp 
	
			sbi EIFR, 1

		rcall delay

	reti

main:
	clr temp
	loop:
		inc temp
		rjmp loop


delay:
		clr r24
		clr r25
	loop1:
		adiw r25:r24, 1
		cpi r25, 255
		brlo loop
		
	ret