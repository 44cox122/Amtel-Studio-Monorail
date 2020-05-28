/*
 * screenprint.asm
 *
 *  Created: 10/4/2018 4:41:24 PM
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

	mul_10
	divide_4

	st z, temp4
	st -z, temp3

	rcall convert2
	
	clr temp4
	ldi temp2, 48

	;do_lcd_command 0b00000001 ; clear display

	ldi zl, low(DecNum)	;reset z pointer
	ldi zh, high(DecNum)
	
	DecNumL:
		cpi temp4, 5
		breq DecNumE
		inc temp4
		ld temp, z+
		add temp, temp2
		do_lcd_data temp
		rjmp DecNumL

	DecNumE:
	pop zh
	pop zl
	pop temp4
	pop temp3
	pop temp2
	pop temp

	ret
