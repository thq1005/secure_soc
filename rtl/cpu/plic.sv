// Mô-đun PLIC đơn giản
module plic #(
    parameter NUM_IRQ = 3
) (
    input  logic        clk_i,
    input  logic        rst_ni,
    // Tín hiệu ngắt từ các nguồn
    input  logic        aes_interrupt,
    input  logic        dma_interrupt,
    input  logic        sd_host_interrupt,
    // Giao tiếp với CPU
    output logic        irq_out,
    // Giao tiếp với bus (địa chỉ, dữ liệu, điều khiển)
    input  logic [31:0] addr,
    input  logic        wr_en,
    input  logic        rd_en,
    input  logic [31:0] wr_data,
    output logic [31:0] rd_data
);

    // Thanh ghi PLIC
    logic [31:0] priority [0:NUM_IRQ-1];        // Mức ưu tiên cho mỗi IRQ
    logic [31:0] pending [0:NUM_IRQ-1];         // Trạng thái pending
    logic [31:0] enable [0:NUM_IRQ-1];          // Trạng thái enable
    logic [31:0] threshold;                     // Ngưỡng ưu tiên
    logic [31:0] claim_complete;                // Claim/Complete

    // Gán tín hiệu ngắt pending
    always_ff @(posedge clk_i) begin
        if (!rst_ni) begin
            pending[0] <= 0;  // IRQ 0 (AES)
            pending[1] <= 0;  // IRQ 1 (DMA)
            pending[2] <= 0;  // IRQ 2 (SD Host Controller)
        end else begin
            pending[0] <= aes_interrupt;  // Ngắt từ AES
            pending[1] <= dma_interrupt;  // Ngắt từ DMA
            pending[2] <= sd_host_interrupt;  // Ngắt từ SD Host Controller
        end
    end

    // Logic ưu tiên và tạo tín hiệu ngắt
    logic [31:0] max_priority;
    logic [2:0]  max_irq;
    always_comb begin
        max_priority = 0;
        max_irq = 0;
        for (int i = 0; i < NUM_IRQ; i++) begin
            if (pending[i] && enable[i] && priority[i] > max_priority && priority[i] > threshold) begin
                max_priority = priority[i];
                max_irq = i;
            end
        end
        irq_out = (max_priority > 0);
    end

    // Đọc/ghi thanh ghi
    always_ff @(posedge clk_i) begin
        if (!rst_ni) begin
            for (int i = 0; i < NUM_IRQ; i++) begin
                priority[i] <= 0;
                enable[i] <= 0;
            end
            threshold <= 0;
            claim_complete <= 0;
            rd_data <= 0;
        end else begin
            if (rd_en) begin
                case (addr)
                    `ADDR_PRIORITY1     : rd_data <= priority[0];  // Priority 0 (dùng để mở rộng)
                    `ADDR_PRIORITY2     : rd_data <= priority[1];  // Priority 1
                    `ADDR_PRIORITY3     : rd_data <= priority[2];  // Priority 3 (AES)
                    `ADDR_ENABLE        : rd_data <= enable[0]; // Enable 0
                    `ADDR_THRESHOLD     : rd_data <= threshold; // Threshold
                    `ADDR_CLAIM_COMPLETE: begin
                        rd_data <= max_irq;         // Claim
                        pending[max_irq] <= 0;      // Xóa pending khi claim
                    end
                    default: rd_data <= 0;
                endcase
            end
            if (wr_en) begin
                case (addr)
                    `ADDR_PRIORITY1     : priority[0] <= wr_data;  // Priority 0 (AES)
                    `ADDR_PRIORITY2     : priority[1] <= wr_data;  // Priority 1 (DMA)
                    `ADDR_PRIORITY3     : priority[2] <= wr_data;  // Priority 3 (SDcontroller)
                    `ADDR_ENABLE        : enable[0] <= wr_data; // Enable 0
                    `ADDR_THRESHOLD     : threshold <= wr_data; // Threshold
                    `ADDR_CLAIM_COMPLETE: claim_complete <= wr_data; // Complete (không làm gì thêm ở đây)
                    default: ;
                endcase
            end
        end
    end

endmodule
