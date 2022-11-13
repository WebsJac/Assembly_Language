	.org 0 
	.global _start
_start:
	ldw r2, N(r0)	#r2 is loop counter( decrementing)
	movi r3, LIST	#r3 points to first element
	movi r4, 0	#r4 accumulates the sum, initialize to zero
LOOP:
	ldw r5, 0(r3)	#get next element
	add r4, r4, r5	#add element to accumulating sum
	addi r3, r3, 4	#advance the list pointer
	subi r2, r2, 1 	#decrement counter by one
	bgt r2, r0, LOOP 	#branch if r2 > r0

	stw r4, SUM(r0)	#write final accumulated value to memory
_end:
	
	N:     	.word 			#number of elements
	SUM: 	.skip			#reserve space for sum
	LIST:	.word 0x		#location of element 1
	   	.word 0x		#location of element 2
 	   	.word 0x		#location of element 3