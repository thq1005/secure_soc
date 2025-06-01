`include "../define.sv"
import cache_def::*;
module IF(
	input logic clk_i,
	input logic rst_ni,
	input logic hit_i,
	input logic [31:0] predicted_pc_i,
	input logic enable_pc_i,
	input logic enable_i, 
	input logic reset_i,
	input logic [1:0] wrong_predicted_i,
	input logic [31:0] mispredicted_pc_i,
	input logic [31:0] alu_pc_i,
	output logic [31:0] pc_d_o,
	output logic [31:0] inst_d_o,
	output logic [31:0] pc4_d_o,
	output logic [31:0] pc_bp_o,
	output logic hit_d_o,
	output logic stall_by_icache_o,
//	output logic [31:0] no_acc_o,
//	output logic [31:0] no_hit_o,
//	output logic [31:0] no_miss_o,4
//	output logic [31:0] No_command_o,
	
	output logic [31:0] mem_addr_o,
	output logic [127:0] mem_wdata_o,
	output logic mem_we_o,
	output logic mem_cs_o,
	input logic [127:0] mem_rdata_i,
	input logic mem_rvalid_i,

	input logic [31:0] csr_pc_i,
	input logic intr_flag
	);
	
    
	logic [31:0] PC_mux_w, PC_mux1_w;
	logic [31:0] PC_w, inst_w, PC_add4_w;
	logic [31:0] PC_r, inst_r, PC_add4_r;
	logic [31:0] PC_mux2_w;
	logic hit_r;
	logic overf_PC_w;
	
	cpu_req_type cpu_req_w;
	cpu_result_type cpu_result_w;
	mem_req_type mem_req_w;
	mem_data_type mem_data_w;

	// counter of access, hit, miss cache
	// logic [31:0] no_acc_w;
	// logic [31:0] no_hit_w;
	// logic [31:0] no_miss_w;

	cache_data_type inst_mem_w;


	mux2to1_32bit MUX_IF(
		.a_i(PC_add4_w), 
		.b_i(predicted_pc_i),
		.se_i(hit_i),
		.c_o(PC_mux_w)
		);
		
	mux3to1_32bit MUX3_IF(
		.a_i(PC_mux_w), 
		.b_i(mispredicted_pc_i), 
		.c_i(alu_pc_i),
		.se_i(wrong_predicted_i),
		.r_o(PC_mux2_w)
		);
	
	assign PC_mux1_w = (intr_flag) ? csr_pc_i : PC_mux2_w;

	pc PC_IF(
		.data_i(PC_mux1_w),
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.enable_i(enable_pc_i),
		.data_o(PC_w)
//		.No_command_o(No_command_o)
		);
	
	adder_32bit ADD4_IF(
		.a_i(32'h04), 
		.b_i(PC_w),
		.re_o(PC_add4_w),
		.c_o(overf_PC_w)
		);
		
	/* adding i_cache */
	i_cache I_CACHE(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.cpu_req_i(cpu_req_w),
		.mem_data_i(mem_data_w),
		.cpu_res_o(cpu_result_w),
		.mem_req_o(mem_req_w),
//		.no_acc_o(no_acc_o),
//		.no_hit_o(no_hit_o),
//		.no_miss_o(no_miss_o),
		.accessing_o(stall_by_icache_o)
	);
	/* ---------------- */
    
	assign mem_addr_o  = {mem_req_w.addr[31:4], 4'b0};
	assign mem_wdata_o = 32'b0;
	assign mem_we_o    = 1'b0;
	assign mem_cs_o    = mem_req_w.valid;
	assign inst_mem_w = mem_rdata_i;   
    
	assign inst_w = cpu_result_w.data;
	
	always_ff @(posedge clk_i, negedge rst_ni) begin
		if (~rst_ni) begin
			PC_r <= 32'b0;
			inst_r <= 32'b0;
			PC_add4_r <= 32'b0;
			hit_r <= 1'b0;
		end
		else if (enable_i) begin
			if (reset_i) begin
				PC_r <= 32'b0;
				inst_r <= 32'b0;
				PC_add4_r <= 32'b0;
				hit_r <= 1'b0;
			end
			else begin
				PC_r <= PC_w;
				inst_r <= inst_w;
				PC_add4_r <= PC_add4_w;
				hit_r <= hit_i;
			end
		end
	end


	assign pc_d_o = PC_r;
	assign inst_d_o = inst_r;
	assign pc4_d_o = PC_add4_r;
	assign pc_bp_o = PC_w;
	assign hit_d_o = hit_r;

	assign cpu_req_w.addr = PC_w;
	assign cpu_req_w.data = 32'b0;
	assign cpu_req_w.rw = 1'b0;
	assign cpu_req_w.valid = 1'b1;
	assign mem_data_w.data = inst_mem_w;
	assign mem_data_w.ready = mem_rvalid_i;
	
endmodule

