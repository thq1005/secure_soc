`timescale 1ns / 1ps
module top_tb;
    logic ACLK_1;
    logic ACLK_2;
    logic ARESETn_1;
    logic ARESETn_2;

    logic rd_reg_en;
    logic [4:0] rd_reg_addr;
    logic [31:0] rd_reg_data;
    logic rd_mem_en;
    logic [31:0] rd_mem_addr;
    logic [127:0] rd_mem_data;
    logic wr_mem_en;
    logic [31:0] wr_mem_addr;
    logic [127:0] wr_mem_data;
    logic enable;
    logic a;
    top_1 top_inst (.ACLK_1       (ACLK_1),
                  .ARESETn_1    (ARESETn_1),
                  .enable       (enable),
                  .rd_reg_en   (rd_reg_en),
                  .rd_reg_addr (rd_reg_addr),
                  .rd_reg_data (rd_reg_data),
                  .rd_mem_en   (rd_mem_en),
                  .rd_mem_addr (rd_mem_addr),
                  .rd_mem_data (rd_mem_data),
                  .rd_mem_rvalid(a),
                  .wr_mem_en   (wr_mem_en),
                  .wr_mem_addr (wr_mem_addr),
                  .wr_mem_data (wr_mem_data)    
                
                  );
    
    always #2.5 ACLK_1 = ~ACLK_1;
    always #2.5 ACLK_2 = ~ACLK_2;
    
    initial begin
        ACLK_1 = 1;
        ACLK_2 = 0;
        ARESETn_1  = 0;
        ARESETn_2  = 0;
        rd_reg_en = 0;
        rd_reg_addr = 0;
        rd_mem_en = 0;
        rd_mem_addr = 0;
        wr_mem_en = 0;
        wr_mem_addr = 0;
        wr_mem_data = 0;
        enable = 0;
        #27;
        ARESETn_1  = 1;
        ARESETn_2  = 1;
        enable = 1;
//        #225;
//        wr_mem_data = 128'h30419073008191933001907300800193;
//        wr_mem_en = 1;
//        @(posedge ACLK_1);
//        wr_mem_en = 0;
//        repeat (20) @(posedge ACLK_1);
//        rd_mem_en = 1;
//        @(posedge ACLK_1);
//        rd_mem_en = 0;
        #3973;
        enable = 0;
        rd_mem_en = 1;
        rd_reg_en = 1;
        while (1) begin
            @(posedge ACLK_1)
            rd_mem_en += 4;
            rd_reg_addr += 1;
        end
            
    end

endmodule
