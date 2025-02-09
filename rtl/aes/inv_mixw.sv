module inv_mixw(
    input logic [31:0] in,
    output logic [31:0] out
    );
    
logic [7:0] b0,b1,b2,b3;
logic [7:0] mb0,mb1,mb2,mb3;
logic [7:0] gm9_0_w, gm9_1_w, gm9_2_w, gm9_3_w;
logic [7:0] gm11_0_w, gm11_1_w, gm11_2_w, gm11_3_w;
logic [7:0] gm13_0_w, gm13_1_w, gm13_2_w, gm13_3_w;
logic [7:0] gm14_0_w, gm14_1_w, gm14_2_w, gm14_3_w;

assign b0 = in[31:24];
assign b1 = in[23:16];
assign b2 = in[15:8];
assign b3 = in[7:0];

gm9 gm9_0 (.in  (b0),
           .out (gm9_0_w));
           
gm9 gm9_1 (.in  (b1),
           .out (gm9_1_w)); 
           
gm9 gm9_2 (.in  (b2),
           .out (gm9_2_w));     
           
gm9 gm9_3 (.in  (b3),
           .out (gm9_3_w));    

gm11 gm11_0 (.in  (b0),
             .out (gm11_0_w));
           
gm11 gm11_1 (.in  (b1),
             .out (gm11_1_w)); 
           
gm11 gm11_2 (.in  (b2),
             .out (gm11_2_w));     
           
gm11 gm11_3 (.in  (b3),
             .out (gm11_3_w));
           
gm13 gm13_0 (.in  (b0),
             .out (gm13_0_w));
           
gm13 gm13_1 (.in  (b1),
             .out (gm13_1_w)); 
           
gm13 gm13_2 (.in  (b2),
             .out (gm13_2_w));     
           
gm13 gm13_3 (.in  (b3),
             .out (gm13_3_w));
           
gm14 gm14_0 (.in  (b0),
             .out (gm14_0_w));
           
gm14 gm14_1 (.in  (b1),
             .out (gm14_1_w)); 
           
gm14 gm14_2 (.in  (b2),
             .out (gm14_2_w));     
           
gm14 gm14_3 (.in  (b3),
             .out (gm14_3_w));      
             
                 
assign mb0 = gm14_0_w ^ gm11_1_w ^ gm13_2_w ^ gm9_3_w;
assign mb1 = gm9_0_w  ^ gm14_1_w ^ gm11_2_w ^ gm13_3_w;
assign mb2 = gm13_0_w ^ gm9_1_w  ^ gm14_2_w ^ gm11_3_w;
assign mb3 = gm11_0_w ^ gm13_1_w ^ gm9_2_w  ^ gm14_3_w;

assign out = {mb0,mb1,mb2,mb3};
endmodule
