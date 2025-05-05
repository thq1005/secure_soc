module crc7_gen (
    input  logic [39:0] data_in,   // 40-bit: CMD index + ARG
    output logic [6:0]  crc_out    // CRC7 result
);

    logic [6:0] crc;
    integer i;

    always_comb begin
        crc = 7'b0000000;

        for (i = 39; i >= 0; i = i - 1) begin
            logic din = data_in[i];
            logic msb = crc[6];

            crc = {crc[5:0], din};      // shift left
            if (msb ^ din)
                crc = crc ^ 7'h89;      // XOR với đa thức nếu cần
        end

        crc_out = crc;
    end

endmodule
