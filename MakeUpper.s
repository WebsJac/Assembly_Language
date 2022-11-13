#MakeUpper.s is a program that converts all characters in a string to uppercase values

.text
.global _start
.org 0

.equ JTAG_UART_BASE, 0x10001000
.equ DATA_OFFSET, 0
.equ STATUS_OFFSET, 4
.equ MASK, 0xFFFF

_start: 
	movia sp, 0x7FFFFC
	movia r2, TEXT1
	call printString
	movia r2, TEST_STR
	call printString
	movi r2, '\n'
	call printChar
	movia r2, TEXT2
	call printString
	movia r2, TEST_STR
	call makeUpper			#make sure uppercase first letter is returned in r2
	movia r2, TEST_STR
	call printString		#move uppercase test_str in and print it
	movi r2, '\n'
	call printChar 
	movia r2, TEXT3
	call printString
	ldw r2, COUNT(r0)		#COUNT was saved to memory. Load from it.
	call printChar
	movi r2, '\n'
	call printChar
	break

printChar:
	subi sp, sp, 12
	stw ra, 8(sp)
	stw r3, 4(sp)
	stw r4, 0(sp)
	
	movia r3, JTAG_UART_BASE
pc_loop:
	ldwio r4, STATUS_OFFSET(r3)
	andhi r4, r4, MASK
	beq r4, r0, pc_loop
	stwio r2, DATA_OFFSET(r3)
	
	ldw ra, 8(sp)
	ldw r3, 4(sp)
	ldw r4, 0(sp)
	addi sp, sp, 12
	ret

printString:
	subi sp, sp, 12
	stw ra, 8(sp)
	stw r2, 4(sp)
	stw r3, 0(sp)

	mov r3, r2
ps_loop:
	ldb r2, 0(r3)
	beq r2, r0, ps_end_if
ps_then:
	call printChar
	addi r3, r3, 1
	br ps_loop
ps_end_if:
	ldw ra, 8(sp)
	ldw r2, 4(sp)
	ldw r3, 0(sp)
	addi sp, sp, 12
	ret

makeUpper:
	subi sp, sp, 24	#r2 contains the first address of test_str
	stw ra, 20(sp)
	stw r2, 16(sp)
	stw r3, 12(sp)
	stw r4, 8(sp)
	stw r5, 4(sp) 	#lowercase a
	stw r6, 0(sp)	#lowercase z
	
	mov r3, r2		#move this first address into r3
	movi r5, 'a'
	movi r6, 'z'
	mov r4, r0	#count of numbers converted from lowercase to uppercase
mu_loop:
	ldb r2, 0(r3)	#load r2 with letter at pointer
	beq r2, r0, mu_end_loop		#if this value is zero, we're done
	blt r2, r5, mu_end		#check if value is between a and z, if it is go to next char
	bgt r2, r6, mu_end
	subi r2, r2, 'a' 
	addi r2, r2, 'A'
	addi r4, r4, 1	#increment count by 1
	stb r2, 0(r3)	#store the value to the address
mu_end:
	addi r3, r3, 1	#go to next byte and repeat
	br mu_loop
	
mu_end_loop:
	stw r4, COUNT(r0)
	
	ldw ra, 20(sp)
	ldw r2, 16(sp)
	ldw r3, 12(sp)
	ldw r4, 8(sp)
	ldw r5, 4(sp)
	ldw r6, 0(sp)
	addi sp, sp, 24
	ret

.org 0x1000
COUNT: .skip 4
TEXT1: .asciz "Original text is "
TEXT2: .asciz "New text is "
TEXT3: .asciz "Number of changes = "
TEST_STR: .asciz "testing"






	











