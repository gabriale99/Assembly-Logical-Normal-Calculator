.include "./cs47_proj_macro.asm"
.text
.globl au_logical
# TBD: Complete your project procedures
# Needed skeleton is given
#####################################################################
# Implement au_logical
# Argument:
# 	$a0: First number
#	$a1: Second number
#	$a2: operation code ('+':add, '-':sub, '*':mul, '/':div)
# Return:
#	$v0: ($a0+$a1) | ($a0-$a1) | ($a0*$a1):LO | ($a0 / $a1)
# 	$v1: ($a0 * $a1):HI | ($a0 % $a1)
# Notes:
#####################################################################
au_logical:
# TBD: Complete it
	addi	$sp, $sp, -24
	sw	$fp, 24($sp)
	sw	$ra, 20($sp)
	sw	$a0, 16($sp)
	sw	$a1, 12($sp)
	sw	$a2, 8($sp)
	addi	$fp, $sp, 24
	
	beq	$a2, '+', au_logical_addition
	beq	$a2, '-', au_logical_substraction
	beq 	$a2, '*', au_logical_multiplication
	beq 	$a2, '/', au_logical_division
au_logical_addition:
	jal	add_logical	
	j	au_logical_ret
au_logical_substraction:
	jal	sub_logical
	j	au_logical_ret
au_logical_multiplication:
	jal	mul_signed
	j	au_logical_ret
au_logical_division:
	jal	div_signed
	j	au_logical_ret
au_logical_ret:
	#restore RTE
	lw	$fp, 24($sp)
	lw	$ra, 20($sp)
	lw	$a0, 16($sp)
	lw	$a1, 12($sp)
	lw	$a2,  8($sp)
	addi	$sp, $sp, 24
	jr 	$ra

add_sub_logical:
	addi	$sp, $sp, -32
	sw	$fp, 32($sp)
	sw	$ra, 28($sp)
	sw	$a0, 24($sp)
	sw	$a1, 20($sp)
	sw	$a2, 16($sp)
	sw	$s0, 12($sp)
	sw	$s1, 8($sp)
	addi	$fp, $sp, 32
	
	add	$s0, $zero, $zero # index i = 0
	add	$s1, $zero, $zero
	extract_nth_bit($s1, $a2, $s0) # C = a2[0] to $s1
	add	$v0, $zero, $zero # S = 0
	beq	$a2, 0xFFFFFFFF, inversion
add_sub_logical_loop:
	extract_nth_bit($t0, $a0, $s0) # a0[i] to $t0
	extract_nth_bit($t1, $a1, $s0) # a1[i] to $t1
	xor	$t2, $t0, $t1 # A XOR B
	and	$t3, $t0, $t1 # AB
	and	$t4, $s1, $t2 # Cin(A XOR B)
	xor	$t2, $s1, $t2 # Y = C XOR A XOR B
	or	$s1, $t3, $t4 # C = AB OR Cin(A XOR B)
	insert_to_nth_bit($v0, $s0, $t2, $t5) # S[i] = Y
	
	add	$s0, $s0, 1 # i = i + 1
	bne	$s0, 32, add_sub_logical_loop # i == 32? return: loop
	move	$v1, $s1 # return final carry out
	j	add_sub_logical_ret
inversion:
	not	$a1, $a1
	j	add_sub_logical_loop
add_sub_logical_ret:
	#restore RTE
	lw	$fp, 32($sp)
	lw	$ra, 28($sp)
	lw	$a0, 24($sp)
	lw	$a1, 20($sp)
	lw	$a2, 16($sp)
	lw	$s0, 12($sp)
	lw	$s1, 8($sp)
	addi	$sp, $sp, 32
	jr 	$ra

add_logical:
	addi	$sp, $sp, -24
	sw	$fp, 24($sp)
	sw	$ra, 20($sp)
	sw	$a0, 16($sp)
	sw	$a1, 12($sp)
	sw	$a2, 8($sp)
	addi	$fp, $sp, 24
	
	li	$a2, 0x00000000 # set mode to addition
	jal	add_sub_logical
