module gm11 (input logic [7:0] in,
             output logic [7:0] out);

logic [7:0] gm8_w;
logic [7:0] gm2_w;
gm8 gm8 (.in (in),
         .out(gm8_w));
         
gm2 gm2 (.in (in),
         .out(gm2_w));
assign out = gm8_w ^ gm2_w ^ in;
    
endmodule