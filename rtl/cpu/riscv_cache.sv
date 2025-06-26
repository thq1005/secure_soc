`include "../define.sv"
module riscv_cache(
	input logic clk_i,
	input logic rst_ni,
	//to mem
    output logic [`ADDR_WIDTH-1:0] addr_o,
    output logic [`DATA_WIDTH_CACHE-1:0] wdata_o,
    output logic we_o,
    output logic cs_o,
    input logic [`DATA_WIDTH_CACHE-1:0] rdata_i,
    input logic rvalid_i,
	input logic e_irq,
	//
	input logic enable,
	input logic rd_reg_en,
	input logic [4:0] rd_reg_addr,
	output logic [31:0] rd_reg_data

	
	);
	
	logic BrEq_w, BrLt_w;
	//logic [4:0] rsW_w;
	logic [31:0] alu_mem_w, pc_d_w, inst_d_w, pc4_d_w, data_wb_w;
	logic hit_d_w;
	logic [31:0] rs1_ex_w, rs2_ex_w, imm_ex_w, pc_ex_w, pc4_ex_w;
	logic [3:0] AluSel_ex_w;
	logic BSel_ex_w, ASel_ex_w, MemRW_ex_w, BrUn_ex_w, RegWEn_ex_w;
	logic hit_ex_w;
	logic [4:0] rsW_ex_w;
	logic [1:0] WBSel_ex_w;
	logic [31:0] rs2_mem_w, pc4_mem_w;
	logic MemRW_mem_w, RegWEn_mem_w;
	logic [1:0] WBSel_mem_w;
	logic [4:0] rsW_mem_w;
	logic [31:0] alu_wb_w, pc4_wb_w, mem_wb_w;
	logic RegWEn_wb_w;
	logic [1:0] WBSel_wb_w;
	logic [4:0] rsW_wb_w;
	
	logic [31:0] inst_ex_w, inst_mem_w, inst_wb_w;
	logic [1:0] Asel_haz_w, Bsel_haz_w;
	logic [31:0] alu_w;
	logic hit_w;
	logic [31:0] predicted_pc_w;
	
	logic Stall_IF_w, Stall_ID_w, Flush_ID_w, Stall_EX_w, Flush_EX_w, Stall_MEM_w, Flush_MEM_w, Stall_WB_w;
	logic Flush_WB_w;
	
	logic [31:0] pc_bp_w;
	logic [1:0] wrong_predicted_w;
	logic [31:0] alu_pc_w;

	/* valid signal when CPU access cache */
	logic Valid_cpu2cache_ex_w;
	logic Valid_cpu2cache_mem_w;

	logic stall_by_dcache_w;
	logic stall_by_icache_w;


    logic [31:0] mem_addr_w;
	logic [127:0] mem_wdata_w;
	logic mem_we_w;
	logic mem_cs_w;
	logic [127:0] dmem_rdata_w;
	logic dmem_rvalid_w;

	logic [31:0] imem_addr_o;
	logic [127:0] imem_wdata_o;
	logic imem_we_o;
	logic imem_cs_o;
	logic [127:0] imem_rdata_i;
	logic imem_rvalid_i;

	logic [31:0] csr_pc_w;
	logic intr_flag;
	logic is_mret;

	logic [31:0] csr_rdata_ex_w;
	logic csr_we_ex_w;
	logic [31:0] csr_waddr_ex_w;
	logic alu_csr_sel_w;

	logic csr_we_mem_w;
	logic [31:0] csr_waddr_mem_w;
	logic [31:0] csr_rdata_mem_w;

	logic csr_we_wb_w;
	logic [31:0] csr_waddr_wb_w;
	logic [31:0] csr_rdata_wb_w;

	logic [31:0] csr_wdata_w;

	logic is_mret_ex_w;
	logic [31:0] pc_mret_ex_w;

