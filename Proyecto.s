# Datos de la matriz
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
li s7, 0x10010000  # Dirección base del buffer de la cola (elegida)
li s8, 0           # Índice de inicio cola
li s9, 0           # Índice de la cabeza
li s10, 3          # Longitud actual de la serpiente
li s11, 148        # Capacidad máxima del buffer ( se puede modificar)

# Inicializar las 3 primeras posiciones
sw zero, 0(s7)     # pos[0] = 0
sw zero, 4(s7)     # pos[1] = 0
sw zero, 8(s7)     # pos[2] = 0 Las 3 las iniciamos en 0 
li s9, 3           # head = 3

# Pintar las 3 primeras posiciones
sw a3, 0(a0)       # pixel en (0,0)

# Direcciones de memoria del DPAD 

li s0, 0 #Registro para guardar el ultimo movimiento (0=derecha)
li t1, 0xF0000000   
li t2, 0xF0000004    
li t3, 0xF0000008   
li t4, 0xF000000C   
    
# Datos iniciales de la manzana
li s3, 0xff0000
li s4, 274  # xi
li s5, 13    # a
li s6, 144  # m

Generate_apple:
    add t5, s4, a0
    sw s3, 0(t5)
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
    slli s4, s4, 2
 
    # Caso para cuando no se presiona boton
    j No_Input
 

Snake_Head:
    # Verificar límites de la matriz
    blt a5, zero, Animation_Initialize      # Si X < 0, game over
    bge a5, a1, Animation_Initialize        # Si X >= ancho, game over
    blt a4, zero, Animation_Initialize      # Si Y < 0, game over
    bge a4, a2, Animation_Initialize        # Si Y >= alto, game over
    
    # Calcular la nueva posicion de la cabeza
    mul a6, a4, a1 
    add a7, a6, a5
    slli a7, a7, 2
    add s1, a0, a7
 
    # Colision con la manzana y cuerpo
    lw t5, 0(s1) # Cargo en t5 el color en la dir de mem de s1 (siguiente cabeza)
    beq t5, s3, Eat_Apple # si es el color de la manzana salto
    beq t5, a3, Animation_Initialize # si es el color del cuerpo salto
    
    # Agregar nueva posición a la cola
    slli t6, s9, 2      # Multiplicar índice por 4 (tamaño de word)
    add t6, t6, s7      # Dirección = base + offset
    sw a7, 0(t6)        # Guardar posición en la cola
    
    addi s9, s9, 1      # Incrementar head
    rem s9, s9, s11     # contador del buffer 
    
    # Pintar nueva cabeza
    sw a3, 0(s1)
    
    # Eliminar la cola (mantener longitud constante)
    slli t6, s8, 2      # Multiplicar índice por 4
    add t6, t6, s7      # Dirección = base + offset
    lw t6, 0(t6)        # Cargar posición de la cola
    add t6, t6, a0      # Convertir a dirección absoluta
    sw zero, 0(t6)      # Borrar pixel de la cola
    
    addi s8, s8, 1      # Incrementar  cola 
    rem s8, s8, s11     # contador del buffer (Por si se satura)
    
    j Dpad_check

Eat_Apple:
    # Agregar nueva posición a la cola
    slli t6, s9, 2
    add t6, t6, s7
    sw a7, 0(t6)
    
    addi s9, s9, 1
    rem s9, s9, s11
    
    # Pintar nueva cabeza
    sw a3, 0(s1)
    
    # NO eliminamos la cola, la serpiente crece
    addi s10, s10, 1    # Incrementar longitud
    
    # Generar nueva manzana
    j Generate_apple
 
      
right:
    li s0,0
    addi a5, a5, 1
    j Snake_Head
    
up:
    li s0,1
    addi a4, a4, -1
    j Snake_Head

down:
    li s0,2
    addi a4, a4, 1
    j Snake_Head

left:
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
  #Se inicializan las variables para la animacion de game over
   li t0, 0 #contador en x
   li t1,0 #contador en y
   li t2,0 
   li t3,0
   li t4,0
   li t5, 0xFFECA1
   li t6, 576 #valor maximo del offset del tablero
   j Animation

Animation:
    mul t2, t0, a1
    add t3,t2,t1
    slli t3,t3,2
    add t4,a0,t3
    sw t5, 0(t4)
    addi t1,t1, 1
    addi t0,t0, 1
    blt t3, t6, Animation  
    li t6,0
    li t4,0
    j Game_Over
    
    
Game_Over:
    #registros para limpiar el tablero
    li t1, 0                # Posicion a eliminar
    li t2, 576              # offset maximo del tablero en este caso 15*15
    li t3, 0x0              # color negro
    j Restart

Restart:
    # se limpia el tablero
    add t6, a0, t1          
    sw t4, 0(t6)            
    addi t1, t1, 4          
    blt t1, t2, Restart

li t4, 0
li t5, 0
li t6, 0     
ret
