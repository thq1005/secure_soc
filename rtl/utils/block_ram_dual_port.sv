`timescale 1ns / 1ps

module block_ram_dual_port #(
    parameter DATA_WIDTH      = 32,
    parameter DEPTH           = 2**10,
    parameter RAM_STYLE       = "block"
)(
    output logic [DATA_WIDTH-1:0]    rd_data,
    input  wire [DATA_WIDTH-1:0]    wr_data,
    input  wire [$clog2(DEPTH)-1:0] addr_rd,
    input  wire [$clog2(DEPTH)-1:0] addr_wr,
    input  wire               wr_en,
    input  wire               rd_en,
    input  wire               clk
);

    (* ram_style = RAM_STYLE *) reg [DATA_WIDTH-1:0] ram[0:DEPTH-1];

    initial begin
        $readmemh ("memory.mem", ram); 
    end

    // Write port
    always @ (posedge clk) begin
        if (wr_en) begin
            ram[addr_wr] <= wr_data;
        end
    end
    // Read port
    always @ (posedge clk) begin
        if (rd_en) begin
            rd_data <= ram[addr_rd];
        end
    end


endmodule