`include "../define.sv"
//CSR register file
module csr_regs  (
   input  logic                     clk_i,
   input  logic                     rst_ni,

   input  logic                     e_intr,     //external interrupt
   input  logic                     is_mret,

   input  logic [`ADDR_WIDTH-1:0]   addr_r,
   input  logic [`ADDR_WIDTH-1:0]   addr_w,
   input  logic                     we,

   input  logic [`DATA_WIDTH-1:0]   pc_i,
   input  logic [`DATA_WIDTH-1:0]   data_i,

   output logic                     intr_flag,
   output logic [`DATA_WIDTH-1:0]   pc_o,
   output logic [`DATA_WIDTH-1:0]   data_o

);

   parameter [`ADDR_WIDTH-1:0] MSTATUS_ADDR = 32'h00000300;
   parameter [`ADDR_WIDTH-1:0] MIE_ADDR     = 32'h00000304;
   parameter [`ADDR_WIDTH-1:0] MTVEC_ADDR   = 32'h00000305;
   parameter [`ADDR_WIDTH-1:0] MEPC_ADDR    = 32'h00000341;
   parameter [`ADDR_WIDTH-1:0] MCAUSE_ADDR  = 32'h00000342;
   parameter [`ADDR_WIDTH-1:0] MIP_ADDR     = 32'h00000344;
   localparam MEIP = 11; 
   localparam MIE  = 3;
   //internal registers of CSR register file
   logic [`DATA_WIDTH-1:0] mstatus_reg;
   logic [`DATA_WIDTH-1:0] mie_reg;
   logic [`DATA_WIDTH-1:0] mtvec_reg;
   logic [`DATA_WIDTH-1:0] mepc_reg;
   logic [`DATA_WIDTH-1:0] mcause_reg;
   logic [`DATA_WIDTH-1:0] mip_reg;

   always_comb begin  
      case(addr_r)
         MSTATUS_ADDR : data_o = mstatus_reg; //mstatus
         MIE_ADDR     : data_o = mie_reg;     //mie
         MTVEC_ADDR   : data_o = mtvec_reg;   //mtvec
         MEPC_ADDR    : data_o = mepc_reg;    //mepc
         MCAUSE_ADDR  : data_o = mcause_reg;  //mcause
         MIP_ADDR     : data_o = mip_reg;     //mip
         default      : data_o = '0;
      endcase
   end

   always_ff @ (posedge clk_i) begin  
      if (~rst_ni) begin
         mie_reg     <= '0;
         mtvec_reg   <= '0;
         mstatus_reg <= '0;
      end
      else if (we) begin
         case(addr_w)
            MSTATUS_ADDR :
               mstatus_reg <= data_i;
            MIE_ADDR     :
               mie_reg     <= data_i;  
            MTVEC_ADDR   : 
               mtvec_reg   <= data_i;   
         endcase
      end
      else if (intr_flag) begin
         mstatus_reg[MIE] <= 1'b0;
      end
      else if (is_mret) begin
         mstatus_reg[MIE] <= 1'b1;
      end
   end


   always_ff @(posedge clk_i) begin
      if (~rst_ni) begin
         mip_reg <= '0;
      end
      if (e_intr) begin
         mip_reg[MEIP] <= 1'b1;
      end
      else if (is_mret) begin
         mip_reg <= '0;
      end
   end

   always_ff @ (posedge clk_i) begin
      if (~rst_ni) begin
         mepc_reg <= '0;
      end
      else if (e_intr) begin
         mepc_reg    <= pc_i;
      end
   end
     
   always_ff @ (posedge clk_i) begin
      if (~rst_ni) 
         mcause_reg <= '0;
      else if (e_intr) 
         mcause_reg <= 32'h8000000b;z
   end

csr_ops i_csr_ops(
   .mstatus_reg(mstatus_reg),
   .mie_reg    (mie_reg    ),
   .mtvec_reg  (mtvec_reg  ),
   .mepc_reg   (mepc_reg   ),
   .mcause_reg (mcause_reg ),
   .mip_reg    (mip_reg    ),

   .is_mret    (is_mret   ),
   .intr_flag  (intr_flag ),
   .where_to_go(pc_o      )   
);

endmodule