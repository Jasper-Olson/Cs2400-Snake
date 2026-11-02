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
#s4 - number of fruits eaten
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
deathScreen: .asciiz "\n\n\n\n\n                 You Died\n             Your score was "

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
#skip if its the 0th space
beqz $t0, newLineReturn
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
#character 10 = \n
putChar(10)
j newLineReturn

printBody:
#prints an x
putChar('x')
#shifts s0 over to the next element
addi $s0, $s0, 4
j loop

printFruit:
#prints an o
putChar('o')
#shifts s0 over to the next element
addi $s0, $s0, 4
j loop

printSpace:
#prints a space
putChar(32)
#shifts s0 over to the next element
addi $s0, $s0, 4
j loop

end:
#shift s0 back to its starting register
subi $s0, $s0, 1280
#exit
.end_macro 

.macro drawDeathScreen
#wipe the display
putChar(12)
#load the death screen to s0
la  $s0, deathScreen
#loop through s0 and print each char in order
loop:
#load the ascii value at each step of s0
lb  $a0, 0($s0)
#exit once the value is null
beq $a0, $zero, exit
#otherwise, wait for the display to be ready
wait:
#load the reciever control register
lw  $t1, 0xffff0008($zero)   
#mask everything but the first bit (ready or not)
andi $t1, $t1, 1        
#if it's not ready, keep waiting
beq $t1, $zero, wait
#now that it's ready, load the ascii value into the transmitter data register
sw  $a0, 0xffff000c($zero) 
#move to the next character
addi $s0, $s0, 1
#jump back
j loop
exit:
#leave
.end_macro 

#prints a character, or clears the display
.macro putChar(%c)
#wait till the display is ready to print
wait:
#load the transmitter control register
lw $t1, 0xffff0008($zero)
#mask off anything but the first bit (ready or not)
andi $t1, $t1, 1
#if its not ready, keep waiting
beqz $t1, wait
#now that it's ready, store the char in the transmitter data register
li $t1, %c
sw $t1, 0xffff000c($zero)
#leave
.end_macro

.macro putInt(%i)
#t1 and t2 hold second and third digits. 
#if the number doesn't have a second/third digit, it's negative
li $t1, -1
li $t2, -1
#if there's 3 digits, go to printTripleDigit
bgt %i, 99, printTripleDigit
#if there's 2 digits, go to printDoubleDigit
bgt %i, 9, printDoubleDigit
#otherwise go to printSingleDigit 
j printSingleDigit

printTripleDigit:
#t2 = i%10 = last digit
rem $t2, %i, 10
#t1 = i%100 / 10 = middle digit
rem $t1, %i, 100
div $t1, $t1, 10
#t0 = i/100 = first digit
div $t0, %i, 100
#move to the printing step
j go


printDoubleDigit:
#t1 = i%10 = second digit
rem $t1, %i, 10
#t0 = i / 10 = first digit
div $t0, %i, 10
#move to the printing step
j go
printSingleDigit:
#load the int to t0
move $t0, %i

go:
#move on to printing stuff
#wait until the transmitter is ready
wait:
#load transmitter control register
lw $t3, 0xffff0008($zero)
#mask off everything but the first bit (ready or not)
andi $t3, $t3, 1
#if its not ready, keep waiting
beqz $t3, wait
#once it is, store it in the transmitter data register
addi $t0, $t0, 48
sw $t0, 0xffff000c($zero)
#if that was the only digit, leave
beq $t1, -1, finalWait
#otherwise repeat above for $t1
move $t0, $t1 
#then load $t2 into slot t1 so it happens on the next call
move $t1, $t2
#reset t2 if necessary
li $t2, -1
#repeat till t1 is -1
j wait
#wait again to make sure it gets printed
finalWait:
#again, load the transmitter control register
lw $t1, 0xffff0008($zero)
#mask everything but the first bit (ready or not)
andi $t1, $t1, 1
#if its not ready, keep waiting
beqz $t1, finalWait
#leave once its done
exit:
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
#pass by unless it was a fruit
bne $t0, 2, continue
#otherwise spawn a new fruit somewhere else
spawnFruit
#increment fruits eaten
addi $s4, $s4, 1
continue:
#put a placeholder value in the new head, so it still gets drawn
li $t0, 1
sw $t0, 0($s1)
#exit
li $t0, 0
.end_macro 

#places a fruit on a random empty space on the map
.macro spawnFruit
#picks a random space until its empty
loop:
#load a random integer
li $v0, 42
#set the upper bound to 321 (exclusive)
li $a1, 321
syscall
#translate unit distance for registers
mul $a0, $a0, 4
#shift $s0 by a0 spaces
add $s0, $s0, $a0
#load the value at that register
lw $t0, 0($s0)
#shift s0 back a0 spaces
sub $s0, $s0, $a0
#if the character at that space isn't 0, try again
bne $t0, 0, loop
#now that we know slot $a0 is free, shift $s0 back over there
add $s0, $s0, $a0
#store 2 in that register
li $t0, 2
sw $t0, 0($s0)
#shift $s0 back to the first register
sub $s0, $s0, $a0
#leave
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

#-----------------------------------------------------------------------------------
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
#start the direction moving right
li $t3, 'd'
#start the number of fruits eaten at 0
li $s4, 0

#movement
loop:
#load the time since starting the program
li $v0, 30
syscall
#load the reciever control register
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
#if t1 is 1, there are 2 or more keypresses to process
#if t1 doesnt equal 1, skip over to safeToMoveSnake
bne $t1, 1, safeToMoveSnake
#otherwise, move with the older direction
moveSnake($t4)
#update the screen
drawScreen
#reset $t1 back to 0
li $t1, 0
#skip back up to handle the second value
j loop

#if we're here, there's only one keypress to process
safeToMoveSnake:
#move in that direction
moveSnake($t3)
#update the screen
drawScreen
#save the last direction that was executed and drawn
move $t4, $t3
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
#load the reciever data register to $t0
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
#otherwise, the key press is valid, so update the direction from the reciever data in $t3
lw $t3, 0xFFFF0004($zero)
j loop

death:
#clear the game screen and print a death screen
drawDeathScreen
#print the number of fruits eaten
putInt($s4)
#exit program
li $v0, 10
syscall
