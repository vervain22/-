`timescale 1ns / 1ps
// DDR 读控制器在 core_clk 返回应答，请求保持到同步应答到达，不能用单周期脉冲跨域。
module ddr_read_start (
    input clk,
    input rst_n,
    input start,
    input [3:0] ack_async,
    input [3:0] line_full,
    output reg [3:0] request,
    output busy,
    output reg ready
);
    (* ASYNC_REG="TRUE" *) reg [3:0] ack_meta, ack_sync;
    assign busy = |request;
    always @(posedge clk) begin
        if (!rst_n) begin
            ack_meta <= 0;
            ack_sync <= 0;
            request <= 0;
            ready <= 0;
        end else begin
            ack_meta <= ack_async;
            ack_sync <= ack_meta;
            if (start) begin
                request <= 4'b1111;
                ready   <= 0;
            end else begin
                request <= request & ~ack_sync;
                if (request == 0 && &line_full) ready <= 1;
            end
        end
    end
endmodule
