`include "../define.sv"

module dmac_write (
    input clk_i,
    input rst_ni,
    input valid_i,
    input [`ADDR_WIDTH-1:0] dst_addr_i,
    input [`LEN_BITS-1:0]   len_i,
    input [`SIZE_BITS-1:0]  size_i,
    input [1:0]             burst_i,
    input [31:0] data_i,
    input fifo_empty_i,
    output logic write_pop, 
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
    input  logic [1:0] m_bresp,
    input  logic m_bvalid,
    output logic m_bready,
    output logic dma_intr
);

    localparam IDLE = 2'd0, WA = 2'd1, W = 2'd2, B = 2'd3;
    logic [3:0] w_state, w_next_state;

    logic [`ADDR_WIDTH-1:0] awaddr_r;
    logic [`LEN_BITS-1:0]   awlen_r;
    logic [`SIZE_BITS-1:0]  awsize_r;
    logic [1:0]             awburst_r;

    logic [7:0]  wdata_cnt;

    always_ff @(posedge clk_i) begin
        if (!rst_ni) begin
            awaddr_r  <= '0;
            awlen_r   <= '0;
            awsize_r  <= '0;
            awburst_r <= '0;
        end else if (valid_i) begin
            awaddr_r  <= dst_addr_i;
            awlen_r   <= len_i;
            awsize_r  <= size_i;
            awburst_r <= burst_i;
        end else begin
            awaddr_r  <= awaddr_r;
            awlen_r   <= awlen_r;
            awsize_r  <= awsize_r;
            awburst_r <= awburst_r;
        end
    end

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
        default: w_next_state = IDLE;
        endcase
    end   

    always_ff @(posedge clk_i) begin
        if (!rst_ni) begin
            wdata_cnt = 0;
        end
        else if (w_state == IDLE) begin
            wdata_cnt = 0;
        end
        else if (w_state == W) begin
            if (m_wvalid && m_wready)
                wdata_cnt = wdata_cnt + 1;
        end 
    end

    always_comb begin
        m_wdata = 0;
        if (w_state == W) 
            m_wdata = data_i;
    end

    assign m_awaddr  = awaddr_r;
    assign m_wstrb   = 4'hf;
    assign m_awid    =  1;

    assign m_awlen   = awlen_r;
    assign m_awsize  = awsize_r;
    assign m_awburst = awburst_r;
    assign m_awvalid = (w_state == WA);
    assign m_wlast   = ((w_state == W) && (wdata_cnt == awlen_r));
    assign m_wvalid  = (w_state == W) && !fifo_empty_i;
    assign write_pop = (w_state == W) && m_wready && !fifo_empty_i;
    assign m_bready  = (w_state == B);
    assign dma_intr  = (w_state == B && m_bvalid && m_bready);
endmodule

    