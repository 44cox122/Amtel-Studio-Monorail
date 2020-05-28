;
; lcdtest.asm
;
; Created: 9/13/2018 3:35:07 PM
; Author : lakew
;


; Replace with your application code

; Board settings: 1. Connect LCD data pins D0-D7 to PORTF0-7.
; 2. Connect the four LCD control pins BE-RS to PORTA4-7.
  
.include "m2560def.inc"

.def count1 = r17
.def count2 = r18
.def sec1 = r19
.def sec2 = r20
.def tempLCD = r21

.macro do_lcd_command
	ldi r16, @0
	rcall lcd_command
	rcall lcd_wait
.endmacro
.macro do_lcd_data
	rcall lcd_data
	rcall lcd_wait
.endmacro

.include "m2560def.inc"

.equ PATTERN = 0b11110000	;led pattern

.def tempC = r16
.def leds = r17	;led pattern
.def temp2 = r18

; The macro clears a word (2 bytes) in the data memory
; The parameter @0 is the memory address for that word
.macro clear
ldi YL, low(@0) ; load the memory address to Y pointer
ldi YH, high(@0)
clr tempC ; set temp to 0
st Y+, tempC ; clear the two bytes at @0 in SRAM
st Y, tempC
.endmacro

.dseg

MinsCounter: .byte 1
SecondCounter: .byte 1		;counter for seconds
TempCounter: .byte 2		; temp count to check time passed

.cseg

.org 0x0000

jmp RESET1
jmp DEFAULT		; no handling for IRQ0.
jmp DEFAULT		; no handling for IRQ1.

.org OVF0addr	; OVF0addr is the address of Timer0 Overflow Interrupt Vector
jmp Timer0OVF	; jump to the interrupt handler for Timer0 overflow.

jmp DEFAULT ; default service for all other interrupts.

DEFAULT:
	reti ; no interrupt handling

RESET1: 
	ldi tempC, high(RAMEND) ; initialize the stack pointer SP
	out SPH, tempC

	ldi tempC, low(RAMEND)
	out SPL, tempC

	ser tempC		; set Port C as output
	out DDRC, tempC

	rjmp main		; jump to main program

Timer0OVF: ; interrupt subroutine to Timer0
	in tempC, SREG
	push tempC ; prologue starts
	push YH ; save all conflicting registers in the prologue
	push YL
	push r25
	push r24 
	push r23 ; prologue ends

; Load the value of the temporary counter
	lds r24, TempCounter
	lds r25, TempCounter+1
	
	adiw r25:r24, 1 ; increase the temporary counter by one

	cpi r24, low(7812) ; check if (r25:r24) = 7812
	ldi tempC, high(7812) ; 7812 = 106/128
	cpc r25, tempC
	brne NotSecond
	clear TempCounter

; Load the value of the second counter
	lds r24, SecondCounter
	inc r24 ; increase the second counter by one

	cpi r24, 60
	brlo continue

	lds r23, MinsCounter
	inc r23
	sts MinsCounter, r23

	clr r24

	continue:
		sts SecondCounter, r24

		lds r24, SecondCounter
		lds r23, MinsCounter
	
	; display time on leds
		clr temp2
		ror r23
		ror temp2
		ror r23
		ror temp2

		add temp2, r24
		
		do_lcd_command 0b00000001 ; clear display

		

		rjmp EndIF

NotSecond: ; store the new value of the temporary counter
	sts TempCounter, r24
	sts TempCounter+1, r25

EndIF: 
	pop r23
	pop r24 ; epilogue starts
	pop r25 ; restore all conflicting registers from the stack
	pop YL
	pop YH
	pop tempC

	out SREG, tempC
	
	reti ; return from the interrupt

main: 
	clr leds
	out PORTC, leds ; set all LEDs on at the beginning
	
	clear TempCounter ; initialize the temporary counter to 0
	clear SecondCounter ; initialize the second counter to 0
	clear MinsCounter

	ldi tempC, 0b00000000
	out TCCR0A, tempC
	
	ldi tempC, 0b00000010
	out TCCR0B, tempC ; set prescalar value to 8
	
	ldi tempC, 1<<TOIE0 ; TOIE0 is the bit number of TOIE0 which is 0
	sts TIMSK0, tempC ; enable Timer0 Overflow Interrupt
	
	sei ; enable global interrupt

stop: 
	rjmp stop ; loop forever\

;DISPLAY

.org 0
	jmp RESET2


RESET2:
	ldi r16, low(RAMEND)
	out SPL, r16
	ldi r16, high(RAMEND)
	out SPH, r16

	ser r16
	out DDRF, r16
	out DDRA, r16
	clr r16
	out PORTF, r16
	out PORTA, r16



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

	clr tempLCD
	clr sec1
	ldi sec1, 47

loop1:
	do_lcd_command 0b00000001 ; clear display
	
	inc sec1
	mov r16, sec1
	do_lcd_data 
	
	clr r16

	inc tempLCD
	cpi tempLCD, 10
	brlo loop1

halt:
	rjmp halt


.equ LCD_RS = 7
.equ LCD_E = 6
.equ LCD_RW = 5
.equ LCD_BE = 4

.macro lcd_set
	sbi PORTA, @0
.endmacro
.macro lcd_clr
	cbi PORTA, @0
.endmacro

;
; Send a command to the LCD (r16)
;

lcd_command:
	out PORTF, r16
	nop
	lcd_set LCD_E
	nop
	nop
	nop
	lcd_clr LCD_E
	nop
	nop
	nop
	ret

lcd_data:
	out PORTF, r16
	lcd_set LCD_RS
	nop
	nop
	nop
	lcd_set LCD_E
	nop
	nop
	nop
	lcd_clr LCD_E
	nop
	nop
	nop
	lcd_clr LCD_RS
	ret

lcd_wait:
	push r16
	clr r16
	out DDRF, r16
	out PORTF, r16
	lcd_set LCD_RW

lcd_wait_loop:
	nop
	lcd_set LCD_E
	nop
	nop
        nop
	in r16, PINF
	lcd_clr LCD_E
	sbrc r16, 7
	rjmp lcd_wait_loop
	lcd_clr LCD_RW
	ser r16
	out DDRF, r16
	pop r16
	ret

.equ F_CPU = 16000000
.equ DELAY_1MS = F_CPU / 4 / 1000 - 4
; 4 cycles per iteration - setup/call-return overhead

sleep_1ms:
	push r24
	push r25
	ldi r25, high(DELAY_1MS)
	ldi r24, low(DELAY_1MS)

delayloop_1ms:
	sbiw r25:r24, 1
	brne delayloop_1ms
	pop r25
	pop r24
	ret

sleep_5ms:
	rcall sleep_1ms
	rcall sleep_1ms
	rcall sleep_1ms
	rcall sleep_1ms
	rcall sleep_1ms
	ret



