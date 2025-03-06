`timescale 1ns / 1ps

module aes_tb;
parameter simulation_cycle = 100;
bit SystemClock;
bit DEBUG;
int cycle_ctr;
aes_io top_io (SystemClock);
aes_test t(top_io);

aes dut (.clk_i       (top_io.clock),
         .rst_ni      (top_io.rst_ni),
         .cs_i        (top_io.cs_i),
         .we_i        (top_io.we_i),
         .addr_i      (top_io.addr_i),
         .wdata_i     (top_io.wdata_i),
         .rdata_o     (top_io.rdata_o));

initial begin
    SystemClock = 0;
    DEBUG = 1;
end
always #(simulation_cycle/2) SystemClock = !SystemClock;

always begin 
    cycle_ctr = cycle_ctr + 1;
    
    #(simulation_cycle);
    
    if (DEBUG)
        begin
          dump_dut_state();
        end
end


  //----------------------------------------------------------------
  // dump_dut_state()
  //
  // Dump the state of the dump when needed.
  //----------------------------------------------------------------
    task dump_dut_state;
        begin
          $display("cycle: 0x%016x", cycle_ctr);
          $display("State of DUT");
          $display("------------");
          $display("ctrl_reg:   init   = 0x%01x, next   = 0x%01x", dut.init_reg, dut.next_reg);
          $display("config_reg: encdec = 0x%01x ", dut.encdec_reg);
          $display("");
          $display("key: 0x%08x, 0x%08x, 0x%08x, 0x%08x",
                   dut.key_reg[0], dut.key_reg[1], dut.key_reg[2], dut.key_reg[3]);  
          $display("block: 0x%08x, 0x%08x, 0x%08x, 0x%08x",
                   dut.block_reg[0], dut.block_reg[1], dut.block_reg[2], dut.block_reg[3]);
          $display("result: 0x%08x, 0x%08x, 0x%08x, 0x%08x",
                   dut.result_reg[0], dut.result_reg[1], dut.result_reg[2], dut.result_reg[3]);         
          $display("status: valid: 0x%01x, ready = 0x%01x", dut.valid_reg,dut.ready_reg);
          $display("");
        
        end
    endtask // dump_dut_state
   


endmodule







//interface.//
interface aes_io(input bit clock);
    logic rst_ni;
    logic cs_i;
    logic we_i;
    logic [7:0] addr_i;
    logic [31:0] wdata_i;
    logic [31:0] rdata_o;
    
    clocking a_cb @(posedge clock);
        default input #1 output #1;
        output rst_ni;
        output cs_i;
        output we_i;
        output addr_i;
        output wdata_i;
        input rdata_o;
    endclocking: a_cb
    modport a_TB(clocking a_cb, output rst_ni);
endinterface




//program test.//
program automatic aes_test (aes_io.a_TB a_io);
    logic [127:0] result;
    
    initial begin
        reset();
        setup();
        #10000;
        $stop;
    end
   
    
   
   
    
    task reset();
        a_io.rst_ni  <= '0;
        a_io.a_cb.cs_i    <= '0;
        a_io.a_cb.we_i    <= '0;
        a_io.a_cb.addr_i  <= '0;
        a_io.a_cb.wdata_i <= '0;
        #2; 
        a_io.a_cb.rst_ni  <= 1'b1;
        repeat(2) @(a_io.a_cb);      
    endtask: reset

    task setup ();
        //send key
        a_io.a_cb.cs_i   <= 1;
        a_io.a_cb.we_i   <= 1;
        a_io.a_cb.addr_i <= 32'h10;
        a_io.a_cb.wdata_i<= 32'h2b7e1516;
        @(a_io.a_cb);
        a_io.a_cb.addr_i <= 32'h11;
        a_io.a_cb.wdata_i<= 32'h28aed2a6;
        @(a_io.a_cb);
        a_io.a_cb.addr_i <= 32'h12;
        a_io.a_cb.wdata_i<= 32'habf71588;
        @(a_io.a_cb);
        a_io.a_cb.addr_i <= 32'h13;
        a_io.a_cb.wdata_i<= 32'h09cf4f3c;
        //send block
        @(a_io.a_cb);
        a_io.a_cb.addr_i <= 32'h14;
        a_io.a_cb.wdata_i<= 32'h3243f6a8;
        @(a_io.a_cb);
        a_io.a_cb.addr_i <= 32'h15;
        a_io.a_cb.wdata_i<= 32'h885a308d;
        @(a_io.a_cb);
        a_io.a_cb.addr_i <= 32'h16;
        a_io.a_cb.wdata_i<= 32'h313198a2;
        @(a_io.a_cb);
        a_io.a_cb.addr_i <= 32'h17;
        a_io.a_cb.wdata_i<= 32'he0370734;
        //send config
        @(a_io.a_cb);
        a_io.a_cb.addr_i <= 32'ha;
        a_io.a_cb.wdata_i<= 32'h00000001;
        //send ctrl
        //init
        @(a_io.a_cb);
        a_io.a_cb.addr_i <= 32'h8;
        a_io.a_cb.wdata_i<= 32'h00000001;
        //next
        @(a_io.a_cb);
        a_io.a_cb.addr_i <= 32'h9;
        a_io.a_cb.we_i   <= 0;
        repeat(3) @(a_io.a_cb);
        wait (a_io.a_cb.rdata_o[0] == 1);
        a_io.a_cb.we_i   <= 1;
        a_io.a_cb.addr_i <= 32'h8;
        a_io.a_cb.wdata_i<= 32'h00000002;
        //check valid
        @(a_io.a_cb);
        a_io.a_cb.we_i   <= 0;
        a_io.a_cb.addr_i <= 32'h9;
        //check result
        wait (a_io.a_cb.rdata_o[1] == 1);
        a_io.a_cb.addr_i <= 32'h30;
        @(a_io.a_cb);
        result[127:96] <= a_io.a_cb.rdata_o;
        a_io.a_cb.addr_i <= 32'h31;
        @(a_io.a_cb);
        result[95:64] <= a_io.a_cb.rdata_o;
        a_io.a_cb.addr_i <= 32'h32;
        @(a_io.a_cb);
        result[63:32] <= a_io.a_cb.rdata_o;
        a_io.a_cb.addr_i <= 32'h33;
        @(a_io.a_cb);
        result[31:0] <= a_io.a_cb.rdata_o;
        //send new data
        a_io.a_cb.we_i   <= 1;
        a_io.a_cb.addr_i <= 32'h14;
        a_io.a_cb.wdata_i<= result[127:96];
        @(a_io.a_cb);
        a_io.a_cb.addr_i <= 32'h15;
        a_io.a_cb.wdata_i<= result[95:64];
        @(a_io.a_cb);
        a_io.a_cb.addr_i <= 32'h16;
        a_io.a_cb.wdata_i<= result[63:32];
        @(a_io.a_cb);
        a_io.a_cb.addr_i <= 32'h17;
        a_io.a_cb.wdata_i<= result[31:0];     
        @(a_io.a_cb);
        //send config
        a_io.a_cb.we_i   <= 1;
        a_io.a_cb.addr_i <= 32'ha;
        a_io.a_cb.wdata_i<= 32'h00000000;
        //check ready
        @(a_io.a_cb);
        a_io.a_cb.we_i   <= 0;
        a_io.a_cb.addr_i <= 32'h9;  
        @(a_io.a_cb);
        wait (a_io.a_cb.rdata_o[0] == 1);
        a_io.a_cb.we_i   <= 1;
        a_io.a_cb.addr_i <= 32'h8;
        a_io.a_cb.wdata_i<= 32'h00000002;
        @(a_io.a_cb);
        a_io.a_cb.we_i   <= 0;
        a_io.a_cb.addr_i <= 32'h9;
    endtask

endprogram
