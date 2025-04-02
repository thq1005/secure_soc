`include "../define.sv"

module aes(
    input logic clk_i,
    input logic rst_ni,
    
    input logic cs_i,
    input logic we_i,
    
    input logic [31:0] addr_i,
    input logic [31:0] wdata_i,
    output logic [31:0] rdata_o,
    output logic aes_irq,
    input logic aes_clear_irq
    );
    logic [3:0] on_reg;
    logic on_we;

    logic start_reg;
    logic start_new;

    
    logic [3:0] encdec_reg ;
    logic config_we;
    
    logic [31:0] block0_reg [0:3];
    logic [31:0] block1_reg [0:3];
    logic [31:0] block2_reg [0:3];
    logic [31:0] block3_reg [0:3];
    logic [3:0]  block_we;

    logic [31:0] key0_reg [0:3];
    logic [31:0] key1_reg [0:3];
    logic [31:0] key2_reg [0:3];
    logic [31:0] key3_reg [0:3];
    logic [3:0]  key_we;

    logic [127:0] result0_reg ;
    logic [127:0] result1_reg ;
    logic [127:0] result2_reg ;
    logic [127:0] result3_reg ;

    logic valid0_reg;
    logic valid1_reg;
    logic valid2_reg;
    logic valid3_reg;
    
    logic ready_reg;
    logic [31:0] tmp_read_data;
    
    logic core_on;
    logic core_encdec;
    logic [127:0] core_key;
    logic [127:0] core_block;
    logic [127:0] core_result;
    logic core_valid;
    
    logic [2:0] state;
    logic [2:0] next_state; 

always_ff @(posedge clk_i) begin
    if (~rst_ni) begin
        state <= 3'b000;
    end
    else begin
        state <= next_state;
    end
end

always_comb begin
    case (state)
    3'b000: if (start_reg) begin
        next_state = 3'b001;
    end
    3'b001: if ((valid0_reg && on_reg[0]) | ~on_reg[0]) begin
        next_state = 3'b010;
    end 
    3'b010: if ((valid1_reg && on_reg[1]) | ~on_reg[1]) begin
        next_state = 3'b011;
    end
    3'b011: if ((valid2_reg && on_reg[2]) | ~on_reg[2]) begin
        next_state = 3'b100;
    end
    3'b100: if ((valid3_reg && on_reg[3]) | ~on_reg[3]) begin
        next_state = 3'b000;
    end
    default: next_state = 3'b000;
    endcase
end

always_ff @(posedge clk_i) begin
    if(~rst_ni) begin
        core_on <= 0;
    end
    else if (next_state == 3'b001 & state == 3'b000) begin
        core_on <= on_reg[0];
    end
    else if (next_state == 3'b010 & state == 3'b001) begin
        core_on <= on_reg[1];
    end
    else if (next_state == 3'b011 & state == 3'b010) begin
        core_on <= on_reg[2];
    end
    else if (next_state == 3'b100 & state == 3'b011) begin
        core_on <= on_reg[3];
    end
    else 
        core_on <= 0;
end


assign rdata_o      = tmp_read_data;
assign core_key     =   (state == 3'b001) ? {key0_reg[0],key0_reg[1],key0_reg[2],key0_reg[3]} :
                        (state == 3'b010) ? {key1_reg[0],key1_reg[1],key1_reg[2],key1_reg[3]} :
                        (state == 3'b011) ? {key2_reg[0],key2_reg[1],key2_reg[2],key2_reg[3]} :
                        (state == 3'b100) ? {key3_reg[0],key3_reg[1],key3_reg[2],key3_reg[3]} : 128'h0;

assign core_block   =   (state == 3'b001) ? {block0_reg[0],block0_reg[1],block0_reg[2],block0_reg[3]} :
                        (state == 3'b010) ? {block1_reg[0],block1_reg[1],block1_reg[2],block1_reg[3]} :
                        (state == 3'b011) ? {block2_reg[0],block2_reg[1],block2_reg[2],block2_reg[3]} :
                        (state == 3'b100) ? {block3_reg[0],block3_reg[1],block3_reg[2],block3_reg[3]} : 128'h0;


assign core_encdec  =   (state == 3'b001) ? encdec_reg[0] :
                        (state == 3'b010) ? encdec_reg[1] :
                        (state == 3'b011) ? encdec_reg[2] :
                        (state == 3'b100) ? encdec_reg[3] : 1'b0;

aes_core core (.clk_i           (clk_i),
               .rst_ni          (rst_ni),
               .encdec_i        (core_encdec),
               .on_i            (core_on),
               .ready_o         (),
               .key_i           (core_key),
               .block_i         (core_block),
               .result_o        (core_result),
               .result_valid_o  (core_valid));
                  

logic [1:0] num;
always_comb begin
    num = 2'b0;
    if (addr_i[3:2] == 2'b00)
        num = 0;
    else if (addr_i[3:2] == 2'b01)
        num = 3;
    else if (addr_i[3:2] == 2'b10)
        num = 2;
    else if (addr_i[3:2] == 2'b11)
        num = 1;
end

always_ff @(posedge clk_i) begin
    if (~rst_ni) begin
        result0_reg <= 128'h0;
        result1_reg <= 128'h0;
        result2_reg <= 128'h0;
        result3_reg <= 128'h0;
    end
    else if (state == 3'b001 && core_valid)
        result0_reg <= core_result;
    else if (state == 3'b010 && core_valid)
        result1_reg <= core_result;
    else if (state == 3'b011 && core_valid)
        result2_reg <= core_result;
    else if (state == 3'b100 && core_valid)
        result3_reg <= core_result;
end 

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
        valid0_reg   <= '0;
        valid1_reg   <= '0;
        valid2_reg   <= '0;
        valid3_reg   <= '0;
        on_reg      <= '0;
    end
    else begin
        start_reg   <= start_new;
        
        if (state == 3'b000)
            ready_reg <= 1;
        else 
            ready_reg <= 0;

        if (state == 3'b001 && ~valid0_reg)
            valid0_reg  <= core_valid;
        else if (state == 3'b010 && ~valid1_reg)
            valid1_reg  <= core_valid;
        else if (state == 3'b011 && ~valid2_reg)
            valid2_reg  <= core_valid;
        else if (state == 3'b100 && ~valid3_reg)
            valid3_reg  <= core_valid;
        else if (start_reg) begin
            valid0_reg  <= 0;
            valid1_reg  <= 0;
            valid2_reg  <= 0;
            valid3_reg  <= 0;
        end
        
        if (config_we) 
            encdec_reg  <= wdata_i[`CTRL_ENCDEC3_BIT:`CTRL_ENCDEC0_BIT];
        if (on_we)
            on_reg      <= wdata_i[`CTRL_ON3_BIT:`CTRL_ON0_BIT];

        if (key_we[0])
            key0_reg[num] <= wdata_i;
        else if (key_we[1])
            key1_reg[num] <= wdata_i;
        else if (key_we[2])
            key2_reg[num] <= wdata_i;
        else if (key_we[3])
            key3_reg[num] <= wdata_i;

        if (block_we[0])
            block0_reg[num] <= wdata_i;
        else if (block_we[1])
            block1_reg[num] <= wdata_i;
        else if (block_we[2])
            block2_reg[num] <= wdata_i;
        else if (block_we[3])
            block3_reg[num] <= wdata_i;
        
    end
end

logic valid_w;
assign valid_w = (valid0_reg == on_reg[0] && valid1_reg == on_reg[1] && valid2_reg == on_reg[2] && valid3_reg == on_reg[3] &&(valid1_reg | valid2_reg | valid3_reg | valid0_reg));

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

            if ((addr_i >= `ADDR_KEY0) && (addr_i < `ADDR_KEY1))
                key_we[0] = 1'b1;
            else if ((addr_i >= `ADDR_KEY1) && (addr_i < `ADDR_KEY2))
                key_we[1] = 1'b1;
            else if ((addr_i >= `ADDR_KEY2) && (addr_i < `ADDR_KEY3))
                key_we[2] = 1'b1;
            else if ((addr_i >= `ADDR_KEY3) && (addr_i < `ADDR_RESULT0))
                key_we[3] = 1'b1;

            if (addr_i == `ADDR_START)
                start_new = wdata_i[`START_BIT];
        end
        else begin
            if (addr_i == `ADDR_STATUS)
                tmp_read_data = {30'h0, valid_w, ready_reg};
            if ((addr_i >= `ADDR_RESULT0) && (addr_i < `ADDR_RESULT1)) begin
                if (addr_i[3:2]==2'b01)
                    tmp_read_data = result0_reg[127:96];
                else if (addr_i[3:2]==2'b10)
                    tmp_read_data = result0_reg[95:64];
                else if (addr_i[3:2]==2'b11)
                    tmp_read_data = result0_reg[63:32];
                else if (addr_i[3:2]==2'b00)
                    tmp_read_data = result0_reg[31:0];
            end
            else if ((addr_i >= `ADDR_RESULT1) && (addr_i < `ADDR_RESULT2)) begin
                if (addr_i[3:2]==2'b01)
                    tmp_read_data = result1_reg[127:96];
                else if (addr_i[3:2]==2'b10)
                    tmp_read_data = result1_reg[95:64];
                else if (addr_i[3:2]==2'b11)
                    tmp_read_data = result1_reg[63:32];
                else if (addr_i[3:2]==2'b00)
                    tmp_read_data = result1_reg[31:0];
            end
            else if ((addr_i >= `ADDR_RESULT2) && (addr_i < `ADDR_RESULT3)) begin
                if (addr_i[3:2]==2'b01)
                    tmp_read_data = result2_reg[127:96];
                else if (addr_i[3:2]==2'b10)
                    tmp_read_data = result2_reg[95:64];
                else if (addr_i[3:2]==2'b11)
                    tmp_read_data = result2_reg[63:32];
                else if (addr_i[3:2]==2'b00)
                    tmp_read_data = result2_reg[31:0];
            end
            else if ((addr_i >= `ADDR_RESULT3)) begin
                if (addr_i[3:2]==2'b01)
                    tmp_read_data = result3_reg[127:96];
                else if (addr_i[3:2]==2'b10)
                    tmp_read_data = result3_reg[95:64];
                else if (addr_i[3:2]==2'b11)
                    tmp_read_data = result3_reg[63:32];
                else if (addr_i[3:2]==2'b00)
                    tmp_read_data = result3_reg[31:0];
            end
        end
    end
end



logic intr_reg;

always_ff @(posedge clk_i) begin
    if(~rst_ni) begin
        intr_reg <= 1'b0;
    end
    else if (valid_w) begin
        intr_reg <= 1'b1;
    end
    else if (aes_clear_irq) begin
        intr_reg <= 1'b0;
    end
end

assign aes_irq = intr_reg;
endmodule
