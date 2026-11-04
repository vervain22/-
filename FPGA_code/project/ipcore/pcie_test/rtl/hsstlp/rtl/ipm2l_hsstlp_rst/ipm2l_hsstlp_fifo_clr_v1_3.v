//---------------------------------------------------

// Copyright (c) 2019 PANGO MICROSYSTEMS, INC
// ALL RIGHTS REVERVED.

// THE SOURCE CODE CONTAINED HEREIN IS PROPRIETARY TO PANGO MICROSYSTEMS, INC.
// IT SHALL NOT BE REPRODUCED OR DISCLOSED IN WHOLE OR IN PART OR USED BY
// PARTIES WITHOUT WRITTEN AUTHORIZATION FROM THE OWNER.

//---------------------------------------------------

//---------------------------------------------------
`timescale 1ns / 1ps
module ipm2l_hsstlp_fifo_clr_v1_3 #(
    parameter CH0_RX_ENABLE          = "TRUE",   // 通道 0 接收复位逻辑使能。
    parameter CH1_RX_ENABLE          = "TRUE",   // 通道 1 接收复位逻辑使能。
    parameter CH2_RX_ENABLE          = "TRUE",   // 通道 2 接收复位逻辑使能。
    parameter CH3_RX_ENABLE          = "TRUE",   // 通道 3 接收复位逻辑使能。
    parameter CH0_MULT_LANE_MODE     = 1,        // 通道 0 配置：1 单通道，2 双通道，4 四通道。
    parameter CH1_MULT_LANE_MODE     = 1,        // 通道 1 配置：1 单通道，2 双通道，4 四通道。
    parameter CH2_MULT_LANE_MODE     = 1,        // 通道 2 配置：1 单通道，2 双通道，4 四通道。
    parameter CH3_MULT_LANE_MODE     = 1,        // 通道 3 配置：1 单通道，2 双通道，4 四通道。
    parameter PCS_CH0_BYPASS_BONDING = "FALSE",  // 通道 0 通道绑定旁路使能。
    parameter PCS_CH1_BYPASS_BONDING = "FALSE",  // 通道 1 通道绑定旁路使能。
    parameter PCS_CH2_BYPASS_BONDING = "FALSE",  // 通道 2 通道绑定旁路使能。
    parameter PCS_CH3_BYPASS_BONDING = "FALSE"   // 通道 3 通道绑定旁路使能。

) (
    // 时钟与复位
    input  wire         clk,
    input  wire [3 : 0] rst_n,
    input  wire         i_hsstlp_fifo_clr_0,
    input  wire         i_hsstlp_fifo_clr_1,
    input  wire         i_hsstlp_fifo_clr_2,
    input  wire         i_hsstlp_fifo_clr_3,
    // HSST 复位控制信号
    input  wire [3 : 0] cdr_align,
    input  wire [3 : 0] rxlane_done,
    output wire [3 : 0] fifo_clr_en
);

    //---------------------------------------------------
    // 内部信号
    //---------------------------------------------------
    reg  [3 : 0] cdr_align_lock;
    wire [3 : 0] cdr_align_vld;
    reg  [3 : 0] cdr_align_vld_ff1;
    wire [3 : 0] cdr_align_vld_pos;
    wire [3 : 0] i_hsstlp_fifo_clr;
    wire         rxlane0_rstn;
    wire         rxlane2_rstn;
    reg  [3 : 0] tx_fifo_clr_en;

    //---------------------------------------------------
    // 时序与组合逻辑
    //---------------------------------------------------
    assign rxlane0_rstn      = rst_n[0];  // 通道 0 绑定时使用的主通道复位端口
    assign rxlane2_rstn      = rst_n[2];  // 通道 2 绑定时使用的主通道复位端口
    assign cdr_align_vld[0]  = (CH0_RX_ENABLE == "TRUE") ? cdr_align[0] : 1'b0;
    assign cdr_align_vld[1]  = (CH1_RX_ENABLE == "TRUE") ? cdr_align[1] : 1'b0;
    assign cdr_align_vld[2]  = (CH2_RX_ENABLE == "TRUE") ? cdr_align[2] : 1'b0;
    assign cdr_align_vld[3]  = (CH3_RX_ENABLE == "TRUE") ? cdr_align[3] : 1'b0;
    assign i_hsstlp_fifo_clr = {i_hsstlp_fifo_clr_3, i_hsstlp_fifo_clr_2, i_hsstlp_fifo_clr_1, i_hsstlp_fifo_clr_0};

    assign cdr_align_vld_pos = cdr_align_vld & (~cdr_align_vld_ff1);

    genvar i;
    generate
        for (i = 0; i < 4; i = i + 1) begin : CDR_LOCK
            always @(posedge clk or negedge rst_n[i]) begin
                if (!rst_n[i]) cdr_align_vld_ff1[i] <= 4'b0;
                else cdr_align_vld_ff1[i] <= cdr_align_vld[i];
            end
            always @(posedge clk or negedge rst_n[i]) begin
                if (!rst_n[i]) cdr_align_lock[i] <= 1'b0;
                else if (fifo_clr_en[i] == 1'b1) cdr_align_lock[i] <= 1'b0;
                else if (cdr_align_vld_pos[i] == 1'b1) cdr_align_lock[i] <= 1'b1;
                else;
            end
        end
    endgenerate

    generate
        if (CH0_MULT_LANE_MODE == 4) begin : FOUR_LANE_MODE
            // 生成清零使能
            always @(posedge clk or negedge rxlane0_rstn) begin
                if (!rxlane0_rstn) tx_fifo_clr_en <= 4'b0;
                else if (PCS_CH0_BYPASS_BONDING == "TRUE") tx_fifo_clr_en <= i_hsstlp_fifo_clr;
                else if ((|cdr_align_lock) && (&rxlane_done)) tx_fifo_clr_en <= 4'b1111;
                else tx_fifo_clr_en <= 4'b0;
            end

            assign fifo_clr_en = tx_fifo_clr_en;
        end else if (CH0_MULT_LANE_MODE == 2 && CH2_MULT_LANE_MODE == 2) begin : TWO_LANE_MODE
            // 生成清零使能
            always @(posedge clk or negedge rxlane0_rstn) begin
                if (!rxlane0_rstn) tx_fifo_clr_en[1:0] <= 2'b0;
                else if (PCS_CH0_BYPASS_BONDING == "TRUE") tx_fifo_clr_en[1:0] <= i_hsstlp_fifo_clr[1:0];
                else if ((|cdr_align_lock[1:0]) && (&rxlane_done[1:0])) tx_fifo_clr_en[1:0] <= 2'b11;
                else tx_fifo_clr_en[1:0] <= 2'b0;
            end

            // 生成清零使能
            always @(posedge clk or negedge rxlane2_rstn) begin
                if (!rxlane2_rstn) tx_fifo_clr_en[3:2] <= 2'b0;
                else if (PCS_CH2_BYPASS_BONDING == "TRUE") tx_fifo_clr_en[3:2] <= i_hsstlp_fifo_clr[3:2];
                else if ((|cdr_align_lock[3:2]) && (&rxlane_done[3:2])) tx_fifo_clr_en[3:2] <= 2'b11;
                else tx_fifo_clr_en[3:2] <= 2'b0;
            end

            assign fifo_clr_en = tx_fifo_clr_en;
        end else if (CH0_MULT_LANE_MODE == 2) begin : TWO_LANE_MODE0
            // 生成清零使能
            always @(posedge clk or negedge rxlane0_rstn) begin
                if (!rxlane0_rstn) tx_fifo_clr_en <= 4'b0000;
                else if (PCS_CH0_BYPASS_BONDING == "TRUE") tx_fifo_clr_en <= {2'b00, i_hsstlp_fifo_clr[1:0]};
                else if ((|cdr_align_lock[1:0]) && (&rxlane_done[1:0])) tx_fifo_clr_en <= 4'b0011;
                else tx_fifo_clr_en <= 4'b0000;
            end

            assign fifo_clr_en = tx_fifo_clr_en;
        end else if (CH2_MULT_LANE_MODE == 2) begin : TWO_LANE_MODE1
            // 生成清零使能
            always @(posedge clk or negedge rxlane2_rstn) begin
                if (!rxlane2_rstn) tx_fifo_clr_en <= 4'b0000;
                else if (PCS_CH2_BYPASS_BONDING == "TRUE") tx_fifo_clr_en <= {i_hsstlp_fifo_clr[3:2], 2'b00};
                else if ((|cdr_align_lock[3:2]) && (&rxlane_done[3:2])) tx_fifo_clr_en <= 4'b1100;
                else tx_fifo_clr_en <= 4'b0000;
            end

            assign fifo_clr_en = tx_fifo_clr_en;
        end else begin : ONE_LANE_MODE
            assign fifo_clr_en = 4'b0;
        end
    endgenerate

endmodule
