.data
	prompt: .asciiz "Please enter the first operand: "
	prompt2: .asciiz "Please enter the second operand: "
	prompt3: .asciiz "Please enter the operation(*,/) "
	errormessage: .asciiz "The operation you entered was not listed"
	errormessage2: .asciiz "You cannot divide by 0"
	operator: .space 40
	multsign: .asciiz "*"
	divsign: .asciiz "/"
	quotient: .asciiz "quotient"
	remainder: .asciiz "remainder"
	product: .asciiz "product"
	equalsign: .asciiz "="
	semicolon: .asciiz ";"
	colon: .asciiz ":"
	
.text

.globl multiplication

multiplication:
	li $t1, 0
	li $t2, 32
	li $s2, 0
loop:
	andi $t0, $s1, 1		# store the  least significant bit of the product in t0
	beq $t0, $0, shift		# if the least significant bit is equal to 0 jump to shift
	add $s2, $s2, $s0		# add multiplicand to the left half of the product and place the result in the left half of Product register
shift:
	andi $t0, $s2, 1
	srl $s1, $s1, 1			# shift the product right 1 bit
	beq $t0, $0, nextm		# if t0 = 0 jump to next
	ori $s1, $s1, 0x80000000
nextm:
	srl $s2, $s2, 1
	add $t1, $t1, 1			# t1 = t1 + 1
	slt $t3, $t1, $t2		# t1 < 32
	bne $t3, $0, loop
	add $s3, $s1, $0	
	j multend

.globl division

division:
	beq $s1, $0, error2		# if you are dividing by 0 jump to error message
	li $t1, 0
	li $t2, 32
	li $s2, 0
	sll $s0, $s0, 1			# shift the Remainder register left 1 bit
loopd:
	sub $s2, $s2, $s1		# Subtract the Divisor register from the left half of the Remainder register
	andi $t0, $s2, 0x80000000	# store the most significant bit of the remainder in t0
	srl $t0, $t0, 31
	beq $t0, $0, more
	add $s2, $s2, $s1
	andi $t0, $s0, 0x80000000
	sll $s0, $s0, 1			# shift the Remainder register to the left and set the new least significant bit to 0
	sll $s2, $s2, 1			# shift the left half of the Remainder register to the left
	beq $t0, $0, nextd
	ori $s2, $s2, 0x00000001
nextd:
	add $t1, $t1, 1			# t1 = t1 + 1
	slt $t3, $t1, $t2		# t1 < 32
	bne $t3, $0, loopd
	j done
	
more:
	andi $t0, $s0, 0x80000000
	sll $s0, $s0, 1			# shift the Remainder register to the left
	ori $s0, $s0, 1			# set the new rightmost bit to 1
	sll $s2, $s2, 1			# shift the left half of the Remainder register to the left
	beq $t0, $0, nextd2
	ori $s2, $s2, 0x00000001
nextd2:
	add $t1, $t1, 1			# t1 = t1 + 1
	slt $t3, $t1, $t2		# t1 < 32
	bne $t3, $0, loopd
	j done
done:
	srl $s2, $s2, 1			# shift left half of Remainder right 1 bit
	add $s3, $s0, $0
	add $s4, $s2, $0
	j divend

.globl main

main:
	li $v0, 4			# display prompt
	la $a0, prompt
	syscall
	li $v0, 5			# get first operand from user
	syscall
	add $s0, $v0, $0		# store first operand in s0
	add $s5, $s0, $0		# store first operand in s5
	li $v0, 4			# display prompt2
	la $a0, prompt2
	syscall
	li $v0, 5			# get second operand from user
	syscall
	add $s1, $v0, $0		# store second operand in s1
	add $s6, $s1, $0		# store second operand in s6
	li $v0, 4			# display prompt3
	la $a0, prompt3	
	syscall
	la $a0, operator
	li $a1, 3			# reads 3 things: a character, an enter, and a null
	li $v0, 8			#load the "read string" syscall number
	syscall
	la $s2, operator		# operator = s2 = value returned
	lbu $t4, 0($s2)			# loads the character entered by the user
	la $t0, multsign		# loads the address of the multiply symbol
	lbu $t5, 0($t0)			# loads the multiply symbol to t5
	beq $t4, $t5, multiplication	# if the character entered is a "*" jump to mulitplication
	la $t0, divsign			# loads the address of the division symbol
	lbu $t5, 0($t0)			# loads the division ymblo to t5
	beq $t4, $t5, division		# if the character entered is a "/" jump to division
	j error				# the character entered is not a "*' or a "/" jump to error message
divend:
	li $v0, 1			# diplay first operand
	add $a0, $s5, $0
	syscall
	li $v0, 4			# display "/"
	la $a0, divsign
	syscall
	li $v0, 1			# diplay second operand
	add $a0, $s6, $0
	syscall
	li $v0, 4			# display ":"
	la $a0, colon
	syscall
	li $v0, 4			# display quotient prompt
	la $a0, quotient
	syscall
	li $v0, 4			#display equals sign
	la $a0, equalsign
	syscall
	add $a0, $s3, $0		# dislplay quotient
	li $v0, 1
	syscall
	li $v0, 4
	la $a0, semicolon		# display semicolon
	syscall
	li $v0, 4			# display remainder prompt
	la $a0, remainder
	syscall
	li $v0, 4			# display equals sign
	la $a0, equalsign
	syscall
	add $a0, $s4, $0		# display remainder
	li $v0, 1
	syscall
	j end
multend:
	li $v0, 1			# diplay first operand
	add $a0, $s5, $0
	syscall
	li $v0, 4			# display "*"
	la $a0, multsign
	syscall
	li $v0, 1			# diplay second operand
	add $a0, $s6, $0
	syscall
	li $v0, 4			# display ":"
	la $a0, colon
	syscall
	li $v0, 4			# display product prompt
	la $a0, product
	syscall
	li $v0, 4			# display equals sign
	la $a0, equalsign
	syscall
	li $v0, 1			# display product
	add $a0, $s3, $0
	syscall
	j end
error:
	li $v0, 4			# display error prompt
	la $a0, errormessage
	syscall
	j end
error2:
	li $v0, 4			# display error2 prompt
	la $a0, errormessage2
	syscall
	j end
end:

	
