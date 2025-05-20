`include "define.sv"
module slave_2_sdio(
  input logic clk_i,
  input logic rst_ni,
  // AXI interface
  //AW channel
  input logic [`ID_BITS - 1:0] awid,
  input logic [`ADDR_WIDTH - 1:0] awaddr,
  input logic [`LEN_BITS - 1:0] awlen,
  input logic [`SIZE_BITS -1 :0] awsize,
  input logic [1:0] awburst,
  input logic awvalid,
  output logic awready,
  //W channel
  input logic [`DATA_WIDTH - 1:0] wdata,
  input logic [(`DATA_WIDTH/8)-1:0] wstrb,
  input logic wvalid,
  input logic wlast,
  output logic wready,
  //B channel
  output logic [`ID_BITS - 1:0] bid,
  output logic [1:0] bresp,
  output logic bvalid,
  input logic bready,
  //AR channel
  input logic [`ID_BITS - 1:0] arid,
  input logic [`ADDR_WIDTH - 1:0] araddr,
  input logic [`LEN_BITS - 1:0] arlen,
  input logic [1:0] arburst,
  input logic [`SIZE_BITS - 1:0] arsize,
  input logic arvalid,
  output logic arready,
  //R channel
  output logic [`ID_BITS - 1:0] rid,
  output logic [`DATA_WIDTH - 1:0] rdata,
  output logic [1:0] rresp,
  output logic rvalid,
  output logic rlast,
  input logic rready,
  output logic sd_irq,
  input logic sd_irq,

  //connect to the sd pin on fpga board
  input logic cmd_i,
  output logic cmd_o,
  output logic cmd_t,
  input logic [3:0] dat_i,
  output logic [3:0] dat_o,
  output logic [3:0] dat_t,
  output logic sdclk_o

);
    
logic we_w;
logic [`ADDR_WIDTH-1:0] waddr_w;
logic [`DATA_WIDTH-1:0] wdata_w;
logic [(`DATA_WIDTH/8)-1:0] strb_w;
logic re_w;
logic [`ADDR_WIDTH-1:0] raddr_w;
logic [`DATA_WIDTH-1:0] rdata_w;
logic [`DATA_WIDTH-1:0] rdata_r;

logic a_cs;
logic a_we;
logic [`ADDR_WIDTH-1:0] a_addr;
logic [`DATA_WIDTH-1:0] a_wdata;
logic [`DATA_WIDTH-1:0] a_rdata;

axi_interface_slave s2_itf (
.clk_i      (clk_i),
.rst_ni     (rst_ni),
.awid       (awid),
.awaddr     (awaddr),
.awlen      (awlen),
.awsize     (awsize),
.awburst    (awburst),
.awvalid    (awvalid),
.awready    (awready),
.wdata      (wdata),
.wstrb      (wstrb),
.wvalid     (wvalid),
.wlast      (wlast),
.wready     (wready),
.bid        (bid),
.bresp      (bresp),
.bvalid     (bvalid),
.bready     (bready),
.arid       (arid),
.araddr     (araddr),
.arlen      (arlen),
.arburst    (arburst),
.arsize     (arsize),
.arvalid    (arvalid),
.arready    (arready),
.rid        (rid),
.rdata      (rdata),
.rresp      (rresp),
.rvalid     (rvalid),
.rlast      (rlast),
.rready     (rready),
.o_we       (we_w),
.o_waddr    (waddr_w),
.o_wdata    (wdata_w),
.o_strb     (strb_w),
.o_re       (re_w),
.o_raddr    (raddr_w),
.i_rdata    (rdata_w)
);


sd_host_controller sd_inst(
.clk_i      (clk_i),
.rst_ni     (rst_ni),   
.waddr      (wdata_w),
.raddr      (raddr_w),
.we         (we_w),
.re         (re_w),
.wdata      (wdata_w),
.rdata      (raddr_w),
.interrupt  (sd_irq),
.cmd_i,    
.cmd_o,    
.cmd_t,    
.dat_i,    
.dat_o,    
.dat_t,    
.sdclk_o  
);

endmodule
