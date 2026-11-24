#CS2640
#Jasper Olson, Kimberly Bui, Lily Konefat, Maxwell Severson, Sean Ayuby


#-----------------------IMPORTANT NOTE-----------------------------
# This code uses the Keyboard and Display MMIO Simulator for I/O, *NOT* the console at the bottom of the screen
# TO RUN THIS CODE, GO TO TOOLS -> KEYBOARD AND DISPLAY MMIO SIMULATOR AND PRESS CONNECT TO MIPS IN THE BOTTOM LEFT CORNER
# THEN YOU CAN ASSEMBLE, PRESS RUN, PRESS RESET ON THE MMIO PAGE, AND TYPE THE WASD CONTROLS IN THE BOTTOM FIELD
# WHEN YOU DIE, CLICK THE REPLAY BUTTON AT THE TOP, THEN THE RUN BUTTON, THEN THE RESET BUTTON ON THE MMIO SCREEN

#In order to run the bitmap display, go to tools -> Bitmap Display
#On startup, set these display values:
#	Unit Width in pixels: 16
#	Unit Height in pixels: 16
#	Display Width in pixels: 512
#	Display Height in pixels: 256
#	Base address for display: 0x10008000 ($gp) <--------
#Connect and reset it in the same way as the MMIO Simulator
# thank you for reading :)



#adresses occupied:
.eqv screenAddress $s0 #s0  - address 0 of the screen
.eqv snakeHead $s1 #s1 - snake head's address
#s2 - snake tail's address
#s3 - time of last update
#s4 - number of fruits eaten
#s5 & s6 - music board & counter
#t0 & t1 - temp values for all the macros
#t2 - time elapsed since code began, and other temporary values when a third is needed
#t3 & t4 - user input direction
#t7 - board clears
.eqv optionSelect $t5
.eqv speed $t6
.eqv chimeSpeed $t8



.include "macrosSnake.asm"

.data
#holds all the info to draw what's happening
screen: .word 
3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,
3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3,
3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3,
3, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3,
3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3,
3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3,
3, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3,
3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3,
3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3,
3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3,
3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3,
3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3,
3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3,
3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3,
3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3,
3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,

music: .word 
60, 250, 0, 250, 62, 250, 0, 250, 67, 250, 0, 250, 62, 250, 0, 250, 
60, 250, 0, 250, 62, 250, 0, 250, 67, 250, 0, 250, 62, 250, 0, 250, 
60, 250, 0, 250, 62, 250, 0, 250, 67, 250, 0, 250, 62, 250, 0, 250, 
60, 250, 0, 250, 62, 250, 0, 250, 67, 250, 0, 250, 62, 250, 0, 250, 
60, 250, 0, 250, 62, 250, 0, 250, 65, 250, 0, 250, 67, 250, 0, 250, 72, 250, 0, 250, 65, 250, 0, 250, 67, 500,
0, 500, 65, 250, 0, 250, 62, 250, 0, 250, 65, 250, 0, 250, 60, 250, 0, 250, 62, 250, 0, 250, 65, 250, 0, 250, 67, 500, 0, 500,

60, 250, 0, 250, 62, 250, 0, 250, 67, 250, 0, 250, 62, 250, 0, 250, 
60, 250, 0, 250, 62, 250, 0, 250, 67, 250, 0, 250, 62, 250, 0, 250, 
60, 250, 0, 250, 62, 250, 0, 250, 67, 250, 0, 250, 62, 250, 0, 250, 
60, 250, 0, 250, 62, 250, 0, 250, 67, 250, 0, 250, 62, 250, 0, 250,   
60, 250, 0, 250, 57, 250, 0, 250, 60, 250, 0, 250, 57, 250, 0, 250, 
60, 250, 0, 250, 62, 250, 0, 250, 64, 500, 0, 500,
62, 250, 0, 250, 65, 250, 0, 250, 67, 250, 0, 250, 
62, 250, 0, 250, 65, 250, 0, 250, 69, 250, 0, 250, 67, 500, 0, 500, 

65, 250, 0, 250, 62, 250, 0, 250, 69, 250, 0, 250, 67, 250, 0, 250, 
65, 250, 0, 250, 62, 250, 0, 250, 69, 250, 0, 250, 67, 250, 0, 250, 
65, 250, 0, 250, 62, 250, 0, 250, 69, 250, 0, 250, 67, 250, 0, 250, 
65, 250, 0, 250, 62, 250, 0, 250, 69, 250, 0, 250, 67, 250, 0, 250, 
65, 500, 0, 500, 62, 500, 0, 500, 60, 500, 0, 500, 57, 500, 0, 500, 
55, 250, 0, 250, 53, 250, 0, 250, 55, 250, 0, 250, 57, 250, 0, 250, 55, 250, 0, 250, 53, 250, 0, 250, 50, 500, 0, 500,

