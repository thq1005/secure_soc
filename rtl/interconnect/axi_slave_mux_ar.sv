`include "../define.sv"
module axi_slave_mux_aw(
	input                       clk_i,
	input      	                rst_ni,
    output                      s0_ARVALID,
    input	   	                s0_ARREADY,
    output                      s1_ARVALID,
    input	   	                s1_ARREADY,
    output                      s2_ARVALID,
    input	   	                s2_ARREADY,
    output                      s3_ARVALID,
    input	   	                s3_ARREADY,
    output  	                arready,
    input     [`ADDR_WIDTH-1:0]	araddr,
    input                       arvalid,
);


    always_comb begin
        case(s_ARADDR[`ADDR_WIDTH-1-:2])
            2'b00: begin
                arready   = s0_ARREADY;
            end
            2'b01: begin
                arready   = s1_ARREADY;
            end
            2'b10: begin
                arready   = s2_ARREADY;
            end
            2'b11: begin
                arready   = s3_ARREADY;
            end
            default: begin
                arready   = '0;
            end
        endcase
    end

    //---------------------------------------------------------
    always_comb begin
        case(awaddr[`ADDR_WIDTH-1-:2])
            2'b00:begin
                s0_ARVALID  = arvalid;
                s1_ARVALID  = '0;
                s2_ARVALID  = '0;
                s3_ARVALID  = '0;
            end
            2'b01:begin
                s0_ARVALID  = '0;
                s1_ARVALID  = arvalid;
                s2_ARVALID  = '0;
                s3_ARVALID  = '0;
            end
            2'b10:begin
                s0_ARVALID  = '0;
                s1_ARVALID  = '0;
                s2_ARVALID  = arvalid;
                s3_ARVALID  = '0;
            end
            2'b11:begin
                s0_ARVALID  = '0;
                s1_ARVALID  = '0;
                s2_ARVALID  = '0;
                s3_ARVALID  = arvalid;
            end
            default: begin
                s0_ARVALID  = '0;
                s1_ARVALID  = '0;
                s2_ARVALID  = '0;
                s3_ARVALID  = '0;
            end
        endcase
    end


    
endmodule