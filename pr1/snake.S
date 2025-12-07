    .section .text
    .globl _start
_start:

# Datos de la matriz
.equ LED_MATRIX_0_BASE, 0x40000000
.equ LED_MATRIX_0_WIDTH, 12
.equ LED_MATRIX_0_HEIGHT,12

li a0, LED_MATRIX_0_BASE
li a1, LED_MATRIX_0_WIDTH
li a2, LED_MATRIX_0_HEIGHT
li a3, 0x32cd32 

# Datos iniciales de la serpiente
li a4, 0 # posicion inicial en y
li a5, 0 # posicion inicial en x
li a6, 0 # resultado de la multiplicacion de a1 con x
li a7, 0 # posicion de la cabeza con la formula

# Cola circular para el cuerpo de la serpiente
li s7, 0x10010000  # DirecciÛn base del buffer de la cola
li s8, 0           # Õndice de inicio cola
li s9, 0           # Õndice de la cabeza
li s10, 3          # Longitud actual de la serpiente
li s11, 148        # Capacidad m·xima del buffer

# Inicializar las 3 primeras posiciones
sw zero, 0(s7)
sw zero, 4(s7)
sw zero, 8(s7)
li s9, 3           # head = 3

# Pintar las 3 primeras posiciones
sw a3, 0(a0)       # pixel en (0,0)

# Direcciones de memoria del DPAD 
li s0, 0 # Registro para guardar el ultimo movimiento (0=derecha inicialmente)
li t1, 0xF0000000   
li t2, 0xF0000004    
li t3, 0xF0000008   
li t4, 0xF000000C   
 
# Datos iniciales de la manzana
li s3, 0xff0000
li s4, 274  # xi
li s5, 13   # a
li s6, 144  # m

Generate_apple:
    add t5, s4, a0       # Se guarda la manzana en una posible posicion
    lw t6, 0(t5)         # Se carga el contenido de la posicion de la manzana en t6 
    beq t6, zero, Apple_Position_ok # Si no hay nada se genera la manzana
    j RNG                # Si no, otro valor

Apple_Position_ok:
    sw s3, 0(t5)         # Pintar manzana
    j Dpad_check

RNG:
    mul s4, s4, s5   #Calculos del algoritmo Linear Congruence Method
    addi s4, s4, 1
    rem s4, s4, s6
    slli s4, s4, 2
    j Generate_apple


Dpad_check:
    lw t0, 0(t1)
    bnez t0, up
    
    lw t0, 0(t2)
    bnez t0, down
    
    lw t0, 0(t3)
    bnez t0, left

    lw t0, 0(t4)
    bnez t0, right

    # Caso para cuando no se presiona boton
    j No_Input


Snake_Head:
    # Verificar lÌmites de la matriz
    blt a5, zero, Animation_Initialize
    bge a5, a1, Animation_Initialize
    blt a4, zero, Animation_Initialize
    bge a4, a2, Animation_Initialize
    
    # Calcular la nueva posicion de la cabeza
    mul a6, a4, a1 
    add a7, a6, a5
    slli a7, a7, 2
    add s1, a0, a7
 
    # Colision con la manzana y cuerpo
    lw t5, 0(s1) 
    beq t5, s3, Eat_Apple
    beq t5, a3, Animation_Initialize
    
    # Agregar nueva posiciÛn a la cola
    slli t6, s9, 2
    add t6, t6, s7
    sw a7, 0(t6)
    
    addi s9, s9, 1
    rem s9, s9, s11
    
    # Pintar nueva cabeza
    sw a3, 0(s1)
    
    # Eliminar la cola (mantener longitud constante)
    slli t6, s8, 2
    add t6, t6, s7
    lw t6, 0(t6)
    add t6, t6, a0
    sw zero, 0(t6)
    
    addi s8, s8, 1
    rem s8, s8, s11
    
    j Dpad_check

Eat_Apple:
    # Agregar nueva posiciÛn a la cola
    slli t6, s9, 2
    add t6, t6, s7
    sw a7, 0(t6)
    
    addi s9, s9, 1
    rem s9, s9, s11
    
    # Pintar nueva cabeza
    sw a3, 0(s1)
    
    # NO eliminamos la cola
    addi s10, s10, 1
    
    # Generar nueva manzana
    j Generate_apple

right:
    li s2, 3              #Las primeras 2 lineas son comprobaciones para no
    beq s0,s2, No_Input   #poder moverse hacia atras
    li s0,0
    addi a5, a5, 1
    j Snake_Head

up:
    li s2, 2
    beq s0,s2, No_Input
    li s0,1
    addi a4, a4, -1
    j Snake_Head

down:
    li s2, 1
    beq s0,s2, No_Input
    li s0,2
    addi a4, a4, 1
    j Snake_Head

left:
    li s2, 0
    beq s0,s2, No_Input
    li s0,3
    addi a5, a5, -1
    j Snake_Head
    
No_Input:
    li t0, 0
    beq s0, t0, right
    li t0, 1
    beq s0, t0, up
    li t0, 2
    beq s0, t0, down
    li t0, 3
    beq s0, t0, left
    j Dpad_check


Animation_Initialize:
   li t0, 0
   li t1, 0
   li t2, 0
   li t3, 0
   li t4, 0
   li t5, 0xFFECA1
   li t6, 576
   j Animation

Animation:
    mul t2, t0, a1
    add t3, t2, t1
    slli t3, t3, 2
    add t4, a0, t3
    sw t5, 0(t4)
    addi t1, t1, 1
    addi t0, t0, 1
    blt t3, t6, Animation
    li t6,0
    li t4,0
    j Game_Over

Game_Over:
    li t1, 0
    li t2, 576
    li t3, 0x0
    j Restart

Restart:
    add t6, a0, t1
    sw t4, 0(t6)
    addi t1, t1, 4
    blt t1, t2, Restart

li t4, 0
li t5, 0
li t6, 0     
ret

