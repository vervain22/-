//---------------------------------------------------

// Copyright (c) 2019 PANGO MICROSYSTEMS, INC
// ALL RIGHTS REVERVED.

// THE SOURCE CODE CONTAINED HEREIN IS PROPRIETARY TO PANGO MICROSYSTEMS, INC.
// IT SHALL NOT BE REPRODUCED OR DISCLOSED IN WHOLE OR IN PART OR USED BY
// PARTIES WITHOUT WRITTEN AUTHORIZATION FROM THE OWNER.

//---------------------------------------------------

//---------------------------------------------------
`timescale 1ns / 1ps
module ipm2l_hsstlp_rst_tx_v1_6 #(
    parameter FREE_CLOCK_FREQ          = 100,      // 自由运行时钟频率来自配置界面，范围 0～200 MHz。
    parameter CH0_TX_ENABLE            = "TRUE",   // 通道 0 发送复位逻辑使能。
    parameter CH1_TX_ENABLE            = "TRUE",   // 通道 1 发送复位逻辑使能。
    parameter CH2_TX_ENABLE            = "TRUE",   // 通道 2 发送复位逻辑使能。
    parameter CH3_TX_ENABLE            = "TRUE",   // 通道 3 发送复位逻辑使能。
    parameter CH0_MULT_LANE_MODE       = 1,        // 通道 0 配置：1 单通道，2 双通道，4 四通道。
    parameter CH1_MULT_LANE_MODE       = 1,        // 通道 1 配置：1 单通道，2 双通道，4 四通道。
    parameter CH2_MULT_LANE_MODE       = 1,        // 通道 2 配置：1 单通道，2 双通道，4 四通道。
    parameter CH3_MULT_LANE_MODE       = 1,        // 通道 3 配置：1 单通道，2 双通道，4 四通道。
    parameter P_LX_TX_CKDIV_0          = 0,
    parameter P_LX_TX_CKDIV_1          = 0,
    parameter P_LX_TX_CKDIV_2          = 0,
    parameter P_LX_TX_CKDIV_3          = 0,
    parameter CH0_TX_PLL_SEL           = 0,        // 通道 0 时钟选择：1 为 PLL1，0 为 PLL0。
    parameter CH1_TX_PLL_SEL           = 0,        // 通道 1 时钟选择：1 为 PLL1，0 为 PLL0。
    parameter CH2_TX_PLL_SEL           = 0,        // 通道 2 时钟选择：1 为 PLL1，0 为 PLL0。
    parameter CH3_TX_PLL_SEL           = 0,        // 通道 3 时钟选择：1 为 PLL1，0 为 PLL0。
    parameter PCS_TX_CLK_EXPLL_USE_CH0 = "FALSE",  // TRUE 表示使用逻辑侧 PLL。
    parameter PCS_TX_CLK_EXPLL_USE_CH1 = "FALSE",
    parameter PCS_TX_CLK_EXPLL_USE_CH2 = "FALSE",
    parameter PCS_TX_CLK_EXPLL_USE_CH3 = "FALSE"
) (
    // 用户侧接口
    input  wire         clk,
    input  wire         i_txlane_rst_0,
    input  wire         i_txlane_rst_1,
    input  wire         i_txlane_rst_2,
    input  wire         i_txlane_rst_3,
    input  wire         i_pll_done_0,
    input  wire         i_pll_done_1,
    input  wire         i_tx_rate_chng_0,
    input  wire         i_tx_rate_chng_1,
    input  wire         i_tx_rate_chng_2,
    input  wire         i_tx_rate_chng_3,
    input  wire         i_pll_lock_tx_0,
    input  wire         i_pll_lock_tx_1,
    input  wire         i_pll_lock_tx_2,
    input  wire         i_pll_lock_tx_3,
    input  wire [2 : 0] i_txckdiv_0,
    input  wire [2 : 0] i_txckdiv_1,
    input  wire [2 : 0] i_txckdiv_2,
    input  wire [2 : 0] i_txckdiv_3,
    output wire         o_txlane_done_0,
    output wire         o_txlane_done_1,
    output wire         o_txlane_done_2,
    output wire         o_txlane_done_3,
    output wire         o_txckdiv_done_0,
    output wire         o_txckdiv_done_1,
    output wire         o_txckdiv_done_2,
    output wire         o_txckdiv_done_3,
    // HSST 侧接口
    // 不支持

    output wire         P_TX_LANE_PD_CLKPATH_0,
    output wire         P_TX_LANE_PD_CLKPATH_1,
    output wire         P_TX_LANE_PD_CLKPATH_2,
    output wire         P_TX_LANE_PD_CLKPATH_3,
    output wire         P_TX_LANE_PD_DRIVER_0,
    output wire         P_TX_LANE_PD_DRIVER_1,
    output wire         P_TX_LANE_PD_DRIVER_2,
    output wire         P_TX_LANE_PD_DRIVER_3,
    output wire         P_TX_LANE_PD_PISO_0,
    output wire         P_TX_LANE_PD_PISO_1,
    output wire         P_TX_LANE_PD_PISO_2,
    output wire         P_TX_LANE_PD_PISO_3,
    output wire [2 : 0] P_TX_RATE_0,
    output wire [2 : 0] P_TX_RATE_1,
    output wire [2 : 0] P_TX_RATE_2,
    output wire [2 : 0] P_TX_RATE_3,
    output wire         P_TX_PMA_RST_0,
    output wire         P_TX_PMA_RST_1,
    output wire         P_TX_PMA_RST_2,
    output wire         P_TX_PMA_RST_3,
    output wire         P_PCS_TX_RST_0,
    output wire         P_PCS_TX_RST_1,
    output wire         P_PCS_TX_RST_2,
    output wire         P_PCS_TX_RST_3,
    output reg          P_LANE_SYNC_0,
    output reg          P_LANE_SYNC_1,
    output reg          P_RATE_CHANGE_TCLK_ON_0,
    output reg          P_RATE_CHANGE_TCLK_ON_1
);

    localparam PLL_LOCK_RISE_CNTR_WIDTH = 12;
    localparam PLL_LOCK_RISE_CNTR_VALUE = 2048;

    //---------------------------------------------------
    // 内部信号
    //---------------------------------------------------
    wire [  4-1 : 0] lane_pd_rstn;
    wire             i_pll_done_ch0;
    wire             i_pll_done_ch1;
    wire             i_pll_done_ch2;
    wire             i_pll_done_ch3;
    wire [  4-1 : 0] i_tx_rate_chng;
    wire [  4-1 : 0] i_txlane_rstn;
    wire [  4-1 : 0] i_pll_lock_tx;
    wire [4*3-1 : 0] l_txckdiv;
    wire [  4-1 : 0] s_txlane_rstn;
    wire [  4-1 : 0] s_pll_lock_tx;
    wire [  4-1 : 0] s_pll_lock_tx_deb;
    wire [  4-1 : 0] l_pll_lock_tx_deb;
    wire             pll0_sync_ch0;
    wire             pll0_sync_ch1;
    wire             pll0_sync_ch2;
    wire             pll0_sync_ch3;
    wire             pll1_sync_ch0;
    wire             pll1_sync_ch1;
    wire             pll1_sync_ch2;
    wire             pll1_sync_ch3;
    wire             pll0_rate_change_ch0;
    wire             pll0_rate_change_ch1;
    wire             pll0_rate_change_ch2;
    wire             pll0_rate_change_ch3;
    wire             pll1_rate_change_ch0;
    wire             pll1_rate_change_ch1;
    wire             pll1_rate_change_ch2;
    wire             pll1_rate_change_ch3;
    wire             LANE_SYNC_0;
    wire             LANE_SYNC_1;
    wire             RATE_CHANGE_TCLK_ON_0;
    wire             RATE_CHANGE_TCLK_ON_1;
    // 发送状态机输出
    wire [  4-1 : 0] o_tx_lane_pd_clkpath;
    wire [  4-1 : 0] o_tx_lane_pd_drive;
    wire [  4-1 : 0] o_tx_lane_pd_piso;
    wire [  4-1 : 0] o_lane_sync;
    wire [  4-1 : 0] o_rate_change_on;
    wire [4*3-1 : 0] o_tx_ckdiv;
    wire [  4-1 : 0] o_tx_pma_rst;
    wire [  4-1 : 0] o_pcs_tx_rst;
    wire [  4-1 : 0] p_txlane_done;
    wire [  4-1 : 0] p_txckdiv_done;
    // 发送输出
    wire [  4-1 : 0] p_tx_lane_pd_clkpath;
    wire [  4-1 : 0] p_tx_lane_pd_drive;
    wire [  4-1 : 0] p_tx_lane_pd_piso;
    wire [  4-1 : 0] p_lane_sync;
    wire [  4-1 : 0] p_rate_change_on;
    wire [4*3-1 : 0] p_tx_ckdiv;
    wire [  4-1 : 0] p_tx_pma_rst;
    wire [  4-1 : 0] p_pcs_tx_rst;
    wire [  4-1 : 0] o_txlane_done;
    wire [  4-1 : 0] o_txckdiv_done;
    // 复位同步
    reg              lane_sync_0_ff;
    reg              lane_sync_1_ff;
    reg              rate_change_tclk_on_0_ff;
    reg              rate_change_tclk_on_1_ff;

    //---------------------------------------------------
    // 时序与组合逻辑
    //---------------------------------------------------
    // 通道 PLL 选择
    assign i_pll_done_ch0 = (CH0_TX_PLL_SEL == 0) ? i_pll_done_0 : i_pll_done_1;
    assign i_pll_done_ch1 = (CH1_TX_PLL_SEL == 0) ? i_pll_done_0 : i_pll_done_1;
    assign i_pll_done_ch2 = (CH2_TX_PLL_SEL == 0) ? i_pll_done_0 : i_pll_done_1;
    assign i_pll_done_ch3 = (CH3_TX_PLL_SEL == 0) ? i_pll_done_0 : i_pll_done_1;

    // 信号生成
    assign i_txlane_rstn = {~i_txlane_rst_3, ~i_txlane_rst_2, ~i_txlane_rst_1, ~i_txlane_rst_0};
    assign i_pll_lock_tx = {
        i_pll_lock_tx_3, i_pll_lock_tx_2, i_pll_lock_tx_1, i_pll_lock_tx_0
    };  // 外部 PLL 指示信号

    // 同步及消抖信号
    genvar i;
    generate
        for (i = 0; i < 4; i = i + 1) begin : SYNC_TXLANE
            ipm2l_hsstlp_rst_sync_v1_0 txlane_rstn_sync (
                .clk(clk),
                .rst_n(i_txlane_rstn[i]),
                .sig_async(1'b1),
                .sig_synced(s_txlane_rstn[i])
            );
            ipm2l_hsstlp_rst_sync_v1_0 i_pll_lock_rstn_sync (
                .clk(clk),
                .rst_n(lane_pd_rstn[i]),
                .sig_async(i_pll_lock_tx[i]),
                .sig_synced(s_pll_lock_tx[i])
            );
            ipm2l_hsstlp_rst_debounce_v1_0 #(
                .RISE_CNTR_WIDTH(PLL_LOCK_RISE_CNTR_WIDTH),
                .RISE_CNTR_VALUE(PLL_LOCK_RISE_CNTR_VALUE)
            ) pll_lock_deb (
                .clk(clk),
                .rst_n(lane_pd_rstn[i]),
                .signal_b(s_pll_lock_tx[i]),
                .signal_deb(s_pll_lock_tx_deb[i])
            );
        end
    endgenerate

    // 发送通道复位状态机例化

    generate
        if (CH0_TX_ENABLE == "TRUE") begin : TXLANE0_ENABLE  // 通道已启用
            ipm2l_hsstlp_txlane_rst_fsm_v1_6 #(
                .LANE_BONDING           (CH0_MULT_LANE_MODE),
                .FREE_CLOCK_FREQ        (FREE_CLOCK_FREQ),
                .P_LX_TX_CKDIV          (P_LX_TX_CKDIV_0),
                .PCS_TX_CLK_EXPLL_USE_CH(PCS_TX_CLK_EXPLL_USE_CH0)
            ) txlane_rst_fsm0 (
                .clk                 (clk),                      // 自由运行时钟
                .rst_n               (lane_pd_rstn[0]),          // 通道掉电复位使用 pll_done。
                .i_tx_rate_chng      (i_tx_rate_chng[0]),        // 发送速率切换信号
                .i_txckdiv           (l_txckdiv[0*3+:3]),
                .i_pll_lock_tx       (l_pll_lock_tx_deb[0]),
                .i_txlane_rst_n      (s_txlane_rstn[0]),
                .P_TX_LANE_PD_CLKPATH(o_tx_lane_pd_clkpath[0]),
                .P_TX_LANE_PD_DRIVER (o_tx_lane_pd_drive[0]),
                .P_TX_LANE_PD_PISO   (o_tx_lane_pd_piso[0]),
                .P_TX_RATE           (o_tx_ckdiv[0*3+:3]),
                .P_TX_PMA_RST        (o_tx_pma_rst[0]),
                .P_PCS_TX_RST        (o_pcs_tx_rst[0]),
                .o_txlane_done       (p_txlane_done[0]),
                .o_txckdiv_done      (p_txckdiv_done[0]),
                .lane_sync           (o_lane_sync[0]),           // 同步控制
                .rate_change_on      (o_rate_change_on[0])       // 速率切换控制
            );
        end else begin : TXLANE0_DISABLE  // 通道未启用
            assign o_tx_lane_pd_clkpath[0] = 1'b1;
            assign o_tx_lane_pd_drive[0]   = 1'b1;
            assign o_tx_lane_pd_piso[0]    = 1'b1;
            assign o_lane_sync[0]          = 1'b0;
            assign o_rate_change_on[0]     = 1'b1;
            assign o_tx_ckdiv[0*3+:3]      = 3'b0;
            assign o_tx_pma_rst[0]         = 1'b1;
            assign o_pcs_tx_rst[0]         = 1'b1;
            assign p_txlane_done[0]        = 1'b0;
            assign p_txckdiv_done[0]       = 1'b0;
        end
    endgenerate

    generate
        if ((CH1_TX_ENABLE == "TRUE") && (CH1_MULT_LANE_MODE == 1)) begin : TXLANE1_ENABLE  // 通道启用且未绑定
            ipm2l_hsstlp_txlane_rst_fsm_v1_6 #(
                .LANE_BONDING           (CH1_MULT_LANE_MODE),
                .FREE_CLOCK_FREQ        (FREE_CLOCK_FREQ),
                .P_LX_TX_CKDIV          (P_LX_TX_CKDIV_1),
                .PCS_TX_CLK_EXPLL_USE_CH(PCS_TX_CLK_EXPLL_USE_CH1)
            ) txlane_rst_fsm1 (
                .clk                 (clk),
                .rst_n               (lane_pd_rstn[1]),
                .i_tx_rate_chng      (i_tx_rate_chng[1]),
                .i_txckdiv           (l_txckdiv[1*3+:3]),
                .i_pll_lock_tx       (l_pll_lock_tx_deb[1]),
                .i_txlane_rst_n      (s_txlane_rstn[1]),
                .P_TX_LANE_PD_CLKPATH(o_tx_lane_pd_clkpath[1]),
                .P_TX_LANE_PD_DRIVER (o_tx_lane_pd_drive[1]),
                .P_TX_LANE_PD_PISO   (o_tx_lane_pd_piso[1]),
                .P_TX_RATE           (o_tx_ckdiv[1*3+:3]),
                .P_TX_PMA_RST        (o_tx_pma_rst[1]),
                .P_PCS_TX_RST        (o_pcs_tx_rst[1]),
                .o_txlane_done       (p_txlane_done[1]),
                .o_txckdiv_done      (p_txckdiv_done[1]),
                .lane_sync           (o_lane_sync[1]),
                .rate_change_on      (o_rate_change_on[1])
            );
        end else begin : TXLANE1_DISABLE  // 通道禁用或共用通道 0 状态机
            assign o_tx_lane_pd_clkpath[1] = 1'b1;
            assign o_tx_lane_pd_drive[1]   = 1'b1;
            assign o_tx_lane_pd_piso[1]    = 1'b1;
            assign o_lane_sync[1]          = 1'b0;
            assign o_rate_change_on[1]     = 1'b1;
            assign o_tx_ckdiv[1*3+:3]      = 3'b0;
            assign o_tx_pma_rst[1]         = 1'b1;
            assign o_pcs_tx_rst[1]         = 1'b1;
            assign p_txlane_done[1]        = 1'b0;
            assign p_txckdiv_done[1]       = 1'b0;
        end
    endgenerate

    generate
        if((CH2_TX_ENABLE=="TRUE") && (CH0_MULT_LANE_MODE  != 4 )) begin : TXLANE2_ENABLE // 通道启用且未作四通道绑定
            ipm2l_hsstlp_txlane_rst_fsm_v1_6 #(
                .LANE_BONDING           (CH2_MULT_LANE_MODE),
                .FREE_CLOCK_FREQ        (FREE_CLOCK_FREQ),
                .P_LX_TX_CKDIV          (P_LX_TX_CKDIV_2),
                .PCS_TX_CLK_EXPLL_USE_CH(PCS_TX_CLK_EXPLL_USE_CH2)
            ) txlane_rst_fsm2 (
                .clk                 (clk),
                .rst_n               (lane_pd_rstn[2]),
                .i_tx_rate_chng      (i_tx_rate_chng[2]),
                .i_txckdiv           (l_txckdiv[2*3+:3]),
                .i_pll_lock_tx       (l_pll_lock_tx_deb[2]),
                .i_txlane_rst_n      (s_txlane_rstn[2]),
                .P_TX_LANE_PD_CLKPATH(o_tx_lane_pd_clkpath[2]),
                .P_TX_LANE_PD_DRIVER (o_tx_lane_pd_drive[2]),
                .P_TX_LANE_PD_PISO   (o_tx_lane_pd_piso[2]),
                .P_TX_RATE           (o_tx_ckdiv[2*3+:3]),
                .P_TX_PMA_RST        (o_tx_pma_rst[2]),
                .P_PCS_TX_RST        (o_pcs_tx_rst[2]),
                .o_txlane_done       (p_txlane_done[2]),
                .o_txckdiv_done      (p_txckdiv_done[2]),
                .lane_sync           (o_lane_sync[2]),
                .rate_change_on      (o_rate_change_on[2])
            );
        end else begin : TXLANE2_DISABLE  // 通道禁用或共用通道 0 状态机
            assign o_tx_lane_pd_clkpath[2] = 1'b1;
            assign o_tx_lane_pd_drive[2]   = 1'b1;
            assign o_tx_lane_pd_piso[2]    = 1'b1;
            assign o_lane_sync[2]          = 1'b0;
            assign o_rate_change_on[2]     = 1'b1;
            assign o_tx_ckdiv[2*3+:3]      = 3'b0;
            assign o_tx_pma_rst[2]         = 1'b1;
            assign o_pcs_tx_rst[2]         = 1'b1;
            assign p_txlane_done[2]        = 1'b0;
            assign p_txckdiv_done[2]       = 1'b0;
        end
    endgenerate

    generate
        if ((CH3_TX_ENABLE == "TRUE") && (CH3_MULT_LANE_MODE == 1)) begin : TXLANE3_ENABLE  // 通道启用且未绑定
            ipm2l_hsstlp_txlane_rst_fsm_v1_6 #(
                .LANE_BONDING           (CH3_MULT_LANE_MODE),
                .FREE_CLOCK_FREQ        (FREE_CLOCK_FREQ),
                .P_LX_TX_CKDIV          (P_LX_TX_CKDIV_3),
                .PCS_TX_CLK_EXPLL_USE_CH(PCS_TX_CLK_EXPLL_USE_CH3)
            ) txlane_rst_fsm3 (
                .clk                 (clk),
                .rst_n               (lane_pd_rstn[3]),
                .i_tx_rate_chng      (i_tx_rate_chng[3]),
                .i_txckdiv           (l_txckdiv[3*3+:3]),
                .i_pll_lock_tx       (l_pll_lock_tx_deb[3]),
                .i_txlane_rst_n      (s_txlane_rstn[3]),
                .P_TX_LANE_PD_CLKPATH(o_tx_lane_pd_clkpath[3]),
                .P_TX_LANE_PD_DRIVER (o_tx_lane_pd_drive[3]),
                .P_TX_LANE_PD_PISO   (o_tx_lane_pd_piso[3]),
                .P_TX_RATE           (o_tx_ckdiv[3*3+:3]),
                .P_TX_PMA_RST        (o_tx_pma_rst[3]),
                .P_PCS_TX_RST        (o_pcs_tx_rst[3]),
                .o_txlane_done       (p_txlane_done[3]),
                .o_txckdiv_done      (p_txckdiv_done[3]),
                .lane_sync           (o_lane_sync[3]),
                .rate_change_on      (o_rate_change_on[3])
            );
        end else begin : TXLANE3_DISABLE  // 通道未启用
            assign o_tx_lane_pd_clkpath[3] = 1'b1;
            assign o_tx_lane_pd_drive[3]   = 1'b1;
            assign o_tx_lane_pd_piso[3]    = 1'b1;
            assign o_lane_sync[3]          = 1'b0;
            assign o_rate_change_on[3]     = 1'b1;
            assign o_tx_ckdiv[3*3+:3]      = 3'b0;
            assign o_tx_pma_rst[3]         = 1'b1;
            assign o_pcs_tx_rst[3]         = 1'b1;
            assign p_txlane_done[3]        = 1'b0;
            assign p_txckdiv_done[3]       = 1'b0;
        end
    endgenerate

    generate
        if (CH0_MULT_LANE_MODE == 4) begin : FOUR_LANE_MODE
            // 来自用户侧

            assign lane_pd_rstn         = {3'b0, i_pll_done_ch0};
            assign i_tx_rate_chng       = {3'b0, i_tx_rate_chng_0};
            assign l_txckdiv            = {9'b0, i_txckdiv_0};
            assign l_pll_lock_tx_deb    = {3'b0, s_pll_lock_tx_deb[0]};
            // 送往 HSST
            assign p_tx_lane_pd_clkpath = {4{o_tx_lane_pd_clkpath[0]}};
            assign p_tx_lane_pd_drive   = {4{o_tx_lane_pd_drive[0]}};
            assign p_tx_lane_pd_piso    = {4{o_tx_lane_pd_piso[0]}};
            assign p_lane_sync          = {4{o_lane_sync[0]}};
            assign p_rate_change_on     = {4{o_rate_change_on[0]}};
            assign p_tx_ckdiv           = {4{o_tx_ckdiv[2:0]}};
            assign p_tx_pma_rst         = {4{o_tx_pma_rst[0]}};
            assign p_pcs_tx_rst         = {4{o_pcs_tx_rst[0]}};
            assign o_txlane_done        = {4{p_txlane_done[0]}};
            assign o_txckdiv_done       = {4{p_txckdiv_done[0]}};
        end else if (CH0_MULT_LANE_MODE == 2 && CH2_MULT_LANE_MODE == 2) begin : TWO_LANE_MODE
            // 来自用户侧

            assign lane_pd_rstn         = {1'b0, i_pll_done_ch2, 1'b0, i_pll_done_ch0};
            assign i_tx_rate_chng       = {1'b0, i_tx_rate_chng_2, 1'b0, i_tx_rate_chng_0};
            assign l_txckdiv            = {3'b0, i_txckdiv_2, 3'b0, i_txckdiv_0};
            assign l_pll_lock_tx_deb    = {1'b0, s_pll_lock_tx_deb[2], 1'b0, s_pll_lock_tx_deb[0]};
            // 送往 HSST
            assign p_tx_lane_pd_clkpath = {{2{o_tx_lane_pd_clkpath[2]}}, {2{o_tx_lane_pd_clkpath[0]}}};
            assign p_tx_lane_pd_drive   = {{2{o_tx_lane_pd_drive[2]}}, {2{o_tx_lane_pd_drive[0]}}};
            assign p_tx_lane_pd_piso    = {{2{o_tx_lane_pd_piso[2]}}, {2{o_tx_lane_pd_piso[0]}}};
            assign p_lane_sync          = {{2{o_lane_sync[2]}}, {2{o_lane_sync[0]}}};
            assign p_rate_change_on     = {{2{o_rate_change_on[2]}}, {2{o_rate_change_on[0]}}};
            assign p_tx_ckdiv           = {{2{o_tx_ckdiv[8:6]}}, {2{o_tx_ckdiv[2:0]}}};
            assign p_tx_pma_rst         = {{2{o_tx_pma_rst[2]}}, {2{o_tx_pma_rst[0]}}};
            assign p_pcs_tx_rst         = {{2{o_pcs_tx_rst[2]}}, {2{o_pcs_tx_rst[0]}}};
            assign o_txlane_done        = {{2{p_txlane_done[2]}}, {2{p_txlane_done[0]}}};
            assign o_txckdiv_done       = {{2{p_txckdiv_done[2]}}, {2{p_txckdiv_done[0]}}};
        end else if (CH0_MULT_LANE_MODE == 2) begin : TWO_LANE_MODE0
            // 来自用户侧

            assign lane_pd_rstn = {i_pll_done_ch3, i_pll_done_ch2, 1'b0, i_pll_done_ch0};
            assign i_tx_rate_chng = {i_tx_rate_chng_3, i_tx_rate_chng_2, 1'b0, i_tx_rate_chng_0};
            assign l_txckdiv = {i_txckdiv_3, i_txckdiv_2, 3'b0, i_txckdiv_0};
            assign l_pll_lock_tx_deb = {s_pll_lock_tx_deb[3], s_pll_lock_tx_deb[2], 1'b0, s_pll_lock_tx_deb[0]};
            // 送往 HSST
            assign p_tx_lane_pd_clkpath = {
                o_tx_lane_pd_clkpath[3], o_tx_lane_pd_clkpath[2], {2{o_tx_lane_pd_clkpath[0]}}
            };
            assign p_tx_lane_pd_drive = {o_tx_lane_pd_drive[3], o_tx_lane_pd_drive[2], {2{o_tx_lane_pd_drive[0]}}};
            assign p_tx_lane_pd_piso = {o_tx_lane_pd_piso[3], o_tx_lane_pd_piso[2], {2{o_tx_lane_pd_piso[0]}}};
            assign p_lane_sync = {o_lane_sync[3], o_lane_sync[2], {2{o_lane_sync[0]}}};
            assign p_rate_change_on = {o_rate_change_on[3], o_rate_change_on[2], {2{o_rate_change_on[0]}}};
            assign p_tx_ckdiv = {o_tx_ckdiv[11:9], o_tx_ckdiv[8:6], {2{o_tx_ckdiv[2:0]}}};
            assign p_tx_pma_rst = {o_tx_pma_rst[3], o_tx_pma_rst[2], {2{o_tx_pma_rst[0]}}};
            assign p_pcs_tx_rst = {o_pcs_tx_rst[3], o_pcs_tx_rst[2], {2{o_pcs_tx_rst[0]}}};
            assign o_txlane_done = {p_txlane_done[3], p_txlane_done[2], {2{p_txlane_done[0]}}};
            assign o_txckdiv_done = {p_txckdiv_done[3], p_txckdiv_done[2], {2{p_txckdiv_done[0]}}};
        end else if (CH2_MULT_LANE_MODE == 2) begin : TWO_LANE_MODE1
            // 来自用户侧

            assign lane_pd_rstn = {1'b0, i_pll_done_ch2, i_pll_done_ch1, i_pll_done_ch0};
            assign i_tx_rate_chng = {1'b0, i_tx_rate_chng_2, i_tx_rate_chng_1, i_tx_rate_chng_0};
            assign l_txckdiv = {3'b0, i_txckdiv_2, i_txckdiv_1, i_txckdiv_0};
            assign l_pll_lock_tx_deb = {1'b0, s_pll_lock_tx_deb[2], s_pll_lock_tx_deb[1], s_pll_lock_tx_deb[0]};
            // 送往 HSST
            assign p_tx_lane_pd_clkpath = {
                {2{o_tx_lane_pd_clkpath[2]}}, o_tx_lane_pd_clkpath[1], o_tx_lane_pd_clkpath[0]
            };
            assign p_tx_lane_pd_drive = {{2{o_tx_lane_pd_drive[2]}}, o_tx_lane_pd_drive[1], o_tx_lane_pd_drive[0]};
            assign p_tx_lane_pd_piso = {{2{o_tx_lane_pd_piso[2]}}, o_tx_lane_pd_piso[1], o_tx_lane_pd_piso[0]};
            assign p_lane_sync = {{2{o_lane_sync[2]}}, o_lane_sync[1], o_lane_sync[0]};
            assign p_rate_change_on = {{2{o_rate_change_on[2]}}, o_rate_change_on[1], o_rate_change_on[0]};
            assign p_tx_ckdiv = {{2{o_tx_ckdiv[8:6]}}, o_tx_ckdiv[5:3], o_tx_ckdiv[2:0]};
            assign p_tx_pma_rst = {{2{o_tx_pma_rst[2]}}, o_tx_pma_rst[1], o_tx_pma_rst[0]};
            assign p_pcs_tx_rst = {{2{o_pcs_tx_rst[2]}}, o_pcs_tx_rst[1], o_pcs_tx_rst[0]};
            assign o_txlane_done = {{2{p_txlane_done[2]}}, p_txlane_done[1], p_txlane_done[0]};
            assign o_txckdiv_done = {{2{p_txckdiv_done[2]}}, p_txckdiv_done[1], p_txckdiv_done[0]};
        end else begin : ONE_LANE_MODE
            // 来自用户侧

            assign lane_pd_rstn = {i_pll_done_ch3, i_pll_done_ch2, i_pll_done_ch1, i_pll_done_ch0};
            assign i_tx_rate_chng = {i_tx_rate_chng_3, i_tx_rate_chng_2, i_tx_rate_chng_1, i_tx_rate_chng_0};
            assign l_txckdiv = {i_txckdiv_3, i_txckdiv_2, i_txckdiv_1, i_txckdiv_0};
            assign l_pll_lock_tx_deb = {
                s_pll_lock_tx_deb[3], s_pll_lock_tx_deb[2], s_pll_lock_tx_deb[1], s_pll_lock_tx_deb[0]
            };
            // 送往 HSST
            assign p_tx_lane_pd_clkpath = {
                o_tx_lane_pd_clkpath[3], o_tx_lane_pd_clkpath[2], o_tx_lane_pd_clkpath[1], o_tx_lane_pd_clkpath[0]
            };
            assign p_tx_lane_pd_drive = {
                o_tx_lane_pd_drive[3], o_tx_lane_pd_drive[2], o_tx_lane_pd_drive[1], o_tx_lane_pd_drive[0]
            };
            assign p_tx_lane_pd_piso = {
                o_tx_lane_pd_piso[3], o_tx_lane_pd_piso[2], o_tx_lane_pd_piso[1], o_tx_lane_pd_piso[0]
            };
            assign p_lane_sync = {o_lane_sync[3], o_lane_sync[2], o_lane_sync[1], o_lane_sync[0]};
            assign p_rate_change_on = {
                o_rate_change_on[3], o_rate_change_on[2], o_rate_change_on[1], o_rate_change_on[0]
            };
            assign p_tx_ckdiv = {o_tx_ckdiv[11:9], o_tx_ckdiv[8:6], o_tx_ckdiv[5:3], o_tx_ckdiv[2:0]};
            assign p_tx_pma_rst = {o_tx_pma_rst[3], o_tx_pma_rst[2], o_tx_pma_rst[1], o_tx_pma_rst[0]};
            assign p_pcs_tx_rst = {o_pcs_tx_rst[3], o_pcs_tx_rst[2], o_pcs_tx_rst[1], o_pcs_tx_rst[0]};
            assign o_txlane_done = {p_txlane_done[3], p_txlane_done[2], p_txlane_done[1], p_txlane_done[0]};
            assign o_txckdiv_done = {p_txckdiv_done[3], p_txckdiv_done[2], p_txckdiv_done[1], p_txckdiv_done[0]};
        end
    endgenerate

    assign o_txlane_done_0 = o_txlane_done[0];
    assign o_txlane_done_1 = o_txlane_done[1];
    assign o_txlane_done_2 = o_txlane_done[2];
    assign o_txlane_done_3 = o_txlane_done[3];
    assign o_txckdiv_done_0 = o_txckdiv_done[0];
    assign o_txckdiv_done_1 = o_txckdiv_done[1];
    assign o_txckdiv_done_2 = o_txckdiv_done[2];
    assign o_txckdiv_done_3 = o_txckdiv_done[3];
    assign P_TX_LANE_PD_CLKPATH_0 = p_tx_lane_pd_clkpath[0];
    assign P_TX_LANE_PD_CLKPATH_1 = p_tx_lane_pd_clkpath[1];
    assign P_TX_LANE_PD_CLKPATH_2 = p_tx_lane_pd_clkpath[2];
    assign P_TX_LANE_PD_CLKPATH_3 = p_tx_lane_pd_clkpath[3];
    assign P_TX_LANE_PD_DRIVER_0 = p_tx_lane_pd_drive[0];
    assign P_TX_LANE_PD_DRIVER_1 = p_tx_lane_pd_drive[1];
    assign P_TX_LANE_PD_DRIVER_2 = p_tx_lane_pd_drive[2];
    assign P_TX_LANE_PD_DRIVER_3 = p_tx_lane_pd_drive[3];
    assign P_TX_LANE_PD_PISO_0 = p_tx_lane_pd_piso[0];
    assign P_TX_LANE_PD_PISO_1 = p_tx_lane_pd_piso[1];
    assign P_TX_LANE_PD_PISO_2 = p_tx_lane_pd_piso[2];
    assign P_TX_LANE_PD_PISO_3 = p_tx_lane_pd_piso[3];
    assign P_TX_RATE_0 = p_tx_ckdiv[2:0];
    assign P_TX_RATE_1 = p_tx_ckdiv[5:3];
    assign P_TX_RATE_2 = p_tx_ckdiv[8:6];
    assign P_TX_RATE_3 = p_tx_ckdiv[11:9];
    assign P_TX_PMA_RST_0 = p_tx_pma_rst[0];
    assign P_TX_PMA_RST_1 = p_tx_pma_rst[1];
    assign P_TX_PMA_RST_2 = p_tx_pma_rst[2];
    assign P_TX_PMA_RST_3 = p_tx_pma_rst[3];
    assign P_PCS_TX_RST_0 = p_pcs_tx_rst[0];
    assign P_PCS_TX_RST_1 = p_pcs_tx_rst[1];
    assign P_PCS_TX_RST_2 = p_pcs_tx_rst[2];
    assign P_PCS_TX_RST_3 = p_pcs_tx_rst[3];
    // 生成 PLL 同步与速率切换控制
    assign pll0_sync_ch0 = (CH0_TX_PLL_SEL == 0) ? p_lane_sync[0] : 1'b0;
    assign pll0_sync_ch1 = (CH1_TX_PLL_SEL == 0) ? p_lane_sync[1] : 1'b0;
    assign pll0_sync_ch2 = (CH2_TX_PLL_SEL == 0) ? p_lane_sync[2] : 1'b0;
    assign pll0_sync_ch3 = (CH3_TX_PLL_SEL == 0) ? p_lane_sync[3] : 1'b0;
    assign pll1_sync_ch0 = (CH0_TX_PLL_SEL == 0) ? 1'b0 : p_lane_sync[0];
    assign pll1_sync_ch1 = (CH1_TX_PLL_SEL == 0) ? 1'b0 : p_lane_sync[1];
    assign pll1_sync_ch2 = (CH2_TX_PLL_SEL == 0) ? 1'b0 : p_lane_sync[2];
    assign pll1_sync_ch3 = (CH3_TX_PLL_SEL == 0) ? 1'b0 : p_lane_sync[3];
    assign LANE_SYNC_0 = pll0_sync_ch0 || pll0_sync_ch1 || pll0_sync_ch2 || pll0_sync_ch3;
    assign LANE_SYNC_1 = pll1_sync_ch0 || pll1_sync_ch1 || pll1_sync_ch2 || pll1_sync_ch3;
    assign pll0_rate_change_ch0 = (CH0_TX_PLL_SEL == 0) ? p_rate_change_on[0] : 1'b1;
    assign pll0_rate_change_ch1 = (CH1_TX_PLL_SEL == 0) ? p_rate_change_on[1] : 1'b1;
    assign pll0_rate_change_ch2 = (CH2_TX_PLL_SEL == 0) ? p_rate_change_on[2] : 1'b1;
    assign pll0_rate_change_ch3 = (CH3_TX_PLL_SEL == 0) ? p_rate_change_on[3] : 1'b1;
    assign pll1_rate_change_ch0 = (CH0_TX_PLL_SEL == 0) ? 1'b1 : p_rate_change_on[0];
    assign pll1_rate_change_ch1 = (CH1_TX_PLL_SEL == 0) ? 1'b1 : p_rate_change_on[1];
    assign pll1_rate_change_ch2 = (CH2_TX_PLL_SEL == 0) ? 1'b1 : p_rate_change_on[2];
    assign pll1_rate_change_ch3 = (CH3_TX_PLL_SEL == 0) ? 1'b1 : p_rate_change_on[3];
    assign RATE_CHANGE_TCLK_ON_0   = pll0_rate_change_ch0 && pll0_rate_change_ch1 && pll0_rate_change_ch2 && pll0_rate_change_ch3 ;
    assign RATE_CHANGE_TCLK_ON_1   = pll1_rate_change_ch0 && pll1_rate_change_ch1 && pll1_rate_change_ch2 && pll1_rate_change_ch3 ;

    always @(posedge clk or negedge i_pll_done_0) begin
        if (!i_pll_done_0) begin
            lane_sync_0_ff           <= 1'b0;
            P_LANE_SYNC_0            <= 1'b0;
            rate_change_tclk_on_0_ff <= 1'b1;
            P_RATE_CHANGE_TCLK_ON_0  <= 1'b1;
        end else begin
            lane_sync_0_ff           <= LANE_SYNC_0;
            P_LANE_SYNC_0            <= lane_sync_0_ff;
            rate_change_tclk_on_0_ff <= RATE_CHANGE_TCLK_ON_0;
            P_RATE_CHANGE_TCLK_ON_0  <= rate_change_tclk_on_0_ff;
        end
    end

    always @(posedge clk or negedge i_pll_done_1) begin
        if (!i_pll_done_1) begin
            lane_sync_1_ff           <= 1'b0;
            P_LANE_SYNC_1            <= 1'b0;
            rate_change_tclk_on_1_ff <= 1'b1;
            P_RATE_CHANGE_TCLK_ON_1  <= 1'b1;
        end else begin
            lane_sync_1_ff           <= LANE_SYNC_1;
            P_LANE_SYNC_1            <= lane_sync_1_ff;
            rate_change_tclk_on_1_ff <= RATE_CHANGE_TCLK_ON_1;
            P_RATE_CHANGE_TCLK_ON_1  <= rate_change_tclk_on_1_ff;
        end
    end

endmodule
