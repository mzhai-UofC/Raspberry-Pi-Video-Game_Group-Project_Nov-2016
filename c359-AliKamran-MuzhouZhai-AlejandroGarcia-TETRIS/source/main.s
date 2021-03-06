//Created by Ali Kamran, Muzhou Zhai, Alejandro Garcia For CPSC 359
//testing changes made to the git repo

.section    .init
.globl     _start, powerup,moveleft, moveright, rotateleft, rotateright, currentScreen, GameLoop, newgame, mainmenu, gamecondition
 
_start:
    b       main
 
.section .text
main:
      mov     sp, #0x8000 // Initializing the stack pointer
      bl      EnableJTAG // Enable JTAG
      bl      InitUART    // Initialize the UART
		bl		InitFrameBuffer
		bl 		mainSNES     //Initializing SENS connect to the main menu
		b		mainmenu        //goto main menu
//------------draw the main menu		
mainmenu:
		bl		ClearScreen     //clear the whole screen
		bl		drawmainMenu	 //print the main menu	
		ldr		r0, =currentScreen    // load the picture
		mov		r1, #0
		strb	r1, [r0]
//------------count the screen status
MainMenuLoop:       
		bl		bigLoop
		ldr		r0,	=currentScreen  //currentScreen is the current status
		ldrb	r0,[r0]
		cmp		r0, #0					// if the value in currentScreen is 0, goto MainMenuLoop 
		beq		MainMenuLoop
		b		newgame						//else goto a new game
endGame:
	bl		ClearScreen						//if the game is over, clear the whole screen
haltLoop$:
	b		main
    b       haltLoop$					//loop halts
//-----------------begin a new game    
newgame:
	push	{r4}
    bl      generateRandomVariables		//random generator generates the arbitrary blocks
	ldr		r0, =GameStateArray        // load GameStateArray in r0
	ldr		r1, =NewGameStateArray		// load newStateArray in r1
	ldr		r2, =maxGameStateArray		// load maxStateArray in r0
	ldr 	r2, [r2]								
	mov		r3, #0							// loop counter
//----------------to check the game status
newgameloop:	
	cmp		r3, r2							//if r3 = r2, game done
	beq		doneNewGame
	ldrb	r4, [r1,r3]
	strb	r4, [r0,r3]
	add		r3, #1								// r3 += 1
	b		newgameloop
//------------------save the game status
doneNewGame:										
	bl		SaveGameState
	ldr		r0, =Score							// load score 
	mov		r1, #0
	str		r1, [r0]
	ldr		r0, =ActiveTet						//activating the blocks function
	strb	r1, [r0]
	ldr		r0, =CurrentRotation				//activating the rotation function
	strb	r1, [r0]
	ldr		r0, =CurrentTetX					//activating the currentTex function
	strb	r1, [r0]
	ldr		r0, =CurrentTetXORG				//activating the CurrentTetXORG function
	strb	r1, [r0]
	ldr		r0, =CurrentTetY					//activating the CurrentTetY function				
	strb	r1, [r0]
	ldr		r0, =gamecondition				//activating the gamecondition function
	strb	r1, [r0]
	ldr		r0, =powerup						//activating the power up function
	strb	r1, [r0]
	pop		{r4}
	b		GameLoop
//--------------------pause if the user press start
pause:
	push	{lr}
	pauseloop:
	bl		bigLoop
	ldr		r0, =currentScreen				//load the current screen status
	ldrb	r0, [r0]
	cmp		r0, #2								//if the user press start button
	beq		pauseloop							//pause
	cmp		r0, #0
	beq		main
	b		pauseloop
	bl		DrawGameState							//if the user press start button again, reload the status before 
	pop		{lr}
	bx		lr

losehandler:
	ldr		r0, =gamecondition				//load the game condition
	mov		r1, #1
	strb	r1, [r0]
	bl		gameMenu									//goto game menu after the game over
	b		pause
