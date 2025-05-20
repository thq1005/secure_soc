`timescale 1ns/1ns
`include "../../rtl/define.sv"
module interconnect_tb();
    logic clk_i;
    logic rst_ni;

    logic [`ID_BITS - 1:0] m0_AWID;
    logic [`ADDR_WIDTH - 1:0] m0_AWADDR;
    logic [`LEN_BITS - 1:0] m0_AWLEN;
    logic [`SIZE_BITS -1 :0] m0_AWSIZE;
    logic [1:0] m0_AWBURST;
    logic m0_AWVALID;
    logic m0_AWREADY;
    logic [`DATA_WIDTH - 1:0] m0_WDATA;
    logic [(`DATA_WIDTH/8)-1:0] m0_WSTRB;
    logic m0_WVALID;
    logic m0_WLAST;
    logic m0_WREADY;
    logic [`ID_BITS - 1:0] m0_BID;
    logic [1:0] m0_BRESP;
    logic m0_BVALID;
    logic m0_BREADY;
    logic [`ID_BITS - 1:0] m0_ARID;
    logic [`ADDR_WIDTH - 1:0] m0_ARADDR;
    logic [`LEN_BITS - 1:0] m0_ARLEN;
    logic [1:0] m0_ARBURST;
    logic [`SIZE_BITS - 1:0] m0_ARSIZE;
    logic m0_ARVALID;
    logic m0_ARREADY;
    logic [`ID_BITS - 1:0] m0_RID;
    logic [`DATA_WIDTH - 1:0] m0_RDATA;
    logic [1:0] m0_RRESP;
    logic m0_RVALID;
    logic m0_RLAST;
    logic m0_RREADY;



    logic [`ID_BITS - 1:0] m1_AWID;
    logic [`ADDR_WIDTH - 1:0] m1_AWADDR;
    logic [`LEN_BITS - 1:0] m1_AWLEN;
    logic [`SIZE_BITS -1 :0] m1_AWSIZE;
    logic [1:0] m1_AWBURST;
    logic m1_AWVALID;
    logic m1_AWREADY;
    logic [`DATA_WIDTH - 1:0] m1_WDATA;
    logic [(`DATA_WIDTH/8)-1:0] m1_WSTRB;
    logic m1_WVALID;
    logic m1_WLAST;
    logic m1_WREADY;
    logic [`ID_BITS - 1:0] m1_BID;
    logic [1:0] m1_BRESP;
    logic m1_BVALID;
    logic m1_BREADY;
    logic [`ID_BITS - 1:0] m1_ARID;
    logic [`ADDR_WIDTH - 1:0] m1_ARADDR;
    logic [`LEN_BITS - 1:0] m1_ARLEN;
    logic [1:0] m1_ARBURST;
    logic [`SIZE_BITS - 1:0] m1_ARSIZE;
    logic m1_ARVALID;
    logic m1_ARREADY;
    logic [`ID_BITS - 1:0] m1_RID;
    logic [`DATA_WIDTH - 1:0] m1_RDATA;
    logic [1:0] m1_RRESP;
    logic m1_RVALID;
    logic m1_RLAST;
    logic m1_RREADY;
    logic [`ID_BITS - 1:0] s0_AWID;
    logic [`ADDR_WIDTH - 1:0] s0_AWADDR;
    logic [`LEN_BITS - 1:0] s0_AWLEN;
    logic [`SIZE_BITS -1 :0] s0_AWSIZE;
    logic [1:0] s0_AWBURST;
    logic s0_AWVALID;
    logic s0_AWREADY;
    logic [`DATA_WIDTH - 1:0] s0_WDATA;
    logic [(`DATA_WIDTH/8)-1:0] s0_WSTRB;
    logic s0_WVALID;
    logic s0_WLAST;
    logic s0_WREADY;
    logic [`ID_BITS - 1:0] s0_BID;
    logic [1:0] s0_BRESP;
    logic s0_BVALID;
    logic s0_BREADY;
    logic [`ID_BITS - 1:0] s0_ARID;
    logic [`ADDR_WIDTH - 1:0] s0_ARADDR;
    logic [`LEN_BITS - 1:0] s0_ARLEN;
    logic [1:0] s0_ARBURST;
    logic [`SIZE_BITS - 1:0] s0_ARSIZE;
    logic s0_ARVALID;
    logic s0_ARREADY;
    logic [`ID_BITS - 1:0] s0_RID;
    logic [`DATA_WIDTH - 1:0] s0_RDATA;
    logic [1:0] s0_RRESP;
    logic s0_RVALID;
    logic s0_RLAST;
    logic s0_RREADY;
    logic [`ID_BITS - 1:0] s1_AWID;
    logic [`ADDR_WIDTH - 1:0] s1_AWADDR;
    logic [`LEN_BITS - 1:0] s1_AWLEN;
    logic [`SIZE_BITS -1 :0] s1_AWSIZE;
    logic [1:0] s1_AWBURST;
    logic s1_AWVALID;
    logic s1_AWREADY;
    logic [`DATA_WIDTH - 1:0] s1_WDATA;
    logic [(`DATA_WIDTH/8)-1:0] s1_WSTRB;
    logic s1_WVALID;
    logic s1_WLAST;
    logic s1_WREADY;
    logic [`ID_BITS - 1:0] s1_BID;
    logic [1:0] s1_BRESP;
    logic s1_BVALID;
    logic s1_BREADY;
    logic [`ID_BITS - 1:0] s1_ARID;
    logic [`ADDR_WIDTH - 1:0] s1_ARADDR;
    logic [`LEN_BITS - 1:0] s1_ARLEN;
    logic [1:0] s1_ARBURST;
    logic [`SIZE_BITS - 1:0] s1_ARSIZE;
    logic s1_ARVALID;
    logic s1_ARREADY;
    logic [`ID_BITS - 1:0] s1_RID;
    logic [`DATA_WIDTH - 1:0] s1_RDATA;
    logic [1:0] s1_RRESP;
    logic s1_RVALID;
    logic s1_RLAST;
    logic s1_RREADY;
    logic [`ID_BITS - 1:0] s2_AWID;
    logic [`ADDR_WIDTH - 1:0] s2_AWADDR;
    logic [`LEN_BITS - 1:0] s2_AWLEN;
    logic [`SIZE_BITS -1 :0] s2_AWSIZE;
    logic [1:0] s2_AWBURST;
    logic s2_AWVALID;
    logic s2_AWREADY;
    logic [`DATA_WIDTH - 1:0] s2_WDATA;
    logic [(`DATA_WIDTH/8)-1:0] s2_WSTRB;
    logic s2_WVALID;
    logic s2_WLAST;
    logic s2_WREADY;
    logic [`ID_BITS - 1:0] s2_BID;
    logic [1:0] s2_BRESP;
    logic s2_BVALID;
    logic s2_BREADY;
    logic [`ID_BITS - 1:0] s3_AWID;
    logic [`ADDR_WIDTH - 1:0] s3_AWADDR;
    logic [`LEN_BITS - 1:0] s3_AWLEN;
    logic [`SIZE_BITS -1 :0] s3_AWSIZE;
    logic [1:0] s3_AWBURST;
    logic s3_AWVALID;
    logic s3_AWREADY;
    logic [`DATA_WIDTH - 1:0] s3_WDATA;
    logic [(`DATA_WIDTH/8)-1:0] s3_WSTRB;
    logic s3_WVALID;
    logic s3_WLAST;
    logic s3_WREADY;
    logic [`ID_BITS - 1:0] s3_BID;
    logic [1:0] s3_BRESP;
    logic s3_BVALID;
    logic s3_BREADY;
    logic [`ID_BITS - 1:0] s3_ARID;
    logic [`ADDR_WIDTH - 1:0] s3_ARADDR;
    logic [`LEN_BITS - 1:0] s3_ARLEN;
    logic [1:0] s3_ARBURST;
    logic [`SIZE_BITS - 1:0] s3_ARSIZE;
    logic s3_ARVALID;
    logic s3_ARREADY;
    logic [`ID_BITS - 1:0] s3_RID;
    logic [`DATA_WIDTH - 1:0] s3_RDATA;
    logic [1:0] s3_RRESP;
    logic s3_RVALID;
    logic s3_RLAST;
    logic s3_RREADY;

    // Clock Generation
    initial begin
        clk_i = 0;
        forever #5 clk_i = ~clk_i; // 100 MHz clock (10 ns period)
    end

    // Reset Generation
    initial begin
        rst_ni <= 0;
        #20 rst_ni <= 1; // Release reset after 20 ns
    end


    axi_interconnect dut (.*);

    logic [31:0] m0_addr;
    logic [127:0] m0_wdata;
    logic m0_we;
    logic m0_cs;
    logic [31:0] m0_rdata;
    logic m0_rvalid;

    logic [31:0] m1_addr;
    logic [127:0] m1_wdata;
    logic m1_we;
    logic m1_cs;
    logic [31:0] m1_rdata;
    logic m1_rvalid;

    axi_interface_master #(.id (0)) master0  (
        .clk_i      (clk_i),
        .rst_ni     (rst_ni),
        .awid_o     (m0_AWID),
        .awaddr_o   (m0_AWADDR),
        .awlen_o    (m0_AWLEN),
        .awsize_o   (m0_AWSIZE),
        .awburst_o  (m0_AWBURST),
        .awvalid_o  (m0_AWVALID),
        .awready_i  (m0_AWREADY),
        .wdata_o    (m0_WDATA),
        .wstrb_o    (m0_WSTRB),
        .wvalid_o   (m0_WVALID),
        .wlast_o    (m0_WLAST),
        .wready_i   (m0_WREADY),
        .bid_i      (m0_BID),
        .bresp_i    (m0_BRESP),
        .bvalid_i   (m0_BVALID),
        .bready_o   (m0_BREADY),
        .arid_o     (m0_ARID),
        .araddr_o   (m0_ARADDR),
        .arlen_o    (m0_ARLEN),
        .arburst_o  (m0_ARBURST),
        .arsize_o   (m0_ARSIZE),
        .arvalid_o  (m0_ARVALID),
        .arready_i  (m0_ARREADY),
        .rid_i      (m0_RID),
        .rdata_i    (m0_RDATA),
        .rresp_i    (m0_RRESP),
        .rvalid_i   (m0_RVALID),
        .rlast_i    (m0_RLAST),
        .rready_o   (m0_RREADY),
        .addr_i     (m0_addr),
        .wdata_i    (m0_wdata),
        .we_i       (m0_we),
        .cs_i       (m0_cs),
        .rdata_o    (m0_rdata),
        .rvalid_o   (m0_rvalid)
    );

    axi_interface_master #(.id (1)) master1  (
        .clk_i      (clk_i),
        .rst_ni     (rst_ni),
        .awid_o     (m1_AWID),
        .awaddr_o   (m1_AWADDR),
        .awlen_o    (m1_AWLEN),
        .awsize_o   (m1_AWSIZE),
        .awburst_o  (m1_AWBURST),
        .awvalid_o  (m1_AWVALID),
        .awready_i  (m1_AWREADY),
        .wdata_o    (m1_WDATA),
        .wstrb_o    (m1_WSTRB),
        .wvalid_o   (m1_WVALID),
        .wlast_o    (m1_WLAST),
        .wready_i   (m1_WREADY),
        .bid_i      (m1_BID),
        .bresp_i    (m1_BRESP),
        .bvalid_i   (m1_BVALID),
        .bready_o   (m1_BREADY),
        .arid_o     (m1_ARID),
        .araddr_o   (m1_ARADDR),
        .arlen_o    (m1_ARLEN),
        .arburst_o  (m1_ARBURST),
        .arsize_o   (m1_ARSIZE),
        .arvalid_o  (m1_ARVALID),
        .arready_i  (m1_ARREADY),
        .rid_i      (m1_RID),
        .rdata_i    (m1_RDATA),
        .rresp_i    (m1_RRESP),
        .rvalid_i   (m1_RVALID),
        .rlast_i    (m1_RLAST),
        .rready_o   (m1_RREADY),
        .addr_i     (m1_addr),
        .wdata_i    (m1_wdata),
        .we_i       (m1_we),
        .cs_i       (m1_cs),
        .rdata_o    (m1_rdata),
        .rvalid_o   (m1_rvalid)
    );


