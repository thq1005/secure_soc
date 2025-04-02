`include "../define.sv"
import cache_def::*;

module cache_pLRU(
    input logic clk_i,
    input logic rst_ni,
    input logic valid_i,
    input logic [`INDEX-1:0] index_i,
    input logic [`INDEX_WAY-1:0] address_i,
    output logic [`INDEX_WAY-1:0] address_o
);

    logic L0, L1, L2;
    logic L1_w,  L2_w,  L3_w,  L4_w,  L5_w,  L6_w; // signal notices that a node need to change
    logic [`INDEX_WAY-1:0] pLRU;

   
    cache_pLRU_node NODE_L0(
        .clk_i(clk_i),
        .rst_ni(rst_ni),
        .valid_i(valid_i),
        .index_i(index_i),
        .value_i(address_i[1]),
        .load_left_o(L1_w),
        .load_right_o(L2_w),
        .load_o(L0)
    );

    cache_pLRU_node NODE_L1(
        .clk_i(clk_i),
        .rst_ni(rst_ni),
        .valid_i(L1_w),
        .index_i(index_i),
        .value_i(address_i[0]),
        .load_left_o(L3_w),
        .load_right_o(L4_w),
        .load_o(L1)
    );

    cache_pLRU_node NODE_L2(
        .clk_i(clk_i),
        .rst_ni(rst_ni),
        .valid_i(L2_w),
        .index_i(index_i),
        .value_i(address_i[0]),
        .load_left_o(L5_w),
        .load_right_o(L6_w),
        .load_o(L2)
    );

    
    
    always_comb begin
        pLRU[1] = (~L0);
        if (~pLRU[1]) pLRU[0] = (~L1);
        else pLRU[0] = (~L2);
    end

    assign address_o = pLRU;

endmodule

module cache_pLRU_node(
    input logic clk_i,
    input logic rst_ni,
    input logic valid_i,
    input logic [`INDEX-1:0] index_i,
    input logic value_i,
    output logic load_left_o,
    output logic load_right_o,
    output logic load_o
);

    logic [`DEPTH-1:0] L_r;

    always_ff @(posedge clk_i) begin
        if (~rst_ni) begin
            L_r <= {`DEPTH{1'b0}};
        end
        else if (valid_i) begin
            L_r[index_i] <= value_i;
        end
    end

    assign load_left_o = (valid_i & (~value_i));
    assign load_right_o = (valid_i & value_i);
    assign load_o = L_r[index_i];

endmodule