//	/* evaluation */
//	logic [31:0] icache_no_acc_w, icache_no_hit_w, icache_no_miss_w, dcache_no_acc_w, dcache_no_hit_w, dcache_no_miss_w;
//	//logic [31:0] no_command_w;

//	subtractor_32bit Icache_hit(
//		.a_i(icache_no_acc_w),
//		.b_i(icache_no_miss_w),
//		.d_o(icache_no_hit_w),
//		.b_o()
//	);
//	/* ---------- */
	
	IF IF(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.hit_i(hit_w),
		.predicted_pc_i(predicted_pc_w),
		.enable_pc_i(~(Stall_IF_w | stall_by_dcache_w | stall_by_icache_w | ~enable)),
		.enable_i   (~(Stall_ID_w | stall_by_dcache_w | stall_by_icache_w | ~enable)),
		.reset_i(Flush_ID_w),
		.mispredicted_pc_i(pc4_ex_w),
		.wrong_predicted_i(wrong_predicted_w),
		.alu_pc_i(alu_pc_w),
		.pc_d_o(pc_d_w),
		.inst_d_o(inst_d_w),
		.pc4_d_o(pc4_d_w),
		.pc_bp_o(pc_bp_w),
		.hit_d_o(hit_d_w),
		.stall_by_icache_o(stall_by_icache_w),
//		.No_command_o(icache_no_acc_w),
//		.no_acc_o(),
//		.no_hit_o(),
//		.no_miss_o(icache_no_miss_w),
		.mem_addr_o(imem_addr_o),
	    .mem_wdata_o(imem_wdata_o),
	    .mem_we_o(imem_we_o),
	    .mem_cs_o(imem_cs_o),
	    .mem_rdata_i(imem_rdata_i),
	    .mem_rvalid_i(imem_rvalid_i),
		.csr_pc_i (csr_pc_w),
		.intr_flag(intr_flag)
		);
		
	ID ID(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.data_wb_i(data_wb_w),
		.inst_d_i(inst_d_w),
		.pc_d_i(pc_d_w),
		.pc4_d_i(pc4_d_w),
		.RegWEn_i(RegWEn_wb_w),
		.rsW_i(rsW_wb_w),
		.enable_i(~(Stall_EX_w | stall_by_dcache_w  | stall_by_icache_w | ~enable)),
		.reset_i(Flush_EX_w),
		.hit_d_i(hit_d_w),
		.e_intr(e_irq),		
		.csr_wdata_i (csr_wdata_w),
		.csr_waddr_i (csr_waddr_wb_w),
		.csr_we_i    (csr_we_wb_w),
		.rs1_ex_o(rs1_ex_w),
		.rs2_ex_o(rs2_ex_w),
		.imm_ex_o(imm_ex_w),
		.pc_ex_o(pc_ex_w),
		.pc4_ex_o(pc4_ex_w),
		.AluSel_ex_o(AluSel_ex_w),
		.BSel_ex_o(BSel_ex_w),
		.ASel_ex_o(ASel_ex_w),
		.MemRW_ex_o(MemRW_ex_w),
		.WBSel_ex_o(WBSel_ex_w),
		.BrUn_ex_o(BrUn_ex_w),
		.RegWEn_ex_o(RegWEn_ex_w),
		.rsW_ex_o(rsW_ex_w),
		.inst_ex_o(inst_ex_w),
		.hit_ex_o(hit_ex_w),
		.Valid_cpu2cache_ex_o(Valid_cpu2cache_ex_w),
		.csr_rdata_o (csr_rdata_ex_w),
		.csr_we_o (csr_we_ex_w),
		.csr_waddr_o (csr_waddr_ex_w),
		.alu_csr_sel_o (alu_csr_sel_w),
		.pc_intr_o (csr_pc_w),
		.intr_flag (intr_flag),
		.is_mret_o   (is_mret_ex_w),
		.pc_mret_o   (pc_mret_ex_w),
		.rd_reg_en (rd_reg_en),
		.rd_reg_addr (rd_reg_addr),
		.rd_reg_data (rd_reg_data)
		);
		
	EX EX(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.rs1_ex_i(rs1_ex_w),
		.rs2_ex_i(rs2_ex_w),
		.imm_ex_i(imm_ex_w),
		.pc_ex_i(pc_ex_w),
		.pc4_ex_i(pc4_ex_w),
		.AluSel_ex_i(AluSel_ex_w),
		.BSel_ex_i(BSel_ex_w),
		.ASel_ex_i(ASel_ex_w),
		.MemRW_ex_i(MemRW_ex_w),
		.WBSel_ex_i(WBSel_ex_w),
		.BrUn_ex_i(BrUn_ex_w),
		.RegWEn_ex_i(RegWEn_ex_w),
		.rsW_ex_i(rsW_ex_w),
		.Asel_haz_i(Asel_haz_w),
		.Bsel_haz_i(Bsel_haz_w),
		.inst_ex_i(inst_ex_w),
		.data_wb_i(data_wb_w),
		.enable_i(~(Stall_MEM_w | stall_by_dcache_w  | stall_by_icache_w| ~enable)),
		.reset_i(Flush_MEM_w),
		.Valid_cpu2cache_ex_i(Valid_cpu2cache_ex_w),
		.csr_rdata_ex_i(csr_rdata_ex_w),
		.csr_we_ex_i(csr_we_ex_w),
		.csr_waddr_ex_i(csr_waddr_ex_w),
		.alu_csr_sel_i(alu_csr_sel_w),
		.alu_mem_o(alu_mem_w),
		.rs2_mem_o(rs2_mem_w),
		.pc4_mem_o(pc4_mem_w),
		.MemRW_mem_o(MemRW_mem_w),
		.WBSel_mem_o(WBSel_mem_w),
		.BrEq_o(BrEq_w),
		.BrLt_o(BrLt_w),
		.RegWEn_mem_o(RegWEn_mem_w),
		.rsW_mem_o(rsW_mem_w),
		.inst_mem_o(inst_mem_w),
		.alu_o(alu_w),
		.Valid_cpu2cache_mem_o(Valid_cpu2cache_mem_w),
		.csr_we_mem_o(csr_we_mem_w),
		.csr_waddr_mem_o(csr_waddr_mem_w),
		.csr_rdata_mem_o(csr_rdata_mem_w),
		.is_mret_ex_i(is_mret_ex_w),
		.pc_mret_ex_i(pc_mret_ex_w)
		);
		
	MEM MEM(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.alu_mem_i(alu_mem_w),
		.rs2_mem_i(rs2_mem_w),
		.pc4_mem_i(pc4_mem_w),
		.MemRW_mem_i(MemRW_mem_w),
		.WBSel_mem_i(WBSel_mem_w),
		.RegWEn_mem_i(RegWEn_mem_w),
		.rsW_mem_i(rsW_mem_w),
		.inst_mem_i(inst_mem_w),
		.enable_i(~(Stall_WB_w | stall_by_dcache_w | stall_by_icache_w| ~enable)),
		.reset_i(Flush_WB_w),
		.Valid_cpu2cache_mem_i(Valid_cpu2cache_mem_w),
		.stall_by_icache_i(stall_by_icache_w),
		.csr_we_mem_i(csr_we_mem_w),
		.csr_waddr_mem_i(csr_waddr_mem_w),
		.csr_rdata_mem_i(csr_rdata_mem_w),
		.alu_wb_o(alu_wb_w),
		.pc4_wb_o(pc4_wb_w),
		.mem_wb_o(mem_wb_w),
		.WBSel_wb_o(WBSel_wb_w),
		.RegWEn_wb_o(RegWEn_wb_w),
		.rsW_wb_o(rsW_wb_w),
		.inst_wb_o(inst_wb_w),
		.stall_by_dcache_o(stall_by_dcache_w),
//		.no_acc_o(dcache_no_acc_w),
//		.no_hit_o(dcache_no_hit_w),
//		.no_miss_o(dcache_no_miss_w),
		.addr_o	(mem_addr_w),
	    .wdata_o(mem_wdata_w),
	    .we_o	(mem_we_w),
	    .cs_o	(mem_cs_w),
	    .mem_rdata_i(dmem_rdata_w),
	    .mem_rvalid_i(dmem_rvalid_w),
		.csr_we_wb_o(csr_we_wb_w),
		.csr_waddr_wb_o(csr_waddr_wb_w),	
		.csr_rdata_wb_o(csr_rdata_wb_w)
		);
		
	WB WB(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.alu_wb_i(alu_wb_w),
		.pc4_wb_i(pc4_wb_w),
		.mem_wb_i(mem_wb_w),
		.WBSel_wb_i(WBSel_wb_w),
		.csr_i (csr_rdata_wb_w),
		//.RegWEn_wb_i(RegWEn_wb_w),
		//.rsW_wb_i(rsW_wb_w),
		.dataWB_o(data_wb_w),
		.wdata_csr_o (csr_wdata_w)
		//.RegWEn_o(RegWEn_w),
		//.rsW_o(rsW_w)
		);
		
	Hazard_unit FCU(
		.rst_ni(rst_ni),
		.RegWEn_mem_i(RegWEn_mem_w),
		.RegWEn_wb_i(RegWEn_wb_w),
		.inst_d_i(inst_d_w),
		.inst_ex_i(inst_ex_w),
		.inst_mem_i(inst_mem_w),
		.inst_wb_i(inst_wb_w),
		.PC_taken_i(wrong_predicted_w),
		.Stall_IF(Stall_IF_w),
		.Stall_ID(Stall_ID_w),
		.Flush_ID(Flush_ID_w),
		.Stall_EX(Stall_EX_w),
		.Flush_EX(Flush_EX_w),
		.Stall_MEM(Stall_MEM_w),
		.Flush_MEM(Flush_MEM_w),
		.Stall_WB(Stall_WB_w),
		.Flush_WB(Flush_WB_w),
		.Bsel_o(Bsel_haz_w),
		.Asel_o(Asel_haz_w)
		);
		
	Branch_predictor BP(
		.rst_ni		(rst_ni),
		.clk_i		(clk_i),
		.BrEq_i		(BrEq_w),
		.BrLt_i		(BrLt_w),
		.inst_ex_i	(inst_ex_w),
		.alu_i		(alu_w),
		.pc_i		(pc_bp_w),
		.pc_ex_i	(pc_ex_w),
		.hit_ex_i	(hit_ex_w),
		.hit_o		(hit_w),
		.predicted_pc_o(predicted_pc_w),
		.wrong_predicted_o(wrong_predicted_w),
		.alu_pc_o(alu_pc_w),
		.enable_i (~(Stall_WB_w | stall_by_dcache_w | stall_by_icache_w| ~enable))
		);
		
	arbiter arbiter_inst (
		.clk_i       (clk_i),
		.rst_ni      (rst_ni),
		.i_addr_i    (imem_addr_o),
		.i_cs_i      (imem_cs_o),
		.i_we_i      (imem_we_o),
		.i_rdata_o   (imem_rdata_i),
		.i_rvalid_o  (imem_rvalid_i),
		.d_addr_i    (mem_addr_w),
		.d_cs_i      (mem_cs_w),
		.d_wdata_i   (mem_wdata_w),
		.d_we_i      (mem_we_w),
		.d_rdata_o   (dmem_rdata_w),  
		.d_rvalid_o  (dmem_rvalid_w), 
		.addr_o      (addr_o),
		.wdata_o     (wdata_o),
		.we_o        (we_o),
		.cs_o        (cs_o ),
		.rdata_i     (rdata_i),
		.rvalid_i    (rvalid_i),
		.stall_by_icache (stall_by_icache_w)
    );
endmodule