48, 250, 0, 250, 50, 250, 0, 250, 53, 250, 0, 250, 55, 250, 0, 250, 
50, 250, 0, 250, 53, 250, 0, 250, 55, 250, 0, 250, 57, 250, 0, 250, 
55, 250, 0, 250, 53, 250, 0, 250, 55, 250, 0, 250, 57, 250, 0, 250, 
60, 250, 0, 250, 57, 250, 0, 250, 62, 500, 0, 500,  
65, 250, 0, 250, 62, 250, 0, 250, 69, 250, 0, 250, 67, 250, 0, 250, 
65, 250, 0, 250, 62, 250, 0, 250, 69, 250, 0, 250, 67, 250, 0, 250, 
65, 250, 0, 250, 62, 250, 0, 250, 69, 250, 0, 250, 67, 250, 0, 250, 
65, 250, 0, 250, 67, 250, 0, 250, 65, 500, 0, 500

deathScreen: .asciiz "\n\n\n\n\n                 You Died\n             Your score was "
mainMenu: .asciiz "\n\n\n\n\nHello! Welcome to Snake in Assembly!\n Please select 's' to start or 'o' to go to options to get started!"
options: .asciiz "\n\n\nYou have selected the menu Option, \nyou can change the speed of the snake to make things harder or easier for you!\nPlease enter 'e' for easy mode, 'n' for normal mode, and 'h' for hard mode. \nIf you would like to go back, please enter 'b'."
error: .asciiz "n\n\n\nError: Not an option is selected, please try again."
easy: .asciiz "\n\n\nYou have selected easy. Press 'c' to continue."
normal: .asciiz "\n\n\nYou have selected normal. Press 'c' to continue."
hard: .asciiz "\n\n\nYou have selected hard. Press 'c' to continue"

#-----------------------------------------------------------------------------------
.text
	li speed, 225
main:
	drawMainMenu
	#get input
	lui $t0, 0xffff
test:
	lw $t1, 0($t0)
	andi $t1, $t1, 0x0001
	beq $t1, $zero, test
	lw $a0, 4($t0)
cont:
	move optionSelect, $a0
	beq optionSelect, 's', start
	beq optionSelect, 'o', option
	#if select option, go to settings
	#otherwise, go to start
	
option:
	drawOption
loopOption:
	lw $t1, 0($t0)
	andi $t1, $t1, 0x0001
	beq $t1, $zero, loopOption
	lw $a0, 4($t0)
	move optionSelect, $a0
	beq optionSelect, 'b', main
	Options(optionSelect)
	j main
errorOp:
	printInMMIO(error)
	j option
	
#----------------------ACTUAL SNAKE GAME-------------------------#
start:
#start keeping track of system time
li $v0, 30
syscall
move $s3, $a0
#screen stays in $s0
la $s0, screen
#starting the head at space 107
addi $s1, $s0, 428
#starting the tail at space 98
addi $s2, $s0, 392
#start the direction moving right
li $t3, 'd'
#start the number of fruits eaten at 0
li $s4, 0
#draw the initial board
drawScreen
#Initialize music values
la $s5, music #base address for music sheet
li chimeSpeed, 0 #duration of time to wait
move $s7, $a0 #time since last chime

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
bgtu $t0, $zero, changeDirection
#find the time since the last note was played
subu $t2, $a0, $s7
bgtu $t2, chimeSpeed, musicTime
#loop back to the top if not enough time has passed
subu $t2, $a0, $s3  
#step speed
bltu $t2, speed, loop
#now that we're ready, update $s3 to mark this timestamp
move $s3, $a0     

#if 2 keypresses have come through since the last update, handle the old one first
#if t1 is 1, there are 2 or more keypresses to process
#if t1 doesnt equal 1, skip over to safeToMoveSnake
bne $t1, 1, safeToMoveSnake
#otherwise, move with the older direction
moveSnake($t4)
#reset $t1 back to 0
li $t1, 0
#skip back up to handle the second value
j loop

#if we're here, there's only one keypress to process
safeToMoveSnake:
#move in that direction
moveSnake($t3)
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
	
musicTime:
addu $s7, $s7, chimeSpeed
musicMacro
j loop

death:
#clear the game screen and print a death screen
drawDeathScreen
#exit program
li $v0, 10
syscall
