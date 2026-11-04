`timescale 1ns / 1ps
// 跨时钟域数据邮箱。发送端保持数据，接收端采样后返回应答；两端使用协调复位。
// 接收端按 dst_valid 单周期脉冲取数，不使用异步 FIFO。
// 跨时钟域路径的布局及最大延迟由约束文件限定。
module assist_mailbox #(
    parameter integer WIDTH = 16
) (
    input wire src_clk,
    src_rst_n,
    src_send,
    input wire [WIDTH-1:0] src_data,
    output wire src_ready,
    input wire dst_clk,
    dst_rst_n,
    output reg dst_valid,
    output reg [WIDTH-1:0] dst_data
);
    (* syn_keep=1 *) reg [WIDTH-1:0] held;
    reg request_toggle, ack_toggle;
    (* syn_keep=1 *) reg dst_capture;
    (* ASYNC_REG="TRUE" *) reg ack_meta, ack_sync;
    (* ASYNC_REG="TRUE" *) reg req_meta, req_sync;
    assign src_ready = src_rst_n && (ack_sync == request_toggle);
    always @(posedge src_clk or negedge src_rst_n) begin
        if (!src_rst_n) begin
            held <= 0;
            request_toggle <= 0;
            ack_meta <= 0;
            ack_sync <= 0;
        end else begin
            ack_meta <= ack_toggle;
            ack_sync <= ack_meta;
            if (src_send && src_ready) begin
                held <= src_data;
                request_toggle <= ~request_toggle;
            end
        end
    end
    always @(posedge dst_clk or negedge dst_rst_n) begin
        if (!dst_rst_n) begin
            req_meta <= 0;
            req_sync <= 0;
            ack_toggle <= 0;
            dst_valid <= 0;
            dst_data <= 0;
            dst_capture <= 0;
        end else begin
            req_meta <= request_toggle;
            req_sync <= req_meta;
            dst_valid <= 0;
            // 请求同步后先译码，下一周期采样数据；发送端在收到应答前保持数据。
            dst_capture <= (req_sync != ack_toggle) && !dst_capture;
            if (dst_capture) begin
                dst_data   <= held;
                dst_valid  <= 1;
                ack_toggle <= req_sync;
            end
        end
    end
endmodule
