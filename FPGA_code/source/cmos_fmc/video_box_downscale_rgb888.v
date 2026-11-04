`timescale 1ns / 1ps

module video_box_downscale_rgb888 #(
    parameter INPUT_WIDTH = 1920,
    INPUT_HEIGHT = 1080,
    DIV = 3
) (
    input clk,
    input rst_n,
    input frame_sync,
    input in_valid,
    input [23:0] in_data,
    output reg out_frame_sync,
    output reg out_valid,
    output reg [15:0] out_data,
    output reg frame_complete
);
    // 模块间连线与横向累加隔开，像素及有效信号同步增加一级输入寄存。
    // 像素、场同步及有效信号使用相同的一级输入延迟。
    (* syn_preserve=1 *) reg [23:0] sample_data;
    (* syn_preserve=1 *) reg sample_valid, sample_frame_sync;
    always @(posedge clk) begin
        if (!rst_n) begin
            sample_data <= 0;
            sample_valid <= 0;
            sample_frame_sync <= 0;
        end else begin
            sample_data <= in_data;
            sample_valid <= in_valid;
            sample_frame_sync <= frame_sync;
        end
    end

    localparam OUT_WIDTH = INPUT_WIDTH / DIV;
    localparam AW = (OUT_WIDTH > 1) ? $clog2(OUT_WIDTH) : 1;
    reg vs_d, armed;
    reg [11:0] x;
    reg [10:0] y;
    reg [1:0] xp, yp;
    reg [AW-1:0] column;
    // 三通道分别累加：横向和不超过 765，前两行和不超过 1530，九点和不超过 2295。

    reg [9:0] hr, hg, hb;
    reg start1, valid1, first1, last1, end1;
    reg [AW-1:0] addr1;
    reg [9:0] r1, g1, b1;
    reg start2, valid2, first2, last2, end2;
    reg [AW-1:0] addr2;
    reg [9:0] r2, g2, b2;
    reg [32:0] partial_mem[0:OUT_WIDTH-1];
    reg [32:0] partial2;
    wire [11:0] sum_r = {2'b0, r2} + (first2 ? 12'd0 : {1'b0, partial2[32:22]});
    wire [11:0] sum_g = {2'b0, g2} + (first2 ? 12'd0 : {1'b0, partial2[21:11]});
    wire [11:0] sum_b = {2'b0, b2} + (first2 ? 12'd0 : {1'b0, partial2[10:0]});
    reg start3, valid3, end3;
    reg [11:0] r3, g3, b3;
    reg start_round, valid_round, end_round;
    reg [11:0] nr_round, ng_round, nb_round;
    reg start_mul, valid_mul, end_mul;
    reg [11:0] nr_mul, ng_mul, nb_mul;
    reg [14:0] seven_r, seven_g, seven_b;
    reg start4, valid4, end4;
    reg [11:0] nr4, ng4, nb4;
    reg [20:0] pr4, pg4, pb4;
    wire [11:0] nr = r3 + ((DIV == 3) ? 12'd4 : 12'd2);
    wire [11:0] ng = g3 + ((DIV == 3) ? 12'd4 : 12'd2);
    wire [11:0] nb = b3 + ((DIV == 3) ? 12'd4 : 12'd2);
    reg start5, valid5, end5;
    reg [8:0] r5, g5, b5;
    reg correct_r5, correct_g5, correct_b5;
    wire [8:0] qr = r5 - {8'b0, correct_r5};
    wire [8:0] qg = g5 - {8'b0, correct_g5};
    wire [8:0] qb = b5 - {8'b0, correct_b5};
    // 0～2299 范围内精确计算向下取整的 n/9，倒数系数为 456/4096。
    // 近似结果最多偏大 1，在量化前修正。
    function automatic needs_correction;
        input [20:0] product;
        input [11:0] numerator;
        reg [ 8:0] approx;
        reg [12:0] times9;
        begin
            approx = product[20:12];
            times9 = ({4'b0, approx} << 3) + {4'b0, approx};
            needs_correction = (times9 > {1'b0, numerator});
        end
    endfunction

    // 同步读写且不整体复位，以推导小容量简单双口 RAM。
    // 同一列的相邻访问间隔一整行。
    always @(posedge clk) begin
        if (valid1) partial2 <= partial_mem[addr1];
        if (rst_n && valid2 && !last2) partial_mem[addr2] <= {sum_r[10:0], sum_g[10:0], sum_b[10:0]};
    end

    always @(posedge clk) begin
        if (!rst_n) begin
            vs_d <= 0;
            armed <= 0;
            x <= 0;
            y <= 0;
            xp <= 0;
            yp <= 0;
            column <= 0;
            hr <= 0;
            hg <= 0;
            hb <= 0;
            start1 <= 0;
            valid1 <= 0;
            first1 <= 0;
            last1 <= 0;
            end1 <= 0;
            addr1 <= 0;
            r1 <= 0;
            g1 <= 0;
            b1 <= 0;
            start2 <= 0;
            valid2 <= 0;
            first2 <= 0;
            last2 <= 0;
            end2 <= 0;
            addr2 <= 0;
            r2 <= 0;
            g2 <= 0;
            b2 <= 0;
            start3 <= 0;
            valid3 <= 0;
            end3 <= 0;
            r3 <= 0;
            g3 <= 0;
            b3 <= 0;
            start_round <= 0;
            valid_round <= 0;
            end_round <= 0;
            nr_round <= 0;
            ng_round <= 0;
            nb_round <= 0;
            start_mul <= 0;
            valid_mul <= 0;
            end_mul <= 0;
            nr_mul <= 0;
            ng_mul <= 0;
            nb_mul <= 0;
            seven_r <= 0;
            seven_g <= 0;
            seven_b <= 0;
            start4 <= 0;
            valid4 <= 0;
            end4 <= 0;
            nr4 <= 0;
            ng4 <= 0;
            nb4 <= 0;
            pr4 <= 0;
            pg4 <= 0;
            pb4 <= 0;
            start5 <= 0;
            valid5 <= 0;
            end5 <= 0;
            r5 <= 0;
            g5 <= 0;
            b5 <= 0;
            correct_r5 <= 0;
            correct_g5 <= 0;
            correct_b5 <= 0;
            out_frame_sync <= 0;
            out_valid <= 0;
            out_data <= 0;
            frame_complete <= 0;
        end else begin
            vs_d <= sample_frame_sync;
            start1 <= sample_frame_sync && !vs_d;
            valid1 <= 0;
            // 每周期寄存数据，仅在 valid1 有效时使用。
            // 避免帧沿及坐标译码扇出到所有数据寄存器的时钟使能。
            addr1 <= column;
            r1 <= hr + {2'b0, sample_data[23:16]};
            g1 <= hg + {2'b0, sample_data[15:8]};
            b1 <= hb + {2'b0, sample_data[7:0]};
            first1 <= (yp == 0);
            last1 <= (yp == DIV - 1);
            end1 <= (x == INPUT_WIDTH - 1 && y == INPUT_HEIGHT - 1);
            // 新帧仅重置采集状态，已接收像素先于新帧标记排空，包括末像素。
            if (sample_frame_sync && !vs_d) begin
                armed <= 1;
                x <= 0;
                y <= 0;
                xp <= 0;
                yp <= 0;
                column <= 0;
                hr <= 0;
                hg <= 0;
                hb <= 0;
            end else if (sample_valid && armed) begin
                if (xp == 0) begin
                    hr <= {2'b0, sample_data[23:16]};
                    hg <= {2'b0, sample_data[15:8]};
                    hb <= {2'b0, sample_data[7:0]};
                end else begin
                    hr <= hr + {2'b0, sample_data[23:16]};
                    hg <= hg + {2'b0, sample_data[15:8]};
                    hb <= hb + {2'b0, sample_data[7:0]};
                end
                if (xp == DIV - 1) begin
                    valid1 <= 1;
                    column <= column + 1'b1;
                end
                if (x == INPUT_WIDTH - 1) begin
                    x <= 0;
                    xp <= 0;
                    column <= 0;
                    if (y == INPUT_HEIGHT - 1) begin
                        y <= 0;
                        yp <= 0;
                        armed <= 0;
                    end else begin
                        y  <= y + 1'b1;
                        yp <= (yp == DIV - 1) ? 2'd0 : yp + 1'b1;
                    end
                end else begin
                    x  <= x + 1'b1;
                    xp <= (xp == DIV - 1) ? 2'd0 : xp + 1'b1;
                end
            end

            start2 <= start1;
            valid2 <= valid1;
            addr2 <= addr1;
            r2 <= r1;
            g2 <= g1;
            b2 <= b1;
            first2 <= first1;
            last2 <= last1;
            end2 <= end1;
            start3 <= start2;
            valid3 <= valid2 && last2;
            end3 <= end2;
            r3 <= sum_r;
            g3 <= sum_g;
            b3 <= sum_b;
            // 全精度舍入与倒数乘法分级处理。
            start_round <= start3;
            valid_round <= valid3;
            end_round <= end3;
            nr_round <= nr;
            ng_round <= ng;
            nb_round <= nb;
            // 456×n=512×n−8×(7×n)，各进位链分别寄存，避免单周期级联。
            start_mul <= start_round;
            valid_mul <= valid_round;
            end_mul <= end_round;
            nr_mul <= nr_round;
            ng_mul <= ng_round;
            nb_mul <= nb_round;
            if (DIV == 3) begin
                seven_r <= ({3'b0, nr_round} << 3) - {3'b0, nr_round};
                seven_g <= ({3'b0, ng_round} << 3) - {3'b0, ng_round};
                seven_b <= ({3'b0, nb_round} << 3) - {3'b0, nb_round};
            end else begin
                seven_r <= 0;
                seven_g <= 0;
                seven_b <= 0;
            end
            start4 <= start_mul;
            valid4 <= valid_mul;
            end4 <= end_mul;
            nr4 <= nr_mul;
            ng4 <= ng_mul;
            nb4 <= nb_mul;
            if (DIV == 3) begin
                pr4 <= ({9'b0, nr_mul} << 9) - ({6'b0, seven_r} << 3);
                pg4 <= ({9'b0, ng_mul} << 9) - ({6'b0, seven_g} << 3);
                pb4 <= ({9'b0, nb_mul} << 9) - ({6'b0, seven_b} << 3);
            end else begin
                pr4 <= {9'b0, nr_mul} >> 2;
                pg4 <= {9'b0, ng_mul} >> 2;
                pb4 <= {9'b0, nb_mul} >> 2;
            end
            start5 <= start4;
            valid5 <= valid4;
            end5   <= end4;
            if (DIV == 3) begin
                r5 <= pr4[20:12];
                g5 <= pg4[20:12];
                b5 <= pb4[20:12];
                correct_r5 <= needs_correction(pr4, nr4);
                correct_g5 <= needs_correction(pg4, ng4);
                correct_b5 <= needs_correction(pb4, nb4);
            end else begin
                r5 <= pr4[8:0];
                g5 <= pg4[8:0];
                b5 <= pb4[8:0];
                correct_r5 <= 0;
                correct_g5 <= 0;
                correct_b5 <= 0;
            end
            out_frame_sync <= start5;
            out_valid <= valid5;
            frame_complete <= valid5 && end5;
            if (valid5) begin
                out_data <= {qr[7:3], qg[7:2], qb[7:3]};
            end
        end
    end
endmodule
