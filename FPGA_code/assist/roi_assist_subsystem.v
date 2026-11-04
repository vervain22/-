`timescale 1ns / 1ps
// 辅助 BAR0 寄存器接口及独立视频输入观测。
// 任一时钟停振时，两时钟域仍须同时进入复位。
module roi_assist_subsystem #(
    parameter integer WIDTH = 1920,
    HEIGHT = 1080,
    PIX_READY_SYNC = 0
) (
    input wire bus_clk,
    pix_clk,
    rst_n,
    input wire pix_ready,
    input wire wr_en,
    input wire [3:0] wr_word,
    input wire [127:0] wr_data,
    input wire [15:0] wr_be,
    input wire rd_en,
    input wire [3:0] rd_word,
    output wire [127:0] rd_data,
    input wire vsync,
    de,
    input wire [23:0] rgb
);
    // 总线复位异步置位。PIX_READY_SYNC=1 时，HDMI 就绪信号已在顶层同步，像素域仅作同步清零。
    // 总线时钟域继续使用异步复位链。
    // 默认参数保留共用复位接口。
    (* ASYNC_REG="TRUE" *) reg [1:0] br, pr;
    wire bus_reset_n = rst_n && (!PIX_READY_SYNC || pix_ready);
    always @(posedge bus_clk or negedge bus_reset_n)
        if (!bus_reset_n) br <= 0;
        else br <= {br[0], 1'b1};
    always @(posedge pix_clk or negedge rst_n)
        if (!rst_n) pr <= 0;
        else if (PIX_READY_SYNC && !pix_ready) pr <= 0;
        else pr <= {pr[0], 1'b1};
    wire cfg_send, cfg_ready, cfg_valid;
    wire [227:0] cfg_payload, cfg_received;
    wire result_valid, result_ready, result_bus_valid;
    wire [507:0] result_payload, result_received;
    wire fs, fe, pv;
    wire [11:0] px, py;
    wire [23:0] pixel;
    wire [31:0] malformed, frame_id, version, tap_error;
    // 共用寄存后的输入，避免原始 DE 边沿逻辑长距离扇出。
    (* syn_preserve=1 *) reg sample_vs, sample_de;
    (* syn_preserve=1 *) reg [23:0] sample_rgb;
    always @(posedge pix_clk) begin
        if (!pr[1]) begin
            sample_vs  <= 0;
            sample_de  <= 0;
            sample_rgb <= 0;
        end else begin
            sample_vs  <= vsync;
            sample_de  <= de;
            sample_rgb <= rgb;
        end
    end
    wire [3:0] enables;
    wire [87:0] total, bright, red, yellow, green;
    // 诊断数据使用独立邮箱传输，不参与视频和驾驶决策。
    wire debug_valid, debug_ready;
    wire [511:0] debug_received;
    reg  [ 15:0] debug_div;
    reg debug_vs_d, debug_de_d;
    reg [31:0] debug_ticks, debug_vs, debug_lines, debug_fs, debug_fe;
    reg [31:0] debug_cfg, debug_version, debug_results, debug_sent;
    reg [11:0] debug_width, debug_last_width, debug_height, debug_last_height;
    reg [21:0] debug_pixels;
    reg [31:0] debug_last_pixels;
    reg [11:0] debug_min_width, debug_max_width, debug_last_min, debug_last_max;
    reg debug_fs_carry;

    always @(posedge pix_clk) begin
        if (!pr[1]) begin
            debug_div <= 0;
            debug_vs_d <= 0;
            debug_de_d <= 0;
            debug_ticks <= 0;
            debug_vs <= 0;
            debug_lines <= 0;
            debug_fs <= 0;
            debug_fe <= 0;
            debug_cfg <= 0;
            debug_version <= 0;
            debug_results <= 0;
            debug_sent <= 0;
            debug_width <= 0;
            debug_last_width <= 0;
            debug_height <= 0;
            debug_last_height <= 0;
            debug_pixels <= 0;
            debug_last_pixels <= 0;
            debug_min_width <= 0;
            debug_max_width <= 0;
            debug_last_min <= 0;
            debug_last_max <= 0;
            debug_fs_carry <= 0;
        end else begin
            debug_div   <= debug_div + 1'b1;
            debug_ticks <= debug_ticks + 1'b1;
            debug_vs_d  <= sample_vs;
            debug_de_d  <= sample_de;
            if (sample_vs && !debug_vs_d) begin
                debug_vs <= debug_vs + 1'b1;
                debug_last_height <= debug_height;
                debug_height <= (sample_de && !debug_de_d) ? 12'd1 : 12'd0;
            end else if (sample_de && !debug_de_d && debug_height != 12'hfff) debug_height <= debug_height + 1'b1;
            if (sample_de && !debug_de_d) debug_lines <= debug_lines + 1'b1;
            if (sample_de) begin
                if (!debug_de_d) debug_width <= 12'd1;
                else if (debug_width != 12'hfff) debug_width <= debug_width + 1'b1;
            end else if (debug_de_d) begin
                debug_last_width <= debug_width;
                debug_width <= 0;
                if (debug_min_width == 0 || debug_width < debug_min_width) debug_min_width <= debug_width;
                if (debug_width > debug_max_width) debug_max_width <= debug_width;
            end
            if (sample_vs && !debug_vs_d) begin
                debug_last_pixels <= {10'd0, debug_pixels};
                debug_pixels <= sample_de ? 22'd1 : 22'd0;
                debug_last_min <= debug_min_width;
                debug_last_max <= debug_max_width;
                debug_min_width <= 0;
                debug_max_width <= 0;
            end else if (sample_de && debug_pixels != 22'h3fffff) debug_pixels <= debug_pixels + 1'b1;
            // 提前译码低位进位，避免 32 位串行进位路径。
            if (fs) begin
                debug_fs[15:0] <= debug_fs[15:0] + 1'b1;
                debug_fs_carry <= (debug_fs[15:0] == 16'hfffe);
                if (debug_fs_carry) debug_fs[31:16] <= debug_fs[31:16] + 1'b1;
            end
            if (fe) debug_fe <= debug_fe + 1'b1;
            if (cfg_valid) begin
                debug_cfg <= debug_cfg + 1'b1;
                debug_version <= cfg_received[227:196];
            end
            if (result_valid) debug_results <= debug_results + 1'b1;
            if (result_valid && result_ready) debug_sent <= debug_sent + 1'b1;
        end
    end
    // 每 65536 个输入时钟采样一次诊断状态，无视频时也继续采样。
    assist_mailbox #(
        .WIDTH(512)
    ) debug_box (
        .src_clk(pix_clk),
        .src_rst_n(pr[1]),
        .src_send((debug_div == 16'hffff) && debug_ready),
        .src_ready(debug_ready),
        .src_data({
            tap_error,
            20'd0,
            debug_last_max,
            20'd0,
            debug_last_min,
            debug_last_pixels,
            20'd0,
            debug_last_height,
            20'd0,
            debug_last_width,
            debug_sent,
            debug_results,
            debug_version,
            debug_cfg,
            malformed,
            debug_fe,
            debug_fs,
            debug_lines,
            debug_vs,
            debug_ticks
        }),
        .dst_clk(bus_clk),
        .dst_rst_n(br[1]),
        .dst_valid(debug_valid),
        .dst_data(debug_received)
    );
    roi_assist_registers regs (
        .clk(bus_clk),
        .rst_n(br[1]),
        .wr_en(wr_en),
        .wr_word(wr_word),
        .wr_data(wr_data),
        .wr_be(wr_be),
        .rd_en(rd_en),
        .rd_word(rd_word),
        .rd_data(rd_data),
        .cfg_send(cfg_send),
        .cfg_ready(cfg_ready),
        .cfg_payload(cfg_payload),
        .result_valid(result_bus_valid),
        .result_payload(result_received),
        .debug_valid(debug_valid),
        .debug_payload(debug_received)
    );
    assist_mailbox #(
        .WIDTH(228)
    ) cfg_box (
        .src_clk  (bus_clk),
        .src_rst_n(br[1]),
        .src_send (cfg_send),
        .src_data (cfg_payload),
        .src_ready(cfg_ready),
        .dst_clk  (pix_clk),
        .dst_rst_n(pr[1]),
        .dst_valid(cfg_valid),
        .dst_data (cfg_received)
    );
    hdmi_roi_tap #(
        .WIDTH (WIDTH),
        .HEIGHT(HEIGHT)
    ) tap (
        .clk(pix_clk),
        .rst_n(pr[1]),
        .vsync(sample_vs),
        .de(sample_de),
        .rgb(sample_rgb),
        .frame_start(fs),
        .frame_end(fe),
        .pixel_valid(pv),
        .pixel_x(px),
        .pixel_y(py),
        .pixel_rgb(pixel),
        .malformed_frames(malformed),
        .last_error(tap_error)
    );
    roi_color_stats stats (
        .clk(pix_clk),
        .rst_n(pr[1]),
        .cfg_commit(cfg_valid),
        .cfg_version(cfg_received[227:196]),
        .cfg_enable(cfg_received[195:192]),
        .cfg_x0(cfg_received[191:144]),
        .cfg_y0(cfg_received[143:96]),
        .cfg_x1(cfg_received[95:48]),
        .cfg_y1(cfg_received[47:0]),
        .frame_start(fs),
        .frame_end(fe),
        .pixel_valid(pv),
        .pixel_x(px),
        .pixel_y(py),
        .pixel_rgb(pixel),
        .result_valid(result_valid),
        .result_frame(frame_id),
        .result_version(version),
        .result_enable(enables),
        .result_total(total),
        .result_bright(bright),
        .result_red(red),
        .result_yellow(yellow),
        .result_green(green)
    );
    assign result_payload = {frame_id, version, enables, total, bright, red, yellow, green};
    // 结果邮箱忙时丢弃本次统计，不阻塞 HDMI，也不更新旧结果的帧号。
    assist_mailbox #(
        .WIDTH(508)
    ) result_box (
        .src_clk  (pix_clk),
        .src_rst_n(pr[1]),
        .src_send (result_valid && result_ready),
        .src_data (result_payload),
        .src_ready(result_ready),
        .dst_clk  (bus_clk),
        .dst_rst_n(br[1]),
        .dst_valid(result_bus_valid),
        .dst_data (result_received)
    );
endmodule
