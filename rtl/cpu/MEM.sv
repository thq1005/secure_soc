module MEM(
	input logic clk_i,
	input logic rst_ni,
	input logic [31:0] alu_mem_i,
	input logic [31:0] rs2_mem_i,
	input logic [31:0] pc4_mem_i,
	input logic MemRW_mem_i,
	input logic [1:0] WBSel_mem_i,
	input logic RegWEn_mem_i,
	input logic [4:0] rsW_mem_i,
	input logic [31:0] inst_mem_i,
	input logic enable_i,
	input logic reset_i,
	input stall_by_icache_i,
	/* valid signal when CPU access cache */
	input logic Valid_cpu2cache_mem_i,
	input logic Valid_cpu2dma_mem_i,
	input logic csr_we_mem_i,
	input logic [31:0] csr_waddr_mem_i,
	input logic [31:0] csr_rdata_mem_i,
	output logic [31:0] alu_wb_o,
	output logic [31:0] pc4_wb_o,
	output logic [31:0] mem_wb_o,
	output logic [1:0] WBSel_wb_o,
	output logic RegWEn_wb_o,
	output logic [4:0] rsW_wb_o,
	output logic [31:0] inst_wb_o,
	output logic stall_by_dcache_o,
//	output logic [31:0] no_acc_o,
//	output logic [31:0] no_hit_o,
//	output logic [31:0] no_miss_o,
	output logic [31:0] mem_addr_o,
	output logic [127:0] mem_wdata_o,
	output logic mem_we_o,
	output logic mem_cs_o,
	input logic  [127:0] mem_rdata_i,
	input logic  mem_rvalid_i,
	output logic csr_we_wb_o,
	output logic [31:0] csr_waddr_wb_o,
	output logic [31:0] csr_rdata_wb_o
	);
	
	logic [31:0] mem_w;
	logic [31:0] aes_result_w;
	logic [31:0] aes_result_r;
	logic [31:0] alu_r, pc4_r, mem_r;
	logic [1:0] WBSel_r;
	logic RegWEn_r;
	logic [4:0] rsW_r;
	logic [31:0] inst_r;
	logic [31:0] csr_waddr_mem_r;
	logic csr_we_mem_r;
	logic [31:0] csr_rdata_wb_r;

	/* valid signal that memory response to cache */
	cpu_req_type cpu_req_w;
	cpu_result_type cpu_result_w;
	mem_req_type mem_req_w;
	mem_data_type mem_data_w;

	cache_data_type memory_data_w;

	assign mem_addr_o  = mem_req_w.addr;
	assign mem_wdata_o = mem_req_w.data;
	assign mem_we_o    = mem_req_w.rw;
	assign mem_cs_o    = mem_req_w.valid;
	assign memory_data_w = mem_rdata_i;

	
	d_cache D_CACHE(
    	.clk_i(clk_i),
    	.rst_ni(rst_ni),
    	.cpu_req_i(cpu_req_w),
    	.mem_data_i(mem_data_w),
    	.cpu_res_o(cpu_result_w),
    	.mem_req_o(mem_req_w)
//		.no_acc_o(no_acc_o),
//		.no_hit_o(no_hit_o),
//		.no_miss_o(no_miss_o)
	);

	assign mem_w = cpu_result_w.data;

	always_ff @(posedge clk_i, negedge rst_ni) begin
		if (~rst_ni) begin
			alu_r <= 32'b0;
			pc4_r <= 32'b0;
			mem_r <= 32'b0;
			WBSel_r <= 2'b0;
			RegWEn_r <= 1'b0;
			rsW_r <= 5'b0;
			inst_r <= 32'b0;
			csr_waddr_mem_r <= 32'b0;
			csr_we_mem_r <= 1'b0;
			csr_rdata_wb_r <= 32'b0;
		end
		else if (enable_i) begin
			if (reset_i) begin
				alu_r <= 32'b0;
				pc4_r <= 32'b0;
				mem_r <= 32'b0;
				WBSel_r <= 2'b0;
				RegWEn_r <= 1'b0;
				rsW_r <= 5'b0;
				inst_r <= 32'b0;
				csr_waddr_mem_r <= 32'b0;
				csr_we_mem_r <= 1'b0;
				csr_rdata_wb_r <= 32'b0;
			end
			else begin
				alu_r <= alu_mem_i;
				pc4_r <= pc4_mem_i;
				mem_r <= mem_w;
				WBSel_r <= WBSel_mem_i;
				RegWEn_r <= RegWEn_mem_i;
				rsW_r <= rsW_mem_i;
				inst_r <= inst_mem_i;
				csr_waddr_mem_r <= csr_waddr_mem_i;
				csr_we_mem_r <= csr_we_mem_i;
				csr_rdata_wb_r <= csr_rdata_mem_i;
			end
		end
	end


	assign alu_wb_o = alu_r;
	assign pc4_wb_o = pc4_r;
	assign mem_wb_o = mem_r;
	assign WBSel_wb_o = WBSel_r;
	assign RegWEn_wb_o = RegWEn_r;
	assign rsW_wb_o = rsW_r;
	assign inst_wb_o = inst_r;
	/* connect signals for cache */
	//assign cpu_req_w = {alu_mem_i, rs2_mem_i, MemRW_mem_i, Valid_cpu2cache_mem_i};
	assign cpu_req_w.addr = alu_mem_i;
	assign cpu_req_w.data = rs2_mem_i;
	assign cpu_req_w.rw = MemRW_mem_i;
	assign cpu_req_w.valid = Valid_cpu2cache_mem_i & (~stall_by_icache_i);
	//assign mem_data_w = {memory_data_w, Valid_memory2cache_w};
	assign mem_data_w.data = memory_data_w;
	assign mem_data_w.ready = mem_rvalid_i;

	/* control stall for previous stages */
	assign stall_by_dcache_o = (Valid_cpu2cache_mem_i&(~cpu_result_w.ready)) ? 1'b1 : 1'b0;
	
	assign csr_waddr_mem_o = csr_waddr_mem_r;
	assign csr_we_mem_o = csr_we_mem_r;
	assign csr_rdata_wb_o = csr_rdata_wb_r;
endmodule
