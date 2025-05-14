`include "../define.sv"
module axi_INTERCONNECT(
    input clk_i,
    input rst_ni,
    //Master 0 cpu
    //AW channel
    input  logic [`ID_BITS - 1:0] m0_AWID,
    input  logic [`ADDR_WIDTH - 1:0] m0_AWADDR,
    input  logic [`LEN_BITS - 1:0] m0_AWLEN,
    input  logic [`SIZE_BITS -1 :0] m0_AWSIZE,
    input  logic [1:0] m0_AWBURST,
    input  logic m0_AWVALID,
    output  logic m0_AWREADY,
    //W channel
    input logic [`DATA_WIDTH - 1:0] m0_WDATA,
    input logic [(`DATA_WIDTH/8)-1:0] m0_WSTRB,
    input logic m0_WVALID,
    input logic m0_WLAST,
    output  logic m0_WREADY,
    //B channel
    output logic [`ID_BITS - 1:0] m0_BID,
    output logic [1:0] m0_BRESP,
    output logic m0_BVALID,
    input  logic m0_BREADY,
    //AR channel
    input  logic [`ID_BITS - 1:0] m0_ARID,
    input  logic [`ADDR_WIDTH - 1:0] m0_ARADDR,
    input  logic [`LEN_BITS - 1:0] m0_ARLEN,
    input  logic [1:0] m0_ARBURST,
    input  logic [`SIZE_BITS - 1:0] m0_ARSIZE,
    input  logic m0_ARVALID,
    output  logic m0_ARREADY,
    //R channel
    output  logic [`ID_BITS - 1:0] m0_RID,
    output  logic [`DATA_WIDTH - 1:0] m0_RDATA,
    output  logic [1:0] m0_RRESP,
    output  logic m0_RVALID,
    output  logic m0_RLAST,
    input logic m0_RREADY,
    
    //Master 1 dmac
    //AW channel
    input  logic [`ID_BITS - 1:0] m1_AWID,
    input  logic [`ADDR_WIDTH - 1:0] m1_AWADDR,
    input  logic [`LEN_BITS - 1:0] m1_AWLEN,
    input  logic [`SIZE_BITS -1 :0] m1_AWSIZE,
    input  logic [1:0] m1_AWBURST,
    input  logic m1_AWVALID,
    output  logic m1_AWREADY,
    //W channel
    input logic [`DATA_WIDTH - 1:0] m1_WDATA,
    input logic [(`DATA_WIDTH/8)-1:0] m1_WSTRB,
    input logic m1_WVALID,
    input logic m1_WLAST,
    output  logic m1_WREADY,
    //B channel
    output logic [`ID_BITS - 1:0] m1_BID,
    output logic [1:0] m1_BRESP,
    output logic m1_BVALID,
    input  logic m1_BREADY,
    //AR channel
    input  logic [`ID_BITS - 1:0] m1_ARID,
    input  logic [`ADDR_WIDTH - 1:0] m1_ARADDR,
    input  logic [`LEN_BITS - 1:0] m1_ARLEN,
    input  logic [1:0] m1_ARBURST,
    input  logic [`SIZE_BITS - 1:0] m1_ARSIZE,
    input  logic m1_ARVALID,
    output  logic m1_ARREADY,
    //R channel
    output  logic [`ID_BITS - 1:0] m1_RID,
    output  logic [`DATA_WIDTH - 1:0] m1_RDATA,
    output  logic [1:0] m1_RRESP,
    output  logic m1_RVALID,
    output  logic m1_RLAST,
    input logic m1_RREADY

    //Slave 0
    //AW channel
    output logic [`ID_BITS - 1:0] s0_AWID,
    output logic [`ADDR_WIDTH - 1:0] s0_AWADDR,
    output logic [`LEN_BITS - 1:0] s0_AWLEN,
    output logic [`SIZE_BITS -1 :0] s0_AWSIZE,
    output logic [1:0] s0_AWBURST,
    output logic s0_AWVALID,
    input  logic s0_AWREADY,
    //W channel
    output logic [`DATA_WIDTH - 1:0] s0_WDATA,
    output logic [(`DATA_WIDTH/8)-1:0] s0_WSTRB,
    output logic s0_WVALID,
    output logic s0_WLAST,
    input  logic s0_WREADY,
    //B channel
    input  logic [`ID_BITS - 1:0] s0_BID,
    input  logic [1:0] s0_BRESP,
    input  logic s0_BVALID,
    output logic s0_BREADY,
    //AR channel
    output logic [`ID_BITS - 1:0] s0_ARID,
    output logic [`ADDR_WIDTH - 1:0] s0_ARADDR,
    output logic [`LEN_BITS - 1:0] s0_ARLEN,
    output logic [1:0] s0_ARBURST,
    output logic [`SIZE_BITS - 1:0] s0_ARSIZE,
    output logic s0_ARVALID,
    input  logic s0_ARREADY,
    //R channel
    input  logic [`ID_BITS - 1:0] s0_RID,
    input  logic [`DATA_WIDTH - 1:0] s0_RDATA,
    input  logic [1:0] s0_RRESP,
    input  logic s0_RVALID,
    input  logic s0_RLAST,
    output logic s0_RREADY,


    //Slave 1
    //AW channel
    output logic [`ID_BITS - 1:0] s1_AWID,
    output logic [`ADDR_WIDTH - 1:0] s1_AWADDR,
    output logic [`LEN_BITS - 1:0] s1_AWLEN,
    output logic [`SIZE_BITS -1 :0] s1_AWSIZE,
    output logic [1:0] s1_AWBURST,
    output logic s1_AWVALID,
    input  logic s1_AWREADY,
    //W channel
    output logic [`DATA_WIDTH - 1:0] s1_WDATA,
    output logic [(`DATA_WIDTH/8)-1:0] s1_WSTRB,
    output logic s1_WVALID,
    output logic s1_WLAST,
    input  logic s1_WREADY,
    //B channel
    input  logic [`ID_BITS - 1:0] s1_BID,
    input  logic [1:0] s1_BRESP,
    input  logic s1_BVALID,
    output logic s1_BREADY,
    //AR channel
    output logic [`ID_BITS - 1:0] s1_ARID,
    output logic [`ADDR_WIDTH - 1:0] s1_ARADDR,
    output logic [`LEN_BITS - 1:0] s1_ARLEN,
    output logic [1:0] s1_ARBURST,
    output logic [`SIZE_BITS - 1:0] s1_ARSIZE,
    output logic s1_ARVALID,
    input  logic s1_ARREADY,
    //R channel
    input  logic [`ID_BITS - 1:0] s1_RID,
    input  logic [`DATA_WIDTH - 1:0] s1_RDATA,
    input  logic [1:0] s1_RRESP,
    input  logic s1_RVALID,
    input  logic s1_RLAST,
    output logic s1_RREADY,

    //dmac just write
    //AW channel
    output logic [`ID_BITS - 1:0] s2_AWID,
    output logic [`ADDR_WIDTH - 1:0] s2_AWADDR,
    output logic [`LEN_BITS - 1:0] s2_AWLEN,
    output logic [`SIZE_BITS -1 :0] s2_AWSIZE,
    output logic [1:0] s2_AWBURST,
    output logic s2_AWVALID,
    input  logic s2_AWREADY,
    //W channel
    output logic [`DATA_WIDTH - 1:0] s2_WDATA,
    output logic [(`DATA_WIDTH/8)-1:0] s2_WSTRB,
    output logic s2_WVALID,
    output logic s2_WLAST,
    input  logic s2_WREADY,
    //B channel
    input  logic [`ID_BITS - 1:0] s2_BID,
    input  logic [1:0] s2_BRESP,
    input  logic s2_BVALID,
    output logic s2_BREADY,

    //Slave 3
    //AW channel
    output logic [`ID_BITS - 1:0] s3_AWID,
    output logic [`ADDR_WIDTH - 1:0] s3_AWADDR,
    output logic [`LEN_BITS - 1:0] s3_AWLEN,
    output logic [`SIZE_BITS -1 :0] s3_AWSIZE,
    output logic [1:0] s3_AWBURST,
    output logic s3_AWVALID,
    input  logic s3_AWREADY,
    //W channel
    output logic [`DATA_WIDTH - 1:0] s3_WDATA,
    output logic [(`DATA_WIDTH/8)-1:0] s3_WSTRB,
    output logic s3_WVALID,
    output logic s3_WLAST,
    input  logic s3_WREADY,
    //B channel
    input  logic [`ID_BITS - 1:0] s3_BID,
    input  logic [1:0] s3_BRESP,
    input  logic s3_BVALID,
    output logic s3_BREADY,
    //AR channel
    output logic [`ID_BITS - 1:0] s3_ARID,
    output logic [`ADDR_WIDTH - 1:0] s3_ARADDR,
    output logic [`LEN_BITS - 1:0] s3_ARLEN,
    output logic [1:0] s3_ARBURST,
    output logic [`SIZE_BITS - 1:0] s3_ARSIZE,
    output logic s3_ARVALID,
    input  logic s3_ARREADY,
    //R channel
    input  logic [`ID_BITS - 1:0] s3_RID,
    input  logic [`DATA_WIDTH - 1:0] s3_RDATA,
    input  logic [1:0] s3_RRESP,
    input  logic s3_RVALID,
    input  logic s3_RLAST,
    output logic s3_RREADY
    );

    //AW channel
    logic [`ID_BITS - 1:0]      awid;
    logic [`ADDR_WIDTH - 1:0]   awaddr;
    logic [`LEN_BITS - 1:0]     awlen;
    logic [`SIZE_BITS -1 :0]    awsize;
    logic [1:0]                 awburst;
    logic                       awvalid;
    logic                       awready;
    //W channel
    logic [`DATA_WIDTH - 1:0]   wdata;
    logic [(`DATA_WIDTH/8)-1:0] wstrb;
    logic                       wvalid;
    logic                       wlast;
    logic                       wready;
    //B channel
    logic [`ID_BITS - 1:0]      bid;
    logic [2:0]                 bresp;
    logic                       bvalid;
    logic                       bready;
    //AR channel
    logic [`ID_BITS - 1:0]      arid;
    logic [`ADDR_WIDTH - 1:0]   araddr;
    logic [`LEN_BITS - 1:0]     arlen;
    logic [1:0]                 arburst;
    logic [`SIZE_BITS - 1:0]    arsize;
    logic                       arvalid;
    logic                       arready;
    //R channel
    logic [`ID_BITS - 1:0]      rid;
    logic [`DATA_WIDTH - 1:0]   rdata;
    logic [2:0]                 rresp;
    logic                       rvalid;
    logic                       rlast;
    logic                       rready;

    logic m0_wgrnt;
    logic m1_wgrnt;

    axi_arbiter_aw arbiter_aw (.*);

    axi_master_mux_aw master_mux_aw (.*);

    axi_slave_mux_aw slave_mux_aw (.*);

    logic w_m0_wgrnt, w_m1_wgrnt;
    logic [1:0] s_wsel;

    fifo #(.DATA_W(4), 
        .DEPTH(128)) fifo_for_w_channel  (
        .clk_i,
        .rst_ni,
        .we_i (awready && awvalid && ~fifo_full),
        .re_i (ready_to_write),
        .wdata_i ({awaddr[`ADDR_WIDTH-1-:2],m1_wgrnt,m0_wgrnt}),
        .rdata_o ({s_wsel,w_m1_wgrnt,w_m0_wgrnt}),
        .full  (fifo_full),
        .empty (fifo_empty)
    );

    axi_master_mux_b master_mux_b (.*);
    axi_slave_mux_b slave_mux_b (.*);
    axi_master_mux_ar master_mux_ar (.*);
    axi_slave_mux_ar slave_mux_ar (.*);
    axi_arbiter_r arbiter_r (.*);
    axi_slave_mux_r slave_mux_r (.*);
    axi_arbiter_r arbiter_r (.*);
endmodule
