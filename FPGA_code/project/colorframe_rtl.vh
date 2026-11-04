// 同帧颜色统计与图像打包模块

`ifndef QIANSAI_V61_COLOR_COUNT_3X3
`define QIANSAI_V61_COLOR_COUNT_3X3
`timescale 1ns / 1ps
// RGB888 光栅输入，每时钟处理一个像素。
// 帧首、帧尾均为空白周期；帧尾后至少留出 6 个时钟再开始下一帧。
// 写入端先暂存，仅在 frame_done 与 frame_good 同时有效时发布整帧。
// 像素缺失或超量时整帧无效，复位撤销尚未完成的写入。
module color_count_3x3 #(
    parameter WIDTH = 1920,
    HEIGHT = 1080,
    COVER_HEIGHT = 540
) (
    input wire clk,
    rst_n,
    frame_start,
    frame_end,
    pixel_valid,
    input wire [31:0] source_frame_id,
    input wire [23:0] rgb,
    output reg out_valid,
    output reg [31:0] out_frame_id,
    output reg [19:0] out_index,
    output reg [15:0] out_counts,
    output reg frame_done,
    frame_good,
    output reg [31:0] done_frame_id
);
    localparam OW = WIDTH / 3, AW = (OW > 1) ? $clog2(OW) : 1;
    wire [8:0] r = {1'b0, rgb[23:16]}, g = {1'b0, rgb[15:8]}, b = {1'b0, rgb[7:0]};
    // 颜色阈值与区域统计模块一致。
    wire red = r >= 80 && r >= g + 9'd32 && r >= b + 9'd32;
    wire green=(g>=80 && g>=r+9'd24 && g>=b+9'd24) ||
 (g>=96 && g>=r+9'd32 && b>=r+9'd24 && b<=g+9'd24 &&
  g<=b+9'd24 && {r[7:0],1'b0}<=g);
    wire yellow = r >= 96 && g >= 80 && r >= b + 9'd32 && g >= b + 9'd32 && r < g + 9'd32 && g < r + 9'd24;
    reg active, bad;
    reg [31:0] fid;
    reg [21:0] count;
    reg [11:0] x, y;
    reg [1:0] xp, yp, hr, hg, hy;
    reg [AW-1:0] col;
    reg [  19:0] idx;
    reg v1, v2, first1, first2, last1, last2;
    reg [AW-1:0] a1, a2;
    reg [3:0] r1, g1, y1, r2, g2, y2;
    reg [19:0] i1, i2;
    reg [31:0] f1, f2;
    reg [11:0] partial[0:OW-1];
    reg [11:0] prev2;
    wire [3:0] sr = r2 + (first2 ? 4'd0 : prev2[3:0]);
    wire [3:0] sg = g2 + (first2 ? 4'd0 : prev2[7:4]);
    wire [3:0] sy = y2 + (first2 ? 4'd0 : prev2[11:8]);
    reg [3:0] eof_delay;
    reg good_pending;
    reg [31:0] done_pending;
    // 按列同步读取，同一列的两次访问至少间隔 WIDTH 个时钟。
    always @(posedge clk) begin
        if (v1) prev2 <= partial[a1];
        if (rst_n && v2 && !last2) partial[a2] <= {sy, sg, sr};
    end
    always @(posedge clk) begin
        if (!rst_n) begin
            active <= 0;
            bad <= 0;
            fid <= 0;
            count <= 0;
            x <= 0;
            y <= 0;
            xp <= 0;
            yp <= 0;
            hr <= 0;
            hg <= 0;
            hy <= 0;
            col <= 0;
            idx <= 0;
            v1 <= 0;
            v2 <= 0;
            first1 <= 0;
            first2 <= 0;
            last1 <= 0;
            last2 <= 0;
            a1 <= 0;
            a2 <= 0;
            r1 <= 0;
            g1 <= 0;
            y1 <= 0;
            r2 <= 0;
            g2 <= 0;
            y2 <= 0;
            i1 <= 0;
            i2 <= 0;
            f1 <= 0;
            f2 <= 0;
            out_valid <= 0;
            out_frame_id <= 0;
            out_index <= 0;
            out_counts <= 0;
            frame_done <= 0;
            frame_good <= 0;
            done_frame_id <= 0;
            eof_delay <= 0;
            good_pending <= 0;
            done_pending <= 0;
        end else begin
            v1 <= 0;
            v2 <= v1;
            out_valid <= v2 && last2;
            a2 <= a1;
            r2 <= r1;
            g2 <= g1;
            y2 <= y1;
            i2 <= i1;
            f2 <= f1;
            first2 <= first1;
            last2 <= last1;
            out_counts <= {4'd0, sy, sg, sr};
            out_index <= i2;
            out_frame_id <= f2;
            eof_delay <= {eof_delay[2:0], 1'b0};
            frame_done <= eof_delay[3];
            frame_good <= eof_delay[3] && good_pending;
            done_frame_id <= done_pending;
            if (frame_start) begin
                active <= 1;
                bad <= pixel_valid || frame_end;
                fid <= source_frame_id;
                count <= 0;
                x <= 0;
                y <= 0;
                xp <= 0;
                yp <= 0;
                col <= 0;
                idx <= 0;
                hr <= 0;
                hg <= 0;
                hy <= 0;
            end else if (frame_end) begin
                active <= 0;
                eof_delay <= 4'b0001;
                good_pending <= active && !bad && !pixel_valid && count == WIDTH * HEIGHT;
                done_pending <= fid;
            end else if (pixel_valid && active) begin
                if (count >= WIDTH * HEIGHT) bad <= 1;
                else begin
                    count <= count + 1'b1;
                    if (y < COVER_HEIGHT) begin
                        hr <= (xp == 0) ? {1'b0, red} : hr + {1'b0, red};
                        hg <= (xp == 0) ? {1'b0, green} : hg + {1'b0, green};
                        hy <= (xp == 0) ? {1'b0, yellow} : hy + {1'b0, yellow};
                        if (xp == 2) begin
                            v1 <= 1;
                            a1 <= col;
                            first1 <= yp == 0;
                            last1 <= yp == 2;
                            r1 <= {2'b0, hr} + {3'b0, red};
                            g1 <= {2'b0, hg} + {3'b0, green};
                            y1 <= {2'b0, hy} + {3'b0, yellow};
                            i1 <= idx;
                            f1 <= fid;
                            if (yp == 2) idx <= idx + 1'b1;
                        end
                    end
                    if (x == WIDTH - 1) begin
                        x   <= 0;
                        xp  <= 0;
                        col <= 0;
                        y   <= y + 1'b1;
                        yp  <= (yp == 2) ? 0 : yp + 1'b1;
                    end else begin
                        x  <= x + 1'b1;
                        xp <= (xp == 2) ? 0 : xp + 1'b1;
                        if (xp == 2) col <= col + 1'b1;
                    end
                end
            end
        end
    end
endmodule

`endif

