`include "../define.sv"
module axi_slave_mux_aw(
	input                       clk_i,
	input      	                rst_ni,
    output                      s0_AWVALID,
    input	   	                s0_AWREADY,
    output                      s1_AWVALID,
    input	   	                s1_AWREADY,
    output                      s2_AWVALID,
    input	   	                s2_AWREADY,
    output                      s3_AWVALID,
    input	   	                s3_AWREADY,
    output  	                awready,
    input     [`ADDR_WIDTH-1:0]	awaddr,
    input                       awvalid,
);


    always_comb begin
        case(s_AWADDR[`ADDR_WIDTH-1-:2])
            2'b00: begin
                awready   = s0_AWREADY;
            end
            2'b01: begin
                awready   = s1_AWREADY;
            end
            2'b10: begin
                awready   = s2_AWREADY;
            end
            2'b11: begin
                awready   = s3_AWREADY;
            end
            default: begin
                awready   = '0;
            end
        endcase
    end

    //---------------------------------------------------------
    always_comb begin
        case(awaddr[`ADDR_WIDTH-1-:2])
            2'b00:begin
                s0_AWVALID  = awvalid;
                s1_AWVALID  = '0;
                s2_AWVALID  = '0;
                s3_AWVALID  = '0;
            end
            2'b01:begin
                s0_AWVALID  = '0;
                s1_AWVALID  = awvalid;
                s2_AWVALID  = '0;
                s3_AWVALID  = '0;
            end
            2'b10:begin
                s0_AWVALID  = '0;
                s1_AWVALID  = '0;
                s2_AWVALID  = awvalid;
                s3_AWVALID  = '0;
            end
            2'b11:begin
                s0_AWVALID  = '0;
                s1_AWVALID  = '0;
                s2_AWVALID  = '0;
                s3_AWVALID  = awvalid;
            end
            default: begin
                s0_AWVALID  = '0;
                s1_AWVALID  = '0;
                s2_AWVALID  = '0;
                s3_AWVALID  = '0;
            end
        endcase
    end


    
endmodule