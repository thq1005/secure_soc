`include "../define.sv"
module register_block (
    input  logic        clk,
    input  logic        rst_n,

    // Giao tiếp với host
    input  logic [31:0] waddr,
    input  logic [31:0] raddr,
    input  logic        we,
    input  logic        re,
    input  logic [31:0] wdata,
    output logic [31:0] rdata,
    output logic        interrupt,

    // Giao tiếp với cmd_path_ctrl
    output logic        cmd_start,
    output logic [5:0]  cmd_index,
    output logic [31:0] cmd_arg,
    output logic [1:0]  response_type,
    output logic        cmd_index_check_en,
    output logic        cmd_crc_check_en,
    input  logic        cmd_busy,
    input  logic        cmd_done,
    input  logic        resp_ready,
    input  logic        timeout_err_cmd,
    input  logic        crc_err_cmd,
    input  logic [47:0] resp_data,

    // Giao tiếp với data_path_ctrl
    output logic        data_direction,
    output logic [11:0] block_size,
    output logic        buffer_access,
    input  logic        data_busy,
    input  logic        data_done,
    input  logic        timeout_err_data,
    input  logic        crc_err_data,

    // Giao tiếp với RX FIFO
    input  logic [31:0] rx_data,
    output logic        rx_rd_en,
    input  logic        rx_empty,
    input  logic        rx_full,

    // Giao tiếp với TX FIFO
    output logic [31:0] tx_data,
    output logic        tx_wr_en,
    input  logic        tx_full,
    input  logic        tx_empty,

    // Giao tiếp với clock_divider
    output logic [7:0]  clk_div
);

    // Thanh ghi nội bộ
    logic [5:0]  cmd_index_reg;
    logic [31:0] cmd_arg_reg;
    logic [11:0] block_size_reg;
    logic        data_direction_reg;
    logic        cmd_start_reg;
    logic [1:0]  response_type_reg;
    logic        cmd_index_check_en_reg;
    logic        cmd_crc_check_en_reg;
    logic [7:0]  clk_div_reg;
    logic [31:0] buffer_rdata_reg;
    logic [47:0] resp_data_reg; // Thanh ghi lưu resp_data
    logic        interrupt_reg;

    // Định nghĩa địa chỉ thanh ghi
    

    // Gán tín hiệu đầu ra
    assign cmd_index = cmd_index_reg;
    assign cmd_arg = cmd_arg_reg;
    assign block_size = block_size_reg;
    assign data_direction = data_direction_reg;
    assign cmd_start = cmd_start_reg;
    assign response_type = response_type_reg;
    assign cmd_index_check_en = cmd_index_check_en_reg;
    assign cmd_crc_check_en = cmd_crc_check_en_reg;
    assign clk_div = clk_div_reg;
    assign interrupt = interrupt_reg;
    assign buffer_access = 1'b0;
    assign tx_data = (tx_wr_en) ? wdata : 32'h0;
    assign tx_wr_en = (we && waddr == ADDR_TX_DATA && !tx_full);

    // Logic đọc từ RX FIFO
    always_comb begin
        rx_rd_en = 1'b0;
        if (re && raddr == ADDR_BUFFER && !rx_empty) begin
            rx_rd_en = 1'b1;
        end
    end

    // Logic ngắt
    always_comb begin
        interrupt_reg = 1'b0;
        if (cmd_done || data_done) begin
            interrupt_reg = 1'b1;
        end
    end

    // Logic đọc dữ liệu từ host
    always_comb begin
        rdata = 32'h0;
        if (re) begin
            case (raddr)
                `ADDR_CMD_INDEX:    rdata = {26'b0, cmd_index_reg};
                `ADDR_CMD_ARG:      rdata = cmd_arg_reg;
                `ADDR_BLOCK_CONFIG: rdata = {19'b0, data_direction_reg, block_size_reg};
                `ADDR_CONTROL:      rdata = {31'b0, cmd_start_reg};
                `ADDR_STATUS:       rdata = {24'b0, crc_err_cmd, timeout_err_cmd, resp_ready, tx_full, rx_empty, data_done, cmd_done};
                `ADDR_BUFFER:       rdata = buffer_rdata_reg;
                `ADDR_CLK_DIV:      rdata = {24'b0, clk_div_reg};
                `ADDR_RESP_DATA_LO: rdata = resp_data_reg[47:16]; // 32 bit thấp
                `ADDR_RESP_DATA_HI: rdata = {16'b0, resp_data_reg[15:0]}; // 16 bit cao
                default:           rdata = 32'h0;
            endcase
        end
    end

    // Logic ghi dữ liệu từ host
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cmd_index_reg <= 6'd0;
            cmd_arg_reg <= 32'd0;
            block_size_reg <= 12'd512;
            data_direction_reg <= 1'b0;
            cmd_start_reg <= 1'b0;
            response_type_reg <= 2'b01;
            cmd_index_check_en_reg <= 1'b1;
            cmd_crc_check_en_reg <= 1'b1;
            clk_div_reg <= 8'd2;
            interrupt_reg <= 1'b0;
            buffer_rdata_reg <= 32'd0;
            resp_data_reg <= 48'd0;
        end else begin
            // Xử lý yêu cầu ghi từ host
            if (we) begin
                case (waddr)
                    ADDR_CMD_INDEX:    cmd_index_reg <= wdata[5:0];
                    ADDR_CMD_ARG:      cmd_arg_reg <= wdata;
                    ADDR_BLOCK_CONFIG: begin
                        block_size_reg <= wdata[11:0];
                        data_direction_reg <= wdata[12];
                    end
                    ADDR_CONTROL:      cmd_start_reg <= wdata[0];
                    ADDR_CLK_DIV:      clk_div_reg <= wdata[7:0];
                endcase
            end

            // Đọc dữ liệu từ RX FIFO khi host yêu cầu
            if (re && raddr == ADDR_BUFFER && !rx_empty && rx_rd_en) begin
                buffer_rdata_reg <= rx_data;
            end

            // Lưu resp_data khi nhận được phản hồi
            if (resp_ready && cmd_done) begin
                resp_data_reg <= resp_data;
            end

            // Reset cmd_start sau khi cmd_path_ctrl xử lý xong
            if (cmd_done) begin
                cmd_start_reg <= 1'b0;
            end
        end
    end

endmodule