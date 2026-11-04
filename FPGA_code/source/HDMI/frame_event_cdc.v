`timescale 1ns / 1ps

// 低速帧事件跨时钟域同步。

// 源时钟域翻转事件标志，目标域同步后累加帧计数，避免源域计数进位链。
module frame_event_cdc #(
    parameter integer WIDTH = 8
) (
    input  wire             src_clk,
    input  wire             src_rst_n,
    input  wire             src_event,
    input  wire             dst_clk,
    input  wire             dst_rst_n,
    output reg  [WIDTH-1:0] dst_count
);

    reg  src_event_d;
    reg  src_event_toggle;

    (* ASYNC_REG = "TRUE" *)reg  dst_toggle_meta;
    (* ASYNC_REG = "TRUE" *)reg  dst_toggle_sync;
    reg  dst_toggle_seen;

    wire src_event_rise = src_event && !src_event_d;

    always @(posedge src_clk or negedge src_rst_n) begin
        if (!src_rst_n) begin
            src_event_d      <= 1'b0;
            src_event_toggle <= 1'b0;
        end else begin
            src_event_d <= src_event;
            if (src_event_rise) src_event_toggle <= ~src_event_toggle;
        end
    end

    always @(posedge dst_clk or negedge dst_rst_n) begin
        if (!dst_rst_n) begin
            dst_toggle_meta <= 1'b0;
            dst_toggle_sync <= 1'b0;
            dst_toggle_seen <= 1'b0;
            dst_count       <= {WIDTH{1'b0}};
        end else begin
            dst_toggle_meta <= src_event_toggle;
            dst_toggle_sync <= dst_toggle_meta;

            if (dst_toggle_sync != dst_toggle_seen) begin
                dst_toggle_seen <= dst_toggle_sync;
                dst_count       <= dst_count + {{(WIDTH - 1) {1'b0}}, 1'b1};
            end
        end
    end

endmodule
