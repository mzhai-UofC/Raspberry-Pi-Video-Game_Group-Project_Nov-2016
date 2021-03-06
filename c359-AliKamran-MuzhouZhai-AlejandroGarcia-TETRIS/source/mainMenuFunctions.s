//Created by Ali Kamran, Muzhou Zhai, Alejandro Garcia For CPSC 359
//testing changes made to the git repo

.section    .init
.globl     drawmainMenu, menuUp, menuDown, gameInter, quitGame, menuSelect
 
 
.section .text
//------------------------function that draws the main menu
drawmainMenu:
	 push    {r4,r10,r11,lr}
	 mov		r11, #0	
//---------------------------draw the menu	

	 mov	r10, #0
	 ldr	r0, =mainMenuImage
		
	 mov	r4, #576//Width of  image
	 mov	r3, #576//height of image
	 mov	r2, #200
	 mov	r1, #200
	 bl	DrawMenu

//--------------------------draw the selector
	ldr		r0, =t1
	mov		r2, #500
	mov		r1, #250
	mov		r4, #96//Width of  image
	mov		r3, #96//height of image
	bl		DrawMenu
	ldr		r0, =currentSelection
	mov		r1, #0
	strb	r1, [r0]
	
	pop   	{r4,r10,r11,lr}
	mov   	pc, lr
//-----------------------the selector move up        
menuUp:	
		push    {r4,r5,r9,r10,lr}
		
		mov		r2, #620
		mov		r1, #250
		bl		ClearMenuImage
		ldr		r0, =t1
		mov		r2, #500
		mov		r1, #250
		
		mov		r4, #96//Width of  image
		mov		r3, #96//height of image
		bl		DrawMenu
		mov     r5, r9
		
		ldr		r10, =currentSelection
		ldrb	r9, [r10]
		cmp		r9, #1
		moveq	r9, #0
		strb	r9, [r10]
		
		pop     {r4,r5,r9,r10,lr}
		mov   	pc, lr

//------------------------------The selector move down
menuDown:
		push     {r4,r5,r7,r9,r10,lr}
		
		mov		r2, #500
		mov		r1, #250
		bl		ClearMenuImage
		
		ldr		r0, =t1
		mov		r2, #620
		mov		r1, #250
		
		mov		r4, #96//Width of  image
		mov		r3, #96//height of image
		bl		DrawMenu
		mov     r5, r9
		mov     r7,  r2
		
		ldr		r10, =currentSelection
		ldrb	r9, [r10]
		cmp		r9, #0
		moveq	r9, #1
		strb	r9, [r10]
		
		pop     {r4,r5,r7,r9,r10,lr}
		mov   	pc, lr	
	
//----------------------check what the user has selected (start or quit) 
menuSelect:
    push	{r9,r10,lr}    
    bl		ClearScreen    
	ldr		r10, =currentSelection
	ldrb	r9, [r10]
		
	
    cmp		r9, #0
    beq		newgame
    b		quitGame
    pop		{r9,r10,lr}  
    bx lr
//-----------------------if the user select quit 
quitGame:
	mov		r11, #0
	bl		ClearScreen
	haltLoop$:
		b       haltLoop$
     
.section .data // data goes in the data section
.align // align to word boundaries

currentSelection: .byte 0
