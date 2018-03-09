//Created by Ali Kamran, Muzhou Zhai, Alejandro Garcia For CPSC 359

.section    .init
.globl     mainSNES,bigLoop
 
_start:
    b       mainSNES
 
.section .text
mainSNES:
		push    {lr}
		
//--------------Initializing the 3 lines(latch line/clock line/data line)
        mov     r0, #9
        mov     r1, #1             //LATCH TO OUTPUT
        bl      Init_GPIO
        mov     r0, #11
        mov     r1, #1             //CLOCK TO OUTPUT
        bl      Init_GPIO
        mov     r0, #10
        mov     r1, #0             //DATA TO INPUT
        bl      Init_GPIO
        
		pop     {lr}
		mov  pc, lr
//--------------The loop controls the program 
bigLoop:

		push    {lr}
		
        bl      Read_SNES
        bl      printList
        
		pop     {lr}
		mov  pc, lr
       

//--------------The loop that print strings declaring which button the user pressed
//--------------The user can press 2 more more buttons at a time
printList:
        push    {r4-r12, lr} 
        mov     r5, #0			//r5 is the loop counter, initialize r5 with 0 before enter the printLoop
        printLoop:
        cmp     r5, #16			//compare the counter with the buttons size 16
        bgt     donePrint		//if the counter exceeds (equal to) the size, the loop finished
        ldr     r0, =buttons		//load buttons(user's input) tp r0
        ldr     r11, =isButtonHeld	//load the isButtonHeld to r11, 
					//the memory isButtonHeld is for thecase if user press 2 or more buttons at one time
        mov     r8, r5, lsl #2 		//r3 is the index, r3 = r5 * 4
        ldrb    r1, [r0, r8]		// load 0 to r1 from the certain address	
        cmp     r1, #0			//if r1 = 0, branch goto notPressed
        beq     notPressed		

        ldrb    r12, [r11, r8]		//load r12 from the index of r11		
        cmp     r12, #1			//if r12 = 1, the button is held, branch goto continue
        beq     continue
        mov     r12, #1			//if not, move 1 to r12
        strb    r12, [r11, r8]		//stroe the value back
        
        ldr		r0, =currentScreen
        ldrb	r0, [r0]
        cmp		r0, #0
        beq		mainmenucontrols
        cmp		r0, #1
        beq		ingamecontrols
        cmp		r0, #2
        beq		pausemenucontrols
        cmp		r0, #3
        beq		winlosemenucontrols
        
        mainmenucontrols:
		cmp     r5, #3 			//if user pressed start button, draw game menu
	//	bleq     startButton		
		cmp     r5, #8			//press "A", draw the mainMenu 
		bleq 	menuSelect
		cmp     r5, #4			//joypad up
		bleq     menuUp
		cmp     r5, #5                  //joy pad down
		bleq     menuDown
        b		contcontrols

        ingamecontrols:
        cmp		r5, #3
        bleq	gameMenu
        cmp     r5, #6 			
        bleq     moveleft		
        cmp     r5, #7
        bleq     moveright
        cmp     r5, #4			
        bleq    rotateleft		
        cmp     r5, #5
        bleq    rotateright		
        b		contcontrols
        
        pausemenucontrols:
		cmp     r5, #8			//press "A", draw the mainMenu 
		beq	    gamemenuSelect
        cmp		r5, #3
        beq		GameLoop
		cmp     r5, #4			//joypad up
		bleq    gameMenuUp
		cmp     r5, #5                  //joy pad down
		bleq    gameMenuDown
		
        winlosemenucontrols:
        cmp		r5, #3
        bleq	gameMenu
        
        contcontrols:
        b       continue		//branch goto continue
 
        notPressed:			//if the button is not held, the user pressed one button at a time
        mov     r12, #0			//let r12 = 0
        strb    r12, [r11, r8]		//store the value back to r11(isButtonHeld)
        b       continue		//branch goto continue	

        continue:
        add     r5, #1			//r5(loop counter)+=1
        b       printLoop
 
        donePrint:     
        pop   {r4-r12, lr} 
		mov   pc, lr
		
Read_SNES:
        push    {r4,r5,r6, lr} 
        
        mov     r1, #1			//write GPIO (Write 1 to the clock)
        bl      Write_Clock
     
        mov     r1, #1
        bl      Write_Latch		//write GPIO (write 1 to the latch)
     
        mov     r1, #12			//the program has to wait for 12 us, that is the time signal from SENS to sample button
        bl      Wait
     
        mov     r1, #0			//write GPIO (write 0 to the latch)
        bl      Write_Latch
     
        mov     r5, #0			//r5 is the counter for the pulseLoop, so we set r5 to 0 each time before enter the loop

//--------------Start pulsing to read from SNES
pulseLoop:
        cmp     r5, #16                 //compare it with 16 (we have 16 buttons store in the data list)
        bge     donePulse		// if it is bigger or equal to 16, the loop done (branch go to donePulse) 
         
        mov     r1, #6			//the program has to wait for 6 us, that is the time for the half period of the CLOCK
        bl      Wait
     
        mov     r1, #0			//write GPIO (Write 0 to the clock)
        bl      Write_Clock
     
        mov     r1, #6			//the program has to wait for 6 us, that is the time for the half period of the CLOCK
        bl      Wait
         
        bl      Read_Data		//branch goto Read_Data

