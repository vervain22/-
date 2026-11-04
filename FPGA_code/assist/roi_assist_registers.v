`timescale 1ns / 1ps
// 辅助寄存器窗口为 256 字节，地址单位为 128 位字；访问前须完成 BAR0 和窗口地址译码。
// 访问须由 BAR0 命中及完整窗口地址共同限定。
// 读数据寄存一级，与同步 RAM 的单周期读延迟一致。
module roi_assist_registers (
    input wire clk,
    rst_n,
    input wire wr_en,
    input wire [3:0] wr_word,
    input wire [127:0] wr_data,
    input wire [15:0] wr_be,
    input wire rd_en,
    input wire [3:0] rd_word,
    output reg [127:0] rd_data,
    output reg cfg_send,
    input wire cfg_ready,
    output reg [227:0] cfg_payload,
    input wire result_valid,
    input wire [507:0] result_payload,
    input wire debug_valid,
    input wire [511:0] debug_payload
);
    reg [3:0] enable_shadow;
    reg [47:0] x0, y0, x1, y1;
    reg commit_rejected;
    reg [31:0] snapshot_seq;
    reg [507:0] latest_result, snapshot;
    reg [511:0] latest_debug, debug_snapshot;
    reg [31:0] debug_updates, result_receives, cfg_commits;
    reg [127:0] debug_meta_snapshot;
    wire [31:0] status = {29'd0, commit_rejected, latest_result[443:440] != 0, cfg_ready && !cfg_send};
    integer i;
    always @(posedge clk) begin
        if (!rst_n) begin
            enable_shadow <= 0;
            x0 <= 0;
            y0 <= 0;
            x1 <= 0;
            y1 <= 0;
            cfg_send <= 0;
            cfg_payload <= 0;
            commit_rejected <= 0;
            latest_result <= 0;
            snapshot <= 0;
            snapshot_seq <= 0;
            rd_data <= 0;
            latest_debug <= 0;
            debug_snapshot <= 0;
            debug_updates <= 0;
            result_receives <= 0;
            cfg_commits <= 0;
            debug_meta_snapshot <= 0;
        end else begin
            cfg_send <= 0;
            if (result_valid) begin
                latest_result   <= result_payload;
                result_receives <= result_receives + 1'b1;
            end
            if (debug_valid) begin
                latest_debug  <= debug_payload;
                debug_updates <= debug_updates + 1'b1;
            end
            if (wr_en) begin
                if (wr_word == 1) begin
                    if (&wr_be[7:4]) enable_shadow <= wr_data[35:32];
                    if ((&wr_be[11:8]) && wr_data[64]) begin
                        snapshot <= latest_result;
                        snapshot_seq <= snapshot_seq + 1'b1;
                        debug_snapshot <= latest_debug;
                        debug_meta_snapshot <= {32'h44424731, cfg_commits, result_receives, debug_updates};
                    end
                    if ((&wr_be[15:12]) && wr_data[96]) commit_rejected <= 0;
                    if (&wr_be[3:0]) begin
                        if (cfg_ready && !cfg_send) begin
                            cfg_payload <= {wr_data[31:0], enable_shadow, x0, y0, x1, y1};
                            cfg_send <= 1;
                            cfg_commits <= cfg_commits + 1'b1;
                        end else commit_rejected <= 1;
                    end
                end
                for (i = 0; i < 4; i = i + 1) begin
                    if (wr_word == i + 2) begin
                        if (&wr_be[3:0]) x0[i*12+:12] <= wr_data[11:0];
                        if (&wr_be[7:4]) y0[i*12+:12] <= wr_data[43:32];
                        if (&wr_be[11:8]) x1[i*12+:12] <= wr_data[75:64];
                        if (&wr_be[15:12]) y1[i*12+:12] <= wr_data[107:96];
                    end
                end
            end
            if (rd_en) begin
                rd_data <= 0;
                case (rd_word)
                    0: rd_data <= {32'd1, snapshot_seq, status, 32'h524f4931};
                    2: rd_data <= debug_snapshot[511:384];
                    3: rd_data <= {96'd0, 32'h44584731};  // DXG1 扩展诊断寄存器
                    6: rd_data <= debug_snapshot[127:0];
                    7: rd_data <= debug_snapshot[255:128];
                    14: rd_data <= debug_snapshot[383:256];
                    15: rd_data <= debug_meta_snapshot;
                    8: rd_data <= {28'd0, snapshot[443:440], snapshot[475:444], snapshot[507:476], snapshot_seq};
                    9: for (i = 0; i < 4; i = i + 1) rd_data[i*32+:32] <= {10'd0, snapshot[352+i*22+:22]};
                    10: for (i = 0; i < 4; i = i + 1) rd_data[i*32+:32] <= {10'd0, snapshot[264+i*22+:22]};
                    11: for (i = 0; i < 4; i = i + 1) rd_data[i*32+:32] <= {10'd0, snapshot[176+i*22+:22]};
                    12: for (i = 0; i < 4; i = i + 1) rd_data[i*32+:32] <= {10'd0, snapshot[88+i*22+:22]};
                    13: for (i = 0; i < 4; i = i + 1) rd_data[i*32+:32] <= {10'd0, snapshot[i*22+:22]};
                    default: rd_data <= 0;
                endcase
            end
        end
    end
endmodule
