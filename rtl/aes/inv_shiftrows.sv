module inv_shiftrows (input logic [127:0] in,
                  output logic [127:0] out);
logic [31:0] w0, w1, w2, w3;
logic [31:0] ws0, ws1, ws2, ws3;

assign w0 = in[127:96];
assign w1 = in[95:64];
assign w2 = in[63:32];
assign w3 = in[31:0];

assign ws0 = {w0[31:24], w3[23:16], w2[15:8], w1[7:0]};
assign ws1 = {w1[31:24], w0[23:16], w3[15:8], w2[7:0]};
assign ws2 = {w2[31:24], w1[23:16], w0[15:8], w3[7:0]};
assign ws3 = {w3[31:24], w2[23:16], w1[15:8], w0[7:0]};

assign out = {ws0, ws1, ws2, ws3};

endmodule 