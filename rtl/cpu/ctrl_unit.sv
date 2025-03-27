`include "../define.sv"

module ctrl_unit(
	input logic [31:0] inst_i,
	output logic RegWEn_o,
	output logic [3:0] AluSel_o, // same as AluOp
	output logic Bsel_o,
	output logic [2:0] ImmSel_o,
	output logic MemRW_o,
	output logic [1:0] WBSel_o,
	output logic BrUn_o,
	output logic Asel_o,
	/* valid signal when CPU access cache */
	output logic Valid_cpu2cache_o,
	output logic Valid_cpu2aes_o,
	output logic is_mret,
	output logic csr_we,
	output logic aes_load
	);

	logic [6:0] opcode_r;
	logic [2:0] funct3;
	logic [6:0] funct7;
	
	assign opcode_r = inst_i[6:0];
	assign funct3 = inst_i[14:12];
	assign funct7 = inst_i[31:25];
	
	assign RegWEn_o = 		(opcode_r == `OP_Stype) | // S type & B type & AES_S type
							(opcode_r == `OP_Btype) |
							(opcode_r == `OP_AES_Stype) |
							(opcode_r == `OP_Itype_csr && inst_i[11:7] == 0) ? (1'b0) : (1'b1);
	
	// 10 instructions R type
	assign AluSel_o = 		((opcode_r == `OP_Btype) | (opcode_r == `OP_JAL)   | (opcode_r == `OP_Itype_load) |
							(opcode_r == `OP_Stype)  | (opcode_r == `OP_AUIPC) | (opcode_r == `OP_JALR)       |
							((opcode_r == `OP_Itype) & (funct3 == 3'b000)))    | 
							((opcode_r == `OP_Itype_csr) & (funct3 == 3'b001 | funct3 == 3'b101)) |
							(opcode_r == `OP_AES_Stype) | (opcode_r == `OP_AES_Itype) ? `ADD :						// in case addi 
							(opcode_r == `OP_LUI) ? `B : 
							((opcode_r == `OP_Itype_csr) & (funct3 == 3'b011 | funct3 == 3'b111)) ? `AND :
							((opcode_r == `OP_Itype_csr) & (funct3 == 3'b010 | funct3 == 3'b110)) ? `OR : {funct7[5], funct3};
	
	assign Bsel_o = ((opcode_r == `OP_Rtype)|(opcode_r == `OP_Itype_csr)) ? 1'b0 : 1'b1;
	
	assign ImmSel_o = 	((opcode_r == `OP_Itype) | (opcode_r == `OP_JALR) | (opcode_r == `OP_Itype_load) | (opcode_r == `OP_Itype_csr) | (opcode_r == `OP_AES_Itype)) 	? `I_TYPE : 
					    ((opcode_r == `OP_Stype) | (opcode_r == `OP_AES_Stype)) 															? `S_TYPE : 
					    (opcode_r == `OP_Btype)																								? `B_TYPE : 
                        (opcode_r == `OP_JAL)   																							? `J_TYPE : 
                    	((opcode_r == `OP_LUI) | (opcode_r == `OP_AUIPC))																	? `U_TYPE : 3'b111;

	assign MemRW_o = ((opcode_r == `OP_Stype)) ? 1'b1 : 1'b0;
	
	assign WBSel_o = 	(opcode_r == `OP_Itype_load)								? 2'b00 : 
						((opcode_r == `OP_JAL) | (opcode_r == `OP_JALR)) 			? 2'b10 : 
						(opcode_r == `OP_Itype_csr) 								? 2'b11	: 2'b01;
	
	assign BrUn_o = ((funct3 == `BLTU) | (funct3 == `BGEU)) ? 1'b1 : 1'b0;
	
	
	
	assign Asel_o = 	((opcode_r == `OP_Btype) |
						(opcode_r == `OP_JAL)    | 
						(opcode_r == `OP_AUIPC)) ? 1'b1 : 1'b0;
						 
	/* valid signal when CPU access cache */
	assign Valid_cpu2cache_o = ((opcode_r == `OP_Itype_load) | (opcode_r == `OP_Stype)) ? 1'b1 : 1'b0;
	assign Valid_cpu2aes_o   = (opcode_r == `OP_AES_Stype | opcode_r == `OP_AES_Itype) ? 1'b1 : 1'b0;

	assign is_mret = ((opcode_r == `OP_Itype_csr) && (inst_i[31:20] == 12'h302));

	assign csr_we  = (opcode_r == `OP_Itype_csr);

	assign aes_load = (opcode_r == `OP_AES_Itype);
endmodule