//-----------------This is a function to check the game status and control the game
GameLoop:
	push	{lr}
	bl		ClearScreen	
	ldr		r0, =currentScreen
	mov		r1, #1
	strb	r1, [r0]
	bl		DrawGameState
	gameloopinside:
	bl		CheckWinCondition
	bl		CheckEndCondition
	
	ldr		r0, =ActiveTet
	ldrb	r0, [r0]
	cmp		r0, #0
    bleq    checkForClearRow
	bleq	SpawnTetramino
	
	bl		GameWait
	
	ldr		r0, =currentScreen
	ldrb	r0, [r0]
	cmp		r0, #2
	bleq	pause	
	bl		DropTet
	bl		UpdateScore
	b gameloopinside
	pop		{lr}
	bx		lr
//------------------------------a function that clear the full row	
checkForClearRow:
        push    {r4-r12, lr}
        mov     r12, #10 //points to add for a clear row
        //this is a recursive function, need to be able to skip some parts that should only be called after this function has already ran at least once
        b skipReiterationInitializing

        //might need to call this function within this function for multiple row clears
        reiterateRowClearAlgorithm:
        bl      SaveGameState
        bl      DrawGameState
        mov     r0, r12
        bl      addScore
        bl      UpdateScore
        
        //each consecutive row adds 5 more points for being cleared
        add     r12, #5


        skipReiterationInitializing:
        ldr     r4, =GameStateArray
        
        mov     r6, #20 //number of rows to check for clearing
        mov     r5, #10 //cells in a row
        mov     r7, #12 //width of a row (for multiplication)

        GameStateArray  .req    r4
        currentCell     .req    r5
        currentRow      .req    r6
        maxColumn       .req    r7
        currentCellIndex       .req    r8

        forEachRow:
                cmp     currentRow, #0
                beq     doneCheckingForClearRow 

                forEachCellInRow:
                        cmp     currentCell, #0
                        beq     clearRow
                        
                        mla     currentCellIndex, currentRow, maxColumn, currentCell
                        ldrb    r9, [GameStateArray, currentCellIndex]
                        //is this cell in the row a 0? if yes, row not full, go on to next row
                        cmp     r9, #0
                        beq     doneForEachCellInRow
                        sub     currentCell, #1
                        b       forEachCellInRow
                
                
     
        doneForEachCellInRow:
        sub     currentRow, #1
        mov     currentCell, #10
        b       forEachRow                
        

        
        //r6: row to clear
        //clears current rows and moves all above rows down one block, then calls checkForClearRow once it finishes
        clearRow:

                mov     currentCell, #10
                
                loopClearRow:

                        cmp     currentCell, #0
                        beq     doneClearRowLoop

                        //r1 is column, r2 is row
                        mov     r1, currentCell
                        mov     r2, currentRow
                        bl      ClearBlock                       

                        //index in row major is row*columnWidth+ Currentcolumn
                        mla     currentCellIndex, currentRow, maxColumn, currentCell
                        mov     r9, #0
                        //clear
                        strb    r9, [GameStateArray, currentCellIndex]
                        
       
                        sub     currentCell, #1
                        b       loopClearRow

					//-------------after the clear is done, save the status
                doneClearRowLoop:
                bl      SaveGameState
                bl      DrawGameState
                sub     currentRow, #1
                mov     currentCell, #10
               
                
                
                //----------------------checking the row's status and iterate recursively until no full rows exist
                dropDownAllRowsLoop:
                        cmp     currentRow, #0
                        //iterate recursively until no full rows exist
                        beq     reiterateRowClearAlgorithm
                        
                        dropEachCellInRowLoop:
                                cmp     currentCell, #0
                                beq     doneDroppingDownRow

                                mla     currentCellIndex, currentRow, maxColumn, currentCell
                                //colour
                                ldrb    r10, [GameStateArray, currentCellIndex]
                                cmp     r10, #0
                                subeq   currentCell, #1
                                beq     dropEachCellInRowLoop
                                
           
                                        
                                mov     r1, currentCell
                                mov     r2, currentRow
                                bl      ClearBlock
                                mov     r9, #0
                                strb    r9, [GameStateArray, currentCellIndex]
                                add     r2, currentRow, #1
                                mla     currentCellIndex, r2, maxColumn, currentCell
                                
                                mov     r0, r10
                                mov     r1, currentCell
                                mov     r2, r2
                                bl      DrawBlock

                                strb    r10, [GameStateArray, currentCellIndex]

                                sub     currentCell, #1
                                b       dropEachCellInRowLoop

								//---------------------if the dropping down row is done
                        doneDroppingDownRow:    
                        sub     currentRow, #1
                        mov     currentCell, #10
                        b       dropDownAllRowsLoop
			//-----------------save the current game state and reload it
        doneCheckingForClearRow:
        bl      SaveGameState
        bl      DrawGameState
        pop     {r4-r12, lr}
        bx      lr	
