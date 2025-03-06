`timescale 1ns / 1ps

interface RISCV_io (input bit clock);
logic rst_ni;
logic [31:0] addr_o;
logic [127:0] wdata_o;
logic we_o;
logic cs_o;
logic [127:0] rdata_i;
logic rvalid_i;
clocking cb@(posedge clock);
    output rst_ni;
    input addr_o;
    input wdata_o;
    input we_o;
    input cs_o;
    output rdata_i;
    output rvalid_i;
endclocking:cb
modport TB(clocking cb, output rst_ni);
endinterface
