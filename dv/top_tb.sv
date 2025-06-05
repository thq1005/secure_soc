`timescale 1ns / 1ps
module top_tb;
    logic ACLK_1;
    logic ACLK_2;
    logic ARESETn_1;
    logic ARESETn_2;


    wire [3:0] dat;
    wire cmd;
    logic clk_o;
    top top_inst (.clk_p     (ACLK_1),
                  .clk_n     (ACLK_2),
                  .ARESETn_1  (ARESETn_1),
                  .io_cmd    (cmd),
                  .io_dat    (dat),
                  .sd_clk (clk_o)
                  );
    
    always #2.5 ACLK_1 = ~ACLK_1;
    always #2.5 ACLK_2 = ~ACLK_2;
    
    initial begin
        ACLK_1 = 1;
        ACLK_2 = 0;
        ARESETn_1  = 0;
        ARESETn_2  = 0;
        #27;
        ARESETn_1  = 1;
        ARESETn_2  = 1;
        #1000;
        $finish;
    end

endmodule
