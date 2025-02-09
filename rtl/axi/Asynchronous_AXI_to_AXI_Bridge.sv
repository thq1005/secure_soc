`include "define.sv"

module Asynchronous_AXI_to_AXI_Bridge(
    //Master 0
    input logic ACLK_m,
    input logic ARESETn_m,
    //AW channel
    input  logic [`ID_BITS - 1:0] m0_awid,
    input  logic [`ADDR_WIDTH - 1:0] m0_awaddr,
    input  logic [`LEN_BITS - 1:0] m0_awlen,
    input  logic [`SIZE_BITS -1 :0] m0_awsize,
    input  logic [1:0] m0_awburst,
    input  logic m0_awvalid,
    output  logic m0_awready,
    //W channel
    input logic [`DATA_WIDTH - 1:0] m0_wdata,
    input logic [(`DATA_WIDTH/8)-1:0] m0_wstrb,
    input logic m0_wvalid,
    input logic m0_wlast,
    output  logic m0_wready,
    //B channel
    output logic [`ID_BITS - 1:0] m0_bid,
    output logic [2:0] m0_bresp,
    output logic m0_bvalid,
    input  logic m0_bready,
    //AR channel
    input  logic [`ID_BITS - 1:0] m0_arid,
    input  logic [`ADDR_WIDTH - 1:0] m0_araddr,
    input  logic [`LEN_BITS - 1:0] m0_arlen,
    input  logic [1:0] m0_arburst,
    input  logic [`SIZE_BITS - 1:0] m0_arsize,
    input  logic m0_arvalid,
    output  logic m0_arready,
    //R channel
    output  logic [`ID_BITS - 1:0] m0_rid,
    output  logic [`DATA_WIDTH - 1:0] m0_rdata,
    output  logic [2:0] m0_rresp,
    output  logic m0_rvalid,
    output  logic m0_rlast,
    input logic m0_rready,
    
    //Master 1
    //AW channel
    input  logic [`ID_BITS - 1:0] m1_awid,
    input  logic [`ADDR_WIDTH - 1:0] m1_awaddr,
    input  logic [`LEN_BITS - 1:0] m1_awlen,
    input  logic [`SIZE_BITS -1 :0] m1_awsize,
    input  logic [1:0] m1_awburst,
    input  logic m1_awvalid,
    output  logic m1_awready,
    //W channel
    input logic [`DATA_WIDTH - 1:0] m1_wdata,
    input logic [(`DATA_WIDTH/8)-1:0] m1_wstrb,
    input logic m1_wvalid,
    input logic m1_wlast,
    output  logic m1_wready,
    //B channel
    output logic [`ID_BITS - 1:0] m1_bid,
    output logic [2:0] m1_bresp,
    output logic m1_bvalid,
    input  logic m1_bready,
    //AR channel
    input  logic [`ID_BITS - 1:0] m1_arid,
    input  logic [`ADDR_WIDTH - 1:0] m1_araddr,
    input  logic [`LEN_BITS - 1:0] m1_arlen,
    input  logic [1:0] m1_arburst,
    input  logic [`SIZE_BITS - 1:0] m1_arsize,
    input  logic m1_arvalid,
    output  logic m1_arready,
    //R channel
    output  logic [`ID_BITS - 1:0] m1_rid,
    output  logic [`DATA_WIDTH - 1:0] m1_rdata,
    output  logic [2:0] m1_rresp,
    output  logic m1_rvalid,
    output  logic m1_rlast,
    input logic m1_rready,    

    //Slave 1
    input logic ACLK_s,
    input logic ARESETn_s,
    //AW channel
    output logic [`ID_BITS - 1:0] s1_awid,
    output logic [`ADDR_WIDTH - 1:0] s1_awaddr,
    output logic [`LEN_BITS - 1:0] s1_awlen,
    output logic [`SIZE_BITS -1 :0] s1_awsize,
    output logic [1:0] s1_awburst,
    output logic s1_awvalid,
    input  logic s1_awready,
    //W channel
    output logic [`DATA_WIDTH - 1:0] s1_wdata,
    output logic [(`DATA_WIDTH/8)-1:0] s1_wstrb,
    output logic s1_wvalid,
    output logic s1_wlast,
    input  logic s1_wready,
    //B channel
    input  logic [`ID_BITS - 1:0] s1_bid,
    input  logic [2:0] s1_bresp,
    input  logic s1_bvalid,
    output logic s1_bready,
    //AR channel
    output logic [`ID_BITS - 1:0] s1_arid,
    output logic [`ADDR_WIDTH - 1:0] s1_araddr,
    output logic [`LEN_BITS - 1:0] s1_arlen,
    output logic [1:0] s1_arburst,
    output logic [`SIZE_BITS - 1:0] s1_arsize,
    output logic s1_arvalid,
    input  logic s1_arready,
    //R channel
    input  logic [`ID_BITS - 1:0] s1_rid,
    input  logic [`DATA_WIDTH - 1:0] s1_rdata,
    input  logic [2:0] s1_rresp,
    input  logic s1_rvalid,
    input  logic s1_rlast,
    output logic s1_rready,

    //Slave 0
    //AW channel
    output logic [`ID_BITS - 1:0] s0_awid,
    output logic [`ADDR_WIDTH - 1:0] s0_awaddr,
    output logic [`LEN_BITS - 1:0] s0_awlen,
    output logic [`SIZE_BITS -1 :0] s0_awsize,
    output logic [1:0] s0_awburst,
    output logic s0_awvalid,
    input  logic s0_awready,
    //W channel
    output logic [`DATA_WIDTH - 1:0] s0_wdata,
    output logic [(`DATA_WIDTH/8)-1:0] s0_wstrb,
    output logic s0_wvalid,
    output logic s0_wlast,
    input  logic s0_wready,
    //B channel
    input  logic [`ID_BITS - 1:0] s0_bid,
    input  logic [2:0] s0_bresp,
    input  logic s0_bvalid,
    output logic s0_bready,
    //AR channel
    output logic [`ID_BITS - 1:0] s0_arid,
    output logic [`ADDR_WIDTH - 1:0] s0_araddr,
    output logic [`LEN_BITS - 1:0] s0_arlen,
    output logic [1:0] s0_arburst,
    output logic [`SIZE_BITS - 1:0] s0_arsize,
    output logic s0_arvalid,
    input  logic s0_arready,
    //R channel
    input  logic [`ID_BITS - 1:0] s0_rid,
    input  logic [`DATA_WIDTH - 1:0] s0_rdata,
    input  logic [2:0] s0_rresp,
    input  logic s0_rvalid,
    input  logic s0_rlast,
    output logic s0_rready
    );
    
    //fifo for AW channel
    logic [`ID_BITS + `LEN_BITS + `SIZE_BITS + 2 + `ADDR_WIDTH - 1 :0] aw_fifo_0 [`FIFO_DEPTH];
    logic [2:0] aw_wptr_0, aw_rptr_0;
    logic aw_empty_0, aw_full_0;



    assign aw_full_0  = (aw_wptr_0 + 1 == aw_rptr_0);
    assign aw_empty_0 = (aw_wptr_0 == aw_rptr_0);

    always_ff @(posedge ACLK_m) begin
        if (!ARESETn_m) begin
            aw_wptr_0 <= 0;
            for (int i = 0; i < 8; i++)
                aw_fifo_0[i] = 0;
        end
        else if (m0_awvalid && !aw_full_0) begin 
            aw_wptr_0 <= aw_wptr_0 + 1;
            aw_fifo_0[aw_wptr_0] <= {m0_awaddr,m0_awid,m0_awsize,m0_awlen,m0_awburst};
        end
    end

    always_ff @(posedge ACLK_s) begin
        if (!ARESETn_s)
            aw_rptr_0 <= 0;
        else if (s0_awready && !aw_empty_0) begin
            aw_rptr_0 <= aw_rptr_0 + 1;
        end
    end

    assign m0_awready = !aw_full_0;
    assign {s0_awaddr,s0_awid,s0_awsize,s0_awlen,s0_awburst} = aw_fifo_0[aw_rptr_0];
    assign s0_awvalid = !aw_empty_0;

    //fifo for W channel
    logic [5 + `DATA_WIDTH - 1 :0] w_fifo_0 [`FIFO_DEPTH];
    logic [2:0] w_wptr_0, w_rptr_0;
    logic w_empty_0, w_full_0;

    assign w_full_0  = (w_wptr_0 + 1 == w_rptr_0);
    assign w_empty_0 = (w_wptr_0 == w_rptr_0);

    always_ff @(posedge ACLK_m) begin
        if (!ARESETn_m) begin
            w_wptr_0 <= 0;
            for (int i = 0; i < 8; i++)
                w_fifo_0[i] = 0;
        end
        else if (m0_wvalid && !w_full_0) begin 
            w_wptr_0 <= w_wptr_0 + 1;
            w_fifo_0[w_wptr_0] <= {m0_wdata,m0_wstrb,m0_wlast};
        end
    end

    always_ff @(posedge ACLK_s) begin
        if (!ARESETn_s)
            w_rptr_0 <= 0;
        else if (s0_wready && !w_empty_0) begin
            w_rptr_0 <= w_rptr_0 + 1;
        end
    end

    assign m0_wready = !w_full_0;
    assign {s0_wdata,s0_wstrb,s0_wlast} = w_fifo_0[w_rptr_0];
    assign s0_wvalid = !w_empty_0;

    //fifo for B channel
    logic [3 + `ID_BITS - 1 :0] b_fifo_0 [`FIFO_DEPTH];
    logic [2:0] b_wptr_0, b_rptr_0;
    logic b_empty_0, b_full_0;

    assign b_full_0  = (b_wptr_0 + 1 == b_rptr_0);
    assign b_empty_0 = (b_wptr_0 == b_rptr_0);

    always_ff @(posedge ACLK_s) begin
        if (!ARESETn_s) begin
            b_wptr_0 <= 0;
            for (int i = 0; i < 8; i++)
                b_fifo_0[i] = 0;
        end   
        else if (s0_bvalid && !b_full_0) begin 
            b_wptr_0 <= b_wptr_0 + 1;
            b_fifo_0[b_wptr_0] <= {s0_bid,s0_bresp};
        end
    end

    always_ff @(posedge ACLK_m) begin
        if (!ARESETn_m)
            b_rptr_0 <= 0;
        else if (m0_bready && !b_empty_0) begin
            b_rptr_0 <= b_rptr_0 + 1;
        end
    end

    assign s0_bready = !b_full_0;
    assign {m0_bid,m0_bresp} = b_fifo_0[b_rptr_0];
    assign m0_bvalid = !b_empty_0;

    //fifo for AR channel
    logic [`ID_BITS + `LEN_BITS + `SIZE_BITS + 2 + `ADDR_WIDTH - 1 :0] ar_fifo_0 [`FIFO_DEPTH];
    logic [2:0] ar_wptr_0, ar_rptr_0;
    logic ar_empty_0, ar_full_0;

    assign ar_full_0  = (ar_wptr_0 + 1 == ar_rptr_0);
    assign ar_empty_0 = (ar_wptr_0 == ar_rptr_0);

    always_ff @(posedge ACLK_m) begin
        if (!ARESETn_m) begin
            ar_wptr_0 <= 0;
            for (int i = 0; i < 8; i++)
                ar_fifo_0[i] = 0;
        end
        else if (m0_arvalid && !ar_full_0) begin 
            ar_wptr_0 <= ar_wptr_0 + 1;
            ar_fifo_0[ar_wptr_0] <= {m0_araddr,m0_arid,m0_arsize,m0_arlen,m0_arburst};
        end
    end

    always_ff @(posedge ACLK_s) begin
        if (!ARESETn_s) begin
            ar_rptr_0 <= 0;
            for (int i = 0; i < 8; i++)
                ar_fifo_0[i] = 0;
        end
        else if (s0_arready && !ar_empty_0) begin
            ar_rptr_0 <= ar_rptr_0 + 1;
        end
    end

    assign m0_arready = !ar_full_0;
    assign {s0_araddr,s0_arid,s0_arsize,s0_arlen,s0_arburst} = ar_fifo_0[ar_rptr_0];
    assign s0_arvalid = !ar_empty_0;

    //fifo for R channel
    logic [`DATA_WIDTH + 4 + `ID_BITS - 1 :0] r_fifo_0 [`FIFO_DEPTH];
    logic [2:0] r_wptr_0, r_rptr_0;
    logic r_empty_0, r_full_0;

    assign r_full_0  = (r_wptr_0 + 1 == r_rptr_0);
    assign r_empty_0 = (r_wptr_0 == r_rptr_0);

    always_ff @(posedge ACLK_s) begin
        if (!ARESETn_s) begin
            r_wptr_0 <= 0;
            for (int i = 0; i < 8; i++)
                r_fifo_0[i] = 0;
        end
        else if (s0_rvalid && !r_full_0) begin 
            r_wptr_0 <= r_wptr_0 + 1;
            r_fifo_0[r_wptr_0] <= {s0_rid,s0_rdata,s0_rresp,s0_rlast};
        end
    end

    always_ff @(posedge ACLK_m) begin
        if (!ARESETn_m)
            r_rptr_0 <= 0;
        else if (m0_rready && !r_empty_0) begin
            r_rptr_0 <= r_rptr_0 + 1;
        end
    end

    assign s0_rready = !r_full_0;
    assign {m0_rid,m0_rdata,m0_rresp,m0_rlast} = r_fifo_0[r_rptr_0];
    assign m0_rvalid = !r_empty_0;


    //fifo for AW channel
    logic [`ID_BITS + `LEN_BITS + `SIZE_BITS + 2 + `ADDR_WIDTH - 1 :0] aw_fifo_1 [`FIFO_DEPTH];
    logic [2:0] aw_wptr_1, aw_rptr_1;
    logic aw_empty_1, aw_full_1;


    assign aw_full_1  = (aw_wptr_1 + 1 == aw_rptr_1);
    assign aw_empty_1 = (aw_wptr_1 == aw_rptr_1);

    always_ff @(posedge ACLK_m) begin
        if (!ARESETn_m) begin
            aw_wptr_1 <= 0;
            for (int i = 0; i < 8; i++)
                aw_fifo_1[i] = 0;
        end
        else if (m1_awvalid && !aw_full_1) begin 
            aw_wptr_1 <= aw_wptr_1 + 1;
            aw_fifo_1[aw_wptr_1] <= {m1_awaddr,m1_awid,m1_awsize,m1_awlen,m1_awburst};
        end
    end

    always_ff @(posedge ACLK_s) begin
        if (!ARESETn_s)
            aw_rptr_1 <= 0;
        else if (s1_awready && !aw_empty_1) begin
            aw_rptr_1 <= aw_rptr_1 + 1;
        end
    end

    assign m1_awready = !aw_full_1;
    assign {s1_awaddr,s1_awid,s1_awsize,s1_awlen,s1_awburst} = aw_fifo_1[aw_rptr_1];
    assign s1_awvalid = !aw_empty_1;

    //fifo for W channel
    logic [5 + `DATA_WIDTH - 1 :0] w_fifo_1 [`FIFO_DEPTH];
    logic [2:0] w_wptr_1, w_rptr_1;
    logic w_empty_1, w_full_1;

    assign w_full_1  = (w_wptr_1 + 1 == w_rptr_1);
    assign w_empty_1 = (w_wptr_1 == w_rptr_1);

    always_ff @(posedge ACLK_m) begin
        if (!ARESETn_m) begin
            w_wptr_1 <= 0;
            for (int i = 0; i < 8; i++)
                w_fifo_1[i] = 0;
        end
        else if (m1_wvalid && !w_full_1) begin 
            w_wptr_1 <= w_wptr_1 + 1;
            w_fifo_1[w_wptr_1] <= {m1_wdata,m1_wstrb,m1_wlast};
        end
    end

    always_ff @(posedge ACLK_s) begin
        if (!ARESETn_s)
            w_rptr_1 <= 0;
        else if (s1_wready && !w_empty_1) begin
            w_rptr_1 <= w_rptr_1 + 1;
        end
    end

    assign m1_wready = !w_full_1;
    assign {s1_wdata,s1_wstrb,s1_wlast} = w_fifo_1[w_rptr_1];
    assign s1_wvalid = !w_empty_1;

    //fifo for B channel
    logic [3 + `ID_BITS - 1 :0] b_fifo_1 [`FIFO_DEPTH];
    logic [2:0] b_wptr_1, b_rptr_1;
    logic b_empty_1, b_full_1;

    assign b_full_1  = (b_wptr_1 + 1 == b_rptr_1);
    assign b_empty_1 = (b_wptr_1 == b_rptr_1);

    always_ff @(posedge ACLK_s) begin
        if (!ARESETn_s) begin
            b_wptr_1 <= 0;
            for (int i = 0; i < 8; i++)
                b_fifo_1[i] = 0;
        end   
        else if (s1_bvalid && !b_full_1) begin 
            b_wptr_1 <= b_wptr_1 + 1;
            b_fifo_1[b_wptr_1] <= {s1_bid,s1_bresp};
        end
    end

    always_ff @(posedge ACLK_m) begin
        if (!ARESETn_m)
            b_rptr_1 <= 0;
        else if (m1_bready && !b_empty_1) begin
            b_rptr_1 <= b_rptr_1 + 1;
        end
    end

    assign s1_bready = !b_full_1;
    assign {m1_bid,m1_bresp} = b_fifo_1[b_rptr_1];
    assign m1_bvalid = !b_empty_1;

    //fifo for AR channel
    logic [`ID_BITS + `LEN_BITS + `SIZE_BITS + 2 + `ADDR_WIDTH - 1 :0] ar_fifo_1 [`FIFO_DEPTH];
    logic [2:0] ar_wptr_1, ar_rptr_1;
    logic ar_empty_1, ar_full_1;

    assign ar_full_1  = (ar_wptr_1 + 1 == ar_rptr_1);
    assign ar_empty_1 = (ar_wptr_1 == ar_rptr_1);

    always_ff @(posedge ACLK_m) begin
        if (!ARESETn_m) begin
            ar_wptr_1 <= 0;
            for (int i = 0; i < 8; i++)
                ar_fifo_1[i] = 0;
        end
        else if (m1_arvalid && !ar_full_1) begin 
            ar_wptr_1 <= ar_wptr_1 + 1;
            ar_fifo_1[ar_wptr_1] <= {m1_araddr,m1_arid,m1_arsize,m1_arlen,m1_arburst};
        end
    end

    always_ff @(posedge ACLK_s) begin
        if (!ARESETn_s) begin
            ar_rptr_1 <= 0;
            for (int i = 0; i < 8; i++)
                ar_fifo_1[i] = 0;
        end
        else if (s1_arready && !ar_empty_1) begin
            ar_rptr_1 <= ar_rptr_1 + 1;
        end
    end

    assign m1_arready = !ar_full_1;
    assign {s1_araddr,s1_arid,s1_arsize,s1_arlen,s1_arburst} = ar_fifo_1[ar_rptr_1];
    assign s1_arvalid = !ar_empty_1;

    //fifo for R channel
    logic [`DATA_WIDTH + 4 + `ID_BITS - 1 :0] r_fifo_1 [`FIFO_DEPTH];
    logic [2:0] r_wptr_1, r_rptr_1;
    logic r_empty_1, r_full_1;

    assign r_full_1  = (r_wptr_1 + 1 == r_rptr_1);
    assign r_empty_1 = (r_wptr_1 == r_rptr_1);

    always_ff @(posedge ACLK_s) begin
        if (!ARESETn_s) begin
            r_wptr_1 <= 0;
            for (int i = 0; i < 8; i++)
                r_fifo_1[i] = 0;
        end
        else if (s1_rvalid && !r_full_1) begin 
            r_wptr_1 <= r_wptr_1 + 1;
            r_fifo_1[r_wptr_1] <= {s1_rid,s1_rdata,s1_rresp,s1_rlast};
        end
    end

    always_ff @(posedge ACLK_m) begin
        if (!ARESETn_m)
            r_rptr_1 <= 0;
        else if (m1_rready && !r_empty_1) begin
            r_rptr_1 <= r_rptr_1 + 1;
        end
    end

    assign s1_rready = !r_full_1;
    assign {m1_rid,m1_rdata,m1_rresp,m1_rlast} = r_fifo_1[r_rptr_1];
    assign m1_rvalid = !r_empty_1;

endmodule
