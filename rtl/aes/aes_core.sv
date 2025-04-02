`include "../define.sv"

module aes_core(
        input logic clk_i,
        input logic rst_ni,
        
        input logic encdec_i,
        input logic on_i,
        output logic ready_o,
        
        input logic [127:0] key_i,
        input logic [127:0] block_i,
        output logic [127:0] result_o,
        output logic result_valid_o
    );
    
localparam CTRL_IDLE = 2'h0;
localparam CTRL_INIT = 2'h1;
localparam CTRL_NEXT = 2'h2;

logic [1 : 0] aes_core_ctrl_reg;
logic [1 : 0] aes_core_ctrl_new;
logic         aes_core_ctrl_we;

logic         result_valid_reg;
logic         result_valid_new;

logic         ready_reg;
logic         ready_new;
logic         ready_we;
logic         init_state;


logic [127 : 0] round_key;
logic           key_ready;

logic           enc_next;
logic [3 : 0]   enc_round_nr;
logic [127 : 0] enc_new_block;
logic           enc_ready;
logic [31 : 0]  enc_sboxw;

logic            dec_next;
logic [3 : 0]   dec_round_nr;
logic [127 : 0] dec_new_block;
logic           dec_ready;

logic [127 : 0]  muxed_new_block;
logic [3 : 0]    muxed_round_nr;
logic            muxed_ready;

logic [31 : 0]  keymem_sboxw;

logic [31 : 0]   muxed_sboxw;
logic [31 : 0]  new_sboxw;

logic next_w;
logic next_r;
aes_encipher_block enc_block (.clk_i        (clk_i),
                              .rst_ni       (rst_ni),
                              .next_i       (enc_next),
                              .round_o      (enc_round_nr),
                              .round_key_i  (round_key),
                              .sbox_i       (new_sboxw),
                              .sbox_o       (enc_sboxw),
                              .block_i      (block_i),
                              .new_block_o  (enc_new_block),
                              .ready_o      (enc_ready));
                              
aes_decipher_block dec_block (.clk_i        (clk_i),
                              .rst_ni       (rst_ni),
                              .next_i       (dec_next),
                              .round_o      (dec_round_nr),
                              .round_key_i  (round_key),
                              .block_i      (block_i),
                              .new_block_o  (dec_new_block),
                              .ready_o      (dec_ready));
                              
aes_key_mem keymem (.clk_i        (clk_i),
                    .rst_ni       (rst_ni),
                    .key_i        (key_i),
                    .init_i       (on_i),
                    .round_i      (muxed_round_nr),
                    .round_key_o  (round_key),
                    .ready_o      (key_ready),
                    .sbox_o       (keymem_sboxw),
                    .sbox_i       (new_sboxw));             
                    
                    
aes_sbox sbox_inst (.in (muxed_sboxw),
                    .out(new_sboxw));
                    
                    
assign ready_o        = ready_reg;
assign result_o       = muxed_new_block;
assign result_valid_o = result_valid_reg;               

always_ff @(posedge clk_i) begin
    if(!rst_ni) begin
        result_valid_reg  <= 1'b0;
        ready_reg         <= 1'b1;
        aes_core_ctrl_reg <= CTRL_IDLE;
    end
    else begin
        result_valid_reg <= result_valid_new;
            
        if (ready_we)
            ready_reg <= ready_new;
            
        if (aes_core_ctrl_we)
            aes_core_ctrl_reg <= aes_core_ctrl_new;

    end 
end

always_comb begin
    if(init_state)
        muxed_sboxw = keymem_sboxw;
    else
        muxed_sboxw = enc_sboxw;        
end

///////////////////////////////////////////
/// encdec mux
///////////////////////////////////////////

always_comb begin
    enc_next = 1'b0;
    dec_next = 1'b0;
    if (encdec_i) begin
        //encipher
        enc_next        = next_r;
        muxed_round_nr  = enc_round_nr;
        muxed_new_block = enc_new_block;
        muxed_ready     = enc_ready;
    end
    else begin
        //decipher
        dec_next        = next_r;
        muxed_round_nr  = dec_round_nr;
        muxed_new_block = dec_new_block;
        muxed_ready     = dec_ready;
    end
end
    
///////////////////////////////////////////


always_ff @(posedge clk_i) begin
    if (~rst_ni) begin
        next_r <= 1'b0;
    end 
    else 
        next_r <= next_w;
end

always_comb begin
    init_state = 1'b0;
    ready_new  = 1'b0;
    ready_we   = 1'b0;
    result_valid_new = 1'b0;
    aes_core_ctrl_new = CTRL_IDLE;
    aes_core_ctrl_we  = 1'b0;
    next_w = 1'b0;

    case (aes_core_ctrl_reg)
    CTRL_IDLE: begin
        if (on_i) begin
            init_state = 1'b1;
            ready_new  = 1'b0;
            ready_we   = 1'b1;
            aes_core_ctrl_new = CTRL_INIT;
            aes_core_ctrl_we  = 1'b1;
        end
        else if (next_r) begin
            init_state       = 1'b0;
            ready_new        = 1'b0;
            ready_we         = 1'b1;
            result_valid_new = 1'b0;
            aes_core_ctrl_new= CTRL_NEXT;
            aes_core_ctrl_we = 1'b1;
        end
    end
    
    CTRL_INIT: begin
        init_state = 1'b1;
        if (key_ready) begin
            aes_core_ctrl_new= CTRL_IDLE;
            aes_core_ctrl_we = 1'b1;
            next_w = 1'b1;
        end
    end
    
    CTRL_NEXT: begin
        init_state = 1'b0;
        if (muxed_ready) begin
            ready_new = 1'b1;
            ready_we  = 1'b1;
            result_valid_new = 1'b1;
            aes_core_ctrl_new = CTRL_IDLE;
            aes_core_ctrl_we  = 1'b1;
        end
    end
    
    default: ;
    endcase
end

endmodule
