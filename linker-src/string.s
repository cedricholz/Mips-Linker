# CS 61C Summer 2016 Project 2-2 
# string.s

#==============================================================================
#                              Project 2-2 Part 1
#                               String README
#==============================================================================
# In this file you will be implementing some utilities for manipulating strings.
# The functions you need to implement are:
#  - strlen()
#  - strncpy()
#  - copy_of_str()
# Test cases are in linker-tests/test_string.s
#==============================================================================

.data
newline:	.asciiz "\n"
tab:	.asciiz "\t"

.text
#------------------------------------------------------------------------------
# function strlen()
#------------------------------------------------------------------------------
# Arguments:
#  $a0 = string input
#
# Returns: the length of the string
#------------------------------------------------------------------------------
strlen:
	addiu $sp, $sp, -4	#Prologue
	sw $ra, 0($sp)
	
	and $t1, $0, $0		#fix counter to zero
strloop:
	lb $t0, 0($a0)  	#load byte of str
	beqz $t0, endlen		#end if null terminator reached
	addiu $t1, $t1, 1	#Increment counter
	addiu $a0, $a0, 1	#increment address
	j strloop		#loop!
endlen:
	addiu $v0, $t1, 0 	#return counter
	
	lw $ra, 0($sp)		#Epilogue
	addiu $sp, $sp, 4
	jr $ra

#------------------------------------------------------------------------------
# function strncpy()
#------------------------------------------------------------------------------
# Arguments:
#  $a0 = pointer to destination array
#  $a1 = source string
#  $a2 = number of characters to copy
#
# Returns: the destination array
#------------------------------------------------------------------------------
strncpy:
	# YOUR CODE HERE
	addiu $sp, $sp, -4	#Prologue
	sw $ra, 0($sp)
	
	addu $t1, $a0, $0
luup:
	beqz $a2, endcpy		#Return when number of chars to copy reaches zero
	lb $t0, 0($a1)		#load from source
	sb $t0, 0($a0)		#store in dest
	addiu $a0, $a0, 1	#increment address 1 byte
	addiu $a1, $a1, 1	#increment address 1 byte
	addiu $a2, $a2, -1	#decrement num chars
	j luup	
endcpy:
	addu $v0, $t1, $0	#Set return value (head of dest array)
	
	lw $ra, 0($sp)		#Epilogue
	addiu $sp, $sp, 4
	jr $ra

#------------------------------------------------------------------------------
# function copy_of_str()
#------------------------------------------------------------------------------
# Creates a copy of a string. You will need to use sbrk (syscall 9) to allocate
# space for the string. strlen() and strncpy() will be helpful for this function.
# In MARS, to malloc memory use the sbrk syscall (syscall 9). See help for details.
#
# Arguments:
#   $a0 = string to copy
#
# Returns: pointer to the copy of the string
#------------------------------------------------------------------------------
copy_of_str:
	# YOUR CODE HERE
	addiu $sp, $sp, -12	#Prologue
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	
	addu $s1, $a0, $0
	jal strlen		#Call strlen to get length
	beqz $v0, getout
	addu $a2, $0, $v0	#Store length of string in $a2
	addu $a1, $s1, $0	#move source string to $a1 to prepare for strncopy call
	addu $a0, $a2, 0	#set size to $a0 for syscall
	addiu $v0, $0, 9	#set syscall var
	syscall			#syscall 9 to malloc heap space
	addu $s0, $v0, $0	#Save malloced pointer to return
	addu $a0, $v0, $0	#move malloced pointer to $a0
	jal strncpy		#execute the copy
getout:
	addu $v0, $s0, $0	
	
	lw $ra, 0($sp)		#Epilogue
	lw $s0, 4($sp)
	lw $s1, 8($sp)		
	addiu $sp, $sp, 12
	jr $ra

###############################################################################
#                 DO NOT MODIFY ANYTHING BELOW THIS POINT                       
###############################################################################

#------------------------------------------------------------------------------
# function streq() - DO NOT MODIFY THIS FUNCTION
#------------------------------------------------------------------------------
# Arguments:
#  $a0 = string 1
#  $a1 = string 2
#
# Returns: 0 if string 1 and string 2 are equal, -1 if they are not equal
#------------------------------------------------------------------------------
streq:
	beq $a0, $0, streq_false	# Begin streq()
	beq $a1, $0, streq_false
streq_loop:
	lb $t0, 0($a0)
	lb $t1, 0($a1)
	addiu $a0, $a0, 1
	addiu $a1, $a1, 1
	bne $t0, $t1, streq_false
	beq $t0, $0, streq_true
	j streq_loop
streq_true:
	li $v0, 0
	jr $ra
streq_false:
	li $v0, -1
	jr $ra			# End streq()
#------------------------------------------------------------------------------
# function dec_to_str() - DO NOT MODIFY THIS FUNCTION
#------------------------------------------------------------------------------
# Convert a number to its unsigned decimal integer string representation, eg.
# 35 => "35", 1024 => "1024". 
#
# Arguments:
#  $a0 = int to write
#  $a1 = character buffer to write into
#
# Returns: the number of digits written
#------------------------------------------------------------------------------
dec_to_str:
	li $t0, 10			# Begin dec_to_str()
	li $v0, 0
dec_to_str_largest_divisor:
	div $a0, $t0
	mflo $t1		# Quotient
	beq $t1, $0, dec_to_str_next
	mul $t0, $t0, 10
	j dec_to_str_largest_divisor
dec_to_str_next:
	mfhi $t2		# Remainder
dec_to_str_write:
	div $t0, $t0, 10	# Largest divisible amount
	div $t2, $t0
	mflo $t3		# extract digit to write
	addiu $t3, $t3, 48	# convert num -> ASCII
	sb $t3, 0($a1)
	addiu $a1, $a1, 1
	addiu $v0, $v0, 1
	mfhi $t2		# setup for next round
	bne $t2, $0, dec_to_str_write
	jr $ra			# End dec_to_str()