`ifndef QIANSAI_V61_COLOR_PAIR_STREAM
`define QIANSAI_V61_COLOR_PAIR_STREAM
`timescale 1ns / 1ps
// 将原始 RGB888 颜色块与增强后的 640×360 图像按像素配对。
// 用小容量 FIFO 补偿流水线延迟，颜色块缺失时不补造数据。
module color_pair_stream #(
    parameter WIDTH = 1920,
    HEIGHT = 1080,
    FIFO_AW = 6
) (
    input clk,
    rst_n,
    raw_vs,
    raw_de,
    input [23:0] raw_rgb,
    input image_vs,
    image_valid,
    input [15:0] image_data,
    output reg pair_vs,
    pair_valid,
    output reg [31:0] pair_data,
    output reg [31:0] pair_errors
);
    localparam OW = WIDTH / 3, OH = HEIGHT / 3, TOTAL = WIDTH * HEIGHT, WORDS = OW * OH, COVER = OW * (OH / 2);
    reg raw_vs_d, raw_ended;
    reg [21:0] raw_count;
    reg [31:0] fid, image_fid;
    wire sof = raw_vs && !raw_vs_d;
    wire eof = (raw_count == TOTAL) && !raw_de && !raw_ended;
    wire cv, cd, cg;
    wire [31:0] cf, df;
    wire [19:0] ci;
    wire [15:0] cc;
    color_count_3x3 #(
        .WIDTH(WIDTH),
        .HEIGHT(HEIGHT),
        .COVER_HEIGHT(HEIGHT)
    ) counts (
        .clk(clk),
        .rst_n(rst_n),
        .frame_start(sof),
        .frame_end(eof),
        .pixel_valid(raw_de),
        .source_frame_id(fid + 32'd1),
        .rgb(raw_rgb),
        .out_valid(cv),
        .out_frame_id(cf),
        .out_index(ci),
        .out_counts(cc),
        .frame_done(cd),
        .frame_good(cg),
        .done_frame_id(df)
    );
    reg [67:0] fifo[0:(1<<FIFO_AW)-1];
    reg [FIFO_AW:0] wp, rp;
    wire empty = wp == rp;
    wire full = (wp[FIFO_AW] != rp[FIFO_AW]) && (wp[FIFO_AW-1:0] == rp[FIFO_AW-1:0]);
    wire [67:0] head = fifo[rp[FIFO_AW-1:0]];
    reg [19:0] index;
    reg bad, raw_good;
    reg [15:0] color_word;
    wire match_head = !empty && head[67:36] == image_fid && head[35:16] == index;
    wire [4:0] nibble_shift = {index[2:0], 2'b00};
    always @* begin
        color_word = (index < COVER) ? {4'd0, head[11:0]} : 16'd0;
        // 重复写入帧号片段，供 RK 检查帧块是否混合。
        color_word[15:12] = (image_fid >> nibble_shift);
        if (index == COVER) color_word = 16'hcf61;
        if (index == COVER + 1) color_word = 16'h0001;
        if (index == COVER + 2) color_word = image_fid[15:0];
        if (index == COVER + 3) color_word = image_fid[31:16];
        if (index == COVER + 4) color_word = OW;
        if (index == COVER + 5) color_word = OH / 2;
        if (index == WORDS - 4) color_word = 16'h61cf;
        if (index == WORDS - 3) color_word = image_fid[15:0];
        if (index == WORDS - 2) color_word = image_fid[31:16];
        if (index == WORDS - 1) color_word = (!bad && match_head && raw_good) ? 16'ha55a : 16'hdead;
        if (bad || !match_head) color_word = 16'hffff;
    end
    always @(posedge clk) begin
        if (!rst_n) begin
            raw_vs_d <= 0;
            raw_ended <= 1;
            raw_count <= 0;
            fid <= 0;
            image_fid <= 0;
            wp <= 0;
            rp <= 0;
            index <= 0;
            bad <= 0;
            raw_good <= 0;
            pair_vs <= 0;
            pair_valid <= 0;
            pair_data <= 0;
            pair_errors <= 0;
        end else begin
            raw_vs_d <= raw_vs;
            pair_vs <= image_vs;
            pair_valid <= image_valid && !image_vs;
            pair_data <= {color_word, image_data};
            if (sof) begin
                fid <= fid + 1'b1;
                raw_count <= 0;
                raw_ended <= 0;
                wp <= 0;
                rp <= 0;
                bad <= 0;
                raw_good <= 0;
            end else begin
                if (raw_de && !raw_ended) begin
                    if (raw_count < TOTAL) raw_count <= raw_count + 1'b1;
                    else begin
                        bad <= 1;
                        pair_errors <= pair_errors + 1'b1;
                    end
                end
                if (eof) raw_ended <= 1;
                if (cd) raw_good <= cg && df == fid;
                if (raw_de && raw_ended) begin
                    bad <= 1;
                    raw_good <= 0;
                    pair_errors <= pair_errors + 1'b1;
                end
                if (cv) begin
                    if (!full) begin
                        fifo[wp[FIFO_AW-1:0]] <= {cf, ci, cc};
                        wp <= wp + 1'b1;
                    end else begin
                        bad <= 1;
                        pair_errors <= pair_errors + 1'b1;
                    end
                end
                if (image_valid && !image_vs) begin
                    index <= index + 1'b1;
                    if (!empty) rp <= rp + 1'b1;
                    if (!match_head || index >= WORDS) begin
                        bad <= 1;
                        pair_errors <= pair_errors + 1'b1;
                    end
                end
            end
            if (image_vs) begin
                image_fid <= fid;
                index <= 0;
            end
        end
    end
endmodule

`endif

