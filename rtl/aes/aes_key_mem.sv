`include "define.sv"
module aes_key_mem(
    input  logic clk_i,
    input  logic rst_ni,
    
    input  logic [127:0] key_i,
    input  logic init_i,
    
    input  logic [3:0] round_i,
    output logic [127:0] round_key_o,
    output logic ready_o,
      
    output logic [31:0] sbox_o,
    input  logic [31:0] sbox_i
    );
    
localparam CTRL_IDLE     = 3'h0;
localparam CTRL_INIT     = 3'h1;
localparam CTRL_GENERATE = 3'h2;
localparam CTRL_DONE     = 3'h3;
 
//////////////////////////////////////
///declare
//////////////////////////////////////
logic [127 : 0] key_mem [0 : 10];
logic [127 : 0] key_mem_new;
logic           key_mem_we;

logic [127 : 0] prev_key_reg;
logic [127 : 0] prev_key_new;
logic           prev_key_we;

logic [3 : 0] round_ctr_reg;
logic [3 : 0] round_ctr_new;
logic         round_ctr_rst;
logic         round_ctr_inc;
logic         round_ctr_we;

logic [2 : 0] key_mem_ctrl_reg;
logic [2 : 0] key_mem_ctrl_new;
logic         key_mem_ctrl_we;

logic         ready_reg;
logic         ready_new;
logic         ready_we;

logic [7 : 0] rcon_reg;
logic [7 : 0] rcon_new;
logic         rcon_we;
logic         rcon_set;
logic         rcon_next;

logic [31 : 0]  tmp_sboxw;
logic           round_key_update;
logic [127 : 0] tmp_round_key;

assign round_key_o = tmp_round_key;
assign ready_o     = ready_reg;
assign sbox_o      = tmp_sboxw;

always_ff @(posedge clk_i) begin
    if (!rst_ni) begin
        for (int i = 0; i <= `AES_ROUND; i=i+1)
            key_mem[i] <= 128'h0;
            
        ready_reg        <= 1'b0;
        rcon_reg         <= 8'h0;
        round_ctr_reg    <= 4'h0;
        prev_key_reg    <= 128'h0;
        key_mem_ctrl_reg <= CTRL_IDLE;
    end
    else begin
        if (ready_we)
            ready_reg <= ready_new;
            
        if (rcon_we)
            rcon_reg <= rcon_new;
            
        if (round_ctr_we)
            round_ctr_reg <= round_ctr_new;
        
        if (key_mem_we)
            key_mem [round_ctr_reg] <= key_mem_new;
        
        if (prev_key_we)
            prev_key_reg <= prev_key_new;
            
        if (key_mem_ctrl_we)
            key_mem_ctrl_reg <= key_mem_ctrl_new;
    end
end

assign tmp_round_key = key_mem[round_i];

//////////////////////////////////////////////////////
// round_key_gen: the round key generator logic for AES-128 
//////////////////////////////////////////////////////
logic [31:0] w0,w1,w2,w3;
logic [31:0] k0,k1,k2,k3;
logic [31:0] rconw,rotstw,trw;

always_comb begin
    key_mem_new   = 128'h0;
    key_mem_we    = 1'b0;
    prev_key_new = 128'h0;
    prev_key_we  = 1'b0;
    
    k0 = 32'h0;
    k1 = 32'h0;
    k2 = 32'h0;
    k3 = 32'h0;
    
    rcon_set  = 1'b1;  
    rcon_next = 1'b0;
    
    w0 = prev_key_reg[127 : 096];
    w1 = prev_key_reg[095 : 064];
    w2 = prev_key_reg[063 : 032];
    w3 = prev_key_reg[031 : 000];
    
    
    rconw = {rcon_reg, 24'h0};
    tmp_sboxw = w3;
    rotstw = {sbox_i[23 : 00], sbox_i[31 : 24]};
    trw = rotstw ^ rconw;
    
    if (round_key_update) begin
        rcon_set   = 1'b0;
        key_mem_we = 1'b1;
        if (round_ctr_reg == 0) begin
            key_mem_new  = key_i;
            prev_key_new = key_i;
            prev_key_we  = 1'b1;
            rcon_next    = 1'b1;
        end
        else begin
            k0 = w0 ^ trw;
            k1 = w1 ^ w0 ^ trw;
            k2 = w2 ^ w1 ^ w0 ^ trw;
            k3 = w3 ^ w2 ^ w1 ^ w0 ^ trw;
            
            key_mem_new  = {k0, k1, k2, k3};
            prev_key_new = {k0, k1, k2, k3};
            prev_key_we  = 1'b1;
            rcon_next = 1'b1;
        end
    end
end

/////////////////////////////////////////////
/// rcon
/////////////////////////////////////////////
logic [7 : 0] tmp_rcon;
always_comb begin
    rcon_new = 8'h00;
    rcon_we  = 1'b0;
    
    tmp_rcon = {rcon_reg[6 : 0], 1'b0} ^ (8'h1b & {8{rcon_reg[7]}});
    
    if (rcon_set)begin
        rcon_new = 8'h8d;
        rcon_we  = 1'b1;
    end
    
    if (rcon_next) begin
        rcon_new = tmp_rcon[7 : 0];
        rcon_we  = 1'b1;
    end
end
//////////////////////////////////////////////

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
    ready_new        = 1'b0;
    ready_we         = 1'b0;
    round_key_update = 1'b0;
    round_ctr_rst    = 1'b0;
    round_ctr_inc    = 1'b0;
    key_mem_ctrl_new = CTRL_IDLE;
    key_mem_ctrl_we  = 1'b0;
    
    case (key_mem_ctrl_reg) 
        CTRL_IDLE: begin
            if(init_i) begin
                ready_new     = 1'b0;
                ready_we      = 1'b1;
                key_mem_ctrl_new  = CTRL_INIT;
                key_mem_ctrl_we   = 1'b1;
            end
        end
        
        CTRL_INIT: begin
            round_ctr_rst    = 1'b1;
            key_mem_ctrl_new = CTRL_GENERATE;
            key_mem_ctrl_we  = 1'b1;
        end
        
        CTRL_GENERATE: begin
            round_ctr_inc    = 1'b1;
            round_key_update = 1'b1;
            if (round_ctr_reg == `AES_ROUND) begin
                key_mem_ctrl_new = CTRL_DONE;
                key_mem_ctrl_we  = 1'b1;
            end
        end
        
        CTRL_DONE: begin
            ready_new        = 1'b1;
            ready_we         = 1'b1;
            key_mem_ctrl_new = CTRL_IDLE;
            key_mem_ctrl_we  = 1'b1;
            end
        
        default: ;
        endcase
end
endmodule
