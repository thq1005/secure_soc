module gm3 (input logic [7:0] in,
            output logic [7:0] out);
            
logic [7:0] gm2_w;

gm2 gm2 (.in (in),
         .out(gm2_w));
assign out = gm2_w ^ in;
    
endmodule