`ifndef QIANSAI_V61_PAIR_FIFO_32TO128
`define QIANSAI_V61_PAIR_FIFO_32TO128
`timescale 1ns / 1ps
// 每条记录包含颜色统计 16 位和图像 16 位，每个 DDR 字存放四条记录。
// 各时钟域的复位同步由 frame_read_write_256_burst 提供。
module pair_fifo_32to128 #(
    parameter AW = 9
) (
    input wr_clk,
    wr_rst,
    wr_en,
    input [31:0] wr_data,
    output wire wr_full,
    input rd_clk,
    rd_rst,
    rd_en,
    output reg [127:0] rd_data,
    output wire [9:0] rd_water_level
);
    reg [127:0] mem  [0:(1<<AW)-1];
    reg [ 95:0] pack;
    reg [  1:0] lane;
    reg [AW:0] wp, wg, rp, rg;
    (* ASYNC_REG="TRUE" *) reg [AW:0] rg1, rg2, wg1, wg2;
    wire [AW:0] next_wp = wp + 1'b1;
    wire [AW:0] next_wg = (next_wp >> 1) ^ next_wp;
    assign wr_full = (wg == {~rg2[AW:AW-1], rg2[AW-2:0]});
    function [AW:0] ungray(input [AW:0] v);
        integer j;
        begin
            ungray[AW] = v[AW];
            for (j = AW - 1; j >= 0; j = j - 1) ungray[j] = ungray[j+1] ^ v[j];
        end
    endfunction
    assign rd_water_level = ungray(wg2) - rp;
    always @(posedge wr_clk or posedge wr_rst) begin
        if (wr_rst) begin
            wp   <= 0;
            wg   <= 0;
            rg1  <= 0;
            rg2  <= 0;
            lane <= 0;
            pack <= 0;
        end else begin
            rg1 <= rg;
            rg2 <= rg1;
            if (wr_en && !wr_full) begin
                lane <= lane + 1'b1;
                case (lane)
                    0: pack[31:0] <= wr_data;
                    1: pack[63:32] <= wr_data;
                    2: pack[95:64] <= wr_data;
                    3: begin
                        mem[wp[AW-1:0]] <= {wr_data, pack};
                        wp <= next_wp;
                        wg <= next_wg;
                    end
                endcase
            end
        end
    end
    always @(posedge rd_clk or posedge rd_rst) begin
        if (rd_rst) begin
            rp <= 0;
            rg <= 0;
            wg1 <= 0;
            wg2 <= 0;
            rd_data <= 0;
        end else begin
            wg1 <= wg;
            wg2 <= wg1;
            if (rd_en && rd_water_level != 0) begin
                rd_data <= mem[rp[AW-1:0]];
                rp <= rp + 1'b1;
                rg <= ((rp + 1'b1) >> 1) ^ (rp + 1'b1);
            end
        end
    end
endmodule

`endif

