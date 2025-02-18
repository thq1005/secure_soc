`include "../define.sv"

module aes_encipher_block(
    input logic clk_i,
    input logic rst_ni,
    
    input logic next_i,
    
    output logic [3:0] round_o,
    input logic [`KEY_WIDTH-1:0] round_key_i,
    
    output logic [31:0] sbox_o,
    input logic [31:0] sbox_i,
    
    input logic [127:0] block_i,
    output logic [127:0] new_block_o,
    output logic ready_o
    );
    
    localparam CTRL_IDLE = 2'h0;
    localparam CTRL_INIT = 2'h1;
    localparam CTRL_SBOX = 2'h2;
    localparam CTRL_MAIN = 2'h3;
 
    localparam NO_UPDATE    = 3'h0;
    localparam INIT_UPDATE  = 3'h1;
    localparam SBOX_UPDATE  = 3'h2;
    localparam MAIN_UPDATE  = 3'h3;
    localparam FINAL_UPDATE = 3'h4; 

////////////////////////////////////////////
/// declare
////////////////////////////////////////////

logic [3:0] round_ctr_reg;
logic round_ctr_we;
logic [3:0] round_ctr_new;
logic round_ctr_inc;
logic round_ctr_rst;

logic [1:0] sword_ctr_reg;
logic sword_ctr_we;
logic [1:0] sword_ctr_new;
logic sword_ctr_rst;
logic sword_ctr_inc;

logic [1:0] enc_ctrl_reg;
logic enc_ctrl_we;
logic [1:0] enc_ctrl_new;

logic [31:0] muxed_sboxw;

logic [31:0] block_w0_reg;
logic [31:0] block_w1_reg;
logic [31:0] block_w2_reg;
logic [31:0] block_w3_reg;
logic [127:0] block_new;
logic block_w0_we;
logic block_w1_we;
logic block_w2_we;
logic block_w3_we;

logic ready_reg;
logic ready_we;
logic ready_new;

assign round_o   = round_ctr_reg;
assign sbox_o    = muxed_sboxw;
assign new_block_o = {block_w0_reg,block_w1_reg,block_w2_reg,block_w3_reg};
assign ready_o   = ready_reg;

//////////////////////////////////////////////////
/// reg update
//////////////////////////////////////////////////

always_ff @(posedge clk_i) begin
    if (!rst_ni) begin
        block_w0_reg  <= 32'h0;
        block_w1_reg  <= 32'h0;
        block_w2_reg  <= 32'h0;
        block_w3_reg  <= 32'h0;
        sword_ctr_reg <= 2'h0;
        round_ctr_reg <= 4'h0;
        ready_reg     <= 1'b1;
        enc_ctrl_reg  <= CTRL_IDLE;
    end
    else begin
        if (block_w0_we)
            block_w0_reg <= block_new[127:96];
        if (block_w1_we)
            block_w1_reg <= block_new[95:64];
        if (block_w2_we)
            block_w2_reg <= block_new[63:32];
        if (block_w3_we)
            block_w3_reg <= block_new[31:0];
            
        if (sword_ctr_we)
            sword_ctr_reg <= sword_ctr_new;
        
        if (round_ctr_we)
            round_ctr_reg <= round_ctr_new;
            
        if (ready_we)
            ready_reg <= ready_new;
        
        if (enc_ctrl_we)
            enc_ctrl_reg <= enc_ctrl_new;
    end
end
////////////////////////////////////////////


////////////////////////////////////////////////////
//// round logic
////////////////////////////////////////////////////
logic [127:0] old_block, shiftrows_block, mixcolumns_block;
logic [127:0] addkey_init_block, addkey_main_block, addkey_final_block;
logic [2:0] update_type;

shiftrows shiftrows (.in  (old_block),
                     .out (shiftrows_block));

mixcolumns mixcolumns (.in  (shiftrows_block),
                       .out (mixcolumns_block));
                       
                       