add_logical_ret:
	#restore RTE
	lw	$fp, 24($sp)
	lw	$ra, 20($sp)
	lw	$a0, 16($sp)
	lw	$a1, 12($sp)
	lw	$a2, 8($sp)
	addi	$sp, $sp, 24
	jr 	$ra
	
sub_logical:
	addi	$sp, $sp, -24
	sw	$fp, 24($sp)
	sw	$ra, 20($sp)
	sw	$a0, 16($sp)
	sw	$a1, 12($sp)
	sw	$a2, 8($sp)
	addi	$fp, $sp, 24
	
	li	$a2, 0xFFFFFFFF # set mode to substraction
	jal	add_sub_logical
sub_logical_ret:
	#restore RTE
	lw	$fp, 24($sp)
	lw	$ra, 20($sp)
	lw	$a0, 16($sp)
	lw	$a1, 12($sp)
	lw	$a2, 8($sp)
	addi	$sp, $sp, 24
	jr 	$ra
	
twos_complement:
	addi	$sp, $sp, -20
	sw	$fp, 20($sp)
	sw	$ra, 16($sp)
	sw	$a0, 12($sp)
	sw	$a1, 8($sp)
	addi	$fp, $sp, 20

	not	$a0, $a0 # ~$a0
	li	$a1, 1
	jal	add_logical # ~$a0 + 1
	j	twos_complement_ret
twos_complement_ret:
	#restore RTE
	lw	$fp, 20($sp)
	lw	$ra, 16($sp)
	lw	$a0, 12($sp)
	lw	$a1, 8($sp)
	addi	$sp, $sp, 20
	jr	$ra
	
twos_complement_if_neg:
	addi	$sp, $sp, -16
	sw	$fp, 16($sp)
	sw	$ra, 12($sp)
	sw	$a0, 8($sp)
	addi	$fp, $sp, 16
	
	move	$v0, $a0
	blt	$a0, $zero, is_negative # $a0 < 0? twos_complement: continue
	j	twos_complement_if_neg_ret
is_negative:
	jal	twos_complement
	j	twos_complement_if_neg_ret
twos_complement_if_neg_ret:
	#restore RTE
	lw	$fp, 16($sp)
	lw	$ra, 12($sp)
	lw	$a0, 8($sp)
	addi	$sp, $sp, 16
	jr	$ra
	
twos_complement_64bit:
	addi	$sp, $sp, -28
	sw	$fp, 28($sp)
	sw	$ra, 24($sp)
	sw	$a0, 20($sp)
	sw	$a1, 16($sp)
	sw	$s0, 12($sp)
	sw	$s1, 8($sp)
	addi	$fp, $sp, 28
	
	not	$a0, $a0 # inverting lo
	not	$a1, $a1 # inverting hi
	move	$s0, $a1 # $a1 storing
	li	$a1, 1
	jal	add_logical # add 1 to inverted $a0
	move	$s1, $v0 # lo part storing
	move	$a0, $s0 # move $a1 to parameter
	move	$a1, $v1 # move final carry out to parameter
	jal	add_logical
	move	$v1, $v0 # hi
	move	$v0, $s1 # lo
twos_complement_64bit_ret:
	#restore RTE
	lw	$fp, 28($sp)
	lw	$ra, 24($sp)
	lw	$a0, 20($sp)
	lw	$a1, 16($sp)
	lw	$s0, 12($sp)
	lw	$s1, 8($sp)
	addi	$sp, $sp, 28
	jr	$ra

bit_replicator:
	addi	$sp, $sp, -16
	sw	$fp, 16($sp)
	sw	$ra, 12($sp)
	sw	$a0, 8($sp)
	addi	$fp, $sp, 16
	
	beq	$a0, 1, replicate_1s
	beq	$a0, 0, replicate_0s
replicate_1s:
	li	$v0, 0xffffffff
	j	bit_replicator_ret
replicate_0s:
	li	$v0, 0x00000000
	j	bit_replicator_ret	
bit_replicator_ret:
	#restore RTE
	lw	$fp, 16($sp)
	lw	$ra, 12($sp)
	lw	$a0, 8($sp)
	addi	$sp, $sp, 16
	jr	$ra

