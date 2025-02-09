module gm2 (input logic [7:0] in,
            output logic [7:0] out);
            
assign out = {in[6:0],1'b0} ^ (8'h1b & {8{in[7]}});
    
endmodule