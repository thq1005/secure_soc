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
    

    output reg   [`ID_BITS - 1:0]    arid   ,
    output reg   [`ADDR_WIDTH-1:0]   araddr ,
    output reg   [`LEN_BITS - 1:0]   arlen  ,
    output reg   [`SIZE_BITS -1 :0]  arsize ,
    output reg   [1:0]               arburst,
    output reg                       arvalid,

    /****************/
    input                       arready,

    input                       m0_rgrnt,
	input                       m1_rgrnt

);

    always_comb begin
        case({m0_rgrnt,m1_rgrnt})    
            2'b10: begin
                arid      =  m0_ARID;
                araddr    =  m0_ARADDR;
                arlen     =  m0_ARLEN;
                arsize    =  m0_ARSIZE;
                arburst   =  m0_ARBURST;
                arvalid   =  m0_ARVALID;
            end
            2'b01: begin
                arid      =  m1_ARID;
                araddr    =  m1_ARADDR;
                arlen     =  m1_ARLEN;
                arsize    =  m1_ARSIZE;
                arburst   =  m1_ARBURST;
                arvalid   =  m1_ARVALID;
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
        case({m0_rgrnt,m1_rgrnt})
            2'b10: begin 
                m0_ARREADY = arready;
                m1_ARREADY = '0;
            end
            2'b01: begin
                m0_ARREADY = '0;
                m1_ARREADY = arready;
            end
            default: begin
                m0_ARREADY = '0;
                m1_ARREADY = '0;
            end
        endcase
    end




endmodule