mul_unsigned:
	addi	$sp, $sp, -36
	sw	$fp, 36($sp)
	sw	$ra, 32($sp)
	sw	$a0, 28($sp) # M = Multiplicand
	sw	$a1, 24($sp) # Lo = Multiplier
	sw	$s0, 20($sp) 
	sw	$s1, 16($sp)
	sw	$s2, 12($sp)
	sw	$s3, 8($sp)
	addi	$fp, $sp, 36
	
	add	$s0, $zero, $zero # index i = 0
	add	$s1, $zero, $zero # Hi = 0
mul_unsigned_loop:
	li	$t0, 0 # for L[0]
	move 	$t1, $a0 # store $a0
	extract_nth_bit($a0, $a1, $t0) # R = L[0]
	jal	bit_replicator # replicate R
	move	$t2, $v0 # R = 32(L[0])
	move	$a0, $t1 # restore $a0
	and	$t2, $a0, $t2 # X = M & R
	move	$s2, $a0 # store $a0
	move	$s3, $a1 # store $a1
	move	$a0, $s1
	move	$a1, $t2
	jal 	add_logical # H = H + X
	move	$s1, $v0 # H
	move	$a0, $s2 # restore $a0
	move	$a1, $s3 # restore $a1
	srl	$a1, $a1, 1 # L = L >> 1
	li	$t0, 0 # for H[0]
	li	$t1, 31 # for L[31]
	extract_nth_bit($t2, $s1, $t0) # H[0]
	insert_to_nth_bit($a1, $t1, $t2, $t3) # L[31] = H[0]
	srl	$s1, $s1, 1 # H = H >> 1
	add	$s0, $s0, 1 # i = i + 1
	bne	$s0, 32, mul_unsigned_loop
	move	$v0, $a1 # $v0 = Lo
	move	$v1, $s1 # $v1 = Hi
mul_unsigned_ret:
	#restore RTE
	lw	$fp, 36($sp)
	lw	$ra, 32($sp)
	lw	$a0, 28($sp) # M = Multiplicand
	lw	$a1, 24($sp) # Lo = Multiplier
	lw	$s0, 20($sp) 
	lw	$s1, 16($sp)
	lw	$s2, 12($sp)
	lw	$s3, 8($sp)
	addi	$sp, $sp, 36
	jr	$ra

mul_signed:
	addi	$sp, $sp, -32
	sw	$fp, 32($sp)
	sw	$ra, 28($sp)
	sw	$a0, 24($sp) # M = Multiplicand, N1
	sw	$a1, 20($sp) # Lo = Multiplier, N2
	sw	$s0, 16($sp)
	sw	$s1, 12($sp)
	sw	$s2, 8($sp)
	addi	$fp, $sp, 32
	
	move	$s0, $a0 # store $a0
	move	$s1, $a1 # store $a1
	jal	twos_complement_if_neg # for M($a0)
	move	$s2, $v0 # store convert M($a0) temporary
	move	$a0, $a1
	jal	twos_complement_if_neg # for L($a1)
	move	$a0, $s2 # 2's complement form of N1
	move	$a1, $v0 # 2's complement form of N2
	jal	mul_unsigned
	li	$t0, 31 # for index
	extract_nth_bit($t1, $s0, $t0) # $a0[31]
	extract_nth_bit($t2, $s1, $t0) # $a1[31]
	xor	$t3, $t1, $t2 # sign
	beq	$t3, 1, mul_signed_sign
	j	mul_signed_ret
mul_signed_sign:
	move	$a0, $v0
	move	$a1, $v1
	jal	twos_complement_64bit
	j	mul_signed_ret
mul_signed_ret:
	#restore RTE
	lw	$fp, 32($sp)
	lw	$ra, 28($sp)
	lw	$a0, 24($sp)
	lw	$a1, 20($sp)
	lw	$s0, 16($sp)
	lw	$s1, 12($sp)
	lw	$s2, 8($sp)
	addi	$sp, $sp, 32
	jr	$ra
	
