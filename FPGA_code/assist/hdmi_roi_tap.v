`timescale 1ns / 1ps
// 按有效像素生成光栅坐标，VS、DE 和 RGB 先在输入端同步寄存。
// 相邻 VS 上升沿界定一帧，仅在 DE 有效时推进坐标。
// 下一次 VS 到来时检查像素总数；仅接收完整的 WIDTH×HEIGHT 帧。
module hdmi_roi_tap #(
    parameter integer WIDTH = 1920,
    HEIGHT = 1080
) (
    input wire clk,
    rst_n,
    vsync,
    de,
    input wire [23:0] rgb,
    output reg frame_start,
    frame_end,
    pixel_valid,
    output reg [11:0] pixel_x,
    pixel_y,
    output reg [23:0] pixel_rgb,
    output reg [31:0] malformed_frames,
    output reg [31:0] last_error
);
    localparam integer TOTAL = WIDTH * HEIGHT;
    reg vs_d, armed, active, bad;
    reg [21:0] count;
    reg [11:0] x, y;
    reg q_valid, end_pending;
    reg [11:0] q_x, q_y;
    reg [23:0] q_rgb;
    always @(posedge clk) begin
        if (!rst_n) begin
            vs_d <= 0;
            armed <= 0;
            active <= 0;
            bad <= 0;
            count <= 0;
            x <= 0;
            y <= 0;
            frame_start <= 0;
            frame_end <= 0;
            pixel_valid <= 0;
            pixel_x <= 0;
            pixel_y <= 0;
            pixel_rgb <= 0;
            malformed_frames <= 0;
            last_error <= 0;
            q_valid <= 0;
            q_x <= 0;
            q_y <= 0;
            q_rgb <= 0;
            end_pending <= 0;
        end else begin
            vs_d <= vsync;
            frame_start <= 0;
            frame_end <= end_pending;
            end_pending <= 0;
            pixel_valid <= q_valid;
            pixel_x <= q_x;
            pixel_y <= q_y;
            pixel_rgb <= q_rgb;
            q_valid <= 0;
            if (vsync && !vs_d) begin
                if (active) begin
                    if (count == TOTAL && !bad && !de) begin
                        end_pending <= 1;
                        last_error  <= 0;
                    end else begin
                        malformed_frames <= malformed_frames + 1'b1;
                        last_error <= {29'd0, de, bad, (count != TOTAL)};
                    end
                end
                // VS 与 DE 重叠视为帧边界异常，不计作首个有效像素。
                armed <= !de;
                active <= 0;
                bad <= 0;
                count <= 0;
                x <= 0;
                y <= 0;
            end else if (de) begin
                if (vsync) begin
                    armed <= 0;
                    bad   <= 1;
                end else if (armed) begin
                    // 首像素之前保留空白标记周期；空白不足时丢弃该帧，避免帧首与帧尾重叠。
                    if (!end_pending) begin
                        armed <= 0;
                        active <= 1;
                        count <= 1;
                        x <= (WIDTH == 1) ? 0 : 1;
                        y <= (WIDTH == 1) ? 1 : 0;
                        frame_start <= 1;
                        q_valid <= 1;
                        q_x <= 0;
                        q_y <= 0;
                        q_rgb <= rgb;
                    end else begin
                        armed <= 0;
                        active <= 1;
                        bad <= 1;
                        last_error <= 8;
                    end
                end else if (active) begin
                    if (count < TOTAL) begin
                        q_valid <= 1;
                        q_x <= x;
                        q_y <= y;
                        q_rgb <= rgb;
                        count <= count + 1'b1;
                        if (x == WIDTH - 1) begin
                            x <= 0;
                            y <= y + 1'b1;
                        end else x <= x + 1'b1;
                    end else bad <= 1;
                end
            end
        end
    end
endmodule
