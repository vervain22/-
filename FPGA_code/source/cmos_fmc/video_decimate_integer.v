`timescale 1ns / 1ps
// 输出保留 640×360 实际采样点：HDMI 三倍抽样，摄像头二倍抽样。
// 仅按有效像素计数，空闲周期不推进坐标。
module video_decimate_integer #(
    parameter INPUT_WIDTH = 1920,
    INPUT_HEIGHT = 1080,
    DIV = 3
) (
    input clk,
    input rst_n,
    input frame_sync,
    input in_valid,
    input [15:0] in_data,
    output reg out_frame_sync,
    output reg out_valid,
    output reg [15:0] out_data,
    output reg frame_complete
);
    reg vs_d;
    reg [11:0] x;
    reg [10:0] y;
    reg [2:0] xp, yp;
    reg armed;
    always @(posedge clk) begin
        if (!rst_n) begin
            vs_d <= 0;
            x <= 0;
            y <= 0;
            xp <= 0;
            yp <= 0;
            armed <= 0;
            out_frame_sync <= 0;
            out_valid <= 0;
            out_data <= 0;
            frame_complete <= 0;
        end else begin
            vs_d <= frame_sync;
            out_frame_sync <= frame_sync && !vs_d;
            out_valid <= 0;
            frame_complete <= 0;
            if (frame_sync && !vs_d) begin
                x <= 0;
                y <= 0;
                xp <= 0;
                yp <= 0;
                armed <= 1;
            end else if (in_valid && armed) begin
                if (xp == 0 && yp == 0) begin
                    out_valid <= 1;
                    out_data  <= in_data;
                end
                if (x == INPUT_WIDTH - 1) begin
                    x  <= 0;
                    xp <= 0;
                    if (y == INPUT_HEIGHT - 1) begin
                        y <= 0;
                        yp <= 0;
                        armed <= 0;
                        frame_complete <= 1;
                    end else begin
                        y  <= y + 1'b1;
                        yp <= (yp == DIV - 1) ? 3'd0 : yp + 1'b1;
                    end
                end else begin
                    x  <= x + 1'b1;
                    xp <= (xp == DIV - 1) ? 3'd0 : xp + 1'b1;
                end
            end
        end
    end
endmodule
