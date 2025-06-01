`include "../define.sv"
import cache_def::*;
/* cache: data memory, single port, 1024 blocks */
module cache_data(
    input logic clk_i,
    input logic rst_ni,
    input cache_req_type data_req_i,
    input cache_data_type data_write_i,
    input logic [`INDEX_WAY-1:0] address_way_tag2data_i,
    output cache_data_type data_read_o
);

    logic [127:0] data_i;
    logic [127:0] data_o;

    assign data_i = data_write_i;
    assign data_read_o = data_o;

    block_ram_single_port #(
        .DATA_WIDTH(128),
        .DEPTH(`WAYS*`DEPTH)
    ) cache_data_ram (
        .rd_data(data_o),
        .wr_data(data_i),
        .addr({data_req_i.index,address_way_tag2data_i}),
        .cs (1),
        .wr_en(data_req_i.we),
        .clk(clk_i),
        .rst_n(rst_ni) 
    );

endmodule
