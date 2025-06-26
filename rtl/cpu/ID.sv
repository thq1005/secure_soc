`include "../define.sv"
module ID(
	input logic clk_i,
	input logic rst_ni,
	input logic [31:0] data_wb_i,
	input logic [31:0] inst_d_i,
	input logic [31:0] pc_d_i,
	input logic [31:0] pc4_d_i,
	input logic RegWEn_i,
	input logic [4:0] rsW_i,
	input logic enable_i,
	input logic reset_i,
	input logic hit_d_i,

	input logic e_intr,		

	input logic [31:0] csr_wdata_i,
	input logic [31:0] csr_waddr_i,
	input logic csr_we_i,
	output logic [31:0] rs1_ex_o,
	output logic [31:0] rs2_ex_o,
	output logic [31:0] imm_ex_o,
	output logic [31:0] pc_ex_o,
	output logic [31:0] pc4_ex_o,
	output logic [3:0] AluSel_ex_o,
	output logic BSel_ex_o,
	output logic ASel_ex_o,
	output logic MemRW_ex_o,
	output logic [1:0] WBSel_ex_o,
	output logic BrUn_ex_o,
	output logic RegWEn_ex_o,
	output logic [4:0] rsW_ex_o,
	output logic [31:0] inst_ex_o,
	output logic hit_ex_o,
	/* valid signal when CPU access cache */
	output logic Valid_cpu2cache_ex_o,
	output logic [31:0] csr_rdata_o,  
	output logic csr_we_o,
	output logic [31:0] csr_waddr_o,
	output logic alu_csr_sel_o,

	output logic [31:0] pc_intr_o,
	output logic intr_flag,
	output logic is_mret_o,
	output logic [31:0] pc_mret_o,

	input logic rd_reg_en,
	input logic [4:0] rd_reg_addr,
	output logic [31:0] rd_reg_data
	);
	
	logic [31:0] rs1_w, rs2_w, imm_w;
	logic [3:0] AluSel_w;
	logic MemRW_w, BrUn_w, RegWEn_w;
	logic BSel_w, ASel_w;
	logic [1:0] WBSel_w;
	
	logic [31:0] rs1_r, rs2_r, imm_r, pc_r, pc4_r;
	logic [3:0] AluSel_r;
	logic MemRW_r, BrUn_r, RegWEn_r;
	logic BSel_r, ASel_r;
	logic [1:0] WBSel_r;
	logic [4:0] rsW_r;
	logic [31:0] inst_r;
	logic hit_r;
	
	logic [2:0] ImmSel_w;

	/* valid signal when CPU access cache */
	logic Valid_cpu2cache_w;
	logic Valid_cpu2cache_r;

	logic [31:0] csr_rdata_w;
	logic [31:0] csr_rdata_r;
	logic csr_we_w;
	logic csr_we_r;
	logic [31:0] csr_waddr_w;
	logic [31:0] csr_waddr_r;

	logic is_mret;
	logic is_mret_r;
	logic [31:0] pc_mret_r;

	regfile RF_ID(
		.dataW_i(data_wb_i),
		.rsW_i(rsW_i), //inst_d_i[11:7]
		.rs1_i(inst_d_i[19:15]), 
		.rs2_i(inst_d_i[24:20]),
		.RegWEn_i(RegWEn_i),
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.data1_o(rs1_w), 
		.data2_o(rs2_w),
		.rd_reg_en(rd_reg_en),
		.rd_reg_addr(rd_reg_addr),
		.rd_reg_data(rd_reg_data)
		);
	
	imm_gen ImmGen_ID(
		.inst_i(inst_d_i[31:7]),
		.ImmSel_i(ImmSel_w),
		.imm_o(imm_w)
		);
		
	ctrl_unit CtrlUnit_ID(
		.inst_i(inst_d_i),
		.RegWEn_o(RegWEn_w),
		.AluSel_o(AluSel_w),
		.Bsel_o(BSel_w),
		.ImmSel_o(ImmSel_w),
		.MemRW_o(MemRW_w),
		.WBSel_o(WBSel_w),
		.BrUn_o(BrUn_w),
		.Asel_o(ASel_w),
		//.Mul_ext_o(Mul_ext_w)
		/* valid signal when CPU access cache */
		.Valid_cpu2cache_o(Valid_cpu2cache_w),
		.csr_we (csr_we_w),
		.is_mret (is_mret)
		);
	
	logic intr_flag_w;
	logic [31:0] pc_intr_w;
	logic intr_flag_r;
	logic [31:0] pc_intr_r;

 
	csr_regs CSR_Regs (					//31             20 19    15 14    12 11     7 6     0  
		.clk_i		(clk_i),			//|       csr      |   rs1  | funct3 |   rd   |opcode|  csrrx
		.rst_ni		(rst_ni),			//|       csr      |   uimm | funct3 |   rd   |opcode|  csrrxi
		.e_intr		(e_intr),
		.is_mret	(is_mret & ~reset_i),
		.addr_r		({20'h00000,inst_d_i[31:20]}),
		.addr_w		(csr_waddr_i),		
		.we			(csr_we_i),
		.inst_i		(inst_d_i),		
		.pc_i		(pc_d_i),
		.data_i		(csr_wdata_i),
		.intr_flag	(intr_flag_w),
		.pc_o		(pc_intr_w),
		.data_o		(csr_rdata_w)
	);

	always_ff @(posedge clk_i) begin
		if (~rst_ni) begin
			intr_flag_r <= 1'b0;
			pc_intr_r <= 32'b0;
		end
		else if (~enable_i && intr_flag_r) begin 
			intr_flag_r <= intr_flag_r;
			pc_intr_r <= pc_intr_r;
		end
		else begin
			intr_flag_r <= intr_flag_w;
			pc_intr_r <= pc_intr_w;
		end
	end

	assign intr_flag = (enable_i) ? intr_flag_r : 0;
	assign pc_intr_o = (enable_i) ? pc_intr_r : 32'b0;

	assign csr_waddr_w = {20'h00000,inst_d_i[31:20]};

	always_ff @(posedge clk_i) begin
		if (~rst_ni) begin
			rs1_r <= 32'b0;
			rs2_r <= 32'b0;
			imm_r <= 32'b0;
			pc_r <= 32'b0;
			pc4_r <= 32'b0;
			AluSel_r <= 4'b0;
			BSel_r <= 1'b0;
			ASel_r <= 1'b0;
			MemRW_r <= 1'b0;
			WBSel_r <= 2'b00;
			BrUn_r <= 1'b0;
			RegWEn_r <= 1'b0;
			rsW_r <= 5'b0;
			inst_r <= 32'b0;
			hit_r <= 1'b0;
			Valid_cpu2cache_r <= 1'b0;
			csr_rdata_r <= 32'b0;
			csr_we_r <= 1'b0;
			csr_waddr_r <= 32'b0;
			is_mret_r <= 1'b0;
			pc_mret_r <= 32'b0;
		end
		else if (enable_i) begin 
			if (reset_i) begin
				rs1_r <= 32'b0;
				rs2_r <= 32'b0;
				imm_r <= 32'b0;
				pc_r <= 32'b0;
				pc4_r <= 32'b0;
				AluSel_r <= 4'b0;
				BSel_r <= 1'b0;
				ASel_r <= 1'b0;
				MemRW_r <= 1'b0;
				WBSel_r <= 2'b00;
				BrUn_r <= 1'b0;
				RegWEn_r <= 1'b0;
				rsW_r <= 5'b0;
				inst_r <= 32'b0;
				hit_r <= 1'b0;
				Valid_cpu2cache_r <= 1'b0;
				csr_rdata_r <= 32'b0;
				csr_we_r <= 1'b0;
				csr_waddr_r <= 32'b0;
				is_mret_r <= 1'b0;
				pc_mret_r <= 32'b0;
			end
			else begin
				rs1_r <= rs1_w;
				rs2_r <= rs2_w;
				imm_r <= imm_w;
				pc_r <= pc_d_i;	
				pc4_r <= pc4_d_i;
				AluSel_r <= AluSel_w;
				BSel_r <= BSel_w;
				ASel_r <= ASel_w;
				MemRW_r <= MemRW_w;
				WBSel_r <= WBSel_w;
				BrUn_r <= BrUn_w;
				RegWEn_r <= RegWEn_w;
				rsW_r <= inst_d_i[11:7];
				inst_r <= inst_d_i;
				hit_r <= hit_d_i;
				Valid_cpu2cache_r <= Valid_cpu2cache_w;
				csr_rdata_r <= csr_rdata_w;
				csr_we_r <= csr_we_w;
				csr_waddr_r <= csr_waddr_w;
				is_mret_r <= is_mret;
				pc_mret_r <= pc_intr_w;
			end
		end
	end
	
	assign rs1_ex_o = rs1_r;
	assign rs2_ex_o = rs2_r;
	assign imm_ex_o = imm_r;
	assign pc_ex_o = pc_r;
	assign pc4_ex_o = pc4_r;
	assign AluSel_ex_o = AluSel_r;
	assign BSel_ex_o = BSel_r;
	assign ASel_ex_o = ASel_r;
	assign MemRW_ex_o = MemRW_r;
	assign WBSel_ex_o = WBSel_r;	
	assign BrUn_ex_o = BrUn_r;
	assign RegWEn_ex_o = RegWEn_r;
	assign rsW_ex_o = rsW_r;
	assign inst_ex_o = inst_r;
	assign hit_ex_o = hit_r;
	assign Valid_cpu2cache_ex_o = Valid_cpu2cache_r;
	assign csr_rdata_o = csr_rdata_r;
	assign csr_we_o    = csr_we_r;
	assign csr_waddr_o = csr_waddr_r;
	assign alu_csr_sel_o = csr_we_r;
	assign is_mret_o = is_mret_r;
	assign pc_mret_o = pc_mret_r;

endmodule
