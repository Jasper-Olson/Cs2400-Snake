
#adresses taken:
#s0  - screen array
#t0 & $t1 - drawscreen macro


.data

newLine: .asciiz "\n"
screen: .word 
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0


.macro drawScreen
li $t0, 0
loop: 
beq $t0, 128, end
rem $t1, $t0, 16
beq $t1, 0, addLine
newLineReturn:
addi $t0, $t0, 1
lw $t1, 0($s0)
li $v0, 11
beq $t1, 1, printBody
beq $t1, 0, printSpace

addLine:
li $v0, 4
la $a0, newLine
syscall
j newLineReturn

printBody:
li $a0, 0
syscall
addi $s0, $s0, 4
j loop

printSpace:
li $a0, ' '
syscall
addi $s0, $s0, 4
j loop
end:
subi $s0, $s0, 512
.end_macro 

.macro flip(%x, %y)
li $t0, 0
li $t1, 16
mul $t1, $t1, %y
add $t1, $t1, %x
mul $t1, $t1, 4
add $s0, $s0, $t1
lw $t0, 0($s0)
slti $t0, $t0, 1
sw $t0, 0($s0)
sub $s0, $s0, $t1
.end_macro 


.text

main:
la $s0, screen
drawScreen

flip(0, 0)
flip(15,0)
flip(0,7)
flip(15,7)

drawScreen


exit:
li $v0, 10
syscall