//-------------------checking the game status array to see if the game ends	
CheckEndCondition:
	ldr		r0, =SavedGameStateArray
	mov		r1, #0
checkcondloop:
	cmp		r1, #24
	beq		doneendcheck
	ldrb	r2, [r0, r1]
	cmp		r2, #8
	beq		ignoreGreyBlocks
	cmp		r2, #0
	bne		losehandler
	ignoreGreyBlocks:
	add		r1, #1
	b		checkcondloop
	
doneendcheck:
	bx		lr
//------------------the function that saves the current game status	
SaveGameState:
	push	{r4, lr}
	ldr		r0, =SavedGameStateArray
	ldr		r1, =GameStateArray
	ldr		r2, =maxGameStateArray
	ldr 	r2, [r2]
	sub		r2, #1
	mov		r3, #0   //r3 is the loop counter
	//--------------check if the status should be saved
	saveloop:
	cmp		r3, r2
	beq		donesave
	
	ldrb	r4, [r1, r3]
	strb	r4, [r0, r3]

	add		r3, #1
	b		saveloop
	
	donesave:
	pop		{r4, lr}
	bx		lr
//--------------------check the score and to see if the game is win
CheckWinCondition:
	push	{lr}
	ldr		r0, =Score
	ldr		r0, [r0]
	
	cmp		r0, #99
	ble		continueGame
	
	ldr		r0, =gamecondition
	mov		r1, #2
	strb	r1, [r0]
	
	bl		gameMenu
	b		pause
	
	continueGame:
	pop		{lr}
	bx		lr
//-----------------The function that update the user's score after one row is cleared	
UpdateScore:
	push	{r4-r7, lr}
	ldr		r4, =ScoreText
	mov		r5, #0
	mov		r6, #400
	add     r1, r6, #64
	add     r2, r5, #48
	bl      ClearImage
	add     r1, r6, #72
	add     r2, r5, #48
	bl      ClearImage
	
/* Function that will take in perform N = D × Q + R 
	r1 contains D and r0 contains N 
	D/N = Q+R
	r0/r1 = r0+r1
	returns Q in r0 and R in r1 */
//--------------draw the score on the screen
scoretextloop:
	cmp		r5, #6
	beq		doneScoreText
	ldrb	r0, [r4,r5]
	
	mov		r1, r6
	bl		DrawChar
	
	add		r5, #1
	add		r6, #8
	b		scoretextloop
doneScoreText:
	ldr		r4, =Score
	ldr		r4, [r4]
	
	mov		r7, #0
	mov		r6, #472

divideloop:	
	mov		r0, r4
	mov 	r1, #10
	cmp		r0, #0
	beq		donedivdeloop
	bl		divide
	mov		r4, r0

	add		r1, #48
	mov		r0, r1
	mov		r1, r6
	bl		DrawChar
	sub		r6, #8	
	b		divideloop
donedivdeloop:
	pop		{r4-r7, lr}
	bx		lr

addScore:
        ldr     r1, =Score
        ldr     r2, [r1]
        add     r0, r2
        str     r0, [r1]
        bx       lr

SpawnTetramino:
	push	{lr}
	
	bl		getTetrimino
	ldr		r1, =CurrentTet
	str		r0, [r1]

	ldr		r1, =CurrentTetBase
	str		r0, [r1]

	ldr		r0, =CurrentTetX
	mov		r1, #5
	strb	r1, [r0]
	
	ldr		r0, =CurrentTetY
	mov		r1, #0
	strb	r1, [r0]
	
	ldr		r0, =CurrentTet
	ldr		r0, [r0]
	mov		r1, #5
	mov		r2, #0
	mov		r3, #0
	bl		DrawTetramino
	
	ldr		r0, =ActiveTet
	mov		r1, #1
	strb	r1, [r0]
	
	pop		{lr}
	bx		lr
