`timescale 1ns / 1ps
// 旁路逐像素统计，每时钟处理一个像素，不反压视频流。
// 所有输入均属于 clk 时钟域，顶层通过跨时钟域邮箱传输结果。
// 帧首和帧尾分别占用空白周期，此时 pixel_valid=0。
// 提交操作更新影子配置，在下一帧开始时生效。
// 提交与帧首同周期发生时，本帧仍使用原影子配置。
// 区域坐标采用左闭右开区间 [x0,x1)、[y0,y1)，输入为 1920×1080 RGB888。
module roi_color_stats #(
    parameter integer N = 4,
    parameter integer LEASE_FRAMES = 30
) (
    input wire clk,
    rst_n,
    input wire cfg_commit,
    input wire [31:0] cfg_version,
    input wire [N-1:0] cfg_enable,
    input wire [N*12-1:0] cfg_x0,
    cfg_y0,
    cfg_x1,
    cfg_y1,
    input wire frame_start,
    frame_end,
    pixel_valid,
    input wire [11:0] pixel_x,
    pixel_y,
    input wire [23:0] pixel_rgb,
    output reg result_valid,
    output reg [31:0] result_frame,
    result_version,
    output reg [N-1:0] result_enable,
    output reg [N*22-1:0] result_total,
    result_bright,
    output reg [N*22-1:0] result_red,
    result_yellow,
    result_green
);
    reg [N*12-1:0] sx0, sy0, sx1, sy1, ax0, ay0, ax1, ay1;
    reg [N-1:0] se, ae;
    reg [31:0] sv, av, frame_id;
    reg [15:0] lease;
    reg in_frame;
    reg [21:0] total[0:N-1];
    reg [21:0] bright[0:N-1];
    reg [21:0] red[0:N-1];
    reg [21:0] yellow[0:N-1];
    reg [21:0] green[0:N-1];
    wire [8:0] r = {1'b0, pixel_rgb[23:16]};
    wire [8:0] g = {1'b0, pixel_rgb[15:8]};
    wire [8:0] b = {1'b0, pixel_rgb[7:0]};
    // 像素分类阈值
    // 比较位宽扩展为 9 位，避免接近 255 时溢出；颜色分类互斥。
    wire is_bright = (r >= 9'd80 || g >= 9'd80 || b >= 9'd80);
    wire is_red = r >= 9'd80 && r >= g + 9'd32 && r >= b + 9'd32;
    // 保留绿色范围，并接收蓝分量有限偏高的青绿灯光；G、B 均须高于 R。
    // 区域内颜色像素统计不直接作为交通灯状态判定。
    // 用扩展位宽的 2×R≤G 条件排除低饱和青灰背景；高饱和背景仍需区域定位排除。
    wire green_standard = g >= 9'd80 && g >= r + 9'd24 && g >= b + 9'd24;
    wire green_cyan = g>=9'd96 && g>=r+9'd32 && b>=r+9'd24 &&
                  b<=g+9'd24 && g<=b+9'd24 && {r[7:0],1'b0}<=g;
    wire is_green = green_standard || green_cyan;
    wire is_yellow = r >= 9'd96 && g >= 9'd80 && r >= b + 9'd32 && g >= b + 9'd32 && r < g + 9'd32 && g < r + 9'd24;
    reg [N-1:0] hit_total, hit_bright, hit_red, hit_yellow, hit_green;
    reg end_d;
    integer i;
    always @(posedge clk) begin
        if (!rst_n) begin
            sx0 <= 0;
            sy0 <= 0;
            sx1 <= 0;
            sy1 <= 0;
            se <= 0;
            sv <= 0;
            ax0 <= 0;
            ay0 <= 0;
            ax1 <= 0;
            ay1 <= 0;
            ae <= 0;
            av <= 0;
            lease <= 0;
            frame_id <= 0;
            in_frame <= 0;
            hit_total <= 0;
            hit_bright <= 0;
            hit_red <= 0;
            hit_yellow <= 0;
            hit_green <= 0;
            end_d <= 0;
            result_valid <= 0;
            result_frame <= 0;
            result_version <= 0;
            result_enable <= 0;
            result_total <= 0;
            result_bright <= 0;
            result_red <= 0;
            result_yellow <= 0;
            result_green <= 0;
            for (i = 0; i < N; i = i + 1) begin
                total[i] <= 0;
                bright[i] <= 0;
                red[i] <= 0;
                yellow[i] <= 0;
                green[i] <= 0;
            end
        end else begin
            result_valid <= 0;
            end_d <= frame_end && in_frame;
            // 区域命中和颜色分类先寄存，再使能计数器。
            // 帧尾延迟一周期，计入流水线中的最后一个像素。
            for (i = 0; i < N; i = i + 1) begin
                hit_total[i] <= 0;
                hit_bright[i] <= 0;
                hit_red[i] <= 0;
                hit_yellow[i] <= 0;
                hit_green[i] <= 0;
                if(pixel_valid && in_frame && !frame_start && !frame_end && ae[i] &&
               pixel_x>=ax0[i*12+:12] && pixel_x<ax1[i*12+:12] &&
               pixel_y>=ay0[i*12+:12] && pixel_y<ay1[i*12+:12]) begin
                    hit_total[i] <= 1;
                    hit_bright[i] <= is_bright;
                    hit_red[i] <= is_red;
                    hit_yellow[i] <= is_yellow;
                    hit_green[i] <= is_green;
                end
            end
            if (cfg_commit) begin
                sx0 <= cfg_x0;
                sy0 <= cfg_y0;
                sx1 <= cfg_x1;
                sy1 <= cfg_y1;
                sv <= cfg_version;
                lease <= LEASE_FRAMES;
                for (i = 0; i < N; i = i + 1)
                se[i]<=cfg_enable[i] &&
                cfg_x0[i*12+:12]<cfg_x1[i*12+:12] && cfg_y0[i*12+:12]<cfg_y1[i*12+:12] &&
                cfg_x1[i*12+:12]<=1920 && cfg_y1[i*12+:12]<=1080;
            end
            if (frame_start) begin
                frame_id <= frame_id + 1'b1;
                in_frame <= 1;
                ax0 <= sx0;
                ay0 <= sy0;
                ax1 <= sx1;
                ay1 <= sy1;
                av <= sv;
                if (!cfg_commit && lease != 0) lease <= lease - 1'b1;
                for (i = 0; i < N; i = i + 1) begin
                    ae[i] <= se[i] && lease != 0;
                    total[i] <= 0;
                    bright[i] <= 0;
                    red[i] <= 0;
                    yellow[i] <= 0;
                    green[i] <= 0;
                end
            end else begin
                if (frame_end) in_frame <= 0;
                for (i = 0; i < N; i = i + 1) begin
                    if (hit_total[i]) total[i] <= total[i] + 1'b1;
                    if (hit_bright[i]) bright[i] <= bright[i] + 1'b1;
                    if (hit_red[i]) red[i] <= red[i] + 1'b1;
                    if (hit_yellow[i]) yellow[i] <= yellow[i] + 1'b1;
                    if (hit_green[i]) green[i] <= green[i] + 1'b1;
                end
            end
            // 结果发布独立于下一帧开始，避免新帧覆盖已完成的计数。
            if (end_d) begin
                result_valid   <= 1;
                result_frame   <= frame_id;
                result_version <= av;
                result_enable  <= ae;
                for (i = 0; i < N; i = i + 1) begin
                    result_total[i*22+:22] <= total[i];
                    result_bright[i*22+:22] <= bright[i];
                    result_red[i*22+:22] <= red[i];
                    result_yellow[i*22+:22] <= yellow[i];
                    result_green[i*22+:22] <= green[i];
                end
            end
        end
    end
endmodule