slave_0_sdram slave0 (
    .clk_i      (clk_i),
    .rst_ni     (rst_ni),
    .awid       (s0_AWID),
    .awaddr     (s0_AWADDR),
    .awlen      (s0_AWLEN),
    .awsize     (s0_AWSIZE),
    .awburst    (s0_AWBURST),
    .awvalid    (s0_AWVALID),
    .awready    (s0_AWREADY),
    .wdata      (s0_WDATA),
    .wstrb      (s0_WSTRB),
    .wvalid     (s0_WVALID),
    .wlast      (s0_WLAST),
    .wready     (s0_WREADY),
    .bid        (s0_BID),
    .bresp      (s0_BRESP),
    .bvalid     (s0_BVALID),
    .bready     (s0_BREADY),
    .arid       (s0_ARID),
    .araddr     (s0_ARADDR),
    .arlen      (s0_ARLEN),
    .arburst    (s0_ARBURST),
    .arsize     (s0_ARSIZE),
    .arvalid    (s0_ARVALID),
    .arready    (s0_ARREADY),
    .rid        (s0_RID),
    .rdata      (s0_RDATA),
    .rresp      (s0_RRESP),
    .rvalid     (s0_RVALID),
    .rlast      (s0_RLAST),
    .rready     (s0_RREADY)
);

