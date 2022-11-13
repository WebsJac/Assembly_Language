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
	ldw r2, TEST_STR(r0)
	call printString
	movi r2, '\n'
	call printChar
	movia r2, TEXT2
	call printString
	ldw r2, TEST_STR(r0)
	call makeUpper			#make sure uppercase first letter is returned in r2
	call printString
	movi r2, '\n'
	call printChar 
	movia r2, TEXT3
	call printString
	ldw r2, COUNT(r0)		#save COUNT to memory. Make a .skip location
	call printString
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
	ret

makeUpper:
	subi sp, sp, 20
	stw ra, 16(sp)
	stw r3, 12(sp)
	stw r4, 8(sp)
	stw r5, 4(sp) 	#a
	stw r6, 0(sp)	#z
	
	mov r3, r2
	movi r5, 'a'
	movi r6, 'z'
	movi r2, 0	#count of numbers converted from lowercase to uppercase
mu_loop:
	ldb r4, 0(r3)
	beq r4, r0, mu_end_loop
	blt r4, r5, mu_else
	bgt r4, r6, mu_else
	subi r4, r4, 'a'
	addi r4, r4, 'A'
	stw r4, 0(r3)	#store back where it came from
	addi r2, r2, 1
mu_else:
	addi r3, r3, 1
	br mu_loop
mu_end_loop:
	stw r2, COUNT(r0)
	mov r2, r3		#reput first address into r2
	ldw ra, 16(sp)
	ldw r3, 12(sp)
	ldw r4, 8(sp)
	ldw r5, 4(sp)
	ldw r6, 0(sp)
	ret

.org 0x1000
TEXT1: .ascii "Original text is "
TEXT2: .ascii "New text is "
TEXT3: .ascii "Number of changes = "
COUNT: .skip 4






	











