`include "../define.sv"
module axi_master_mux_b (
    /********************/
    input                    m0_BREADY,
    input                    m1_BREADY,
    output                   m0_BVALID,
    output                   m1_BVALID,

    input  [7:0]             bid,
    input                    bvalid,
    output                   bready

);

    always_comb begin
        case(bid)    
            8'h01: begin
                m0_BVALID = bvalid;
                m1_BVALID = 1'b0;
            end
            8'h02: begin
                m0_BVALID = 1'b0;
                m1_BVALID = bvalid;
            end
            default: begin
                m0_BVALID = 1'b0;
                m1_BVALID = 1'b0;
            end
        endcase
    end

    always_comb begin
        case(bid)    
            8'h01: begin
                bready = m0_BREADY;
            end
            8'h02: begin
                bready = m1_BREADY;
            end
            default: begin
                bready = 0;
            end
        endcase
    end
endmodule