`include "../define.sv"
module axi_slave_mux_ar(
	input                       clk_i,
	input      	                rst_ni,
    output  logic               s0_ARVALID,
    input	   	                s0_ARREADY,
    output  logic               s1_ARVALID,
    input	   	                s1_ARREADY,
    output  logic               s3_ARVALID,
    input	   	                s3_ARREADY,
    output  logic               arready,
    input     [`ADDR_WIDTH-1:0]	araddr,
    input                       arvalid
);


    always_comb begin
        case(araddr[`ADDR_WIDTH-1-:2])
            2'b00: begin
                arready   = s0_ARREADY;
            end
            2'b01: begin
                arready   = s1_ARREADY;
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
        case(araddr[`ADDR_WIDTH-1-:2])
            2'b00:begin
                s0_ARVALID  = arvalid;
                s1_ARVALID  = '0;
                s3_ARVALID  = '0;
            end
            2'b01:begin
                s0_ARVALID  = '0;
                s1_ARVALID  = arvalid;
                s3_ARVALID  = '0;
            end
            2'b11:begin
                s0_ARVALID  = '0;
                s1_ARVALID  = '0;
                s3_ARVALID  = arvalid;
            end
            default: begin
                s0_ARVALID  = '0;
                s1_ARVALID  = '0;
                s3_ARVALID  = '0;
            end
        endcase
    end


    
endmodule