`include "../define.sv"

module aes(
    input logic clk_i,
    input logic rst_ni,
    
    input logic cs_i,
    input logic we_i,
    
    input logic [7:0] addr_i,
    input logic [31:0] wdata_i,
    output logic [31:0] rdata_o
    );
    
    logic init_reg;
    logic init_new;
    
    logic next_reg;
    logic next_new;
    
    logic encdec_reg;
    logic config_we;
    
    logic [31:0] block_reg [0:3];
    logic block_we;
    
    logic [31:0] key_reg [0:3];
    logic key_we;
    
    logic [127:0] result_reg;
    logic valid_reg;
    logic ready_reg;
    
logic [31:0] tmp_read_data;

logic core_encdec;
logic core_init;
logic core_next;
logic core_ready;
logic [127:0] core_key;
logic [127:0] core_block;
logic [127 : 0] core_result;
logic core_valid;

assign rdata_o = tmp_read_data;
assign core_key = {key_reg[0],key_reg[1],key_reg[2],key_reg[3]};
assign core_block = {block_reg[0],block_reg[1],block_reg[2],block_reg[3]};
assign core_init = init_reg;
assign core_next = next_reg;
assign core_encdec = encdec_reg;

aes_core core (.clk_i           (clk_i),
               .rst_ni          (rst_ni),
               .encdec_i        (core_encdec),
               .init_i          (core_init),
               .next_i          (core_next),
               .ready_o         (core_ready),
               .key_i           (core_key),
               .block_i         (core_block),
               .result_o        (core_result),
               .result_valid_o  (core_valid));
               
               
always_ff @(posedge clk_i) begin
    if (!rst_ni) begin
        for (int i = 0; i < 4; i++)
            block_reg[i] <= 32'h0;
        for (int i = 0; i < 4; i++) 
            key_reg[i]   <= 32'h0;
            
        init_reg    <= 1'b0;
        next_reg    <= 1'b0;
        encdec_reg  <= 1'b0;
        result_reg  <= 1'b0; 
        valid_reg   <= 1'b0;
        ready_reg   <= 1'b0;
    end
    else begin
        init_reg    <= init_new;
        next_reg    <= next_new;
        ready_reg   <= core_ready;
        valid_reg   <= core_valid;
        result_reg  <= core_result;
        
        if (config_we) 
            encdec_reg <= wdata_i[`CTRL_ENCDEC_BIT];
            
        if (key_we)
            key_reg[addr_i[1:0]] <= wdata_i;
        
        if (block_we)
            block_reg[addr_i[1:0]] <= wdata_i;
            
    end
end

always_comb begin
    init_new = 1'b0;
    next_new = 1'b0;
    config_we = 1'b0;
    key_we = 1'b0;
    block_we = 1'b0;
    tmp_read_data = 32'h0;
    
    if (cs_i) begin
        if (we_i) begin
            if (addr_i == `ADDR_CTRL) begin
                init_new = wdata_i[`CTRL_INIT_BIT];
                next_new = wdata_i[`CTRL_NEXT_BIT];
            end
            
            if (addr_i == `ADDR_CONFIG) 
                config_we = 1'b1;
      
            if ((addr_i >= `ADDR_BLOCK0) && (addr_i <= `ADDR_BLOCK3)) 
                block_we = 1'b1;
            
            if ((addr_i >= `ADDR_KEY0) && (addr_i <= `ADDR_KEY3))
                key_we = 1'b1;
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
endmodule
