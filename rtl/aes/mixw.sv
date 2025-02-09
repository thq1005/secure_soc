module mixw( input logic [31:0] in,
             output logic [31:0] out);
             
logic [7:0] b0,b1,b2,b3;
logic [7:0] mb0,mb1,mb2,mb3;
logic [7:0] gm2_0_w, gm2_1_w, gm2_2_w, gm2_3_w;
logic [7:0] gm3_0_w, gm3_1_w, gm3_2_w, gm3_3_w;

assign b0 = in[31:24];
assign b1 = in[23:16];
assign b2 = in[15:8];
assign b3 = in[7:0];

gm2 gm2_0 (.in (b0),
           .out(gm2_0_w));
           
gm2 gm2_1 (.in (b1),
           .out(gm2_1_w));  
           
gm2 gm2_2 (.in (b2),
           .out(gm2_2_w)); 
           
gm2 gm2_3 (.in (b3),
           .out(gm2_3_w));     
           
gm3 gm3_0 (.in (b0),
           .out(gm3_0_w));                   
           
gm3 gm3_1 (.in (b1),
           .out(gm3_1_w)); 
           
gm3 gm3_2 (.in (b2),
           .out(gm3_2_w)); 
           
gm3 gm3_3 (.in (b3),
           .out(gm3_3_w));                
              

assign mb0 = gm2_0_w ^ gm3_1_w ^ b2      ^ b3;
assign mb1 = b0      ^ gm2_1_w ^ gm3_2_w ^ b3;
assign mb2 = b0      ^ b1      ^ gm2_2_w ^ gm3_3_w;
assign mb3 = gm3_0_w ^ b1      ^ b2      ^ gm2_3_w;

assign out = {mb0,mb1,mb2,mb3};            
endmodule
