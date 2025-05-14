`include "../define.sv"
module axi_slave_mux_w(
	input                       clk_i,
	input      	                rst_ni,
    output                      s0_WVALID,
    input	 	                s0_WREADY,
    output                      s1_WVALID,
    input	 	                s1_WREADY,
    output                      s2_WVALID,
    input	 	                s2_WREADY,
    output                      s3_WVALID,
    input	 	                s3_WREADY,
    output  	                wready,
    input     [1:0]     	    s_wsel,
    input                       wvalid,
);


    always_comb begin
        case(s_wsel)
            2'b00: begin
                wready   = s0_WREADY;
            end
            2'b01: begin
                wready   = s1_WREADY;
            end
            2'b10: begin
                wready   = s2_WREADY;
            end
            2'b11: begin
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
            2'b00:begin
                s0_WVALID  = wvalid;
                s1_WVALID  = '0;
                s2_WVALID  = '0;
                s3_WVALID  = '0;
            end
            2'b01:begin
                s0_WVALID  = '0;
                s1_WVALID  = wvalid;
                s2_WVALID  = '0;
                s3_WVALID  = '0;
            end
            2'b10:begin
                s0_AWVALID  = '0;
                s1_AWVALID  = '0;
                s2_AWVALID  = awvalid;
                s3_AWVALID  = '0;
            end
            2'b11:begin
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