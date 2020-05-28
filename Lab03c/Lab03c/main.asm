  ;
; Lab03c.asm
;
; Created: 9/6/2018 2:41:17 PM
; Author : lakew
;

.include "m2560def.inc"

.def count1 = r16
.def count2 = r17
.def count3 = r18
.def temp = r19
.def second = r20
.def mins = r21
.def temp2 = r22


.macro shift
	ror mins
	ror temp
.endmacro

.equ start = 0b00000000

.cseg

main:
	
	.org 0x0

	ldi temp2, 1
	ldi mins, start
	ldi second, start
	clr count1
	clr count2
	clr count3
	
	ser temp 
	out DDRC, temp
	
	clr temp
	out PORTC, temp

	forloop:
		cpi count3, 18	;to fill in later
		brlo end

		secondj:
			nop
			clr count3
			clr count2
			clr count1

			inc second		;add a second
			cpi second, 60		;60 seconds, need to change mins
			brlo end

			incM:
				inc mins
				clr second

		end:
			clr temp
			add count1, temp2
			adc count2, temp
			adc count3, temp
			
			shift
			shift

			add temp, second
			
			out PORTC, temp

			rjmp forloop