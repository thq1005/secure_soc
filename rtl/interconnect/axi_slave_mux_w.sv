`include "../define.sv"
module axi_slave_mux_w(
	input                       clk_i,
	input      	                rst_ni,
    output  logic               s0_WVALID,
    input	 	                s0_WREADY,
    output  logic               s1_WVALID,
    input	 	                s1_WREADY,
    output  logic               s2_WVALID,
    input	 	                s2_WREADY,
    output  logic               s3_WVALID,
    input	 	                s3_WREADY,
    output  logic               wready,
    input     [3:0]     	    s_wsel,
    input                       wvalid
);


    always_comb begin
        case(s_wsel)
            4'h0: begin
                wready   = s0_WREADY;
            end
            4'h1: begin
                wready   = s1_WREADY;
            end
            4'h2: begin
                wready   = s2_WREADY;
            end
            4'h3: begin
                wready   = s3_WREADY;
            end
            default: begin
                wready   = '0;
            end
        endcase
    end

    //---------------------------------------------------------
    always_comb begin
        case(s_wsel)
            4'h0:begin
                s0_WVALID  = wvalid;
                s1_WVALID  = '0;
                s2_WVALID  = '0;
                s3_WVALID  = '0;
            end
            4'h1:begin
                s0_WVALID  = '0;
                s1_WVALID  = wvalid;
                s2_WVALID  = '0;
                s3_WVALID  = '0;
            end
            4'h2:begin
                s0_WVALID  = '0;
                s1_WVALID  = '0;
                s2_WVALID  = wvalid;
                s3_WVALID  = '0;
            end
            4'h3:begin
                s0_WVALID  = '0;
                s1_WVALID  = '0;
                s2_WVALID  = '0;
                s3_WVALID  = wvalid;
            end
            default: begin
                s0_WVALID  = '0;
                s1_WVALID  = '0;
                s2_WVALID  = '0;
                s3_WVALID  = '0;
            end
        endcase
    end


    
endmodule