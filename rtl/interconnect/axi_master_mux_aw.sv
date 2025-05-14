`include "../define.sv"
module axi_master_mux_aw (
    /********************/
	input   [`ID_BITS - 1:0]    m0_AWID,
    input   [`ADDR_WIDTH-1:0]   m0_AWADDR,
    input   [`LEN_BITS - 1:0]   m0_AWLEN,
    input   [`SIZE_BITS -1 :0]  m0_AWSIZE,
    input   [1:0]               m0_AWBURST,
    input                       m0_AWVALID,
    output reg                  m0_AWREADY,
    
 
    input   [`ID_BITS - 1:0]    m1_AWID,
    input   [`ADDR_WIDTH-1:0]   m1_AWADDR,
    input   [`LEN_BITS - 1:0]   m1_AWLEN,
    input   [`SIZE_BITS -1 :0]  m1_AWSIZE,
    input   [1:0]               m1_AWBURST,
    input                       m1_AWVALID,
    output reg                  m1_AWREADY,
    

    output reg   [`ID_BITS - 1:0]    awid   ,
    output reg   [`ADDR_WIDTH-1:0]   awaddr ,
    output reg   [`LEN_BITS - 1:0]   awlen  ,
    output reg   [`SIZE_BITS -1 :0]  awsize ,
    output reg   [1:0]               awburst,
    output reg                       awvalid,

    /****************/
    input                       awready,

    input                       m0_wgrnt,
	input                       m1_wgrnt

);

    always_comb begin
        case({m0_wgrnt,m1_wgrnt})    
            2'b10: begin
                awid      =  m0_AWID;
                awaddr    =  m0_AWADDR;
                awlen     =  m0_AWLEN;
                awsize    =  m0_AWSIZE;
                awburst   =  m0_AWBURST;
                awvalid   =  m0_AWVALID;
            end
            2'b01: begin
                awid      =  m1_AWID;
                awaddr    =  m1_AWADDR;
                awlen     =  m1_AWLEN;
                awsize    =  m1_AWSIZE;
                awburst   =  m1_AWBURST;
                awvalid   =  m1_AWVALID;
            end
            default: begin
                awid      =  '0;
                awaddr    =  '0;
                awlen     =  '0;
                awsize    =  '0;
                awburst   =  '0;
                awvalid   =  '0;
            end
        endcase
    end


    //---------------------------------------------------------
    always_comb begin
        case({m0_wgrnt,m1_wgrnt})
            2'b10: begin 
                m0_AWREADY = awready;
                m1_AWREADY = '0;
            end
            2'b01: begin
                m0_AWREADY = '0;
                m1_AWREADY = awready;
            end
            default: begin
                m0_AWREADY = '0;
                m1_AWREADY = '0;
            end
        endcase
    end




endmodule