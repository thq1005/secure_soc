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
    output logic [511:0] data_o, 
    input write_rq,
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
    output logic                m_rready,
    output logic [1:0]          r_nstate
);

    localparam IDLE = 2'd0, RA = 2'd1, R = 2'd2;
    logic [1:0] r_state, r_next_state;

    logic [`ADDR_WIDTH-1:0] araddr_r;
    logic [`LEN_BITS-1:0]   arlen_r;
    logic [`SIZE_BITS-1:0]  arsize_r;
    logic [1:0]             arburst_r;

    logic [31:0] rdata_r [0:15];
    logic [3:0]  rdata_cnt;

    always_ff @(posedge clk_i) begin
        if (!rst_ni) begin
            araddr_r <= '0;
            arlen_r  <= '0;
            arsize_r <= '0;
            arburst_r <= '0;
        end else if (write_rq) begin
            araddr_r <= src_addr_i;
            arlen_r  <= len_i;
            arsize_r <= size_i;
            arburst_r <= burst_i;
        end else begin
            araddr_r <= araddr_r;
            arlen_r  <= arlen_r;
            arsize_r <= arsize_r;
            arburst_r <= arburst_r;
        end
    end

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
             

    assign m_araddr = araddr_r;
    
    always_ff @(posedge clk_i) begin
        if (!rst_ni) begin
            rdata_cnt <= 0;
        end
        else if (r_state == RA) begin
            rdata_cnt <= 0;
        end
        else if (r_state == R) begin
            if (m_rvalid && m_rready)
                rdata_cnt <= rdata_cnt + 1;
        end
    end

    always_ff @(posedge clk_i) begin
        if (!rst_ni) 
            for (int i = 0; i < 16; i++) begin
            rdata_r[i] <= '0; 
        end
        else if (r_state == R) begin
            if (m_rvalid && m_rready) begin
                rdata_r[rdata_cnt] <= m_rdata;
            end
        end
    end

    always_ff @(posedge clk_i) begin
        if (!rst_ni) 
            rdata_valid_o <= 0;
        else if (r_state == R) begin
            if (m_rvalid && m_rready && m_rlast) begin
                rdata_valid_o <= 1;
            end
        end
        else 
            rdata_valid_o <= 0;
    end

    assign m_arid    = (araddr_r[19:16] == 4'h0) ? `ID_DMA2MEM:
                       (araddr_r[19:16] == 4'h2) ? `ID_DMA2AES: 0;
    assign m_arlen   = arlen_r;
    assign m_arsize  = arsize_r;
    assign m_arburst = arburst_r;
    assign m_rready  = (r_state == R);
    assign m_arvalid = (r_state == RA);
    assign data_o    = {rdata_r[15], rdata_r[14], rdata_r[13], rdata_r[12], rdata_r[11], rdata_r[10], rdata_r[9], rdata_r[8], rdata_r[7], rdata_r[6], rdata_r[5], rdata_r[4], rdata_r[3], rdata_r[2], rdata_r[1], rdata_r[0]};
    assign r_nstate = r_next_state;
endmodule

    