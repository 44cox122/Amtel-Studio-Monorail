/*
 * macros.asm
 *
 *  Created: 10/4/2018 4:39:43 PM
 *   Author: lakew
 */ 
 ;macros
.macro clear
ldi YL, low(@0) ; load the memory address to Y pointer
ldi YH, high(@0)
clr temp ; set temp to 0
st Y+, temp ; clear the two bytes at @0 in SRAM
st Y, temp
.endmacro

.macro do_lcd_command
	ldi r16, @0
	rcall lcd_command
	rcall lcd_wait
.endmacro

.macro do_lcd_data
	push temp
	mov r16, @0
	rcall lcd_data
	rcall lcd_wait
	pop temp
.endmacro

.macro do_lcd_data2
	push temp
	ldi r16, @0
	rcall lcd_data
	rcall lcd_wait
	pop temp
.endmacro	

.macro divide_4
	clc
	ror temp4
	ror temp3
	clc
	ror temp4
	ror temp3

.endmacro

.macro mul_10
	push temp
	push temp2
	
	clc
	rol temp3
	rol temp4
	mov temp, temp3
	mov temp2, temp4

	clc
	rol temp3
	rol temp4
	clc
	rol temp3
	rol temp4

	add temp3, temp
	adc temp4, temp2

	pop temp2
	pop temp

.endmacro