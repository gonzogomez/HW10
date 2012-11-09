.data
	prompt: .asciiz "Please enter the first operand: "
	prompt2: .asciiz "Please enter the second operand: "
	prompt3: .asciiz "Please enter the operation(*,/) "
	operator: .space 40
	multsign: .asciiz "*"
	divsign: .asciiz "/"
	
.text

.globl multiplication

multiplication:
	li $t1, 0
	li $t2, 16
loop:
	andi $t0, $s1, 1	# store the  least significant bit of the product in t0
	beq $t0, $0, shift	# if the least significant bit is equal to 0 jump to shift
	srl $t0, $s1, 16	# store the upper half of the product in t0
	add $t0, $t0, $s0	# add multiplicand to the left half of the product
	sll $t0, $t0, 16
	and $s1, $s1, 0x0000ffff
	or $s1, $s1, $t0	# place the result in the left half of Product register
shift:
	srl $s1, $s1, 1		# shift the product right 1 bit
	add $t1, $t1, 1		# t1 = t1 + 1
	slt $t3, $t1, $t2	# t1 < 32
	bne $t3, $0, loop
	add $s3, $s1, $0	
	j end

.globl division

division:
	li $t1, 0
	li $t2, 16
	sll $s0, $s0, 1		# shift the Remainder register left 1 bit
loopd:
	srl $t0, $s0, 16	# store the upper half of the remainder in t0
	sub $t0, $t0, $s1	# Subtract the Divisor register from the left half of the Remainder register
	sll $t0, $t0, 16
	and $s0, $s0, 0x0000ffff
	or $s0, $s0, $t0	# place the result in the left half of the Remainder register.
	andi $t0, $s0, 0x10000000	# store the most significant bit of the remainder in t0
	srl $t0, $t0, 28
	beq $t0, $0, more
	add $t1, $t1, 1		# t1 = t1 + 1
	slt $t3, $t1, $t2	# t1 < 32
	bne $t3, $0, loopd
	j done
	
more:
	sll $s0, $s0, 1		# shift the Remainder register to the left
	ori $s0, $s0, 1		# set the new rightmost bit to 1
	add $t1, $t1, 1		# t1 = t1 + 1
	slt $t3, $t1, $t2	# t1 < 32
	bne $t3, $0, loopd
	j done
done:
	add $s3, $s0, $0
	j end

.globl main

main:
	li $v0, 4		# display prompt
	la $a0, prompt
	syscall
	li $v0, 5		# get first operand from user
	syscall
	add $s0, $v0, $0	# store first operand in s0
	li $v0, 4		# display prompt2
	la $a0, prompt2
	syscall
	li $v0, 5		# get second operand from user
	syscall
	add $s1, $v0, $0	# store second operand in s1
	li $v0, 4		# display prompt3
	la $a0, prompt3	
	syscall
	la $a0, operator
	li $a1, 3		# reads 3 things: a character, an enter, and a null
	li $v0, 8		#load the "read string" syscall number
	syscall
	la $s2, operator	# operator = s2 = value returned
	lbu $t4, 0($s2)		# loads the character entered by the user
	la $t0, multsign	# loads the address of the multiply symbol
	lbu $t5, 0($t0)		# loads the multiply symbol to t5
	beq $t4, $t5, multiplication	# if the character entered is a "*" jump to mulitplication
	la $t0, divsign		# loads the address of the division symbol
	lbu $t5, 0($t0)		# loads the division ymblo to t5
	beq $t4, $t5, division	# if the character entered is a "/" jump to division
end:
	add $a0, $s3, $0
	li $v0, 1
	syscall

	