always_comb begin
    block_new   = '0;
    muxed_sboxw = '0;
    block_w0_we = '0;
    block_w1_we = '0;
    block_w2_we = '0;
    block_w3_we = '0;
    
    old_block          = {block_w0_reg, block_w1_reg, block_w2_reg, block_w3_reg};
    addkey_init_block  = block_i ^ round_key_i;
    addkey_main_block  = mixcolumns_block ^ round_key_i;
    addkey_final_block = shiftrows_block ^ round_key_i;
    
    case(update_type)
        INIT_UPDATE: begin
            block_new = addkey_init_block;
            block_w0_we  = 1'b1;
            block_w1_we  = 1'b1;
            block_w2_we  = 1'b1;
            block_w3_we  = 1'b1;
        end
        SBOX_UPDATE: begin
            block_new = {sbox_i,sbox_i,sbox_i,sbox_i};
            
            case (sword_ctr_reg)
                2'h0: begin
                    muxed_sboxw = block_w0_reg;
                    block_w0_we = 1'b1;
                end
                2'h1: begin
                    muxed_sboxw = block_w1_reg;
                    block_w1_we = 1'b1;
                end
                2'h2: begin
                    muxed_sboxw = block_w2_reg;
                    block_w2_we = 1'b1;
                end
                2'h3: begin
                    muxed_sboxw = block_w3_reg;
                    block_w3_we = 1'b1;
                end
            endcase                    
        end
        
        MAIN_UPDATE: begin
            block_new = addkey_main_block;
            block_w0_we  = 1'b1;
            block_w1_we  = 1'b1;
            block_w2_we  = 1'b1;
            block_w3_we  = 1'b1;
        end
        
        FINAL_UPDATE: begin
            block_new    = addkey_final_block;
            block_w0_we  = 1'b1;
            block_w1_we  = 1'b1;
            block_w2_we  = 1'b1;
            block_w3_we  = 1'b1;
        end
        
        default: ;
     endcase  
end
////////////////////////////////////////////////////

////////////////////////////////////////////////////
/// sword_ctr: The subbytes word counter with reset and increase logic
////////////////////////////////////////////////////
always_comb begin
    sword_ctr_new = 2'h0;
    sword_ctr_we  = 1'h0;
    
    if (sword_ctr_rst) begin
        sword_ctr_new = 2'h0;
        sword_ctr_we  = 1'h1;
    end
    else if (sword_ctr_inc) begin
        sword_ctr_new = sword_ctr_reg + 1'b1;
        sword_ctr_we  = 1'b1;
    end 
end
////////////////////////////////////////////////////

////////////////////////////////////////////////////
/// round_ctr: The round counter with reset and increase logic
////////////////////////////////////////////////////
always_comb begin
    round_ctr_new = 4'h0;
    round_ctr_we  = 1'h0;
    
    if (round_ctr_rst) begin
        round_ctr_new = 4'h0;
        round_ctr_we  = 1'h1;
    end
    else if (round_ctr_inc) begin
        round_ctr_new = round_ctr_reg + 1'b1;
        round_ctr_we  = 1'b1;
    end 
end
////////////////////////////////////////////////////

////////////////////////////////////////////////////
/// encipher_ctrl: The FSM that controls the encipher operations
////////////////////////////////////////////////////
always_comb begin
    sword_ctr_inc = 1'b0;
    sword_ctr_rst = 1'b0;
    round_ctr_inc = 1'b0;
    round_ctr_rst = 1'b0;
    ready_new     = 1'b0;
    ready_we      = 1'b0;
    update_type   = NO_UPDATE;
    enc_ctrl_new  = CTRL_IDLE;
    enc_ctrl_we   = 1'b0;
    
    case (enc_ctrl_reg) 
        CTRL_IDLE: begin
            if(next_i) begin
                round_ctr_rst = 1'b1;
                ready_new     = 1'b0;
                ready_we      = 1'b1;
                enc_ctrl_new  = CTRL_INIT;
                enc_ctrl_we   = 1'b1;
            end
        end
        
        CTRL_INIT: begin
            round_ctr_inc = 1'b1;
            sword_ctr_rst = 1'b1;
            update_type   = INIT_UPDATE;
            enc_ctrl_new  = CTRL_SBOX;
            enc_ctrl_we   = 1'b1;
        end
        
        CTRL_SBOX: begin
            sword_ctr_inc = 1'b1;
            update_type = SBOX_UPDATE;
            if (sword_ctr_reg == 2'h3) begin
                enc_ctrl_new = CTRL_MAIN;
                enc_ctrl_we  = 1'b1;
            end  
        end
        
        CTRL_MAIN: begin
            sword_ctr_rst = 1'b1;
            round_ctr_inc = 1'b1;
            if (round_ctr_reg < `AES_ROUND) begin
                update_type  = MAIN_UPDATE;
                enc_ctrl_new = CTRL_SBOX;
                enc_ctrl_we  = 1'b1; 
            end 
            else begin
                update_type  = FINAL_UPDATE;
                ready_new    = 1'b1;
                ready_we     = 1'b1;
                enc_ctrl_new = CTRL_IDLE;
                enc_ctrl_we  = 1'b1; 
            end
        
        end
        
        endcase
end
////////////////////////////////////////////////////
endmodule
