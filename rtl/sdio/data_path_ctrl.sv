module data_path_ctrl (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        sdclk_i,
    input  logic        cmd_done,
    input  logic        resp_ready,
    input  logic        crc_err_cmd,
    input  logic        timeout_err_cmd,
    input  logic        data_direction,
    input  logic [11:0] block_size,
    input  logic        buffer_access,
    input  logic [31:0] tx_data,
    output logic        tx_rd_en,
    input  logic        tx_empty,
    output logic [31:0] rx_data,
    output logic        rx_wr_en,
    input  logic        rx_full,
    input  logic [3:0]  dat_i,
    output logic [3:0]  dat_o,
    output logic [3:0]  dat_t,
    output logic        data_busy,
    output logic        data_done,
    output logic        timeout_err_data,
    output logic        crc_err_data
);

    // FSM trạng thái
    typedef enum logic [2:0] {
        IDLE,
        WAIT_DATA,
        READ_DATA,
        CHECK_CRC,
        WRITE_DATA,
        SEND_CRC,
        DONE,
        ERROR
    } state_t;
    state_t state, next_state;

    // Tín hiệu nội bộ
    logic [31:0] data_buffer;
    logic [2:0]  bit_count;
    logic [9:0]  byte_count;
    logic [15:0] crc_received;
    logic [15:0] crc_calculated;
    logic [6:0]  crc7_calculated;
    logic [15:0] crc_shift_reg [3:0];
    logic [6:0]  crc7_shift_reg;
    logic [11:0] timeout_counter;
    logic        start_bit_detected;
    logic        data_bit;

    // Gán tín hiệu đầu ra
    assign rx_wr_en = (state == READ_DATA && bit_count == 3'd7 && !rx_full);
    assign tx_rd_en = (state == WRITE_DATA && !tx_empty);
    assign rx_data = data_buffer;
    assign dat_t = (data_direction) ? 4'hF : 4'h0;

    // Logic tính CRC16 (cho đọc)
    always_comb begin
        if (data_direction) begin
            for (int i = 0; i < 4; i++) begin
                crc_shift_reg[i] = {crc_shift_reg[i][14:0], dat_i[i]} ^ (crc_shift_reg[i][15] ? 16'h1021 : 16'h0000);
            end
        end
    end

    // Logic tính CRC7 (cho ghi)
    always_comb begin
        if (!data_direction) begin
            crc7_shift_reg = {crc7_shift_reg[5:0], data_bit} ^ (crc7_shift_reg[6] ? 7'h89 : 7'h00);
        end
    end

    // Logic FSM
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            data_busy <= 1'b0;
            data_done <= 1'b0;
            timeout_err_data <= 1'b0;
            crc_err_data <= 1'b0;
            data_buffer <= 32'd0;
            bit_count <= 3'd0;
            byte_count <= 10'd0;
            crc_received <= 16'd0;
            crc_calculated <= 16'd0;
            crc7_calculated <= 7'd0;
            timeout_counter <= 12'd0;
            start_bit_detected <= 1'b0;
            dat_o <= 4'b0;
            for (int i = 0; i < 4; i++) begin
                crc_shift_reg[i] <= 16'd0;
            end
            crc7_shift_reg <= 7'd0;
        end else begin
            state <= next_state;

            case (state)
                IDLE: begin
                    data_busy <= 1'b0;
                    data_done <= 1'b0;
                    timeout_err_data <= 1'b0;
                    crc_err_data <= 1'b0;
                    byte_count <= 10'd0;
                    bit_count <= 3'd0;
                    crc_received <= 16'd0;
                    crc_calculated <= 16'd0;
                    crc7_calculated <= 7'd0;
                    for (int i = 0; i < 4; i++) begin
                        crc_shift_reg[i] <= 16'd0;
                    end
                    crc7_shift_reg <= 7'd0;
                end

                WAIT_DATA: begin
                    data_busy <= 1'b1;
                    if (dat_i[0] == 1'b0 && data_direction) begin
                        start_bit_detected <= 1'b1;
                    end
                    if (start_bit_detected || !data_direction) begin
                        timeout_counter <= 12'd0;
                    end else begin
                        timeout_counter <= timeout_counter + 1;
                        if (timeout_counter == 12'd4095) begin
                            timeout_err_data <= 1'b1;
                        end
                    end
                end

                READ_DATA: begin
                    if (data_direction && !rx_full) begin
                        data_buffer <= {data_buffer[27:0], dat_i};
                        bit_count <= bit_count + 1;
                        for (int i = 0; i < 4; i++) begin
                            crc_shift_reg[i] <= {crc_shift_reg[i][14:0], dat_i[i]} ^ (crc_shift_reg[i][15] ? 16'h1021 : 16'h0000);
                        end
                        if (bit_count == 3'd7) begin
                            bit_count <= 3'd0;
                            byte_count <= byte_count + 4;
                        end
                    end
                end

                CHECK_CRC: begin
                    if (data_direction) begin
                        if (byte_count < 10'd514) begin
                            crc_received <= {crc_received[11:0], dat_i};
                            byte_count <= byte_count + 1;
                        end
                        crc_calculated <= crc_shift_reg[0];
                        if (crc_received != crc_calculated) begin
                            crc_err_data <= 1'b1;
                        end
                    end
                end

                WRITE_DATA: begin
                    if (!data_direction && !tx_empty) begin
                        data_buffer <= tx_data;
                        dat_o <= tx_data[31:28];
                        data_bit <= tx_data[31];
                        bit_count <= bit_count + 1;
                        if (bit_count == 3'd7) begin
                            data_buffer <= {data_buffer[27:0], 4'b0};
                            bit_count <= 3'd0;
                            byte_count <= byte_count + 4;
                        end
                    end
                end

                SEND_CRC: begin
                    if (!data_direction) begin
                        dat_o <= crc7_calculated[6:3];
                        crc7_calculated <= crc7_shift_reg;
                        if (byte_count == 10'd514) begin
                            byte_count <= byte_count + 1;
                        end
                    end
                end

                DONE: begin
                    data_done <= 1'b1;
                    data_busy <= 1'b0;
                end

                ERROR: begin
                    data_busy <= 1'b0;
                end
            endcase
        end
    end

    // Logic chuyển trạng thái
    always_comb begin
        next_state = state;
        case (state)
            IDLE: begin
                if (cmd_done && resp_ready && !crc_err_cmd && !timeout_err_cmd) begin
                    if (data_direction) begin
                        next_state = WAIT_DATA;
                    end else begin
                        next_state = WRITE_DATA;
                    end
                end
            end
            WAIT_DATA: begin
                if (start_bit_detected) begin
                    next_state = READ_DATA;
                end else if (timeout_err_data) begin
                    next_state = ERROR;
                end
            end
            READ_DATA: begin
                if (byte_count >= 10'd512) begin
                    next_state = CHECK_CRC;
                end else if (rx_full) begin
                    next_state = READ_DATA;
                end
            end
            CHECK_CRC: begin
                if (byte_count >= 10'd514) begin
                    if (crc_err_data) begin
                        next_state = ERROR;
                    end else begin
                        next_state = DONE;
                    end
                end
            end
            WRITE_DATA: begin
                if (byte_count >= 10'd512) begin
                    next_state = SEND_CRC;
                end else if (tx_empty) begin
                    next_state = WRITE_DATA;
                end
            end
            SEND_CRC: begin
                if (byte_count >= 10'd514) begin
                    next_state = DONE;
                end
            end
            DONE: begin
                if (!cmd_done) begin
                    next_state = IDLE;
                end
            end
            ERROR: begin
                if (!cmd_done) begin
                    next_state = IDLE;
                end
            end
        endcase
    end

endmodule