//---------------------------------------------------
// Copyright (c) 2015 PANGO MICROSYSTEMS, INC
// ALL RIGHTS REVERVED.
//---------------------------------------------------

`timescale 1ns / 1ps

module pgs_pciex4_prefetch_fifo_v1_2 #(
    parameter D = 16,  // 取值应为 2 的整数次幂。
    parameter W = 8,
    parameter TYPE = "Distributed"  // 存储资源类型：分布式 RAM 或 DRM。
) (
    input clk,
    input rst_n,

    input          data_in_valid,
    input  [W-1:0] data_in,
    output         data_in_ready,

    input          data_out_ready,
    output [W-1:0] data_out,
    output         data_out_valid
);

    //---------------------------------------------------
    // 类型、延迟、地址宽度及数据宽度
    // 分布式 RAM：延迟 2 周期，地址宽度 4～10，数据宽度 1～256。
    // DRM：延迟 3 周期，地址宽度 9～20，数据宽度 1～1152。
    //---------------------------------------------------

    reg          fifo_vld;
    reg          rd_en_ff1;
    reg  [  2:0] shift_vld;
    reg  [W-1:0] rd_data_ff1;

    wire [W-1:0] rd_data;
    wire         pop;
    wire         wr_en;
    wire         rd_en;
    wire         empty;
    wire         full;
    wire         rst;

    assign wr_en = data_in_valid & ~full;
    assign data_in_ready = ~full;
    assign rst = ~rst_n;

    generate
        if (TYPE == "Distributed") // 分布式 RAM
begin
            localparam DEPTH = (D < 16) ? 16 : D;
            assign rd_en = ~empty & (~data_out_valid | data_out_ready);
            assign data_out_valid = fifo_vld;
            always @(posedge clk or negedge rst_n) begin
                if (!rst_n) fifo_vld <= 1'b0;
                else if (rd_en) fifo_vld <= 1'b1;
                else if (data_out_ready) fifo_vld <= 1'b0;
            end

            assign data_out = rd_data_ff1;
            always @(posedge clk or negedge rst_n) begin
                if (!rst_n) rd_data_ff1 <= 1'b0;
                else if (rd_en) rd_data_ff1 <= rd_data;
            end

            pgs_pciex4_fifo_v1_2 #(
                .DATA_WIDTH(W),
                .ADDR_WIDTH(log2(DEPTH)),
                .OUT_REG   (0)
            ) pgs_pciex4_fifo (
                .clk    (clk),
                .rst_n  (rst_n),
                .wr_data(data_in),
                .wr_en  (wr_en),
                .full   (full),
                .rd_data(rd_data),
                .rd_en  (rd_en),
                .empty  (empty)
            );
        end else  // 块存储资源
        begin
            localparam DEPTH = (D < 512) ? 512 : D;
            assign rd_en = (~shift_vld[2] | data_out_ready) & ~empty;
            always @(posedge clk or negedge rst_n) begin
                if (!rst_n) rd_en_ff1 <= 1'b0;
                else rd_en_ff1 <= rd_en;
            end

            assign pop = data_out_valid & data_out_ready;
            always @(posedge clk or negedge rst_n) begin
                if (!rst_n) shift_vld <= 3'b001;
                else begin
                    case ({
                        rd_en, pop
                    })
                        2'b10: shift_vld <= {shift_vld[1:0], shift_vld[2]};
                        2'b01: shift_vld <= {shift_vld[0], shift_vld[2:1]};
                    endcase
                end
            end

            // 块存储 FIFO
            pgm_fifo_v1_2 #(
                .c_RD_DATA_WIDTH (W),
                .c_WR_DEPTH_WIDTH(log2(DEPTH)),
                .c_WR_DATA_WIDTH (W),
                .c_RD_DEPTH_WIDTH(log2(DEPTH)),
                .c_OUTPUT_REG    (0)
            ) pgm_fifo_v1_2 (
                .wr_data       (data_in),
                .wr_en         (wr_en),
                .wr_clk        (clk),
                .wr_full       (full),
                .wr_rst        (rst),
                .wr_byte_en    (8'b0),
                .almost_full   (),
                .wr_water_level(),
                .rd_data       (rd_data),
                .rd_en         (rd_en),
                .rd_clk        (clk),
                .rd_empty      (empty),
                .rd_rst        (rst),
                .rd_oce        (1'b1),
                .almost_empty  (),
                .rd_water_level()
            );

            // 深度为 2
            pgs_pciex4_reg_fifo2_v1_2 #(
                .W(W)
            ) pgs_pciex4_reg_fifo2 (
                .clk           (clk),
                .rst_n         (rst_n),
                .data_in_valid (rd_en_ff1),
                .data_in       (rd_data),
                .data_in_ready (),
                .data_out_ready(data_out_ready),
                .data_out      (data_out),
                .data_out_valid(data_out_valid)
            );

        end
    endgenerate

    // 以 2 为底的对数
    function integer log2;
        input integer dep;
        begin
            log2 = 0;
            while (dep > 1) begin
                dep  = dep >> 1;
                log2 = log2 + 1;
            end
        end
    endfunction

endmodule
