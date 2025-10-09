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
li s11, 100        # Capacidad máxima del buffer ( se puede modificar)

# Inicializar las 3 primeras posiciones
sw zero, 0(s7)     # pos[0] = 0
sw zero, 4(s7)     # pos[1] = 0
sw zero, 8(s7)     # pos[2] = 0 Las 3 las iniciamos en 0 
li s9, 3           # head = 3

# Pintar las 3 primeras posiciones
sw a3, 0(a0)       # pixel en (0,0)

# Direcciones de memoria del DPAD 
li t1, 0xF0000000   
li t2, 0xF0000004    
li t3, 0xF0000008   
li t4, 0xF000000C   
    
# Datos iniciales de la manzana
li s3, 0xff0000
li s4, 128  # xi
li s5, 2    # a
li s6, 898  # m

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
    j Dpad_check

Snake_Head:
    # Verificar límites de la matriz
    blt a5, zero, Game_Over      # Si X < 0, game over
    bge a5, a1, Game_Over        # Si X >= ancho, game over
    blt a4, zero, Game_Over      # Si Y < 0, game over
    bge a4, a2, Game_Over        # Si Y >= alto, game over
    
    # Calcular la nueva posicion de la cabeza
    mul a6, a4, a1 
    add a7, a6, a5
    slli a7, a7, 2
    add s1, a0, a7
 
    # Colision con la manzana
    lw t5, 0(s1) # Cargo en t5 el color en la dir de mem de s1 (siguiente cabeza)
    beq t5, s3, Eat_Apple # si es el color de la manzana salto
    
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
    addi a5, a5, 1
    j Snake_Head
    
up:
    addi a4, a4, -1
    j Snake_Head

down:
    addi a4, a4, 1
    j Snake_Head

left:
    addi a5, a5, -1
    j Snake_Head

Game_Over:
    # Bucle infinito - el juego termina
    j Game_Over     #Se para el juego alli lo podemos modificar como queramos