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
        input logic aes_irq,        //aes interrupt
        output logic aes_clear_irq,	
        output logic dma_irq,		//dma interrupt
        input logic dma_clear_irq
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
    logic src_addr_we;
    logic dst_addr_we;
    logic config_we;

    logic ready_to_pop;
    logic run;

    logic [1:0] r_nstate;
    logic [1:0] w_nstate;

    logic we_w;
    logic [`ADDR_WIDTH-1:0] waddr_w;
    logic [`DATA_WIDTH-1:0] wdata_w;

    logic dma_intr_w;
    logic mode_r;
    
    always_comb begin
        if (fifo_pop) 
            ready_to_pop <= 1'b0;
        else if (r_nstate == 2'b00) 
            ready_to_pop <= 1'b1;
        else 
            ready_to_pop <= 1'b0;
    end

    assign run = (fifo_pop && ~current_mode) | (mode_r && aes_irq);

    
    always_ff @(posedge clk_i) begin
        if (~rst_ni) begin
            mode_r <= 0;
        end
        else if (fifo_pop)
            mode_r <= current_mode;
        else if (aes_irq)
            mode_r <= 0;
        else
            mode_r <= mode_r;
    end

    fifo #(
        .DATA_W (`ADDR_WIDTH+`ADDR_WIDTH+2+`SIZE_BITS+`LEN_BITS+1),
        .DEPTH  (4)) fifo_request_inst (
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
        if (!rst_ni) 
            fifo_pop         <= 1'b0;
        else if (~fifo_empty && ready_to_pop) 
            fifo_pop         <= 1'b1;
        else if (fifo_pop)
            fifo_pop         <= 1'b0;
    end

    

    axi_interface_slave_write s_itf (
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
        .o_we       (we_w),
        .o_waddr    (waddr_w),
        .o_wdata    (wdata_w),
        .o_strb     ()
        );

    logic [511:0] data_w;
    logic rdata_valid_w;

    dmac_read read_inst (
        .clk_i,
        .rst_ni,
        .valid_i    (run),
        .write_rq   (fifo_pop),
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
        .m_rready,
        .r_nstate
    );

    logic [2+`SIZE_BITS+`LEN_BITS-1:0] write_config;
    logic [2+`SIZE_BITS+`LEN_BITS-1:0] w_fifo_config; 
    logic [`ADDR_WIDTH-1:0] r_dst_addr;
    logic [`ADDR_WIDTH-1:0] write_dst_addr;
    logic [511:0] write_data;
    logic f_write_push;
    logic f_write_pop;
    logic f_write_full;
    logic f_write_empty;
    logic ready_fw_pop;

    always_ff @(posedge clk_i) begin
        if (~rst_ni)
            r_dst_addr <= '0;
        else if (fifo_pop)
            r_dst_addr <= current_dst_addr;
    end

    always_comb begin
        if (f_write_pop) 
            ready_fw_pop <= 1'b0;
        else if (w_nstate == 2'b00) 
            ready_fw_pop <= 1'b1;
        else 
            ready_fw_pop <= 1'b0;
    end

    assign w_fifo_config = {m_arburst,m_arsize,m_arlen};
    
    always_comb begin
        f_write_push = 1'b0;
        if (rdata_valid_w) begin
            if (!f_write_full) begin
                f_write_push = 1'b1;
            end
        end
    end

    always_ff @(posedge clk_i) begin
        if (!rst_ni) 
            f_write_pop       <= 1'b0;
        else if (~f_write_empty && ready_fw_pop) 
            f_write_pop       <= 1'b1;
        else if (f_write_pop)
            f_write_pop       <= 1'b0;
    end

    fifo #(
        .DATA_W (`ADDR_WIDTH+2+`SIZE_BITS+`LEN_BITS+512),
        .DEPTH  (4)) fifo_write_inst (
        .clk_i  (clk_i),
        .rst_ni (rst_ni),
        .we_i   (f_write_push),
        .re_i   (f_write_pop),
        .full   (f_write_full),
        .empty  (f_write_empty),
        .wdata_i({r_dst_addr, w_fifo_config, data_w}),
        .rdata_o({write_dst_addr, write_config, write_data})
    );

    dmac_write write_inst (
        .clk_i,
        .rst_ni,
        .valid_i    (f_write_pop),
        .dst_addr_i (write_dst_addr),
        .len_i      (write_config[`DMA_LEN_BIT7:`DMA_LEN_BIT0]),
        .size_i     (write_config[`DMA_SIZE_BIT2:`DMA_SIZE_BIT0]),
        .burst_i    (write_config[`DMA_BURST_BIT1:`DMA_BURST_BIT0]),
        .data_i     (write_data),
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
        .w_nstate,
        .dma_intr (dma_intr_w)
    );


    always_ff @(posedge clk_i) begin
        if (!rst_ni) begin            
            fifo_src_addr  <= '0;
            fifo_dst_addr  <= '0;
            fifo_config    <= '0; 
            fifo_mode <= 0;
        end
        else begin           
            if (config_we) begin
                fifo_config <= wdata_w[2+`SIZE_BITS+`LEN_BITS-1:0];
                fifo_mode   <= wdata_w[`DMA_MODE_BIT];
            end   
            if (src_addr_we)
                if (wdata_w[19:16]==0)
                    fifo_src_addr <= wdata_w + 32'h00000800;
                else 
                    fifo_src_addr <= wdata_w;
            if (dst_addr_we)
                if (wdata_w[19:16]==0)
                    fifo_dst_addr <= wdata_w + 32'h00000800;
                else 
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
    
            if (waddr_w == `ADDR_CONFIG_DMA) 
                config_we = 1'b1;
        end
    end

    always_ff @(posedge clk_i) begin
        if(~rst_ni) begin
            dma_irq <= 1'b0;
        end
        else if (dma_intr_w && (m_awid == 2)) begin
            dma_irq <= 1'b1;
        end
        else if (dma_clear_irq) begin
            dma_irq <= 1'b0;
        end
    end

    assign aes_clear_irq = aes_irq && dma_irq;

endmodule