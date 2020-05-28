 /*
 * bi2dec.asm
 *
 *  Created: 10/1/2018 12:42:12 PM
 *   Author: lakew
 */ 
.cseg
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

	ldi zl, low(HoleCounter)
	ldi zh, high(HoleCounter)
	ld temp2, z+		;stores origional number
	ld temp3, z

	ldi yl, low(DecNum)
	ldi yh, high(DecNum)

Bin2Bcd:	
	ldi r21, low(10000)
	ldi r20, high(10000)
	rcall Bin2Digit

	ldi r21, low(1000)
	ldi r20, high(1000)
	rcall Bin2Digit

	ldi r21, low(100)
	ldi r20, high(100)
	rcall Bin2Digit

	ldi r21, low(10)
	ldi r20, high(10)
	rcall Bin2Digit

	ldi r21, low(1)
	ldi r20, high(1)
	rcall Bin2Digit

	;epilogue
	pop yh
	pop yl
	pop zh
	pop zl
	pop r22
	pop r21
	pop r20
	pop temp4
	pop temp3
	pop temp2
	pop temp

ret


Bin2Digit:
	clr r22
	Subtract:
		cp temp2, r21
		cpc temp3, r20
		brlt store
	
		sub temp2, r21
		sbc temp3, r20
		inc r22
		rjmp Subtract
	
	store:
		st y+, r22


	ret