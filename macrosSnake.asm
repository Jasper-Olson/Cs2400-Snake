#------MACROS------#

.macro printInMMIO(%reg)
	li $t0, 12
	putChar($t0)
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

#prints out the full grid with spaces for 0 and boxes for 1
.macro drawScreen
#reset t0 because it gets used elsewhere 
li $t0, 0
loop: 
#exit after traversing the full array (t0 is the loop counter)
beq $t0, 512, end
#load the value saved at each index of s0
lw $t1, 0($s0)
#print a red fruit if its 2
beq $t1, 2, printFruit
#print a grey wall if its 3
beq $t1, 3, printWall
#print a body segment if it still doesn't equal 0
bnez $t1, printBody
#otherwise, draw a black pixel
j drawBlack

printWall:
#prints a grey pixel at that index
putPix(0x8c8c8c)
j continue

printBody:
#prints a green pixel
putPix(0x00ff00)
j continue

printFruit:
#prints a red pixel
putPix(0xff0000)
j continue

drawBlack:
#prints a black pixel
putPix(0x00000000)

continue:
#shift s0 over to the next element
addi $s0, $s0, 4
#iterate t0
addi $t0, $t0, 1
#repeat for the next index
j loop

end:
#shift s0 back to its initial address after the traversal
subi $s0, $s0, 2048
#exit
.end_macro 

#prints a pixel of some color at index t0
.macro putPix(%color) 
# $t1 stores the base address for the bitmap display
li $t1, 0x10008000
#adjust t0 to the pixel size
mul $t0, $t0, 4
#shift the base adress up to the current pixel	
add $t1, $t1, $t0
#revert t0 in order to keep using it as a loop counter
div $t0, $t0, 4
#color that pixel whichever color it needs to be
li $t2, %color
sw $t2, 0($t1)
#leave
.end_macro 

#draws the 'you died' screen
.macro drawDeathScreen
#wipe the display (passing the value 12 into the MMIO transmitter data register tells it to wipe the display)
li $t0, 12
putChar($t0)
#load the death screen into s0
la $s0, deathScreen
#loop through s0 and print each char in order
loop:
#load the ascii value at each index of s0
lb $a0, 0($s0)
#exit once the value is null
beq $a0, $zero, exit
#otherwise, print it
putChar($a0)
#move to the next character
addi $s0, $s0, 1
#jump back for the next char in s0
j loop
exit:
#print the player's score (the number of fruits eaten)
putInt($s4)
#wait until the display is finished with printing everything out (otherwise the program terminates too early)
wait:
#load the transmitter control register
lw $t1, 0xffff0008($zero) 
#mask off anything but the first bit (ready or not) 
andi $t1, $t1, 1
#if its not ready, keep waiting
beqz $t1, wait
#leave once it's done
.end_macro 

.macro drawMainMenu
	#load the main menu
	li $t7, 12
	putChar($t7)
	la $s0, mainMenu
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

.macro drawOption
	li $t7, 12
	putChar($t7)
	la $s0, options
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

#prints a character, or clears the display
.macro putChar(%c)
#wait till the display is ready to print
wait:
#load the transmitter control register
lw $t2, 0xffff0008($zero) 
#mask off anything but the first bit (ready or not) 
andi $t2, $t2, 1
#if its not ready, keep waiting
beqz $t2, wait
#now that it's ready, store the char in the transmitter data register
move $t2, %c
sw $t2, 0xffff000c($zero)
#leave
.end_macro

#prints an integer up to 3 digits to the MMIO display
.macro putInt(%i)
#if there's 3 digits, go to printTripleDigit
bgt %i, 99, printTripleDigit
#if there's 2 digits, go to printDoubleDigit
bgt %i, 9, printDoubleDigit
#otherwise go to printSingleDigit 
j printSingleDigit

printTripleDigit:

#i/100 = first digit
div $t0, %i, 100
#shift the value up by 48 so it aligns with its ascii value
addi $t0, $t0, 48
#print the first digit
putChar($t0)

#i%100 / 10 = middle digit
rem $t0, %i, 100
div $t0, $t0, 10
#shift the value again
addi $t0, $t0, 48
#print the middle digit
putChar($t0)

#i%10 = last digit
rem $t0, %i, 10
#shift the value
addi $t0, $t0, 48
#print the last digit
putChar($t0)

#skip to the exit
j exit


printDoubleDigit:
#i / 10 = first digit
div $t0, %i, 10
#shift the value
addi $t0, $t0, 48
#print the first digit
putChar($t0)

#i%10 = second digit
rem $t0, %i, 10
#shift the value
addi $t0, $t0, 48
#print the second digit
putChar($t0)

#skip to the exit
j exit


printSingleDigit:
#load the int to t0
move $t0, %i
#shift the digits up to represent its corresponding ascii value
addi $t0, $t0, 48
#print the digit
putChar($t0)

#time to leave
exit:
.end_macro 


#removes 1 tail, sets $s2 to the space it points to
.macro trimTail
#convert the tail's address into a pixel index
sub $t0, $s2, $s0
div $t0, $t0, 4
putPix(0x00000000)
#load the tail's current value
#every segment holds the direction of the next segment in the snake
lw $t0, 0($s2)
#translate registers to bytes
mul $t0, $t0, 4
#clear the value of the old tail
sw $zero, 0($s2)
#move s2 to the next segment over
add $s2, $s2, $t0
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
#put a placeholder value in the new head, so the data array still knows it's a body segment
li $t0, 1
sw $t0, 0($s1)
#get the distance in registers between the start of the grid and the new head location
sub $t0, $s1, $s0
#convert from registers to indexes in the screen array, and store that in t0 because putPix uses that register for the index
div $t0, $t0, 4
#draw the new head at that index
putPix(0x00ff00)
#exit
li $t0, 0
.end_macro

#places a fruit on a random empty space on the map
.macro spawnFruit
#picks a random space until its empty
loop:
#load a random integer
li $v0, 42
#set the upper bound to 512 exclusive (the pixels are from index 0 to 511)
li $a1, 512
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
#convert a0 back to an index, and store it in t0
div $t0, $a0, 4
#draw a fruit pixel at that index
putPix(0xff0000)
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

.macro Options(%int)
	move $t0, %int
	beq $t0, 'e', easySp
	beq $t0, 'n', normalSp
	beq $t0, 'h', hardSp
easySp:
	li $t7, 12
	putChar($t7)
	printInMMIO(easy)
	li speed, 225
easyloop:
	lui $t0, 0xffff
	lw $t1, 0($t0)
	andi $t1, $t1, 0x0001
	beq $t1, $zero, easyloop
	lw $a0, 4($t0)
	move optionSelect, $a0
	beq optionSelect, 'c', exit
	j easyloop
normalSp:
	li $t7, 12
	putChar($t7)
	printInMMIO(normal)
	li speed, 175
normalloop:
	lui $t0, 0xffff
	lw $t1, 0($t0)
	andi $t1, $t1, 0x0001
	beq $t1, $zero, normalloop
	lw $a0, 4($t0)
	move optionSelect, $a0
	beq $a0, 'c', exit
	j normalSp
hardSp:
	li $t7, 12
	putChar($t7)
	printInMMIO(hard)
	li speed, 75
hardloop:
	lui $t0, 0xffff
	lw $t1, 0($t0)
	andi $t1, $t1, 0x0001
	beq $t1, $zero, hardloop
	lw $a0, 4($t0)
	move optionSelect, $a0
	beq $a0, 'c', exit
	j hardSp
exit:
.end_macro
