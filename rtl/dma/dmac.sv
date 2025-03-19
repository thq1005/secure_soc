`include "../define.sv"

module dmac (
        input clk_i,
        input rst_ni,
        input [`ID_BITS - 1:0] s_awid,
        input [`ADDR_WIDTH - 1:0] s_awaddr,
        input [`LEN_BITS - 1:0] s_awlen,
        input [`SIZE_BITS -1 :0] s_awsize,
        input [1:0] s_awburst,
        input s_awvalid,
        output logic s_awready,
        //W channel
        input [`DATA_WIDTH - 1:0] s_wdata,
        input [(`DATA_WIDTH/8)-1:0] s_wstrb,
        input s_wvalid,
        input s_wlast,
        output logic s_wready,
        //B channel
        output logic [`ID_BITS - 1:0] s_bid,
        output logic [2:0] s_bresp,
        output logic s_bvalid,
        input s_bready,
        //AR channel
        input [`ID_BITS - 1:0] s_arid,
        input [`ADDR_WIDTH - 1:0] s_araddr,
        input [`LEN_BITS - 1:0] s_arlen,
        input [1:0] s_arburst,
        input [`SIZE_BITS - 1:0] s_arsize,
        input s_arvalid,
        output logic s_arready,
        //R channel
        output logic [`ID_BITS - 1:0] s_rid,
        output logic [`DATA_WIDTH - 1:0] s_rdata,
        output logic [2:0] s_rresp,
        output logic s_rvalid,
        output logic s_rlast,
        input s_rready,

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
        output logic m_bready,
        //AR channel
        output logic [`ID_BITS - 1:0] m_arid,
        output logic [`ADDR_WIDTH - 1:0] m_araddr,
        output logic [`LEN_BITS - 1:0] m_arlen,
        output logic [1:0] m_arburst,
        output logic [`SIZE_BITS - 1:0] m_arsize,
        output logic m_arvalid,
        input  logic m_arready,
        //R channel
        input  logic [`ID_BITS - 1:0] m_rid,
        input  logic [`DATA_WIDTH - 1:0] m_rdata,
        input  logic [2:0] m_rresp,
        input  logic m_rvalid,
        input  logic m_rlast,
        output logic m_rready,
        input logic aes_intr,		//aes interrupt
        output logic dma_intr		//dma interrupt
);
     // | burst | size | len |
     // 12    11 10   8 7    0

    // FIFO signals
    logic fifo_push, fifo_pop;
    logic fifo_full, fifo_empty;
    logic [`ADDR_WIDTH-1:0] fifo_src_addr, fifo_dst_addr;
    logic [2+`SIZE_BITS+`LEN_BITS-1:0] fifo_config;
    logic fifo_mode;

    // Current request signals
    logic [`ADDR_WIDTH-1:0] current_src_addr, current_dst_addr;
    logic [2+`SIZE_BITS+`LEN_BITS-1:0] current_config;
    logic current_mode;
    logic current_valid;

    fifo #(
        .DATA_W (`ADDR_WIDTH+`ADDR_WIDTH+2+`SIZE_BITS+`LEN_BITS),
        .DEPTH  (4)) fifo_inst (
        .clk_i  (clk_i),
        .rst_ni (rst_ni),
        .we_i   (fifo_push),
        .re_i   (fifo_pop),
        .full   (fifo_full),
        .empty  (fifo_empty),
        .wdata_i({fifo_src_addr, fifo_dst_addr, fifo_config, fifo_mode}),
        .rdata_o({current_src_addr, current_dst_addr, current_config, current_mode})
    );

    always_comb begin
        fifo_push = 1'b0;
        if (we_w) begin
            if (waddr_w == `ADDR_VALID && wdata_w[0] && !fifo_full) begin
                fifo_push = 1'b1;
            end
        end
    end

    always_ff @(posedge clk_i) begin
        if (!rst_ni) begin
            current_src_addr <= '0;
            current_dst_addr <= '0;
            current_config   <= '0;
            current_mode     <= '0;
            current_valid    <= 1'b0;
        end else if (!current_valid && !fifo_empty) begin
            // Fetch the next request from the FIFO
            current_src_addr <= fifo_src_addr;
            current_dst_addr <= fifo_dst_addr;
            current_config   <= fifo_config;
            current_mode     <= fifo_mode;
            current_valid    <= 1'b1;
            fifo_pop         <= 1'b1;
        end else if (dma_intr_w) begin
            // Clear the current request when completed
            current_valid <= 1'b0;
            fifo_pop      <= 1'b0;
        end
    end

    axi_interface_slave s_itf (
        .clk_i      (clk_i),
        .rst_ni     (rst_ni),
        .awid       (s_awid),
        .awaddr     (s_awaddr),
        .awlen      (s_awlen),
        .awsize     (s_awsize),
        .awburst    (s_awburst),
        .awvalid    (s_awvalid),
        .awready    (s_awready),
        .wdata      (s_wdata),
        .wstrb      (s_wstrb),
        .wvalid     (s_wvalid),
        .wlast      (s_wlast),
        .wready     (s_wready),
        .bid        (s_bid),
        .bresp      (s_bresp),
        .bvalid     (s_bvalid),
        .bready     (s_bready),
        .arid       (s_arid),
        .araddr     (s_araddr),
        .arlen      (s_arlen),
        .arburst    (s_arburst),
        .arsize     (s_arsize),
        .arvalid    (s_arvalid),
        .arready    (s_arready),
        .rid        (s_rid),
        .rdata      (s_rdata),
        .rresp      (s_rresp),
        .rvalid     (s_rvalid),
        .rlast      (s_rlast),
        .rready     (s_rready),
        .o_we       (we_w),
        .o_waddr    (waddr_w),
        .o_wdata    (wdata_w),
        .o_strb     (strb_w),
        .o_re       (),
        .o_raddr    (),
        .i_rdata    ()
        );

    dmac_read read_inst (
        .clk_i,
        .rst_ni,
        .valid_i    (current_valid && (current_mode == 1'b0)),
        .src_addr_i (current_src_addr),
        .len_i      (current_config[`DMA_LEN_BIT7:`DMA_LEN_BIT0]),
        .size_i     (current_config[`DMA_SIZE_BIT2:`DMA_SIZE_BIT0]),
        .burst_i    (current_config[`DMA_BURST_BIT1:`DMA_BURST_BIT0]),
        .rdata_valid_o (rdata_valid_w),
        .data_o     (data_w),
        .m_arid,
        .m_araddr,
        .m_arlen,
        .m_arburst,
        .m_arsize,
        .m_arvalid,
        .m_arready,
        .m_rid,
        .m_rdata,
        .m_rresp,
        .m_rvalid,
        .m_rlast,
        .m_rready
    );

    logic dma_intr_w;

    dmac_write write_inst (
        .clk_i,
        .rst_ni,
        .valid_i    (current_valid && (current_mode == 1'b1)),
        .dst_addr_i (current_dst_addr),
        .len_i      (current_config[`DMA_LEN_BIT7:`DMA_LEN_BIT0]),
        .size_i     (current_config[`DMA_SIZE_BIT2:`DMA_SIZE_BIT0]),
        .burst_i    (current_config[`DMA_BURST_BIT1:`DMA_BURST_BIT0]),
        .rdata_valid_i (rdata_valid_w),
        .data_i     (data_w),
        .m_awid,
        .m_awaddr,
        .m_awlen,
        .m_awburst,
        .m_awsize,
        .m_awvalid,
        .m_awready,
        .m_wdata,
        .m_wstrb,
        .m_wvalid,
        .m_wlast,
        .m_wready,
        .m_bid,
        .m_bresp,
        .m_bvalid,
        .m_bready,
        .dma_intr (dma_intr_w)
    );


    always_ff @(posedge clk_i) begin
        if (!rst_ni) begin            
            fifo_src_addr  <= '0;
            fifo_dst_addr  <= '0;
            fifo_config    <= '0; 
            valid_reg     <= '0;
        end
        else begin           
            if (config_we) begin
                fifo_config <= wdata_w[2+`SIZE_BITS+`LEN_BITS-1:0];
                fifo_mode   <= wdata_w[`DMA_MODE_BIT];
            end   
            if (src_addr_we)
                fifo_src_addr <= wdata_w;
            
            if (dst_addr_we)
                fifo_dst_addr <= wdata_w;
        end
    end 

    always_comb begin
        config_we   = 1'b0;
        src_addr_we = 1'b0;
        dst_addr_we = 1'b0;  
        if (we_w) begin
            if (waddr_w == `ADDR_ADDR_SRC)
                src_addr_we = 1'b1;
            
            if (waddr_w == `ADDR_ADDR_DST) 
                dst_addr_we = 1'b1;
    
            if (waddr_w == `ADDR_CONFIG) 
                config_we = 1'b1;
        end
    end

    assign dma_intr = (current_mode == 1'b1) && (dma_intr_w);

endmodule