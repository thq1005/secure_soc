`include "../define.sv"
module axi_slave_mux_r (
    input                    clk_i,
    input                    rst_ni,
    /********************/
    input                    s0_RVALID,
    input                    s1_RVALID,
    input                    s3_RVALID,
    input                    s4_RVALID,
    input   [7:0]            s0_RID,
    input   [7:0]            s1_RID,
    input   [7:0]            s3_RID,
    input   [7:0]            s4_RID,
    input   [`DATA_WIDTH - 1:0] s0_RDATA,
    input   [`DATA_WIDTH - 1:0] s1_RDATA,
    input   [`DATA_WIDTH - 1:0] s3_RDATA,
    input   [`DATA_WIDTH - 1:0] s4_RDATA,
    input   [1:0]            s0_RRESP,
    input   [1:0]            s1_RRESP,
    input   [1:0]            s3_RRESP,
    input   [1:0]            s4_RRESP,
    input                    s0_RLAST,
    input                    s1_RLAST,  
    input                    s3_RLAST,
    input                    s4_RLAST,

    input                    rready,

    output logic [7:0]            rid,
    output logic                  rvalid,
    output logic                  rlast,
    output logic [`DATA_WIDTH - 1:0] rdata,
    output logic [1:0]            rresp,
    output logic                  s0_RREADY,
    output logic                  s1_RREADY,
    output logic                  s3_RREADY,
    output logic                  s4_RREADY
);

    enum logic [0:1] {
        AXI_MASTER_0,  
        AXI_MASTER_1,
        AXI_MASTER_3,
        AXI_MASTER_4  
    } state,next_state;
//------------------------------------------------------
    always_comb begin
        case (state)
            AXI_MASTER_0: begin                 
                if(s0_RVALID)                  
                    next_state = AXI_MASTER_0;  
                else if (s1_RVALID && rready && s0_RVALID)             
                    next_state = AXI_MASTER_1;  
                else if (s3_RVALID && rready && s0_RVALID)             
                    next_state = AXI_MASTER_3;
                else if (s4_RVALID && rready && s0_RVALID)
                    next_state = AXI_MASTER_4;
                else if (s1_RVALID)
                    next_state = AXI_MASTER_1;
                else if (s3_RVALID)
                    next_state = AXI_MASTER_3;
                else if (s4_RVALID)
                    next_state = AXI_MASTER_4;
                else                            
                    next_state = AXI_MASTER_0;
            end
            AXI_MASTER_1: begin                 
                if(s1_RVALID)                  
                    next_state = AXI_MASTER_1;
                else if(s0_RVALID && rready && s1_RVALID)
                    next_state = AXI_MASTER_0;
                else if (s3_RVALID && rready && s1_RVALID)
                    next_state = AXI_MASTER_3;
                else if (s4_RVALID && rready && s1_RVALID)
                    next_state = AXI_MASTER_4;
                else if (s0_RVALID)
                    next_state = AXI_MASTER_0;
                else if (s3_RVALID)
                    next_state = AXI_MASTER_3;
                else if (s4_RVALID)
                    next_state = AXI_MASTER_4;
                else
                    next_state = AXI_MASTER_1;
            end
            AXI_MASTER_3: begin                 
                if(s3_RVALID)                  
                    next_state = AXI_MASTER_3;
                else if(s0_RVALID && rready && s3_RVALID)
                    next_state = AXI_MASTER_0;
                else if (s1_RVALID && rready && s3_RVALID)
                    next_state = AXI_MASTER_1;
                else if (s4_RVALID && rready && s3_RVALID)
                    next_state = AXI_MASTER_4;
                else if (s0_RVALID)
                    next_state = AXI_MASTER_0;
                else if (s1_RVALID)
                    next_state = AXI_MASTER_1;
                else if (s4_RVALID)
                    next_state = AXI_MASTER_4;
                else
                    next_state = AXI_MASTER_3;
            end
            default:
                next_state = AXI_MASTER_0;      
        endcase
    end
    //------------------------------------------------------
    always_ff@(posedge clk_i)begin
        if(!rst_ni)
            state <= AXI_MASTER_0;         
        else
            state <= next_state;
    end
    always_comb begin
        case (state)
            AXI_MASTER_0: begin
                s0_RREADY = rready;
                s1_RREADY = '0;
                s3_RREADY = '0;
                s4_RREADY = '0;
            end
            AXI_MASTER_1: begin
                s0_RREADY = '0;
                s1_RREADY = rready;
                s3_RREADY = '0;
                s4_RREADY = '0;
            end
            AXI_MASTER_3: begin
                s0_RREADY = '0;
                s1_RREADY = '0;
                s3_RREADY = rready;
                s4_RREADY = '0;
            end
            AXI_MASTER_4: begin
                s0_RREADY = '0;
                s1_RREADY = '0;
                s3_RREADY = '0;
                s4_RREADY = rready;
            end
            default: begin
                s0_RREADY = '0;
                s1_RREADY = '0;
                s3_RREADY = '0;
                s4_RREADY = '0;
            end
        endcase
    end

    assign rid = (state == AXI_MASTER_0) ? s0_RID :
                 (state == AXI_MASTER_1) ? s1_RID :
                 (state == AXI_MASTER_3) ? s3_RID : 
                 (state == AXI_MASTER_4) ? s4_RID : 8'b0;

    assign rvalid = (state == AXI_MASTER_0) ? s0_RVALID :
                    (state == AXI_MASTER_1) ? s1_RVALID :
                    (state == AXI_MASTER_3) ? s3_RVALID :
                    (state == AXI_MASTER_4) ? s4_RVALID : 1'b0;

    assign rresp  = (state == AXI_MASTER_0) ? s0_RRESP :
                    (state == AXI_MASTER_1) ? s1_RRESP :
                    (state == AXI_MASTER_3) ? s3_RRESP :
                    (state == AXI_MASTER_4) ? s4_RRESP : 2'b0;

    assign rdata  = (state == AXI_MASTER_0) ? s0_RDATA :
                    (state == AXI_MASTER_1) ? s1_RDATA :
                    (state == AXI_MASTER_3) ? s3_RDATA :
                    (state == AXI_MASTER_4) ? s4_RDATA : 0; 

    assign rlast  = (state == AXI_MASTER_0) ? s0_RLAST :
                    (state == AXI_MASTER_1) ? s1_RLAST :
                    (state == AXI_MASTER_3) ? s3_RLAST :
                    (state == AXI_MASTER_4) ? s4_RLAST : 1'b0; 

endmodule