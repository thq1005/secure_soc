`include "../define.sv"

module dmac_write (
    input clk_i,
    input rst_ni,
    input valid_i,
    input [`ADDR_WIDTH-1:0] dst_addr_i,
    input [`LEN_BITS-1:0]   len_i,
    input [`SIZE_BITS-1:0]  size_i,
    input [1:0]             burst_i,
    input rdata_valid_i,
    input [`DATA_WIDTH-1:0] data_i, 
    //AW channel
    output logic [`ID_BITS - 1:0] m_awid,
    output logic [`ADDR_WIDTH - 1:0] m_awaddr,
    output logic [`LEN_BITS - 1:0] m_awlen,
    output logic [`SIZE_BITS -1 :0] m_awsize,
    output logic [1:0] m_awburst,
    output logic m_awvalid,
    input  logic m_awready,
    //W channel
    output logic [`DATA_WIDTH - 1:0] m_wdata,
    output logic [(`DATA_WIDTH/8)-1:0] m_wstrb,
    output logic m_wvalid,
    output logic m_wlast,
    input  logic m_wready,
    //B channel
    input  logic [`ID_BITS - 1:0] m_bid,
    input  logic [2:0] m_bresp,
    input  logic m_bvalid,
    output logic m_bready
);

    localparam IDLE = 2'd0, WA = 2'd1, W = 2'd2, B = 2'd3;
    logic [3:0] w_state, w_next_state;
    logic [1:0] w_len_cnt;

    always_ff @(posedge clk_i) begin
        if(~rst_ni) 
            w_state <= 0;
        else
            w_state <= w_next_state; 
    end

        always_comb begin
        case (w_state)
        IDLE: begin
            if (valid_i)
                w_next_state = WA;
            else 
                w_next_state = IDLE;
        end        
        WA: begin
            if (m_awvalid && m_awready)
                w_next_state = W;
            else
                w_next_state = WA;
        end
        W: begin
            if (m_wvalid && m_wready && m_wlast)
                w_next_state = B;
            else
                w_next_state = W;
        end
        B: begin
            if (m_bvalid && m_bready) 
                w_next_state = IDLE;
            else 
                w_next_state = B;
        end
        endcase
    end   

    always_ff @(posedge clk_i) begin
        if (!rst_ni) begin
            w_len_cnt = 0;
        end
        else if (w_state == IDLE) begin
            w_len_cnt = 0;
        end
        else if (w_state == W) begin
            if (m_wvalid && m_wready)
                w_len_cnt = w_len_cnt - 1;
        end 
    end

    always_ff @(posedge clk_i) begin
        if (!rst_ni) begin
            m_awaddr <= 0;
            m_wstrb  <= 0;
        end else if (w_state == IDLE) begin
            if (valid_i)
                m_awaddr <= dst_addr_i;
            m_wstrb  <= 4'hf;
        end
        else begin
            m_awaddr  <= m_awaddr;
            m_wstrb   <= m_wstrb;
        end
    end

    assign m_awid    = 0;
    assign m_awlen   = len_i;
    assign m_awsize  = size_i;
    assign m_awburst = burst_i;
    assign m_awvalid = (w_state == WA);

    assign m_wlast   = ((w_state == W) && (w_len_cnt == 1));
    assign m_wvalid  = rdata_valid_i;
    assign m_bready  = (w_state == B);
    assign m_wdata   = data_i;
endmodule

    