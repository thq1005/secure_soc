`include "define.sv" 
module top(
    input logic ACLK_1,
    input logic ARESETn_1
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


    //signal of s3
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
        .aes_interrupt      (aes_irq)
    );



    axi_interconnect axi_interconnect (
        .clk_i          (ACLK_1),
        .rst_ni         (ARESETn_1),
        .m0_AWID        (m0_awid),
        .m0_AWADDR      (m0_awaddr),
        .m0_AWLEN       (m0_awlen),
        .m0_AWSIZE      (m0_awsize),
        .m0_AWBURST     (m0_awburst),
        .m0_AWVALID     (m0_awvalid),
        .m0_AWREADY     (m0_awready),
        .m0_WDATA       (m0_wdata),
        .m0_WSTRB       (m0_wstrb),
        .m0_WVALID      (m0_wvalid),
        .m0_WLAST       (m0_wlast),
        .m0_WREADY      (m0_wready),
        .m0_BID         (m0_bid),
        .m0_BRESP       (m0_bresp),
        .m0_BVALID      (m0_bvalid),
        .m0_BREADY      (m0_bready),
        .m0_ARID        (m0_arid),
        .m0_ARADDR      (m0_araddr),
        .m0_ARLEN       (m0_arlen),
        .m0_ARBURST     (m0_arburst),
        .m0_ARSIZE      (m0_arsize),
        .m0_ARVALID     (m0_arvalid),
        .m0_ARREADY     (m0_arready),
        .m0_RID         (m0_rid),
        .m0_RDATA       (m0_rdata),
        .m0_RRESP       (m0_rresp),
        .m0_RVALID      (m0_rvalid),
        .m0_RLAST       (m0_rlast),
        .m0_RREADY      (m0_rready),
        .m1_AWID        (m1_awid),
        .m1_AWADDR      (m1_awaddr),
        .m1_AWLEN       (m1_awlen),
        .m1_AWSIZE      (m1_awsize),
        .m1_AWBURST     (m1_awburst),
        .m1_AWVALID     (m1_awvalid),
        .m1_AWREADY     (m1_awready),
        .m1_WDATA       (m1_wdata),
        .m1_WSTRB       (m1_wstrb),
        .m1_WVALID      (m1_wvalid),
        .m1_WLAST       (m1_wlast),
        .m1_WREADY      (m1_wready),
        .m1_BID         (m1_bid),
        .m1_BRESP       (m1_bresp),
        .m1_BVALID      (m1_bvalid),
        .m1_BREADY      (m1_bready),
        .m1_ARID        (m1_arid),
        .m1_ARADDR      (m1_araddr),
        .m1_ARLEN       (m1_arlen),
        .m1_ARBURST     (m1_arburst),
        .m1_ARSIZE      (m1_arsize),
        .m1_ARVALID     (m1_arvalid),
        .m1_ARREADY     (m1_arready),
        .m1_RID         (m1_rid),
        .m1_RDATA       (m1_rdata),
        .m1_RRESP       (m1_rresp),
        .m1_RVALID      (m1_rvalid),
        .m1_RLAST       (m1_rlast),
        .m1_RREADY      (m1_rready),
        .s0_AWID        (s0_awid),
        .s0_AWADDR      (s0_awaddr),
        .s0_AWLEN       (s0_awlen),
        .s0_AWSIZE      (s0_awsize),
        .s0_AWBURST     (s0_awburst),
        .s0_AWVALID     (s0_awvalid),
        .s0_AWREADY     (s0_awready),
        .s0_WDATA       (s0_wdata),
        .s0_WSTRB       (s0_wstrb),
        .s0_WVALID      (s0_wvalid),
        .s0_WLAST       (s0_wlast),
        .s0_WREADY      (s0_wready),
        .s0_BID         (s0_bid),
        .s0_BRESP       (s0_bresp),
        .s0_BVALID      (s0_bvalid),
        .s0_BREADY      (s0_bready),
        .s0_ARID        (s0_arid),
        .s0_ARADDR      (s0_araddr),
        .s0_ARLEN       (s0_arlen),
        .s0_ARBURST     (s0_arburst),
        .s0_ARSIZE      (s0_arsize),
        .s0_ARVALID     (s0_arvalid),
        .s0_ARREADY     (s0_arready),
        .s0_RID         (s0_rid),
        .s0_RDATA       (s0_rdata),
        .s0_RRESP       (s0_rresp),
        .s0_RVALID      (s0_rvalid),
        .s0_RLAST       (s0_rlast),
        .s0_RREADY      (s0_rready),
        .s1_AWID        (s1_awid),
        .s1_AWADDR      (s1_awaddr),
        .s1_AWLEN       (s1_awlen),
        .s1_AWSIZE      (s1_awsize),
        .s1_AWBURST     (s1_awburst),
        .s1_AWVALID     (s1_awvalid),
        .s1_AWREADY     (s1_awready),
        .s1_WDATA       (s1_wdata),
        .s1_WSTRB       (s1_wstrb),
        .s1_WVALID      (s1_wvalid),
        .s1_WLAST       (s1_wlast),
        .s1_WREADY      (s1_wready),
        .s1_BID         (s1_bid),
        .s1_BRESP       (s1_bresp),
        .s1_BVALID      (s1_bvalid),
        .s1_BREADY      (s1_bready),
        .s1_ARID        (s1_arid),
        .s1_ARADDR      (s1_araddr),
        .s1_ARLEN       (s1_arlen),
        .s1_ARBURST     (s1_arburst),
        .s1_ARSIZE      (s1_arsize),
        .s1_ARVALID     (s1_arvalid),
        .s1_ARREADY     (s1_arready),
        .s1_RID         (s1_rid),
        .s1_RDATA       (s1_rdata),
        .s1_RRESP       (s1_rresp),
        .s1_RVALID      (s1_rvalid),
        .s1_RLAST       (s1_rlast),
        .s1_RREADY      (s1_rready),
        .s2_AWID        (s2_awid),
        .s2_AWADDR      (s2_awaddr),
        .s2_AWLEN       (s2_awlen),
        .s2_AWSIZE      (s2_awsize),
        .s2_AWBURST     (s2_awburst),
        .s2_AWVALID     (s2_awvalid),
        .s2_AWREADY     (s2_awready),
        .s2_WDATA       (s2_wdata),
        .s2_WSTRB       (s2_wstrb),
        .s2_WVALID      (s2_wvalid),
        .s2_WLAST       (s2_wlast),
        .s2_WREADY      (s2_wready),
        .s2_BID         (s2_bid),
        .s2_BRESP       (s2_bresp),
        .s2_BVALID      (s2_bvalid),
        .s2_BREADY      (s2_bready),
        .s3_AWID        (s3_awid),
        .s3_AWADDR      (s3_awaddr),
        .s3_AWLEN       (s3_awlen),
        .s3_AWSIZE      (s3_awsize),
        .s3_AWBURST     (s3_awburst),
        .s3_AWVALID     (s3_awvalid),
        .s3_AWREADY     (s3_awready),
        .s3_WDATA       (s3_wdata),
        .s3_WSTRB       (s3_wstrb),
        .s3_WVALID      (s3_wvalid),
        .s3_WLAST       (s3_wlast),
        .s3_WREADY      (s3_wready),
        .s3_BID         (s3_bid),
        .s3_BRESP       (s3_bresp),
        .s3_BVALID      (s3_bvalid),
        .s3_BREADY      (s3_bready),
        .s3_ARID        (s3_arid),
        .s3_ARADDR      (s3_araddr),
        .s3_ARLEN       (s3_arlen),
        .s3_ARBURST     (s3_arburst),
        .s3_ARSIZE      (s3_arsize),
        .s3_ARVALID     (s3_arvalid),
        .s3_ARREADY     (s3_arready),
        .s3_RID         (s3_rid),
        .s3_RDATA       (s3_rdata),
        .s3_RRESP       (s3_rresp),
        .s3_RVALID      (s3_rvalid),
        .s3_RLAST       (s3_rlast),
        .s3_RREADY      (s3_rready)
    );

endmodule
