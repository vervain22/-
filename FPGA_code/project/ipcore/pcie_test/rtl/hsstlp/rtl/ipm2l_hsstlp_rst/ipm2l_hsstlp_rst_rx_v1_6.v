//---------------------------------------------------

// Copyright (c) 2019 PANGO MICROSYSTEMS, INC
// ALL RIGHTS REVERVED.

// THE SOURCE CODE CONTAINED HEREIN IS PROPRIETARY TO PANGO MICROSYSTEMS, INC.
// IT SHALL NOT BE REPRODUCED OR DISCLOSED IN WHOLE OR IN PART OR USED BY
// PARTIES WITHOUT WRITTEN AUTHORIZATION FROM THE OWNER.

//---------------------------------------------------

//---------------------------------------------------
`timescale 1ns / 1ps
module ipm2l_hsstlp_rst_rx_v1_6 #(
    parameter FREE_CLOCK_FREQ           = 100,      // 自由运行时钟频率，单位 MHz。
    parameter CH0_RX_ENABLE             = "TRUE",   // 通道 0 接收复位逻辑使能。
    parameter CH1_RX_ENABLE             = "TRUE",   // 通道 1 接收复位逻辑使能。
    parameter CH2_RX_ENABLE             = "TRUE",   // 通道 2 接收复位逻辑使能。
    parameter CH3_RX_ENABLE             = "TRUE",   // 通道 3 接收复位逻辑使能。
    parameter CH0_MULT_LANE_MODE        = 1,        // 通道 0 配置：1 单通道，2 双通道，4 四通道。
    parameter CH1_MULT_LANE_MODE        = 1,        // 通道 1 配置：1 单通道，2 双通道，4 四通道。
    parameter CH2_MULT_LANE_MODE        = 1,        // 通道 2 配置：1 单通道，2 双通道，4 四通道。
    parameter CH3_MULT_LANE_MODE        = 1,        // 通道 3 配置：1 单通道，2 双通道，4 四通道。
    parameter CH0_RXPCS_ALIGN_TIMER     = 10000,    // 字对齐等待超时后复位接收 PMA。
    parameter CH1_RXPCS_ALIGN_TIMER     = 10000,    // 字对齐等待超时后复位接收 PMA。
    parameter CH2_RXPCS_ALIGN_TIMER     = 10000,    // 字对齐等待超时后复位接收 PMA。
    parameter CH3_RXPCS_ALIGN_TIMER     = 10000,    // 字对齐等待超时后复位接收 PMA。
    parameter PCS_CH0_BYPASS_WORD_ALIGN = "FALSE",  // 通道 0 字对齐旁路使能。
    parameter PCS_CH1_BYPASS_WORD_ALIGN = "FALSE",  // 通道 1 字对齐旁路使能。
    parameter PCS_CH2_BYPASS_WORD_ALIGN = "FALSE",  // 通道 2 字对齐旁路使能。
    parameter PCS_CH3_BYPASS_WORD_ALIGN = "FALSE",  // 通道 3 字对齐旁路使能。
    parameter PCS_CH0_BYPASS_BONDING    = "FALSE",  // 通道 0 通道绑定旁路使能。
    parameter PCS_CH1_BYPASS_BONDING    = "FALSE",  // 通道 1 通道绑定旁路使能。
    parameter PCS_CH2_BYPASS_BONDING    = "FALSE",  // 通道 2 通道绑定旁路使能。
    parameter PCS_CH3_BYPASS_BONDING    = "FALSE",  // 通道 3 通道绑定旁路使能。
    parameter PCS_CH0_BYPASS_CTC        = "FALSE",  // 通道 0 时钟补偿旁路使能。
    parameter PCS_CH1_BYPASS_CTC        = "FALSE",  // 通道 1 时钟补偿旁路使能。
    parameter PCS_CH2_BYPASS_CTC        = "FALSE",  // 通道 2 时钟补偿旁路使能。
    parameter PCS_CH3_BYPASS_CTC        = "FALSE",  // 通道 3 时钟补偿旁路使能。
    parameter LX_RX_CKDIV_0             = 0,
    parameter LX_RX_CKDIV_1             = 0,
    parameter LX_RX_CKDIV_2             = 0,
    parameter LX_RX_CKDIV_3             = 0,
    parameter CH0_RX_PLL_SEL            = 0,        // 通道 0 时钟选择：1 为 PLL1，0 为 PLL0。
    parameter CH1_RX_PLL_SEL            = 0,        // 通道 1 时钟选择：1 为 PLL1，0 为 PLL0。
    parameter CH2_RX_PLL_SEL            = 0,        // 通道 2 时钟选择：1 为 PLL1，0 为 PLL0。
    parameter CH3_RX_PLL_SEL            = 0,        // 通道 3 时钟选择：1 为 PLL1，0 为 PLL0。
    parameter PCS_RX_CLK_EXPLL_USE_CH0  = "FALSE",
    parameter PCS_RX_CLK_EXPLL_USE_CH1  = "FALSE",
    parameter PCS_RX_CLK_EXPLL_USE_CH2  = "FALSE",
    parameter PCS_RX_CLK_EXPLL_USE_CH3  = "FALSE"
) (
    // 时钟与复位
    input  wire         clk,
    input  wire         i_hsstlp_fifo_clr_0,
    input  wire         i_hsstlp_fifo_clr_1,
    input  wire         i_hsstlp_fifo_clr_2,
    input  wire         i_hsstlp_fifo_clr_3,
    // HSST 复位控制信号
    input  wire         i_pll_done_0,
    input  wire         i_pll_done_1,
    input  wire         i_rxlane_rst_0,
    input  wire         i_rxlane_rst_1,
    input  wire         i_rxlane_rst_2,
    input  wire         i_rxlane_rst_3,
    input  wire         i_rx_rate_chng_0,
    input  wire         i_rx_rate_chng_1,
    input  wire         i_rx_rate_chng_2,
    input  wire         i_rx_rate_chng_3,
    input  wire [  2:0] i_rxckdiv_0,
    input  wire [  2:0] i_rxckdiv_1,
    input  wire [  2:0] i_rxckdiv_2,
    input  wire [  2:0] i_rxckdiv_3,
    input  wire         i_pcs_cb_rst_0,
    input  wire         i_pcs_cb_rst_1,
    input  wire         i_pcs_cb_rst_2,
    input  wire         i_pcs_cb_rst_3,
    input  wire         i_force_rxfsm_det_0,    // 环回模式调试信号
    input  wire         i_force_rxfsm_det_1,    // 环回模式调试信号
    input  wire         i_force_rxfsm_det_2,    // 环回模式调试信号
    input  wire         i_force_rxfsm_det_3,    // 环回模式调试信号
    input  wire         i_force_rxfsm_lsm_0,    // 环回模式调试信号
    input  wire         i_force_rxfsm_lsm_1,    // 环回模式调试信号
    input  wire         i_force_rxfsm_lsm_2,    // 环回模式调试信号
    input  wire         i_force_rxfsm_lsm_3,    // 环回模式调试信号
    input  wire         i_force_rxfsm_cdr_0,    // 环回模式调试信号
    input  wire         i_force_rxfsm_cdr_1,    // 环回模式调试信号
    input  wire         i_force_rxfsm_cdr_2,    // 环回模式调试信号
    input  wire         i_force_rxfsm_cdr_3,    // 环回模式调试信号
    input  wire         i_txckdiv_done_0,       // 来自发送端
    input  wire         i_txckdiv_done_1,       // 来自发送端
    input  wire         i_txckdiv_done_2,       // 来自发送端
    input  wire         i_txckdiv_done_3,       // 来自发送端
    input  wire         i_pll_lock_rx_0,
    input  wire         i_pll_lock_rx_1,
    input  wire         i_pll_lock_rx_2,
    input  wire         i_pll_lock_rx_3,
    input  wire         P_RX_SIGDET_STATUS_0,
    input  wire         P_RX_SIGDET_STATUS_1,
    input  wire         P_RX_SIGDET_STATUS_2,
    input  wire         P_RX_SIGDET_STATUS_3,
    input  wire         P_RX_READY_0,
    input  wire         P_RX_READY_1,
    input  wire         P_RX_READY_2,
    input  wire         P_RX_READY_3,
    input  wire         P_PCS_LSM_SYNCED_0,
    input  wire         P_PCS_LSM_SYNCED_1,
    input  wire         P_PCS_LSM_SYNCED_2,
    input  wire         P_PCS_LSM_SYNCED_3,
    input  wire         P_PCS_RX_MCB_STATUS_0,
    input  wire         P_PCS_RX_MCB_STATUS_1,
    input  wire         P_PCS_RX_MCB_STATUS_2,
    input  wire         P_PCS_RX_MCB_STATUS_3,
    output wire         P_PCS_CB_RST_0,
    output wire         P_PCS_CB_RST_1,
    output wire         P_PCS_CB_RST_2,
    output wire         P_PCS_CB_RST_3,
    output wire         P_LANE_PD_0,
    output wire         P_LANE_PD_1,
    output wire         P_LANE_PD_2,
    output wire         P_LANE_PD_3,
    output wire         P_LANE_RST_0,
    output wire         P_LANE_RST_1,
    output wire         P_LANE_RST_2,
    output wire         P_LANE_RST_3,
    output wire         P_RX_LANE_PD_0,
    output wire         P_RX_LANE_PD_1,
    output wire         P_RX_LANE_PD_2,
    output wire         P_RX_LANE_PD_3,
    output wire         P_RX_PMA_RST_0,
    output wire         P_RX_PMA_RST_1,
    output wire         P_RX_PMA_RST_2,
    output wire         P_RX_PMA_RST_3,
    output wire         P_PCS_RX_RST_0,
    output wire         P_PCS_RX_RST_1,
    output wire         P_PCS_RX_RST_2,
    output wire         P_PCS_RX_RST_3,
    output wire [2 : 0] P_RX_RATE_0,
    output wire [2 : 0] P_RX_RATE_1,
    output wire [2 : 0] P_RX_RATE_2,
    output wire [2 : 0] P_RX_RATE_3,
    output wire         o_rxlane_done_0,
    output wire         o_rxlane_done_1,
    output wire         o_rxlane_done_2,
    output wire         o_rxlane_done_3,
    output wire         o_rxckdiv_done_0,
    output wire         o_rxckdiv_done_1,
    output wire         o_rxckdiv_done_2,
    output wire         o_rxckdiv_done_3
);

    localparam SIGDET_DEB_RISE_CNTR_WIDTH    = 12;
    localparam SIGDET_DEB_RISE_CNTR_VALUE    = 4;
    localparam CDR_ALIGN_DEB_RISE_CNTR_WIDTH = 12;
`ifdef IPM_HSST_SPEEDUP_SIM
    localparam CDR_ALIGN_DEB_RISE_CNTR_VALUE = 20;
