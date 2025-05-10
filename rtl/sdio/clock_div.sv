module clock_div (
    input  logic        clk,        // Đồng hồ hệ thống (ví dụ: 50 MHz)
    input  logic        rst_n,      // Reset active-low
    input  logic [7:0]  clk_div,    // Tỷ lệ chia tần (từ register_block)
    output logic        sdclk_i     // Đồng hồ cho thẻ SD
);

    // Thanh ghi và tín hiệu nội bộ
    logic [7:0] counter;       // Bộ đếm để chia tần
    logic       sdclk_next;    // Tín hiệu trung gian để tạo sdclk_i

    // Logic chia tần
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter <= 8'd0;
            sdclk_i <= 1'b0;
        end else begin
            if (clk_div == 8'd0) begin
                // Nếu clk_div = 0, sdclk_i = clk (không chia tần)
                sdclk_i <= clk;
                counter <= 8'd0;
            end else begin
                counter <= counter + 1;
                // Chia tần: sdclk_i chuyển đổi trạng thái mỗi clk_div chu kỳ
                if (counter == clk_div - 1) begin
                    counter <= 8'd0;
                    sdclk_i <= ~sdclk_i;
                end
            end
        end
    end

endmodule