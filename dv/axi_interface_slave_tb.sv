`timescale 1ns / 1ps

module axi_interface_slave_tb;
parameter simulation_cycle = 100;
bit SystemClock;
slave_0_io top_io (SystemClock);
test_slave t(top_io);

axi_interface_slave dut (
.clk_i      (top_io.clock),
.rst_ni     (top_io.rst_ni),
.awid       (top_io.awid),
.awaddr     (top_io.awaddr),
.awlen      (top_io.awlen),
.awsize     (top_io.awsize),
.awburst    (top_io.awburst),
.awvalid    (top_io.awvalid),
.awready    (top_io.awready),
.wdata      (top_io.wdata),
.wstrb      (top_io.wstrb),
.wvalid     (top_io.wvalid),
.wlast      (top_io.wlast),
.wready     (top_io.wready),
.bid        (top_io.bid),
.bresp      (top_io.bresp),
.bvalid     (top_io.bvalid),
.bready     (top_io.bready),
.arid       (top_io.arid),
.araddr     (top_io.araddr),
.arlen      (top_io.arlen),
.arburst    (top_io.arburst),
.arsize     (top_io.arsize),
.arvalid    (top_io.arvalid),
.arready    (top_io.arready),
.rid        (top_io.rid),
.rdata      (top_io.rdata),
.rresp      (top_io.rresp),
.rvalid     (top_io.rvalid),
.rlast      (top_io.rlast),
.rready     (top_io.rready),
.o_we       (top_io.o_we),
.o_waddr    (top_io.o_waddr),
.o_wdata    (top_io.o_wdata),
.o_strb     (top_io.o_strb),
.o_re       (top_io.o_re),
.o_raddr    (top_io.o_raddr),
.i_rdata    (top_io.i_rdata)
);  

dpram mem (.clk_i   (top_io.clock),
           .rst_ni  (top_io.rst_ni),
           .waddr_i (top_io.o_waddr),
           .wdata_i (top_io.o_wdata),
           .we_i    (top_io.o_we),
           .raddr_i (top_io.o_raddr),
           .re_i    (top_io.o_re),
           .rdata_o (top_io.i_rdata));

initial begin
    SystemClock = 0;
end
always #(simulation_cycle/2) SystemClock = !SystemClock;
endmodule







//interface.//
interface slave_0_io(input bit clock);
    logic rst_ni;
    //AW channel
    logic [`ID_BITS - 1:0] awid;
    logic [`ADDR_WIDTH - 1:0] awaddr;
    logic [`LEN_BITS - 1:0] awlen;
    logic [`SIZE_BITS -1 :0] awsize;
    logic [1:0] awburst;
    logic awvalid;
    logic awready;
    //W channel
    logic [`DATA_WIDTH - 1:0] wdata;
    logic [(`DATA_WIDTH/8)-1:0] wstrb;
    logic wvalid;
    logic wlast;
    logic wready;
    //B channel
    logic [`ID_BITS - 1:0] bid;
    logic [2:0] bresp;
    logic bvalid;
    logic bready;
    //AR channel
    logic [`ID_BITS - 1:0] arid;
    logic [`ADDR_WIDTH - 1:0] araddr;
    logic [`LEN_BITS - 1:0] arlen;
    logic [1:0] arburst;
    logic [`SIZE_BITS - 1:0] arsize;
    logic arvalid;
    logic arready;
    //R channel
    logic [`ID_BITS - 1:0] rid;
    logic [`DATA_WIDTH - 1:0] rdata;
    logic [2:0] rresp;
    logic rvalid;
    logic rlast;
    logic rready;
    logic o_we;
    logic [`ADDR_WIDTH-1:0] o_waddr;
    logic [`DATA_WIDTH-1:0] o_wdata;
    logic [(`DATA_WIDTH/8)-1:0] o_strb;
    logic o_re;
    logic [`ADDR_WIDTH-1:0] o_raddr;
    logic [`DATA_WIDTH-1:0] i_rdata;
    clocking cb@(posedge clock);
        default input #1 output #1;
        output rst_ni;
        //AW channel
        output awid;
        output awaddr;
        output awlen;
        output awsize;
        output awburst;
        output awvalid;
        input awready;
        //W channel
        output wdata;
        output wstrb;
        output wvalid;
        output wlast;
        input wready;
        //B channel
        input bid;
        input bresp;
        input bvalid;
        output bready;
        //AR channel
        output arid;
        output araddr;
        output arlen;
        output arburst;
        output arsize;
        output arvalid;
        input arready;
        //R channel
        input rid;
        input rdata;
        input rresp;
        input rvalid;
        input rlast;
        output rready;
        input o_we;
        input o_waddr;
        input o_wdata;
        input o_re;
        input o_raddr;
        input o_strb;
        output i_rdata;
    endclocking: cb
    modport TB(clocking cb, output rst_ni);
endinterface




//program test.//
program automatic test_slave (slave_0_io.TB s_io);
    logic [`ADDR_WIDTH-1:0] addr;
    logic [`DATA_WIDTH-1:0] data [$];
    
    initial begin
        reset();
        //test1: one write transfer.
//        write_with_input (32'h00000800,32'h00112233,32'h44556677,32'h8899aabb,32'hccddeeff,2,3,0); 
        //test2: two write transfer in a row (test for skid buffer)
        test2();
        //test3: one read transfer.
//        read_with_input (32'h00000004,2,3,1,0);            
        #1000;
        $stop;
    end
    
    task reset();
        s_io.rst_ni     <= 1'b0;
        s_io.cb.awid    <= 0;
        s_io.cb.awaddr  <= 0;
        s_io.cb.awlen   <= 0;
        s_io.cb.awsize  <= 0;
        s_io.cb.awburst <= 0;
        s_io.cb.awvalid <= 0;
        
        s_io.cb.wdata  <= 0;
        s_io.cb.wstrb  <= 0;
        s_io.cb.wvalid <= 0;
        s_io.cb.wlast  <= 0;
        
        s_io.cb.bready <= 0;
        
        s_io.cb.arid    <= 0;
        s_io.cb.araddr  <= 0;
        s_io.cb.arlen   <= 0;
        s_io.cb.arburst <= 0;
        s_io.cb.arsize  <= 0;
        s_io.cb.arvalid <= 0;
        
        s_io.cb.rready  <= 0;
        
        s_io.cb.i_rdata <= 0;
        #2; 
        s_io.cb.rst_ni  <= 1'b1;
        repeat(2) @(s_io.cb);
        
    endtask: reset

task gen ();
    repeat($urandom_range(1,4))
        data.push_back($random);
endtask: gen

    // Task for writing to mem
task write_with_input (input [`ADDR_WIDTH-1:0] address, 
            input [`DATA_WIDTH-1:0] data0,
            input [`DATA_WIDTH-1:0] data1,
            input [`DATA_WIDTH-1:0] data2,
            input [`DATA_WIDTH-1:0] data3,
            input [`SIZE_BITS-1:0] size,
            input [`LEN_BITS-1:0] len,
            input [1:0] burst);
    s_io.cb.awaddr <= address;
    s_io.cb.awsize <= size;
    s_io.cb.awlen  <= len;
    s_io.cb.awburst <= burst;
    s_io.cb.awvalid <= 1;
    wait(s_io.cb.awready == 1);
    @s_io.cb;
    s_io.cb.awvalid <= 0;
    s_io.cb.wvalid <= 1; 
    for (int i = 0 ; i < len+1; i++) begin
        if (i == 0)
            s_io.cb.wdata <= data0;
        else if (i == 1) 
            s_io.cb.wdata <= data1;
        else if (i == 2) 
            s_io.cb.wdata <= data2;
        else if (i == 3)
            s_io.cb.wdata <= data3;
        if (i == len) begin
            s_io.cb.wlast <= 1;
            s_io.cb.wvalid <= 1;
        end
        @s_io.cb;
        if (!s_io.cb.wready)
            i = i - 1;
    end   
    s_io.cb.wlast <= 0;
    s_io.cb.bready <= 1;
    s_io.cb.wvalid <= 0;
    @s_io.cb;
    s_io.cb.bready <= 0;
endtask

task read_with_input (input [`ADDR_WIDTH - 1:0] address,
                      input [`SIZE_BITS-1:0] size,
                      input [`LEN_BITS-1:0] len,
                      input [1:0] burst,
                      input [`ID_BITS - 1:0] id);
    s_io.cb.araddr <= address;
    s_io.cb.arsize <= size;
    s_io.cb.arlen  <= len;
    s_io.cb.arburst <= burst;
    s_io.cb.arvalid <= 1;
    wait(s_io.cb.awready == 1);
    @s_io.cb;
    s_io.cb.arvalid <= 0;
    s_io.cb.rready <= 1;
endtask

task test2 ();
    //first request
    s_io.cb.awaddr <= 32'h900;
    s_io.cb.awsize <= 2;
    s_io.cb.awlen  <= 3;
    s_io.cb.awburst <= 1;
    s_io.cb.awvalid <= 1;
    wait(s_io.cb.awready == 1);
    @s_io.cb;
    //second request
    s_io.cb.awaddr <= 32'h930;
    s_io.cb.awsize <= 2;
    s_io.cb.awlen  <= 3;
//    s_io.cb.awvalid <= 0;
    s_io.cb.wvalid <= 1; 
    //first data
    for (int i = 0 ; i < 4; i++) begin
        if (i == 0) 
            s_io.cb.wdata <= 32'h00112233;
        else if (i == 1) begin
            s_io.cb.wdata <= 32'h44556677;
            s_io.cb.awvalid <= 0;
        end
        else if (i == 2) 
            s_io.cb.wdata <= 32'h8899aabb;
        else if (i == 3)
            s_io.cb.wdata <= 32'hccddeeff;
        if (i == 3) begin
            s_io.cb.wlast <= 1;
            s_io.cb.wvalid <= 1;
        end
        @s_io.cb;
        if (!s_io.cb.wready)
            i = i - 1;
    end   
    s_io.cb.wlast <= 0;
    s_io.cb.bready <= 1;
    @s_io.cb;
    s_io.cb.bready <= 0;
    //second data
    s_io.cb.wvalid <= 1;
    for (int i = 0 ; i < 4; i++) begin
        if (i == 0)
            s_io.cb.wdata <= 32'hccddeeff;
        else if (i == 1) 
            s_io.cb.wdata <= 32'h8899aabb;
        else if (i == 2) 
            s_io.cb.wdata <= 32'h44556677;
        else if (i == 3)
            s_io.cb.wdata <= 32'h00112233;
        if (i == 3) begin
            s_io.cb.wlast <= 1;
            s_io.cb.wvalid <= 1;
        end
        @s_io.cb;
        if (!s_io.cb.wready)
            i = i - 1;
    end   
    s_io.cb.wlast <= 0;
    s_io.cb.bready <= 1;
    s_io.cb.wvalid <= 0;
    @s_io.cb;
    s_io.cb.bready <= 0;
endtask
endprogram
