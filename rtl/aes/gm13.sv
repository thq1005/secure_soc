module gm13 (input logic [7:0] in,
             output logic [7:0] out);

logic [7:0] gm8_w;
logic [7:0] gm4_w;
gm8 gm8 (.in (in),
           .out(gm8_w));
         
gm4 gm4 (.in (in),
         .out(gm4_w));
assign out = gm8_w ^ gm4_w ^ in;
    
endmodule