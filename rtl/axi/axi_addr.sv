
module axi_addr(
    input logic [`ADDR_WIDTH-1:0] i_last_addr,
    input logic [`SIZE_BITS-1 :0] i_size,
    input logic [`LEN_BITS-1:0] i_len,
    input logic [1:0] i_burst,
    output logic [`ADDR_WIDTH-1:0] o_next_addr
    );
    
    logic [`ADDR_WIDTH-1:0] increment;
    
    always_comb begin
        increment = 0;
        if (i_burst != 0) begin
            case (i_size)
            0: increment = 1;
            1: increment = 2;
            2: increment = 4;
            3: increment = 8;
            4: increment = 16;
            5: increment = 32;
            6: increment = 64;
            7: increment = 128;
            default: increment = 0;
            endcase
        end 
        o_next_addr = i_last_addr + increment;
    end
    
    
endmodule
