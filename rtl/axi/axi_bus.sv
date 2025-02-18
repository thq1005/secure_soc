`include "../define.sv"
module axi_bus(
    input clk_i,
    input rst_ni,
    //Master 0 cpu
    //AW channel
    input  logic [`ID_BITS - 1:0] m0_awid,
    input  logic [`ADDR_WIDTH - 1:0] m0_awaddr,
    input  logic [`LEN_BITS - 1:0] m0_awlen,
    input  logic [`SIZE_BITS -1 :0] m0_awsize,
    input  logic [1:0] m0_awburst,
    input  logic m0_awvalid,
    output  logic m0_awready,
    //W channel
    input logic [`DATA_WIDTH - 1:0] m0_wdata,
    input logic [(`DATA_WIDTH/8)-1:0] m0_wstrb,
    input logic m0_wvalid,
    input logic m0_wlast,
    output  logic m0_wready,
    //B channel
    output logic [`ID_BITS - 1:0] m0_bid,
    output logic [2:0] m0_bresp,
    output logic m0_bvalid,
    input  logic m0_bready,
    //AR channel
    input  logic [`ID_BITS - 1:0] m0_arid,
    input  logic [`ADDR_WIDTH - 1:0] m0_araddr,
    input  logic [`LEN_BITS - 1:0] m0_arlen,
    input  logic [1:0] m0_arburst,
    input  logic [`SIZE_BITS - 1:0] m0_arsize,
    input  logic m0_arvalid,
    output  logic m0_arready,
    //R channel
    output  logic [`ID_BITS - 1:0] m0_rid,
    output  logic [`DATA_WIDTH - 1:0] m0_rdata,
    output  logic [2:0] m0_rresp,
    output  logic m0_rvalid,
    output  logic m0_rlast,
    input logic m0_rready,
    
    //Slave 0
    //AW channel
    output logic [`ID_BITS - 1:0] s0_awid,
    output logic [`ADDR_WIDTH - 1:0] s0_awaddr,
    output logic [`LEN_BITS - 1:0] s0_awlen,
    output logic [`SIZE_BITS -1 :0] s0_awsize,
    output logic [1:0] s0_awburst,
    output logic s0_awvalid,
    input  logic s0_awready,
    //W channel
    output logic [`DATA_WIDTH - 1:0] s0_wdata,
    output logic [(`DATA_WIDTH/8)-1:0] s0_wstrb,
    output logic s0_wvalid,
    output logic s0_wlast,
    input  logic s0_wready,
    //B channel
    input  logic [`ID_BITS - 1:0] s0_bid,
    input  logic [2:0] s0_bresp,
    input  logic s0_bvalid,
    output logic s0_bready,
    //AR channel
    output logic [`ID_BITS - 1:0] s0_arid,
    output logic [`ADDR_WIDTH - 1:0] s0_araddr,
    output logic [`LEN_BITS - 1:0] s0_arlen,
    output logic [1:0] s0_arburst,
    output logic [`SIZE_BITS - 1:0] s0_arsize,
    output logic s0_arvalid,
    input  logic s0_arready,
    //R channel
    input  logic [`ID_BITS - 1:0] s0_rid,
    input  logic [`DATA_WIDTH - 1:0] s0_rdata,
    input  logic [2:0] s0_rresp,
    input  logic s0_rvalid,
    input  logic s0_rlast,
    output logic s0_rready,


    //Slave 1
    //AW channel
    output logic [`ID_BITS - 1:0] s1_awid,
    output logic [`ADDR_WIDTH - 1:0] s1_awaddr,
    output logic [`LEN_BITS - 1:0] s1_awlen,
    output logic [`SIZE_BITS -1 :0] s1_awsize,
    output logic [1:0] s1_awburst,
    output logic s1_awvalid,
    input  logic s1_awready,
    //W channel
    output logic [`DATA_WIDTH - 1:0] s1_wdata,
    output logic [(`DATA_WIDTH/8)-1:0] s1_wstrb,
    output logic s1_wvalid,
    output logic s1_wlast,
    input  logic s1_wready,
    //B channel
    input  logic [`ID_BITS - 1:0] s1_bid,
    input  logic [2:0] s1_bresp,
    input  logic s1_bvalid,
    output logic s1_bready,
    //AR channel
    output logic [`ID_BITS - 1:0] s1_arid,
    output logic [`ADDR_WIDTH - 1:0] s1_araddr,
    output logic [`LEN_BITS - 1:0] s1_arlen,
    output logic [1:0] s1_arburst,
    output logic [`SIZE_BITS - 1:0] s1_arsize,
    output logic s1_arvalid,
    input  logic s1_arready,
    //R channel
    input  logic [`ID_BITS - 1:0] s1_rid,
    input  logic [`DATA_WIDTH - 1:0] s1_rdata,
    input  logic [2:0] s1_rresp,
    input  logic s1_rvalid,
    input  logic s1_rlast,
    output logic s1_rready,

    //dmac
    //AW channel
    output logic [`ID_BITS - 1:0] s_awid,
    output logic [`ADDR_WIDTH - 1:0] s_awaddr,
    output logic [`LEN_BITS - 1:0] s_awlen,
    output logic [`SIZE_BITS -1 :0] s_awsize,
    output logic [1:0] s_awburst,
    output logic s_awvalid,
    input  logic s_awready,
    //W channel
    output logic [`DATA_WIDTH - 1:0] s_wdata,
    output logic [(`DATA_WIDTH/8)-1:0] s_wstrb,
    output logic s_wvalid,
    output logic s_wlast,
    input  logic s_wready,
    //B channel
    input  logic [`ID_BITS - 1:0] s_bid,
    input  logic [2:0] s_bresp,
    input  logic s_bvalid,
    output logic s_bready,
    //AR channel
    output logic [`ID_BITS - 1:0] s_arid,
    output logic [`ADDR_WIDTH - 1:0] s_araddr,
    output logic [`LEN_BITS - 1:0] s_arlen,
    output logic [1:0] s_arburst,
    output logic [`SIZE_BITS - 1:0] s_arsize,
    output logic s_arvalid,
    input  logic s_arready,
    //R channel
    input  logic [`ID_BITS - 1:0] s_rid,
    input  logic [`DATA_WIDTH - 1:0] s_rdata,
    input  logic [2:0] s_rresp,
    input  logic s_rvalid,
    input  logic s_rlast,
    output logic s_rready,

    //AW channel
    input  logic [`ID_BITS - 1:0] m_awid,
    input  logic [`ADDR_WIDTH - 1:0] m_awaddr,
    input  logic [`LEN_BITS - 1:0] m_awlen,
    input  logic [`SIZE_BITS -1 :0] m_awsize,
    input  logic [1:0] m_awburst,
    input  logic m_awvalid,
    output  logic m_awready,
    //W channel
    input logic [`DATA_WIDTH - 1:0] m_wdata,
    input logic [(`DATA_WIDTH/8)-1:0] m_wstrb,
    input logic m_wvalid,
    input logic m_wlast,
    output  logic m_wready,
    //B channel
    output logic [`ID_BITS - 1:0] m_bid,
    output logic [2:0] m_bresp,
    output logic m_bvalid,
    input  logic m_bready,
    //AR channel
    input  logic [`ID_BITS - 1:0] m_arid,
    input  logic [`ADDR_WIDTH - 1:0] m_araddr,
    input  logic [`LEN_BITS - 1:0] m_arlen,
    input  logic [1:0] m_arburst,
    input  logic [`SIZE_BITS - 1:0] m_arsize,
    input  logic m_arvalid,
    output  logic m_arready,
    //R channel
    output  logic [`ID_BITS - 1:0] m_rid,
    output  logic [`DATA_WIDTH - 1:0] m_rdata,
    output  logic [2:0] m_rresp,
    output  logic m_rvalid,
    output  logic m_rlast,
    input logic m_rready
    );
    
    //AW channel
    wire [`ID_BITS - 1:0] awid;
    wire [`ADDR_WIDTH - 1:0] awaddr;
    wire [`LEN_BITS - 1:0] awlen;
    wire [`SIZE_BITS -1 :0] awsize;
    wire [1:0] awburst;
    wire awvalid;
    wire awready;
    //W channel
    wire [`DATA_WIDTH - 1:0] wdata;
    wire [(`DATA_WIDTH/8)-1:0] wstrb;
    wire wvalid;
    wire wlast;
    wire wready;
    //B channel
    wire [`ID_BITS - 1:0] bid;
    wire [2:0] bresp;
    wire bvalid;
    wire bready;
    //AR channel
    wire [`ID_BITS - 1:0] arid;
    wire [`ADDR_WIDTH - 1:0] araddr;
    wire [`LEN_BITS - 1:0] arlen;
    wire [1:0] arburst;
    wire [`SIZE_BITS - 1:0] arsize;
    wire arvalid;
    wire arready;
    //R channel
    wire [`ID_BITS - 1:0] rid;
    wire [`DATA_WIDTH - 1:0] rdata;
    wire [2:0] rresp;
    wire rvalid;
    wire rlast;
    wire rready;

    logic handshaked;
    logic [`ID_BITS-1:0] wid;

    always_comb begin
        awvalid = '0;
        awid    = '0;
        awlen   = '0;
        awsize  = '0;
        awburst = '0;
        awaddr  = '0;
        if (m_awvalid) begin
            awvalid = m_awvalid;
            awid    = m_awid;
            awlen   = m_awlen;
            awsize  = m_awsize;
            awburst = m_awburst;
            awaddr  = m_awaddr;
        end
        else if (m0_awvalid) begin
            awvalid = m0_awvalid;
            awid    = m0_awid;
            awlen   = m0_awlen;
            awsize  = m0_awsize;
            awburst = m0_awburst;
            awaddr  = m0_awaddr;
        end
    end
 
    assign awready = (awid == `ID_CPU2MEM | awid == `ID_DMA2MEM) ? s0_awready :
                     (awid == `ID_CPU2DMA) ? s_awready :
                     (awid == `ID_DMA2AES) : s1_awready : 0;

    always_ff @(posedge clk_i) begin
        if (~rst_ni) 
            handshaked = 0;
        else 
            handshaked = awready && awvalid;
    end

    fifo fifo_for_w_channel (
        .clk_i,
        .rst_ni,
        .we_i (awready && awvalid),
        .re_i (handshaked),
        .wdata_i (awid),
        .rdata_o (wid),
        .full  (),
        .empty ()
    )

    always_comb begin
        if (wid == `ID_CPU2MEM || wid == `ID_CPU2DMA) begin
            wvalid = m0_wvalid;
            wlast  = m0_wlast;
            wstrb  = m0_wstrb;
            wdata  = m0_wdata;
        else if (wid == `ID_DMA2MEM || wid == `ID_DMA2AES) begin
            wvalid = m_wvalid;
            wlast  = m_wlast;
            wstrb  = m_wstrb;
            wdata  = m_wdata;
        end
        end
    end

    assign wready = (wid == `ID_CPU2MEM | wid == `ID_DMA2MEM) ? s0_wready :
                    (wid == `ID_CPU2DMA) ? s_wready :
                    (wid == `ID_DMA2AES) : s1_wready : 0;

    always_comb begin
        bid     = '0;
        bresp   = '0;
        bvalid  = '0;
        if (s0_bvalid) begin
            bid = s0_bid;
            bresp = s0_bresp;
            bvalid = s0_bvalid;
        end
        else if (s_bvalid) begin
            bid = s_bid;
            bresp = s_bresp;
            bvalid = s_bvalid;
        end
        else if (s1_bvalid) begin
            bid = s1_bid;
            bresp = s1_bresp;
            bvalid = s1_bvalid;
        end
    end

    always_comb begin
        arvalid = '0;
        arid    = '0;
        arlen   = '0;
        arsize  = '0;
        arburst = '0;
        araddr  = '0;
        if (m_awvalid) begin
            awvalid = m_awvalid;
            awid    = m_awid;
            awlen   = m_awlen;
            awsize  = m_awsize;
            awburst = m_awburst;
            awaddr  = m_awaddr;
        end
        else if (m0_awvalid) begin
            awvalid = m0_awvalid;
            awid    = m0_awid;
            awlen   = m0_awlen;
            awsize  = m0_awsize;
            awburst = m0_awburst;
            awaddr  = m0_awaddr;
        end
    end
    
    assign arready = (arid == `ID_CPU2MEM | arid == `ID_DMA2MEM) ? s0_arready :
                     (arid == `ID_CPU2DMA) ? s_arready :
                     (arid == `ID_DMA2AES) : s1_arready : 0;    

    always_comb begin
        rid = '0;
        rdata ='0;
        rvalid = '0;
        rresp = '0;
        rlast = '0;
        if (s0_rvalid) begin
            rid = s0_rid;
            rdata = s0_rdata;
            rresp = s0_rresp;
            rvalid = s0_rvalid;
            rlast = s0_rlast;
        end
        else (s1_rvalid) begin
            rid = s1_rid;
            rdata = s1_rdata;
            rresp = s1_rresp;
            rvalid = s1_rvalid;
            rlast = s1_rlast;
        end
    end

    assign rready = (rid == `ID_CPU2MEM) ? m0_rready:
                    (rid == `ID_DMA2MEM | rid == `ID_DMA2AES) ? m_rready: 0;

    //master0
    assign m0_awready = (awid == `ID_CPU2MEM || awid == `ID_CPU2DMA) ? awready : 0;
    assign m0_wready  = (wid == `ID_CPU2MEM || wid == `ID_CPU2DMA) ? wready : 0;
    assign m0_bid     = bid;
    assign m0_bresp   = bresp;
    assign m0_bvalid  = (bid == `ID_CPU2MEM || bid == `ID_CPU2DMA) ? bvalid : 0;
    assign m0_arready = (arid == `ID_CPU2MEM) ? arready : 0;
    assign m0_rid     = rid;
    assign m0_rresp   = rresp;
    assign m0_rdata   = rdata;
    assign m0_rlast   = rlast;
    assign m0_rvalid  = (rid == `ID_CPU2MEM) ? rvalid : 0;
    //dma master
    assign m_awready  = (awid == `ID_DMA2MEM || awid == `ID_DMA2AES) ? awready : 0;
    assign m_wready   = (wid == `ID_DMA2MEM || wid == `ID_DMA2AES) ? wready : 0;
    assign m_bid      = bid;
    assign m_bresp    = bresp;
    assign m_bvalid   = (bid == `ID_DMA2MEM || bid == `ID_DMA2AES) ? bvalid : 0;
    assign m_arready  = (arid == `ID_DMA2MEM || arid == `ID_DMA2AES) ? arready : 0;
    assign m_rid      = rid;
    assign m_rresp    = rresp;
    assign m_rdata    = rdata;
    assign m_rlast    = rlast;
    assign m_rvalid   = (rid == `ID_DMA2MEM || rid == `ID_DMA2AES) ? rvalid : 0;
    //slave0
    assign s0_awid    = awid;
    assign s0_awaddr  = awaddr;
    assign s0_awlen   = awlen;
    assign s0_awsize  = awsize;
    assign s0_awburst = awburst;
    assign s0_awvalid = (awid == `ID_DMA2MEM || awid == `ID_CPU2MEM) ? awvalid : 0;
    assign s0_wdata   = wdata;
    assign s0_wstrb   = wstrb;
    assign s0_wvalid  = (wid == `ID_DMA2MEM || wid == `ID_CPU2MEM) ? wready : 0;
    assign s0_wlast   = wlast;
    assign s0_bready  = (bid == `ID_DMA2MEM || bid == `ID_CPU2MEM) ? bready : 0;
    assign s0_arid    = arid;
    assign s0_araddr  = araddr;
    assign s0_arlen   = arlen;
    assign s0_arburst = arburts;
    assign s0_arsize  = arsize;
    assign s0_arvalid = (arid == `ID_DMA2MEM || arid == `ID_CPU2MEM) ? arvalid : 0;
    assign s0_rready  = (rid == `ID_DMA2MEM || rid == `ID_CPU2MEM) ? rready : 0;
    //slave1
    assign s1_awid    = awid;
    assign s1_awaddr  = awaddr;
    assign s1_awlen   = awlen;
    assign s1_awsize  = awsize;
    assign s1_awburst = awburst;
    assign s1_awvalid = (awid == `ID_DMA2AES) ? awvalid : 0;
    assign s1_wdata   = wdata;
    assign s1_wstrb   = wstrb;
    assign s1_wvalid  = (wid == `ID_DMA2AES) ? wready : 0;
    assign s1_wlast   = wlast;
    assign s1_bready  = (bid == `ID_DMA2AES) ? bready : 0;
    assign s1_arid    = arid;
    assign s1_araddr  = araddr;
    assign s1_arlen   = arlen;
    assign s1_arburst = arburts;
    assign s1_arsize  = arsize;
    assign s1_arvalid = (arid == `ID_DMA2AES) ? arvalid : 0;
    assign s1_rready  = (rid == `ID_DMA2AES) ? rready : 0;
    //dma
    assign s_awid    = awid;
    assign s_awaddr  = awaddr;
    assign s_awlen   = awlen;
    assign s_awsize  = awsize;
    assign s_awburst = awburst;
    assign s_awvalid = (awid == `ID_CPU2DMA) ? awvalid : 0;
    assign s_wdata   = wdata;
    assign s_wstrb   = wstrb;
    assign s_wvalid  = (wid == `ID_CPU2DMA) ? wready : 0;
    assign s_wlast   = wlast;
    assign s_bready  = (bid == `ID_CPU2DMA) ? bready : 0;
    assign s_arid    = arid;
    assign s_araddr  = araddr;
    assign s_arlen   = arlen;
    assign s_arburst = arburts;
    assign s_arsize  = arsize;
    assign s_arvalid = (arid == `ID_CPU2DMA) ? arvalid : 0;
    assign s_rready  = (rid == `ID_CPU2DMA) ? rready : 0;


endmodule