div_unsigned:
	addi	$sp, $sp, -28
	sw	$fp, 28($sp)
	sw	$ra, 24($sp)
	sw	$a0, 20($sp) # Q = Dividend
	sw	$a1, 16($sp) # D = Divisor
	sw	$s0, 12($sp)
	sw	$s1, 8($sp)
	addi	$fp, $sp, 28
	
	add	$s0, $zero, $zero # index i = 0
	add	$s1, $zero, $zero # R = 0
div_unsigned_loop:
	sll	$s1, $s1, 1 # R = R << 1
	li	$t0, 0 # for index 0
	li	$t1, 31 # for index 31
	extract_nth_bit($t2, $a0, $t1) # Q[31] in $t2
	insert_to_nth_bit($s1, $t0, $t2, $t3) # R[0] = Q[31]
	sll	$a0, $a0, 1 # Q = Q << 1
	move	$s2, $a0 # store Q
	move	$a0, $s1
	jal	sub_logical # S = R - D
	move	$a0, $s2 # restore Q
	move	$t3, $v0 # S in $t3
	blt	$t3, $zero, div_unsigned_increasing_index
	move	$s1, $t3 # R = S
	li	$t0, 0
	li	$t1, 1
	insert_to_nth_bit($a0, $t0, $t1, $t3) # Q[0] = 1
	j	div_unsigned_increasing_index
div_unsigned_increasing_index:
	add	$s0, $s0, 1 # i = i + 1
	bne 	$s0, 32, div_unsigned_loop
	move	$v0, $a0 # Quotient
	move	$v1, $s1 # Reminder
	j	div_unsigned_ret
div_unsigned_ret:
	#restore RTE
	lw	$fp, 28($sp)
	lw	$ra, 24($sp)
	lw	$a0, 20($sp) # Q = Dividend
	lw	$a1, 16($sp) # D = Divisor
	lw	$s0, 12($sp)
	lw	$s1, 8($sp)
	addi	$sp, $sp, 28
	jr	$ra
	
div_signed:
	addi	$sp, $sp, -32
	sw	$fp, 32($sp)
	sw	$ra, 28($sp)
	sw	$a0, 24($sp) # Q = Dividend, N1
	sw	$a1, 20($sp) # D = Divisor, N2
	sw	$s0, 16($sp)
	sw	$s1, 12($sp)
	sw	$s2, 8($sp)
	addi	$fp, $sp, 32
	
	move	$s0, $a0 # store $a0
	move	$s1, $a1 # store $a1
	jal	twos_complement_if_neg # for N1($a0)
	move	$s2, $v0 # store converted N1($a0) temporary
	move	$a0, $a1
	jal	twos_complement_if_neg # for N2($a1)
	move	$a0, $s2 # 2's complement form of N1
	move	$a1, $v0 # 2's complement form of N2
	jal	div_unsigned
	li	$t0, 31 # for index
	extract_nth_bit($t1, $s0, $t0) # $a0[31], sign of R
	extract_nth_bit($t2, $s1, $t0) # $a1[31]
	xor	$t3, $t1, $t2 # sign of Q
	beq	$t3, 1, div_signed_quotient
	beq	$t1, 1, div_signed_reminder
	j	div_signed_ret
div_signed_quotient:
	move	$s0, $v1 # store R
	move	$s1, $t1 # store sign of R
	move	$a0, $v0 # loading Q from div_unsigned
	jal	twos_complement
	move	$v1, $s0
	beq	$s1, 1, div_signed_reminder
	j	div_signed_ret
div_signed_reminder:
	move	$s0, $v0 # store Q
	move	$a0, $v1 # loading R from div_unsigned
	jal	twos_complement
	move	$v1, $v0
	move	$v0, $s0
	j	div_signed_ret
div_signed_ret:
	#restore RTE
	lw	$fp, 32($sp)
	lw	$ra, 28($sp)
	lw	$a0, 24($sp)
	lw	$a1, 20($sp)
	lw	$s0, 16($sp)
	lw	$s1, 12($sp)
	lw	$s2, 8($sp)
	addi	$sp, $sp, 32
	jr	$ra	
