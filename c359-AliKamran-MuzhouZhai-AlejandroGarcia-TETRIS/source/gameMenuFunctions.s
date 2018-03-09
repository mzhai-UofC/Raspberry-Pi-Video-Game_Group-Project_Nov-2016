//Created by Ali Kamran, Muzhou Zhai, Alejandro Garcia For CPSC 359
//testing changes made to the git repo

.section    .init
.globl     gameMenu, gameMenuQuit, gameMenuUp,gameMenuDown, gamemenuSelect
 
 
.section .text
//--------------------checking the screen status, decide which game menu to print
gameMenu:	
		push    {r4,lr}

		ldr		r0, =currentScreen
		mov		r1, #2
		strb	r1, [r0]
			
		bl		ClearScreen
		
		ldr		r0, =gamecondition
		ldrb	r1, [r0]
		cmp		r1, #0
		beq		Nocondition
		cmp		r1, #1
		beq		loseConditionDraw
		cmp		r1, #2
		beq		winConditionDraw
		b		Nocondition
//-------------------if the game lost		
loseConditionDraw:
	 	ldr		r0, =lostMenu
		b		contdrawingpause
//-------------------if the game win
winConditionDraw:	
	 	ldr		r0, =winMenu
		b		contdrawingpause
//------------------the user press start before a game win or lost		
Nocondition:
		ldr		r0, =GameMenu
//---------------------the game status pause and draw the game menu
contdrawingpause:
		mov		r2, #200
		mov		r1, #200
		mov		r4, #576//Width of  image
		mov		r3, #576//height of image
		bl		DrawMenu

		mov		r2, #500
		mov		r1, #250
		bl		ClearMenuImage
		
		ldr		r0, =t1
		mov		r2, #500
		mov		r1, #250
		
		mov		r4, #96//Width of  image
		mov		r3, #96//height of image
		bl		DrawMenu
		
		ldr		r0, =currentSelection
		mov		r1, #0
		strb	r1, [r0]

		pop     {r4,lr}
		mov   	pc, lr
		
//-----------------------the selector move up
gameMenuUp:	
		push     {r4,r9,r10,lr}
		
		mov		r2, #620
		mov		r1, #250
		bl		ClearMenuImage
		
		ldr		r0, =t1
		mov		r2, #500
		mov		r1, #250
		mov		r4, #96//Width of  image
		mov		r3, #96//height of image
		bl		DrawMenu
		
		ldr		r10, =currentSelection
		ldrb	r9, [r10]
		cmp		r9, #1
		moveq	r9, #0
		strb	r9, [r10]	
		pop     {r4,r9,r10,lr}
		mov   	pc, lr
        	
 

//--------------------------------------The selector moves down
gameMenuDown:
		push    {r4,r9,r10,lr}
		mov		r2, #500
		mov		r1, #250
		bl		ClearMenuImage
		
		ldr		r0, =t1
		mov		r2, #620
		mov		r1, #250
		mov		r4, #96//Width of  image
		mov		r3, #96//height of image
		bl		DrawMenu

		
		ldr		r10, =currentSelection
		ldrb	r9, [r10]
		cmp		r9, #0
		moveq	r9, #1
		strb	r9, [r10]		

		pop     {r4,r9,r10,lr}
		mov   	pc, lr	
//-----------------------------------check which selection the user chose (restart or quit)
gamemenuSelect:
		ldr		r0, =currentSelection
		ldrb	r1, [r0]
		cmp		r1, #0
		beq		newgame
		b		mainmenu
		
haltLoop$:
        b       haltLoop$

     
.section .data // data goes in the data section
.align // align to word boundaries

currentSelection: .byte 0
