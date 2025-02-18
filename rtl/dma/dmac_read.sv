`include "../define.sv"

module dmac_read (
    input clk_i,
    input rst_ni,
    input valid_i,
    input [`ADDR_WIDTH-1:0] src_addr_i,
    input [`LEN_BITS-1:0]   len_i,
    input [`SIZE_BITS-1:0]  size_i,
    input [1:0]             burst_i,
    output logic rdata_valid_o,
    output logic [`DATA_WIDTH-1:0] data_o, 
    //AR channel
    output logic [`ID_BITS - 1:0]       m_arid,
    output logic [`ADDR_WIDTH - 1:0]    m_araddr,
    output logic [`LEN_BITS - 1:0]      m_arlen,
    output logic [1:0]                  m_arburst,
    output logic [`SIZE_BITS - 1:0]     m_arsize,
    output logic                        m_arvalid,
    input                               m_arready,
    //R channel
    input [`ID_BITS - 1:0]      m_rid,
    input [`DATA_WIDTH - 1:0]   m_rdata,
    input [2:0]                 m_rresp,
    input                       m_rvalid,
    input                       m_rlast,
    output logic                m_rready
);

    localparam IDLE = 2'd0, RA = 2'd1, R = 2'd2;
    logic [3:0] r_state, r_next_state;

        
    always_ff @(posedge clk_i) begin
        if(~rst_ni) 
            r_state <= 0;
        else
            r_state <= r_next_state; 
    end         

    always_comb begin
        case (r_state)
        IDLE: begin
            if (valid_i)
                r_next_state = RA;
            else 
                r_next_state = IDLE;
        end        
        RA: begin
            if (m_arvalid && m_arready)
                r_next_state = R;
            else 
                r_next_state = RA;    
        end
        R: begin
            if (m_rvalid && m_rready && m_rlast)
                r_next_state = IDLE;
            else 
                r_next_state = R;
        end
        endcase
    end    
             

    always_ff @(posedge clk_i) begin
        if (!rst_ni) begin
            m_araddr <= 0;
        end else if (r_state == IDLE) begin
            m_araddr <= src_addr_i;
        end
        else begin
            m_araddr  <= m_araddr; 
        end
    end
    
    assign m_arid    = 1;
    assign m_arlen   = len_i;
    assign m_arsize  = size_i;
    assign m_arburst = burst_i;
    assign m_rready  = (r_state == R);
    assign m_arvalid = (r_state == RA);
    assign data_o    = m_rdata;
    assign rdata_valid_o = (m_rvalid & m_rready);

endmodule

    