`include "define.sv"
module slave_0_sdram(
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
  output logic [2:0] bresp,
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
  output logic [2:0] rresp,
  output logic rvalid,
  output logic rlast,
  input logic rready
);
    
logic we_w;
logic [`ADDR_WIDTH-1:0] waddr_w;
logic [`DATA_WIDTH-1:0] wdata_w;
logic [(`DATA_WIDTH/8)-1:0] strb_w;
logic re_w;
logic [`ADDR_WIDTH-1:0] raddr_w;
logic [`DATA_WIDTH-1:0] rdata_w;

logic r_cs;

axi_interface_slave s1_itf (
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

always_comb begin
    r_cs = 0;
    if (we_w || re_w) 
        r_cs = 1;
end


ram sdram_inst(
.clk_i    (clk_i),
.rst_ni   (rst_ni),   
.cs_i     (r_cs),
.we_i     (we_w),
.re_i     (re_w),
.raddr_i  (raddr_w),
.waddr_i  (waddr_w),
.wdata_i  (wdata_w),
.rdata_o  (rdata_w)
);

endmodule
