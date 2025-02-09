`ifndef DEFINE_sv
`define DEFINE_sv

// Opcode of all types in RISC-V
`define OP_Rtype 		 7'b0110011
`define OP_Itype 		 7'b0010011
`define OP_Itype_load    7'b0000011
`define OP_Stype 		 7'b0100011
`define OP_Btype 		 7'b1100011
`define OP_JAL 		     7'b1101111
`define OP_LUI 		     7'b0110111
`define OP_AUIPC 		 7'b0010111
`define OP_JALR 		 7'b1100111
// Opcode for AES-128
`define OP_DMA_Stype     7'b0100111

// ALU function decode from funct3 and bit 5 of funct7
`define ADD  4'b0000
`define SUB  4'b1000
`define SLL  4'b0001
`define SLT  4'b0010
`define SLTU 4'b0011
`define XOR  4'b0100
`define SRL  4'b0101
`define SRA  4'b1101
`define OR   4'b0110
`define AND  4'b0111
`define B	 4'b1111 // in case of grab only immediate value in LUI instruction


// Immediate generation type 
`define I_TYPE 3'b000
`define S_TYPE 3'b001
`define B_TYPE 3'b010
`define J_TYPE 3'b011
`define U_TYPE 3'b100


// Control signal (funct3) for Branch Comparator
`define BEQ  3'b000
`define BNE  3'b001
`define BLT  3'b100
`define BGE  3'b101
`define BLTU 3'b110
`define BGEU 3'b111

//cache         |       tag       |  index  | offset |
//              31               7 6       4 3       0 
`define DATA_WIDTH_CACHE  128


//MEM
`define DATA_WIDTH     32
`define DATA_WIDTH_MEM 128
`define ADDR_WIDTH     32

//AXI4
`define ID_BITS   8
`define LEN_BITS  8
`define SIZE_BITS 3
`define RESP_OKAY 0

//AES-128
`define AES_ROUND           10
`define KEY_WIDTH           128
`define ADDR_CTRL           8'h8
`define CTRL_INIT_BIT       0
`define CTRL_NEXT_BIT       1
`define ADDR_STATUS         8'h9
`define STATUS_READY_BIT    0
`define STATUS_VALID_BIT    1
`define ADDR_CONFIG         8'ha
`define CTRL_ENCDEC_BIT     0
`define ADDR_KEY0           8'h10
`define ADDR_KEY3           8'h13
`define ADDR_BLOCK0         8'h14
`define ADDR_BLOCK3         8'h17
`define ADDR_RESULT0        8'h30
`define ADDR_RESULT3        8'h33

//Asyn AXI to AXI bridge
`define FIFO_DEPTH               8

//DMA
`define ADDR_VALID          8'h0
`define ADDR_ADDR_SRC       8'h1
`define ADDR_ADDR_DST       8'h2
`define ADDR_CONFIG         8'h3
`define DMA_BURST_BIT0      0
`define DMA_BURST_BIT1      1
`define DMA_LEN_BIT0        2
`define DMA_LEN_BIT7        9
`define DMA_SIZE_BIT0       10
`define DMA_SIZE_BIT1       11

//ADDR MAP
`define ADDR_DATA           32'h00000000
`define ADDR_DMA            32'h00010000
`define ADDR_AES            32'h00020000
`endif
