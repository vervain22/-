//---------------------------------------------------

// Copyright (c) 2019 PANGO MICROSYSTEMS, INC
// ALL RIGHTS REVERVED.

// THE SOURCE CODE CONTAINED HEREIN IS PROPRIETARY TO PANGO MICROSYSTEMS, INC.
// IT SHALL NOT BE REPRODUCED OR DISCLOSED IN WHOLE OR IN PART OR USED BY
// PARTIES WITHOUT WRITTEN AUTHORIZATION FROM THE OWNER.

//---------------------------------------------------

//---------------------------------------------------
`timescale 1ns / 1ps
module ipm2l_hsstlp_rst_wtchdg_v1_0 #(
    parameter ACTIVE_HIGH        = 0,   // 有效电平：0 低有效，1 高有效。
    parameter WTCHDG_CNTR1_WIDTH = 10,  // 一级看门狗计数长度：2^(WTCHDG_CNTR1_WIDTH−1)=512。
    parameter WTCHDG_CNTR2_WIDTH = 10   // 看门狗超时长度为两级计数周期乘积，默认 256K 周期。
                                        // 看门狗复位持续 2^(WTCHDG_CNTR1_WIDTH−1) 个周期。
) (
    input  wire         clk,
    input  wire         rst_n,
    input  wire         wtchdg_clr,
    input  wire         wtchdg_in,
    output reg          wtchdg_rst_n,
    output reg  [1 : 0] wtchdg_st
);

    wire                          wtchdg_in_mux;
    reg  [WTCHDG_CNTR1_WIDTH-1:0] cnt_1;
    reg  [WTCHDG_CNTR2_WIDTH-1:0] cnt_2;

    assign wtchdg_in_mux = (ACTIVE_HIGH == 1'b1) ? ~wtchdg_in : wtchdg_in;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt_1 <= {WTCHDG_CNTR1_WIDTH{1'b0}};
        end else if (cnt_1[WTCHDG_CNTR1_WIDTH-1] | wtchdg_in_mux | wtchdg_clr) begin
            cnt_1 <= {WTCHDG_CNTR1_WIDTH{1'b0}};
        end else begin
            cnt_1 <= cnt_1 + {{(WTCHDG_CNTR1_WIDTH - 1) {1'b0}}, 1'b1};
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt_2 <= {WTCHDG_CNTR2_WIDTH{1'b0}};
        end else if (wtchdg_clr | wtchdg_in_mux | (cnt_2[WTCHDG_CNTR2_WIDTH-1] & cnt_2[0])) begin
            cnt_2 <= {WTCHDG_CNTR2_WIDTH{1'b0}};
        end else if (cnt_1[WTCHDG_CNTR1_WIDTH-1]) begin
            cnt_2 <= cnt_2 + {{(WTCHDG_CNTR2_WIDTH - 1) {1'b0}}, 1'b1};
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wtchdg_rst_n <= 1'b1;
        end else if (cnt_2[WTCHDG_CNTR2_WIDTH-1]) begin
            wtchdg_rst_n <= 1'b0;
        end else begin
            wtchdg_rst_n <= 1'b1;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) wtchdg_st <= 2'b0;
        else if (wtchdg_in_mux | wtchdg_clr) wtchdg_st <= 2'b0;
        else if (cnt_2[WTCHDG_CNTR2_WIDTH-1]) wtchdg_st <= 2'b10;
        else wtchdg_st <= 2'b01;
    end

endmodule