slave_0_sdram slave1 (
    .clk_i      (clk_i),
    .rst_ni     (rst_ni),
    .awid       (s1_AWID),
    .awaddr     (s1_AWADDR),
    .awlen      (s1_AWLEN),
    .awsize     (s1_AWSIZE),
    .awburst    (s1_AWBURST),
    .awvalid    (s1_AWVALID),
    .awready    (s1_AWREADY),
    .wdata      (s1_WDATA),
    .wstrb      (s1_WSTRB),
    .wvalid     (s1_WVALID),
    .wlast      (s1_WLAST),
    .wready     (s1_WREADY),
    .bid        (s1_BID),
    .bresp      (s1_BRESP),
    .bvalid     (s1_BVALID),
    .bready     (s1_BREADY),
    .arid       (s1_ARID),
    .araddr     (s1_ARADDR),
    .arlen      (s1_ARLEN),
    .arburst    (s1_ARBURST),
    .arsize     (s1_ARSIZE),
    .arvalid    (s1_ARVALID),
    .arready    (s1_ARREADY),
    .rid        (s1_RID),
    .rdata      (s1_RDATA),
    .rresp      (s1_RRESP),
    .rvalid     (s1_RVALID),
    .rlast      (s1_RLAST),
    .rready     (s1_RREADY)
);

