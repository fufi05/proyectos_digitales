#Datos de la matriz
li a0, LED_MATRIX_0_BASE
li a1, LED_MATRIX_0_WIDTH
li a2, LED_MATRIX_0_HEIGHT
li a3, 0x32cd32 

#Datos iniciales de la serpiente
sw a3, 0(a0)
li a4, 0 #posicion inicial en y
li a5, 0 #posicion inicial en x
li a6, 0 #resultado de la multiplicacion de a1 con x
li a7, 0 # posicion de la cabeza con la formula
li s2, 0 # flag para verificar si ya se elimino la cabeza inicial

# Direcciones de memoria del DPAD 
    li t1, 0xF0000000   
    li t2, 0xF0000004    
    li t3, 0xF0000008   
    li t4, 0xF000000C   
    
#Datos iniciales de la manzana
li s3, 0xff0000
li s4, 128  #xi
li s5, 2  # a
li s6 898 #m

Generate_apple:
    add t5, s4, a0
    sw s3, 0(t5)
    li t5, 0
    j Dpad_check
    
Dpad_check:
    # Se carga el contenido de la dir de mem en t0 y se verifica si es distinto de 0
    lw t0, 0(t1)
    bnez t0, up

    lw t0, 0(t2)       
    bnez t0, down

    lw t0, 0(t3)       
    bnez t0, left

    lw t0, 0(t4)       
    bnez t0, right
    
    RNG:
    mul s4, s4, s5 
    addi s4, s4, 1
    rem s4, s4, s6
    slli s4, s4,2
    j Dpad_check

Snake_Head:
    #Aqui hacemos el calculo para la posicion de la cabeza de la serpiente
    beq s2, zero Delete_First_Head
    mul a6 ,a4, a1 
    add a7, a6, a5
    slli a7, a7, 2
    add s1, a0, a7
    sw a3,0(s1) 
    j Dpad_check
    
Delete_First_Head:
        sw zero,0(a0)
        addi s2, s2, 1
        j Snake_Head
        
right:
  sw zero,0(s1)
  addi a5, a5, 1
  j Snake_Head
    
up:
  sw zero,0(s1)
  addi a4, a4, -1
  j Snake_Head

down:
  sw zero,0(s1)
  addi a4, a4, 1
  j Snake_Head

left:
    sw zero,0(s1)
    addi a5, a5, -1
    j Snake_Head
    



    




