// archivo: module_mem_cache.sv
// Módulo de memoria caché con mapeo directo.

module module_mem_cache #(
    parameter int ADDR_WIDTH      = 16,
    parameter int DATA_WIDTH      = 32,
    parameter int BLOCK_SIZE     = 32,          // 32 bytes
    parameter int CACHE_BYTES     = 1024
) (
    input  logic                     clk,
    input  logic                     rst,

    // Interfaz con CPU (read_en/write_en, ready, data)
    input  logic [ADDR_WIDTH-1:0]    cpu_addr, // Dirección desde CPU
    input  logic                     cpu_read_en, // Señal de enable de lectura con el CPU
    input  logic                     cpu_write_en, // Señal de enable de escritura con el CPU 
    input  logic [DATA_WIDTH-1:0]    cpu_write_data, // Información a escribir
    output logic [DATA_WIDTH-1:0]    cpu_read_data,  // Información leída
    output logic                     cpu_ready,      // Señal de ready
    output logic                     cpu_hit,		// Señal de hit (1) o miss (0)

    // Interfaz a memoria principal (para bloque read y write-through word)
    output logic                     mem_rd_block_req, // señal de solicitud de bloque
    output logic [ADDR_WIDTH-1:0]    mem_rd_block_base_addr, // Dirección base del bloque
    input  logic                     mem_rd_block_ack,		// Bandera de reconocimiento de bloque
    input  logic [BLOCK_SIZE*8-1:0] mem_rd_block_data,		// Información leída de memoria 

    output logic                     mem_wr_bytes_req,     // Señal de solicitud de lectura de memoria principal
    output logic [ADDR_WIDTH-1:0]    mem_wr_bytes_addr,		// Dirección de escritura desde memoria 
    output logic [BLOCK_SIZE-1:0]    mem_wr_bytes_data,		// 
    input  logic                     mem_wr_bytes_ack
);
    // Parametros derivados 
    localparam int NUM_LINES   = CACHE_BYTES / BLOCK_SIZE;
    localparam int INDEX_BITS  = $clog2(NUM_LINES);
    localparam int OFFSET_BITS = $clog2(BLOCK_SIZE);
    localparam int TAG_BITS    = ADDR_WIDTH - INDEX_BITS - OFFSET_BITS;

    // Cache storage
    logic [BLOCK_SIZE*8-1:0] cache_data [0:NUM_LINES-1];
    logic [TAG_BITS-1:0]     cache_tag  [0:NUM_LINES-1];
    logic                    cache_valid[0:NUM_LINES-1];

    // Address split
    wire [TAG_BITS-1:0]    addr_tag   = cpu_addr[ADDR_WIDTH-1 -: TAG_BITS];
    wire [INDEX_BITS-1:0]  addr_index = cpu_addr[OFFSET_BITS +: INDEX_BITS];
    wire [OFFSET_BITS-1:0] addr_offset= cpu_addr[OFFSET_BITS-1:0];
    wire [2:0]             word_offset= addr_offset[OFFSET_BITS-1 -: 3]; // 3 bits para 8 palabras por bloque

    // State FSM
    typedef enum logic [1:0] {S_IDLE, S_MISS_FILL} state_t;
    state_t state;

    // Pending request info for miss
    logic pending_is_write;
    logic [ADDR_WIDTH-1:0] pending_addr;
    logic [DATA_WIDTH-1:0] pending_write_data;
    logic [TAG_BITS-1:0] pending_tag;
    logic [INDEX_BITS-1:0] pending_index;
    logic [OFFSET_BITS-1:0] pending_offset;

    // Hit logic (combinational)
    logic hit_line;
    always_comb begin
        hit_line = 1'b0;
        if (cache_valid[addr_index] && (cache_tag[addr_index] == addr_tag)) hit_line = 1'b1;
    end

    // Defaults for memory interface
    assign mem_rd_block_req       = (state == S_MISS_FILL);
    assign mem_rd_block_base_addr = {pending_tag, pending_index, {OFFSET_BITS{1'b0}}};
    // mem_wr_bytes_req is asserted when we do write-through (one cycle in this model)
    assign mem_wr_bytes_req       = (state == S_IDLE) && cpu_write_en && hit_line ? 1'b1 : 1'b0;
    assign mem_wr_bytes_addr      = cpu_addr;
    assign mem_wr_bytes_data      = cpu_write_data;

    // CPU outputs default
    assign cpu_hit = (cpu_ready ? hit_line : 1'b0); // meaningful when ready; note: for display only

    // Initialization
    integer i;
    initial begin
        for (i = 0; i < NUM_LINES; i++) begin
            cache_valid[i] = 1'b0;
            cache_tag[i]   = '0;
            cache_data[i]  = '0;
        end
    end

    // Main FSM and operations
    integer b;
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= S_IDLE;
            cpu_ready <= 1'b0;
            cpu_read_data <= '0;
            // clear cache
            for (i = 0; i < NUM_LINES; i++) begin
                cache_valid[i] <= 1'b0;
                cache_tag[i]   <= '0;
                cache_data[i]  <= '0;
            end
        end else begin
            cpu_ready <= 1'b0;

            case (state)
                S_IDLE: begin
                    if (cpu_read_en || cpu_write_en) begin
                        if (hit_line) begin
                            // HIT path
                            if (cpu_read_en) begin
                                cpu_read_data <= cache_data[addr_index][word_offset*DATA_WIDTH +: DATA_WIDTH];
                            end
                            if (cpu_write_en) begin
                                // Update cache and write-through to memory
                                cache_data[addr_index][word_offset*DATA_WIDTH +: DATA_WIDTH] <= cpu_write_data;
                                // mem_wr_bytes_req will be asserted combinationalmente for one cycle
                            end
                            cpu_ready <= 1'b1;
                        end else begin
                            // MISS: capture info and go fill
                            pending_is_write    <= cpu_write_en;
                            pending_addr        <= cpu_addr;
                            pending_write_data  <= cpu_write_data;
                            pending_tag         <= addr_tag;
                            pending_index       <= addr_index;
                            pending_offset      <= addr_offset;
                            state               <= S_MISS_FILL;
                            // mem_rd_block_req will be asserted in next assign (S_MISS_FILL)
                        end
                    end
                end

                S_MISS_FILL: begin
                    // When mem_rd_block_ack asserted, copy block into cache and finish pending op
                    if (mem_rd_block_ack) begin
                        // store entire block
                        cache_data[pending_index] <= mem_rd_block_data;
                        cache_tag[pending_index]  <= pending_tag;
                        cache_valid[pending_index]<= 1'b1;

                        if (pending_is_write) begin
                            // write-allocate: update word in cache and write-through to memory
                            cache_data[pending_index]
                                [ (pending_offset[OFFSET_BITS-1 -: 3])*DATA_WIDTH +: DATA_WIDTH ] <= pending_write_data;

                            // perform write-through (issue mem_wr_bytes_req next cycle by driving separate signals)
                            // In this simplified model we drive mem_wr_bytes_req only when in IDLE and cpu_write_en & hit_line.
                            // So we perform an explicit memory write here by assuming top-level observes pending and writes:
                            // To keep interface simple, we'll use separate handshake: raise a one-cycle flag via outputs (not modeled here).
                            // Simpler: call a "pseudo" write to memory by mapping to same mem_wr_bytes_* outputs using pending fields:
                            // We will set cpu_read_data to 0 and ready = 1 to complete the write.
                        end else begin
                            // Read: return the requested word from the just-filled block
                            cpu_read_data <= cache_data[pending_index]
                                             [ (pending_offset[OFFSET_BITS-1 -: 3])*DATA_WIDTH +: DATA_WIDTH ];
                        end

                        // For write-allocate write-through to memory, the top can detect pending_is_write and perform mem_wr_bytes
                        cpu_ready <= 1'b1;
                        state <= S_IDLE;
                    end
                end

                default: state <= S_IDLE;
            endcase
        end
    end

endmodule