slave_0_sdram slave2 (
    .clk_i      (clk_i),
    .rst_ni     (rst_ni),
    .awid       (s2_AWID),
    .awaddr     (s2_AWADDR),
    .awlen      (s2_AWLEN),
    .awsize     (s2_AWSIZE),
    .awburst    (s2_AWBURST),
    .awvalid    (s2_AWVALID),
    .awready    (s2_AWREADY),
    .wdata      (s2_WDATA),
    .wstrb      (s2_WSTRB),
    .wvalid     (s2_WVALID),
    .wlast      (s2_WLAST),
    .wready     (s2_WREADY),
    .bid        (s2_BID),
    .bresp      (s2_BRESP),
    .bvalid     (s2_BVALID),
    .bready     (s2_BREADY)
);

slave_0_sdram slave3 (
    .clk_i      (clk_i),
    .rst_ni     (rst_ni),
    .awid       (s3_AWID),
    .awaddr     (s3_AWADDR),
    .awlen      (s3_AWLEN),
    .awsize     (s3_AWSIZE),
    .awburst    (s3_AWBURST),
    .awvalid    (s3_AWVALID),
    .awready    (s3_AWREADY),
    .wdata      (s3_WDATA),
    .wstrb      (s3_WSTRB),
    .wvalid     (s3_WVALID),
    .wlast      (s3_WLAST),
    .wready     (s3_WREADY),
    .bid        (s3_BID),
    .bresp      (s3_BRESP),
    .bvalid     (s3_BVALID),
    .bready     (s3_BREADY),
    .arid       (s3_ARID),
    .araddr     (s3_ARADDR),
    .arlen      (s3_ARLEN),
    .arburst    (s3_ARBURST),
    .arsize     (s3_ARSIZE),
    .arvalid    (s3_ARVALID),
    .arready    (s3_ARREADY),
    .rid        (s3_RID),
    .rdata      (s3_RDATA),
    .rresp      (s3_RRESP),
    .rvalid     (s3_RVALID),
    .rlast      (s3_RLAST),
    .rready     (s3_RREADY)
);


//case1: master 0 w-> slave 0 then master 1 r-> slave 0
//case2: master 0 w-> slave 0 and master 1 w-> slave 1 at the same time

    initial begin
        m0_addr     <= 32'h00000000;
        m0_wdata    <= 128'h00000000_00000000_00000000_00000000;
        m0_cs       <= 0;
        m0_we       <= 0;
        #45;
        //case 1
        m0_addr     <= 32'h00000000;
        m0_wdata    <= 128'h0000000d_0000000c_0000000b_0000000a;
        m0_cs       <= 1;
        m0_we       <= 1;
        #10;
        m0_cs       <= 0;
        //case2
        #100;
        m0_addr     <= 32'h00000000;
        m0_wdata    <= 128'h11111111_22222222_33333333_44444444;
        m0_cs       <= 1;
        m0_we       <= 1;
        #10;
        m0_cs       <= 0;
    end


    initial begin
        m1_addr     <= 32'h00000000;
        m1_wdata    <= 128'h00000000_00000000_00000000_00000000;
        m1_cs       <= 0;
        m1_we       <= 0;
        #75;
        //case 1
        m1_addr     <= 32'h00000000;
        m1_wdata    <= 128'h00000000_00000000_00000000_00000000;
        m1_cs       <= 1;
        m1_we       <= 0;
        #10;
        m1_cs       <= 0;
        //case 2
        #70;
        m1_addr     <= 32'h40000000;
        m1_wdata    <= 128'h00000000_00000000_00000000_aaaaaaaa;
        m1_cs       <= 1;
        m1_we       <= 1;
        #10;
        m1_cs       <= 0;
    end

endmodule