//-------------------------Function for the blocks dropping down	
DropTet:
	push	{r4,r5,lr}
	Tetx	.req r4
	Tety	.req r5
	
	ldr		r0, =CurrentTetX
	ldrb	Tetx, [r0]
	ldr		r0, =CurrentTetY
	ldrb	Tety, [r0]
	
	ldr		r0, =CurrentTet
	ldr		r0, [r0]
	mov		r1, Tetx
	mov		r2, Tety
	add		r2, #1
	bl		CheckPlacementSpace
	
	cmp		r0, #0
	beq		contDropping
	ldr		r0, =ActiveTet
	mov		r1, #0
	strb	r1,[r0]
	bl		SaveGameState
	b		stopDropping
	
	contDropping:
	ldr		r0, =CurrentTet
	ldr		r0, [r0]
	mov		r1, Tetx
	mov		r2, Tety
	mov		r3, #1
	bl		DrawTetramino
	
	ldr		r0, =CurrentTet
	ldr		r0, [r0]
	mov		r1, Tetx
	mov		r2, Tety
	add		r2, #1
	mov		r3, #0
	bl		DrawTetramino
	
	ldr		r0, =CurrentTetY
	mov		r1, Tety
	add		r1, #1
	strb	r1, [r0]
	
	stopDropping:
	pop		{r4,r5,lr}
	bx		lr
    
//--------------------the function for the block move left
moveleft:
	push	{lr}
	ldr		r0, =CurrentTetX
	ldrb	r1, [r0]
	sub		r1, #1
	ldr		r0, =CurrentTetY
	ldrb	r2, [r0]
	ldr		r0, =CurrentTet
	ldr		r0, [r0]
	bl		CheckPlacementSpace
	
	cmp		r0, #0
	bne		donotmoveleft
	
	ldr		r0, =CurrentTetX
	ldrb	r1, [r0]
	ldr		r2, =CurrentTetXORG
	strb	r1, [r2]
	sub		r1, #1
	strb	r1, [r0]
	
	ldr		r0, =CurrentTetXORG
	ldrb	r1, [r0]
	ldr		r0, =CurrentTetY
	ldrb	r2, [r0]
	mov		r3, #1
	ldr		r0, =CurrentTet
	ldr		r0, [r0]
	bl		DrawTetramino
	
	ldr		r0, =CurrentTetX
	ldrb	r1, [r0]
	ldr		r0, =CurrentTetY
	ldrb	r2, [r0]
	mov		r3, #0
	ldr		r0, =CurrentTet
	ldr		r0, [r0]
	bl		DrawTetramino
		
	donotmoveleft:
	pop		{lr}
	bx		lr
//--------------------the function for the block move right	
moveright:
	push	{lr}
	ldr		r0, =CurrentTetX
	ldrb	r1, [r0]
	add		r1, #1
	ldr		r0, =CurrentTetY
	ldrb	r2, [r0]
	ldr		r0, =CurrentTet
	ldr		r0, [r0]
	bl		CheckPlacementSpace
	
	cmp		r0, #0
	bne		donotmoveright
	
	ldr		r0, =CurrentTetX
	ldrb	r1, [r0]
	ldr		r2, =CurrentTetXORG
	strb	r1, [r2]
	add		r1, #1
	strb	r1, [r0]

	ldr		r0, =CurrentTetXORG
	ldrb	r1, [r0]
	ldr		r0, =CurrentTetY
	ldrb	r2, [r0]
	mov		r3, #1
	ldr		r0, =CurrentTet
	ldr		r0, [r0]
	bl		DrawTetramino
	
	ldr		r0, =CurrentTetX
	ldrb	r1, [r0]
	ldr		r0, =CurrentTetY
	ldrb	r2, [r0]
	mov		r3, #0
	ldr		r0, =CurrentTet
	ldr		r0, [r0]
	bl		DrawTetramino
	
	donotmoveright:
	pop		{lr}
	bx		lr
