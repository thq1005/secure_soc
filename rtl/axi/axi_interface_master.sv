`include "define.sv"

module axi_interface_master(
    input logic clk_i,
    input logic rst_ni,
    //AW channel
    output logic [`ID_BITS - 1:0] awid_o,
    output logic [`ADDR_WIDTH - 1:0] awaddr_o,
    output logic [`LEN_BITS - 1:0] awlen_o,
    output logic [`SIZE_BITS -1 :0] awsize_o,
    output logic [1:0] awburst_o,
    output logic awvalid_o,
    input  logic awready_i,
    //W channel
    output logic [`DATA_WIDTH - 1:0] wdata_o,
    output logic [(`DATA_WIDTH/8)-1:0] wstrb_o,
    output logic wvalid_o,
    output logic wlast_o,
    input  logic wready_i,
    //B channel
    input  logic [`ID_BITS - 1:0] bid_i,
    input  logic [2:0] bresp_i,
    input  logic bvalid_i,
    output logic bready_o,
    //AR channel
    output logic [`ID_BITS - 1:0] arid_o,
    output logic [`ADDR_WIDTH - 1:0] araddr_o,
    output logic [`LEN_BITS - 1:0] arlen_o,
    output logic [1:0] arburst_o,
    output logic [`SIZE_BITS - 1:0] arsize_o,
    output logic arvalid_o,
    input  logic arready_i,
    //R channel
    input  logic [`ID_BITS - 1:0] rid_i,
    input  logic [`DATA_WIDTH - 1:0] rdata_i,
    input  logic [2:0] rresp_i,
    input  logic rvalid_i,
    input  logic rlast_i,
    output logic rready_o,
    //signal of cpu
    input logic [`ADDR_WIDTH - 1:0] addr_i,
    input logic [`DATA_WIDTH_CACHE - 1:0] wdata_i,
    input logic we_i,
    input logic cs_i,
    output logic [`DATA_WIDTH_CACHE - 1:0] rdata_o,
    output logic rvalid_o,
    output logic handshaked_o,

    input logic [`ADDR_WIDTH - 1:0] dma_addr_i,
    input logic [`DATA_WIDTH - 1:0] dma_wdata_i,
    input logic dma_cs_i

    );
    
    localparam IDLE = 2'd0, WA = 2'd1, W = 2'd2, B = 2'd3, RA = 2'd1, R = 2'd2;       


    logic [3:0] w_state, w_next_state;
    logic [3:0] r_state, r_next_state;

    logic [1:0] w_len_cnt;
    logic [1:0] r_len_cnt;
        
    always_ff @(posedge clk_i) begin
        if(~rst_ni) 
            w_state <= 0;
        else
            w_state <= w_next_state; 
    end   
    
    always_ff @(posedge clk_i) begin
        if(~rst_ni) 
            r_state <= 0;
        else
            r_state <= r_next_state; 
    end         

    always_comb begin
        case (w_state)
        IDLE: begin
            if ((we_i && cs_i)|dma_cs_i)
                w_next_state = WA;
            else 
                w_next_state = IDLE;
        end        
        WA: begin
            if (awvalid_o && awready_i)
                w_next_state = W;
            else
                w_next_state = WA;
        end
        W: begin
            if (wvalid_o && wready_i && wlast_o)
                w_next_state = B;
            else
                w_next_state = W;
        end
        B: begin
            if (bvalid_i && bready_o) 
                w_next_state = IDLE;
            else 
                w_next_state = B;
        end
        endcase
    end    

    always_comb begin
        case (r_state)
        IDLE: begin
            if (!we_i && cs_i)
                r_next_state = RA;
            else 
                r_next_state = IDLE;
        end        
        RA: begin
            if (arvalid_o && arready_i)
                r_next_state = R;
            else 
                r_next_state = RA;    
        end
        R: begin
            if (rvalid_i && rready_o && rlast_i)
                r_next_state = IDLE;
            else 
                r_next_state = R;
        end
        endcase
    end    
    
    always_ff @(posedge clk_i) begin
        if (!rst_ni) begin
            w_len_cnt = 0;
        end
        else if (w_state == IDLE) begin
            w_len_cnt = 0;
        end
        else if (w_state == W) begin
            if (wvalid_o && wready_i)
                w_len_cnt = w_len_cnt - 1;
        end 
    end
    
    always_ff @(posedge clk_i) begin
        if (!rst_ni) begin
            r_len_cnt = 0;
        end
        else if (r_state == IDLE) begin
            r_len_cnt = 0;
        end
        else if (r_state == R) begin
            if (rvalid_i && rready_o)
                r_len_cnt = r_len_cnt - 1;
        end 
    end

    always_comb begin
        if ((w_len_cnt == 0) && cs_i) 
            wdata_o = wdata_i[31:0];
        else if (w_len_cnt == 3) 
            wdata_o = wdata_i[63:32];
        else if (w_len_cnt == 2) 
            wdata_o = wdata_i[95:64];
        else if (w_len_cnt == 1)
            wdata_o = wdata_i[127:96];
        else if (dma_cs_i)
            wdata_o = dma_wdata_i;
    end
    


    always_ff @(posedge clk_i) begin
        if (!rst_ni) 
            rdata_o = 0;
        else if (r_state == R) begin
            if (rvalid_i && rready_o) begin
                if (r_len_cnt == 3) 
                    rdata_o[31:0] = rdata_i;
                else if (r_len_cnt == 2) 
                    rdata_o[63:32] = rdata_i;
                else if (r_len_cnt == 1) 
                    rdata_o[95:64] = rdata_i;
                else if (r_len_cnt == 0) begin
                    rdata_o[127:96] = rdata_i;
                end
            end 
        end
    end
    
    assign handshaked_o = (r_state == R)?1:0;
    
    always_ff @(posedge clk_i) begin
        if (!rst_ni) begin
            rvalid_o = 0;
        end 
        else if (rlast_i && rvalid_i) 
            rvalid_o = 1;
        else 
            rvalid_o = 0;
    end
    

    always_ff @(posedge clk_i) begin
        if (!rst_ni) begin
            awaddr_o <= 0;
            wstrb_o <= 0;
        end else if (w_state == IDLE) begin
            if (cs_i)
                awaddr_o <= addr_i;
            else if (dma_cs_i)
                awaddr_o <= dma_addr_i;
            wstrb_o  <= 4'hf;
        end
        else begin
            awaddr_o  <= awaddr_o;
            wstrb_o   <= wstrb_o;
        end
    end


    always_ff @(posedge clk_i) begin
        if (!rst_ni) begin
            araddr_o <= 0;
        end else if (r_state == IDLE) begin
            araddr_o <= addr_i;
        end
        else begin
            araddr_o  <= araddr_o; 
        end
    end
      
    assign arid_o    = 1;
    assign arlen_o   = 3;
    assign arsize_o  = 2;
    assign arburst_o = 1;
    assign rready_o  = (r_state == R);
    assign arvalid_o = (r_state == RA);
    
    assign awid_o    = (w_state == WA && cs_i)      ? 1 :
                       (w_state == WA && dma_cs_i)  ? 0 : 0;


    assign awlen_o   = 3;
    assign awsize_o  = 2;
    assign awburst_o = 1;
    assign awvalid_o = (w_state == WA);
    
    assign wlast_o  = ((w_state == W) && (w_len_cnt == 1));
    assign wvalid_o = (w_state == W);
    assign bready_o = (w_state == B);
                 
        
endmodule
