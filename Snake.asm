#adresses taken:
#s0  - address 0 of screen
#s1 - snake head's address
#s2 - snake tail's address
#t0 & t1 - temp values for all the macros

.data
newLine: .asciiz "\n"
screen: .word 
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0,
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

#prints out the full grid with spaces for 0 and boxes for 1
.macro drawScreen
#reset t0 because it gets overridden all over the place
li $t0, 0
loop: 
#exit after traversing the array
beq $t0, 128, end
#print a new line every 16 digits 
rem $t1, $t0, 16
beq $t1, 0, addLine
#if a new line was added, it jumps back here
newLineReturn:
#iterate t0
addi $t0, $t0, 1
#load the value saved at s0
lw $t1, 0($s0)
li $v0, 11
#print a space if its 0
beq $t1, 0, printSpace
#print body symbol otherwise
j printBody
#afterward, they both jump back to loop

addLine:
li $v0, 4
la $a0, newLine
syscall
j newLineReturn

printBody:
#0 in mars ascii looks like a rectangle
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
#shift s0 back to its starting register
subi $s0, $s0, 512
#exit
.end_macro 


#removes 1 tail, sets $s2 to the space it points to
.macro trimTail
#load the tail's current value
#every segment holds the direction of the next segment in the snake
lw $t0, 0($s2)
#translate registers to bytes
mul $t0, $t0, 4
#clear the value if the old tail
sw $zero, 0($s2)
#move s2 to the next segment over
add $s2, $s2, $t0
#exit
.end_macro


#Moves the head 1 unit in direction dir
.macro moveHead(%dir) 
#dir equals -1, +1, -16, or +16, which are the number of 
#units needed to shift right, left, up, or down
move $t0, %dir
#save the new direction value to the old head
sw $t0, 0($s1)
#translate from registers to bytes 
mul $t0, $t0, 4
#move that many spaces forward
add $s1, $s1, $t0
#put a placeholder value in the new head, so it still gets drawn
li $t0, 1
sw $t0, 0($s1)
#exit
.end_macro 

#combine moveHead and trimTail, taking WASD as a parameter
.macro moveSnake (%dir)
li $t0, %dir
#check what the input was
beq $t0, 'w', wCase
beq $t0, 'a', aCase
beq $t0, 's', sCase
beq $t0, 'd', dCase
#if it was something else, disregard it
j exit
wCase:
#w = up = back 16 spaces 
li $t0, -16
#jump to what comes next, so t0 doesn't get overridden
j next
aCase:
#a = left = back 1 space
li $t0, -1
j next
sCase:
#s = down = forward 16  spaces
li $t0, 16
j next
dCase:
#d = right = forward 1 space
li $t0, 1

next:
#pass in t0 for moveHead
moveHead($t0)
#trim tail too
trimTail
#leave
exit:
.end_macro 

.macro sleep
li $v0, 32
la $a0, 200
syscall
.end_macro 
.text

main:
#screen stays in $s0
la $s0, screen
#starting the head at space 55
addi $s1, $s0, 220
#starting the tail at space 51
addi $s2, $s0, 204

#example for movement
loop:
moveSnake('d')
drawScreen
sleep
moveSnake('d')
drawScreen
sleep
moveSnake('d')
drawScreen
sleep
moveSnake('d')
drawScreen
sleep
moveSnake('w')
drawScreen
sleep
moveSnake('a')
drawScreen
sleep
moveSnake('w')
drawScreen
sleep
moveSnake('a')
drawScreen
sleep
moveSnake('a')
drawScreen
sleep
moveSnake('a')
drawScreen
sleep
moveSnake('a')
drawScreen
sleep
moveSnake('a')
drawScreen
sleep
moveSnake('a')
drawScreen
sleep
moveSnake('s')
drawScreen
sleep
moveSnake('a')
drawScreen
sleep
moveSnake('s')
drawScreen
sleep
moveSnake('d')
drawScreen
sleep
moveSnake('d')
drawScreen
sleep
moveSnake('d')
drawScreen
sleep
moveSnake('d')
drawScreen
sleep
j loop

exit:
li $v0, 10
syscall
