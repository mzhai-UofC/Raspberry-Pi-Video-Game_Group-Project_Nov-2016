//Created by Ali Kamran, Muzhou Zhai, Alejandro Garcia For CPSC 359
//testing changes made to the git repo

.section    .init
.globl    ClearMenuImage, DrawMenu, divide, WaitInterval, GetHeight, maxGameStateArray, CheckPlacementSpace, DrawGameState, DrawPixel, ClearScreen, DrawImage, ClearImage, DrawTetramino, SavedGameStateArray, GameStateArray, NewGameStateArray, ClearBlock, DrawBlock
 
 
.section .text
//----------------------the function that clear menu
ClearMenuImage:
	push 	{r4-r10, lr}
	mov		r4, #96//width of section to clear
	mov		r5, #96//height of section to clear
	mov		r9, r1
	mov		r10, r2
	mov		r6, #0
	mov		r7, #0
	mov		r8, r0
	imageLoc	.req	r8
	maxWidth	.req 	r4
	maxHeight	.req	r5
	currRow		.req	r6
	currCol  	.req	r7
	xoffset		.req	r9
	yoffset		.req	r10
	
	rowClearImgmenu:
		cmp		currRow, maxHeight
		bge		doneDrawClearmenu
		colLoopImgClearmnu:
			cmp		currCol, maxWidth
			bge		doneRowImgClearmenu
			mov		r2, #0
			add		r0, currCol, xoffset
			add		r1, currRow, yoffset
			bl 		DrawPixel
			add		currCol, #1
			b		colLoopImgClearmnu
	doneRowImgClearmenu:
		add		currRow, #1
		mov		currCol, #0
		b		rowClearImgmenu
doneDrawClearmenu:
	pop		{r4-r10, lr}
	bx		lr

//---------------------the function that clears whole screen
ClearScreen:
	push	{r4-r7, lr}
	mov		r4, #1024
	mov		r5, #768  
	mov		r6, #0    
	mov		r7, #0	 
	
	maxWidth	.req 	r4
	maxHeight	.req	r5
	currRow		.req	r6
	currCol  	.req	r7
	rowLoop:
		cmp		currRow, maxHeight
		bge		doneClear
		colLoop:
			cmp		currCol, maxWidth
			bge		doneRow
			mov		r0, currCol
			mov		r1, currRow
			mov		r2, #0x0
			bl 		DrawPixel
			add		currCol, #1
			b		colLoop
	doneRow:
		add		currRow, #1
		mov		currCol, #0
		b		rowLoop
	doneClear:
	pop		{r4-r7, lr}
	bx		lr

/*
*	r0: mem of image
*	r1: X to draw
*	r2: Y to drew
*/
//----------------------function draws the menus
DrawMenu:
	push 	{r4-r11, lr}
	mov		r9, r1
	mov		r10, r2
	mov		r6, #0
	mov		r7, #0
	mov		r8, r0
	mov		r5,	r3
	
	imageLoc	.req	r8
	maxWidth	.req 	r4
	maxHeight	.req	r5
	currRow		.req	r6
	currCol  	.req	r7
	xoffset		.req	r9
	yoffset		.req	r10
	
	rowLoopMenu:
		cmp		currRow, maxHeight
		bge		doneDrawmenu
		colLoopMenu:
			cmp		currCol, maxWidth
			bge		doneRowImgmenu
			mul		r11, maxHeight, currRow
			add		r11, currCol
			mov		r2, #2
			mul		r11, r2
			ldrh	r2, [imageLoc, r11]
			add		r0, currCol, xoffset
			add		r1, currRow, yoffset
			bl 		DrawPixel
			add		currCol, #1
			b		colLoopMenu
	doneRowImgmenu:
		add		currRow, #1
		mov		currCol, #0
		b		rowLoopMenu
		
doneDrawmenu:
	pop		{r4-r11, lr}
	bx		lr

/*
*	r0: mem of image
*	r1: X to draw
*	r2: Y to drew
*/
//---------------function draw the images 
DrawImage:
	push 	{r4-r11, lr}
	mov		r4, #32//Width of  image
	mov		r5, #32//height of image
	mov		r9, r1
	mov		r10, r2
	mov		r6, #0
	mov		r7, #0
	mov		r8, r0
	imageLoc	.req	r8
	maxWidth	.req 	r4
	maxHeight	.req	r5
	currRow		.req	r6
	currCol  	.req	r7
	xoffset		.req	r9
	yoffset		.req	r10
	rowLoopImg:
		cmp		currRow, maxHeight
		bge		doneDraw
		colLoopImg:
			cmp		currCol, maxWidth
			bge		doneRowImg
			mul		r11, maxHeight, currRow
			add		r11, currCol
			mov		r2, #2
			mul		r11, r2
						
			ldrh	r2, [imageLoc, r11]
			add		r0, currCol, xoffset
			add		r1, currRow, yoffset

			bl 		DrawPixel
			
			add		currCol, #1
			b		colLoopImg
	doneRowImg:
		add		currRow, #1
		mov		currCol, #0
		b		rowLoopImg
		
