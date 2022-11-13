#CalcAvg program to calculate the average of a list of integers 

.text
.global _start
.org 0 

_start:
	movia sp, 0x7FFFFC
	movia r2, LIST
	movia r3, N
	ldw r3, 0(r3)
	
	call CalcAvg
	movia r3, AVG
	stw r2, 0(r3)
	mov r4, r2
	movia r2, LIST			#repoint to start of list	
	movia r3, N
	ldw r3, 0(r3)
	
	call CountGTorEQAvg		#count numbers greater than or equal to the average
	movia r5, N_GT_OR_EQ
	stw r2, 0(r5)
	sub r2, r3, r2
	movia r5, N_LT
	stw r2, 0(r5)
	
	break

CalcAvg:
	subi sp, sp, 12
	stw r3, 8(sp)	#orig n
	stw r4, 4(sp)	#list element
	stw r5, 0(sp)	#sum

	movi r5, 0 	#sum = 0
	
	calc_loop:
		ldw r4, 0(r2)		#read list[i]
		add r5, r5, r4		#sum = sum + list[i]
		addi r2, r2, 4		#advance list pointer
		subi r3, r3, 1		#decrement N
		bgt r3, r0, calc_loop

	ldw r3, 8(sp)		#load original N
	divu r2, r5, r3 	#avg = sum/N, return in r2
	
	ldw r3, 8(sp)
	ldw r4, 4(sp)
	ldw r5, 0(sp)
	addi sp, sp, 12
	
	ret
CountGTorEQAvg:
	subi sp, sp, 16
	stw r3, 12(sp)		#orig N
	stw r4, 8(sp)		#orig avg
	stw r5, 4(sp)		#list element
	stw r6, 0(sp)		#count

	movi r6, 0		#initialize count to zero
	
	count_loop:
		if:
		ldw r5, 0(r2)		#read list[i]
		blt r5, r4, end_if	#its less than avg so don't increment count
		then:
		addi r6,r6,1
		end_if:
		addi r2,r2,4		#next element
		subi r3, r3, 1		#decrement N
		bgt r3, r0, count_loop

	mov r2, r6		#put count from r6 to r2
	
	ldw r3, 12(sp)
	ldw r4, 8(sp)
	ldw r5, 4(sp)
	ldw r6, 0(sp)
	addi sp, sp, 16

	ret
DiffFromAvg:			#function to calc difference between avg and a number. Not called in this program
	subi sp, sp, 12
	stw r2, 8(sp)		#orig lst pointer
	stw r3, 4(sp)		#orig N
	stw r5, 0(sp)		#element from list
	
	dfa_loop:
		ldw r5, 0(r2)
		sub r5, r5, r4		#subtract avg, r4
		stw r5, 0(r2)
		
		addi r2, r2, 4
		subi r3, r3, 1
		bgt r3, r0, dfa_loop
	ldw r2, 8(sp)
	ldw r3, 4(sp)
	ldw r5, 0(sp)
	addi sp, sp, 12
	ret

.org 0x1000
N: .word 6
LIST: .word 44, 52, 67, 74, 82, 93
AVG: .skip 4
N_GT_OR_EQ: .skip 4
N_LT:	.skip 4
	.end
