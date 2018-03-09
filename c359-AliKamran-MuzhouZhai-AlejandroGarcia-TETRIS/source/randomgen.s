//Created by Ali Kamran, Muzhou Zhai, Alejandro Garcia For CPSC 359
//testing changes made to the git repo

.section    .init
.globl      getRandom, getTetrimino, generateRandomVariables
 
 
.section .text
//-----------------------function that get the tetrimino
getTetrimino:
        push    {lr}
        bl		getRandom
        cmp     r0, #1
        ldreq   r0, =defaultI0
        cmp     r0, #2
        ldreq   r0, =defaultJ0
        cmp     r0, #3
        ldreq   r0, =defaultL0
        cmp     r0, #4
        ldreq   r0, =defaultO0
        cmp     r0, #5
        ldreq   r0, =defaultS0
        cmp     r0, #6
        ldreq   r0, =defaultT0
        cmp     r0, #7
        ldreq   r0, =defaultZ0
        pop     {lr}
        bx      lr


//returns in r0 a number from 1-7
//--------------function that get the random number
getRandom:
        push    {r4-r8, lr}
		gotAZero:
        x       .req    r4
        y       .req    r5
        z       .req    r6
        w       .req    r7
        t       .req    r8
 
        ldr     r0, =xRandom
        ldr     x, [r0]
        ldr     r0, =yRandom
        ldr     y, [r0]
        ldr     r0, =zRandom
        ldr     z, [r0]
        ldr     r0, =wRandom
        ldr     w, [r0]
 
        mov     t, x
        eor     t, t, t, lsl #11
        eor     t, t, t, lsr #8
        mov     x, y
        mov     y, z
        mov     z, w
        eor     w, w, w, lsr #19
        eor     w, t

        ldr     r0, =xRandom
        str     x, [r0]
        ldr     r0, =yRandom
        str     y, [r0]
        ldr     r0, =zRandom
        str     z, [r0]
        ldr     r0, =wRandom
        str     w, [r0]
 
        //clear all except first 3 bits for a number from 1-7
        mov     r0, w
        mov     r1, #7
        and     r0, r1
 
        //don't want a 0
        cmp     r0, #0
        beq     gotAZero
 
        pop     { r4-r8, lr}
        bx      lr
//------------------------------function that generate one random number at one time        
generateRandomVariables:
	push    {r4-r8, lr}

	ldr     r0, =xRandom
	ldr     r1, =yRandom
	ldr     r2, =zRandom
	ldr     r3, =wRandom
	ldr     r4, =0x3F003004
	ldr     r4, [r4]
	mov     r5, r4       
	mov     r6, r4, lsl #1
	mov     r7, r4, lsl #2
	mov     r8, r4, lsl #3
	str     r5, [r0]
	str     r6, [r1]
	str     r7, [r2]
	str     r8, [r3]

	pop     {r4-r8, lr}
	bx      lr

     
.section .data // data goes in the data section
.align // align to word boundaries
xRandom: .int 501
yRandom: .int 848
zRandom: .int 925
wRandom: .int 803