doneDraw:
	pop		{r4-r11, lr}
	bx		lr

//r0 int color 
//returns in r0 address of colorcoded block
GetIntColorBlock:
	cmp r0, #0
	beq retblackblock
	cmp r0, #1
	beq retblueblock
	cmp r0, #2
	beq retcyanblock
	cmp r0, #3
	beq retgreenblock
	cmp r0, #4
	beq retorangeblock
	cmp r0, #5
	beq retpurpleblock
	cmp r0, #6
	beq	retredblock
	cmp r0, #7
	beq retyellowBlock
	cmp r0, #8
	beq retgreyBlock
	cmp r0, #9
	beq retpowerBlock
retblueblock:
	ldr	r0, =BlueBlock
	bx	lr
retcyanblock:
	ldr	r0, =CyanBlock
	bx	lr
retgreenblock:
	ldr	r0, =GreenBlock
	bx	lr
retorangeblock:
	ldr	r0, =OrangeBlock
	bx	lr
retpurpleblock:
	ldr	r0, =PurpleBlock
	bx	lr
retredblock:
	ldr	r0, =RedBlock
	bx	lr
retyellowBlock:
	ldr	r0, =YellowBlock
	bx	lr
retgreyBlock:
	ldr	r0, =GreyBlock
	bx	lr
retpowerBlock:
	ldr	r0, =PowerBlock
	bx	lr
retblackblock:
	ldr	r0, =BlackBlock
	bx	lr


//r0: color int 1-7
//r1: x in gamestate coord
//r2: y in gamestate coord
ClearBlock:
	push	{r5,r6, lr}
	ldr		r6, =GameStateArray
	mov		r5, #12
	mul		r3, r2, r5
	add     r3, r1	
	mov		r0, #0
	strb	r0, [r6, r3]
	ldr		r0, =BlackBlock
	lsl		r1, #5
	lsl		r2, #5
	bl		DrawImage
	pop		{r5,r6,lr}
	bx		lr
	
//r0: color int 1-7
//r1: x in gamestate coord
//r2: y in gamestate coord
DrawBlock:
	push	{r5,r6, lr}
	ldr		r6, =GameStateArray
	mov		r5, #12
	mul		r3, r2, r5
	add     r3, r1
	strb	r0, [r6, r3]
	bl 		GetIntColorBlock
	lsl		r1, #5
	lsl		r2, #5
	bl		DrawImage
	pop		{r5,r6, lr}
	bx		lr
	
//r0: Array of tet to draw  //32pixel width max of 320 pixels in width
//r1: x in gamestate coordinates
//r2: y in gamestate coordinates
//r3: clear or draw. If r3 is 1 then clear.
DrawTetramino:
	push	{r4-r9, lr}
	TetArray 		.req r4
	GameStateX		.req r5
	GameStateY		.req r6
	TetArrayIndex 	.req r7
	TetColorInt		.req r8
	Clear			.req r9 
	mov		TetArray, r0
	mov		GameStateX, r1
	mov		GameStateY, r2
	mov		TetArrayIndex, #0
	mov		TetColorInt, #0
	mov		Clear,	r3
	
DrawTetLoop:
	cmp 	TetArrayIndex, #16 //index for tetArray
	bge		doneDrawTetramino
	ldrb	r0, [TetArray, TetArrayIndex]
	cmp 	r0, #0
	beq 	noBlockHere
	//the current index in tetarray is >0
	//check if cell is taken here
	mov		r0, TetArrayIndex
	mov		r1, #4
	bl		divide
	mov		r2, r0
	ldrb	r0, [TetArray, TetArrayIndex]
	add		r1, GameStateX
	add		r2, GameStateY
	breakhere:
	cmp		Clear, #1
	blne	DrawBlock
	bleq	ClearBlock
noBlockHere:
	add TetArrayIndex, #1
	b	DrawTetLoop
doneDrawTetramino:
	pop		{r4-r9, lr}
	bx		lr



//r0: Array of tet to draw  //32pixel width max of 320 pixels in width
//r1: x in gamestate coordinates where tet is being placed
//r2: y in gamestate coordinates
CheckPlacementSpace:
	push	{r4-r11, lr}
	
	TetArray 		.req r4
	GameStateCol	.req r5
	GameStateRow	.req r6
	TetArrayIndex 	.req r7
	TetColorInt		.req r8
	GameArray  		.req r9
	TetArrayCol		.req r10
	TetArrayRow		.req r11

	mov		TetArray, r0
	mov		GameStateCol, r1
	mov		GameStateRow, r2
	mov		TetArrayIndex, #0
	mov		TetColorInt, #0
	mov		TetArrayCol, #0
	mov		TetArrayRow, #0
	ldr		GameArray, =SavedGameStateArray
