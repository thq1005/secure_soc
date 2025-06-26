`include "../define.sv"

module arbiter(
    input  logic clk_i,
    input  logic rst_ni,
    //icache
    input  logic [`ADDR_WIDTH-1:0] i_addr_i,
    input  logic i_cs_i,
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

    input stall_by_icache
    );
    
    typedef enum {IDLE, I_CACHE, MEM} arbiter_state_type;
    arbiter_state_type next_state, state;
    
    logic i_cs_r;
    logic d_cs_r;

    logic rvalid_r;
    logic [`DATA_WIDTH_CACHE-1:0] rdata_r;

    always_ff @(posedge clk_i) begin
        if (!rst_ni) begin
            rvalid_r <= 0;
            rdata_r <= 0;
        end
        else if (stall_by_icache && rvalid_r) begin
            rvalid_r <= rvalid_r;
            rdata_r <= rdata_r;
        end
        else
        begin
            rvalid_r <= rvalid_i;
            rdata_r <= rdata_i;
        end
    end

    always_comb begin
        if (state == I_CACHE)
        begin
            i_cs_r = 0;
            d_cs_r = (~i_cs_i & d_cs_i);
        end
        else if (state == MEM)
        begin
            i_cs_r = (i_cs_i & ~d_cs_i);
            d_cs_r = (d_we_i && d_cs_i);
        end
        else
        begin
            i_cs_r = i_cs_i;
            d_cs_r = d_cs_i;
        end
    end

    always_comb begin
        next_state = state;
        case (state)
            IDLE: begin
                if (i_cs_i) next_state = I_CACHE;
                else if (d_cs_i & ~d_we_i & ~stall_by_icache) next_state = MEM;
            end
            I_CACHE: begin
                if ((~i_cs_i & ~d_cs_i) | (~i_cs_i & d_cs_i & d_we_i)) next_state = IDLE;
                else if ((~i_cs_i) & d_cs_i & ~d_we_i & ~stall_by_icache) next_state = MEM;
            end
            MEM: begin
                if ((~i_cs_i & ~d_cs_i)| (~i_cs_i & d_cs_i & d_we_i)) next_state = IDLE;
                else if ((i_cs_i & ~d_cs_i) | (i_cs_i & d_cs_i & d_we_i)) next_state = I_CACHE;
            end
            default: next_state = IDLE;
        endcase
    end

    always_comb begin
        if (state == I_CACHE) begin
            i_rdata_o   = rdata_i;
            i_rvalid_o  = rvalid_i;
            d_rdata_o   = 0;
            d_rvalid_o  = 0;
        end
        else if (state == MEM) begin       
            i_rdata_o   = 0;
            i_rvalid_o  = 0;
            d_rdata_o   = rdata_r;
            d_rvalid_o  = rvalid_r;
        end
        else begin
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
    
    assign cs_o     = i_cs_r | (d_cs_r && ~stall_by_icache);
    assign addr_o   = (i_cs_i) ? i_addr_i : 
                      (d_cs_i & (d_addr_i[31-:4] == 4'h0)) ? {d_addr_i[31:4], 4'b0} + 32'h00000800 : d_addr_i;
    assign wdata_o  = d_wdata_i;
    assign we_o     = i_cs_i ? 0 : 
                      (d_cs_i & d_we_i) ? 1 : 0;
    
endmodule


