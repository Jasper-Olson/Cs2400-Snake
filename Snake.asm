#CS2640
#Jasper Olson, Kimberly Bui, Lily Konefat, Maxwell Severson, Sean Ayuby

#-----------------------IMPORTANT NOTE-----------------------------
# This code uses the Keyboard and Display MMIO Simulator for I/O, *NOT* the console at the bottom of the screen
# TO RUN THIS CODE, GO TO TOOLS -> KEYBOARD AND DISPLAY MMIO SIMULATOR AND PRESS CONNECT TO MIPS IN THE BOTTOM LEFT CORNER
# THEN YOU CAN ASSEMBLE, PRESS RUN, PRESS RESET ON THE MMIO PAGE, AND TYPE THE WASD CONTROLS IN THE BOTTOM FIELD
# WHEN YOU DIE, CLICK THE REPLAY BUTTON AT THE TOP, THEN THE RUN BUTTON, THEN THE RESET BUTTON ON THE MMIO SCREEN
# thank you for reading :)


#adresses occupied:
#s0  - address 0 of the screen
#s1 - snake head's address
#s2 - snake tail's address
#s3 - time of last update
#t0 & t1 - temp values for all the macros
#t2 - time elapsed since code began
#t3 & t4 - user input direction


.data
#holds all the info to draw what's happening
screen: .word 
1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
1, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
deathScreen: .asciiz "\n\n\n\n\n             You Died"

#prints out the full grid with spaces for 0 and boxes for 1
.macro drawScreen
#reset t0 because it gets overridden all over the place
li $t0, 0
#reset the previous screen drawn in the MMIO display
putChar(12)
loop: 
#exit after traversing the array
beq $t0, 320, end
#print a new line every 16 digits 
rem $t1, $t0, 32
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
#print fruit if its 2
beq $t1, 2, printFruit
#print body symbol otherwise
j printBody
#afterward, they both jump back to loop

addLine:
putChar(10)
sw $t1, 0xffff000c($zero)
j newLineReturn

printBody:
putChar('x')
addi $s0, $s0, 4
j loop

printFruit:
putChar('o')
addi $s0, $s0, 4
j loop

#print a space to the MMIO display
printSpace:
putChar(32)
addi $s0, $s0, 4
j loop

end:
#shift s0 back to its starting register
subi $s0, $s0, 1280
#exit
.end_macro 

.macro drawDeathScreen
putChar(12)
lui $t0, 0xffff      # Load base address 0xffff0000 into $t0
    la  $s0, deathScreen            # Load pointer to string

print_loop:
    lb  $a0, 0($s0)         # Load next character from string
    beq $a0, $zero, exit    # If null terminator (0), finish

check_ready:
    lw  $t1, 8($t0)         # Read transmitter control at 0xffff0008
    andi $t1, $t1, 1        # Check ready bit (bit 0)
    beq $t1, $zero, check_ready # If not ready, keep polling

    sw  $a0, 12($t0)        # Write character to transmitter data at 0xffff000c
    addiu $s0, $s0, 1       # Move to next character
    j   print_loop

exit:
.end_macro 

#prints a character to the MMIO display, or clears the display
.macro putChar(%c)
waitReady:
lw   $t1, 0xffff0008($zero)
andi $t1, $t1, 1
beqz $t1, waitReady
li   $t1, %c
sw   $t1, 0xffff000c($zero)
.end_macro

#removes 1 tail, sets $s2 to the space it points to
.macro trimTail
#load the tail's current value
#every segment holds the direction of the next segment in the snake
lw $t0, 0($s2)
#translate registers to bytes
mul $t0, $t0, 4
#clear the value of the old tail
sw $zero, 0($s2)
#move s2 to the next segment over
add $s2, $s2, $t0
li $t0, 0
#exit
.end_macro