`else
    localparam CDR_ALIGN_DEB_RISE_CNTR_VALUE = 2048;
`endif
    localparam PLL_LOCK_RISE_CNTR_WIDTH = 12;
    localparam PLL_LOCK_RISE_CNTR_VALUE = 2048;
    localparam FIFO_CLR_NUMBER                = (CH0_MULT_LANE_MODE == 1 && CH2_MULT_LANE_MODE == 1) ? 0 : (CH0_MULT_LANE_MODE == 2 && CH2_MULT_LANE_MODE == 2 && (CH0_RX_PLL_SEL != CH2_RX_PLL_SEL)) ? 2 : 1 ;
    //---------------------------------------------------
    // 内部信号
    //---------------------------------------------------
    wire [  4-1 : 0] lane_pd_rstn;
    wire [  4-1 : 0] fifo_clr_rstn;
    wire             i_pll_done_ch0;
    wire             i_pll_done_ch1;
    wire             i_pll_done_ch2;
    wire             i_pll_done_ch3;
    wire [  4-1 : 0] i_rxlane_rstn;
    wire [  4-1 : 0] i_rx_rate_chng;
    wire [4*3-1 : 0] i_rxckdiv;
    wire [  4-1 : 0] i_pll_lock_rx;
    wire [  4-1 : 0] o_txckdiv_done;
    wire [  4-1 : 0] P_LX_SIGDET_STA;
    wire [  4-1 : 0] P_LX_CDR_ALIGN;
    wire [  4-1 : 0] P_PCS_LSM_SYNCED;
    wire [  4-1 : 0] P_PCS_RX_MCB_STATUS;

    wire [  4-1 : 0] s_rxlane_rstn;
    wire [  4-1 : 0] s_LX_SIGDET_STA;
    wire [  4-1 : 0] s_LX_SIGDET_STA_deb;
    wire [  4-1 : 0] s_LX_CDR_ALIGN;
    wire [  4-1 : 0] s_LX_CDR_ALIGN_deb;
    wire [  4-1 : 0] s_PCS_LSM_SYNCED;
    wire [  4-1 : 0] s_P_PCS_RX_MCB_STATUS;
    wire [  4-1 : 0] fifo_clr_en;
    wire [  4-1 : 0] rxlane_done;
    wire [  4-1 : 0] fifoclr_sig;
    wire [  4-1 : 0] p_force_rxfsm_det;
    wire [  4-1 : 0] p_force_rxfsm_lsm;
    wire [  4-1 : 0] p_force_rxfsm_cdr;
    wire [  4-1 : 0] p_pcs_cb_rst;
    wire [  4-1 : 0] sigdet;
    wire [  4-1 : 0] cdr_align;
    wire [  4-1 : 0] word_align;
    wire [  4-1 : 0] bonding;
    wire [  4-1 : 0] s_pll_lock_rx;
    wire [  4-1 : 0] s_pll_lock_rx_deb;
    wire             fifoclr_sig_0;
    wire             fifoclr_sig_1;
    wire             fifoclr_sig_2;
    wire             fifoclr_sig_3;
    //---------------------------------------------------
    // 时序与组合逻辑
    //---------------------------------------------------
    // 通道 PLL 选择
    assign i_pll_done_ch0 = (CH0_RX_PLL_SEL == 0) ? i_pll_done_0 : i_pll_done_1;
    assign i_pll_done_ch1 = (CH1_RX_PLL_SEL == 0) ? i_pll_done_0 : i_pll_done_1;
    assign i_pll_done_ch2 = (CH2_RX_PLL_SEL == 0) ? i_pll_done_0 : i_pll_done_1;
    assign i_pll_done_ch3 = (CH3_RX_PLL_SEL == 0) ? i_pll_done_0 : i_pll_done_1;

    generate
        if (CH0_MULT_LANE_MODE == 4) begin : FOUR_LANE_MODE
            assign i_rxlane_rstn     = {4{~i_rxlane_rst_0}};
            assign i_rx_rate_chng    = {4{i_rx_rate_chng_0}};
            assign i_rxckdiv         = {4{i_rxckdiv_0}};
            assign i_pll_lock_rx     = {4{i_pll_lock_rx_0}};
            assign o_txckdiv_done    = {4{i_txckdiv_done_0}};
            assign p_pcs_cb_rst      = {4{i_pcs_cb_rst_0}};
            assign p_force_rxfsm_det = {4{i_force_rxfsm_det_0}};
            assign p_force_rxfsm_lsm = {4{i_force_rxfsm_lsm_0}};
            assign p_force_rxfsm_cdr = {4{i_force_rxfsm_cdr_0}};
        end else if (CH0_MULT_LANE_MODE == 2 && CH2_MULT_LANE_MODE == 2) begin : TWO_LANE_MODE
            assign i_rxlane_rstn     = {{2{~i_rxlane_rst_2}}, {2{~i_rxlane_rst_0}}};
            assign i_rx_rate_chng    = {{2{i_rx_rate_chng_2}}, {2{i_rx_rate_chng_0}}};
            assign i_rxckdiv         = {{2{i_rxckdiv_2}}, {2{i_rxckdiv_0}}};
            assign i_pll_lock_rx     = {{2{i_pll_lock_rx_2}}, {2{i_pll_lock_rx_0}}};
            assign o_txckdiv_done    = {{2{i_txckdiv_done_2}}, {2{i_txckdiv_done_0}}};
            assign p_pcs_cb_rst      = {{2{i_pcs_cb_rst_2}}, {2{i_pcs_cb_rst_0}}};
            assign p_force_rxfsm_det = {{2{i_force_rxfsm_det_2}}, {2{i_force_rxfsm_det_0}}};
            assign p_force_rxfsm_lsm = {{2{i_force_rxfsm_lsm_2}}, {2{i_force_rxfsm_lsm_0}}};
            assign p_force_rxfsm_cdr = {{2{i_force_rxfsm_cdr_2}}, {2{i_force_rxfsm_cdr_0}}};
        end else if (CH0_MULT_LANE_MODE == 2) begin : TWO_LANE_MODE0
            assign i_rxlane_rstn     = {~i_rxlane_rst_3, ~i_rxlane_rst_2, {2{~i_rxlane_rst_0}}};
            assign i_rx_rate_chng    = {i_rx_rate_chng_3, i_rx_rate_chng_2, {2{i_rx_rate_chng_0}}};
            assign i_rxckdiv         = {i_rxckdiv_3, i_rxckdiv_2, {2{i_rxckdiv_0}}};
            assign i_pll_lock_rx     = {i_pll_lock_rx_3, i_pll_lock_rx_2, {2{i_pll_lock_rx_0}}};
            assign o_txckdiv_done    = {i_txckdiv_done_3, i_txckdiv_done_2, {2{i_txckdiv_done_0}}};
            assign p_pcs_cb_rst      = {i_pcs_cb_rst_3, i_pcs_cb_rst_2, {2{i_pcs_cb_rst_0}}};
            assign p_force_rxfsm_det = {i_force_rxfsm_det_3, i_force_rxfsm_det_2, {2{i_force_rxfsm_det_0}}};
            assign p_force_rxfsm_lsm = {i_force_rxfsm_lsm_3, i_force_rxfsm_lsm_2, {2{i_force_rxfsm_lsm_0}}};
            assign p_force_rxfsm_cdr = {i_force_rxfsm_cdr_3, i_force_rxfsm_cdr_2, {2{i_force_rxfsm_cdr_0}}};
        end else if (CH2_MULT_LANE_MODE == 2) begin : TWO_LANE_MODE1
            assign i_rxlane_rstn     = {{2{~i_rxlane_rst_2}}, ~i_rxlane_rst_1, ~i_rxlane_rst_0};
            assign i_rx_rate_chng    = {{2{i_rx_rate_chng_2}}, i_rx_rate_chng_1, i_rx_rate_chng_0};
            assign i_rxckdiv         = {{2{i_rxckdiv_2}}, i_rxckdiv_1, i_rxckdiv_0};
            assign i_pll_lock_rx     = {{2{i_pll_lock_rx_2}}, i_pll_lock_rx_1, i_pll_lock_rx_0};
            assign o_txckdiv_done    = {{2{i_txckdiv_done_2}}, i_txckdiv_done_1, i_txckdiv_done_0};
            assign p_pcs_cb_rst      = {{2{i_pcs_cb_rst_2}}, i_pcs_cb_rst_1, i_pcs_cb_rst_0};
            assign p_force_rxfsm_det = {{2{i_force_rxfsm_det_2}}, i_force_rxfsm_det_1, i_force_rxfsm_det_0};
            assign p_force_rxfsm_lsm = {{2{i_force_rxfsm_lsm_2}}, i_force_rxfsm_lsm_1, i_force_rxfsm_lsm_0};
            assign p_force_rxfsm_cdr = {{2{i_force_rxfsm_cdr_2}}, i_force_rxfsm_cdr_1, i_force_rxfsm_cdr_0};
        end else begin : ONE_LANE_MODE
            assign i_rxlane_rstn = {~i_rxlane_rst_3, ~i_rxlane_rst_2, ~i_rxlane_rst_1, ~i_rxlane_rst_0};
            assign i_rx_rate_chng = {i_rx_rate_chng_3, i_rx_rate_chng_2, i_rx_rate_chng_1, i_rx_rate_chng_0};
            assign i_rxckdiv = {i_rxckdiv_3, i_rxckdiv_2, i_rxckdiv_1, i_rxckdiv_0};
            assign i_pll_lock_rx = {i_pll_lock_rx_3, i_pll_lock_rx_2, i_pll_lock_rx_1, i_pll_lock_rx_0};
            assign o_txckdiv_done = {i_txckdiv_done_3, i_txckdiv_done_2, i_txckdiv_done_1, i_txckdiv_done_0};
            assign p_pcs_cb_rst = {i_pcs_cb_rst_3, i_pcs_cb_rst_2, i_pcs_cb_rst_1, i_pcs_cb_rst_0};
            assign p_force_rxfsm_det = {
                i_force_rxfsm_det_3, i_force_rxfsm_det_2, i_force_rxfsm_det_1, i_force_rxfsm_det_0
            };
            assign p_force_rxfsm_lsm = {
                i_force_rxfsm_lsm_3, i_force_rxfsm_lsm_2, i_force_rxfsm_lsm_1, i_force_rxfsm_lsm_0
            };
            assign p_force_rxfsm_cdr = {
                i_force_rxfsm_cdr_3, i_force_rxfsm_cdr_2, i_force_rxfsm_cdr_1, i_force_rxfsm_cdr_0
            };
        end
    endgenerate

    assign P_LX_SIGDET_STA = {P_RX_SIGDET_STATUS_3, P_RX_SIGDET_STATUS_2, P_RX_SIGDET_STATUS_1, P_RX_SIGDET_STATUS_0};
    assign P_LX_CDR_ALIGN = {P_RX_READY_3, P_RX_READY_2, P_RX_READY_1, P_RX_READY_0};
    assign P_PCS_LSM_SYNCED = {P_PCS_LSM_SYNCED_3, P_PCS_LSM_SYNCED_2, P_PCS_LSM_SYNCED_1, P_PCS_LSM_SYNCED_0};
    assign P_PCS_RX_MCB_STATUS = {
        P_PCS_RX_MCB_STATUS_3, P_PCS_RX_MCB_STATUS_2, P_PCS_RX_MCB_STATUS_1, P_PCS_RX_MCB_STATUS_0
    };

    genvar i;
    generate
        for (i = 0; i < 4; i = i + 1) begin : SYNC_RXLANE
            // 同步复位信号
            ipm2l_hsstlp_rst_sync_v1_0 rxlane_rstn_sync (
                .clk(clk),
                .rst_n(i_rxlane_rstn[i]),
                .sig_async(1'b1),
                .sig_synced(s_rxlane_rstn[i])
            );

            // 各通道分别同步 ALOS、CDR_ALIGN 和 PCS_LSM_SYNCED。
            ipm2l_hsstlp_rst_sync_v1_0 i_pll_lock_sync (
                .clk(clk),
                .rst_n(lane_pd_rstn[i]),
                .sig_async(i_pll_lock_rx[i]),
                .sig_synced(s_pll_lock_rx[i])
            );
            ipm2l_hsstlp_rst_sync_v1_0 sigdet_sync (
                .clk(clk),
                .rst_n(s_rxlane_rstn[i] & lane_pd_rstn[i]),
                .sig_async(P_LX_SIGDET_STA[i]),
                .sig_synced(s_LX_SIGDET_STA[i])
            );
            ipm2l_hsstlp_rst_sync_v1_0 cdr_align_sync (
                .clk(clk),
                .rst_n(s_rxlane_rstn[i] & lane_pd_rstn[i]),
                .sig_async(P_LX_CDR_ALIGN[i]),
                .sig_synced(s_LX_CDR_ALIGN[i])
            );
            ipm2l_hsstlp_rst_sync_v1_0 word_align_sync (
                .clk(clk),
                .rst_n(s_rxlane_rstn[i] & lane_pd_rstn[i]),
                .sig_async(P_PCS_LSM_SYNCED[i]),
                .sig_synced(s_PCS_LSM_SYNCED[i])
            );
            ipm2l_hsstlp_rst_sync_v1_0 bonding_sync (
                .clk(clk),
                .rst_n(s_rxlane_rstn[i] & lane_pd_rstn[i]),
                .sig_async(P_PCS_RX_MCB_STATUS[i]),
                .sig_synced(s_P_PCS_RX_MCB_STATUS[i])
            );

            // 各通道分别消抖 ALOS 和 CDR_ALIGN。
            ipm2l_hsstlp_rst_debounce_v1_0 #(
                .RISE_CNTR_WIDTH(SIGDET_DEB_RISE_CNTR_WIDTH),
                .RISE_CNTR_VALUE(SIGDET_DEB_RISE_CNTR_VALUE)
            ) sigdet_deb (
                .clk(clk),
                .rst_n(s_rxlane_rstn[i] & lane_pd_rstn[i]),
                .signal_b(s_LX_SIGDET_STA[i]),
                .signal_deb(s_LX_SIGDET_STA_deb[i])
            );

            ipm2l_hsstlp_rst_debounce_v1_0 #(
                .RISE_CNTR_WIDTH(CDR_ALIGN_DEB_RISE_CNTR_WIDTH),
                .RISE_CNTR_VALUE(CDR_ALIGN_DEB_RISE_CNTR_VALUE)
            ) cdr_align_deb (
                .clk(clk),
                .rst_n(s_rxlane_rstn[i] & lane_pd_rstn[i]),
                .signal_b(s_LX_CDR_ALIGN[i]),
                .signal_deb(s_LX_CDR_ALIGN_deb[i])
            );

            ipm2l_hsstlp_rst_debounce_v1_0 #(
                .RISE_CNTR_WIDTH(PLL_LOCK_RISE_CNTR_WIDTH),
                .RISE_CNTR_VALUE(PLL_LOCK_RISE_CNTR_VALUE)
            ) i_pll_lock_deb (
                .clk(clk),
                .rst_n(lane_pd_rstn[i]),
                .signal_b(s_pll_lock_rx[i]),
                .signal_deb(s_pll_lock_rx_deb[i])
            );
        end
    endgenerate

    assign lane_pd_rstn  = {i_pll_done_ch3, i_pll_done_ch2, i_pll_done_ch1, i_pll_done_ch0};
    assign fifo_clr_rstn = lane_pd_rstn & s_rxlane_rstn;
    assign sigdet        = s_LX_SIGDET_STA_deb | p_force_rxfsm_det;
    assign cdr_align     = s_LX_CDR_ALIGN_deb | p_force_rxfsm_cdr;
    assign word_align    = s_PCS_LSM_SYNCED | p_force_rxfsm_lsm;
    assign bonding       = s_P_PCS_RX_MCB_STATUS | p_force_rxfsm_lsm;

    // 通道 0
    generate
        if (CH0_RX_ENABLE == "TRUE") begin : RXLANE0_ENABLE
            ipm2l_hsstlp_rxlane_rst_fsm_v1_6 #(
                .FREE_CLOCK_FREQ     (FREE_CLOCK_FREQ),
                .CH_MULT_LANE_MODE   (CH0_MULT_LANE_MODE),
                .CH_RXPCS_ALIGN_TIMER(CH0_RXPCS_ALIGN_TIMER),
                .CH_BYPASS_WORD_ALIGN(PCS_CH0_BYPASS_WORD_ALIGN),
                .CH_BYPASS_BONDING   (PCS_CH0_BYPASS_BONDING),
                .CH_BYPASS_CTC       (PCS_CH0_BYPASS_CTC),
                .LX_RX_CKDIV         (LX_RX_CKDIV_0),
                .PCS_RX_CLK_EXPLL_USE(PCS_RX_CLK_EXPLL_USE_CH0)
            ) rxlane_fsm0 (
                .clk            (clk),
                .rst_n          (lane_pd_rstn[0]),
                .i_rxlane_rst_n (s_rxlane_rstn[0]),
                .fifo_clr_en    (fifo_clr_en[0]),
                .i_rx_rate_chng (i_rx_rate_chng[0]),
                .i_rxckdiv      (i_rxckdiv[2:0]),
                .i_tx_ckdiv_done(o_txckdiv_done[0]),
                .sigdet         (sigdet[0]),
                .cdr_align      (cdr_align[0]),
                .word_align     (word_align[0]),
                .bonding        (bonding[0]),
                .i_pcs_cb_rst   (p_pcs_cb_rst[0]),
                .i_pll_lock_rx  (s_pll_lock_rx_deb[0]),
                .P_LANE_PD      (P_LANE_PD_0),
                .P_LANE_RST     (P_LANE_RST_0),
                .P_RX_LANE_PD   (P_RX_LANE_PD_0),
                .P_RX_PMA_RST   (P_RX_PMA_RST_0),
                .P_PCS_RX_RST   (P_PCS_RX_RST_0),
                .P_RX_RATE      (P_RX_RATE_0),
                .P_PCS_CB_RST   (P_PCS_CB_RST_0),
                .o_rxckdiv_done (o_rxckdiv_done_0),
                .o_rxlane_done  (o_rxlane_done_0),
                .fifoclr_sig    (fifoclr_sig_0)
            );
        end else begin : RXLANE0_DISABLE
            assign P_LANE_PD_0      = 1'b1;
            assign P_LANE_RST_0     = 1'b1;
            assign P_RX_LANE_PD_0   = 1'b1;
            assign P_RX_PMA_RST_0   = 1'b1;
            assign P_PCS_RX_RST_0   = 1'b1;
            assign P_RX_RATE_0      = 3'b0;
            assign P_PCS_CB_RST_0   = 1'b0;
            assign o_rxckdiv_done_0 = 1'b0;
            assign o_rxlane_done_0  = 1'b0;
        end
    endgenerate

    // 通道 1
    generate
        if (CH1_RX_ENABLE == "TRUE") begin : RXLANE1_ENABLE
            ipm2l_hsstlp_rxlane_rst_fsm_v1_6 #(
                .FREE_CLOCK_FREQ     (FREE_CLOCK_FREQ),
                .CH_MULT_LANE_MODE   (CH1_MULT_LANE_MODE),
                .CH_RXPCS_ALIGN_TIMER(CH1_RXPCS_ALIGN_TIMER),
                .CH_BYPASS_WORD_ALIGN(PCS_CH1_BYPASS_WORD_ALIGN),
                .CH_BYPASS_BONDING   (PCS_CH1_BYPASS_BONDING),
                .CH_BYPASS_CTC       (PCS_CH1_BYPASS_CTC),
                .LX_RX_CKDIV         (LX_RX_CKDIV_1),
                .PCS_RX_CLK_EXPLL_USE(PCS_RX_CLK_EXPLL_USE_CH1)
            ) rxlane_fsm1 (
                .clk            (clk),
                .rst_n          (lane_pd_rstn[1]),
                .i_rxlane_rst_n (s_rxlane_rstn[1]),
                .fifo_clr_en    (fifo_clr_en[1]),
                .i_rx_rate_chng (i_rx_rate_chng[1]),
                .i_rxckdiv      (i_rxckdiv[5:3]),
                .i_tx_ckdiv_done(o_txckdiv_done[1]),
                .sigdet         (sigdet[1]),
                .cdr_align      (cdr_align[1]),
                .word_align     (word_align[1]),
                .bonding        (bonding[1]),
                .i_pcs_cb_rst   (p_pcs_cb_rst[1]),
                .i_pll_lock_rx  (s_pll_lock_rx_deb[1]),
                .P_LANE_PD      (P_LANE_PD_1),
                .P_LANE_RST     (P_LANE_RST_1),
                .P_RX_LANE_PD   (P_RX_LANE_PD_1),
                .P_RX_PMA_RST   (P_RX_PMA_RST_1),
                .P_PCS_RX_RST   (P_PCS_RX_RST_1),
                .P_RX_RATE      (P_RX_RATE_1),
                .P_PCS_CB_RST   (P_PCS_CB_RST_1),
                .o_rxckdiv_done (o_rxckdiv_done_1),
                .o_rxlane_done  (o_rxlane_done_1),
                .fifoclr_sig    (fifoclr_sig_1)
            );
        end else begin : RXLANE1_DISABLE
            assign P_LANE_PD_1      = 1'b1;
            assign P_LANE_RST_1     = 1'b1;
            assign P_RX_LANE_PD_1   = 1'b1;
            assign P_RX_PMA_RST_1   = 1'b1;
            assign P_PCS_RX_RST_1   = 1'b1;
            assign P_RX_RATE_1      = 3'b0;
            assign P_PCS_CB_RST_1   = 1'b0;
            assign o_rxckdiv_done_1 = 1'b0;
            assign o_rxlane_done_1  = 1'b0;
        end
    endgenerate

    // 通道 2
    generate
        if (CH2_RX_ENABLE == "TRUE") begin : RXLANE2_ENABLE
            ipm2l_hsstlp_rxlane_rst_fsm_v1_6 #(
                .FREE_CLOCK_FREQ     (FREE_CLOCK_FREQ),
                .CH_MULT_LANE_MODE   (CH2_MULT_LANE_MODE),
                .CH_RXPCS_ALIGN_TIMER(CH2_RXPCS_ALIGN_TIMER),
                .CH_BYPASS_WORD_ALIGN(PCS_CH2_BYPASS_WORD_ALIGN),
                .CH_BYPASS_BONDING   (PCS_CH2_BYPASS_BONDING),
                .CH_BYPASS_CTC       (PCS_CH2_BYPASS_CTC),
                .LX_RX_CKDIV         (LX_RX_CKDIV_2),
                .PCS_RX_CLK_EXPLL_USE(PCS_RX_CLK_EXPLL_USE_CH2)
            ) rxlane_fsm2 (
                .clk            (clk),
                .rst_n          (lane_pd_rstn[2]),
                .i_rxlane_rst_n (s_rxlane_rstn[2]),
                .fifo_clr_en    (fifo_clr_en[2]),
                .i_rx_rate_chng (i_rx_rate_chng[2]),
                .i_rxckdiv      (i_rxckdiv[8:6]),
                .i_tx_ckdiv_done(o_txckdiv_done[2]),
                .sigdet         (sigdet[2]),
                .cdr_align      (cdr_align[2]),
                .word_align     (word_align[2]),
                .bonding        (bonding[2]),
                .i_pcs_cb_rst   (p_pcs_cb_rst[2]),
                .i_pll_lock_rx  (s_pll_lock_rx_deb[2]),
                .P_LANE_PD      (P_LANE_PD_2),
                .P_LANE_RST     (P_LANE_RST_2),
                .P_RX_LANE_PD   (P_RX_LANE_PD_2),
                .P_RX_PMA_RST   (P_RX_PMA_RST_2),
                .P_PCS_RX_RST   (P_PCS_RX_RST_2),
                .P_RX_RATE      (P_RX_RATE_2),
                .P_PCS_CB_RST   (P_PCS_CB_RST_2),
                .o_rxckdiv_done (o_rxckdiv_done_2),
                .o_rxlane_done  (o_rxlane_done_2),
                .fifoclr_sig    (fifoclr_sig_2)
            );
        end else begin : RXLANE2_DISABLE
            assign P_LANE_PD_2      = 1'b1;
            assign P_LANE_RST_2     = 1'b1;
            assign P_RX_LANE_PD_2   = 1'b1;
            assign P_RX_PMA_RST_2   = 1'b1;
            assign P_PCS_RX_RST_2   = 1'b1;
            assign P_RX_RATE_2      = 3'b0;
            assign P_PCS_CB_RST_2   = 1'b0;
            assign o_rxckdiv_done_2 = 1'b0;
            assign o_rxlane_done_2  = 1'b0;
        end
    endgenerate

    // 通道 3
    generate
        if (CH3_RX_ENABLE == "TRUE") begin : RXLANE3_ENABLE
            ipm2l_hsstlp_rxlane_rst_fsm_v1_6 #(
                .FREE_CLOCK_FREQ     (FREE_CLOCK_FREQ),
                .CH_MULT_LANE_MODE   (CH3_MULT_LANE_MODE),
                .CH_RXPCS_ALIGN_TIMER(CH3_RXPCS_ALIGN_TIMER),
                .CH_BYPASS_WORD_ALIGN(PCS_CH3_BYPASS_WORD_ALIGN),
                .CH_BYPASS_BONDING   (PCS_CH3_BYPASS_BONDING),
                .CH_BYPASS_CTC       (PCS_CH3_BYPASS_CTC),
                .LX_RX_CKDIV         (LX_RX_CKDIV_3),
                .PCS_RX_CLK_EXPLL_USE(PCS_RX_CLK_EXPLL_USE_CH3)
            ) rxlane_fsm3 (
                .clk            (clk),
                .rst_n          (lane_pd_rstn[3]),
                .i_rxlane_rst_n (s_rxlane_rstn[3]),
                .fifo_clr_en    (fifo_clr_en[3]),
                .i_rx_rate_chng (i_rx_rate_chng[3]),
                .i_rxckdiv      (i_rxckdiv[11:9]),
                .i_tx_ckdiv_done(o_txckdiv_done[3]),
                .sigdet         (sigdet[3]),
                .cdr_align      (cdr_align[3]),
                .word_align     (word_align[3]),
                .bonding        (bonding[3]),
                .i_pcs_cb_rst   (p_pcs_cb_rst[3]),
                .i_pll_lock_rx  (s_pll_lock_rx_deb[3]),
                .P_LANE_PD      (P_LANE_PD_3),
                .P_LANE_RST     (P_LANE_RST_3),
                .P_RX_LANE_PD   (P_RX_LANE_PD_3),
                .P_RX_PMA_RST   (P_RX_PMA_RST_3),
                .P_PCS_RX_RST   (P_PCS_RX_RST_3),
                .P_RX_RATE      (P_RX_RATE_3),
                .P_PCS_CB_RST   (P_PCS_CB_RST_3),
                .o_rxckdiv_done (o_rxckdiv_done_3),
                .o_rxlane_done  (o_rxlane_done_3),
                .fifoclr_sig    (fifoclr_sig_3)
            );
        end else begin : RXLANE3_DISABLE
            assign P_LANE_PD_3      = 1'b1;
            assign P_LANE_RST_3     = 1'b1;
            assign P_RX_LANE_PD_3   = 1'b1;
            assign P_RX_PMA_RST_3   = 1'b1;
            assign P_PCS_RX_RST_3   = 1'b1;
            assign P_RX_RATE_3      = 3'b0;
            assign P_PCS_CB_RST_3   = 1'b0;
            assign o_rxckdiv_done_3 = 1'b0;
            assign o_rxlane_done_3  = 1'b0;
        end
    endgenerate

    assign fifoclr_sig = {fifoclr_sig_3, fifoclr_sig_2, fifoclr_sig_1, fifoclr_sig_0};

    generate
        if (FIFO_CLR_NUMBER == 1) begin : FIFO_GENERATE_1
            ipm2l_hsstlp_fifo_clr_v1_3 #(
                .CH0_RX_ENABLE(CH0_RX_ENABLE),  // 通道 0 接收复位逻辑使能。
                .CH1_RX_ENABLE(CH1_RX_ENABLE),  // 通道 1 接收复位逻辑使能。
                .CH2_RX_ENABLE(CH2_RX_ENABLE),  // 通道 2 接收复位逻辑使能。
                .CH3_RX_ENABLE(CH3_RX_ENABLE),  // 通道 3 接收复位逻辑使能。
                .CH0_MULT_LANE_MODE           (CH0_MULT_LANE_MODE       ), // 通道 0 配置：1 单通道，2 双通道，4 四通道。
                .CH1_MULT_LANE_MODE           (CH1_MULT_LANE_MODE       ), // 通道 1 配置：1 单通道，2 双通道，4 四通道。
                .CH2_MULT_LANE_MODE           (CH2_MULT_LANE_MODE       ), // 通道 2 配置：1 单通道，2 双通道，4 四通道。
                .CH3_MULT_LANE_MODE           (CH3_MULT_LANE_MODE       ), // 通道 3 配置：1 单通道，2 双通道，4 四通道。
                .PCS_CH0_BYPASS_BONDING(PCS_CH0_BYPASS_BONDING),  // 通道 0 通道绑定旁路使能。
                .PCS_CH1_BYPASS_BONDING(PCS_CH1_BYPASS_BONDING),  // 通道 1 通道绑定旁路使能。
                .PCS_CH2_BYPASS_BONDING(PCS_CH2_BYPASS_BONDING),  // 通道 2 通道绑定旁路使能。
                .PCS_CH3_BYPASS_BONDING(PCS_CH3_BYPASS_BONDING)  // 通道 3 通道绑定旁路使能。
            ) fifo_clr (
                .clk                (clk),
                .rst_n              (fifo_clr_rstn),
                .i_hsstlp_fifo_clr_0(i_hsstlp_fifo_clr_0),
                .i_hsstlp_fifo_clr_1(i_hsstlp_fifo_clr_1),
                .i_hsstlp_fifo_clr_2(i_hsstlp_fifo_clr_2),
                .i_hsstlp_fifo_clr_3(i_hsstlp_fifo_clr_3),
                .cdr_align          (s_LX_CDR_ALIGN_deb),
                .rxlane_done        (fifoclr_sig),
                .fifo_clr_en        (fifo_clr_en)
            );
        end else if (FIFO_CLR_NUMBER == 2) begin : FIFO_GENERATE_2
            wire [4-1 : 0] fifo_clr_en_0;
            wire [4-1 : 0] fifo_clr_en_2;
            ipm2l_hsstlp_fifo_clr_v1_3 #(
                .CH0_RX_ENABLE(CH0_RX_ENABLE),  // 通道 0 接收复位逻辑使能。
                .CH1_RX_ENABLE(CH1_RX_ENABLE),  // 通道 1 接收复位逻辑使能。
                .CH2_RX_ENABLE(CH2_RX_ENABLE),  // 通道 2 接收复位逻辑使能。
                .CH3_RX_ENABLE(CH3_RX_ENABLE),  // 通道 3 接收复位逻辑使能。
                .CH0_MULT_LANE_MODE           (CH0_MULT_LANE_MODE       ), // 通道 0 配置：1 单通道，2 双通道，4 四通道。
                .CH1_MULT_LANE_MODE           (CH1_MULT_LANE_MODE       ), // 通道 1 配置：1 单通道，2 双通道，4 四通道。
                .CH2_MULT_LANE_MODE(1),  // 通道 2 配置：1 单通道，2 双通道，4 四通道。
                .CH3_MULT_LANE_MODE(1),  // 通道 3 配置：1 单通道，2 双通道，4 四通道。
                .PCS_CH0_BYPASS_BONDING(PCS_CH0_BYPASS_BONDING),  // 通道 0 通道绑定旁路使能。
                .PCS_CH1_BYPASS_BONDING(PCS_CH1_BYPASS_BONDING),  // 通道 1 通道绑定旁路使能。
                .PCS_CH2_BYPASS_BONDING(PCS_CH2_BYPASS_BONDING),  // 通道 2 通道绑定旁路使能。
                .PCS_CH3_BYPASS_BONDING(PCS_CH3_BYPASS_BONDING)  // 通道 3 通道绑定旁路使能。
            ) fifo_clr_0 (
                .clk                (clk),
                .rst_n              (fifo_clr_rstn),
                .i_hsstlp_fifo_clr_0(i_hsstlp_fifo_clr_0),
                .i_hsstlp_fifo_clr_1(i_hsstlp_fifo_clr_1),
                .i_hsstlp_fifo_clr_2(i_hsstlp_fifo_clr_2),
                .i_hsstlp_fifo_clr_3(i_hsstlp_fifo_clr_3),
                .cdr_align          (s_LX_CDR_ALIGN_deb),
                .rxlane_done        (fifoclr_sig),
                .fifo_clr_en        (fifo_clr_en_0)
            );
            ipm2l_hsstlp_fifo_clr_v1_3 #(
                .CH0_RX_ENABLE(CH0_RX_ENABLE),  // 通道 0 接收复位逻辑使能。
                .CH1_RX_ENABLE(CH1_RX_ENABLE),  // 通道 1 接收复位逻辑使能。
                .CH2_RX_ENABLE(CH2_RX_ENABLE),  // 通道 2 接收复位逻辑使能。
                .CH3_RX_ENABLE(CH3_RX_ENABLE),  // 通道 3 接收复位逻辑使能。
                .CH0_MULT_LANE_MODE(1),  // 通道 0 配置：1 单通道，2 双通道，4 四通道。
                .CH1_MULT_LANE_MODE(1),  // 通道 1 配置：1 单通道，2 双通道，4 四通道。
                .CH2_MULT_LANE_MODE           (CH2_MULT_LANE_MODE       ), // 通道 2 配置：1 单通道，2 双通道，4 四通道。
                .CH3_MULT_LANE_MODE           (CH3_MULT_LANE_MODE       ), // 通道 3 配置：1 单通道，2 双通道，4 四通道。
                .PCS_CH0_BYPASS_BONDING(PCS_CH0_BYPASS_BONDING),  // 通道 0 通道绑定旁路使能。
                .PCS_CH1_BYPASS_BONDING(PCS_CH1_BYPASS_BONDING),  // 通道 1 通道绑定旁路使能。
                .PCS_CH2_BYPASS_BONDING(PCS_CH2_BYPASS_BONDING),  // 通道 2 通道绑定旁路使能。
                .PCS_CH3_BYPASS_BONDING(PCS_CH3_BYPASS_BONDING)  // 通道 3 通道绑定旁路使能。
            ) fifo_clr_2 (
                .clk                (clk),
                .rst_n              (fifo_clr_rstn),
                .i_hsstlp_fifo_clr_0(i_hsstlp_fifo_clr_0),
                .i_hsstlp_fifo_clr_1(i_hsstlp_fifo_clr_1),
                .i_hsstlp_fifo_clr_2(i_hsstlp_fifo_clr_2),
                .i_hsstlp_fifo_clr_3(i_hsstlp_fifo_clr_3),
                .cdr_align          (s_LX_CDR_ALIGN_deb),
                .rxlane_done        (fifoclr_sig),
                .fifo_clr_en        (fifo_clr_en_2)
            );
            assign fifo_clr_en = fifo_clr_en_0 | fifo_clr_en_2;
        end else begin : FIFO_GENERATE_0
            assign fifo_clr_en = 4'b0;
        end
    endgenerate

endmodule
