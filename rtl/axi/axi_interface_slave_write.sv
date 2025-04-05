`include "../define.sv"

module axi_interface_slave_write (
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
  //output to core
  output logic o_we,
  output logic [`ADDR_WIDTH-1:0] o_waddr,
  output logic [`DATA_WIDTH-1:0] o_wdata,
  output logic [(`DATA_WIDTH/8)-1:0] o_strb
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
logic [`ID_BITS-1:0] axi_bid;
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
                           .i_burst     (wburst),
                           .o_next_addr (next_wr_addr));

always_ff @(posedge clk_i) begin
    if (m_awready) begin
        waddr <= m_awaddr;
        wburst <= m_awburst;
        wsize <= m_awsize;
        wlen <= m_awlen;
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
endmodule
