;
; lab05a.asm
;
; Created: 10/4/2018 1:58:38 PM
; Author : lakew
;

.include "m2560def.inc"
.include "macros.asm"

;defined registers
.def temp = r23
.def temp2 = r17
.def temp3 = r18
.def temp4 = r19
.def i = r20

.dseg
TempCounter: .byte 2		; temp count to check time passed
HoleCounter: .byte 2
DecNum: .byte 5

.cseg
.org 0x0
jmp RESET ; interrupt vector for RESET

.org INT0addr ; INT0addr is the address of EXT_INT0 (External Interrupt 0)
jmp EXT_INT0 ; interrupt vector for External Interrupt 0

.org INT1addr ; INT1addr is the address of EXT_INT1 (External Interrupt 1)
jmp EXT_INT1 ; interrupt vector for External Interrupt 1

.org INT2addr		;sets address for external interrupt 3
jmp EXT_INT2

.org OVF0addr	; OVF0addr is the address of Timer0 Overflow Interrupt Vector
jmp Timer0OVF

RESET:
	cli 
;stack pointer
	ldi temp, high(RAMEND) ; initialize the stack pointer SP
	out SPH, temp
	ldi temp, low(RAMEND)
	out SPL, temp

;timer reset	
	ldi temp, 0b00000000
	out TCCR0A, temp
	
	ldi temp, 0b00000010
	out TCCR0B, temp ; set prescalar value to 8
	
	ldi temp, 1<<TOIE0 ; TOIE0 is the bit number of TOIE0 which is 0
	sts TIMSK0, temp ; enable Timer0 Overflow Interrupt

	clr temp

;lcd reset
	ser temp
	out DDRF, temp
	out DDRA, temp
	clr temp
	out PORTF, temp
	out PORTA, temp

	do_lcd_command 0b00111000 ; 2x5x7
	rcall sleep_5ms
	do_lcd_command 0b00111000 ; 2x5x7
	rcall sleep_1ms
	do_lcd_command 0b00111000 ; 2x5x7
	do_lcd_command 0b00111000 ; 2x5x7
	do_lcd_command 0b00001000 ; display off?
	do_lcd_command 0b00000001 ; clear display
	do_lcd_command 0b00000110 ; increment, no display shift
	do_lcd_command 0b00001110 ; Cursor on, bar, no blink

main:
	clear TempCounter
	clear HoleCounter

	;interrupt reset
	clr temp ; temp = 0b00000000
	out DDRD, temp ; Port D is set to all inputs
	ser temp
	out PORTD, temp
	ldi temp, (2 << ISC20) | (2 << ISC10) | (2 << ISC00) ; The built-in constants ISC10=2 and ISC00=0 are their bit numbers in EICRA register
	sts EICRA, temp ; temp=0b00001010, so both interrupts are configured as falling edge
	in temp, EIMSK
	ori temp, (1<<INT0) | (1<<INT1) | (1<<INT2) ; INT0=0 & INT1=1 & INT2 = 2
	out EIMSK, temp ; Enable External Interrupts 0 and 1

	sei		;enable global interrupt

stop:
	rjmp stop


	;Inerupt handlers
EXT_INT0:
	reti

EXT_INT1:
	reti

EXT_INT2:		;counts the time btwn two holes
	push temp
	in temp, SREG
	push temp
	push r24
	push r25


	lds r24, HoleCounter
	lds r25, HoleCounter+1

	adiw r25:r24, 1

	sts HoleCounter, r24
	sts HoleCounter+1, r25

	pop r25
	pop r24
	pop temp
	out SREG, temp
	pop temp

return:
	reti

Timer0OVF: ; interrupt subroutine to Timer0
	push temp
	in temp, SREG
	push temp ; prologue starts
	push YH ; save all conflicting registers in the prologue
	push YL
	push r25
	push r24 
	push r23 	; prologue ends

; Load the value of the temporary counter
	lds r24, TempCounter
	lds r25, TempCounter+1
	
	adiw r25:r24, 1 ; increase the temporary counter by one

	cpi r24, low(790) ; we are assuming that 790 will be 100ms
	ldi temp, high(790) ; 
	cpc r25, temp
	brne NotMSecond		;if it has not been 100ms we do not want to do anyting
	clear TempCounter
	rjmp continue

	rjmp EndIF

	NotMSecond: ; store the new value of the temporary counter
		sts TempCounter, r24
		sts TempCounter+1, r25
		rjmp EndIF

	continue:
		do_lcd_command 0b00000001 ; clear display

		ldi zl, low(HoleCounter)
		ldi zh, high(HoleCounter)

		rcall print_to_screen
		clear HoleCounter

EndIF: 
	pop r23
	pop r24 
	pop r25 ; restore all conflicting registers from the stack
	pop YL
	pop YH
	pop temp
	out SREG, temp
	pop temp

	reti ; return from the interrupt

.include "lcd.asm"
.include "bi2dec.asm"
.include "screenprint.asm"
