`include "define.sv"


module master_cpu(
      input logic clk_i,
      input logic rst_ni,
      // AXI interface
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
      input  logic [1:0] m_bresp,
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
      input  logic [1:0] m_rresp,
      input  logic m_rvalid,
      input  logic m_rlast,
      output logic m_rready,
      input logic irq,

      input                               M_AXIL_ARREADY,
      input          [`DATA_WIDTH-1:0]    M_AXIL_RDATA,
      input               [1:0]           M_AXIL_RRESP,
      input                               M_AXIL_RVALID,
      input                               M_AXIL_AWREADY,
      input                               M_AXIL_WREADY,
      input             [1:0]             M_AXIL_BRESP,
      input                               M_AXIL_BVALID,
      output logic    [`AW_AXIL-1 : 0]    M_AXIL_ARADDR,
      output logic                        M_AXIL_ARVALID,
      output logic                        M_AXIL_RREADY,
      output logic    [`AW_AXIL-1 : 0]    M_AXIL_AWADDR,
      output logic                        M_AXIL_AWVALID,
      output logic   [`DATA_WIDTH-1:0]    M_AXIL_WDATA,
      output logic   [3:0]                M_AXIL_WSTRB,
      output logic                        M_AXIL_WVALID,
      output logic                        M_AXIL_BREADY,

      output logic [31:0] cpu_debug

    );
    
    logic [`ADDR_WIDTH-1:0] mem_addr_w;
    logic [`DATA_WIDTH_CACHE-1:0] mem_wdata_w, mem_rdata_w, axi_rdata_w;
    logic mem_we_w,mem_cs_w,mem_rvalid_w;
    
    logic axil_re_w, axil_we_w, axi_we_w, axi_cs_w;
    logic axi_rvalid_w;
    logic axil_rvalid_w;

    axi_interface_master m_itf (
    .clk_i        (clk_i),
    .rst_ni       (rst_ni),
    .awid_o       (m_awid),
    .awaddr_o     (m_awaddr),
    .awlen_o      (m_awlen),
    .awsize_o     (m_awsize),
    .awburst_o    (m_awburst),
    .awvalid_o    (m_awvalid),
    .awready_i    (m_awready),
    .wdata_o      (m_wdata),
    .wstrb_o      (m_wstrb),
    .wvalid_o     (m_wvalid),
    .wlast_o      (m_wlast),
    .wready_i     (m_wready),
    .bid_i        (m_bid),
    .bresp_i      (m_bresp),
    .bvalid_i     (m_bvalid),
    .bready_o     (m_bready),
    .arid_o       (m_arid),
    .araddr_o     (m_araddr),
    .arlen_o      (m_arlen),
    .arburst_o    (m_arburst),
    .arsize_o     (m_arsize),
    .arvalid_o    (m_arvalid),
    .arready_i    (m_arready),
    .rid_i        (m_rid),
    .rdata_i      (m_rdata),
    .rresp_i      (m_rresp),
    .rvalid_i     (m_rvalid),
    .rlast_i      (m_rlast),
    .rready_o     (m_rready),
    .addr_i       (mem_addr_w),
    .wdata_i      (mem_wdata_w),
    .we_i         (axi_we_w),
    .cs_i         (axi_cs_w),
    .rdata_o      (axi_rdata_w),
    .rvalid_o     (axi_rvalid_w)
    );
    
    axi4_lite_master m_axil (
      .clk_i        (clk_i),
      .rst_ni       (rst_ni),
      .re           (axil_re_w),
      .we           (axil_we_w),
      .address      (mem_addr_w[`AW_AXIL-1:0]),
      .W_data       (mem_wdata_w[`DATA_WIDTH-1:0]),
      .M_ARREADY    (M_AXIL_ARREADY),
      .M_RDATA      (M_AXIL_RDATA),
      .M_RRESP      (M_AXIL_RRESP),
      .M_RVALID     (M_AXIL_RVALID),
      .M_AWREADY    (M_AXIL_AWREADY),
      .M_WREADY     (M_AXIL_WREADY),
      .M_BRESP      (M_AXIL_BRESP),
      .M_BVALID     (M_AXIL_BVALID),
      .M_ARADDR     (M_AXIL_ARADDR),
      .M_ARVALID    (M_AXIL_ARVALID),
      .M_RREADY     (M_AXIL_RREADY),
      .M_AWADDR     (M_AXIL_AWADDR),
      .M_AWVALID    (M_AXIL_AWVALID),
      .M_WDATA      (M_AXIL_WDATA),
      .M_WSTRB      (M_AXIL_WSTRB),
      .M_WVALID     (M_AXIL_WVALID),
      .M_BREADY     (M_AXIL_BREADY)
    );

    assign mem_rdata_w = (axi_rvalid_w) ? axi_rdata_w : 
                         (axil_rvalid_w) ? M_AXIL_RDATA : 0;

    assign mem_rvalid_w = axi_rvalid_w || axil_rvalid_w;

    assign axil_re_w = (mem_addr_w[31-:4] == 4'h4) && mem_cs_w && ~mem_we_w;
    assign axil_we_w = (mem_addr_w[31-:4] == 4'h4) && mem_cs_w && mem_we_w;

    assign axi_we_w = mem_we_w;
    assign axi_cs_w = mem_cs_w && (mem_addr_w[31-:4] != 4'h4);

    assign axil_rvalid_w = M_AXIL_RVALID && M_AXIL_RREADY;


    riscv_cache cpu_inst (
    .clk_i          (clk_i),
    .rst_ni         (rst_ni),
    .addr_o         (mem_addr_w),
    .wdata_o        (mem_wdata_w),
    .we_o           (mem_we_w),
    .cs_o           (mem_cs_w),
    .rdata_i        (mem_rdata_w),
    .rvalid_i       (mem_rvalid_w),
    .e_irq          (irq)
    );
    
    assign cpu_debug = {mem_rvalid_w, mem_addr_w[6:0], axi_rdata_w[7:0], mem_wdata_w[7:0]};
endmodule
