`timescale 1ns / 1ps

module block_ram_single_port #(
    parameter DATA_WIDTH      = 128,
    parameter DEPTH           = 2**6,
    parameter RAM_STYLE       = "block"
)(
    output logic [DATA_WIDTH-1:0]    rd_data,
    input  [DATA_WIDTH-1:0]    wr_data,
    input                      cs,
    input  [$clog2(DEPTH)-1:0] addr,
    input                      wr_en,
    input                      clk,
    input                      rst_n
);

    (* ram_style = RAM_STYLE *) reg [DATA_WIDTH-1:0] ram[0:DEPTH-1];

    // Write port
    always @ (posedge clk) begin
        if (~rst_n) begin
            integer i;
            for (i = 0; i < DEPTH; i = i + 1) begin
                ram[i] <= '0; // Initialize RAM to zero on reset
            end
        end
        else
        if (cs)
            if (wr_en) begin
                ram[addr] <= wr_data;
            end
    end

    always @ (posedge clk) begin
        if (cs) begin
            rd_data <= ram[addr];
        end
    end


endmodule