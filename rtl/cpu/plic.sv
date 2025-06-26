module plic #(
    parameter NUM_IRQ = 3 
) (
    input  logic        clk_i,
    input  logic        rst_ni,
    input  logic        aes_interrupt,
    input  logic        dma_interrupt,
    output logic        irq_out,

    input  logic [31:0] addr,
    input  logic        wr_en,
    input  logic        rd_en,
    input  logic [31:0] wr_data,
    output logic [31:0] rd_data
);

    logic [31:0] priority_r [0:NUM_IRQ];       
    logic [31:0] pending;         
    logic [31:0] enable;          
    logic [31:0] threshold;                    
    logic [31:0] claim_complete;               

    always_ff @(posedge clk_i) begin
        if (!rst_ni) begin
            pending[1] <= 0;  
            pending[2] <= 0;  
            pending[3] <= 0;
        end else begin
            pending[1] <= aes_interrupt; 
            pending[2] <= dma_interrupt; 
        end
    end

    logic [31:0] max_priority;
    logic [3:0]  max_irq;
    always_comb begin
        max_priority = 0;
        max_irq = 0;
        for (int i = 1; i <= NUM_IRQ; i++) begin
            if (pending[i] && enable[i] && priority_r[i] > max_priority && priority_r[i] > threshold) begin
                max_priority = priority_r[i];
                max_irq = i;
            end
        end
        irq_out = (max_priority > 0);
    end

    always_ff @(posedge clk_i) begin
        if (!rst_ni) begin
            for (int i = 0; i <= NUM_IRQ; i++) begin
                priority_r[i] <= 0;
            end
            enable <= 0;
            threshold <= 0;
            claim_complete <= 0;
            rd_data <= 0;
        end else begin
            if (rd_en) begin
                case (addr)
                    `ADDR_PRIORITY1     : rd_data <= priority_r[1]; 
                    `ADDR_PRIORITY2     : rd_data <= priority_r[2]; 
                    `ADDR_PRIORITY3     : rd_data <= priority_r[3];
                    `ADDR_ENABLE        : rd_data <= enable; 
                    `ADDR_THRESHOLD     : rd_data <= threshold; 
                    `ADDR_CLAIM_COMPLETE: begin
                        rd_data <= max_irq;         
                    end
                    default: rd_data <= 0;
                endcase
            end
            if (wr_en) begin
                case (addr)
                    `ADDR_PRIORITY1     : priority_r[1] <= wr_data;  
                    `ADDR_PRIORITY2     : priority_r[2] <= wr_data;  
                    `ADDR_PRIORITY3     : priority_r[3] <= wr_data;
                    `ADDR_ENABLE        : enable      <= wr_data; 
                    `ADDR_THRESHOLD     : threshold   <= wr_data; 
                    `ADDR_CLAIM_COMPLETE: claim_complete <= wr_data; 
                    default: ;
                endcase
            end
        end
    end

endmodule
