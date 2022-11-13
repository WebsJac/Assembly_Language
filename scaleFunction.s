#Assembly code to scale an element using subroutines	
	.text
	.global _start
	.org 0
	_start:
MAIN:
	movia sp, 0x7FFFFC
	ldw r4, N(r0) 				#load counter pointer
	movi r5, LIST				#puts an actual number into memory. Not an address.
	
LOOP:
	ldw r2, 0(r5)				#passing first item to our subroutine
	ldw r3, SCALE(r0)			#passing our scale factor to our subroutine. This could be placed in MAIN to save space
	call SCALE_LIST 			#call our function
	stw r2, 0(r5)				#r5 and r3 haven't changed, only r2 has

	addi
	subi r4, r4, 1 				#decrement counter each time
	bgt r4, r0, LOOP			#continue through loop as long as r4>r0. Closes loop as well
	

	break

SCALE_LIST:
	subi sp, sp, 8				#make space to store new variables. Moves stack pointer down
	stw ra, 4(sp)
	stw r4, 2(sp)				#must store r4 since it is important
						#beside sp is number of stw operations * 4, then count down	
	mul r4, r2, r3				#compute scaled number
	mov r2, r4				
	
	ldw ra, 4(sp)				#reassign register with their original contents
	ldw r4, 0(sp)				
	addi sp, sp, 8				#reincrease sp to its original number	
	ret


.org 0x1000
	N: .word 5				#of elements
	LIST: .word 1,-2,6,3,-1			#elements in list
	SCALE: .word 2