#Moves the head 1 unit in direction dir
.macro moveHead(%dir) 
#dir equals -1, +1, -32, or +32, which are the number of 
#units needed to shift right, left, up, or down
move $t0, %dir
#save the new direction value to the old head
sw $t0, 0($s1)
#translate from registers to bytes 
mul $t0, $t0, 4
#move that many spaces forward
add $s1, $s1, $t0
#skip trimming if it's a fruit
lw $t0, 0($s1)
beq $t0, 2, eat
#otherwise, trim the tail
trimTail
#die if the next space is a body segment or wall
lw $t0, 0($s1)
bnez  $t0, death 
#skip to here assuming it was a fruit
eat:
#call the spawnFruit macro if a fruit was just eaten
bne $t0, 2, continue
spawnFruit
continue:
#put a placeholder value in the new head, so it still gets drawn
li $t0, 1
sw $t0, 0($s1)
#exit
li $t0, 0
.end_macro 

#places a fruit on a random empty space on the map
.macro spawnFruit
loop:
li $v0, 42
li $a1, 321
syscall
mul $a0, $a0, 4
add $s0, $s0, $a0
lw $t0, 0($s0)
sub $s0, $s0, $a0
bne $t0, 0, loop
li $t0, 2
add $s0, $s0, $a0
sw $t0, 0($s0)
sub $s0, $s0, $a0
.end_macro 



#combine moveHead and trimTail, taking WASD as a parameter
.macro moveSnake (%dir)
move $t0, %dir
#check what the input was
beq $t0, 'w', wCase
beq $t0, 'a', aCase
beq $t0, 's', sCase
beq $t0, 'd', dCase
#if it was something else, disregard it
j exit
wCase:
#w = up = back 32 spaces 
li $t0, -32
#jump to what comes next, so t0 doesn't get overridden
j next
aCase:
#a = left = back 1 space
li $t0, -1
j next
sCase:
#s = down = forward 32 spaces
li $t0, 32
j next
dCase:
#d = right = forward 1 space
li $t0, 1

next:
#pass in t0 for moveHead
moveHead($t0)
#leave
exit:
.end_macro 

.text
main:
#start keeping track of system time
li $v0, 30
syscall
move $s3, $a0
#screen stays in $s0
la $s0, screen
#starting the head at space 103
addi $s1, $s0, 428
#starting the tail at space 99
addi $s2, $s0, 392
li $t3, 'd'

#movement
loop:
#load the time since starting the program
li $v0, 30
syscall
#load keyboard control register
lw $t0, 0xFFFF0000($zero)
#check if there is a key pressed (the first bit stores that)
andi $t0, $t0, 0x0001
#if something was pressed, go to the method
bgt $t0, $zero, changeDirection
#loop back to the top if not enough time has passed
subu $t2, $a0, $s3  
#step speed
bltu $t2, 225, loop
#now that we're ready, update $s3 to mark this timestamp
move $s3, $a0     

#if 2 keypresses have come through since the last update, handle the old one first
bne $t1, 1, safeToMoveSnake
li $t1, 0
moveSnake($t4)
drawScreen
j loop

#otherwise, move it in the new direction
safeToMoveSnake:
moveSnake($t3)
#save the last direction that was actually executed
move $t4, $t3
drawScreen
j loop

changeDirection:
#make sure $t3 hold the last dirction EXECUTED, so that unexecuted instructions don't get overridden
beq $t3, $t4, sameDir
#if the old $t3 hasn't been run yet, flag $t1 to let MoveSnake run the old one first
li $t1, 1
#save the old value to t4 before t3 gets overridden
move $t4, $t3
sameDir:
#load the new keypress into $t0 to check if the input was valid
#first, make sure the key is W,A,S, or D
lw $t0, 0xFFFF0004($zero)
beq $t0, 'w', keyOK
beq $t0, 'a', keyOK
beq $t0, 's', keyOK
beq $t0, 'd', keyOK
j loop         
keyOK:
#next, make sure it's not trying to back into itself
#pressing w after s
subi $t0, $t0, 4
beq $t0, $t3, loop
#pressing s after w
addi $t0, $t0, 8
beq $t0, $t3, loop
#pressing d after a
subi $t0, $t0, 7
beq $t0, $t3, loop
#pressing a after d
addi $t0, $t0, 6
beq $t0, $t3, loop
#otherwise, the key press is valid, so update the direction in $t3
lw $t3, 0xFFFF0004($zero)
j loop


death:
drawDeathScreen
syscall
li $v0, 10
syscall
