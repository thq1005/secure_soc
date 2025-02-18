module fifo #(
    parameter DATA_W = 4,
    parameter DEPTH  = 4          
    ) (
    input clk_i,
    input rst_ni,
    input we_i,
    input re_i,
    input [DATA_W-1:0] wdata_i,
    output logic [DATA_W-1:0] rdata_o,
    output logic full,
    output logic empty
);

    logic [DATA_W-1:0] fifo [DEPTH];
    logic [$clog2(DEPTH)-1:0] wptr,rptr;

    assign full  = (wptr + 1 == rptr);
    assign empty = (wptr     == rptr);

    always_ff @(posedge clk_i) begin
        if (!rst_ni) begin
            wptr <= 0;
            for (int i = 0; i < DEPTH; i++)
                fifo[i] = 0;
        end
        else if (we_i && !full) begin 
            wptr <= wptr + 1;
            fifo[wptr] <= wdata_i;
        end
    end

    always_ff @(posedge clk_i) begin
        if (!rst_ni)
            rptr <= 0;
        else if (re_i && !empty) begin
            rptr <= rptr + 1;
        end
    end

    assign rdata_o = fifo[rptr];

endmodule