//-----------------The function for the block rotate counterclockwise		
rotateleft:
    push	{r4,r5, lr}
    ldr		r0, =CurrentRotation
    ldrb	r4, [r0]
    cmp		r4, #2
    ble		elseroation
    mov		r4, #0
	ldr		r5, =CurrentTetBase
	ldr		r5, [r5]
	b		controtation
    elseroation:
    add   	r4, #1     
    ldr		r5, =CurrentTetBase
    ldr		r5, [r5]
    mov		r3, r4
    lsl		r3, #4
    add		r5, r3
    controtation:
	ldr		r0, =CurrentTetX
	ldrb	r1, [r0]
	ldr		r0, =CurrentTetY
	ldrb	r2, [r0]
	mov		r0, r5
	bl		CheckPlacementSpace
	cmp		r0, #0
	bne		donotrotate
	ldr		r0, =CurrentTetX
	ldrb	r1, [r0]
	ldr		r0, =CurrentTetY
	ldrb	r2, [r0]
	mov		r3, #1
	ldr		r0, =CurrentTet
	ldr		r0, [r0]
	bl		DrawTetramino
	ldr		r0, =CurrentRotation
    strb	r4, [r0]
	ldr		r0, =CurrentTet
	str		r5, [r0]
	ldr		r0, =CurrentTetX
	ldrb	r1, [r0]
	ldr		r0, =CurrentTetY
	ldrb	r2, [r0]
	ldr		r0, =CurrentTet
	ldr		r0, [r0]
	mov		r3, #0
	bl		DrawTetramino
    
    donotrotate:
	pop		{r4,r5, lr}
	bx		lr
//-------------------The function for the block rotate clockwise	
rotateright:
    push	{r4,r5, lr}
    ldr		r0, =CurrentRotation
    ldrb	r4, [r0]
    cmp		r4, #0
    beq		elseroationright
    sub   	r4, #1     
    ldr		r5, =CurrentTetBase
    ldr		r5, [r5]
    mov		r3, r4
    lsl		r3, #4
    add		r5, r3
    b		controtationright
    elseroationright:
    mov		r4, #3
    mov		r3, r4
    lsl		r3, #4
	ldr		r5, =CurrentTetBase
	ldr		r5, [r5]
	add		r5, r3
    controtationright:
	ldr		r0, =CurrentTetX
	ldrb	r1, [r0]
	ldr		r0, =CurrentTetY
	ldrb	r2, [r0]
	mov		r0, r5
	bl		CheckPlacementSpace
	cmp		r0, #0
	bne		donotrotateright
	ldr		r0, =CurrentTetX
	ldrb	r1, [r0]
	ldr		r0, =CurrentTetY
	ldrb	r2, [r0]
	mov		r3, #1
	ldr		r0, =CurrentTet
	ldr		r0, [r0]
	bl		DrawTetramino
	ldr		r0, =CurrentRotation
    strb	r4, [r0]
	ldr		r0, =CurrentTet
	str		r5, [r0]
	ldr		r0, =CurrentTetX
	ldrb	r1, [r0]
	ldr		r0, =CurrentTetY
	ldrb	r2, [r0]
	ldr		r0, =CurrentTet
	ldr		r0, [r0]
	mov		r3, #0
	bl		DrawTetramino
    donotrotateright:
	pop		{r4,r5, lr}
	bx		lr
//-----------------------the function for setting the delay time in the game	
GameWait:
	push     {r4,r5, lr}
	ldr		r0, =WaitInterval
	ldr 	r1, [r0]
	ldr      r0, =0x3F003004	//load the address for CLO
	ldr      r4, [r0]		//read CLO	
	ldr      r5, [r0]        	//r3 is current clock
	add      r4, r1         	//r2 is the upper clock  
	bl 		mainSNES
	//-------This loop is to make sure the current time is at least equal to the delay time we set
	loopWait2:
	cmp     r5, r4			//if the current clock is smaller than the upper clock
	bge		donewait
	ldr     r0, =0x3F003004
	ldr     r5, [r0]        	//r3 is current clock
	bl 		bigLoop
	b      loopWait2	
	donewait:
	pop     {r4,r5, lr}
	bx       lr


.section .data // data goes in the data section
.align // align to word boundaries

CurrentTet:  .word 0
CurrentTetBase: .word 0 
CurrentTetX: .byte 0
CurrentTetXORG: .byte 0
CurrentTetY: .byte 0
CurrentTetYORG: .byte 0
ActiveTet:	 .byte 0
CurrentRotation: .byte 0
ScoreText: .ascii "SCORE:"
Score:	.int 230
blank: .byte 0
gamecondition: .byte 0
currentScreen: .byte 0
powerup: .byte 0
