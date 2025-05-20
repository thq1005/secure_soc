module axi_arbiter_aw (
	input           clk_i,
	input      	    rst_ni,
    input           m0_AWVALID,
    input           m1_AWVALID,
    input           awready,
    output  logic   m0_wgrnt,
	output 	logic   m1_wgrnt
);

    enum logic [0:0] {
        AXI_MASTER_0,  
        AXI_MASTER_1  
    } state,next_state;
//------------------------------------------------------
    always_comb begin
        case (state)
            AXI_MASTER_0: begin                 
                if(m0_AWVALID)                  
                    next_state = AXI_MASTER_0;  
                else if (m1_AWVALID && awready && m0_AWVALID)             
                    next_state = AXI_MASTER_1;  
                else if (m1_AWVALID)
                    next_state = AXI_MASTER_1;
                else                            
                    next_state = AXI_MASTER_0;  
            end
            AXI_MASTER_1: begin                 
                if(m1_AWVALID)                  
                    next_state = AXI_MASTER_1;
                else if(m0_AWVALID && awready && m1_AWVALID)
                    next_state = AXI_MASTER_0;
                else if (m0_AWVALID)
                    next_state = AXI_MASTER_0;
                else
                    next_state = AXI_MASTER_1;
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
            AXI_MASTER_0: {m0_wgrnt,m1_wgrnt} = 2'b10;
            AXI_MASTER_1: {m0_wgrnt,m1_wgrnt} = 2'b01;
            default:      {m0_wgrnt,m1_wgrnt} = 2'b00;
        endcase
    end

endmodule