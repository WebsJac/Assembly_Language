.text
.global _start
.org 0

.equ JTAG_UART_BASE, 0x10001000		#address of first JTAG UART register
.equ DATA_OFFSET, 0			#offset of JTAG UART data register
.equ STATUS_OFFSET, 4			#offset of JTAG UART status register
.equ WSPACE_MASK, 0xFFFF		#used in AND operation to check status

_start:
movia sp, 0x7FFFFC
movi r2, '\n'
call PrintChar				#prints new line
movia r2, TEXT				#points to first address in TEXT
call PrintString

movi r2, ' '
call PrintChar				#prints a space

break

PrintString:
	subi sp, sp, 12
	stw ra, 8(sp)
	stw r3, 4(sp)			#save r3 so it can be used as temp
	stw r2, 0(sp)
	
	mov r3, r2			#move first address into r3 to use as a counter of sorts
ps_loop:
	ldb r2, 0(r3)			#load byte from r3
ps_if:
	beq r2, r0, ps_end_if	#if r2 is equal to the end symbol then stop branching
ps_then:
	call PrintChar
	addi r3, r3, 1 			#traverse to next
	br ps_loop			#loop to next iteration
ps_end_if:
	ldw ra, 8(sp)
	ldw r3, 4(sp)
	ldw r2, 0(sp)
	addi sp, sp, 12
	ret

PrintChar:
	subi sp, sp, 12
	stw ra, 8(sp)
	stw r3, 4(sp)			#save value of r3 so it can be a temp
	stw r4, 0(sp)			#save value of r4 so it can be a temp
	movia r3, JTAG_UART_BASE	#point to first memory mapped IO register
pc_loop:
	ldwio r4, STATUS_OFFSET(r3)	#read bits from status register
	andhi r4, r4, WSPACE_MASK	#mask off lower bits to isolate upper bits
	beq r4, r0, pc_loop		#keep going until upper bits are not zero
	stwio r2, DATA_OFFSET(r3)	#write character to data register
	ldw ra, 8(sp)
	ldw r3, 4(sp)
	ldw r4, 0(sp)
	addi sp, sp, 12
	ret

.org 0x1000
TEXT: 	.asciz	"Random text\n"
	.end

#------------------------------------------------------------------------------------------------------------------

#PrintHexDigit - print an ascii character 0-9 or A-F for an input value n and priunt it to screen
PrintHexDigit: 
	subi sp, sp, 12
	stw ra, 8(sp)		#return address
	stw r2, 4(sp)		#original n
	stw r3, 0(sp)		#constant to compare - 9

	movi r3, 9		#to compare
phd_if:
	bgt r2, r3, phd_else	#will skip number
phd_then:
	addi r2, r2, '0'	#add constant '0' to r2
	br phd_end_if
phd_else:
	subi r2, r2, 10		#subtract 10 from n
	addi r2, r2, 'A'	#add character A. Will make n a value between A and F
phd_end_if:
	call PrintChar		#argument is ready in r2

	ldw ra, 8(sp)
	ldw r2, 4(sp)		
	ldw r3, 0(sp)
	addi sp, sp, 12

	ret

#-------------------------------------------------------------------------------------------------------------------

#PrintHexByte - call PrintHexDigit twice to get first four bits then next four bits - number between 0 and 255
#Shift right by 4 then do printhexdigit for high. mask with 0xF for low thne do printhexdigit.
PrintHexByte:
	subi sp, sp, 12		#IF A REGISTER IS MODIFIED SAVE ITS VALUE
	stw ra, 8(sp)
	stw r2, 4(sp)		#r2 is being used to save and restore and won't be returned so we save
	stw r3, 0(sp)		#orginal value of n
	
	mov r3, r2		#copy r2 to r3
	
	srli r2, r2, 4		#shift right by 4 bits
	call PrintHexDigit

	andi r2, r3, 0xF	#and with 0xF
	call PrintHexDigit
	
	ldw ra, 8(sp)
	ldw r2, 4(sp)		#r2 is being used to save and restore and won't be returned so we save
	ldw r3, 0(sp)		#orginal value of n
	addi sp, sp, 12
	
	ret

#----------------------------------------------------------------------------------------------------------------------

PrintHexWord: 			#32 bits
	subi sp, sp, 12
	stw ra, 8(sp)
	stw r2, 4(sp)
	stw r3, 0(sp)

	mov r3, r2   		#make a copy of r2
	srli r2, r3, 24		#shift right logical immediate by 24 bits. Put into r2, r3 is preserved
	call PrintHexByte	#byte 1
	srli r2, r3, 16
	andi r2, r2, 0xFF	#to get rid of byte 1
	call PrintHexByte	#byte 2	
	srli r2, r3, 8
	andi r2, r2, 0xFF
	call PrintHexByte	#byte 3
	andi r3, r3, 0xFF
	call PrintHexByte	#byte 4

	ldw ra, 8(sp)
	ldw r2, 4(sp)
	ldw r3, 0(sp)
	addi sp, sp, 12	

	ret
#------------------------------------------------------------------------------------------------------------------------

PrintDec99: 			#print decimal between 0 and 99
	subi sp, sp, 16
	stw ra, 12(sp)
	stw r2, 8(sp)		#keep n value preserved
	stw r3, 4(sp)		#tens
	stw r4, 0(sp)		#ones + temp

	movi r4, 10
	div r3, r2, r4		#put tens into r3
	muli r4, r3, 10		#multiply tens by 10 and put into r4
	sub r4, r2, r4
pd_if:
	ble r3, r0, pd_end_if	#skip then if there is no tens component
pd_then:
	addi r3, r3, '0'	#add character code for digit
	mov r2, r3
	call PrintChar
pd_end_if:
	addi r4, r4, '0'
	mov r2, r4
	call PrintChar
	
	ldw ra, 12(sp)
	ldw r2, 8(sp)		#keep n value preserved
	ldw r3, 4(sp)		#tens
	ldw r4, 0(sp)		#ones + temp
	addi sp, sp, 16

	ret

#-------------------------------------------------------------------------------------------------------------------------

MakeUpperCase:
	subi sp, sp, 20
	stw ra, 16(sp)
	stw r3, 12(sp)		#string pointer from r2
	stw r4, 8(sp)		#ch
	stw r5, 4(sp)		#a for if statement
	stw r6, 0(sp)		#z for if statement

	mov r3, r2		#move string pointer to r3
	movi r5, 'a'
	movi r6, 'z'
	movi r2, 1		#count of number of characters converted from lower to upper
mu_loop:
	ldb r4, 0(r3)		#load character into r4
mu_if:
	be r4, r0, mu_loop_end	#we are at end of string
mu_else:
	blt r4, r5, mu_end_if
	bgt r4, r6, mu_end_if	#character is lowercase if it is between 'a' and 'z'
	subi r4, r4, 'a'
	addi r4, r4, 'A'	#now uppercase
	addi r2, r2, 1		#increment count by 1
	stw r4, 0(r3)		#store back where it came from
mu_end_if:
	addi r3, r3, 1		#increment string pointer by 1
	br mu_loop
mu_loop_end:			#at end of string, restore registers and return
	ldw ra, 16(sp)
	ldw r3, 12(sp)		#string pointer from r2
	ldw r4, 8(sp)		#ch
	ldw r5, 4(sp)		#a for if statement
	ldw r6, 0(sp)		#z for if statement
	addi sp, sp, 20
	ret
	











	
	