CheckPlaceLoop:
	cmp 	TetArrayIndex, #16 //index for tetArray
	bge		DonePlaceLoop
	ldrb	r0, [TetArray, TetArrayIndex]
	cmp 	r0, #0
	beq 	ContinuePlaceCheck
	mov		r0, TetArrayIndex
	add		r1, GameStateRow, TetArrayRow
	add		r2, GameStateCol, TetArrayCol
	mov		r0, #12
	mul		r3, r1, r0
	add     r3, r2		
	ldrb	r0, [GameArray, r3]
	cmp		r0, #9
	bleq	Addpowerup
	beq		ignorePowerupcollision
	cmp		r0, #0
	beq		ContinuePlaceCheck
	b		DonePlaceLoop
ignorePowerupcollision:	

ContinuePlaceCheck:
	cmp	    TetArrayCol, #3
	addeq	TetArrayRow, #1
	moveq	TetArrayCol, #0
	addne	TetArrayCol, #1
	add     TetArrayIndex, #1
	b	CheckPlaceLoop
DonePlaceLoop:
	pop		{r4-r11, lr}
	bx		lr	
	
Addpowerup:
	push	{r4,r5, lr}
	ldr		r4, =powerup
	mov		r5, #1
	strb	r5, [r4]
	mov		r0, #9
	mov		r1, #13
	mov		r2, #2
	bl		DrawBlock
	pop		{r4,r5, lr}
	bx		lr	

/*
*	
*	r1: X to draw
*	r2: Y to drew
*/
ClearImage:
	push 	{r4-r10, lr}
	mov		r4, #16//width of section to clear
	mov		r5, #16//height of section to clear
	mov		r9, r1
	mov		r10, r2
	mov		r6, #0
	mov		r7, #0
	mov		r8, r0
	
	imageLoc	.req	r8
	maxWidth	.req 	r4
	maxHeight	.req	r5
	currRow		.req	r6
	currCol  	.req	r7
	xoffset		.req	r9
	yoffset		.req	r10
	rowClearImg:
		cmp		currRow, maxHeight
		bge		doneDrawClear
		colLoopImgClear:
			cmp		currCol, maxWidth
			bge		doneRowImgClear
			mov		r2, #0
			add		r0, currCol, xoffset
			add		r1, currRow, yoffset
			bl 		DrawPixel
			add		currCol, #1
			b		colLoopImgClear
	doneRowImgClear:
		add		currRow, #1
		mov		currCol, #0
		b		rowClearImg
doneDrawClear:
	pop		{r4-r10, lr}
	bx		lr



DrawGameState:
	push 	{r4-r10, lr}
	xoffset		.req	r5
	yoffset		.req	r6
	gamestatex	.req	r7
	gamestatey	.req	r8
	mov		r5, r0
	mov		r6, r1
	mov		r4,	 #0
	mov		gamestatex,	 #0
	mov		gamestatey,	 #0
	ldr		r10, =maxGameStateArray
	ldr		r10, [r10]
drawgamestateloop:
	cmp		r4, r10
	beq		doneDrawGameState
	ldr		r9, =GameStateArray
	ldrb	r9, [r9, r4]
	mov		r0, r9
	mov		r1, gamestatex
	mov		r2, gamestatey
	bl		DrawBlock	
	add		r4, #1
	cmp		gamestatex, #11
	addle   gamestatex, #1
	moveq	gamestatex, #0
	addeq	gamestatey, #1	
	b		drawgamestateloop
	
doneDrawGameState:	
	pop		{r4-r10, lr}
	bx		lr

/* Draw Pixel
 *  r0 - x
 *  r1 - y
 *  r2 - color
 */

DrawPixel:
	push	{r4}
	offset	.req	r4
	// offset = (y * 1024) + x = x + (y << 10)
	add		offset,	r0, r1, lsl #10
	// offset *= 2 (for 16 bits per pixel = 2 bytes per pixel)
	lsl		offset, #1
	// store the colour (half word) at framebuffer pointer + offset
	ldr	r0, =FrameBufferPointer
	ldr	r0, [r0]
	strh	r2, [r0, offset]
	pop		{r4}
	bx		lr
	
/* Function that will take in perform N = D × Q + R 
	r1 contains D and r0 contains N
	returns Q in r0 and R in r1 */
divide:
    mov r2, r1         
    mov r1, r0             
    mov r0, #0            
    b Lloop_check
    Lloop:
       add r0, r0, #1      
       sub r1, r1, r2      
    Lloop_check:
       cmp r1, r2     
       bhs Lloop            
    bx lr

.section .data // data goes in the data section
.align // align to word boundaries

