li a0, LED_MATRIX_0_BASE
li a1, LED_MATRIX_0_WIDTH
li a2, LED_MATRIX_0_HEIGHT
li a3, 0  #contador x
li a4, 0  #contador y
li a6, 0
li a7, 0
li t1, 0xfc032c


diagonal:
mul a6, a3, a1 
add a7, a6, a4  
slli a7, a7, 2

add t0, a0, a7
sw t1, 0(t0)

addi a3, a3, 1
addi a4,a4,1

j diagonal
