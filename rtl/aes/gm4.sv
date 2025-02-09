module gm4 (input logic [7:0] in,
            output logic [7:0] out);
            
logic [7:0] gm2_w;

gm2 gm2_0 (.in (in),
         .out(gm2_w));
         
gm2 gm2_1 (.in (gm2_w),
         .out(out));
                
    
endmodule