/*
 * print_to_screen.asm
 *
 *  Created: 10/8/2018 6:31:10 PM
 *   Author: lakew
 */ 

print_to_screen:
	push temp
	push temp2
	push temp3
	push temp4
	push zl
	push zh

	ldi zl, low(HoleCounter)
	ldi zh, high(HoleCounter)

	ld temp3, z+
	ld temp4, z

	mul_10		;CONVERTING IT INTO THE CORRECT UNITS, REVS/SEC
	divide_4

	st z, temp4
	st -z, temp3

	ldi zl, low(HoleCounter)		;set the pointer back to top of HoleCounter
	ldi zh, high(HoleCounter)

	rcall convert2

	clr temp4
	ldi temp3, 48

	ldi zl, low(DecNum)	;set z to decnum
	ldi zh, high(DecNum)

	DecNumL:
		cpi temp4, 5
		breq End_C
		inc temp4
		ld temp, z+
		add temp, temp2
		do_lcd_data temp
		rjmp DecNumL


End_C:
	pop zh
	pop zl
	pop temp4
	pop temp3
	pop temp2
	pop temp