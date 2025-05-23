`include "define.sv" 
module top(
    input logic ACLK_1,
    input logic ARESETn_1,
    //sd
    input logic cmd_i,
    output logic cmd_o,
    output logic cmd_t,
    input logic [3:0] dat_i,
    output logic [3:0] dat_o,
    output logic [3:0] dat_t,
    output logic sdclk_o,
    
    );
    
    
    //signal of m0
    logic [`ID_BITS - 1:0] m0_awid;
    logic [`ADDR_WIDTH - 1:0] m0_awaddr;
    logic [`LEN_BITS - 1:0] m0_awlen;
    logic [`SIZE_BITS -1 :0] m0_awsize;
    logic [1:0] m0_awburst;
    logic m0_awvalid;
    logic m0_awready;
    //W channel
    logic [`DATA_WIDTH - 1:0] m0_wdata;
    logic [(`DATA_WIDTH/8)-1:0] m0_wstrb;
    logic m0_wvalid;
    logic m0_wlast;
    logic m0_wready;
    //B channel
    logic [`ID_BITS - 1:0] m0_bid;
    logic [1:0] m0_bresp;
    logic m0_bvalid;
    logic m0_bready;
    //AR channel
    logic [`ID_BITS - 1:0] m0_arid;
    logic [`ADDR_WIDTH - 1:0] m0_araddr;
    logic [`LEN_BITS - 1:0] m0_arlen;
    logic [1:0] m0_arburst;
    logic [`SIZE_BITS - 1:0] m0_arsize;
    logic m0_arvalid;
    logic m0_arready;
    //R channel
    logic [`ID_BITS - 1:0] m0_rid;
    logic [`DATA_WIDTH - 1:0] m0_rdata;
    logic [1:0] m0_rresp;
    logic m0_rvalid;
    logic m0_rlast;
    logic m0_rready;

    //signal of s0
    logic [`ID_BITS - 1:0] s0_awid;
    logic [`ADDR_WIDTH - 1:0] s0_awaddr;
    logic [`LEN_BITS - 1:0] s0_awlen;
    logic [`SIZE_BITS -1 :0] s0_awsize;
    logic [1:0] s0_awburst;
    logic s0_awvalid;
    logic s0_awready;
    //W channel
    logic [`DATA_WIDTH - 1:0] s0_wdata;
    logic [(`DATA_WIDTH/8)-1:0] s0_wstrb;
    logic s0_wvalid;
    logic s0_wlast;
    logic s0_wready;
    //B channel
    logic [`ID_BITS - 1:0] s0_bid;
    logic [1:0] s0_bresp;
    logic s0_bvalid;
    logic s0_bready;
    //AR channel
    logic [`ID_BITS - 1:0] s0_arid;
    logic [`ADDR_WIDTH - 1:0] s0_araddr;
    logic [`LEN_BITS - 1:0] s0_arlen;
    logic [1:0] s0_arburst;
    logic [`SIZE_BITS - 1:0] s0_arsize;
    logic s0_arvalid;
    logic s0_arready;
    //R channel
    logic [`ID_BITS - 1:0] s0_rid;
    logic [`DATA_WIDTH - 1:0] s0_rdata;
    logic [1:0] s0_rresp;
    logic s0_rvalid;
    logic s0_rlast;
    logic s0_rready;

    
    //signal of m1
    logic [`ID_BITS - 1:0] m1_awid;
    logic [`ADDR_WIDTH - 1:0] m1_awaddr;
    logic [`LEN_BITS - 1:0] m1_awlen;
    logic [`SIZE_BITS -1 :0] m1_awsize;
    logic [1:0] m1_awburst;
    logic m1_awvalid;
    logic m1_awready;
    //W channel
    logic [`DATA_WIDTH - 1:0] m1_wdata;
    logic [(`DATA_WIDTH/8)-1:0] m1_wstrb;
    logic m1_wvalid;
    logic m1_wlast;
    logic m1_wready;
    //B channel
    logic [`ID_BITS - 1:0] m1_bid;
    logic [1:0] m1_bresp;
    logic m1_bvalid;
    logic m1_bready;
    //AR channel
    logic [`ID_BITS - 1:0] m1_arid;
    logic [`ADDR_WIDTH - 1:0] m1_araddr;
    logic [`LEN_BITS - 1:0] m1_arlen;
    logic [1:0] m1_arburst;
    logic [`SIZE_BITS - 1:0] m1_arsize;
    logic m1_arvalid;
    logic m1_arready;
    //R channel
    logic [`ID_BITS - 1:0] m1_rid;
    logic [`DATA_WIDTH - 1:0] m1_rdata;
    logic [1:0] m1_rresp;
    logic m1_rvalid;
    logic m1_rlast;
    logic m1_rready;

    //signal of s1
    logic [`ID_BITS - 1:0] s1_awid;
    logic [`ADDR_WIDTH - 1:0] s1_awaddr;
    logic [`LEN_BITS - 1:0] s1_awlen;
    logic [`SIZE_BITS -1 :0] s1_awsize;
    logic [1:0] s1_awburst;
    logic s1_awvalid;
    logic s1_awready;
    //W channel
    logic [`DATA_WIDTH - 1:0] s1_wdata;
    logic [(`DATA_WIDTH/8)-1:0] s1_wstrb;
    logic s1_wvalid;
    logic s1_wlast;
    logic s1_wready;
    //B channel
    logic [`ID_BITS - 1:0] s1_bid;
    logic [1:0] s1_bresp;
    logic s1_bvalid;
    logic s1_bready;
    //AR channel
    logic [`ID_BITS - 1:0] s1_arid;
    logic [`ADDR_WIDTH - 1:0] s1_araddr;
    logic [`LEN_BITS - 1:0] s1_arlen;
    logic [1:0] s1_arburst;
    logic [`SIZE_BITS - 1:0] s1_arsize;
    logic s1_arvalid;
    logic s1_arready;
    //R channel
    logic [`ID_BITS - 1:0] s1_rid;
    logic [`DATA_WIDTH - 1:0] s1_rdata;
    logic [1:0] s1_rresp;
    logic s1_rvalid;
    logic s1_rlast;
    logic s1_rready;

    //signal of s1
    logic [`ID_BITS - 1:0] s2_awid;
    logic [`ADDR_WIDTH - 1:0] s2_awaddr;
    logic [`LEN_BITS - 1:0] s2_awlen;
    logic [`SIZE_BITS -1 :0] s2_awsize;
    logic [1:0] s2_awburst;
    logic s2_awvalid;
    logic s2_awready;
    //W channel
    logic [`DATA_WIDTH - 1:0] s2_wdata;
    logic [(`DATA_WIDTH/8)-1:0] s2_wstrb;
    logic s2_wvalid;
    logic s2_wlast;
    logic s2_wready;
    //B channel
    logic [`ID_BITS - 1:0] s2_bid;
    logic [1:0] s2_bresp;
    logic s2_bvalid;
    logic s2_bready;


    //signal of s1
    logic [`ID_BITS - 1:0] s3_awid;
    logic [`ADDR_WIDTH - 1:0] s3_awaddr;
    logic [`LEN_BITS - 1:0] s3_awlen;
    logic [`SIZE_BITS -1 :0] s3_awsize;
    logic [1:0] s3_awburst;
    logic s3_awvalid;
    logic s3_awready;
    //W channel
    logic [`DATA_WIDTH - 1:0] s3_wdata;
    logic [(`DATA_WIDTH/8)-1:0] s3_wstrb;
    logic s3_wvalid;
    logic s3_wlast;
    logic s3_wready;
    //B channel
    logic [`ID_BITS - 1:0] s3_bid;
    logic [1:0] s3_bresp;
    logic s3_bvalid;
    logic s3_bready;
    //AR channel
    logic [`ID_BITS - 1:0] s3_arid;
    logic [`ADDR_WIDTH - 1:0] s3_araddr;
    logic [`LEN_BITS - 1:0] s3_arlen;
    logic [1:0] s3_arburst;
    logic [`SIZE_BITS - 1:0] s3_arsize;
    logic s3_arvalid;
    logic s3_arready;
    //R channel
    logic [`ID_BITS - 1:0] s3_rid;
    logic [`DATA_WIDTH - 1:0] s3_rdata;
    logic [1:0] s3_rresp;
    logic s3_rvalid;
    logic s3_rlast;
    logic s3_rready;

    logic dma_irq;
    logic aes_irq;
    logic sd_host_irq;

    logic irq;

    master_cpu m_inst (
        .clk_i        (ACLK_1),
        .rst_ni       (ARESETn_1),
        .m_awid       (m0_awid),
        .m_awaddr     (m0_awaddr),
        .m_awlen      (m0_awlen),
        .m_awsize     (m0_awsize),
        .m_awburst    (m0_awburst),
        .m_awvalid    (m0_awvalid),
        .m_awready    (m0_awready),
        .m_wdata      (m0_wdata),
        .m_wstrb      (m0_wstrb),
        .m_wvalid     (m0_wvalid),
        .m_wlast      (m0_wlast),
        .m_wready     (m0_wready),
        .m_bid        (m0_bid),
        .m_bresp      (m0_bresp),
        .m_bvalid     (m0_bvalid),
        .m_bready     (m0_bready),
        .m_arid       (m0_arid),
        .m_araddr     (m0_araddr),
        .m_arlen      (m0_arlen),
        .m_arburst    (m0_arburst),
        .m_arsize     (m0_arsize),
        .m_arvalid    (m0_arvalid),
        .m_arready    (m0_arready),
        .m_rid        (m0_rid),
        .m_rdata      (m0_rdata),
        .m_rresp      (m0_rresp),
        .m_rvalid     (m0_rvalid),
        .m_rlast      (m0_rlast),
        .m_rready     (m0_rready),
        .irq          (irq)
        );
        
    dmac dma (
        .clk_i      (ACLK_1),
        .rst_ni     (ARESETn_1),
        .s_awid     (s2_awid),
        .s_awaddr   (s2_awaddr),
        .s_awlen    (s2_awlen),
        .s_awsize   (s2_awsize),
        .s_awburst  (s2_awburst),
        .s_awvalid  (s2_awvalid),
        .s_awready  (s2_awready),
        .s_wdata    (s2_wdata),
        .s_wstrb    (s2_wstrb),
        .s_wvalid   (s2_wvalid),
        .s_wlast    (s2_wlast),
        .s_wready   (s2_wready),
        .s_bid      (s2_bid),
        .s_bresp    (s2_bresp),
        .s_bvalid   (s2_bvalid),
        .s_bready   (s2_bready),
        .m_awid     (m1_awid),
        .m_awaddr   (m1_awaddr),
        .m_awlen    (m1_awlen),
        .m_awsize   (m1_awsize),
        .m_awburst  (m1_awburst),
        .m_awvalid  (m1_awvalid),
        .m_awready  (m1_awready),
        .m_wdata    (m1_wdata),
        .m_wstrb    (m1_wstrb),
        .m_wvalid   (m1_wvalid),
        .m_wlast    (m1_wlast),
        .m_wready   (m1_wready),
        .m_bid      (m1_bid),
        .m_bresp    (m1_bresp),
        .m_bvalid   (m1_bvalid),
        .m_bready   (m1_bready),
        .m_arid     (m1_arid),
        .m_araddr   (m1_araddr),
        .m_arlen    (m1_arlen),
        .m_arburst  (m1_arburst),
        .m_arsize   (m1_arsize),
        .m_arvalid  (m1_arvalid),
        .m_arready  (m1_arready),
        .m_rid      (m1_rid),
        .m_rdata    (m1_rdata),
        .m_rresp    (m1_rresp),
        .m_rvalid   (m1_rvalid),
        .m_rlast    (m1_rlast),
        .m_rready   (m1_rready),
        .dma_irq    (dma_irq)
    );
    
    slave_0_sdram s0_inst (
        .clk_i      (ACLK_1),
        .rst_ni     (ARESETn_1),
        .awid       (s0_awid),
        .awaddr     (s0_awaddr),
        .awlen      (s0_awlen),
        .awsize     (s0_awsize),
        .awburst    (s0_awburst),
        .awvalid    (s0_awvalid),
        .awready    (s0_awready),
        .wdata      (s0_wdata),
        .wstrb      (s0_wstrb),
        .wvalid     (s0_wvalid),
        .wlast      (s0_wlast),
        .wready     (s0_wready),
        .bid        (s0_bid),
        .bresp      (s0_bresp),
        .bvalid     (s0_bvalid),
        .bready     (s0_bready),
        .arid       (s0_arid),
        .araddr     (s0_araddr),
        .arlen      (s0_arlen),
        .arburst    (s0_arburst),
        .arsize     (s0_arsize),
        .arvalid    (s0_arvalid),
        .arready    (s0_arready),
        .rid        (s0_rid),
        .rdata      (s0_rdata),
        .rresp      (s0_rresp),
        .rvalid     (s0_rvalid),
        .rlast      (s0_rlast),
        .rready     (s0_rready)
    );
    
    slave_1_aes s1_inst (
        .clk_i      (ACLK_1),
        .rst_ni     (ARESETn_1),
        .awid       (s1_awid),
        .awaddr     (s1_awaddr),
        .awlen      (s1_awlen),
        .awsize     (s1_awsize),
        .awburst    (s1_awburst),
        .awvalid    (s1_awvalid),
        .awready    (s1_awready),
        .wdata      (s1_wdata),
        .wstrb      (s1_wstrb),
        .wvalid     (s1_wvalid),
        .wlast      (s1_wlast),
        .wready     (s1_wready),
        .bid        (s1_bid),
        .bresp      (s1_bresp),
        .bvalid     (s1_bvalid),
        .bready     (s1_bready),
        .arid       (s1_arid),
        .araddr     (s1_araddr),
        .arlen      (s1_arlen),
        .arburst    (s1_arburst),
        .arsize     (s1_arsize),
        .arvalid    (s1_arvalid),
        .arready    (s1_arready),
        .rid        (s1_rid),
        .rdata      (s1_rdata),
        .rresp      (s1_rresp),
        .rvalid     (s1_rvalid),
        .rlast      (s1_rlast),
        .rready     (s1_rready),
        .aes_irq    (aes_irq)
    );    

    slave_3_plic s3_inst (
        .clk_i      (ACLK_1),
        .rst_ni     (ARESETn_1),
        .awid       (s3_awid),
        .awaddr     (s3_awaddr),
        .awlen      (s3_awlen),
        .awsize     (s3_awsize),
        .awburst    (s3_awburst),
        .awvalid    (s3_awvalid),
        .awready    (s3_awready),
        .wdata      (s3_wdata),
        .wstrb      (s3_wstrb),
        .wvalid     (s3_wvalid),
        .wlast      (s3_wlast),
        .wready     (s3_wready),
        .bid        (s3_bid),
        .bresp      (s3_bresp),
        .bvalid     (s3_bvalid),
        .bready     (s3_bready),
        .arid       (s3_arid),
        .araddr     (s3_araddr),
        .arlen      (s3_arlen),
        .arburst    (s3_arburst),
        .arsize     (s3_arsize),
        .arvalid    (s3_arvalid),
        .arready    (s3_arready),
        .rid        (s3_rid),
        .rdata      (s3_rdata),
        .rresp      (s3_rresp),
        .rvalid     (s3_rvalid),
        .rlast      (s3_rlast),
        .rready     (s3_rready),

        .irq_out            (irq),
        .dma_interrupt      (dma_irq),
        .aes_interrupt      (aes_irq),
        .sd_host_interrupt  (sd_host_irq)
    );

    slave_4_sdio s4_inst (
        .clk_i      (ACLK_1),
        .rst_ni     (ARESETn_1),
        .awid       (s4_awid),
        .awaddr     (s4_awaddr),
        .awlen      (s4_awlen),
        .awsize     (s4_awsize),
        .awburst    (s4_awburst),
        .awvalid    (s4_awvalid),
        .awready    (s4_awready),
        .wdata      (s4_wdata),
        .wstrb      (s4_wstrb),
        .wvalid     (s4_wvalid),
        .wlast      (s4_wlast),
        .wready     (s4_wready),
        .bid        (s4_bid),
        .bresp      (s4_bresp),
        .bvalid     (s4_bvalid),
        .bready     (s4_bready),
        .arid       (s4_arid),
        .araddr     (s4_araddr),
        .arlen      (s4_arlen),
        .arburst    (s4_arburst),
        .arsize     (s4_arsize),
        .arvalid    (s4_arvalid),
        .arready    (s4_arready),
        .rid        (s4_rid),
        .rdata      (s4_rdata),
        .rresp      (s4_rresp),
        .rvalid     (s4_rvalid),
        .rlast      (s4_rlast),
        .rready     (s4_rready),

        //sd_host_controller
        .cmd_i,
        .cmd_o,
        .cmd_t,
        .dat_i,
        .dat_o,
        .dat_t,
        .sdclk_o,
        .sd_host_irq
    );

endmodule
