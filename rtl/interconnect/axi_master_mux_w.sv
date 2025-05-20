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
    output logic [`DATA_WIDTH - 1:0] wdata,
    output logic [(`DATA_WIDTH/8)-1:0] wstrb,
    output logic                wlast,
    output logic                wvalid,
    input                       wready,
    /****************/
    input                       w_m0_wgrnt,
	input                       w_m1_wgrnt
);

    always_comb begin
        case({w_m0_wgrnt,w_m1_wgrnt})    
            2'b10: begin
                wdata    =  m0_WDATA;
                wstrb    =  m0_WSTRB;
                wlast    =  m0_WLAST;
                wvalid   =  m0_WVALID;
            end
            2'b01: begin
                wdata    =  m1_WDATA;
                wstrb    =  m1_WSTRB;
                wlast    =  m1_WLAST;
                wvalid   =  m1_WVALID;
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
        case({w_m0_wgrnt,w_m1_wgrnt})
            2'b10: begin 
                m0_WREADY = wready;
                m1_WREADY = '0;
            end
            2'b01: begin
                m0_WREADY = '0;
                m1_WREADY = wready;
            end
            default: begin
                m0_WREADY = '0;
                m1_WREADY = '0;
            end
        endcase
    end




endmodule