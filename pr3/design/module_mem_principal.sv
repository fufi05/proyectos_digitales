// archivo: module_mem_principal.sv
// Módulo de memoria principal modelada por bytes. Tamaño: MEM_SIZE_BYTES (2^16) 

module module_mem_principal #(
    // Parámetros de tamaño
    parameter int ADDR_WIDTH = 16, // tamaño de la dirección de memoria
    parameter int SIZE_BLOCK = 256, // Tamaño de los bloques de memoria en bits
    parameter int WORD_SIZE = 32, // Tamaño de la palabra en bits 
    parameter int MEM_SIZE_BYTES = (1 << ADDR_WIDTH) // Tamaño total de la memoria en bytes (2^16)
)(

    input logic clk,
    input logic rst,

    // Interfaz de lectura y escritura de bloques 
    // Lectura de bloques: leer un bloque de datos desde una dirección específica
    input logic                       rd_block_rq, // Señal de solicitud de lectura de bloque
    input logic [ADDR_WIDTH-1:0]      rd_block_addr, // Dirección de inicio para la lectura del bloque
    output logic                      rd_block_ack,  // Bandera de reconocimiento de lectura de bloque
    output logic [SIZE_BLOCK-1:0]     rd_block_data, // Datos leídos del bloque

    // Escritura de bloques: Escribir un bloque de datos en una dirección específica
    input logic                      wr_bytes_rq, // Señal de solicitud de escritura de bloque
    input logic [ADDR_WIDTH-1:0]     wr_bytes_addr, // dirección de byte
    input logic [WORD_SIZE-1:0]      wr_bytes_data, // Datos a escribir en el bloque
    output logic                     wr_bytes_ack  // Bandera de reconocimiento de escritura de bloque 
);

    localparam int MEM_BYTES = MEM_SIZE_BYTES;
    // Definición de la memoria principal en bytes
    logic [7:0] mem [0:MEM_BYTES-1];

    // Inicialización
    integer i;
    initial begin
        for (i = 0; i < MEM_BYTES; i++) mem[i] = i[7:0];
    end

    // Lógica para la lectura de bloques
    // ack en el mismo ciclo (o en el siguiente) para simulación.
    // Lectura de bloque: se concatenan 32 bytes en rd_block_data (LSB: byte[0])
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            rd_block_ack <= 1'b0;
            rd_block_data <= '0;
            wr_bytes_ack <= 1'b0;
        end 
        else begin
            // read block
            if (rd_block_req) begin
                rd_block_ack <= 1'b1;
                // Si el bloque es menor, ajusta el trozo.
                integer b;
                for (b = 0; b < 32; b++) begin
                    rd_block_data[8*b +: 8] <= mem[rd_block_base_addr + b];
                end
            end 
            else begin
                rd_block_ack <= 1'b0;
            end

            // write bytes (32-bit word)
            if (wr_bytes_req) begin
                wr_bytes_ack <= 1'b1;
                integer k;
                for (k = 0; k < 4; k++) begin
                    mem[wr_bytes_addr + k] <= wr_bytes_data[8*k +: 8];
                end
            end 
            else begin
                wr_bytes_ack <= 1'b0;
            end
        end
    end
endmodule 
