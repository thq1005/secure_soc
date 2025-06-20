`include "../define.sv"
module axi_master_mux_r (
    /********************/
    input                    m0_RREADY,
    input                    m1_RREADY,
    input                    m2_RREADY,
    output  logic            m0_RVALID,
    output  logic            m1_RVALID,
    output  logic            m2_RVALID,

    input  [7:0]             rid,
    input                    rvalid,
    output  logic            rready
);

    always_comb begin
        case(rid)    
            8'h00: begin
                m0_RVALID = rvalid;
                m1_RVALID = 1'b0;
                m2_RVALID = 1'b0;
            end
            8'h01: begin
                m0_RVALID = 1'b0;
                m1_RVALID = rvalid;
                m2_RVALID = 1'b0;
            end
            8'h02: begin
                m0_RVALID = 1'b0;
                m1_RVALID = 1'b0;
                m2_RVALID = rvalid;
            end
            default: begin
                m0_RVALID = 1'b0;
                m1_RVALID = 1'b0;
                m2_RVALID = 1'b0;
            end
        endcase
    end

    always_comb begin
        case(rid)    
            8'h00: begin
                rready = m0_RREADY;
            end
            8'h01: begin
                rready = m1_RREADY;
            end
            8'h02: begin
                rready = m2_RREADY;
            end
            default: begin
                rready = 0;
            end
        endcase
    end
endmodule