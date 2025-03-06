`timescale 1ns / 1ps
module top_tb;
    logic ACLK_1;
    logic ACLK_2;
    logic ARESETn_1;
    logic ARESETn_2;

    
    top top_inst (.ACLK_1     (ACLK_1),
                  .ACLK_2     (ACLK_2),
                  .ARESETn_1  (ARESETn_1),
                  .ARESETn_2  (ARESETn_2));
    
    always #5 ACLK_1 = ~ACLK_1;
    always #10 ACLK_2 = ~ACLK_2;
    
    initial begin
        ACLK_1 = 0;
        ACLK_2 = 0;
        ARESETn_1  = 0;
        ARESETn_2  = 0;
        #27;
        ARESETn_1  = 1;
        ARESETn_2  = 1;
    end
endmodule