`ifndef QIANSAI_V61_PROTECTED_FRAME_WRITER
`define QIANSAI_V61_PROTECTED_FRAME_WRITER
`timescale 1ns / 1ps
// 四帧缓存轮转写入，跳过 DDR 读端正在占用的缓存。
// 读端占用期间保持缓存编号，经过两级同步后再参与轮转判断。
module protected_frame_writer (
    input rst,
    pclk,
    vsync,
    write_req_ack,
    input read_locked,
    input [1:0] read_bank,
    output reg write_req,
    output reg [1:0] write_bank,
    input published_valid,
    input [1:0] published_bank
);
    reg vs_d;
    (* ASYNC_REG="TRUE" *) reg ack1, ack2, lock1, lock2;
    (* ASYNC_REG="TRUE" *) reg [1:0] bank1, bank2;
    (* ASYNC_REG="TRUE" *) reg pub1, pub2;
    (* ASYNC_REG="TRUE" *) reg [1:0] pb1, pb2;
    wire [1:0] next_bank = write_bank + 2'd1;
    wire [1:0] next2 = write_bank + 2'd2, next3 = write_bank + 2'd3;
    wire busy1 = (lock2 && next_bank == bank2) || (pub2 && next_bank == pb2);
    wire busy2 = (lock2 && next2 == bank2) || (pub2 && next2 == pb2);
    always @(posedge pclk or posedge rst) begin
        if (rst) begin
            vs_d <= 0;
            ack1 <= 0;
            ack2 <= 0;
            lock1 <= 0;
            lock2 <= 0;
            bank1 <= 0;
            bank2 <= 0;
            write_req <= 0;
            write_bank <= 0;
            pub1 <= 0;
            pub2 <= 0;
            pb1 <= 0;
            pb2 <= 0;
        end else begin
            vs_d  <= vsync;
            ack1  <= write_req_ack;
            ack2  <= ack1;
            lock1 <= read_locked;
            lock2 <= lock1;
            bank1 <= read_bank;
            bank2 <= bank1;
            pub1  <= published_valid;
            pub2  <= pub1;
            pb1   <= published_bank;
            pb2   <= pb1;
            if (vsync && !vs_d) begin
                write_req  <= 1;
                write_bank <= !busy1 ? next_bank : (!busy2 ? next2 : next3);
            end else if (ack2) write_req <= 0;
        end
    end
endmodule

`endif
