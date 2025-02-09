module WB(
	input logic clk_i,
	input logic rst_ni,
	input logic [31:0] alu_wb_i,
	input logic [31:0] pc4_wb_i,
	input logic [31:0] mem_wb_i,
	input logic [31:0] aes_result_i,
	input logic [1:0] WBSel_wb_i,
	output logic [31:0] dataWB_o
	);
		
assign dataWB_o = (WBSel_wb_i == 00) ? mem_wb_i :
				  (WBSel_wb_i == 01) ? alu_wb_i :
				  (WBSel_wb_i == 10) ? pc4_wb_i : aes_result_i;

endmodule
