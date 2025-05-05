module command_path_ctrl #(
    parameter TIMEOUT_CYCLES = 100000
)(
    input  logic        clk,
    input  logic        rst_n,

    //input from Register Block
    input  logic        cmd_start,
    input  logic [5:0]  cmd_index,
    input  logic [31:0] cmd_arg,
    input  logic [1:0]  cmd_type,         // 00 = no resp, 01 = short, 10 = long
    input  logic        resp_timeout_en,

    // connect to PHY
    output logic        phy_cmd_valid,
    output logic [47:0] phy_cmd_out,
    input  logic        phy_cmd_done,

    input  logic        phy_resp_valid,
    input  logic [47:0] phy_resp_in,

    // response Host
    output logic        cmd_busy,
    output logic        cmd_done,
    output logic        resp_ready,
    output logic        timeout_err,
    output logic        crc_err,
    output logic [47:0] resp_data
);

    // ========== State machine ==========
    typedef enum logic [2:0] {
        IDLE,
        LOAD,
        SEND_CMD,
        WAIT_RESP,
        CHECK_RESP,
        DONE,
        ERROR
    } state_t;

    state_t state, next_state;

    // ========== Internal signals ==========
    logic [47:0] cmd_frame;
    logic [6:0]  crc7_result;
    logic [15:0] timeout_cnt;

    // CRC7 module instance placeholder (you'll implement it later)
    // crc7_gen u_crc7 (.data_in(...), .crc_out(crc7_result));

    // ========== FSM ==========
    always_ff @(posedge clk or negedge resetn) begin
        if (!rst_n) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    // ========== Next state logic ==========
    always_comb begin
        next_state = state;
        case (state)
            IDLE: if (cmd_start) next_state = LOAD;
            LOAD: next_state = SEND_CMD;
            SEND_CMD: if (phy_cmd_done) next_state = (cmd_type == 2'b00) ? DONE : WAIT_RESP;
            WAIT_RESP: begin
                if (phy_resp_valid)  next_state = CHECK_RESP;
                else if (resp_timeout_en && timeout_cnt == 0) next_state = ERROR;
            end
            CHECK_RESP: next_state = DONE;
            DONE: next_state = IDLE;
            ERROR: next_state = IDLE;
        endcase
    end

    // ========== Command frame format ==========
    always_comb begin
        // Format: [start|tx|cmd_index|arg|crc7|end] = 48 bits
        cmd_frame = {1'b0, 1'b1, cmd_index, cmd_arg, crc7_result, 1'b1};
    end

    // ========== Outputs & control logic ==========
    always_ff @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            phy_cmd_valid <= 0;
            cmd_done      <= 0;
            resp_ready    <= 0;
            timeout_err   <= 0;
            crc_err       <= 0;
            cmd_busy      <= 0;
            timeout_cnt   <= TIMEOUT_CYCLES;
        end else begin
            case (state)
                IDLE: begin
                    phy_cmd_valid <= 0;
                    cmd_done      <= 0;
                    resp_ready    <= 0;
                    timeout_err   <= 0;
                    crc_err       <= 0;
                    cmd_busy      <= 0;
                    timeout_cnt   <= TIMEOUT_CYCLES;
                end
                LOAD: begin
                    cmd_busy <= 1;
                end
                SEND_CMD: begin
                    phy_cmd_valid <= 1;
                    phy_cmd_out   <= cmd_frame;
                end
                WAIT_RESP: begin
                    phy_cmd_valid <= 0;
                    if (timeout_cnt > 0)
                        timeout_cnt <= timeout_cnt - 1;
                end
                CHECK_RESP: begin
                    resp_data   <= phy_resp_in;
                    resp_ready  <= 1;
                    crc_err     <= 0; // Optional: add real CRC7 checker here
                end
                DONE: begin
                    cmd_done <= 1;
                end
                ERROR: begin
                    timeout_err <= 1;
                    cmd_done    <= 1;
                end
            endcase
        end
    end

endmodule
