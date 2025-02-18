`include "../define.sv"
module skid_buffer(
    input logic clk_i,
    input logic rst_ni,
    input logic valid_i,
    output logic ready_o,
    input logic [`DATA_WIDTH+2+`SIZE_BITS+`LEN_BITS+`ID_BITS-1:0] data_i,
    output logic valid_o,
    input logic ready_i,
    output logic [`DATA_WIDTH+2+`SIZE_BITS+`LEN_BITS+`ID_BITS-1:0] data_o
    );

logic r_valid;
logic [`DATA_WIDTH+2+`SIZE_BITS+`LEN_BITS+`ID_BITS-1:0] r_data;

always_ff @(posedge clk_i) begin
    if (!rst_ni)
        r_valid <= 0;
    else if (valid_i && ready_o && valid_o && !ready_i)
        // We have incoming data, but the output is stalled
        r_valid <= 1;
    else if (ready_i) 
        r_valid <= 0;
end   

always_ff @(posedge clk_i) begin
    if (ready_o) 
        r_data <= data_i;
end
          
always_comb begin
    ready_o = !r_valid;
end

always_comb begin
    valid_o = (valid_i || r_valid);
end

always_comb begin
    if (r_valid)
        data_o = r_data;
    else
        data_o = data_i;
end
endmodule
