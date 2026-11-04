//---------------------------------------------------

// Copyright (c) 2019 PANGO MICROSYSTEMS, INC
// ALL RIGHTS REVERVED.

// THE SOURCE CODE CONTAINED HEREIN IS PROPRIETARY TO PANGO MICROSYSTEMS, INC.
// IT SHALL NOT BE REPRODUCED OR DISCLOSED IN WHOLE OR IN PART OR USED BY
// PARTIES WITHOUT WRITTEN AUTHORIZATION FROM THE OWNER.

//---------------------------------------------------

//---------------------------------------------------
`timescale 1ns / 1ps
module ipm2l_hsstlp_rst_v1_6 #(
    parameter INNER_RST_EN = "TRUE",  // TRUE：HSST 自动控制复位；FALSE：用户控制复位。
    parameter FREE_CLOCK_FREQ = 100,  // 自由运行时钟频率来自配置界面，范围 0～200 MHz。
    parameter CH0_TX_ENABLE = "TRUE",  // 通道 0 发送复位逻辑使能。
    parameter CH1_TX_ENABLE = "TRUE",  // 通道 1 发送复位逻辑使能。
    parameter CH2_TX_ENABLE = "TRUE",  // 通道 2 发送复位逻辑使能。
    parameter CH3_TX_ENABLE = "TRUE",  // 通道 3 发送复位逻辑使能。
    parameter CH0_RX_ENABLE = "TRUE",  // 通道 0 接收复位逻辑使能。
    parameter CH1_RX_ENABLE = "TRUE",  // 通道 1 接收复位逻辑使能。
    parameter CH2_RX_ENABLE = "TRUE",  // 通道 2 接收复位逻辑使能。
    parameter CH3_RX_ENABLE = "TRUE",  // 通道 3 接收复位逻辑使能。
    parameter CH0_MULT_LANE_MODE = 1,  // 通道 0 配置：1 单通道，2 双通道，4 四通道。
    parameter CH1_MULT_LANE_MODE = 1,  // 通道 1 配置：1 单通道，2 双通道，4 四通道。
    parameter CH2_MULT_LANE_MODE = 1,  // 通道 2 配置：1 单通道，2 双通道，4 四通道。
    parameter CH3_MULT_LANE_MODE = 1,  // 通道 3 配置：1 单通道，2 双通道，4 四通道。
    parameter CH0_RXPCS_ALIGN_TIMER = 10000,  // 字对齐等待超时后复位接收 PMA。
    parameter CH1_RXPCS_ALIGN_TIMER = 10000,  // 字对齐等待超时后复位接收 PMA。
    parameter CH2_RXPCS_ALIGN_TIMER = 10000,  // 字对齐等待超时后复位接收 PMA。
    parameter CH3_RXPCS_ALIGN_TIMER = 10000,  // 字对齐等待超时后复位接收 PMA。
    parameter PCS_CH0_BYPASS_WORD_ALIGN = "FALSE",  // 通道 0 字对齐旁路使能。
    parameter PCS_CH1_BYPASS_WORD_ALIGN = "FALSE",  // 通道 1 字对齐旁路使能。
    parameter PCS_CH2_BYPASS_WORD_ALIGN = "FALSE",  // 通道 2 字对齐旁路使能。
    parameter PCS_CH3_BYPASS_WORD_ALIGN = "FALSE",  // 通道 3 字对齐旁路使能。
    parameter PCS_CH0_BYPASS_BONDING = "FALSE",  // 通道 0 通道绑定旁路使能。
    parameter PCS_CH1_BYPASS_BONDING = "FALSE",  // 通道 1 通道绑定旁路使能。
    parameter PCS_CH2_BYPASS_BONDING = "FALSE",  // 通道 2 通道绑定旁路使能。
    parameter PCS_CH3_BYPASS_BONDING = "FALSE",  // 通道 3 通道绑定旁路使能。
    parameter PCS_CH0_BYPASS_CTC = "TRUE",  // 通道 0 时钟补偿旁路使能。
    parameter PCS_CH1_BYPASS_CTC = "TRUE",  // 通道 1 时钟补偿旁路使能。
    parameter PCS_CH2_BYPASS_CTC = "TRUE",  // 通道 2 时钟补偿旁路使能。
    parameter PCS_CH3_BYPASS_CTC = "TRUE",  // 通道 3 时钟补偿旁路使能。
    parameter P_LX_TX_CKDIV_0 = 0,  // 发送端初始时钟分频值
    parameter P_LX_TX_CKDIV_1 = 0,  // 发送端初始时钟分频值
    parameter P_LX_TX_CKDIV_2 = 0,  // 发送端初始时钟分频值
    parameter P_LX_TX_CKDIV_3 = 0,  // 发送端初始时钟分频值
    parameter LX_RX_CKDIV_0 = 0,  // 接收端初始时钟分频值
    parameter LX_RX_CKDIV_1 = 0,  // 接收端初始时钟分频值
    parameter LX_RX_CKDIV_2 = 0,  // 接收端初始时钟分频值
    parameter LX_RX_CKDIV_3 = 0,  // 接收端初始时钟分频值
    parameter CH0_TX_PLL_SEL = 0,  // 通道 0 时钟选择：1 为 PLL1，0 为 PLL0。
    parameter CH1_TX_PLL_SEL = 0,  // 通道 1 时钟选择：1 为 PLL1，0 为 PLL0。
    parameter CH2_TX_PLL_SEL = 0,  // 通道 2 时钟选择：1 为 PLL1，0 为 PLL0。
    parameter CH3_TX_PLL_SEL = 0,  // 通道 3 时钟选择：1 为 PLL1，0 为 PLL0。
    parameter CH0_RX_PLL_SEL = 0,  // 通道 0 时钟选择：1 为 PLL1，0 为 PLL0。
    parameter CH1_RX_PLL_SEL = 0,  // 通道 1 时钟选择：1 为 PLL1，0 为 PLL0。
    parameter CH2_RX_PLL_SEL = 0,  // 通道 2 时钟选择：1 为 PLL1，0 为 PLL0。
    parameter CH3_RX_PLL_SEL = 0,  // 通道 3 时钟选择：1 为 PLL1，0 为 PLL0。
    parameter PLL_NUBER = 1,
    // Logos2 扩展信号
    // 不支持

    parameter PCS_TX_CLK_EXPLL_USE_CH0 = "FALSE",  // TRUE 表示使用逻辑侧 PLL。
    parameter PCS_TX_CLK_EXPLL_USE_CH1 = "FALSE",
    parameter PCS_TX_CLK_EXPLL_USE_CH2 = "FALSE",
    parameter PCS_TX_CLK_EXPLL_USE_CH3 = "FALSE",
    parameter PCS_RX_CLK_EXPLL_USE_CH0 = "FALSE",
    parameter PCS_RX_CLK_EXPLL_USE_CH1 = "FALSE",
    parameter PCS_RX_CLK_EXPLL_USE_CH2 = "FALSE",
    parameter PCS_RX_CLK_EXPLL_USE_CH3 = "FALSE"
) (
    // 两者均需要
    input  wire         i_pll_lock_tx_0,
    input  wire         i_pll_lock_tx_1,
    input  wire         i_pll_lock_tx_2,
    input  wire         i_pll_lock_tx_3,
    input  wire         i_pll_lock_rx_0,
    input  wire         i_pll_lock_rx_1,
    input  wire         i_pll_lock_rx_2,
    input  wire         i_pll_lock_rx_3,
    // 用户侧接口
    // 启用内部复位
    input  wire         i_free_clk,
    input  wire         i_pll_rst_0,
    input  wire         i_pll_rst_1,
    input  wire         i_wtchdg_clr_0,
    input  wire         i_wtchdg_clr_1,
    input  wire         i_txlane_rst_0,
    input  wire         i_txlane_rst_1,
    input  wire         i_txlane_rst_2,
    input  wire         i_txlane_rst_3,
    input  wire         i_rxlane_rst_0,
    input  wire         i_rxlane_rst_1,
    input  wire         i_rxlane_rst_2,
    input  wire         i_rxlane_rst_3,
    input  wire         i_tx_rate_chng_0,
    input  wire         i_tx_rate_chng_1,
    input  wire         i_tx_rate_chng_2,
    input  wire         i_tx_rate_chng_3,
    input  wire         i_rx_rate_chng_0,
    input  wire         i_rx_rate_chng_1,
    input  wire         i_rx_rate_chng_2,
    input  wire         i_rx_rate_chng_3,
    input  wire [1 : 0] i_txckdiv_0,
    input  wire [1 : 0] i_txckdiv_1,
    input  wire [1 : 0] i_txckdiv_2,
    input  wire [1 : 0] i_txckdiv_3,
    input  wire [1 : 0] i_rxckdiv_0,
    input  wire [1 : 0] i_rxckdiv_1,
    input  wire [1 : 0] i_rxckdiv_2,
    input  wire [1 : 0] i_rxckdiv_3,
    input  wire         i_pcs_cb_rst_0,
    input  wire         i_pcs_cb_rst_1,
    input  wire         i_pcs_cb_rst_2,
    input  wire         i_pcs_cb_rst_3,
    input  wire         i_hsstlp_fifo_clr_0,
    input  wire         i_hsstlp_fifo_clr_1,
    input  wire         i_hsstlp_fifo_clr_2,
    input  wire         i_hsstlp_fifo_clr_3,
    input  wire         i_force_rxfsm_det_0,        // 环回模式调试信号
    input  wire         i_force_rxfsm_det_1,        // 环回模式调试信号
    input  wire         i_force_rxfsm_det_2,        // 环回模式调试信号
    input  wire         i_force_rxfsm_det_3,        // 环回模式调试信号
    input  wire         i_force_rxfsm_lsm_0,        // 环回模式调试信号
    input  wire         i_force_rxfsm_lsm_1,        // 环回模式调试信号
    input  wire         i_force_rxfsm_lsm_2,        // 环回模式调试信号
    input  wire         i_force_rxfsm_lsm_3,        // 环回模式调试信号
    input  wire         i_force_rxfsm_cdr_0,        // 环回模式调试信号
    input  wire         i_force_rxfsm_cdr_1,        // 环回模式调试信号
    input  wire         i_force_rxfsm_cdr_2,        // 环回模式调试信号
    input  wire         i_force_rxfsm_cdr_3,        // 环回模式调试信号
    output wire [1 : 0] o_wtchdg_st_0,
    output wire [1 : 0] o_wtchdg_st_1,
    output wire         o_pll_done_0,
    output wire         o_pll_done_1,
    output wire         o_txlane_done_0,
    output wire         o_txlane_done_1,
    output wire         o_txlane_done_2,
    output wire         o_txlane_done_3,
    output wire         o_tx_ckdiv_done_0,
    output wire         o_tx_ckdiv_done_1,
    output wire         o_tx_ckdiv_done_2,
    output wire         o_tx_ckdiv_done_3,
    output wire         o_rxlane_done_0,
    output wire         o_rxlane_done_1,
    output wire         o_rxlane_done_2,
    output wire         o_rxlane_done_3,
    output wire         o_rx_ckdiv_done_0,
    output wire         o_rx_ckdiv_done_1,
    output wire         o_rx_ckdiv_done_2,
    output wire         o_rx_ckdiv_done_3,
    // 禁用内部复位
    input  wire         i_f_pllpowerdown_0,
    input  wire         i_f_pllpowerdown_1,
    input  wire         i_f_pll_rst_0,
    input  wire         i_f_pll_rst_1,
    input  wire         i_f_lane_sync_0,
    input  wire         i_f_lane_sync_1,
    input  wire         i_f_rate_change_tclk_on_0,
    input  wire         i_f_rate_change_tclk_on_1,
    input  wire         i_f_tx_lane_pd_clkpath_0,
    input  wire         i_f_tx_lane_pd_clkpath_1,
    input  wire         i_f_tx_lane_pd_clkpath_2,
    input  wire         i_f_tx_lane_pd_clkpath_3,
    input  wire         i_f_tx_pma_rst_0,
    input  wire         i_f_tx_pma_rst_1,
    input  wire         i_f_tx_pma_rst_2,
    input  wire         i_f_tx_pma_rst_3,
    input  wire         i_f_tx_lane_pd_piso_0,
    input  wire         i_f_tx_lane_pd_piso_1,
    input  wire         i_f_tx_lane_pd_piso_2,
    input  wire         i_f_tx_lane_pd_piso_3,
    input  wire         i_f_tx_lane_pd_driver_0,
    input  wire         i_f_tx_lane_pd_driver_1,
    input  wire         i_f_tx_lane_pd_driver_2,
    input  wire         i_f_tx_lane_pd_driver_3,
    input  wire [1 : 0] i_f_tx_ckdiv_0,
    input  wire [1 : 0] i_f_tx_ckdiv_1,
    input  wire [1 : 0] i_f_tx_ckdiv_2,
    input  wire [1 : 0] i_f_tx_ckdiv_3,
    input  wire         i_f_pcs_tx_rst_0,
    input  wire         i_f_pcs_tx_rst_1,
    input  wire         i_f_pcs_tx_rst_2,
    input  wire         i_f_pcs_tx_rst_3,
    input  wire         i_f_lane_pd_0,
    input  wire         i_f_lane_pd_1,
    input  wire         i_f_lane_pd_2,
    input  wire         i_f_lane_pd_3,
    input  wire         i_f_lane_rst_0,
    input  wire         i_f_lane_rst_1,
    input  wire         i_f_lane_rst_2,
    input  wire         i_f_lane_rst_3,
    input  wire         i_f_rx_lane_pd_0,
    input  wire         i_f_rx_lane_pd_1,
    input  wire         i_f_rx_lane_pd_2,
    input  wire         i_f_rx_lane_pd_3,
    input  wire         i_f_rx_pma_rst_0,
    input  wire         i_f_rx_pma_rst_1,
    input  wire         i_f_rx_pma_rst_2,
    input  wire         i_f_rx_pma_rst_3,
    input  wire         i_f_pcs_rx_rst_0,
    input  wire         i_f_pcs_rx_rst_1,
    input  wire         i_f_pcs_rx_rst_2,
    input  wire         i_f_pcs_rx_rst_3,
    input  wire [1 : 0] i_f_lx_rx_ckdiv_0,
    input  wire [1 : 0] i_f_lx_rx_ckdiv_1,
    input  wire [1 : 0] i_f_lx_rx_ckdiv_2,
    input  wire [1 : 0] i_f_lx_rx_ckdiv_3,
    input  wire         i_f_pcs_cb_rst_0,
    input  wire         i_f_pcs_cb_rst_1,
    input  wire         i_f_pcs_cb_rst_2,
    input  wire         i_f_pcs_cb_rst_3,

    // HSST 侧接口
    input wire P_PLL_READY_0,
    input wire P_PLL_READY_1,
    input wire P_RX_SIGDET_STATUS_0,
    input wire P_RX_SIGDET_STATUS_1,
    input wire P_RX_SIGDET_STATUS_2,
    input wire P_RX_SIGDET_STATUS_3,
    input wire P_RX_READY_0,
    input wire P_RX_READY_1,
    input wire P_RX_READY_2,
    input wire P_RX_READY_3,
    // 不支持

    input  wire         P_PCS_LSM_SYNCED_0,
    input  wire         P_PCS_LSM_SYNCED_1,
    input  wire         P_PCS_LSM_SYNCED_2,
    input  wire         P_PCS_LSM_SYNCED_3,
    input  wire         P_PCS_RX_MCB_STATUS_0,
    input  wire         P_PCS_RX_MCB_STATUS_1,
    input  wire         P_PCS_RX_MCB_STATUS_2,
    input  wire         P_PCS_RX_MCB_STATUS_3,
    output wire         P_PLLPOWERDOWN_0,
    output wire         P_PLLPOWERDOWN_1,
    output wire         P_PLL_RST_0,
    output wire         P_PLL_RST_1,
    output wire         P_LANE_SYNC_0,
    output wire         P_LANE_SYNC_1,
    output wire         P_RATE_CHANGE_TCLK_ON_0,
    output wire         P_RATE_CHANGE_TCLK_ON_1,
    output wire         P_TX_LANE_PD_CLKPATH_0,
    output wire         P_TX_LANE_PD_CLKPATH_1,
    output wire         P_TX_LANE_PD_CLKPATH_2,
    output wire         P_TX_LANE_PD_CLKPATH_3,
    output wire         P_TX_LANE_PD_PISO_0,
    output wire         P_TX_LANE_PD_PISO_1,
    output wire         P_TX_LANE_PD_PISO_2,
    output wire         P_TX_LANE_PD_PISO_3,
    output wire         P_TX_LANE_PD_DRIVER_0,
    output wire         P_TX_LANE_PD_DRIVER_1,
    output wire         P_TX_LANE_PD_DRIVER_2,
    output wire         P_TX_LANE_PD_DRIVER_3,
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
    output wire         P_RX_PMA_RST_0,
    output wire         P_RX_PMA_RST_1,
    output wire         P_RX_PMA_RST_2,
    output wire         P_RX_PMA_RST_3,
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
    output wire         P_PCS_RX_RST_0,
    output wire         P_PCS_RX_RST_1,
    output wire         P_PCS_RX_RST_2,
    output wire         P_PCS_RX_RST_3,
    output wire [2 : 0] P_RX_RATE_0,
    output wire [2 : 0] P_RX_RATE_1,
    output wire [2 : 0] P_RX_RATE_2,
    output wire [2 : 0] P_RX_RATE_3,
    output wire         P_PCS_CB_RST_0,
    output wire         P_PCS_CB_RST_1,
    output wire         P_PCS_CB_RST_2,
    output wire         P_PCS_CB_RST_3
);

    //---------------------------------------------------
    // 内部信号
    //---------------------------------------------------
    // 时钟补偿使能，收发共用速率切换端口。
    wire       p_rx_rate_chng_0;
    wire       p_rx_rate_chng_1;
    wire       p_rx_rate_chng_2;
    wire       p_rx_rate_chng_3;
    wire [2:0] p_rxckdiv_0;
    wire [2:0] p_rxckdiv_1;
    wire [2:0] p_rxckdiv_2;
    wire [2:0] p_rxckdiv_3;

    //---------------------------------------------------
    // 时序与组合逻辑
    //---------------------------------------------------
    assign   p_rx_rate_chng_0 = (CH0_TX_ENABLE=="TRUE" && PCS_CH0_BYPASS_CTC=="FALSE") ? i_tx_rate_chng_0 : i_rx_rate_chng_0;
    assign   p_rx_rate_chng_1 = (CH1_TX_ENABLE=="TRUE" && PCS_CH1_BYPASS_CTC=="FALSE") ? i_tx_rate_chng_1 : i_rx_rate_chng_1;
    assign   p_rx_rate_chng_2 = (CH2_TX_ENABLE=="TRUE" && PCS_CH2_BYPASS_CTC=="FALSE") ? i_tx_rate_chng_2 : i_rx_rate_chng_2;
    assign   p_rx_rate_chng_3 = (CH3_TX_ENABLE=="TRUE" && PCS_CH3_BYPASS_CTC=="FALSE") ? i_tx_rate_chng_3 : i_rx_rate_chng_3;

    assign   p_rxckdiv_0      = (CH0_TX_ENABLE=="TRUE" && PCS_CH0_BYPASS_CTC=="FALSE") ? {1'b0,i_txckdiv_0} : {1'b0,i_rxckdiv_0};
    assign   p_rxckdiv_1      = (CH1_TX_ENABLE=="TRUE" && PCS_CH1_BYPASS_CTC=="FALSE") ? {1'b0,i_txckdiv_1} : {1'b0,i_rxckdiv_1};
    assign   p_rxckdiv_2      = (CH2_TX_ENABLE=="TRUE" && PCS_CH2_BYPASS_CTC=="FALSE") ? {1'b0,i_txckdiv_2} : {1'b0,i_rxckdiv_2};
    assign   p_rxckdiv_3      = (CH3_TX_ENABLE=="TRUE" && PCS_CH3_BYPASS_CTC=="FALSE") ? {1'b0,i_txckdiv_3} : {1'b0,i_rxckdiv_3};

    generate
        if (INNER_RST_EN == "TRUE") begin : AUTO_MODE
            ipm2l_hsstlp_rst_pll_v1_0 #(
                .FREE_CLOCK_FREQ(FREE_CLOCK_FREQ),
                .PLL_NUBER      (PLL_NUBER)
            ) hsstlp_rst_pll (
                .clk             (i_free_clk),
                .i_pll_rst_0     (i_pll_rst_0),
                .i_pll_rst_1     (i_pll_rst_1),
                .P_PLL_READY_0   (P_PLL_READY_0),
                .P_PLL_READY_1   (P_PLL_READY_1),
                .i_wtchdg_clr_0  (i_wtchdg_clr_0),
                .i_wtchdg_clr_1  (i_wtchdg_clr_1),
                .o_wtchdg_st_0   (o_wtchdg_st_0),
                .o_wtchdg_st_1   (o_wtchdg_st_1),
                .o_pll_done_0    (o_pll_done_0),
                .o_pll_done_1    (o_pll_done_1),
                .P_PLLPOWERDOWN_0(P_PLLPOWERDOWN_0),
                .P_PLLPOWERDOWN_1(P_PLLPOWERDOWN_1),
                .P_PLL_RST_0     (P_PLL_RST_0),
                .P_PLL_RST_1     (P_PLL_RST_1)
            );

            ipm2l_hsstlp_rst_tx_v1_6 #(
                .FREE_CLOCK_FREQ         (FREE_CLOCK_FREQ),
                .CH0_TX_ENABLE           (CH0_TX_ENABLE),
                .CH1_TX_ENABLE           (CH1_TX_ENABLE),
                .CH2_TX_ENABLE           (CH2_TX_ENABLE),
                .CH3_TX_ENABLE           (CH3_TX_ENABLE),
                .CH0_MULT_LANE_MODE      (CH0_MULT_LANE_MODE),
                .CH1_MULT_LANE_MODE      (CH1_MULT_LANE_MODE),
                .CH2_MULT_LANE_MODE      (CH2_MULT_LANE_MODE),
                .CH3_MULT_LANE_MODE      (CH3_MULT_LANE_MODE),
                .P_LX_TX_CKDIV_0         (P_LX_TX_CKDIV_0),
                .P_LX_TX_CKDIV_1         (P_LX_TX_CKDIV_1),
                .P_LX_TX_CKDIV_2         (P_LX_TX_CKDIV_2),
                .P_LX_TX_CKDIV_3         (P_LX_TX_CKDIV_3),
                .CH0_TX_PLL_SEL          (CH0_TX_PLL_SEL),
                .CH1_TX_PLL_SEL          (CH1_TX_PLL_SEL),
                .CH2_TX_PLL_SEL          (CH2_TX_PLL_SEL),
                .CH3_TX_PLL_SEL          (CH3_TX_PLL_SEL),
                .PCS_TX_CLK_EXPLL_USE_CH0(PCS_TX_CLK_EXPLL_USE_CH0),
                .PCS_TX_CLK_EXPLL_USE_CH1(PCS_TX_CLK_EXPLL_USE_CH1),
                .PCS_TX_CLK_EXPLL_USE_CH2(PCS_TX_CLK_EXPLL_USE_CH2),
                .PCS_TX_CLK_EXPLL_USE_CH3(PCS_TX_CLK_EXPLL_USE_CH3)
            ) hsstlp_rst_tx (
                .clk                    (i_free_clk),
                .i_txlane_rst_0         (i_txlane_rst_0),
                .i_txlane_rst_1         (i_txlane_rst_1),
                .i_txlane_rst_2         (i_txlane_rst_2),
                .i_txlane_rst_3         (i_txlane_rst_3),
                .i_pll_done_0           (o_pll_done_0),
                .i_pll_done_1           (o_pll_done_1),
                .i_tx_rate_chng_0       (i_tx_rate_chng_0),
                .i_tx_rate_chng_1       (i_tx_rate_chng_1),
                .i_tx_rate_chng_2       (i_tx_rate_chng_2),
                .i_tx_rate_chng_3       (i_tx_rate_chng_3),
                .i_pll_lock_tx_0        (i_pll_lock_tx_0),
                .i_pll_lock_tx_1        (i_pll_lock_tx_1),
                .i_pll_lock_tx_2        (i_pll_lock_tx_2),
                .i_pll_lock_tx_3        (i_pll_lock_tx_3),
                .i_txckdiv_0            ({1'b0, i_txckdiv_0}),
                .i_txckdiv_1            ({1'b0, i_txckdiv_1}),
                .i_txckdiv_2            ({1'b0, i_txckdiv_2}),
                .i_txckdiv_3            ({1'b0, i_txckdiv_3}),
                .o_txlane_done_0        (o_txlane_done_0),
                .o_txlane_done_1        (o_txlane_done_1),
                .o_txlane_done_2        (o_txlane_done_2),
                .o_txlane_done_3        (o_txlane_done_3),
                .o_txckdiv_done_0       (o_tx_ckdiv_done_0),
                .o_txckdiv_done_1       (o_tx_ckdiv_done_1),
                .o_txckdiv_done_2       (o_tx_ckdiv_done_2),
                .o_txckdiv_done_3       (o_tx_ckdiv_done_3),
                .P_TX_LANE_PD_CLKPATH_0 (P_TX_LANE_PD_CLKPATH_0),
                .P_TX_LANE_PD_CLKPATH_1 (P_TX_LANE_PD_CLKPATH_1),
                .P_TX_LANE_PD_CLKPATH_2 (P_TX_LANE_PD_CLKPATH_2),
                .P_TX_LANE_PD_CLKPATH_3 (P_TX_LANE_PD_CLKPATH_3),
                .P_TX_LANE_PD_DRIVER_0  (P_TX_LANE_PD_DRIVER_0),
                .P_TX_LANE_PD_DRIVER_1  (P_TX_LANE_PD_DRIVER_1),
                .P_TX_LANE_PD_DRIVER_2  (P_TX_LANE_PD_DRIVER_2),
                .P_TX_LANE_PD_DRIVER_3  (P_TX_LANE_PD_DRIVER_3),
                .P_TX_LANE_PD_PISO_0    (P_TX_LANE_PD_PISO_0),
                .P_TX_LANE_PD_PISO_1    (P_TX_LANE_PD_PISO_1),
                .P_TX_LANE_PD_PISO_2    (P_TX_LANE_PD_PISO_2),
                .P_TX_LANE_PD_PISO_3    (P_TX_LANE_PD_PISO_3),
                .P_TX_RATE_0            (P_TX_RATE_0),
                .P_TX_RATE_1            (P_TX_RATE_1),
                .P_TX_RATE_2            (P_TX_RATE_2),
                .P_TX_RATE_3            (P_TX_RATE_3),
                .P_TX_PMA_RST_0         (P_TX_PMA_RST_0),
                .P_TX_PMA_RST_1         (P_TX_PMA_RST_1),
                .P_TX_PMA_RST_2         (P_TX_PMA_RST_2),
                .P_TX_PMA_RST_3         (P_TX_PMA_RST_3),
                .P_PCS_TX_RST_0         (P_PCS_TX_RST_0),
                .P_PCS_TX_RST_1         (P_PCS_TX_RST_1),
                .P_PCS_TX_RST_2         (P_PCS_TX_RST_2),
                .P_PCS_TX_RST_3         (P_PCS_TX_RST_3),
                .P_LANE_SYNC_0          (P_LANE_SYNC_0),
                .P_LANE_SYNC_1          (P_LANE_SYNC_1),
                .P_RATE_CHANGE_TCLK_ON_0(P_RATE_CHANGE_TCLK_ON_0),
                .P_RATE_CHANGE_TCLK_ON_1(P_RATE_CHANGE_TCLK_ON_1)
            );

            ipm2l_hsstlp_rst_rx_v1_6 #(
                .FREE_CLOCK_FREQ          (FREE_CLOCK_FREQ),
                .CH0_RX_ENABLE            (CH0_RX_ENABLE),
                .CH1_RX_ENABLE            (CH1_RX_ENABLE),
                .CH2_RX_ENABLE            (CH2_RX_ENABLE),
                .CH3_RX_ENABLE            (CH3_RX_ENABLE),
                .CH0_MULT_LANE_MODE       (CH0_MULT_LANE_MODE),
                .CH1_MULT_LANE_MODE       (CH1_MULT_LANE_MODE),
                .CH2_MULT_LANE_MODE       (CH2_MULT_LANE_MODE),
                .CH3_MULT_LANE_MODE       (CH3_MULT_LANE_MODE),
                .CH0_RXPCS_ALIGN_TIMER    (CH0_RXPCS_ALIGN_TIMER),
                .CH1_RXPCS_ALIGN_TIMER    (CH1_RXPCS_ALIGN_TIMER),
                .CH2_RXPCS_ALIGN_TIMER    (CH2_RXPCS_ALIGN_TIMER),
                .CH3_RXPCS_ALIGN_TIMER    (CH3_RXPCS_ALIGN_TIMER),
                .PCS_CH0_BYPASS_WORD_ALIGN(PCS_CH0_BYPASS_WORD_ALIGN),
                .PCS_CH1_BYPASS_WORD_ALIGN(PCS_CH1_BYPASS_WORD_ALIGN),
                .PCS_CH2_BYPASS_WORD_ALIGN(PCS_CH2_BYPASS_WORD_ALIGN),
                .PCS_CH3_BYPASS_WORD_ALIGN(PCS_CH3_BYPASS_WORD_ALIGN),
                .PCS_CH0_BYPASS_BONDING   (PCS_CH0_BYPASS_BONDING),
                .PCS_CH1_BYPASS_BONDING   (PCS_CH1_BYPASS_BONDING),
                .PCS_CH2_BYPASS_BONDING   (PCS_CH2_BYPASS_BONDING),
                .PCS_CH3_BYPASS_BONDING   (PCS_CH3_BYPASS_BONDING),
                .PCS_CH0_BYPASS_CTC       (PCS_CH0_BYPASS_CTC),
                .PCS_CH1_BYPASS_CTC       (PCS_CH1_BYPASS_CTC),
                .PCS_CH2_BYPASS_CTC       (PCS_CH2_BYPASS_CTC),
                .PCS_CH3_BYPASS_CTC       (PCS_CH3_BYPASS_CTC),
                .LX_RX_CKDIV_0            (LX_RX_CKDIV_0),
                .LX_RX_CKDIV_1            (LX_RX_CKDIV_1),
                .LX_RX_CKDIV_2            (LX_RX_CKDIV_2),
                .LX_RX_CKDIV_3            (LX_RX_CKDIV_3),
                .CH0_RX_PLL_SEL           (CH0_RX_PLL_SEL),
                .CH1_RX_PLL_SEL           (CH1_RX_PLL_SEL),
                .CH2_RX_PLL_SEL           (CH2_RX_PLL_SEL),
                .CH3_RX_PLL_SEL           (CH3_RX_PLL_SEL),
                .PCS_RX_CLK_EXPLL_USE_CH0 (PCS_RX_CLK_EXPLL_USE_CH0),
                .PCS_RX_CLK_EXPLL_USE_CH1 (PCS_RX_CLK_EXPLL_USE_CH1),
                .PCS_RX_CLK_EXPLL_USE_CH2 (PCS_RX_CLK_EXPLL_USE_CH2),
                .PCS_RX_CLK_EXPLL_USE_CH3 (PCS_RX_CLK_EXPLL_USE_CH3)
            ) hsstlp_rst_rx (
                .clk                  (i_free_clk),
                .i_hsstlp_fifo_clr_0  (i_hsstlp_fifo_clr_0),
                .i_hsstlp_fifo_clr_1  (i_hsstlp_fifo_clr_1),
                .i_hsstlp_fifo_clr_2  (i_hsstlp_fifo_clr_2),
                .i_hsstlp_fifo_clr_3  (i_hsstlp_fifo_clr_3),
                .i_pll_done_0         (o_pll_done_0),
                .i_pll_done_1         (o_pll_done_1),
                .i_rxlane_rst_0       (i_rxlane_rst_0),
                .i_rxlane_rst_1       (i_rxlane_rst_1),
                .i_rxlane_rst_2       (i_rxlane_rst_2),
                .i_rxlane_rst_3       (i_rxlane_rst_3),
                .i_rx_rate_chng_0     (p_rx_rate_chng_0),
                .i_rx_rate_chng_1     (p_rx_rate_chng_1),
                .i_rx_rate_chng_2     (p_rx_rate_chng_2),
                .i_rx_rate_chng_3     (p_rx_rate_chng_3),
                .i_rxckdiv_0          (p_rxckdiv_0),
                .i_rxckdiv_1          (p_rxckdiv_1),
                .i_rxckdiv_2          (p_rxckdiv_2),
                .i_rxckdiv_3          (p_rxckdiv_3),
                .i_force_rxfsm_det_0  (i_force_rxfsm_det_0),
                .i_force_rxfsm_det_1  (i_force_rxfsm_det_1),
                .i_force_rxfsm_det_2  (i_force_rxfsm_det_2),
                .i_force_rxfsm_det_3  (i_force_rxfsm_det_3),
                .i_force_rxfsm_lsm_0  (i_force_rxfsm_lsm_0),
                .i_force_rxfsm_lsm_1  (i_force_rxfsm_lsm_1),
                .i_force_rxfsm_lsm_2  (i_force_rxfsm_lsm_2),
                .i_force_rxfsm_lsm_3  (i_force_rxfsm_lsm_3),
                .i_force_rxfsm_cdr_0  (i_force_rxfsm_cdr_0),
                .i_force_rxfsm_cdr_1  (i_force_rxfsm_cdr_1),
                .i_force_rxfsm_cdr_2  (i_force_rxfsm_cdr_2),
                .i_force_rxfsm_cdr_3  (i_force_rxfsm_cdr_3),
                .i_txckdiv_done_0     (o_tx_ckdiv_done_0),
                .i_txckdiv_done_1     (o_tx_ckdiv_done_1),
                .i_txckdiv_done_2     (o_tx_ckdiv_done_2),
                .i_txckdiv_done_3     (o_tx_ckdiv_done_3),
                .i_pcs_cb_rst_0       (i_pcs_cb_rst_0),
                .i_pcs_cb_rst_1       (i_pcs_cb_rst_1),
                .i_pcs_cb_rst_2       (i_pcs_cb_rst_2),
                .i_pcs_cb_rst_3       (i_pcs_cb_rst_3),
                .i_pll_lock_rx_0      (i_pll_lock_rx_0),
                .i_pll_lock_rx_1      (i_pll_lock_rx_1),
                .i_pll_lock_rx_2      (i_pll_lock_rx_2),
                .i_pll_lock_rx_3      (i_pll_lock_rx_3),
                .P_RX_SIGDET_STATUS_0 (P_RX_SIGDET_STATUS_0),
                .P_RX_SIGDET_STATUS_1 (P_RX_SIGDET_STATUS_1),
                .P_RX_SIGDET_STATUS_2 (P_RX_SIGDET_STATUS_2),
                .P_RX_SIGDET_STATUS_3 (P_RX_SIGDET_STATUS_3),
                .P_RX_READY_0         (P_RX_READY_0),
                .P_RX_READY_1         (P_RX_READY_1),
                .P_RX_READY_2         (P_RX_READY_2),
                .P_RX_READY_3         (P_RX_READY_3),
                .P_PCS_LSM_SYNCED_0   (P_PCS_LSM_SYNCED_0),
                .P_PCS_LSM_SYNCED_1   (P_PCS_LSM_SYNCED_1),
                .P_PCS_LSM_SYNCED_2   (P_PCS_LSM_SYNCED_2),
                .P_PCS_LSM_SYNCED_3   (P_PCS_LSM_SYNCED_3),
                .P_PCS_RX_MCB_STATUS_0(P_PCS_RX_MCB_STATUS_0),
                .P_PCS_RX_MCB_STATUS_1(P_PCS_RX_MCB_STATUS_1),
                .P_PCS_RX_MCB_STATUS_2(P_PCS_RX_MCB_STATUS_2),
                .P_PCS_RX_MCB_STATUS_3(P_PCS_RX_MCB_STATUS_3),
                .P_LANE_PD_0          (P_LANE_PD_0),
                .P_LANE_PD_1          (P_LANE_PD_1),
                .P_LANE_PD_2          (P_LANE_PD_2),
                .P_LANE_PD_3          (P_LANE_PD_3),
                .P_LANE_RST_0         (P_LANE_RST_0),
                .P_LANE_RST_1         (P_LANE_RST_1),
                .P_LANE_RST_2         (P_LANE_RST_2),
                .P_LANE_RST_3         (P_LANE_RST_3),
                .P_RX_LANE_PD_0       (P_RX_LANE_PD_0),
                .P_RX_LANE_PD_1       (P_RX_LANE_PD_1),
                .P_RX_LANE_PD_2       (P_RX_LANE_PD_2),
                .P_RX_LANE_PD_3       (P_RX_LANE_PD_3),
                .P_RX_PMA_RST_0       (P_RX_PMA_RST_0),
                .P_RX_PMA_RST_1       (P_RX_PMA_RST_1),
                .P_RX_PMA_RST_2       (P_RX_PMA_RST_2),
                .P_RX_PMA_RST_3       (P_RX_PMA_RST_3),
                .P_PCS_RX_RST_0       (P_PCS_RX_RST_0),
                .P_PCS_RX_RST_1       (P_PCS_RX_RST_1),
                .P_PCS_RX_RST_2       (P_PCS_RX_RST_2),
                .P_PCS_RX_RST_3       (P_PCS_RX_RST_3),
                .P_RX_RATE_0          (P_RX_RATE_0),
                .P_RX_RATE_1          (P_RX_RATE_1),
                .P_RX_RATE_2          (P_RX_RATE_2),
                .P_RX_RATE_3          (P_RX_RATE_3),
                .P_PCS_CB_RST_0       (P_PCS_CB_RST_0),
                .P_PCS_CB_RST_1       (P_PCS_CB_RST_1),
                .P_PCS_CB_RST_2       (P_PCS_CB_RST_2),
                .P_PCS_CB_RST_3       (P_PCS_CB_RST_3),
                .o_rxlane_done_0      (o_rxlane_done_0),
                .o_rxlane_done_1      (o_rxlane_done_1),
                .o_rxlane_done_2      (o_rxlane_done_2),
                .o_rxlane_done_3      (o_rxlane_done_3),
                .o_rxckdiv_done_0     (o_rx_ckdiv_done_0),
                .o_rxckdiv_done_1     (o_rx_ckdiv_done_1),
                .o_rxckdiv_done_2     (o_rx_ckdiv_done_2),
                .o_rxckdiv_done_3     (o_rx_ckdiv_done_3)
            );
        end else begin : USER_MODE
            assign o_wtchdg_st_0           = 2'b0;
            assign o_wtchdg_st_1           = 2'b0;
            assign o_pll_done_0            = 1'b0;
            assign o_pll_done_1            = 1'b0;
            assign o_txlane_done_0         = 1'b0;
            assign o_txlane_done_1         = 1'b0;
            assign o_txlane_done_2         = 1'b0;
            assign o_txlane_done_3         = 1'b0;
            assign o_tx_ckdiv_done_0       = 1'b0;
            assign o_tx_ckdiv_done_1       = 1'b0;
            assign o_tx_ckdiv_done_2       = 1'b0;
            assign o_tx_ckdiv_done_3       = 1'b0;
            assign o_rxlane_done_0         = 1'b0;
            assign o_rxlane_done_1         = 1'b0;
            assign o_rxlane_done_2         = 1'b0;
            assign o_rxlane_done_3         = 1'b0;
            assign o_rx_ckdiv_done_0       = 1'b0;
            assign o_rx_ckdiv_done_1       = 1'b0;
            assign o_rx_ckdiv_done_2       = 1'b0;
            assign o_rx_ckdiv_done_3       = 1'b0;
            // 直接送往 HSST
            assign P_PLLPOWERDOWN_0        = i_f_pllpowerdown_0;
            assign P_PLLPOWERDOWN_1        = i_f_pllpowerdown_1;
            assign P_PLL_RST_0             = i_f_pll_rst_0;
            assign P_PLL_RST_1             = i_f_pll_rst_1;
            assign P_LANE_SYNC_0           = i_f_lane_sync_0;
            assign P_LANE_SYNC_1           = i_f_lane_sync_1;
            assign P_RATE_CHANGE_TCLK_ON_0 = i_f_rate_change_tclk_on_0;
            assign P_RATE_CHANGE_TCLK_ON_1 = i_f_rate_change_tclk_on_1;
            assign P_TX_LANE_PD_CLKPATH_0  = i_f_tx_lane_pd_clkpath_0;
            assign P_TX_LANE_PD_CLKPATH_1  = i_f_tx_lane_pd_clkpath_1;
            assign P_TX_LANE_PD_CLKPATH_2  = i_f_tx_lane_pd_clkpath_2;
            assign P_TX_LANE_PD_CLKPATH_3  = i_f_tx_lane_pd_clkpath_3;
            assign P_TX_LANE_PD_PISO_0     = i_f_tx_lane_pd_piso_0;
            assign P_TX_LANE_PD_PISO_1     = i_f_tx_lane_pd_piso_1;
            assign P_TX_LANE_PD_PISO_2     = i_f_tx_lane_pd_piso_2;
            assign P_TX_LANE_PD_PISO_3     = i_f_tx_lane_pd_piso_3;
            assign P_TX_LANE_PD_DRIVER_0   = i_f_tx_lane_pd_driver_0;
            assign P_TX_LANE_PD_DRIVER_1   = i_f_tx_lane_pd_driver_1;
            assign P_TX_LANE_PD_DRIVER_2   = i_f_tx_lane_pd_driver_2;
            assign P_TX_LANE_PD_DRIVER_3   = i_f_tx_lane_pd_driver_3;
            assign P_TX_RATE_0             = {1'b0, i_f_tx_ckdiv_0};
            assign P_TX_RATE_1             = {1'b0, i_f_tx_ckdiv_1};
            assign P_TX_RATE_2             = {1'b0, i_f_tx_ckdiv_2};
            assign P_TX_RATE_3             = {1'b0, i_f_tx_ckdiv_3};
            assign P_TX_PMA_RST_0          = i_f_tx_pma_rst_0;
            assign P_TX_PMA_RST_1          = i_f_tx_pma_rst_1;
            assign P_TX_PMA_RST_2          = i_f_tx_pma_rst_2;
            assign P_TX_PMA_RST_3          = i_f_tx_pma_rst_3;
            assign P_PCS_TX_RST_0          = i_f_pcs_tx_rst_0;
            assign P_PCS_TX_RST_1          = i_f_pcs_tx_rst_1;
            assign P_PCS_TX_RST_2          = i_f_pcs_tx_rst_2;
            assign P_PCS_TX_RST_3          = i_f_pcs_tx_rst_3;
            assign P_LANE_PD_0             = i_f_lane_pd_0;
            assign P_LANE_PD_1             = i_f_lane_pd_1;
            assign P_LANE_PD_2             = i_f_lane_pd_2;
            assign P_LANE_PD_3             = i_f_lane_pd_3;
            assign P_LANE_RST_0            = i_f_lane_rst_0;
            assign P_LANE_RST_1            = i_f_lane_rst_1;
            assign P_LANE_RST_2            = i_f_lane_rst_2;
            assign P_LANE_RST_3            = i_f_lane_rst_3;
            assign P_RX_LANE_PD_0          = i_f_rx_lane_pd_0;
            assign P_RX_LANE_PD_1          = i_f_rx_lane_pd_1;
            assign P_RX_LANE_PD_2          = i_f_rx_lane_pd_2;
            assign P_RX_LANE_PD_3          = i_f_rx_lane_pd_3;
            assign P_RX_PMA_RST_0          = i_f_rx_pma_rst_0;
            assign P_RX_PMA_RST_1          = i_f_rx_pma_rst_1;
            assign P_RX_PMA_RST_2          = i_f_rx_pma_rst_2;
            assign P_RX_PMA_RST_3          = i_f_rx_pma_rst_3;
            assign P_PCS_RX_RST_0          = i_f_pcs_rx_rst_0;
            assign P_PCS_RX_RST_1          = i_f_pcs_rx_rst_1;
            assign P_PCS_RX_RST_2          = i_f_pcs_rx_rst_2;
            assign P_PCS_RX_RST_3          = i_f_pcs_rx_rst_3;
            assign P_RX_RATE_0             = {1'b0, i_f_lx_rx_ckdiv_0};
            assign P_RX_RATE_1             = {1'b0, i_f_lx_rx_ckdiv_1};
            assign P_RX_RATE_2             = {1'b0, i_f_lx_rx_ckdiv_2};
            assign P_RX_RATE_3             = {1'b0, i_f_lx_rx_ckdiv_3};
            assign P_PCS_CB_RST_0          = i_f_pcs_cb_rst_0;
            assign P_PCS_CB_RST_1          = i_f_pcs_cb_rst_1;
            assign P_PCS_CB_RST_2          = i_f_pcs_cb_rst_2;
            assign P_PCS_CB_RST_3          = i_f_pcs_cb_rst_3;
        end
    endgenerate

endmodule
