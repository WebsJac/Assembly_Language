	.org 0 
	.global _start
_start:
	ldw r2, N(r0)					#r2 is loop counter( decrementing)
	movi r3, LIST					#r3 points to first element
	movi r4, 0					#r4 accumulates the sum, initialize to zero
	movi r6, 0					#initialize r6 to zero, this will be our negative number counter
LOOP:
	ldw r5, 0(r3)					#get next element
	add r4, r4, r5					#add element to accumulating sum
	IF:
		bge r5, r0, END_IF			#if contents are greater than or equal to zero, then exit loop
	THEN:
		addi r6, r6, 1				#must be less than zero, so increment neg_count by 1
	END_IF:	
	addi r3, r3, 4					#advance the list pointer
	subi r2, r2, 1 					#decrement counter by one
	bgt r2, r0, LOOP 				#branch if r2 > r0

	br_ end

	stw r4, SUM(r0)					#write final accumulated value to memory
	stw r6, NEG_COUNT(r0) 				#write number of negative numbers to memory
_end:
	
	N:     		.word 				#number of elements
	SUM: 		.skip 		4		#reserve space for sum
	NEG_COUNT 	.skip 		4
	LIST:		.word 		0x		#location of element 1
	   		.word 		0x		#location of element 2
 	   		.word 		0x		#location of element 3