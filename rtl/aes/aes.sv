`include "../define.sv"

module aes(
    input logic clk_i,
    input logic rst_ni,
    
    input logic cs_i,
    input logic we_i,
    
    input logic [31:0] addr_i,
    input logic [31:0] wdata_i,
    output logic [31:0] rdata_o,
    output logic aes_intr
    );
    logic [3:0] on_reg;
    logic on_we;

    logic start_reg;
    logic start_we;

    logic [3:0] init_reg ;
    logic [3:0] init_w;
    
    logic [3:0] next_reg ;
    logic [3:0] next_w;
    
    logic [3:0] encdec_reg ;
    logic config_we;
    
    logic [31:0] block0_reg [0:3];
    logic [3:0]  block0_we;
    logic [31:0] block1_reg [0:3];
    logic [3:0]  block1_we;
    logic [31:0] block2_reg [0:3];
    logic [3:0]  block2_we;
    logic [31:0] block3_reg [0:3];
    logic [3:0]  block3_we;

    logic [31:0] key0_reg [0:3];
    logic [3:0]  key0_we;
    logic [31:0] key1_reg [0:3];
    logic [3:0]  key1_we;
    logic [31:0] key2_reg [0:3];
    logic [3:0]  key2_we;
    logic [31:0] key3_reg [0:3];
    logic [3:0]  key3_we;
    
    logic [31:0] result0_reg [0:3];
    logic [31:0] result0_reg [0:3];
    logic [31:0] result0_reg [0:3];
    logic [31:0] result0_reg [0:3];

    logic [3:0] valid_reg;
    logic [3:0] ready_reg;
    
logic [31:0] tmp_read_data;

logic core_encdec;
logic core_init;
logic core_next;
logic core_ready;
logic [127:0] core_key;
logic [127:0] core_block;
logic [127:0] core_result;
logic core_valid;

assign rdata_o      = tmp_read_data;
assign core_key     = {key_reg[0],key_reg[1],key_reg[2],key_reg[3]};
assign core_block   = {block_reg[0],block_reg[1],block_reg[2],block_reg[3]};
assign core_on      = on_reg;
assign core_encdec  = encdec_reg;

aes_core core (.clk_i           (clk_i),
               .rst_ni          (rst_ni),
               .encdec_i        (core_encdec),
               .on_i            (core_on),
               .ready_o         (core_ready),
               .key_i           (core_key),
               .block_i         (core_block),
               .result_o        (core_result),
               .result_valid_o  (core_valid));
                  

always_ff @(posedge clk_i) begin
    if (!rst_ni) begin
        for (int i = 0; i < 4; i++) begin
            block0_reg [i] <= 32'h0;
            block1_reg [i] <= 32'h0;
            block2_reg [i] <= 32'h0;
            block3_reg [i] <= 32'h0;
            key0_reg [i]   <= 32'h0;
            key1_reg [i]   <= 32'h0;
            key2_reg [i]   <= 32'h0;
            key3_reg [i]   <= 32'h0;
        end   
        encdec_reg  <= '0;
        result_reg  <= '0; 
        valid_reg   <= '0;
        ready_reg   <= '0;
        on_reg      <= '0;
    end
    else begin
        start_reg   <= start_new;
        ready_reg   <= core_ready;
        valid_reg   <= core_valid;
        result_reg  <= core_result;
        
        if (config_we) 
            encdec_reg  <= wdata_i[`CTRL_ENCDEC3_BIT:`CTRL_ENCDEC0_BIT];
        if (on_we)
            on_reg      <= wdata_i[`CTRL_ON3_BIT:`CTRL_ON0_BIT];

        if (key_we[0])
            key0_reg[addr_i[1:0]] <= wdata_i;
        else if (key_we[1])
            key1_reg[addr_i[1:0]] <= wdata_i;
        else if (key_we[2])
            key2_reg[addr_i[1:0]] <= wdata_i;
        else if (key_we[3])
            key3_reg[addr_i[1:0]] <= wdata_i;

        if (block_we[0])
            block0_reg[addr_i[1:0]] <= wdata_i;
        else if (block_we[1])
            block1_reg[addr_i[1:0]] <= wdata_i;
        else if (block_we[2])
            block2_reg[addr_i[1:0]] <= wdata_i;
        else if (block_we[3])
            block3_reg[addr_i[1:0]] <= wdata_i;
        
    end
end

always_comb begin
    start_new   = 1'b0;
    on_we       = 1'b0;
    config_we   = 1'b0;
    key_we      = 3'b0;
    block_we    = 3'b0;
    tmp_read_data = 32'h0;
    
    if (cs_i) begin
        if (we_i) begin
            if (addr_i == `ADDR_CTRL) begin
                on_we = 1'b1;
            end
            
            if (addr_i == `ADDR_CONFIG) 
                config_we = 1'b1;
      
            if ((addr_i >= `ADDR_BLOCK0) && (addr_i < `ADDR_BLOCK1)) 
                block_we[0] = 1'b1;
            else if ((addr_i >= `ADDR_BLOCK1) && (addr_i < `ADDR_BLOCK2)) 
                block_we[1] = 1'b1;
            else if ((addr_i >= `ADDR_BLOCK2) && (addr_i < `ADDR_BLOCK3)) 
                block_we[2] = 1'b1;
            else if ((addr_i >= `ADDR_BLOCK3) && (addr_i < `ADDR_KEY0))             
                block_we[3] = 1'b1;

            if ((addr_i >= `ADDR_KEY0) && (addr_i <= `ADDR_KEY1))
                key_we[0] = 1'b1;
            else if ((addr_i >= `ADDR_KEY1) && (addr_i <= `ADDR_KEY2))
                key_we[1] = 1'b1;
            else if ((addr_i >= `ADDR_KEY2) && (addr_i <= `ADDR_KEY3))
                key_we[2] = 1'b1;
            else if ((addr_i >= `ADDR_KEY3) && (addr_i <= `ADDR_RESULT0))
                key_we[3] = 1'b1;

            if (addr_i == `ADDR_START)
                start_new = wdata_i[`START_BIT];
        end
        else begin
            case (addr_i)
                `ADDR_CTRL:   tmp_read_data = {29'h0, encdec_reg, next_reg, init_reg};
                `ADDR_STATUS: tmp_read_data = {30'h0, valid_reg, ready_reg};
                default: ;
            endcase
            if ((addr_i >= `ADDR_RESULT0) && (addr_i <= `ADDR_RESULT3))
                tmp_read_data = result_reg[(3 - (addr_i - `ADDR_RESULT0)) * 32 +: 32];
        end
    end
end

assign aes_intr = valid_reg;
endmodule
