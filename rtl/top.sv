`include "define.sv" 
module top(
    input logic ACLK_1,
    input logic ARESETn_1,
    input logic ACLK_2,
    input logic ARESETn_2
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
    logic [2:0] s0_bresp;
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
    logic [2:0] s0_rresp;
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
    logic [2:0] m1_bresp;
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
    logic [2:0] m1_rresp;
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


    master_cpu m_inst (
        .clk_i         (ACLK_1),
        .rst_ni        (ARESETn_1),
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
        //m1
        .m1_awid       (m1_awid),
        .m1_awaddr     (m1_awaddr),
        .m1_awlen      (m1_awlen),
        .m1_awsize     (m1_awsize),
        .m1_awburst    (m1_awburst),
        .m1_awvalid    (m1_awvalid),
        .m1_awready    (m1_awready),
        .m1_wdata      (m1_wdata),
        .m1_wstrb      (m1_wstrb),
        .m1_wvalid     (m1_wvalid),
        .m1_wlast      (m1_wlast),
        .m1_wready     (m1_wready),
        .m1_bid        (m1_bid),
        .m1_bresp      (m1_bresp),
        .m1_bvalid     (m1_bvalid),
        .m1_bready     (m1_bready),
        .m1_arid       (m1_arid),
        .m1_araddr     (m1_araddr),
        .m1_arlen      (m1_arlen),
        .m1_arburst    (m1_arburst),
        .m1_arsize     (m1_arsize),
        .m1_arvalid    (m1_arvalid),
        .m1_arready    (m1_arready),
        .m1_rid        (m1_rid),
        .m1_rdata      (m1_rdata),
        .m1_rresp      (m1_rresp),
        .m1_rvalid     (m1_rvalid),
        .m1_rlast      (m1_rlast),
        .m1_rready     (m1_rready)
        );
        
    slave_0_sdram s0_inst (
        .clk_i      (ACLK_2),
        .rst_ni     (ARESETn_2),
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
        .clk_i      (ACLK_2),
        .rst_ni     (ARESETn_2),
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
        .rready     (s1_rready)
    );    

    Asynchronous_AXI_to_AXI_Bridge bridge (
        .ACLK_m        (ACLK_1),
        .ARESETn_m     (ARESETn_1),
        .ACLK_s        (ACLK_2),
        .ARESETn_s     (ARESETn_2),
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
        .m1_awid       (m1_awid),
        .m1_awaddr     (m1_awaddr),
        .m1_awlen      (m1_awlen),
        .m1_awsize     (m1_awsize),
        .m1_awburst    (m1_awburst),
        .m1_awvalid    (m1_awvalid),
        .m1_awready    (m1_awready),
        .m1_wdata      (m1_wdata),
        .m1_wstrb      (m1_wstrb),
        .m1_wvalid     (m1_wvalid),
        .m1_wlast      (m1_wlast),
        .m1_wready     (m1_wready),
        .m1_bid        (m1_bid),
        .m1_bresp      (m1_bresp),
        .m1_bvalid     (m1_bvalid),
        .m1_bready     (m1_bready),
        .m1_arid       (m1_arid),
        .m1_araddr     (m1_araddr),
        .m1_arlen      (m1_arlen),
        .m1_arburst    (m1_arburst),
        .m1_arsize     (m1_arsize),
        .m1_arvalid    (m1_arvalid),
        .m1_arready    (m1_arready),
        .m1_rid        (m1_rid),
        .m1_rdata      (m1_rdata),
        .m1_rresp      (m1_rresp),
        .m1_rvalid     (m1_rvalid),
        .m1_rlast      (m1_rlast),
        .m1_rready     (m1_rready),
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
        .s1_rready     (s1_rready)
    );
    
endmodule
