`timescale 1ns/1ps
`include "../rtl/define.sv"

module cpu_tb;

    // Clock and Reset
    logic clk;
    logic rst_ni;

    // AXI signals for master_cpu and slave_0_sdram

    // AW channel signals
    logic [`ID_BITS-1:0] m_awid;
    logic [`ADDR_WIDTH-1:0] m_awaddr;
    logic [`LEN_BITS-1:0] m_awlen;
    logic [`SIZE_BITS-1:0] m_awsize;
    logic [1:0] m_awburst;
    logic m_awvalid;
    logic m_awready;
    
    // W channel signals
    logic [`DATA_WIDTH-1:0] m_wdata;
    logic [(`DATA_WIDTH/8)-1:0] m_wstrb;
    logic m_wvalid;
    logic m_wlast;
    logic m_wready;
    
    // B channel signals
    logic [`ID_BITS-1:0] m_bid;
    logic [2:0] m_bresp;
    logic m_bvalid;
    logic m_bready;
    
    // AR channel signals
    logic [`ID_BITS-1:0] m_arid;
    logic [`ADDR_WIDTH-1:0] m_araddr;
    logic [`LEN_BITS-1:0] m_arlen;
    logic [1:0] m_arburst;
    logic [`SIZE_BITS-1:0] m_arsize;
    logic m_arvalid;
    logic m_arready;
    
    // R channel signals
    logic [`ID_BITS-1:0] m_rid;
    logic [`DATA_WIDTH-1:0] m_rdata;
    logic [2:0] m_rresp;
    logic m_rvalid;
    logic m_rlast;
    logic m_rready;
    
    
    // Instantiate the Master CPU module
    master_cpu dut (
        .clk_i           (clk),
        .rst_ni          (rst_ni),
        // AW channel
        .m_awid          (m_awid),
        .m_awaddr        (m_awaddr),
        .m_awlen         (m_awlen),
        .m_awsize        (m_awsize),
        .m_awburst       (m_awburst),
        .m_awvalid       (m_awvalid),
        .m_awready       (m_awready),
        // W channel
        .m_wdata         (m_wdata),
        .m_wstrb         (m_wstrb),
        .m_wvalid        (m_wvalid),
        .m_wlast         (m_wlast),
        .m_wready        (m_wready),
        // B channel
        .m_bid           (m_bid),
        .m_bresp         (m_bresp),
        .m_bvalid        (m_bvalid),
        .m_bready        (m_bready),
        // AR channel
        .m_arid          (m_arid),
        .m_araddr        (m_araddr),
        .m_arlen         (m_arlen),
        .m_arburst       (m_arburst),
        .m_arsize        (m_arsize),
        .m_arvalid       (m_arvalid),
        .m_arready       (m_arready),
        // R channel
        .m_rid           (m_rid),
        .m_rdata         (m_rdata),
        .m_rresp         (m_rresp),
        .m_rvalid        (m_rvalid),
        .m_rlast         (m_rlast),
        .m_rready        (m_rready),
        // DMA IRQ signaling
        .dma_irq         (0),
        .dma_clear_irq   ()
    );
    
    // Instantiate the Slave SDRAM module
    slave_0_sdram sdram_inst (
        .clk_i   (clk),
        .rst_ni  (rst_ni),
        // AW channel
        .awid    (m_awid),
        .awaddr  (m_awaddr),
        .awlen   (m_awlen),
        .awsize  (m_awsize),
        .awburst (m_awburst),
        .awvalid (m_awvalid),
        .awready (m_awready),
        // W channel
        .wdata   (m_wdata),
        .wstrb   (m_wstrb),
        .wvalid  (m_wvalid),
        .wlast   (m_wlast),
        .wready  (m_wready),
        // B channel
        .bid     (m_bid),
        .bresp   (m_bresp),
        .bvalid  (m_bvalid),
        .bready  (m_bready),
        // AR channel
        .arid    (m_arid),
        .araddr  (m_araddr),
        .arlen   (m_arlen),
        .arburst (m_arburst),
        .arsize  (m_arsize),
        .arvalid (m_arvalid),
        .arready (m_arready),
        // R channel
        .rid     (m_rid),
        .rdata   (m_rdata),
        .rresp   (m_rresp),
        .rvalid  (m_rvalid),
        .rlast   (m_rlast),
        .rready  (m_rready)
    );
    
    // Clock Generation: 10ns period (100MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Reset Generation
    initial begin
        rst_ni = 0;
        #20;
        rst_ni = 1;
    end

    // Optional: Stimulus or monitor tasks can be added here.
    initial begin
        $readmemh("memory.mem", sdram_inst.sdram_inst.ram); // Load test data into SDRAM
    end

endmodule