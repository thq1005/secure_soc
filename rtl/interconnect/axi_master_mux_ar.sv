`include "../define.sv"
module axi_master_mux_ar (
    /********************/
	input   [`ID_BITS - 1:0]    m0_ARID,
    input   [`ADDR_WIDTH-1:0]   m0_ARADDR,
    input   [`LEN_BITS - 1:0]   m0_ARLEN,
    input   [`SIZE_BITS -1 :0]  m0_ARSIZE,
    input   [1:0]               m0_ARBURST,
    input                       m0_ARVALID,
    output reg                  m0_ARREADY,
    
 
    input   [`ID_BITS - 1:0]    m1_ARID,
    input   [`ADDR_WIDTH-1:0]   m1_ARADDR,
    input   [`LEN_BITS - 1:0]   m1_ARLEN,
    input   [`SIZE_BITS -1 :0]  m1_ARSIZE,
    input   [1:0]               m1_ARBURST,
    input                       m1_ARVALID,
    output reg                  m1_ARREADY,
    
    input   [`ID_BITS - 1:0]    m2_ARID,
    input   [`ADDR_WIDTH-1:0]   m2_ARADDR,
    input   [`LEN_BITS - 1:0]   m2_ARLEN,
    input   [`SIZE_BITS -1 :0]  m2_ARSIZE,
    input   [1:0]               m2_ARBURST,
    input                       m2_ARVALID,
    output reg                  m2_ARREADY,

    output reg   [`ID_BITS - 1:0]    arid   ,
    output reg   [`ADDR_WIDTH-1:0]   araddr ,
    output reg   [`LEN_BITS - 1:0]   arlen  ,
    output reg   [`SIZE_BITS -1 :0]  arsize ,
    output reg   [1:0]               arburst,
    output reg                       arvalid,

    /****************/
    input                       arready,

    input                       m0_rgrnt,
	input                       m1_rgrnt,
    input                       m2_rgrnt

);

    always_comb begin
        case({m0_rgrnt,m1_rgrnt,m2_rgrnt})    
            3'b100: begin
                arid      =  m0_ARID;
                araddr    =  m0_ARADDR;
                arlen     =  m0_ARLEN;
                arsize    =  m0_ARSIZE;
                arburst   =  m0_ARBURST;
                arvalid   =  m0_ARVALID;
            end
            3'b010: begin
                arid      =  m1_ARID;
                araddr    =  m1_ARADDR;
                arlen     =  m1_ARLEN;
                arsize    =  m1_ARSIZE;
                arburst   =  m1_ARBURST;
                arvalid   =  m1_ARVALID;
            end
            3'b100: begin
                arid      =  m2_ARID;
                araddr    =  m2_ARADDR;
                arlen     =  m2_ARLEN;
                arsize    =  m2_ARSIZE;
                arburst   =  m2_ARBURST;
                arvalid   =  m2_ARVALID;
            end
            default: begin
                arid      =  '0;
                araddr    =  '0;
                arlen     =  '0;
                arsize    =  '0;
                arburst   =  '0;
                arvalid   =  '0;
            end
        endcase
    end


    //---------------------------------------------------------
    always_comb begin
        case({m0_rgrnt,m1_rgrnt,m2_rgrnt})
            3'b100: begin 
                m0_ARREADY = arready;
                m1_ARREADY = '0;
                m2_ARREADY = '0;
            end
            3'b010: begin
                m0_ARREADY = '0;
                m1_ARREADY = arready;
                m2_ARREADY = '0;
            end
            3'b001:begin
                m0_ARREADY = '0;
                m1_ARREADY = '0;
                m2_ARREADY = arready;
            end
            default: begin
                m0_ARREADY = '0;
                m1_ARREADY = '0;
                m2_ARREADY = '0;
            end
        endcase
    end




endmodule