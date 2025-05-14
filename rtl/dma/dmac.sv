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
        output logic dma_irq,		//dma interrupt
        input logic dma_clear_irq
);
     // | burst | size | len |
     // 12    11 10   8 7    0

    // reg request
    logic [`ADDR_WIDTH-1:0] saddr_reg, daddr_reg;
    logic [2+`SIZE_BITS+`LEN_BITS-1:0] config_reg;
    logic src_addr_we;
    logic dst_addr_we;
    logic config_we;
    //valid signal
    logic run;
    //interface
    logic we_w;
    logic [`ADDR_WIDTH-1:0] waddr_w;
    logic [`DATA_WIDTH-1:0] wdata_w;

    logic [31:0] data_w;

    logic dma_intr_w;
       

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


    dmac_read read_inst (
        .clk_i,
        .rst_ni,
        .valid_i    (run),
        .src_addr_i (saddr_reg),
        .len_i      (config_reg[`DMA_LEN_BIT7:`DMA_LEN_BIT0]),
        .size_i     (config_reg[`DMA_SIZE_BIT2:`DMA_SIZE_BIT0]),
        .burst_i    (config_reg[`DMA_BURST_BIT1:`DMA_BURST_BIT0]),
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

    logic fifo_empty_w;
    logic write_pop;
    logic [31:0] write_data;


    fifo #(
        .DATA_W (32),
        .DEPTH  (128)) fifo_write_inst (
        .clk_i  (clk_i),
        .rst_ni (rst_ni),
        .we_i   (rdata_valid_w),
        .re_i   (write_pop),
        .full   (),
        .empty  (fifo_empty_w),
        .wdata_i(data_w),
        .rdata_o(write_data)
    );

    dmac_write write_inst (
        .clk_i,
        .rst_ni,
        .valid_i    (run),
        .dst_addr_i (daddr_reg),
        .len_i      (config_reg[`DMA_LEN_BIT7:`DMA_LEN_BIT0]),
        .size_i     (config_reg[`DMA_SIZE_BIT2:`DMA_SIZE_BIT0]),
        .burst_i    (config_reg[`DMA_BURST_BIT1:`DMA_BURST_BIT0]),
        .data_i     (write_data),
        .fifo_empty_i (fifo_empty_w),
        .write_pop  (write_pop),
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
            saddr_reg  <= '0;
            daddr_reg  <= '0;
            config_reg <= '0; 
        end
        else begin           
            if (config_we) 
                config_reg <= wdata_w[2+`SIZE_BITS+`LEN_BITS-1:0];
            if (src_addr_we)
                if (wdata_w[19:16]==0)
                    saddr_reg <= wdata_w;// + 32'h00000800;
                else 
                    saddr_reg <= wdata_w;
            if (dst_addr_we)
                if (wdata_w[19:16]==0)
                    daddr_reg <= wdata_w;// + 32'h00000800;
                else 
                    daddr_reg <= wdata_w;
            if (waddr_w == `ADDR_VALID && we_w)
                run <= wdata_w[0];
            else  
                run <= 0;
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


endmodule
