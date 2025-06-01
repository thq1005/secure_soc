`include "../define.sv"
module axi_master_mux_w (
    /********************/
    input   [`DATA_WIDTH - 1:0] m0_WDATA,
    input [(`DATA_WIDTH/8)-1:0] m0_WSTRB,
    input                       m0_WLAST,
    input                       m0_WVALID,
    output   logic              m0_WREADY,

    input   [`DATA_WIDTH - 1:0] m1_WDATA,
    input [(`DATA_WIDTH/8)-1:0] m1_WSTRB,
    input                       m1_WLAST,
    input                       m1_WVALID,
    output logic                m1_WREADY,

    input   [`DATA_WIDTH - 1:0] m2_WDATA,
    input [(`DATA_WIDTH/8)-1:0] m2_WSTRB,
    input                       m2_WLAST,
    input                       m2_WVALID,
    output logic                m2_WREADY,
    output logic [`DATA_WIDTH - 1:0] wdata,
    output logic [(`DATA_WIDTH/8)-1:0] wstrb,
    output logic                wlast,
    output logic                wvalid,
    input                       wready,
    /****************/
    input                       w_m0_wgrnt,
	input                       w_m1_wgrnt,
    input                       w_m2_wgrnt
);

    always_comb begin
        case({w_m0_wgrnt,w_m1_wgrnt,w_m2_wgrnt})    
            3'b100: begin
                wdata    =  m0_WDATA;
                wstrb    =  m0_WSTRB;
                wlast    =  m0_WLAST;
                wvalid   =  m0_WVALID;
            end
            3'b010: begin
                wdata    =  m1_WDATA;
                wstrb    =  m1_WSTRB;
                wlast    =  m1_WLAST;
                wvalid   =  m1_WVALID;
            end
            3'b001: begin
                wdata    =  m2_WDATA;
                wstrb    =  m2_WSTRB;
                wlast    =  m2_WLAST;
                wvalid   =  m2_WVALID;
            end
            default: begin
                wdata    =  '0;
                wstrb    =  '0;
                wlast    =  '0;
                wvalid   =  '0;
            end
        endcase
    end


    //---------------------------------------------------------
    always_comb begin
        case({w_m0_wgrnt,w_m1_wgrnt,w_m2_wgrnt})
            3'b100: begin 
                m0_WREADY = wready;
                m1_WREADY = '0;
                m2_WREADY = '0;
            end
            3'b010: begin
                m0_WREADY = '0;
                m1_WREADY = wready;
                m2_WREADY = '0;
            end
            3'b001: begin
                m0_WREADY = '0;
                m1_WREADY = '0;
                m2_WREADY = wready;
            end
            default: begin
                m0_WREADY = '0;
                m1_WREADY = '0;
                m2_WREADY = '0;
            end
        endcase
    end




endmodule