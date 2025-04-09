module ram(								//SDRAM
    input logic clk_i,
    input logic rst_ni,
    input logic [31:0] addr_i,
    input logic [31:0] wdata_i,
    input logic cs_i,
    input logic wr_i,
	/* ------------ */
    output logic [31:0] rdata_o,
    output logic [31:0] soc_on_o
);

	/* Spec of memory */
	/*
	 4KB instruction and data, the first 2KB for instruction and the second 2KB for data
	 Address:
	 	0 -> 511 : instructions
		512 -> 1023 : data memory
	
	*/
	/* -------------- */

	/* imem */
	logic [31:0] imem [512]; //2KB instruction memory
	

	/* ------------- */

	/* dmem */

	logic [31:0] dmem [512]; 
	
    logic [31:0] soc_on;
	
	logic temp;
	
	assign temp = (addr_i > 511) ? 1 : 0; 
	always_ff @(posedge clk_i) begin
	    if (~rst_ni) begin
            for (int i = 0; i < 512; i++) begin
                imem[i] <= 32'h00000000;
                dmem[i] <= 32'h00000000;
            end
            soc_on <= 32'h00000000;
	    end
		else if (cs_i) begin 
            if (~wr_i) begin
              	if (!temp)
              	    rdata_o = imem[addr_i[31:2]];
              	else 
                  	rdata_o = dmem[addr_i[31:2]-512];
            end
            else if (addr_i != 32'h00030000)
                dmem[addr_i[31:2]-512] = wdata_i;
            else 
                soc_on = wdata_i;
        end
	end

    assign soc_on_o = soc_on;
endmodule
