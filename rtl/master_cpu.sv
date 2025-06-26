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

      input enable,
      input rd_reg_en,
      input [4:0] rd_reg_addr,
      output logic [31:0] rd_reg_data
    );
    
    logic [`ADDR_WIDTH-1:0] mem_addr_w;
    logic [`DATA_WIDTH_CACHE-1:0] mem_wdata_w, mem_rdata_w;
    logic mem_we_w,mem_cs_w,mem_rvalid_w,mem_handshaked_w;
    

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
    .we_i         (mem_we_w),
    .cs_i         (mem_cs_w),
    .rdata_o      (mem_rdata_w),
    .rvalid_o     (mem_rvalid_w)
    );
    
    riscv_cache cpu_inst (
    .clk_i          (clk_i),
    .rst_ni         (rst_ni),
    .enable         (enable),
    .addr_o         (mem_addr_w),
    .wdata_o        (mem_wdata_w),
    .we_o           (mem_we_w),
    .cs_o           (mem_cs_w),
    .rdata_i        (mem_rdata_w),
    .rvalid_i       (mem_rvalid_w),
    .e_irq          (irq),
    .rd_reg_en      (rd_reg_en),
    .rd_reg_addr    (rd_reg_addr),
    .rd_reg_data    (rd_reg_data)
    );
    
    
endmodule
