`include "../define.sv"

module arbiter(
    input  logic clk_i,
    input  logic rst_ni,
    //icache
    input  logic [`ADDR_WIDTH-1:0] i_addr_i,
    input  logic i_cs_i,
    input  logic [`DATA_WIDTH_CACHE-1:0] i_wdata_i,
    input  logic i_we_i,
    output logic [`DATA_WIDTH_CACHE-1:0] i_rdata_o,
    output logic i_rvalid_o,
    //mem
    input  logic [`ADDR_WIDTH-1:0] d_addr_i,
    input  logic d_cs_i,
    input  logic [`DATA_WIDTH_CACHE-1:0] d_wdata_i,
    input  logic d_we_i,
    output logic [`DATA_WIDTH_CACHE-1:0] d_rdata_o,
    output logic d_rvalid_o,

    output logic [`ADDR_WIDTH-1:0] addr_o,
    output logic [`DATA_WIDTH_CACHE-1:0] wdata_o,
    output logic we_o,
    output logic cs_o,
    input  logic [`DATA_WIDTH_CACHE-1:0] rdata_i,
    input  logic rvalid_i,
    input  logic handshaked_i
    );

    logic hs;
    
    typedef enum {IDLE, I_CACHE, MEM} arbiter_state_type;
    arbiter_state_type next_state, state;
    
    always_ff @(posedge clk_i) begin
        if (!rst_ni)
            hs = 0;
        else if (hs && ((state == I_CACHE) | (state == MEM)))
            hs = 1;
        else
            hs = handshaked_i;
    end
    
    always_comb begin
        next_state = state;
        case (state)
            IDLE: begin
                if (i_cs_i) next_state = I_CACHE;
                else if ((~i_cs_i) & d_cs_i) next_state = MEM;
            end
            I_CACHE: begin
                if ((~i_cs_i) & (~d_cs_i)) next_state = IDLE;
                else if ((~i_cs_i) & d_cs_i) next_state = MEM;
            end
            MEM: begin
                if ((~i_cs_i) & (~d_cs_i)) next_state = IDLE;
                else if (i_cs_i & (~d_cs_i)) next_state = I_CACHE;
            end
            default: next_state = IDLE;
        endcase
    end

    always_comb begin
        if (state == I_CACHE) begin
            addr_o  = {i_addr_i[31:4], 4'b0}; // fetch data from block 0
            wdata_o = i_wdata_i;
            we_o    = i_we_i;
            cs_o    = (hs) ? 0 : 1;
            /* -------------------------- */
            i_rdata_o   = rdata_i;
            i_rvalid_o  = rvalid_i;
            d_rdata_o   = 0;
            d_rvalid_o  = 0;
        end
        else if (state == MEM) begin       
            if (d_addr_i[19:16] == 4'h1) begin
                addr_o  = d_addr_i;
            end
            else begin
                addr_o   = {d_addr_i[31:4], 4'b0} + 32'h00000800;
            end
            wdata_o  = d_wdata_i;
            we_o     = d_we_i;
            cs_o     = (hs) ? 0 : 1;
            /* -------------------------- */
            i_rdata_o   = 0;
            i_rvalid_o  = 0;
            d_rdata_o   = rdata_i;
            d_rvalid_o  = rvalid_i;
        end
        else begin 
            addr_o   = 0;
            wdata_o  = 0;
            we_o     = 0;
            cs_o     = 0;
            /* -------------------------- */
            i_rdata_o   = 0;
            i_rvalid_o  = 0;
            d_rdata_o   = 0;
            d_rvalid_o  = 0;
        end
    end

    always_ff @(posedge clk_i) begin
        if (!rst_ni) begin
            state <= IDLE;
        end
        else begin
            state <= next_state;
        end
    end
    
    
endmodule


