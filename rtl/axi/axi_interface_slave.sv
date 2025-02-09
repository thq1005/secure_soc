`include "define.sv"

module axi_interface_slave (
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
  input logic rready,
  //output to core
  output logic o_we,
  output logic [`ADDR_WIDTH-1:0] o_waddr,
  output logic [`DATA_WIDTH-1:0] o_wdata,
  output logic [(`DATA_WIDTH/8)-1:0] o_strb,
  output logic o_re,
  output logic [`ADDR_WIDTH-1:0] o_raddr,
  input logic [`DATA_WIDTH-1:0] i_rdata
);


logic m_awvalid;
logic m_awready;
logic [`ADDR_WIDTH-1:0] m_awaddr;
logic [1:0] m_awburst;
logic [`SIZE_BITS-1:0] m_awsize;
logic [`LEN_BITS-1:0]  m_awlen;
logic [`ID_BITS-1:0]   m_awid; 
logic axi_awready;
logic axi_wready;
logic axi_bid;
logic axi_bvalid;
logic r_bvalid;
logic [`ADDR_WIDTH-1:0] waddr;
logic [1:0] wburst;
logic [`SIZE_BITS-1:0] wsize;
logic [`LEN_BITS-1:0] wlen;

logic [`ADDR_WIDTH-1:0] next_wr_addr;
logic [`ID_BITS-1:0] r_bid;
//skidbuffer
skid_buffer awbuf (.clk_i   (clk_i),
                   .rst_ni  (rst_ni),
                   .valid_i (awvalid),
                   .ready_o (awready),
                   .data_i  ({awaddr,awburst,awsize,awlen,awid}),
                   .valid_o (m_awvalid),
                   .ready_i (m_awready),
                   .data_o  ({m_awaddr,m_awburst,m_awsize,m_awlen,m_awid}));

//assign m_awvalid = awvalid;
//assign {m_awaddr,m_awburst,m_awsize,m_awlen,m_awid} = {awaddr,awburst,awsize,awlen,awid};
//assign awready = m_awready;

always_ff @(posedge clk_i) begin
    if (!rst_ni) begin
        axi_awready <= 1;
        axi_wready  <= 0;
    end else if (m_awvalid && m_awready) begin
        axi_awready <= 0;
        axi_wready  <= 1;
    end else if (wvalid && wready) begin
        axi_awready <= (wlast) && (!bvalid || bready);
        axi_wready  <= !wlast;
    end else if (!axi_awready) begin
        if (axi_wready) 
            axi_awready <= 0;
        else if (r_bvalid && !bready) 
            axi_awready <= 0;
        else 
            axi_awready <= 1;
    end
end

axi_addr get_next_wr_addr (.i_last_addr (waddr),
                           .i_size      (wsize),
                           .i_len       (wlen),
                           .i_burst     (wburst),
                           .o_next_addr (next_wr_addr));

always_ff @(posedge clk_i) begin
    if (m_awready) begin
        waddr <= awaddr;
        wburst <= awburst;
        wsize <= awsize;
        wlen <= awlen;
    end else if (wvalid) 
        waddr <= next_wr_addr;
end


always_ff @(posedge clk_i) begin
    if (~rst_ni)
        r_bvalid <= 0;
    else if (wvalid && wready && wlast && (bvalid && !bready))
        r_bvalid <= 1;
    else if (bready)
        r_bvalid <= 0;
end

always_ff @(posedge clk_i) begin
    if (m_awready)
        r_bid <= m_awid;
    if (!bvalid || bready)
        axi_bid <= r_bid;         
end

always_ff @(posedge clk_i) begin
    if (!rst_ni) 
        axi_bvalid <= 0;
    else if (wvalid && wready && wlast)
        axi_bvalid <= 1;
    else if (bready)
        axi_bvalid <= r_bvalid;    
end

always_comb begin
    m_awready = axi_awready;
    if (wvalid && wready && wlast && (!bvalid || bready))
        m_awready = 1;
end

always_comb begin
    o_we    = (wvalid && wready);
    o_waddr = waddr;
    o_wdata = wdata;
    o_strb  = wstrb;
end

assign wready = axi_wready;
assign bvalid = axi_bvalid;
assign bid    = axi_bid;
assign bresp  = `RESP_OKAY;

//read
logic [`ADDR_WIDTH-1:0] raddr;
logic [1:0] rburst;
logic [`SIZE_BITS-1:0] rsize;
logic [`LEN_BITS-1:0] rlen;
logic [`ID_BITS-1:0] r_rid;
logic [`ADDR_WIDTH-1:0] next_rd_addr;
logic axi_arready;
logic [`LEN_BITS-1:0] axi_rlen;
logic axi_rvalid;
logic axi_rid;
logic axi_rlast;
logic [`DATA_WIDTH-1:0] axi_rdata;
always_ff @(posedge clk_i) begin
    if (!rst_ni) 
        axi_arready <= 1;
    else if (arvalid && arready)
        axi_arready <= (arlen == 0)&&o_re;
    else if (!rvalid || rready) begin
        if ((!axi_arready) && rvalid)
            axi_arready <= (axi_rlen <= 2);
    end
end

always_ff @(posedge clk_i) begin
    if (!rst_ni) begin
        axi_rlen <= 0;
    end
    else if (arvalid && arready) 
        axi_rlen <= (arlen+1) + ((rvalid && !rready) ? 1:0);
    else if (rready && rvalid)
        axi_rlen <= axi_rlen - 1;
end

always_ff @(posedge clk_i) begin
    if (o_re)
        raddr <= next_rd_addr;
    else if (arready) 
        raddr <= araddr;
end

always_ff @(posedge clk_i) begin
    if (arready) begin
        rburst <= arburst;
        rsize  <= arsize;
        rlen   <= arlen;
        r_rid  <= arid;
    end
end

axi_addr get_next_rd_addr (.i_last_addr ((arready)?araddr:raddr),
                           .i_size      ((arready)?arsize:rsize),
                           .i_len       ((arready)?arlen:rlen),
                           .i_burst     ((arready)?arburst:rburst),
                           .o_next_addr (next_rd_addr));

always_comb begin 
    o_re = (arvalid || !arready);
    if (rvalid && !rready)
        o_re = 0;
    o_raddr = (arready) ? araddr : raddr;
end

always_ff @(posedge clk_i) begin
    if (!rst_ni) 
        axi_rvalid <= 0 ;
    else if (o_re) 
        axi_rvalid <= 1;
    else if (rready) 
        axi_rvalid <= 0;
end

always_ff @(posedge clk_i) begin
    if (!rvalid || rready) begin
        if (arvalid && arready) 
            axi_rid <= arid;
        else 
            axi_rid <= r_rid;
    end
end

always_ff @(posedge clk_i) begin
    if (!rvalid || rready) begin
        if (arvalid && arready)
            axi_rlast <= (arlen == 0);
        else if (rvalid) 
            axi_rlast <= (axi_rlen == 2);
        else 
            axi_rlast <= (axi_rlen == 1);
    end     
end

always_comb begin
    axi_rdata = i_rdata;
end

assign arready = axi_arready;
assign rvalid  = axi_rvalid;
assign rid     = axi_rid;
assign rdata   = axi_rdata;
assign rresp   = 0;
assign rlast   = axi_rlast;
endmodule
