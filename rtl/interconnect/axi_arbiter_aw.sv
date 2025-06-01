module axi_arbiter_aw (
	input           clk_i,
	input      	    rst_ni,
    input           m0_AWVALID,
    input           m1_AWVALID,
    input           m2_AWVALID,
    output  logic   m2_wgrnt,

    input           awready,
    output  logic   m0_wgrnt,
	output 	logic   m1_wgrnt
);

    enum logic [1:0] {
        AXI_MASTER_0,  
        AXI_MASTER_1,
        AXI_MASTER_2
    } state,next_state;
//------------------------------------------------------
    always_comb begin
        case (state)
            AXI_MASTER_0: begin                 
                if(m0_AWVALID)                  
                    next_state = AXI_MASTER_0;  
                else if (m1_AWVALID && awready && m0_AWVALID)             
                    next_state = AXI_MASTER_1;  
                else if (m2_AWVALID && awready && m0_AWVALID)
                    next_state = AXI_MASTER_2;
                else if (m1_AWVALID)
                    next_state = AXI_MASTER_1;
                else if (m2_AWVALID)
                    next_state = AXI_MASTER_2;
                else                            
                    next_state = AXI_MASTER_0;  
            end
            AXI_MASTER_1: begin                 
                if(m1_AWVALID)                  
                    next_state = AXI_MASTER_1;
                else if (m0_AWVALID && awready && m1_AWVALID)
                    next_state = AXI_MASTER_0;
                else if (m2_AWVALID && awready && m0_AWVALID)
                    next_state = AXI_MASTER_2;
                else if (m0_AWVALID)
                    next_state = AXI_MASTER_0;
                else if (m2_AWVALID)
                    next_state = AXI_MASTER_2;
                else
                    next_state = AXI_MASTER_1;
            end
            AXI_MASTER_2: begin                 
                if(m2_AWVALID)                  
                    next_state = AXI_MASTER_2;
                else if (m0_AWVALID && awready && m2_AWVALID)
                    next_state = AXI_MASTER_0;
                else if (m1_AWVALID && awready && m2_AWVALID)
                    next_state = AXI_MASTER_1;
                else if (m0_AWVALID)
                    next_state = AXI_MASTER_0;
                else if (m1_AWVALID)
                    next_state = AXI_MASTER_1;
                else
                    next_state = AXI_MASTER_2;
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
            AXI_MASTER_0: {m0_wgrnt,m1_wgrnt,m2_wgrnt} = 3'b100;
            AXI_MASTER_1: {m0_wgrnt,m1_wgrnt,m2_wgrnt} = 3'b010;
            AXI_MASTER_2: {m0_wgrnt,m1_wgrnt,m2_wgrnt} = 3'b001;
            default:      {m0_wgrnt,m1_wgrnt,m2_wgrnt} = 3'b000;
        endcase
    end

endmodule