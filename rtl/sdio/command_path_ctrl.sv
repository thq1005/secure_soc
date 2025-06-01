module command_path_ctrl (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        sdclk_i,

    // Input from Register Block
    input  logic        cmd_start,
    input  logic [5:0]  cmd_index,
    input  logic [31:0] cmd_arg,
    input  logic [1:0]  response_type,
    input  logic        cmd_index_check_en,
    input  logic        cmd_crc_check_en,

    // Connect to CMD pin
    input  logic        cmd_i,
    output logic        cmd_o,
    output logic        cmd_t,

    // Response to Host
    output logic        cmd_busy,
    output logic        cmd_done,
    output logic        resp_ready,
    output logic        timeout_err,
    output logic        crc_err,
    output logic [47:0] resp_data
);

    // Trạng thái của FSM
    typedef enum logic [2:0] {
        IDLE,
        SEND_CMD,
        WAIT_RESP,
        RECV_RESP,
        CHECK_RESP,
        DONE
    } state_t;
    state_t state, next_state;

    // Các hằng số
    localparam CMD_FRAME_LEN = 48; // Độ dài khung lệnh: 1 start bit + 1 transmission bit + 6 cmd_index + 32 cmd_arg + 7 CRC + 1 end bit
    localparam RESP_TIMEOUT = 64;  // Thời gian chờ phản hồi tối đa (64 chu kỳ sdclk_i)
    localparam RESP_LEN_R1_R3_R6_R7 = 48; // Độ dài phản hồi R1, R3, R6, R7
    localparam RESP_LEN_R2 = 136;  // Độ dài phản hồi R2

    // Thanh ghi và tín hiệu nội bộ
    logic [47:0] cmd_frame;        // Khung lệnh gửi đi
    logic [6:0]  cmd_crc7;         // CRC7 của lệnh
    logic [CMD_FRAME_LEN-1:0] cmd_shift_reg; // Thanh ghi dịch để gửi lệnh
    logic [5:0]  cmd_bit_counter;  // Đếm số bit đã gửi
    logic [6:0]  resp_timeout_counter; // Đếm thời gian chờ phản hồi
    logic [RESP_LEN_R2-1:0] resp_shift_reg; // Thanh ghi dịch để nhận phản hồi
    logic [6:0]  resp_bit_counter; // Đếm số bit phản hồi đã nhận
    logic [47:0] resp_data_reg;    // Dữ liệu phản hồi lưu trữ
    logic [6:0]  resp_crc7_calc;   // CRC7 tính toán của phản hồi
    logic [6:0]  resp_crc7_rcvd;   // CRC7 nhận được từ phản hồi
    logic [5:0]  resp_index;       // Chỉ số lệnh trong phản hồi
    logic        cmd_busy_reg;
    logic        cmd_done_reg;
    logic        resp_ready_reg;
    logic        timeout_err_reg;
    logic        crc_err_reg;

    // Gán tín hiệu đầu ra
    assign cmd_busy = cmd_busy_reg;
    assign cmd_done = cmd_done_reg;
    assign resp_ready = resp_ready_reg;
    assign timeout_err = timeout_err_reg;
    assign crc_err = crc_err_reg;
    assign resp_data = resp_data_reg;
    assign cmd_o = cmd_shift_reg[CMD_FRAME_LEN-1]; // Bit cao nhất của thanh ghi dịch

    // Tính CRC7 cho lệnh
    function automatic logic [6:0] calc_crc7(input logic [39:0] data);
        logic [6:0] crc = 7'd0;
        logic [39:0] poly = 40'h120; // Đa thức CRC7: x^7 + x^3 + 1
        logic [39:0] temp = data;
        for (int i = 39; i >= 0; i--) begin
            crc = {crc[5:0], 1'b0} ^ (crc[6] ? poly[6:0] : 7'd0);
            if (temp[i]) crc[0] = crc[0] ^ 1'b1;
        end
        return crc;
    endfunction

    // Tạo khung lệnh
    always_comb begin
        cmd_frame = 48'd0;
        cmd_frame[47] = 1'b0;              // Start bit
        cmd_frame[46] = 1'b1;              // Transmission bit (1 = host gửi)
        cmd_frame[45:40] = cmd_index;      // Chỉ số lệnh
        cmd_frame[39:8] = cmd_arg;         // Đối số lệnh
        cmd_crc7 = calc_crc7(cmd_frame[47:8]); // Tính CRC7
        cmd_frame[7:1] = cmd_crc7;         // CRC7
        cmd_frame[0] = 1'b1;               // End bit
    end

    // FSM chuyển trạng thái
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    // FSM logic
    always_comb begin
        next_state = state;
        case (state)
            IDLE: begin
                if (cmd_start) begin
                    next_state = SEND_CMD;
                end
            end
            SEND_CMD: begin
                if (cmd_bit_counter == CMD_FRAME_LEN - 1) begin
                    if (response_type == 2'b00) begin // Không phản hồi
                        next_state = DONE;
                    end else begin
                        next_state = WAIT_RESP;
                    end
                end
            end
            WAIT_RESP: begin
                if (cmd_i == 1'b0 || resp_timeout_counter == RESP_TIMEOUT - 1) begin
                    next_state = RECV_RESP;
                end
            end
            RECV_RESP: begin
                if (response_type == 2'b10) begin // R2
                    if (resp_bit_counter == RESP_LEN_R2 - 1) begin
                        next_state = CHECK_RESP;
                    end
                end else begin // R1, R3, R6, R7
                    if (resp_bit_counter == RESP_LEN_R1_R3_R6_R7 - 1) begin
                        next_state = CHECK_RESP;
                    end
                end
            end
            CHECK_RESP: begin
                next_state = DONE;
            end
            DONE: begin
                next_state = IDLE;
            end
        endcase
    end

    // Logic xử lý
    always_ff @(posedge sdclk_i or negedge rst_n) begin
        if (!rst_n) begin
            cmd_shift_reg <= 48'd0;
            cmd_bit_counter <= 6'd0;
            cmd_busy_reg <= 1'b0;
            cmd_done_reg <= 1'b0;
            cmd_t <= 1'b0; // Đầu ra
            resp_timeout_counter <= 7'd0;
            resp_shift_reg <= 136'd0;
            resp_bit_counter <= 7'd0;
            resp_data_reg <= 48'd0;
            resp_ready_reg <= 1'b0;
            timeout_err_reg <= 1'b0;
            crc_err_reg <= 1'b0;
            resp_index <= 6'd0;
            resp_crc7_calc <= 7'd0;
            resp_crc7_rcvd <= 7'd0;
        end else begin
            case (state)
                IDLE: begin
                    cmd_shift_reg <= 48'd0;
                    cmd_bit_counter <= 6'd0;
                    cmd_busy_reg <= 1'b0;
                    cmd_done_reg <= 1'b0;
                    cmd_t <= 1'b0;
                    resp_timeout_counter <= 7'd0;
                    resp_shift_reg <= 136'd0;
                    resp_bit_counter <= 7'd0;
                    resp_data_reg <= 48'd0;
                    resp_ready_reg <= 1'b0;
                    timeout_err_reg <= 1'b0;
                    crc_err_reg <= 1'b0;
                    resp_index <= 6'd0;
                    resp_crc7_calc <= 7'd0;
                    resp_crc7_rcvd <= 7'd0;
                end
                SEND_CMD: begin
                    cmd_busy_reg <= 1'b1;
                    cmd_t <= 1'b0; // Đầu ra
                    if (cmd_bit_counter == 6'd0) begin
                        cmd_shift_reg <= cmd_frame;
                    end else begin
                        cmd_shift_reg <= {cmd_shift_reg[CMD_FRAME_LEN-2:0], 1'b1};
                    end
                    cmd_bit_counter <= cmd_bit_counter + 1;
                end
                WAIT_RESP: begin
                    cmd_t <= 1'b1; // Đầu vào
                    if (cmd_i == 1'b0) begin
                        resp_timeout_counter <= 7'd0;
                    end else if (resp_timeout_counter == RESP_TIMEOUT - 1) begin
                        timeout_err_reg <= 1'b1;
                    end else begin
                        resp_timeout_counter <= resp_timeout_counter + 1;
                    end
                end
                RECV_RESP: begin
                    resp_shift_reg <= {resp_shift_reg[RESP_LEN_R2-2:0], cmd_i};
                    resp_bit_counter <= resp_bit_counter + 1;

                    if (response_type == 2'b10) begin // R2
                        if (resp_bit_counter == RESP_LEN_R2 - 1) begin
                            resp_data_reg <= resp_shift_reg[135:88]; // Lưu 48-bit đầu tiên
                            resp_crc7_rcvd <= resp_shift_reg[7:1];
                            resp_crc7_calc <= calc_crc7(resp_shift_reg[135:8]);
                        end
                    end else begin // R1, R3, R6, R7
                        if (resp_bit_counter == RESP_LEN_R1_R3_R6_R7 - 1) begin
                            resp_data_reg <= resp_shift_reg[47:0];
                            resp_index <= resp_shift_reg[45:40];
                            resp_crc7_rcvd <= resp_shift_reg[7:1];
                            resp_crc7_calc <= calc_crc7(resp_shift_reg[47:8]);
                        end
                    end
                end
                CHECK_RESP: begin
                    if (response_type != 2'b00) begin // Có phản hồi
                        // Kiểm tra CRC (nếu bật)
                        if (cmd_crc_check_en && response_type != 2'b11) begin // R3 không có CRC
                            if (resp_crc7_calc != resp_crc7_rcvd) begin
                                crc_err_reg <= 1'b1;
                            end
                        end
                        // Kiểm tra chỉ số lệnh (nếu bật và không phải R2, R3)
                        if (cmd_index_check_en && response_type != 2'b10 && response_type != 2'b11) begin
                            if (resp_index != cmd_index) begin
                                crc_err_reg <= 1'b1; // Dùng crc_err để báo lỗi chung
                            end
                        end
                        resp_ready_reg <= 1'b1;
                    end
                    cmd_done_reg <= 1'b1;
                end
                DONE: begin
                    cmd_busy_reg <= 1'b0;
                    cmd_done_reg <= 1'b0;
                    resp_ready_reg <= 1'b0;
                end
            endcase
        end
    end

endmodule