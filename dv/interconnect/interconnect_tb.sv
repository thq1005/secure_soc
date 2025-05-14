`timescale 1ns/1ns

module tb_AXI_Interconnect();

    // Parameters matching AXI_Interconnect
    parameter DATA_WIDTH = 32;
    parameter ADDR_WIDTH = 32;
    parameter ID_WIDTH = 16;
    parameter STRB_WIDTH = DATA_WIDTH/8;

    // Clock and Reset
    logic ACLK;
    logic ARESETn;

    // Master 0 (CPU) Signals
    logic [ID_WIDTH-1:0]   m0_AWID;
    logic [ADDR_WIDTH-1:0] m0_AWADDR;
    logic [7:0]            m0_AWLEN;
    logic [2:0]            m0_AWSIZE;
    logic [1:0]            m0_AWBURST;
    logic                  m0_AWVALID;
    logic                  m0_AWREADY;

    logic [ID_WIDTH-1:0]   m0_WID;
    logic [DATA_WIDTH-1:0] m0_WDATA;
    logic [STRB_WIDTH-1:0] m0_WSTRB;
    logic                  m0_WLAST;
    logic                  m0_WVALID;
    logic                  m0_WREADY;

    logic                  m0_BVALID;
    logic                  m0_BREADY;

    logic [ID_WIDTH-1:0]   m0_ARID;
    logic [ADDR_WIDTH-1:0] m0_ARADDR;
    logic [7:0]            m0_ARLEN;
    logic [2:0]            m0_ARSIZE;
    logic [1:0]            m0_ARBURST;
    logic                  m0_ARVALID;
    logic                  m0_ARREADY;

    logic                  m0_RVALID;
    logic                  m0_RREADY;

    // Master 1 (DMA) Signals
    logic [ID_WIDTH-1:0]   m1_AWID;
    logic [ADDR_WIDTH-1:0] m1_AWADDR;
    logic [7:0]            m1_AWLEN;
    logic [2:0]            m1_AWSIZE;
    logic [1:0]            m1_AWBURST;
    logic                  m1_AWVALID;
    logic                  m1_AWREADY;

    logic [ID_WIDTH-1:0]   m1_WID;
    logic [DATA_WIDTH-1:0] m1_WDATA;
    logic [STRB_WIDTH-1:0] m1_WSTRB;
    logic                  m1_WLAST;
    logic                  m1_WVALID;
    logic                  m1_WREADY;

    logic                  m1_BVALID;
    logic                  m1_BREADY;

    logic [ID_WIDTH-1:0]   m1_ARID;
    logic [ADDR_WIDTH-1:0] m1_ARADDR;
    logic [7:0]            m1_ARLEN;
    logic [2:0]            m1_ARSIZE;
    logic [1:0]            m1_ARBURST;
    logic                  m1_ARVALID;
    logic                  m1_ARREADY;

    logic                  m1_RVALID;
    logic                  m1_RREADY; 

    // Slave 0 Signals
    logic                  s0_AWVALID;
    logic                  s0_AWREADY;
    logic                  s0_WVALID;
    logic                  s0_WREADY;
    logic [ID_WIDTH-1:0]   s0_BID;
    logic [1:0]            s0_BRESP;
    logic                  s0_BVALID;
    logic                  s0_BREADY;
    logic                  s0_ARVALID;
    logic                  s0_ARREADY;
    logic [ID_WIDTH-1:0]   s0_RID;
    logic [DATA_WIDTH-1:0] s0_RDATA;
    logic [1:0]            s0_RRESP;
    logic                  s0_RLAST;
    logic                  s0_RVALID;
    logic                  s0_RREADY;

    // Slave 1 Signals
    logic                  s1_AWVALID;
    logic                  s1_AWREADY;
    logic                  s1_WVALID;
    logic                  s1_WREADY;
    logic [ID_WIDTH-1:0]   s1_BID;
    logic [1:0]            s1_BRESP;
    logic [USER_WIDTH-1:0] s1_BUSER;
    logic                  s1_BVALID;
    logic                  s1_BREADY;
    logic                  s1_ARVALID;
    logic                  s1_ARREADY;
    logic [ID_WIDTH-1:0]   s1_RID;
    logic [DATA_WIDTH-1:0] s1_RDATA;
    logic [1:0]            s1_RRESP;
    logic                  s1_RLAST;
    logic [USER_WIDTH-1:0] s1_RUSER;
    logic                  s1_RVALID;
    logic                  s1_RREADY;

    // Slave 2 Signals
    logic                  s2_AWVALID;
    logic                  s2_AWREADY;
    logic                  s2_WVALID;
    logic                  s2_WREADY;
    logic [ID_WIDTH-1:0]   s2_BID;
    logic [1:0]            s2_BRESP;
    logic [USER_WIDTH-1:0] s2_BUSER;
    logic                  s2_BVALID;
    logic                  s2_BREADY;
    logic                  s2_ARVALID;
    logic                  s2_ARREADY;
    logic [ID_WIDTH-1:0]   s2_RID;
    logic [DATA_WIDTH-1:0] s2_RDATA;
    logic [1:0]            s2_RRESP;
    logic                  s2_RLAST;
    logic [USER_WIDTH-1:0] s2_RUSER;
    logic                  s2_RVALID;
    logic                  s2_RREADY;

    // Slave 3 Signals
    logic                  s3_AWVALID;
    logic                  s3_AWREADY;
    logic                  s3_WVALID;
    logic                  s3_WREADY;
    logic [ID_WIDTH-1:0]   s3_BID;
    logic [1:0]            s3_BRESP;
    logic [USER_WIDTH-1:0] s3_BUSER;
    logic                  s3_BVALID;
    logic                  s3_BREADY;
    logic                  s3_ARVALID;
    logic                  s3_ARREADY;
    logic [ID_WIDTH-1:0]   s3_RID;
    logic [DATA_WIDTH-1:0] s3_RDATA;
    logic [1:0]            s3_RRESP;
    logic                  s3_RLAST;
    logic [USER_WIDTH-1:0] s3_RUSER;
    logic                  s3_RVALID;
    logic                  s3_RREADY;

    // Common Slave Response Signals
    logic [ID_WIDTH-1:0]   m_BID;
    logic [1:0]            m_BRESP;
    logic [USER_WIDTH-1:0] m_BUSER;
    logic [ID_WIDTH-1:0]   m_RID;
    logic [DATA_WIDTH-1:0] m_RDATA;
    logic [1:0]            m_RRESP;
    logic                  m_RLAST;
    logic [USER_WIDTH-1:0] m_RUSER;

    // Clock Generation
    initial begin
        ACLK = 0;
        forever #5 ACLK = ~ACLK; // 100 MHz clock (10 ns period)
    end

    // Reset Generation
    initial begin
        ARESETn = 0;
        #20 ARESETn = 1; // Release reset after 20 ns
    end

    // Instantiate the DUT (Device Under Test)
    AXI_Interconnect #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .ID_WIDTH(ID_WIDTH),
        .USER_WIDTH(USER_WIDTH),
        .STRB_WIDTH(STRB_WIDTH)
    ) dut (
        .ACLK(ACLK),
        .ARESETn(ARESETn),
        .m0_AWID(m0_AWID),
        .m0_AWADDR(m0_AWADDR),
        .m0_AWLEN(m0_AWLEN),
        .m0_AWSIZE(m0_AWSIZE),
        .m0_AWBURST(m0_AWBURST),
        .m0_AWLOCK(m0_AWLOCK),
        .m0_AWCACHE(m0_AWCACHE),
        .m0_AWPROT(m0_AWPROT),
        .m0_AWQOS(m0_AWQOS),
        .m0_AWREGION(m0_AWREGION),
        .m0_AWUSER(m0_AWUSER),
        .m0_AWVALID(m0_AWVALID),
        .m0_AWREADY(m0_AWREADY),
        .m0_WID(m0_WID),
        .m0_WDATA(m0_WDATA),
        .m0_WSTRB(m0_WSTRB),
        .m0_WLAST(m0_WLAST),
        .m0_WUSER(m0_WUSER),
        .m0_WVALID(m0_WVALID),
        .m0_WREADY(m0_WREADY),
        .m0_BVALID(m0_BVALID),
        .m0_BREADY(m0_BREADY),
        .m0_ARID(m0_ARID),
        .m0_ARADDR(m0_ARADDR),
        .m0_ARLEN(m0_ARLEN),
        .m0_ARSIZE(m0_ARSIZE),
        .m0_ARBURST(m0_ARBURST),
        .m0_ARLOCK(m0_ARLOCK),
        .m0_ARCACHE(m0_ARCACHE),
        .m0_ARPROT(m0_ARPROT),
        .m0_ARQOS(m0_ARQOS),
        .m0_ARREGION(m0_ARREGION),
        .m0_ARUSER(m0_ARUSER),
        .m0_ARVALID(m0_ARVALID),
        .m0_ARREADY(m0_ARREADY),
        .m0_RVALID(m0_RVALID),
        .m0_RREADY(m0_RREADY),
        .m1_AWID(m1_AWID),
        .m1_AWADDR(m1_AWADDR),
        .m1_AWLEN(m1_AWLEN),
        .m1_AWSIZE(m1_AWSIZE),
        .m1_AWBURST(m1_AWBURST),
        .m1_AWLOCK(m1_AWLOCK),
        .m1_AWCACHE(m1_AWCACHE),
        .m1_AWPROT(m1_AWPROT),
        .m1_AWQOS(m1_AWQOS),
        .m1_AWREGION(m1_AWREGION),
        .m1_AWUSER(m1_AWUSER),
        .m1_AWVALID(m1_AWVALID),
        .m1_AWREADY(m1_AWREADY),
        .m1_WID(m1_WID),
        .m1_WDATA(m1_WDATA),
        .m1_WSTRB(m1_WSTRB),
        .m1_WLAST(m1_WLAST),
        .m1_WUSER(m1_WUSER),
        .m1_WVALID(m1_WVALID),
        .m1_WREADY(m1_WREADY),
        .m1_BVALID(m1_BVALID),
        .m1_BREADY(m1_BREADY),
        .m1_ARID(m1_ARID),
        .m1_ARADDR(m1_ARADDR),
        .m1_ARLEN(m1_ARLEN),
        .m1_ARSIZE(m1_ARSIZE),
        .m1_ARBURST(m1_ARBURST),
        .m1_ARLOCK(m1_ARLOCK),
        .m1_ARCACHE(m1_ARCACHE),
        .m1_ARPROT(m1_ARPROT),
        .m1_ARQOS(m1_ARQOS),
        .m1_ARREGION(m1_ARREGION),
        .m1_ARUSER(m1_ARUSER),
        .m1_ARVALID(m1_ARVALID),
        .m1_ARREADY(m1_ARREADY),
        .m1_RVALID(m1_RVALID),
        .m1_RREADY(m1_RREADY),
        .m_BID(m_BID),
        .m_BRESP(m_BRESP),
        .m_BUSER(m_BUSER),
        .m_RID(m_RID),
        .m_RDATA(m_RDATA),
        .m_RRESP(m_RRESP),
        .m_RLAST(m_RLAST),
        .m_RUSER(m_RUSER),
        .s0_AWVALID(s0_AWVALID),
        .s0_AWREADY(s0_AWREADY),
        .s0_WVALID(s0_WVALID),
        .s0_WREADY(s0_WREADY),
        .s0_BID(s0_BID),
        .s0_BRESP(s0_BRESP),
        .s0_BUSER(s0_BUSER),
        .s0_BVALID(s0_BVALID),
        .s0_BREADY(s0_BREADY),
        .s0_ARVALID(s0_ARVALID),
        .s0_ARREADY(s0_ARREADY),
        .s0_RID(s0_RID),
        .s0_RDATA(s0_RDATA),
        .s0_RRESP(s0_RRESP),
        .s0_RLAST(s0_RLAST),
        .s0_RUSER(s0_RUSER),
        .s0_RVALID(s0_RVALID),
        .s0_RREADY(s0_RREADY),
        .s1_AWVALID(s1_AWVALID),
        .s1_AWREADY(s1_AWREADY),
        .s1_WVALID(s1_WVALID),
        .s1_WREADY(s1_WREADY),
        .s1_BID(s1_BID),
        .s1_BRESP(s1_BRESP),
        .s1_BUSER(s1_BUSER),
        .s1_BVALID(s1_BVALID),
        .s1_BREADY(s1_BREADY),
        .s1_ARVALID(s1_ARVALID),
        .s1_ARREADY(s1_ARREADY),
        .s1_RID(s1_RID),
        .s1_RDATA(s1_RDATA),
        .s1_RRESP(s1_RRESP),
        .s1_RLAST(s1_RLAST),
        .s1_RUSER(s1_RUSER),
        .s1_RVALID(s1_RVALID),
        .s1_RREADY(s1_RREADY),
        .s2_AWVALID(s2_AWVALID),
        .s2_AWREADY(s2_AWREADY),
        .s2_WVALID(s2_WVALID),
        .s2_WREADY(s2_WREADY),
        .s2_BID(s2_BID),
        .s2_BRESP(s2_BRESP),
        .s2_BUSER(s2_BUSER),
        .s2_BVALID(s2_BVALID),
        .s2_BREADY(s2_BREADY),
        .s2_ARVALID(s2_ARVALID),
        .s2_ARREADY(s2_ARREADY),
        .s2_RID(s2_RID),
        .s2_RDATA(s2_RDATA),
        .s2_RRESP(s2_RRESP),
        .s2_RLAST(s2_RLAST),
        .s2_RUSER(s2_RUSER),
        .s2_RVALID(s2_RVALID),
        .s2_RREADY(s2_RREADY),
        .s3_AWVALID(s3_AWVALID),
        .s3_AWREADY(s3_AWREADY),
        .s3_WVALID(s3_WVALID),
        .s3_WREADY(s3_WREADY),
        .s3_BID(s3_BID),
        .s3_BRESP(s3_BRESP),
        .s3_BUSER(s3_BUSER),
        .s3_BVALID(s3_BVALID),
        .s3_BREADY(s3_BREADY),
        .s3_ARVALID(s3_ARVALID),
        .s3_ARREADY(s3_ARREADY),
        .s3_RID(s3_RID),
        .s3_RDATA(s3_RDATA),
        .s3_RRESP(s3_RRESP),
        .s3_RLAST(s3_RLAST),
        .s3_RUSER(s3_RUSER),
        .s3_RVALID(s3_RVALID),
        .s3_RREADY(s3_RREADY),
        .s_AWID(s_AWID),
        .s_AWADDR(s_AWADDR),
        .s_AWLEN(s_AWLEN),
        .s_AWSIZE(s_AWSIZE),
        .s_AWBURST(s_AWBURST),
        .s_AWLOCK(s_AWLOCK),
        .s_AWCACHE(s_AWCACHE),
        .s_AWPROT(s_AWPROT),
        .s_AWQOS(s_AWQOS),
        .s_AWREGION(s_AWREGION),
        .s_AWUSER(s_AWUSER),
        .s_WID(s_WID),
        .s_WDATA(s_WDATA),
        .s_WSTRB(s_WSTRB),
        .s_WLAST(s_WLAST),
        .s_WUSER(s_WUSER),
        .s_ARID(s_ARID),
        .s_ARADDR(s_ARADDR),
        .s_ARLEN(s_ARLEN),
        .s_ARSIZE(s_ARSIZE),
        .s_ARBURST(s_ARBURST),
        .s_ARLOCK(s_ARLOCK),
        .s_ARCACHE(s_ARCACHE),
        .s_ARPROT(s_ARPROT),
        .s_ARQOS(s_ARQOS),
        .s_ARREGION(s_ARREGION),
        .s_ARUSER(s_ARUSER)
    );

    // Test Scenario
    initial begin
        // Initialize signals
        m0_AWID = 0; m0_AWADDR = 0; m0_AWLEN = 0; m0_AWSIZE = 0; m0_AWBURST = 0;
        m0_AWLOCK = 0; m0_AWCACHE = 0; m0_AWPROT = 0; m0_AWQOS = 0; m0_AWREGION = 0;
        m0_AWUSER = 0; m0_AWVALID = 0;
        m0_WID = 0; m0_WDATA = 0; m0_WSTRB = 0; m0_WLAST = 0; m0_WUSER = 0; m0_WVALID = 0;
        m0_BREADY = 0;
        m0_ARID = 0; m0_ARADDR = 0; m0_ARLEN = 0; m0_ARSIZE = 0; m0_ARBURST = 0;
        m0_ARLOCK = 0; m0_ARCACHE = 0; m0_ARPROT = 0; m0_ARQOS = 0; m0_ARREGION = 0;
        m0_ARUSER = 0; m0_ARVALID = 0; m0_RREADY = 0;

        m1_AWID = 0; m1_AWADDR = 0; m1_AWLEN = 0; m1_AWSIZE = 0; m1_AWBURST = 0;
        m1_AWLOCK = 0; m1_AWCACHE = 0; m1_AWPROT = 0; m1_AWQOS = 0; m1_AWREGION = 0;
        m1_AWUSER = 0; m1_AWVALID = 0;
        m1_WID = 0; m1_WDATA = 0; m1_WSTRB = 0; m1_WLAST = 0; m1_WUSER = 0; m1_WVALID = 0;
        m1_BREADY = 0;
        m1_ARID = 0; m1_ARADDR = 0; m1_ARLEN = 0; m1_ARSIZE = 0; m1_ARBURST = 0;
        m1_ARLOCK = 0; m1_ARCACHE = 0; m1_ARPROT = 0; m1_ARQOS = 0; m1_ARREGION = 0;
        m1_ARUSER = 0; m1_ARVALID = 0; m1_RREADY = 0;

        s0_AWREADY = 0; s0_WREADY = 0; s0_BID = 0; s0_BRESP = 0; s0_BUSER = 0; s0_BVALID = 0;
        s0_ARREADY = 0; s0_RID = 0; s0_RDATA = 0; s0_RRESP = 0; s0_RLAST = 0; s0_RUSER = 0; s0_RVALID = 0;

        s1_AWREADY = 0; s1_WREADY = 0; s1_BID = 0; s1_BRESP = 0; s1_BUSER = 0; s1_BVALID = 0;
        s1_ARREADY = 0; s1_RID = 0; s1_RDATA = 0; s1_RRESP = 0; s1_RLAST = 0; s1_RUSER = 0; s1_RVALID = 0;

        s2_AWREADY = 0; s2_WREADY = 0; s2_BID = 0; s2_BRESP = 0; s2_BUSER = 0; s2_BVALID = 0;
        s2_ARREADY = 0; s2_RID = 0; s2_RDATA = 0; s2_RRESP = 0; s2_RLAST = 0; s2_RUSER = 0; s2_RVALID = 0;

        s3_AWREADY = 0; s3_WREADY = 0; s3_BID = 0; s3_BRESP = 0; s3_BUSER = 0; s3_BVALID = 0;
        s3_ARREADY = 0; s3_RID = 0; s3_RDATA = 0; s3_RRESP = 0; s3_RLAST = 0; s3_RUSER = 0; s3_RVALID = 0;

        // Wait for reset to deassert
        @(posedge ARESETn);
        @(posedge ACLK);

        // Test Case 1: Write Transaction (AW/W/B)
        // Master 0 (CPU) initiates a write
        m0_AWID = 16'h0001;
        m0_AWADDR = 32'h00000000; // Targets Slave 0 (address decoding: 3'b000)
        m0_AWLEN = 8'h03; // Burst length 4
        m0_AWSIZE = 3'b010; // 4 bytes per transfer
        m0_AWBURST = 2'b01; // INCR burst
        m0_AWVALID = 1;

        @(posedge ACLK);
        wait(m0_AWREADY);
        @(posedge ACLK);
        m0_AWVALID = 0;

        // Master 0 sends write data
        m0_WID = 16'h0001;
        m0_WDATA = 32'hDEADBEEF;
        m0_WSTRB = 4'b1111;
        m0_WLAST = 0;
        m0_WVALID = 1;

        @(posedge ACLK);
        wait(m0_WREADY);
        @(posedge ACLK);
        m0_WDATA = 32'hCAFEBABE;
        @(posedge ACLK);
        wait(m0_WREADY);
        @(posedge ACLK);
        m0_WDATA = 32'h12345678;
        @(posedge ACLK);
        wait(m0_WREADY);
        @(posedge ACLK);
        m0_WDATA = 32'h87654321;
        m0_WLAST = 1;
        @(posedge ACLK);
        wait(m0_WREADY);
        @(posedge ACLK);
        m0_WVALID = 0;

        // Master 0 waits for B response
        m0_BREADY = 1;
        wait(m0_BVALID);
        @(posedge ACLK);
        m0_BREADY = 0;

        // Master 1 (DMA) initiates a write after Master 0 completes
        m1_AWID = 16'h0002;
        m1_AWADDR = 32'h00000000; // Targets Slave 0
        m1_AWLEN = 8'h01; // Burst length 2
        m1_AWSIZE = 3'b010;
        m1_AWBURST = 2'b01;
        m1_AWVALID = 1;

        @(posedge ACLK);
        wait(m1_AWREADY);
        @(posedge ACLK);
        m1_AWVALID = 0;

        // Master 1 sends write data
        m1_WID = 16'h0002;
        m1_WDATA = 32'h5555AAAA;
        m1_WSTRB = 4'b1111;
        m1_WLAST = 0;
        m1_WVALID = 1;

        @(posedge ACLK);
        wait(m1_WREADY);
        @(posedge ACLK);
        m1_WDATA = 32'hAAAA5555;
        m1_WLAST = 1;
        @(posedge ACLK);
        wait(m1_WREADY);
        @(posedge ACLK);
        m1_WVALID = 0;

        // Master 1 waits for B response
        m1_BREADY = 1;
        wait(m1_BVALID);
        @(posedge ACLK);
        m1_BREADY = 0;

        // Test Case 1: Read Transaction (AR/R)
        // Master 0 (CPU) initiates a read
        m0_ARID = 16'h0001;
        m0_ARADDR = 32'h00000000; // Targets Slave 0
        m0_ARLEN = 8'h03; // Burst length 4
        m0_ARSIZE = 3'b010;
        m0_ARBURST = 2'b01;
        m0_ARVALID = 1;

        @(posedge ACLK);
        wait(m0_ARREADY);
        @(posedge ACLK);
        m0_ARVALID = 0;

        // Master 0 waits for read data
        m0_RREADY = 1;
        repeat(4) begin
            wait(m0_RVALID);
            @(posedge ACLK);
        end
        m0_RREADY = 0;

        // Master 1 (DMA) initiates a read after Master 0 completes
        m1_ARID = 16'h0002;
        m1_ARADDR = 32'h00000000; // Targets Slave 0
        m1_ARLEN = 8'h01; // Burst length 2
        m1_ARSIZE = 3'b010;
        m1_ARBURST = 2'b01;
        m1_ARVALID = 1;

        @(posedge ACLK);
        wait(m1_ARREADY);
        @(posedge ACLK);
        m1_ARVALID = 0;

        // Master 1 waits for read data
        m1_RREADY = 1;
        repeat(2) begin
            wait(m1_RVALID);
            @(posedge ACLK);
        end
        m1_RREADY = 0;

        // End simulation
        #100;
        $finish;
    end

    // Slave 0 Response (Simple Slave Model)
    initial begin
        forever begin
            // Respond to AW
            wait(s0_AWVALID);
            @(posedge ACLK);
            s0_AWREADY = 1;
            @(posedge ACLK);
            s0_AWREADY = 0;

            // Respond to W
            repeat(4) begin // For Master 0
                wait(s0_WVALID);
                @(posedge ACLK);
                s0_WREADY = 1;
                @(posedge ACLK);
                s0_WREADY = 0;
            end

            // Send B response
            @(posedge ACLK);
            s0_BID = s_AWID;
            s0_BRESP = 2'b00; // OKAY
            s0_BUSER = 0;
            s0_BVALID = 1;
            wait(s0_BREADY);
            @(posedge ACLK);
            s0_BVALID = 0;

            // Respond to AW from Master 1
            wait(s0_AWVALID);
            @(posedge ACLK);
            s0_AWREADY = 1;
            @(posedge ACLK);
            s0_AWREADY = 0;

            // Respond to W from Master 1
            repeat(2) begin
                wait(s0_WVALID);
                @(posedge ACLK);
                s0_WREADY = 1;
                @(posedge ACLK);
                s0_WREADY = 0;
            end

            // Send B response
            @(posedge ACLK);
            s0_BID = s_AWID;
            s0_BRESP = 2'b00; // OKAY
            s0_BUSER = 0;
            s0_BVALID = 1;
            wait(s0_BREADY);
            @(posedge ACLK);
            s0_BVALID = 0;
        end
    end

    initial begin
        forever begin
            // Respond to AR
            wait(s0_ARVALID);
            @(posedge ACLK);
            s0_ARREADY = 1;
            @(posedge ACLK);
            s0_ARREADY = 0;

            // Send read data
            repeat(4) begin // For Master 0
                @(posedge ACLK);
                s0_RID = s_ARID;
                s0_RDATA = $random;
                s0_RRESP = 2'b00; // OKAY
                s0_RLAST = (s0_ARLEN == 8'h00);
                s0_RUSER = 0;
                s0_RVALID = 1;
                s0_ARLEN = s0_ARLEN - 1;
                wait(s0_RREADY);
                @(posedge ACLK);
                s0_RVALID = 0;
            end

            // Respond to AR from Master 1
            wait(s0_ARVALID);
            @(posedge ACLK);
            s0_ARREADY = 1;
            @(posedge ACLK);
            s0_ARREADY = 0;

            // Send read data
            repeat(2) begin // For Master 1
                @(posedge ACLK);
                s0_RID = s_ARID;
                s0_RDATA = $random;
                s0_RRESP = 2'b00; // OKAY
                s0_RLAST = (s1_ARLEN == 8'h00);
                s0_RUSER = 0;
                s0_RVALID = 1;
                s1_ARLEN = s1_ARLEN - 1;
                wait(s0_RREADY);
                @(posedge ACLK);
                s0_RVALID = 0;
            end
        end
    end

    // Dump waveform
    initial begin
        $dumpfile("tb_AXI_Interconnect.vcd");
        $dumpvars(0, tb_AXI_Interconnect);
    end

endmodule