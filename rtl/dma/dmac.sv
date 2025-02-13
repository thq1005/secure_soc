`include "../define.sv"

module axi_dmac (
        input clk_i,
        input rst_ni,
        input [`ID_BITS - 1:0] s_awid,
        input [`ADDR_WIDTH - 1:0] s_awaddr,
        input [`LEN_BITS - 1:0] s_awlen,
        input [`SIZE_BITS -1 :0] s_awsize,
        input [1:0] s_awburst,
        input s_awvalid,
        output logic s_awready,
        //W channel
        input [`DATA_WIDTH - 1:0] s_wdata,
        input [(`DATA_WIDTH/8)-1:0] s_wstrb,
        input s_wvalid,
        input s_wlast,
        output logic s_wready,
        //B channel
        output logic [`ID_BITS - 1:0] s_bid,
        output logic [2:0] s_bresp,
        output logic s_bvalid,
        input s_bready,
        //AR channel
        input [`ID_BITS - 1:0] s_arid,
        input [`ADDR_WIDTH - 1:0] s_araddr,
        input [`LEN_BITS - 1:0] s_arlen,
        input [1:0] s_arburst,
        input [`SIZE_BITS - 1:0] s_arsize,
        input s_arvalid,
        output logic s_arready,
        //R channel
        output logic [`ID_BITS - 1:0] s_rid,
        output logic [`DATA_WIDTH - 1:0] s_rdata,
        output logic [2:0] s_rresp,
        output logic s_rvalid,
        output logic s_rlast,
        input s_rready,

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
        input  logic [2:0] m_bresp,
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
        input  logic [2:0] m_rresp,
        input  logic m_rvalid,
        input  logic m_rlast,
        output logic m_rready
);
    logic we_w;
    logic [`ADDR_WIDTH-1:0] waddr_w;
    logic [`DATA_WIDTH-1:0] wdata_w;
    logic [(`DATA_WIDTH/8)-1:0] strb_w;

    axi_interface_slave s_itf (
        .clk_i      (clk_i),
        .rst_ni     (rst_ni),
        .awid       (s_awid),
        .awaddr     (s_awaddr),
        .awlen      (s_awlen),
        .awsize     (s_awsize),
        .awburst    (s_awburst),
        .awvalid    (s_awvalid),
        .awready    (s_awready),
        .wdata      (s_wdata),
        .wstrb      (s_wstrb),
        .wvalid     (s_wvalid),
        .wlast      (s_wlast),
        .wready     (s_wready),
        .bid        (s_bid),
        .bresp      (s_bresp),
        .bvalid     (s_bvalid),
        .bready     (s_bready),
        .arid       (s_arid),
        .araddr     (s_araddr),
        .arlen      (s_arlen),
        .arburst    (s_arburst),
        .arsize     (s_arsize),
        .arvalid    (s_arvalid),
        .arready    (s_arready),
        .rid        (s_rid),
        .rdata      (s_rdata),
        .rresp      (s_rresp),
        .rvalid     (s_rvalid),
        .rlast      (s_rlast),
        .rready     (s_rready),
        .o_we       (we_w),
        .o_waddr    (waddr_w),
        .o_wdata    (wdata_w),
        .o_strb     (strb_w),
        .o_re       (),
        .o_raddr    (),
        .i_rdata    ()
        );

    dmac_read read_inst (
        .clk_i,
        .rst_ni,
        .valid,
        .src_addr,
        .len,
        .size,
        .burst,
        .m_arid,
        .m_araddr,
        .m_arlen,
        .m_arburst,
        .m_arsize,
        .m_arvalid,
        .m_arready,
        .m_rid,
        .m_rdata,
        .m_rresp,
        .m_rvalid,
        .m_rlast,
        .m_rready
    )

    logic [`ADDR_WIDTH-1:0] src_addr_reg;
    logic src_addr_we;
    
    logic [`ADDR_WIDTH-1:0] dst_addr_reg;
    logic dst_addr_we;

    logic [2+`SIZE_BITS+`LEN_BITS-1:0] config_reg; // | burst | size | len |
    logic config_we;                               // 12    11 10   8 7    0

    logic valid_reg;   
    logic valid_new;

    always_ff @(posedge clk_i) begin
        if (!rst_ni) begin            
            src_addr_reg  <= '0;
            dst_addr_reg  <= '0;
            config_reg    <= '0; 
            valid_reg     <= '0;
        end
        else begin
            valid_reg   <= valid_new;
            
            if (config_we) 
                config_reg <= wdata_w[2+`SIZE_BITS+`LEN_BITS-1:0];
                
            if (src_addr_we)
                src_addr_reg <= wdata_w;
            
            if (dst_addr_we)
                dst_addr_reg <= wdata_w;
        end
    end 

    always_comb begin
        config_we   = 1'b0;
        src_addr_we = 1'b0;
        dst_addr_we = 1'b0;
        valid_new   = 1'h0;  
        if (we_w) begin
            if (waddr_w == `ADDR_ADDR_SRC)
                src_addr_we = 1'b1;
            
            if (waddr_w == `ADDR_ADDR_DST) 
                dst_addr_we = 1'b1;
    
            if (waddr_w == `ADDR_CONFIG) 
                config_we = 1'b1;
            
            if (waddr_w == `ADDR_VALID)
                valid_new = wdata_i[0];
        end
    end

endmodule