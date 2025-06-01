module sd_host_controller (
    input  logic        clk,           
    input  logic        rst_n,         

    // Giao tiếp với host (CPU)
    input  logic [31:0] waddr,
    input  logic [31:0] raddr,
    input  logic        we,
    input  logic        re,
    input  logic [31:0] wdata,
    output logic [31:0] rdata,
    output logic        interrupt,

    // Giao tiếp với thẻ SD
    input  logic        cmd_i,         
    output logic        cmd_o,         
    output logic        cmd_t,         
    input  logic [3:0]  dat_i,         
    output logic [3:0]  dat_o,         
    output logic [3:0]  dat_t,         
    output logic        sdclk_o        
);

    // Tín hiệu nội bộ giữa các khối
    logic        cmd_start;
    logic [5:0]  cmd_index;
    logic [31:0] cmd_arg;
    logic [1:0]  response_type;
    logic        cmd_index_check_en;
    logic        cmd_crc_check_en;
    logic        cmd_busy;
    logic        cmd_done;
    logic        resp_ready;
    logic        timeout_err_cmd;
    logic        crc_err_cmd;
    logic [47:0] resp_data;
    logic        data_direction;
    logic [11:0] block_size;
    logic        buffer_access;
    logic        data_busy;
    logic        data_done;
    logic        timeout_err_data;
    logic        crc_err_data;
    logic [31:0] rx_data;
    logic        rx_rd_en;
    logic        rx_empty;
    logic        rx_full;
    logic [31:0] tx_data;
    logic        tx_wr_en;
    logic        tx_full;
    logic        tx_empty;
    logic        tx_rd_en;
    logic [7:0]  clk_div;

    // Khối register_block
    register_block reg_block (
        .clk(clk),
        .rst_n(rst_n),
        .waddr(waddr),
        .raddr(raddr),
        .we(we),
        .re(re),
        .wdata(wdata),
        .rdata(rdata),
        .interrupt(interrupt),
        .cmd_start(cmd_start),
        .cmd_index(cmd_index),
        .cmd_arg(cmd_arg),
        .response_type(response_type),
        .cmd_index_check_en(cmd_index_check_en),
        .cmd_crc_check_en(cmd_crc_check_en),
        .cmd_busy(cmd_busy),
        .cmd_done(cmd_done),
        .resp_ready(resp_ready),
        .timeout_err_cmd(timeout_err_cmd),
        .crc_err_cmd(crc_err_cmd),
        .resp_data(resp_data),
        .data_direction(data_direction),
        .block_size(block_size),
        .buffer_access(buffer_access),
        .data_busy(data_busy),
        .data_done(data_done),
        .timeout_err_data(timeout_err_data),
        .crc_err_data(crc_err_data),
        .rx_data(rx_data),
        .rx_rd_en(rx_rd_en),
        .rx_empty(rx_empty),
        .rx_full(rx_full),
        .tx_data(tx_data),
        .tx_wr_en(tx_wr_en),
        .tx_full(tx_full),
        .tx_empty(tx_empty),
        .clk_div(clk_div)
    );

    // Khối data_path_ctrl
    data_path_ctrl data_path (
        .clk(clk),
        .rst_n(rst_n),
        .sdclk_i(sdclk_o),
        .cmd_done(cmd_done),
        .resp_ready(resp_ready),
        .crc_err_cmd(crc_err_cmd),
        .timeout_err_cmd(timeout_err_cmd),
        .data_direction(data_direction),
        .block_size(block_size),
        .buffer_access(buffer_access),
        .tx_data(tx_data),
        .tx_rd_en(tx_rd_en),
        .tx_empty(tx_empty),
        .rx_data(rx_data),
        .rx_wr_en(rx_wr_en),
        .rx_full(rx_full),
        .dat_i(dat_i),
        .dat_o(dat_o),
        .dat_t(dat_t),
        .data_busy(data_busy),
        .data_done(data_done),
        .timeout_err_data(timeout_err_data),
        .crc_err_data(crc_err_data)
    );

    // Khối cmd_path_ctrl (giả định, cần được triển khai đầy đủ)
    command_path_ctrl cmd_path (
        .clk(clk),
        .rst_n(rst_n),
        .sdclk_i(sdclk_o),
        .cmd_start(cmd_start),
        .cmd_index(cmd_index),
        .cmd_arg(cmd_arg),
        .response_type(response_type),
        .cmd_index_check_en(cmd_index_check_en),
        .cmd_crc_check_en(cmd_crc_check_en),
        .cmd_i(cmd_i),
        .cmd_o(cmd_o),
        .cmd_t(cmd_t),
        .cmd_busy(cmd_busy),
        .cmd_done(cmd_done),
        .resp_ready(resp_ready),
        .timeout_err(timeout_err_cmd),
        .crc_err(crc_err_cmd),
        .resp_data(resp_data)
    );

    // Khối clock_divider
    clock_div clk_divider (
        .clk(clk),
        .rst_n(rst_n),
        .clk_div(clk_div),
        .sdclk_i(sdclk_o)
    );

    // Khối tx_fifo (giả định, sử dụng FIFO đơn giản)
    fifo #(.DATA_W(32), .DEPTH(128)) tx_fifo (
        .clk_i (clk),
        .rst_ni (rst_n),
        .we_i (tx_wr_en),
        .re_i (tx_rd_en),
        .wdata_i(tx_data),
        .rdata_o(tx_data),
        .full   (tx_full),
        .empty  (tx_empty)
    );

    // Khối rx_fifo (giả định, sử dụng FIFO đơn giản)
    fifo #(.DATA_W(32), .DEPTH(128)) rx_fifo (
        .clk_i   (clk),
        .rst_ni  (rst_n),
        .we_i    (rx_wr_en),
        .re_i    (rx_rd_en),
        .wdata_i (rx_data),
        .rdata_o (rx_data),
        .full   (rx_full),
        .empty  (rx_empty)
    );

endmodule