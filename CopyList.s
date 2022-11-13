#CopyList Subroutine

CopyList:
	subi sp, sp, 16
	stw r2, 12(sp)
	stw r3, 8(sp)
	stw r4, 4(sp)
	stw r5, 0(sp)

cl_loop:
	ldw r5, 0(r2)
	stw r5, 0(r3) 
	addi r2, r2, 4
	addi r3, r3, 4
	subi r4, r4, 1
	bgt r4, r0, cl_loop

	ldw r2, 12(sp)
	ldw r3, 8(sp)
	ldw r4, 4(sp)
	ldw r5, 0(sp)
	addi sp, sp, 16


#CopyListPos
CopyListPos:
	subi sp, sp, 16
	stw r3, 12(sp)	#list2 ptr
	stw r4, 8(sp)	#orig N
	stw r5, 4(sp)	#element from list1
	stw r6, 0(sp)	#index k

	movi r6, 0
	
clp_loop:
clp_if:
	ldw r5, 0(r2)
	ble r5, r0, clp_end_if
clp_then:				#list[i]>0
	stw r5, 0(r3)
	addi r3, r3, 4			#advance list2 pointer
	addi r6, r6, 1			#increase k
clp_end_if:
	addi r2, r2, 4			#advance list1 pointer
	subi r4, r4, 1
	bgt r4, r0, clp_loop
	
	mov r2, r6			#move r6 into r2

	ldw r3, 12(sp)	#list2 ptr
	ldw r4, 8(sp)	#orig N
	ldw r5, 4(sp)	#element from list1
	ldw r6, 0(sp)	#index k
	addi sp, sp, 16

	ret
	