/*
 * Convert.asm
 *
 *  Created: 10/8/2018 6:38:08 PM
 *   Author: lakew
 */ 
 convert2:
	;prologue
	push temp
	push temp2	;rBin1L old number
	push temp3	;rBin1H
	push temp4
	push r20	;rBin2H
	push r21	;rBin2L
	push r22
	push zl
	push zh
	push yl
	push yh