`include "../define.sv"
module axi_slave_mux_b (
    input                    clk_i,
    input                    rst_ni,
    /********************/
    input                    s0_BVALID,
    input                    s1_BVALID,
    input                    s2_BVALID,
    input                    s3_BVALID,
    input   [7:0]            s0_BID,
    input   [7:0]            s1_BID,
    input   [7:0]            s2_BID,
    input   [7:0]            s3_BID,
    input                    bready,

    output logic [7:0]       bid,
    output logic             bvalid,
    output logic             s0_BREADY,
    output logic             s1_BREADY,
    output logic             s2_BREADY,
    output logic             s3_BREADY
);

    enum logic [0:2] {
        AXI_MASTER_0,  
        AXI_MASTER_1,
        AXI_MASTER_2,
        AXI_MASTER_3
    } state,next_state;
//------------------------------------------------------
    always_comb begin
        case (state)
            AXI_MASTER_0: begin                 
                if(s0_BVALID)                  
                    next_state = AXI_MASTER_0;  
                else if (s1_BVALID && bready && s0_BVALID)             
                    next_state = AXI_MASTER_1;  
                else if (s2_BVALID && bready && s0_BVALID)             
                    next_state = AXI_MASTER_2;  
                else if (s3_BVALID && bready && s0_BVALID)             
                    next_state = AXI_MASTER_3;
                else if (s1_BVALID)
                    next_state = AXI_MASTER_1;
                else if (s2_BVALID)
                    next_state = AXI_MASTER_2;
                else if (s3_BVALID)
                    next_state = AXI_MASTER_3;
                else                            
                    next_state = AXI_MASTER_0;
            end
            AXI_MASTER_1: begin                 
                if(s1_BVALID)                  
                    next_state = AXI_MASTER_1;
                else if(s0_BVALID && bready && s1_BVALID)
                    next_state = AXI_MASTER_0;
                else if (s2_BVALID && bready && s1_BVALID)
                    next_state = AXI_MASTER_2;
                else if (s3_BVALID && bready && s1_BVALID)
                    next_state = AXI_MASTER_3;
                else if (s0_BVALID)
                    next_state = AXI_MASTER_0;
                else if (s2_BVALID)
                    next_state = AXI_MASTER_2;
                else if (s3_BVALID)
                    next_state = AXI_MASTER_3;
                else
                    next_state = AXI_MASTER_1;
            end
            AXI_MASTER_2: begin                 
                if(s2_BVALID)                  
                    next_state = AXI_MASTER_2;
                else if(s0_BVALID && bready && s2_BVALID)
                    next_state = AXI_MASTER_0;
                else if (s1_BVALID && bready && s2_BVALID)
                    next_state = AXI_MASTER_1;
                else if (s3_BVALID && bready && s2_BVALID)
                    next_state = AXI_MASTER_3;
                else if (s0_BVALID)
                    next_state = AXI_MASTER_0;
                else if (s1_BVALID)
                    next_state = AXI_MASTER_1;
                else if (s3_BVALID)
                    next_state = AXI_MASTER_3;
                else
                    next_state = AXI_MASTER_2;
            end
            AXI_MASTER_3: begin                 
                if(s3_BVALID)                  
                    next_state = AXI_MASTER_3;
                else if(s0_BVALID && bready && s3_BVALID)
                    next_state = AXI_MASTER_0;
                else if (s1_BVALID && bready && s3_BVALID)
                    next_state = AXI_MASTER_1;
                else if (s2_BVALID && bready && s3_BVALID)
                    next_state = AXI_MASTER_2;
                else if (s0_BVALID)
                    next_state = AXI_MASTER_0;
                else if (s1_BVALID)
                    next_state = AXI_MASTER_1;
                else if (s2_BVALID)
                    next_state = AXI_MASTER_2;
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
                s0_BREADY = bready;
                s1_BREADY = '0;
                s2_BREADY = '0;
                s3_BREADY = '0;
            end
            AXI_MASTER_1: begin
                s0_BREADY = '0;
                s1_BREADY = bready;
                s2_BREADY = '0;
                s3_BREADY = '0;
            end
            AXI_MASTER_2: begin
                s0_BREADY = '0;
                s1_BREADY = '0;
                s2_BREADY = bready;
                s3_BREADY = '0;
            end
            AXI_MASTER_3: begin
                s0_BREADY = '0;
                s1_BREADY = '0;
                s2_BREADY = '0;
                s3_BREADY = bready;
            end
            default: begin
                s0_BREADY = '0;
                s1_BREADY = '0;
                s2_BREADY = '0;
                s3_BREADY = '0;
            end
        endcase
    end

    assign bid = (state == AXI_MASTER_0) ? s0_BID :
                 (state == AXI_MASTER_1) ? s1_BID :
                 (state == AXI_MASTER_2) ? s2_BID :
                 (state == AXI_MASTER_3) ? s3_BID : 8'b0;

    assign bvalid = (state == AXI_MASTER_0) ? s0_BVALID :
                    (state == AXI_MASTER_1) ? s1_BVALID :
                    (state == AXI_MASTER_2) ? s2_BVALID :
                    (state == AXI_MASTER_3) ? s3_BVALID : 1'b0;
endmodule