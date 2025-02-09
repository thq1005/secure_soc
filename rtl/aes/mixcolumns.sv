module mixcolumns (input [127:0] in,
                   output [127:0] out);
                   
logic [31:0] w0, w1, w2, w3;
logic [31:0] ws0, ws1, ws2, ws3;

assign w0 = in[127:96];
assign w1 = in[95:64];
assign w2 = in[63:32];
assign w3 = in[31:0];
    
mixw m0 (.in (w0),
         .out(ws0));
         
mixw m1 (.in (w1),
         .out(ws1));  
         
mixw m2 (.in (w2),
         .out(ws2)); 
         
mixw m3 (.in (w3),
         .out(ws3));      
    
assign out = {ws0,ws1,ws2,ws3};

endmodule 
