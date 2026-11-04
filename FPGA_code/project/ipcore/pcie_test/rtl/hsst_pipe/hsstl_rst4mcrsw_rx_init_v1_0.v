//---------------------------------------------------
// Copyright (c) 2015 PANGO MICROSYSTEMS, INC
// ALL RIGHTS REVERVED.
//---------------------------------------------------
`timescale 1ns / 1ps
module hsstl_rst4mcrsw_rx_init_v1_0 (
    input wire clk,
    input wire rst_n,
    input wire rxlane_soft_rst_n,

    input wire P_LX_ALOS_STA,
    input wire P_LX_CDR_ALIGN,
    input wire P_PCS_LSM_SYNCED,

    input wire main_rst_align,

    output wire [3:0] rx_init_fsm,
    output wire       s_LX_ALOS_STA,
    output wire       s_LX_CDR_ALIGN,
    output wire       s_PCS_LSM_SYNCED,
    output wire       s_LX_ALOS_STA_deb,
    output wire       s_LX_CDR_ALIGN_deb,

    input  wire P_RX_LANE_POWERUP,
    output wire P_RX_PMA_RSTN,
    output wire P_RX_PLL_RSTN,
    output wire P_PCS_RX_RSTN,
    output wire P_PCS_CB_RSTN,
    output wire init_done
);

    localparam LOSS_DEB_RISE_CNTR_WIDTH      = 12;
    localparam LOSS_DEB_RISE_CNTR_VALUE      = 4;
    localparam CDR_ALIGN_DEB_RISE_CNTR_WIDTH = 12;
    localparam CDR_ALIGN_DEB_RISE_CNTR_VALUE = 2048;

    wire rx_rst_n;

    assign rx_rst_n = rst_n & rxlane_soft_rst_n;

    // 各通道分别同步 ALOS、CDR_ALIGN 和 PCS_LSM_SYNCED。
    hsst_rst_sync_v1_0 loss_signal_multi_sw_sync (
        .clk(clk),
        .rst_n(rx_rst_n),
        .sig_async(P_LX_ALOS_STA),
        .sig_synced(s_LX_ALOS_STA)
    );
    hsst_rst_sync_v1_0 cdr_align_multi_sw_sync (
        .clk(clk),
        .rst_n(rx_rst_n),
        .sig_async(P_LX_CDR_ALIGN),
        .sig_synced(s_LX_CDR_ALIGN)
    );
    hsst_rst_sync_v1_0 word_align_multi_sw_sync (
        .clk(clk),
        .rst_n(rx_rst_n),
        .sig_async(P_PCS_LSM_SYNCED),
        .sig_synced(s_PCS_LSM_SYNCED)
    );

    // 各通道分别消抖 ALOS 和 CDR_ALIGN。
    hsst_rst_debounce_v1_0 #(
        .RISE_CNTR_WIDTH(LOSS_DEB_RISE_CNTR_WIDTH),
        .RISE_CNTR_VALUE(LOSS_DEB_RISE_CNTR_VALUE),
        .ACTIVE_HIGH(1)
    ) loss_signal_multi_sw_deb (
        .clk(clk),
        .rst_n(rx_rst_n),
        .signal_b(s_LX_ALOS_STA),
        .signal_deb(s_LX_ALOS_STA_deb)
    );

    hsst_rst_debounce_v1_0 #(
        .RISE_CNTR_WIDTH(CDR_ALIGN_DEB_RISE_CNTR_WIDTH),
        .RISE_CNTR_VALUE(CDR_ALIGN_DEB_RISE_CNTR_VALUE)
    ) cdr_align_multi_sw_deb (
        .clk(clk),
        .rst_n(rx_rst_n),
        .signal_b(s_LX_CDR_ALIGN),
        .signal_deb(s_LX_CDR_ALIGN_deb)
    );

    // 接收复位状态机
    hsstl_rst4mcrsw_rx_rst_initfsm_v1_0 rx_rst_initfsm_multi_sw_lane (
        .clk              (clk),
        .rst_n            (rx_rst_n),
        .P_RX_LANE_POWERUP(P_RX_LANE_POWERUP),
        .main_rst_align   (main_rst_align),

        .loss_signal(s_LX_ALOS_STA),
        .cdr_align  (s_LX_CDR_ALIGN),
        .word_align (s_PCS_LSM_SYNCED),

        .rx_init_fsm  (rx_init_fsm),
        .P_RX_PMA_RSTN(P_RX_PMA_RSTN),
        .P_RX_PLL_RSTN(P_RX_PLL_RSTN),
        .P_PCS_RX_RSTN(P_PCS_RX_RSTN),
        .P_PCS_CB_RSTN(P_PCS_CB_RSTN),
        .init_done    (init_done)
    );

endmodule