maxGameStateArray: 
.int 264

WaitInterval: 
.int 160000

SavedGameStateArray:
.byte 8,0,0,0,0,0,0,0,0,0,0,8
.byte 8,0,0,0,0,0,0,0,0,0,0,8
.byte 8,0,0,0,0,0,0,0,0,0,0,8
.byte 8,0,0,0,0,0,0,0,0,0,0,8
.byte 8,0,0,0,0,0,0,0,0,0,0,8
.byte 8,0,0,0,0,0,0,0,0,0,0,8
.byte 8,0,0,0,0,0,0,0,0,0,0,8
.byte 8,0,0,0,0,0,0,0,0,0,0,8
.byte 8,0,0,0,0,0,0,0,0,0,0,8
.byte 8,0,0,0,0,0,0,0,0,0,0,8
.byte 8,0,0,0,0,0,0,0,0,0,0,8
.byte 8,0,0,0,0,0,0,0,0,0,0,8
.byte 8,0,0,0,0,0,0,0,0,0,0,8
.byte 8,0,0,0,0,0,0,0,0,0,0,8
.byte 8,0,0,0,0,0,0,0,0,0,0,8
.byte 8,0,0,0,0,0,0,0,0,0,0,8
.byte 8,0,0,0,0,0,0,0,0,0,0,8
.byte 8,0,0,0,0,0,0,0,0,0,0,8
.byte 8,0,0,0,0,0,0,0,0,0,0,8
.byte 8,0,0,0,0,0,0,0,0,0,0,8
.byte 8,0,0,0,0,0,0,0,0,0,0,8
.byte 8,8,8,8,8,8,8,8,8,8,8,8


NewGameStateArray:
.byte 8,0,0,0,0,0,0,0,0,0,0,8
.byte 8,0,0,0,0,0,0,0,0,0,0,8
.byte 8,0,0,0,0,0,0,0,0,0,0,8
.byte 8,0,0,0,0,0,0,0,0,0,0,8
.byte 8,0,0,0,0,0,0,0,0,0,0,8
.byte 8,0,0,0,0,0,0,0,0,0,0,8
.byte 8,0,0,0,0,0,0,0,0,0,0,8
.byte 8,0,0,0,0,0,0,0,0,0,0,8
.byte 8,0,0,0,0,0,0,0,0,0,0,8
.byte 8,0,0,0,0,0,0,0,0,0,0,8
.byte 8,0,0,0,0,0,0,0,0,0,0,8
.byte 8,0,0,0,0,0,0,0,0,0,0,8
.byte 8,0,0,0,0,0,0,0,0,0,0,8
.byte 8,0,0,0,0,0,0,0,0,0,0,8
.byte 8,0,0,0,0,0,0,0,0,0,0,8
.byte 8,0,0,0,0,0,0,0,0,0,0,8
.byte 8,0,0,0,0,0,0,0,0,0,0,8
.byte 8,0,0,0,0,0,0,0,0,0,0,8
.byte 8,0,0,0,0,0,0,0,0,0,0,8
.byte 8,0,0,0,0,0,0,0,0,0,0,8
.byte 8,0,0,0,0,0,0,0,0,0,0,8
.byte 8,8,8,8,8,8,8,8,8,8,8,8

GameStateArray: 
.byte 8,0,0,0,0,0,0,0,0,0,0,8
.byte 8,0,0,0,0,0,0,0,0,0,0,8
.byte 8,0,0,0,0,0,0,0,0,0,0,8
.byte 8,0,0,0,0,0,0,0,0,0,0,8
.byte 8,0,0,0,0,0,0,0,0,0,0,8
.byte 8,0,0,0,0,0,0,0,0,0,0,8
.byte 8,0,0,0,0,0,0,0,0,0,0,8
.byte 8,0,0,0,0,0,0,0,0,0,0,8
.byte 8,0,0,0,0,0,0,0,0,0,0,8
.byte 8,0,0,0,0,0,0,0,0,0,0,8
.byte 8,0,0,0,0,0,0,0,0,0,0,8
.byte 8,0,0,0,0,0,0,0,0,0,0,8
.byte 8,0,0,0,0,0,0,0,0,0,0,8
.byte 8,0,0,0,0,0,0,0,0,0,0,8
.byte 8,0,0,0,0,0,0,0,0,0,0,8
.byte 8,0,0,0,0,0,0,0,0,0,0,8
.byte 8,0,0,0,0,0,0,0,0,0,0,8
.byte 8,0,0,0,0,0,0,0,0,0,0,8
.byte 8,0,0,0,0,0,0,0,0,0,0,8
.byte 8,0,0,0,0,0,0,0,0,0,0,8
.byte 8,0,0,0,0,0,0,0,0,0,0,8
.byte 8,8,8,8,8,8,8,8,8,8,8,8


