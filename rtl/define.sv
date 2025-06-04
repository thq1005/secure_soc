`ifndef DEFINE_sv
`define DEFINE_sv

//cache define
`define TAGMSB          31       
`define TAGLSB          8        
`define INDEX           4        
`define DEPTH           16       
`define WAYS            4        
`define INDEX_WAY       2   
`define NO_TAG_TYPE     24

// Opcode of all types in RISC-V
`define OP_Rtype 		 7'b0110011
`define OP_Itype 		 7'b0010011
`define OP_Itype_load    7'b0000011
`define OP_Itype_csr     7'b1110011
`define OP_Stype 		 7'b0100011
`define OP_Btype 		 7'b1100011
`define OP_JAL 		     7'b1101111
`define OP_LUI 		     7'b0110111
`define OP_AUIPC 		 7'b0010111
`define OP_JALR 		 7'b1100111
// Opcode for AES-128
`define OP_AES_Stype     7'b0100111
`define OP_AES_Itype     7'b0001011

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

//funct 3 for AES
 `define BLOCK  3'b000
 `define KEY    3'b001
 `define START  3'b010
 `define CONFI  3'b011
 `define RESULT 3'b100
 `define CTRL   3'b101
 `define STATUS 3'b000

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
`define ADDR_CTRL           32'h10000000
`define CTRL_ON0_BIT        0
`define CTRL_ON1_BIT        1
`define CTRL_ON2_BIT        2
`define CTRL_ON3_BIT        3
`define ADDR_STATUS         32'h10000004
`define STATUS_READY_BIT    0
`define STATUS_VALID_BIT    1
`define ADDR_CONFIG         32'h10000008
`define CTRL_ENCDEC0_BIT    0
`define CTRL_ENCDEC1_BIT    1
`define CTRL_ENCDEC2_BIT    2
`define CTRL_ENCDEC3_BIT    3
`define ADDR_START          32'h1000000c
`define START_BIT           0
`define ADDR_BLOCK0         32'h10000010
`define ADDR_BLOCK1         32'h10000020
`define ADDR_BLOCK2         32'h10000030
`define ADDR_BLOCK3         32'h10000040
`define ADDR_KEY0           32'h10000050
`define ADDR_KEY1           32'h10000060
`define ADDR_KEY2           32'h10000070
`define ADDR_KEY3           32'h10000080
`define ADDR_RESULT0        32'h10000090
`define ADDR_RESULT1        32'h100000a0
`define ADDR_RESULT2        32'h100000b0
`define ADDR_RESULT3        32'h100000c0 

//DMA
`define ADDR_VALID          32'h2000000c
`define ADDR_ADDR_SRC       32'h20000000
`define ADDR_ADDR_DST       32'h20000004
`define ADDR_CONFIG_DMA     32'h20000008
`define ADDR_STATUS_DMA     32'h20000010
`define DMA_BURST_BIT0      11
`define DMA_BURST_BIT1      12
`define DMA_LEN_BIT0        0
`define DMA_LEN_BIT7        7
`define DMA_SIZE_BIT0       8
`define DMA_SIZE_BIT2       10

//PLIC
`define ADDR_PRIORITY1      32'h30000000
`define ADDR_PRIORITY2      32'h30000004
`define ADDR_PRIORITY3      32'h30000008
`define ADDR_ENABLE         32'h3000000c
`define ADDR_THRESHOLD      32'h30000010
`define ADDR_CLAIM_COMPLETE 32'h30000014

//define for sdio IP
`define SDIO_AXI
`define AW_AXIL             5

`endif