//------------- Read GPIO(data, buttons)
dataRead:     
        ldr     r0, =buttons		//buttons is a initialized memory stores the buttons value (16 linked with the buttons on SENS)
        mov     r6, r5, lsl #2		//r6=r5*4, 4 stands for 4 bytes for each integer, r5 is the counter 
        strb    r1, [r0, r6]		//store the input signal(number) 
     
        mov     r1, #1			//write GPIO (write 1 to the latch)
        bl      Write_Clock
     
        add     r5, #1			//r5+=1 after each loop

     
        b       pulseLoop		//branch goto pluseLoop

//-------------finish the pulseLoop    
donePulse:     
        pop   {r4,r5,r6, lr} 
        bx    lr
 
//-------------function that read from the GPIO data line (pin #10)
Read_Data: 
        ldr     r2, =0x3F200000		//base GPIO reg
        ldr     r1, [r2, #52]		//GPLEV0
        mov     r3, #1			//r3 = 1
        lsl     r3, #10			//align pin 10 bit
        and     r1, r3			//mask everything else
        cmp     r1, #0			//compare if r1 = 0
        moveq   r1, #1			//if equal, return 1 to r4
        movne   r1, #0			// if not equal, retuen 0 to r4
        bx      lr
//--------------function to initialize the GPIO lines     
//r0 contains the lineNumber
//r1 contains the function code
Init_GPIO:
        push {r4} 
        mov     r2, r0  		//move pin# to r2
        ldr     r0, =0x3F200000 	//load r0 with base register
        //--------------find the address accrording to the pin
        loopReg:
                cmp     r2, #9		//compare the pin with 9
                subhi   r2, #10		//if r2 is smaller, substract 10 from r2
                addhi   r0, #4		//if r2 is greater, add 4 to the address
                bhi     loopReg		
 
        donereg:
        ldr     r4, [r0]		//copy GPFSEL into r4
        mov     r3, #7			//r3 = 111
        add     r2, r2, lsl #1		//r2 = r2 + r2 * 2, now r2 is the index number of 1st bit for the pin
        lsl     r3, r2			//align r3 for r2 bits 
        bic     r4, r3			//do the bit clear in r4 (in 3 bits)
        lsl     r1, r2			//align r1 for r2 bits
        orr     r4, r1			//set the pin's function in r1	
        str     r4, [r0]		//write back to GPFSEL
        pop     {r4} 
        bx      lr
 
 
//--------------writing pin number 11
Write_Clock:
        ldr     r2, =0x3F200000		//load r2 with base register
        mov     r3, #1			//r3 = 1
        lsl     r3, #11			//align bit for pin#11
        cmp     r1, #0			//compare r1 with 0
        streq   r3, [r2, #40] 		//GPCLR0: write 0 to the clock
        strne   r3, [r2, #28] 		//GPCLR0: write 0 to the clock
        bx      lr
 
//--------------writting pin number 9
Write_Latch:    
        ldr     r2, =0x3F200000		//load r2 with base register
        mov     r3, #1			//r3 = 1
        lsl     r3, #9			//align bit for pin#9
        cmp     r1, #0			//compare r1 with 0
        streq   r3, [r2, #40] 		//GPCLR0: write 0 to the latch
        strne   r3, [r2, #28] 		//GPCLR0: write 0 to the latch
        bx      lr
 
 
 
//---------------This function is for setting a delay time
//Takes in amount of time to wait in r1
Wait:
        ldr      r0, =0x3F003004	//load the address for CLO
        ldr      r2, [r0]		//read CLO	
        ldr      r3, [r0]        	//r3 is current clock
        add      r2, r1         	//r2 is the upper clock  
     	//-------This loop is to make sure the current time is at least equal to the delay time we set
        loopWait:
        cmp      r3, r2			//if the current clock is smaller than the upper clock
        ldr      r3, [r0]		//branch goto the loopWait again
        blt      loopWait		
        bx       lr
 
exitProgram:
        b       haltLoop$		//exit the program

//-------end of the program
haltLoop$:
        b       haltLoop$
     
.section .data // data goes in the data section
.align // align to word boundaries
//-------The list for every output string according to the buttons order in the data line 
MsgList:
        .ascii  "You have pressed B...\n\r",
        .ascii  "You have pressed Y...\n\r",
        .ascii  "You have pressed the select button...\n\r",
        .ascii  "You have pressed the start button...\n\r",
        .ascii  "You have pressed joy-pad UP...\n\r",
        .ascii  "You have pressed joy-pad DOWN...\n\r",
        .ascii  "You have pressed joy-pad LEFT...\n\r",
        .ascii  "You have pressed joy-pad RIGHT...\n\r",
        .ascii  "You have pressed A...\n\r",
        .ascii  "You have pressed X...\n\r",
        .ascii  "You have pressed L...\n\r",
        .ascii  "You have pressed R...\n\r",
        .ascii  "Created by Ali Kamran, Muzhou Zhai, Alejandro Garcia\n\r",
        .ascii  "\n\n\rPlease press a button...\n\r",
        .ascii  "The program will now terminate...\n\n\r"
                 
                                
//-------the list of each string's length 
MsgSizes:
        .byte 23, 23, 39, 38, 32, 34, 34, 35, 23, 23, 23, 23, 54, 29, 36

currentgamestate: .byte
     
//-------a memory to store the 16 button's value     
buttons:  
        .int    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

ABuff:
    .rept    256   			 // use repeat (.rept / .endr)
    .byte 0				 // to define large areas of
    .endr				 // repeated data
 
isButtonHeld:
	.int 	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0



    

