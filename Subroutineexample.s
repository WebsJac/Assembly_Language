/*Code for subroutines*/
#pseudo code --> 3 nested loops, we would add operations within these loops and return a specific variable
#sub1(0x11110002, 0x11110003, 0x11110004)
#sub2(0x22220002, 0x22220003, 0x22220004)
#sub3(0x33330002, 0x33330003, 0x33330004)


_start:
main:
	movia sp, 0x00007FFC 		#stack not at very end of memory, but sufficiently far
	
	movia r2, 0x11110002		#we use R2 for argument 1, r3 for argument 2 and r4 for argument 3
	movia r3, 0x11110003	
	movia r4, 0x11110004 		
	call Sub1

Sub1:	
	subi sp, sp, 16			#allocate enough space, decrease by 4*number of saved
	stw ra, 12(sp)			#ra for nested calls
	stw r2, 8(sp)
	stw r3, 4(sp)
	stw r4, 0(sp)	
	
	movia r2, 0x22220002
	movia r3, 0x22220003
	movia r4, 0x22220004
	call Sub2  			#this call will change ra so its important we save registers and ra
	
	ldw ra, 12(sp)			#load the new values created
	ldw r2, 8(sp)
	ldw r3, 4(sp)
	ldw r4, 0(sp)
	addi sp, sp, 16
	ret

Sub2:
	subi sp, sp, 16
	stw ra, 12(sp)
	stw r2, 8(sp)
	stw r3, 4(sp)
	stw r4, 0(sp)
	
	movia r2, 0x33330002
	movia r3, 0x33330003
	movia r4, 0x33330004
	call Sub3
	
	ldw ra, 12(sp)
	ldw r2, 8(sp)
	ldw r3, 4(sp)
	ldw r4, 0(sp)
	addi sp, sp, 16
	ret

Sub3:
	#nothing in here, except return function
	ret