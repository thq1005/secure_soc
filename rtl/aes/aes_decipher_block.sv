`include "../define.sv"

module aes_decipher_block(
    input logic clk_i,
    input logic rst_ni,
    
    input logic next_i,
    
    output logic [3:0] round_o,
    input logic [`KEY_WIDTH-1:0] round_key_i,
    
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
logic round_ctr_dec;
logic round_ctr_set;

logic [1:0] sword_ctr_reg;
logic sword_ctr_we;
logic [1:0] sword_ctr_new;
logic sword_ctr_rst;
logic sword_ctr_inc;

logic [1:0] dec_ctrl_reg;
logic dec_ctrl_we;
logic [1:0] dec_ctrl_new;

logic [31:0] tmp_sboxw;
logic [31:0] new_sboxw;

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
assign new_block_o = {block_w0_reg,block_w1_reg,block_w2_reg,block_w3_reg};
assign ready_o   = ready_reg;

aes_inv_sbox inv_sbox (.in  (tmp_sboxw),
                       .out (new_sboxw));
                       
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
        dec_ctrl_reg  <= CTRL_IDLE;
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
        
        if (dec_ctrl_we)
            dec_ctrl_reg <= dec_ctrl_new;
    end
end
////////////////////////////////////////////


////////////////////////////////////////////////////
//// round logic
////////////////////////////////////////////////////
logic [127:0] old_block, inv_shiftrows_block, inv_mixcolumns_block;
logic [127:0] addkey_block;
logic [2:0] update_type;

logic [127:0] inv_shiftrows_i;
logic [127:0] inv_mixcolumns_i;

inv_shiftrows inv_shiftrows_init   (.in  (inv_shiftrows_i),
                                    .out (inv_shiftrows_block));

inv_mixcolumns inv_mixcolumns_init (.in  (inv_mixcolumns_i),
                                    .out (inv_mixcolumns_block));

always_comb begin
    block_new            = '0;
    addkey_block         = '0;
    tmp_sboxw            = '0;
    block_w0_we          = '0;
    block_w1_we          = '0;
    block_w2_we          = '0;
    block_w3_we          = '0;
    inv_shiftrows_i      = '0;
    inv_mixcolumns_i      = '0;
    old_block          = {block_w0_reg, block_w1_reg, block_w2_reg, block_w3_reg};
    
    case(update_type)
        INIT_UPDATE: begin
            old_block = block_i;
            addkey_block = old_block ^ round_key_i;
            inv_shiftrows_i = addkey_block;
            block_new = inv_shiftrows_block;
            block_w0_we  = 1'b1;
            block_w1_we  = 1'b1;
            block_w2_we  = 1'b1;
            block_w3_we  = 1'b1;
        end
        SBOX_UPDATE: begin
            block_new = {new_sboxw,new_sboxw,new_sboxw,new_sboxw};
            
            case (sword_ctr_reg)
                2'h0: begin
                    tmp_sboxw = block_w0_reg;
                    block_w0_we = 1'b1;
                end
                2'h1: begin
                    tmp_sboxw = block_w1_reg;
                    block_w1_we = 1'b1;
                end
                2'h2: begin
                    tmp_sboxw = block_w2_reg;
                    block_w2_we = 1'b1;
                end
                2'h3: begin
                    tmp_sboxw = block_w3_reg;
                    block_w3_we = 1'b1;
                end
            endcase                    
        end
        
        MAIN_UPDATE: begin
            addkey_block = old_block ^ round_key_i;
            inv_mixcolumns_i = addkey_block;
            inv_shiftrows_i = inv_mixcolumns_block;
            block_new = inv_shiftrows_block;
            block_w0_we  = 1'b1;
            block_w1_we  = 1'b1;
            block_w2_we  = 1'b1;
            block_w3_we  = 1'b1;
        end
        
        FINAL_UPDATE: begin
            block_new    = old_block ^ round_key_i;
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
    
    if (round_ctr_set) begin
        round_ctr_new = `AES_ROUND;
        round_ctr_we  = 1'h1;
    end
    else if (round_ctr_dec) begin
        round_ctr_new = round_ctr_reg - 1'b1;
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
    round_ctr_dec = 1'b0;
    round_ctr_set = 1'b0;
    ready_new     = 1'b0;
    ready_we      = 1'b0;
    update_type   = NO_UPDATE;
    dec_ctrl_new  = CTRL_IDLE;
    dec_ctrl_we   = 1'b0;
    
    case (dec_ctrl_reg) 
        CTRL_IDLE: begin
            if(next_i) begin
                round_ctr_set = 1'b1;
                ready_new     = 1'b0;
                ready_we      = 1'b1;
                dec_ctrl_new  = CTRL_INIT;
                dec_ctrl_we   = 1'b1;
            end
        end
        
        CTRL_INIT: begin
            sword_ctr_rst = 1'b1;
            update_type   = INIT_UPDATE;
            dec_ctrl_new  = CTRL_SBOX;
            dec_ctrl_we   = 1'b1;
        end
        
        CTRL_SBOX: begin
            sword_ctr_inc = 1'b1;
            update_type = SBOX_UPDATE;
            if (sword_ctr_reg == 2'h3) begin
                round_ctr_dec = 1'b1;
                dec_ctrl_new = CTRL_MAIN;
                dec_ctrl_we  = 1'b1;
            end  
        end
        
        CTRL_MAIN: begin
            sword_ctr_rst = 1'b1;
            if (round_ctr_reg > 0) begin
                update_type  = MAIN_UPDATE;
                dec_ctrl_new = CTRL_SBOX;
                dec_ctrl_we  = 1'b1; 
            end 
            else begin
                update_type  = FINAL_UPDATE;
                ready_new    = 1'b1;
                ready_we     = 1'b1;
                dec_ctrl_new = CTRL_IDLE;
                dec_ctrl_we  = 1'b1; 
            end
        
        end
        
        default: ;
        endcase
end
////////////////////////////////////////////////////
endmodule
