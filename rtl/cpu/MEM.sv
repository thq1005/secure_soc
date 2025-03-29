`include "../define.sv" 
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
	input logic Valid_cpu2aes_mem_i,
	input logic csr_we_mem_i,
	input logic [31:0] csr_waddr_mem_i,
	input logic [31:0] csr_rdata_mem_i,
	input logic aes_load_mem_i,
	output logic [31:0] alu_wb_o,
	output logic [31:0] pc4_wb_o,
	output logic [31:0] mem_wb_o,
	output logic [1:0] WBSel_wb_o,
	output logic RegWEn_wb_o,
	output logic [4:0] rsW_wb_o,
	output logic [31:0] inst_wb_o,
	output logic stall_by_aes_o,
	output logic stall_by_dcache_o,
//	output logic [31:0] no_acc_o,
//	output logic [31:0] no_hit_o,
//	output logic [31:0] no_miss_o,
	output logic [31:0] addr_o,
	output logic [127:0] wdata_o,
	output logic we_o,
	output logic cs_o,
	input logic  [127:0] mem_rdata_i,
	input logic  mem_rvalid_i,
	output logic csr_we_wb_o,
	output logic [31:0] csr_waddr_wb_o,
	output logic [31:0] csr_rdata_wb_o
	);
	 
	logic [31:0] mem_w;
	logic [31:0] alu_r, pc4_r, mem_r;
	logic [1:0] WBSel_r;
	logic RegWEn_r;
	logic [4:0] rsW_r;
	logic [31:0] inst_r;
	logic [31:0] csr_waddr_mem_r;
	logic csr_we_mem_r;
	logic [31:0] csr_rdata_mem_r;
	logic [31:0] aes_status_r;
	logic [31:0] aes_status_w;
	logic aes_load_r;
	/* valid signal that memory response to cache */
	cpu_req_type cpu_req_w;
	cpu_result_type cpu_result_w;
	mem_req_type mem_req_w;
	mem_data_type mem_data_w;

	cache_data_type memory_data_w;

	/* DMA */
	logic [31:0] valid_dma;
	logic [31:0] config_dma;
	logic [31:0] src_addr_dma;
	logic [31:0] dst_addr_dma;
	logic [31:0] aes_gen_addr;

	always_comb begin
		aes_gen_addr <= 32'h00000000;
		if (inst_mem_i[14:12] == `BLOCK)
			aes_gen_addr <= `ADDR_BLOCK0;
		else if (inst_mem_i[14:12] == `KEY)
			aes_gen_addr <= `ADDR_KEY0;
		else if (inst_mem_i[14:12] == `RESULT)
			aes_gen_addr <= `ADDR_RESULT0;
	end

	always_comb begin
		config_dma[31:`DMA_MODE_BIT+1] <= '0;
		config_dma[`DMA_LEN_BIT7:`DMA_LEN_BIT0] 	<= (rs2_mem_i[7:0] << 2) + 3;
		config_dma[`DMA_SIZE_BIT2:`DMA_SIZE_BIT0] 	<= 3'h2;
		config_dma[`DMA_BURST_BIT1:`DMA_BURST_BIT0] <= 2'h1;

		if (inst_mem_i[14:12] == `BLOCK | inst_mem_i[14:12] == `KEY) begin
			config_dma[`DMA_MODE_BIT] <= 0;
		end
		else if (inst_mem_i[14:12] == `RESULT) begin
			config_dma[`DMA_MODE_BIT] <= 1;
		end
		else begin
			config_dma[`DMA_MODE_BIT] <= 0;
		end
	end

	assign src_addr_dma = (inst_mem_i[14:12] == `BLOCK | inst_mem_i[14:12] == `KEY) ? alu_mem_i : 
						  (inst_mem_i[14:12] == `RESULT) ? aes_gen_addr : 32'h0;

	assign dst_addr_dma = (inst_mem_i[14:12] == `BLOCK | inst_mem_i[14:12] == `KEY) ? aes_gen_addr : 
						  (inst_mem_i[14:12] == `RESULT) ? alu_mem_i : 32'h0;

	assign addr_o  		= (mem_req_w.valid) 	? mem_req_w.addr :
						  (Valid_cpu2aes_mem_i && inst_mem_i[14:12] == `CTRL)   ? `ADDR_CTRL : 
						  (Valid_cpu2aes_mem_i && inst_mem_i[14:12] == `CONFI) 	? `ADDR_CONFIG : 
						  (Valid_cpu2aes_mem_i && inst_mem_i[14:12] == `BLOCK && ~aes_load_mem_i) 	? `ADDR_ADDR_SRC :
						  (Valid_cpu2aes_mem_i && inst_mem_i[14:12] == `KEY) 	? `ADDR_ADDR_SRC :
						  (Valid_cpu2aes_mem_i && inst_mem_i[14:12] == `RESULT)	? `ADDR_ADDR_SRC : 
						  (Valid_cpu2aes_mem_i && inst_mem_i[14:12] == `START)	? `ADDR_START : 	
						  (Valid_cpu2aes_mem_i && inst_mem_i[14:12] == `STATUS && aes_load_mem_i) 	? `ADDR_STATUS : 32'h0;

	assign we_o    		= (mem_req_w.valid) 	? mem_req_w.rw :
						  (Valid_cpu2aes_mem_i && ~aes_load_mem_i) ? 1'b1 : 1'b0;

	assign wdata_o 		= (mem_req_w.valid) ? mem_req_w.data:
						  (Valid_cpu2aes_mem_i && inst_mem_i[14:12] == `START) ? 128'h1 :
						  (Valid_cpu2aes_mem_i && (inst_mem_i[14:12] == `CONFI | inst_mem_i[14:12] == `CTRL)) ? {96'h0,alu_mem_i} : {32'h00000001,config_dma,dst_addr_dma,src_addr_dma};

	assign cs_o    		= mem_req_w.valid | Valid_cpu2aes_mem_i;
	
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

	assign aes_status_w = mem_rdata_i[31:0];


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
			csr_rdata_mem_r <= 32'b0;
			aes_status_r <= 32'b0;
			aes_load_r <= 1'b0;
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
				csr_rdata_mem_r <= 32'b0;
				aes_status_r <= 32'b0;
				aes_load_r <= 1'b0;
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
				csr_rdata_mem_r <= csr_rdata_mem_i;
				aes_status_r <= aes_status_w;
				aes_load_r <= aes_load_mem_i;
			end
		end
	end

	assign alu_wb_o = alu_r;
	assign pc4_wb_o = pc4_r;
	assign mem_wb_o =  (aes_load_r)? aes_status_r : mem_r;
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
	assign stall_by_dcache_o = (Valid_cpu2cache_mem_i&(~cpu_result_w.ready))   ? 1'b1 : 1'b0;
	assign stall_by_aes_o 	 = (Valid_cpu2aes_mem_i  & aes_load_mem_i &~mem_rvalid_i) ? 1'b1 : 1'b0;

	assign csr_waddr_wb_o = csr_waddr_mem_r;
	assign csr_we_wb_o = csr_we_mem_r;
	assign csr_rdata_wb_o = csr_rdata_mem_r;
endmodule
