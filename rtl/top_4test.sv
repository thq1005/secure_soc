`include "define.sv" 
module top_4test(
    input logic ACLK_1,
    input logic ARESETn_1,
//signal of m00
    input logic [15:0] s00_awid,
    input logic [`ADDR_WIDTH - 1:0] s00_awaddr,
    input logic [`LEN_BITS - 1:0] s00_awlen,
    input logic [`SIZE_BITS -1 :0] s00_awsize,
    input logic [1:0] s00_awburst,
    input logic s00_awvalid,
    output logic s00_awready,
    //W channel
    input logic [`DATA_WIDTH - 1:0] s00_wdata,
    input logic [(`DATA_WIDTH/8)-1:0] s00_wstrb,
    input logic s00_wvalid,
    input logic s00_wlast,
    output logic s00_wready,
    //B channel
    output logic [15:0] s00_bid,
    output logic [2:0] s00_bresp,
    output logic s00_bvalid,
    input logic s00_bready,
    //AR channel
    input logic [15:0] s00_arid,
    input logic [`ADDR_WIDTH - 1:0] s00_araddr,
    input logic [`LEN_BITS - 1:0] s00_arlen,
    input logic [1:0] s00_arburst,
    input logic [`SIZE_BITS - 1:0] s00_arsize,
    input logic s00_arvalid,
    output logic s00_arready,
    //R channel
    output logic [15:0] s00_rid,
    output logic [`DATA_WIDTH - 1:0] s00_rdata,
    output logic [2:0] s00_rresp,
    output logic s00_rvalid,
    output logic s00_rlast,
    input logic s00_rready
    );
    


    logic we_w;
    logic [`ADDR_WIDTH-1:0] waddr_w;
    logic [`DATA_WIDTH-1:0] wdata_w;
    logic [(`DATA_WIDTH/8)-1:0] strb_w;

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
    logic [2:0] m0_bresp;
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
    logic [2:0] m0_rresp;
    logic m0_rvalid;
    logic m0_rlast;
    logic m0_rready;

    
    //signal of m1
    logic [`ID_BITS - 1:0] m_awid;
    logic [`ADDR_WIDTH - 1:0] m_awaddr;
    logic [`LEN_BITS - 1:0] m_awlen;
    logic [`SIZE_BITS -1 :0] m_awsize;
    logic [1:0] m_awburst;
    logic m_awvalid;
    logic m_awready;
    //W channel
    logic [`DATA_WIDTH - 1:0] m_wdata;
    logic [(`DATA_WIDTH/8)-1:0] m_wstrb;
    logic m_wvalid;
    logic m_wlast;
    logic m_wready;
    //B channel
    logic [`ID_BITS - 1:0] m_bid;
    logic [2:0] m_bresp;
    logic m_bvalid;
    logic m_bready;
    //AR channel
    logic [`ID_BITS - 1:0] m_arid;
    logic [`ADDR_WIDTH - 1:0] m_araddr;
    logic [`LEN_BITS - 1:0] m_arlen;
    logic [1:0] m_arburst;
    logic [`SIZE_BITS - 1:0] m_arsize;
    logic m_arvalid;
    logic m_arready;
    //R channel
    logic [`ID_BITS - 1:0] m_rid;
    logic [`DATA_WIDTH - 1:0] m_rdata;
    logic [2:0] m_rresp;
    logic m_rvalid;
    logic m_rlast;
    logic m_rready;

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
    logic [2:0] s1_bresp;
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
    logic [2:0] s1_rresp;
    logic s1_rvalid;
    logic s1_rlast;
    logic s1_rready;

    //signal of s1
    logic [`ID_BITS - 1:0] s_awid;
    logic [`ADDR_WIDTH - 1:0] s_awaddr;
    logic [`LEN_BITS - 1:0] s_awlen;
    logic [`SIZE_BITS -1 :0] s_awsize;
    logic [1:0] s_awburst;
    logic s_awvalid;
    logic s_awready;
    //W channel
    logic [`DATA_WIDTH - 1:0] s_wdata;
    logic [(`DATA_WIDTH/8)-1:0] s_wstrb;
    logic s_wvalid;
    logic s_wlast;
    logic s_wready;
    //B channel
    logic [`ID_BITS - 1:0] s_bid;
    logic [2:0] s_bresp;
    logic s_bvalid;
    logic s_bready;


    logic dma_irq;
    logic dma_clear_irq;
    logic aes_irq;
    logic aes_clear_irq;
    
    logic cpu_on;

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
        .dma_irq      (dma_irq),
        .dma_clear_irq(dma_clear_irq),
        .cpu_on       (cpu_on)
        );
        
    dmac dma (
        .clk_i      (ACLK_1),
        .rst_ni     (ARESETn_1),
        .s_awid     (s_awid),
        .s_awaddr   (s_awaddr),
        .s_awlen    (s_awlen),
        .s_awsize   (s_awsize),
        .s_awburst  (s_awburst),
        .s_awvalid  (s_awvalid),
        .s_awready  (s_awready),
        .s_wdata    (s_wdata),
        .s_wstrb    (s_wstrb),
        .s_wvalid   (s_wvalid),
        .s_wlast    (s_wlast),
        .s_wready   (s_wready),
        .s_bid      (s_bid),
        .s_bresp    (s_bresp),
        .s_bvalid   (s_bvalid),
        .s_bready   (s_bready),
        .m_awid     (m_awid),
        .m_awaddr   (m_awaddr),
        .m_awlen    (m_awlen),
        .m_awsize   (m_awsize),
        .m_awburst  (m_awburst),
        .m_awvalid  (m_awvalid),
        .m_awready  (m_awready),
        .m_wdata    (m_wdata),
        .m_wstrb    (m_wstrb),
        .m_wvalid   (m_wvalid),
        .m_wlast    (m_wlast),
        .m_wready   (m_wready),
        .m_bid      (m_bid),
        .m_bresp    (m_bresp),
        .m_bvalid   (m_bvalid),
        .m_bready   (m_bready),
        .m_arid     (m_arid),
        .m_araddr   (m_araddr),
        .m_arlen    (m_arlen),
        .m_arburst  (m_arburst),
        .m_arsize   (m_arsize),
        .m_arvalid  (m_arvalid),
        .m_arready  (m_arready),
        .m_rid      (m_rid),
        .m_rdata    (m_rdata),
        .m_rresp    (m_rresp),
        .m_rvalid   (m_rvalid),
        .m_rlast    (m_rlast),
        .m_rready   (m_rready),
        .dma_irq    (dma_irq),
        .dma_clear_irq (dma_clear_irq),
        .aes_irq   ( aes_irq),
        .aes_clear_irq (aes_clear_irq)
    );
    
    slave_0_4test s0_inst (
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
        .rready     (s0_rready),
        .soc_on     (cpu_on)
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
        .aes_irq    (aes_irq),
        .aes_clear_irq (aes_clear_irq)
    );    



    axi_bus_test bus (
        .clk_i         (ACLK_1),
        .rst_ni        (ARESETn_1),
        //ps
        .m00_awid       (s00_awid),
        .m00_awaddr     (s00_awaddr),
        .m00_awlen      (s00_awlen),
        .m00_awsize     (s00_awsize),
        .m00_awburst    (s00_awburst),
        .m00_awvalid    (s00_awvalid),
        .m00_awready    (s00_awready),
        .m00_wdata      (s00_wdata),
        .m00_wstrb      (s00_wstrb),
        .m00_wvalid     (s00_wvalid),
        .m00_wlast      (s00_wlast),
        .m00_wready     (s00_wready),
        .m00_bid        (s00_bid),
        .m00_bresp      (s00_bresp),
        .m00_bvalid     (s00_bvalid),
        .m00_bready     (s00_bready),
        .m00_arid       (s00_arid),
        .m00_araddr     (s00_araddr),
        .m00_arlen      (s00_arlen),
        .m00_arburst    (s00_arburst),
        .m00_arsize     (s00_arsize),
        .m00_arvalid    (s00_arvalid),
        .m00_arready    (s00_arready),
        .m00_rid        (s00_rid),
        .m00_rdata      (s00_rdata),
        .m00_rresp      (s00_rresp),
        .m00_rvalid     (s00_rvalid),
        .m00_rlast      (s00_rlast),
        .m00_rready     (s00_rready),
        //m0
        .m0_awid       (m0_awid),
        .m0_awaddr     (m0_awaddr),
        .m0_awlen      (m0_awlen),
        .m0_awsize     (m0_awsize),
        .m0_awburst    (m0_awburst),
        .m0_awvalid    (m0_awvalid),
        .m0_awready    (m0_awready),
        .m0_wdata      (m0_wdata),
        .m0_wstrb      (m0_wstrb),
        .m0_wvalid     (m0_wvalid),
        .m0_wlast      (m0_wlast),
        .m0_wready     (m0_wready),
        .m0_bid        (m0_bid),
        .m0_bresp      (m0_bresp),
        .m0_bvalid     (m0_bvalid),
        .m0_bready     (m0_bready),
        .m0_arid       (m0_arid),
        .m0_araddr     (m0_araddr),
        .m0_arlen      (m0_arlen),
        .m0_arburst    (m0_arburst),
        .m0_arsize     (m0_arsize),
        .m0_arvalid    (m0_arvalid),
        .m0_arready    (m0_arready),
        .m0_rid        (m0_rid),
        .m0_rdata      (m0_rdata),
        .m0_rresp      (m0_rresp),
        .m0_rvalid     (m0_rvalid),
        .m0_rlast      (m0_rlast),
        .m0_rready     (m0_rready),
        //s0
        .s0_awid       (s0_awid),
        .s0_awaddr     (s0_awaddr),
        .s0_awlen      (s0_awlen),
        .s0_awsize     (s0_awsize),
        .s0_awburst    (s0_awburst),
        .s0_awvalid    (s0_awvalid),
        .s0_awready    (s0_awready),
        .s0_wdata      (s0_wdata),
        .s0_wstrb      (s0_wstrb),
        .s0_wvalid     (s0_wvalid),
        .s0_wlast      (s0_wlast),
        .s0_wready     (s0_wready),
        .s0_bid        (s0_bid),
        .s0_bresp      (s0_bresp),
        .s0_bvalid     (s0_bvalid),
        .s0_bready     (s0_bready),
        .s0_arid       (s0_arid),
        .s0_araddr     (s0_araddr),
        .s0_arlen      (s0_arlen),
        .s0_arburst    (s0_arburst),
        .s0_arsize     (s0_arsize),
        .s0_arvalid    (s0_arvalid),
        .s0_arready    (s0_arready),
        .s0_rid        (s0_rid),
        .s0_rdata      (s0_rdata),
        .s0_rresp      (s0_rresp),
        .s0_rvalid     (s0_rvalid),
        .s0_rlast      (s0_rlast),
        .s0_rready     (s0_rready),
        //m1
        .m_awid        (m_awid),
        .m_awaddr      (m_awaddr),
        .m_awlen       (m_awlen),
        .m_awsize      (m_awsize),
        .m_awburst     (m_awburst),
        .m_awvalid     (m_awvalid),
        .m_awready     (m_awready),
        .m_wdata       (m_wdata),
        .m_wstrb       (m_wstrb),
        .m_wvalid      (m_wvalid),
        .m_wlast       (m_wlast),
        .m_wready      (m_wready),
        .m_bid         (m_bid),
        .m_bresp       (m_bresp),
        .m_bvalid      (m_bvalid),
        .m_bready      (m_bready),
        .m_arid        (m_arid),
        .m_araddr      (m_araddr),
        .m_arlen       (m_arlen),
        .m_arburst     (m_arburst),
        .m_arsize      (m_arsize),
        .m_arvalid     (m_arvalid),
        .m_arready     (m_arready),
        .m_rid         (m_rid),
        .m_rdata       (m_rdata),
        .m_rresp       (m_rresp),
        .m_rvalid      (m_rvalid),
        .m_rlast       (m_rlast),
        .m_rready      (m_rready),
        //s1
        .s1_awid       (s1_awid),
        .s1_awaddr     (s1_awaddr),
        .s1_awlen      (s1_awlen),
        .s1_awsize     (s1_awsize),
        .s1_awburst    (s1_awburst),
        .s1_awvalid    (s1_awvalid),
        .s1_awready    (s1_awready),
        .s1_wdata      (s1_wdata),
        .s1_wstrb      (s1_wstrb),
        .s1_wvalid     (s1_wvalid),
        .s1_wlast      (s1_wlast),
        .s1_wready     (s1_wready),
        .s1_bid        (s1_bid),
        .s1_bresp      (s1_bresp),
        .s1_bvalid     (s1_bvalid),
        .s1_bready     (s1_bready),
        .s1_arid       (s1_arid),
        .s1_araddr     (s1_araddr),
        .s1_arlen      (s1_arlen),
        .s1_arburst    (s1_arburst),
        .s1_arsize     (s1_arsize),
        .s1_arvalid    (s1_arvalid),
        .s1_arready    (s1_arready),
        .s1_rid        (s1_rid),
        .s1_rdata      (s1_rdata),
        .s1_rresp      (s1_rresp),
        .s1_rvalid     (s1_rvalid),
        .s1_rlast      (s1_rlast),
        .s1_rready     (s1_rready),
        //s
        .s_awid       (s_awid),
        .s_awaddr     (s_awaddr),
        .s_awlen      (s_awlen),
        .s_awsize     (s_awsize),
        .s_awburst    (s_awburst),
        .s_awvalid    (s_awvalid),
        .s_awready    (s_awready),
        .s_wdata      (s_wdata),
        .s_wstrb      (s_wstrb),
        .s_wvalid     (s_wvalid),
        .s_wlast      (s_wlast),
        .s_wready     (s_wready),
        .s_bid        (s_bid),
        .s_bresp      (s_bresp),
        .s_bvalid     (s_bvalid),
        .s_bready     (s_bready)
    );
    
endmodule
