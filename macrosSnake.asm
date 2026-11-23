#------MACROS------#

.macro printInMMIO(%reg)
	putChar(12)
	la $s0, %reg
loop: 
	lb $a0, 0($s0) #load byte into $a0, from the offset(base address(screen))
	beq $a0, $zero, exit #exit once value is null just like death screen
wait:
	lw $t1, 0xffff0008($zero)
	andi $t1, $t1, 1
	beq $t1, $zero, wait
	sw $a0, 0xffff000c($zero)
	addi $s0, $s0, 1
	j loop
exit:
.end_macro
