module axi_arbiter_ar (
	input           clk_i,
	input      	    rst_ni,
    input           m0_ARVALID,
    input           m1_ARVALID,
    input           arready,
    output  logic   m0_rgrnt,
	output 	logic   m1_rgrnt
);

    enum logic [0:0] {
    AXI_MASTER_0,  
    AXI_MASTER_1  
} state,next_state;
//------------------------------------------------------
always_comb begin
    case (state)
        AXI_MASTER_0: begin                 
            if(m0_ARVALID)                  
                next_state = AXI_MASTER_0;  
            else if (m1_ARVALID && arready && m0_ARVALID)             
                next_state = AXI_MASTER_1;  
            else if (m1_ARVALID)
                next_state = AXI_MASTER_1;
            else                            
                next_state = AXI_MASTER_0;  
        end
        AXI_MASTER_1: begin                 
            if(m1_ARVALID)                  
                next_state = AXI_MASTER_1;
            else if(m0_ARVALID && arready && m1_ARVALID)
                next_state = AXI_MASTER_0;
            else if (m0_ARVALID)
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
        AXI_MASTER_0: {m0_rgrnt,m1_rgrnt} = 2'b10;
        AXI_MASTER_1: {m0_rgrnt,m1_rgrnt} = 2'b01;
        default:      {m0_rgrnt,m1_rgrnt} = 2'b00;
    endcase
end

endmodule