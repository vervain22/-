

//---------------------------------------------------

// Copyright (c) 2019 PANGO MICROSYSTEMS, INC
// ALL RIGHTS REVERVED.

// THE SOURCE CODE CONTAINED HEREIN IS PROPRIETARY TO PANGO MICROSYSTEMS, INC.
// IT SHALL NOT BE REPRODUCED OR DISCLOSED IN WHOLE OR IN PART OR USED BY
// PARTIES WITHOUT WRITTEN AUTHORIZATION FROM THE OWNER.

//---------------------------------------------------

//---------------------------------------------------

`timescale 1ns / 100fs

module ipm2l_pcie_hsstlp_x2_top (

    input         i_p_refckn_0,
    input         i_p_refckp_0,
    input         i_p_tx_lane_pd_clkpath_0,
    input         i_p_tx_lane_pd_clkpath_1,
    input         i_p_tx_lane_pd_piso_0,
    input         i_p_tx_lane_pd_piso_1,
    input         i_p_tx_lane_pd_driver_0,
    input         i_p_tx_lane_pd_driver_1,
    input         i_p_lane_pd_0,
    input         i_p_lane_pd_1,
    input         i_p_lane_rst_0,
    input         i_p_lane_rst_1,
    input         i_p_rx_lane_pd_0,
    input         i_p_rx_lane_pd_1,
    output        o_p_clk2core_tx_0,
    output        o_p_clk2core_tx_1,
    input         i_p_tx0_clk_fr_core,
    input         i_p_tx1_clk_fr_core,
    input         i_p_rx0_clk_fr_core,
    input         i_p_rx1_clk_fr_core,
    input         i_p_rx0_clk2_fr_core,
    input         i_p_rx1_clk2_fr_core,
    input         i_pll_lock_rx_0,
    input         i_pll_lock_rx_1,
    output        o_p_refck2core_0,
    input         i_p_pll_rst_0,
    input         i_p_tx_pma_rst_0,
    input         i_p_tx_pma_rst_1,
    input         i_p_pcs_tx_rst_0,
    input         i_p_pcs_tx_rst_1,
    input         i_p_rx_pma_rst_0,
    input         i_p_rx_pma_rst_1,
    input         i_p_pcs_rx_rst_0,
    input         i_p_pcs_rx_rst_1,
    input         i_p_pcs_cb_rst_0,
    input         i_p_pcs_cb_rst_1,
    input  [ 2:0] i_p_lx_margin_ctl_0,
    input  [ 2:0] i_p_lx_margin_ctl_1,
    input         i_p_lx_swing_ctl_0,
    input         i_p_lx_swing_ctl_1,
    input  [ 1:0] i_p_lx_deemp_ctl_0,
    input  [ 1:0] i_p_lx_deemp_ctl_1,
    input         i_p_lane_sync_0,
    input         i_p_rate_change_tclk_on_0,
    input  [ 1:0] i_p_tx_ckdiv_0,
    input  [ 1:0] i_p_tx_ckdiv_1,
    input  [ 1:0] i_p_lx_rx_ckdiv_0,
    input  [ 1:0] i_p_lx_rx_ckdiv_1,
    input  [ 1:0] i_p_lx_elecidle_en_0,
    input  [ 1:0] i_p_lx_elecidle_en_1,
    output        o_p_pll_lock_0,
    output        o_p_rx_sigdet_sta_0,
    output        o_p_rx_sigdet_sta_1,
    output        o_p_lx_cdr_align_0,
    output        o_p_lx_cdr_align_1,
    input         i_p_lx_rxdct_en_0,
    input         i_p_lx_rxdct_en_1,
    output        o_p_lx_rxdct_out_0,
    output        o_p_lx_rxdct_out_1,
    output        o_p_pcs_lsm_synced_0,
    output        o_p_pcs_lsm_synced_1,
    input         i_p_pcs_nearend_loop_0,
    input         i_p_pcs_farend_loop_0,
    input         i_p_pma_nearend_ploop_0,
    input         i_p_pma_nearend_sloop_0,
    input         i_p_pma_farend_ploop_0,
    input         i_p_pcs_nearend_loop_1,
    input         i_p_pcs_farend_loop_1,
    input         i_p_pma_nearend_ploop_1,
    input         i_p_pma_nearend_sloop_1,
    input         i_p_pma_farend_ploop_1,
    input         i_p_rx_polarity_invert_0,
    input         i_p_rx_polarity_invert_1,
    input         i_p_tx_beacon_en_0,
    input         i_p_tx_beacon_en_1,
    input         i_p_cfg_clk,
    input         i_p_cfg_rst,
    input         i_p_cfg_psel,
    input         i_p_cfg_enable,
    input         i_p_cfg_write,
    input  [15:0] i_p_cfg_addr,
    input  [ 7:0] i_p_cfg_wdata,
    output [ 7:0] o_p_cfg_rdata,
    output        o_p_cfg_int,
    output        o_p_cfg_ready,
    input         i_p_l0rxn,
    input         i_p_l0rxp,
    input         i_p_l1rxn,
    input         i_p_l1rxp,
    output        o_p_l0txn,
    output        o_p_l0txp,
    output        o_p_l1txn,
    output        o_p_l1txp,
    input  [31:0] i_txd_0,
    input  [ 3:0] i_tdispsel_0,
    input  [ 3:0] i_tdispctrl_0,
    input  [ 3:0] i_txk_0,
    input  [31:0] i_txd_1,
    input  [ 3:0] i_tdispsel_1,
    input  [ 3:0] i_tdispctrl_1,
    input  [ 3:0] i_txk_1,
    output [ 2:0] o_rxstatus_0,
    output [31:0] o_rxd_0,
    output [ 3:0] o_rdisper_0,
    output [ 3:0] o_rdecer_0,
    output [ 3:0] o_rxk_0,
    output [ 2:0] o_rxstatus_1,
    output [31:0] o_rxd_1,
    output [ 3:0] o_rdisper_1,
    output [ 3:0] o_rdecer_1,
    output [ 3:0] o_rxk_1,
    input         i_p_pllpowerdown_0
);

    // 用户接口参数
    localparam CH0_EN = "Fullduplex";
    localparam CH1_EN = "Fullduplex";
    localparam CH2_EN = "DISABLE";
    localparam CH3_EN = "DISABLE";
    localparam CH0_PROTOCOL = "PCIEx2";
    localparam CH1_PROTOCOL = "PCIEx2";
    localparam CH2_PROTOCOL = "CUSTOMERIZEDx1";
    localparam CH3_PROTOCOL = "CUSTOMERIZEDx1";
    localparam CH0_PROTOCOL_DEFAULT = "FALSE";
    localparam CH1_PROTOCOL_DEFAULT = "FALSE";
    localparam CH2_PROTOCOL_DEFAULT = "FALSE";
    localparam CH3_PROTOCOL_DEFAULT = "FALSE";
    localparam CH0_TX_RATE = 5.0;
    localparam CH1_TX_RATE = 5.0;
    localparam CH2_TX_RATE = 0.0;
    localparam CH3_TX_RATE = 0.0;
    localparam CH0_RX_RATE = 5.0;
    localparam CH1_RX_RATE = 5.0;
    localparam CH2_RX_RATE = 0.0;
    localparam CH3_RX_RATE = 0.0;
    localparam CH0_TX_ENCODER = "8B10B";
    localparam CH1_TX_ENCODER = "8B10B";
    localparam CH2_TX_ENCODER = "Bypassed";
    localparam CH3_TX_ENCODER = "Bypassed";
    localparam CH0_RX_DECODER = "8B10B";
    localparam CH1_RX_DECODER = "8B10B";
    localparam CH2_RX_DECODER = "Bypassed";
    localparam CH3_RX_DECODER = "Bypassed";
    localparam CH0_TDATA_WIDTH = 32;
    localparam CH1_TDATA_WIDTH = 32;
    localparam CH2_TDATA_WIDTH = 32;
    localparam CH3_TDATA_WIDTH = 32;
    localparam CH0_RDATA_WIDTH = 32;
    localparam CH1_RDATA_WIDTH = 32;
    localparam CH2_RDATA_WIDTH = 32;
    localparam CH3_RDATA_WIDTH = 32;
    localparam CH0_TX_FABRIC_FEQ = 125.0;
    localparam CH1_TX_FABRIC_FEQ = 125.0;
    localparam CH2_TX_FABRIC_FEQ = 0.0;
    localparam CH3_TX_FABRIC_FEQ = 0.0;
    localparam CH0_RX_FABRIC_FEQ = 125.0;
    localparam CH1_RX_FABRIC_FEQ = 125.0;
    localparam CH2_RX_FABRIC_FEQ = 0.0;
    localparam CH3_RX_FABRIC_FEQ = 0.0;
    localparam PLL_NUM = 1;
    localparam PLL0_EN = "TRUE";
    localparam PLL1_EN = "FALSE";
    localparam PLL_REFCLK_SAME = "FALSE";
    localparam PLL0_REF_SEL = "Diff_REFCK0";
    localparam PLL1_REF_SEL = "Diff_REFCK1";
    localparam PLL0_FRQ_INDEX = 0;
    localparam PLL1_FRQ_INDEX = 0;
    localparam PLL0_REF_FRQ = 100.0;
    localparam PLL1_REF_FRQ = 125.0;
    localparam CH0_TX_PLL_SEL = "PLL0";
    localparam CH1_TX_PLL_SEL = "PLL0";
    localparam CH2_TX_PLL_SEL = "PLL0";
    localparam CH3_TX_PLL_SEL = "PLL0";
    localparam CH0_RX_PLL_SEL = "PLL0";
    localparam CH1_RX_PLL_SEL = "PLL0";
    localparam CH2_RX_PLL_SEL = "PLL0";
    localparam CH3_RX_PLL_SEL = "PLL0";
    localparam CH0_RXPCS_ALIGN = "XAUI_MODE";
    localparam CH1_RXPCS_ALIGN = "XAUI_MODE";
    localparam CH2_RXPCS_ALIGN = "Bypassed";
    localparam CH3_RXPCS_ALIGN = "Bypassed";
    localparam CH0_RXPCS_COMMA_SEL = "K28.5";
    localparam CH1_RXPCS_COMMA_SEL = "K28.5";
    localparam CH2_RXPCS_COMMA_SEL = "K28.5";
    localparam CH3_RXPCS_COMMA_SEL = "K28.5";
    localparam CH0_RXPCS_BONDING = "Bypassed";
    localparam CH1_RXPCS_BONDING = "Bypassed";
    localparam CH2_RXPCS_BONDING = "Bypassed";
    localparam CH3_RXPCS_BONDING = "Bypassed";
    localparam CH0_RXPCS_CTC = "PCIE_4BYTE";
    localparam CH1_RXPCS_CTC = "PCIE_4BYTE";
    localparam CH2_RXPCS_CTC = "Bypassed";
    localparam CH3_RXPCS_CTC = "Bypassed";
    localparam [9:0] CH0_RXPCS_COMMA_REG0 = 10'b0101111100;
    localparam [9:0] CH1_RXPCS_COMMA_REG0 = 10'b0101111100;
    localparam [9:0] CH2_RXPCS_COMMA_REG0 = 10'b0;
    localparam [9:0] CH3_RXPCS_COMMA_REG0 = 10'b0;
    localparam [9:0] CH0_RXPCS_COMMA_MASK = 10'b0000000000;
    localparam [9:0] CH1_RXPCS_COMMA_MASK = 10'b0000000000;
    localparam [9:0] CH2_RXPCS_COMMA_MASK = 10'b0;
    localparam [9:0] CH3_RXPCS_COMMA_MASK = 10'b0;
    localparam [9:0] CH0_RXPCS_SKIP_REG0 = 10'b110111100;
    localparam [9:0] CH1_RXPCS_SKIP_REG0 = 10'b110111100;
    localparam [9:0] CH2_RXPCS_SKIP_REG0 = 10'b0;
    localparam [9:0] CH3_RXPCS_SKIP_REG0 = 10'b0;
    localparam [9:0] CH0_RXPCS_SKIP_REG1 = 10'b100011100;
    localparam [9:0] CH1_RXPCS_SKIP_REG1 = 10'b100011100;
    localparam [9:0] CH2_RXPCS_SKIP_REG1 = 10'b0;
    localparam [9:0] CH3_RXPCS_SKIP_REG1 = 10'b0;
    localparam [9:0] CH0_RXPCS_SKIP_REG2 = 10'b100011100;
    localparam [9:0] CH1_RXPCS_SKIP_REG2 = 10'b100011100;
    localparam [9:0] CH2_RXPCS_SKIP_REG2 = 10'b0;
    localparam [9:0] CH3_RXPCS_SKIP_REG2 = 10'b0;
    localparam [9:0] CH0_RXPCS_SKIP_REG3 = 10'b100011100;
    localparam [9:0] CH1_RXPCS_SKIP_REG3 = 10'b100011100;
    localparam [9:0] CH2_RXPCS_SKIP_REG3 = 10'b0;
    localparam [9:0] CH3_RXPCS_SKIP_REG3 = 10'b0;
    localparam [7:0] CH0_RXPCS_A_REG = 8'b01111100;
    localparam [7:0] CH1_RXPCS_A_REG = 8'b01111100;
    localparam [7:0] CH2_RXPCS_A_REG = 8'b01111100;
    localparam [7:0] CH3_RXPCS_A_REG = 8'b01111100;
    localparam INNER_RST_EN = "FALSE";
    localparam FREE_FRQ = 10.0;
    localparam CH0_RXPCS_ALIGN_TIMER = 32767;
    localparam CH1_RXPCS_ALIGN_TIMER = 32767;
    localparam CH2_RXPCS_ALIGN_TIMER = 32767;
    localparam CH3_RXPCS_ALIGN_TIMER = 32767;
    localparam CH0_RXPCS_BONDING_RANGE = "80BIT";
    localparam CH1_RXPCS_BONDING_RANGE = "80BIT";
    localparam CH2_RXPCS_BONDING_RANGE = "80BIT";
    localparam CH3_RXPCS_BONDING_RANGE = "80BIT";
    localparam CH0_RXPMA_RTERM = 5;
    localparam CH1_RXPMA_RTERM = 5;
    localparam CH2_RXPMA_RTERM = 6;
    localparam CH3_RXPMA_RTERM = 6;
    localparam CH0_PRE_CURSOR_EN = "FALSE";
    localparam CH1_PRE_CURSOR_EN = "FALSE";
    localparam CH2_PRE_CURSOR_EN = "FALSE";
    localparam CH3_PRE_CURSOR_EN = "FALSE";
    localparam CH0_POST_CURSOR_EN = "TRUE";
    localparam CH1_POST_CURSOR_EN = "TRUE";
    localparam CH2_POST_CURSOR_EN = "FALSE";
    localparam CH3_POST_CURSOR_EN = "FALSE";
    localparam CH0_PRE_CURSOR_EMPHASIS = 0;
    localparam CH1_PRE_CURSOR_EMPHASIS = 0;
    localparam CH2_PRE_CURSOR_EMPHASIS = 0;
    localparam CH3_PRE_CURSOR_EMPHASIS = 0;
    localparam CH0_POST_CURSOR_EMPHASIS = 12;
    localparam CH1_POST_CURSOR_EMPHASIS = 12;
    localparam CH2_POST_CURSOR_EMPHASIS = 0;
    localparam CH3_POST_CURSOR_EMPHASIS = 0;
    localparam CH0_POST1_CURSOR_EMPHASIS = 19;
    localparam CH1_POST1_CURSOR_EMPHASIS = 19;
    localparam CH2_POST1_CURSOR_EMPHASIS = 0;
    localparam CH3_POST1_CURSOR_EMPHASIS = 0;
    localparam CH0_POST2_CURSOR_EMPHASIS = 0;
    localparam CH1_POST2_CURSOR_EMPHASIS = 0;
    localparam CH2_POST2_CURSOR_EMPHASIS = 0;
    localparam CH3_POST2_CURSOR_EMPHASIS = 0;
    localparam P_APB_EN = "TRUE";
    localparam PLL0_VCO = 5000.0;
    localparam PLL0_M = 1;
    localparam PLL0_N1 = 5;
    localparam PLL0_N2 = 10;
    localparam PLL1_VCO = 1600.0;
    localparam PLL1_M = 1;
    localparam PLL1_N1 = 5;
    localparam PLL1_N2 = 4;
    localparam P_LX_TX_CKDIV_0 = 2;
    localparam P_LX_TX_CKDIV_1 = 2;
    localparam P_LX_TX_CKDIV_2 = 0;
    localparam P_LX_TX_CKDIV_3 = 0;
    localparam LX_RX_CKDIV_0 = 2;
    localparam LX_RX_CKDIV_1 = 2;
    localparam LX_RX_CKDIV_2 = 0;
    localparam LX_RX_CKDIV_3 = 0;
    localparam RX0_CLK2_FR_CORE = "TRUE";
    localparam RX1_CLK2_FR_CORE = "TRUE";
    localparam RX2_CLK2_FR_CORE = "FALSE";
    localparam RX3_CLK2_FR_CORE = "FALSE";
    localparam TX0_CLK2_FR_CORE = "FALSE";
    localparam TX1_CLK2_FR_CORE = "FALSE";
    localparam TX2_CLK2_FR_CORE = "FALSE";
    localparam TX3_CLK2_FR_CORE = "FALSE";
    localparam CH0_DEBUG_BUS = "TRUE";
    localparam CH1_DEBUG_BUS = "TRUE";
    localparam CH2_DEBUG_BUS = "FALSE";
    localparam CH3_DEBUG_BUS = "FALSE";
    localparam CH0_FFE_CTRL_EN = "TRUE";
    localparam CH1_FFE_CTRL_EN = "TRUE";
    localparam CH2_FFE_CTRL_EN = "FALSE";
    localparam CH3_FFE_CTRL_EN = "FALSE";
    localparam CH0_RX_CLK_SLIP_EN = "FALSE";
    localparam CH1_RX_CLK_SLIP_EN = "FALSE";
    localparam CH2_RX_CLK_SLIP_EN = "FALSE";
    localparam CH3_RX_CLK_SLIP_EN = "FALSE";
    localparam PCIE_CLK_MODE_EN_0 = "FALSE";
    localparam PCIE_CLK_MODE_EN_1 = "TRUE";
    localparam PCIE_CLK_MODE_EN_2 = "FALSE";
    localparam PCIE_CLK_MODE_EN_3 = "FALSE";

    // GTP 原语参数

    // 参数名称映射
    // 发送数据位宽选项：8、10、16、20、32、40 位及对应的 8b/10b 模式。
    // 接收数据位宽选项：8、10、16、20、32、40 位及对应的 8b/10b 模式。
    localparam           CH0_TDATA_WIDTH_TYPE          = ((CH0_TX_ENCODER=="Bypassed")&&(CH0_TDATA_WIDTH==8)) ? "8bit_only" :
                                                     ((CH0_TX_ENCODER=="Bypassed")&&(CH0_TDATA_WIDTH==10)) ? "10bit_only" :
                                                     ((CH0_TX_ENCODER=="Bypassed")&&(CH0_TDATA_WIDTH==16)) ? "16bit_only" :
                                                     ((CH0_TX_ENCODER=="Bypassed")&&(CH0_TDATA_WIDTH==20)) ? "20bit_only" :
                                                     ((CH0_TX_ENCODER=="Bypassed")&&(CH0_TDATA_WIDTH==32)) ? "32bit_only" :
                                                     ((CH0_TX_ENCODER=="Bypassed")&&(CH0_TDATA_WIDTH==40)) ? "40bit_only" :
                                                     ((CH0_TX_ENCODER=="8B10B") &&  (CH0_TDATA_WIDTH==8)) ? "8b10b_8bit"  :
                                                     ((CH0_TX_ENCODER=="8B10B") &&  (CH0_TDATA_WIDTH==16)) ? "8b10b_16bit" :
                                                     ((CH0_TX_ENCODER=="64B66B_transparent") &&  (CH0_TDATA_WIDTH==16)) ? "64b66b_16bit" :
                                                     ((CH0_TX_ENCODER=="64B66B_transparent") &&  (CH0_TDATA_WIDTH==32)) ? "64b66b_32bit" :
                                                     ((CH0_TX_ENCODER=="64B67B_transparent") &&  (CH0_TDATA_WIDTH==16)) ? "64b67b_16bit" :
                                                     ((CH0_TX_ENCODER=="64B67B_transparent") &&  (CH0_TDATA_WIDTH==32)) ? "64b67b_32bit" : "8b10b_32bit";
    localparam           CH1_TDATA_WIDTH_TYPE          = ((CH1_TX_ENCODER=="Bypassed")&&(CH1_TDATA_WIDTH==8)) ? "8bit_only" :
                                                     ((CH1_TX_ENCODER=="Bypassed")&&(CH1_TDATA_WIDTH==10)) ? "10bit_only" :
                                                     ((CH1_TX_ENCODER=="Bypassed")&&(CH1_TDATA_WIDTH==16)) ? "16bit_only" :
                                                     ((CH1_TX_ENCODER=="Bypassed")&&(CH1_TDATA_WIDTH==20)) ? "20bit_only" :
                                                     ((CH1_TX_ENCODER=="Bypassed")&&(CH1_TDATA_WIDTH==32)) ? "32bit_only" :
                                                     ((CH1_TX_ENCODER=="Bypassed")&&(CH1_TDATA_WIDTH==40)) ? "40bit_only" :
                                                     ((CH1_TX_ENCODER=="8B10B") &&  (CH1_TDATA_WIDTH==8)) ? "8b10b_8bit" :
                                                     ((CH1_TX_ENCODER=="8B10B") &&  (CH1_TDATA_WIDTH==16)) ? "8b10b_16bit" :
                                                     ((CH1_TX_ENCODER=="64B66B_transparent") &&  (CH1_TDATA_WIDTH==16)) ? "64b66b_16bit" :
                                                     ((CH1_TX_ENCODER=="64B66B_transparent") &&  (CH1_TDATA_WIDTH==32)) ? "64b66b_32bit" :
                                                     ((CH1_TX_ENCODER=="64B67B_transparent") &&  (CH1_TDATA_WIDTH==16)) ? "64b67b_16bit" :
                                                     ((CH1_TX_ENCODER=="64B67B_transparent") &&  (CH1_TDATA_WIDTH==32)) ? "64b67b_32bit" : "8b10b_32bit";
    localparam           CH2_TDATA_WIDTH_TYPE          = ((CH2_TX_ENCODER=="Bypassed")&&(CH2_TDATA_WIDTH==8)) ? "8bit_only" :
                                                     ((CH2_TX_ENCODER=="Bypassed")&&(CH2_TDATA_WIDTH==10)) ? "10bit_only" :
                                                     ((CH2_TX_ENCODER=="Bypassed")&&(CH2_TDATA_WIDTH==16)) ? "16bit_only" :
                                                     ((CH2_TX_ENCODER=="Bypassed")&&(CH2_TDATA_WIDTH==20)) ? "20bit_only" :
                                                     ((CH2_TX_ENCODER=="Bypassed")&&(CH2_TDATA_WIDTH==32)) ? "32bit_only" :
                                                     ((CH2_TX_ENCODER=="Bypassed")&&(CH2_TDATA_WIDTH==40)) ? "40bit_only" :
                                                     ((CH2_TX_ENCODER=="8B10B") &&  (CH2_TDATA_WIDTH==8)) ? "8b10b_8bit" :
                                                     ((CH2_TX_ENCODER=="8B10B") &&  (CH2_TDATA_WIDTH==16)) ? "8b10b_16bit" :
                                                     ((CH2_TX_ENCODER=="64B66B_transparent") &&  (CH2_TDATA_WIDTH==16)) ? "64b66b_16bit" :
                                                     ((CH2_TX_ENCODER=="64B66B_transparent") &&  (CH2_TDATA_WIDTH==32)) ? "64b66b_32bit" :
                                                     ((CH2_TX_ENCODER=="64B67B_transparent") &&  (CH2_TDATA_WIDTH==16)) ? "64b67b_16bit" :
                                                     ((CH2_TX_ENCODER=="64B67B_transparent") &&  (CH2_TDATA_WIDTH==32)) ? "64b67b_32bit" : "8b10b_32bit";
    localparam           CH3_TDATA_WIDTH_TYPE          = ((CH3_TX_ENCODER=="Bypassed")&&(CH3_TDATA_WIDTH==8)) ? "8bit_only" :
                                                     ((CH3_TX_ENCODER=="Bypassed")&&(CH3_TDATA_WIDTH==10)) ? "10bit_only" :
                                                     ((CH3_TX_ENCODER=="Bypassed")&&(CH3_TDATA_WIDTH==16)) ? "16bit_only" :
                                                     ((CH3_TX_ENCODER=="Bypassed")&&(CH3_TDATA_WIDTH==20)) ? "20bit_only" :
                                                     ((CH3_TX_ENCODER=="Bypassed")&&(CH3_TDATA_WIDTH==32)) ? "32bit_only" :
                                                     ((CH3_TX_ENCODER=="Bypassed")&&(CH3_TDATA_WIDTH==40)) ? "40bit_only" :
                                                     ((CH3_TX_ENCODER=="8B10B") &&  (CH3_TDATA_WIDTH==8)) ? "8b10b_8bit" :
                                                     ((CH3_TX_ENCODER=="8B10B") &&  (CH3_TDATA_WIDTH==16)) ? "8b10b_16bit" :
                                                     ((CH3_TX_ENCODER=="64B66B_transparent") &&  (CH3_TDATA_WIDTH==16)) ? "64b66b_16bit" :
                                                     ((CH3_TX_ENCODER=="64B66B_transparent") &&  (CH3_TDATA_WIDTH==32)) ? "64b66b_32bit" :
                                                     ((CH3_TX_ENCODER=="64B67B_transparent") &&  (CH3_TDATA_WIDTH==16)) ? "64b67b_16bit" :
                                                     ((CH3_TX_ENCODER=="64B67B_transparent") &&  (CH3_TDATA_WIDTH==32)) ? "64b67b_32bit" : "8b10b_32bit";
    localparam           CH0_RDATA_WIDTH_TYPE          = ((CH0_RX_DECODER=="Bypassed")&&(CH0_RDATA_WIDTH==8)) ? "8bit_only" :
                                                     ((CH0_RX_DECODER=="Bypassed")&&(CH0_RDATA_WIDTH==10)) ? "10bit_only" :
                                                     ((CH0_RX_DECODER=="Bypassed")&&(CH0_RDATA_WIDTH==16)) ? "16bit_only" :
                                                     ((CH0_RX_DECODER=="Bypassed")&&(CH0_RDATA_WIDTH==20)) ? "20bit_only" :
                                                     ((CH0_RX_DECODER=="Bypassed")&&(CH0_RDATA_WIDTH==32)) ? "32bit_only" :
                                                     ((CH0_RX_DECODER=="Bypassed")&&(CH0_RDATA_WIDTH==40)) ? "40bit_only" :
                                                     ((CH0_RX_DECODER=="8B10B") &&  (CH0_RDATA_WIDTH==8)) ? "8b10b_8bit" :
                                                     ((CH0_RX_DECODER=="8B10B") &&  (CH0_RDATA_WIDTH==16)) ? "8b10b_16bit" :
                                                     ((CH0_RX_DECODER=="64B66B_transparent") &&  (CH0_RDATA_WIDTH==16)) ? "64b66b_16bit" :
                                                     ((CH0_RX_DECODER=="64B66B_transparent") &&  (CH0_RDATA_WIDTH==32)) ? "64b66b_32bit" :
                                                     ((CH0_RX_DECODER=="64B67B_transparent") &&  (CH0_RDATA_WIDTH==16)) ? "64b67b_16bit" :
                                                     ((CH0_RX_DECODER=="64B67B_transparent") &&  (CH0_RDATA_WIDTH==32)) ? "64b67b_32bit" : "8b10b_32bit";
    localparam           CH1_RDATA_WIDTH_TYPE          = ((CH1_RX_DECODER=="Bypassed")&&(CH1_RDATA_WIDTH==8)) ? "8bit_only" :
                                                     ((CH1_RX_DECODER=="Bypassed")&&(CH1_RDATA_WIDTH==10)) ? "10bit_only" :
                                                     ((CH1_RX_DECODER=="Bypassed")&&(CH1_RDATA_WIDTH==16)) ? "16bit_only" :
                                                     ((CH1_RX_DECODER=="Bypassed")&&(CH1_RDATA_WIDTH==20)) ? "20bit_only" :
                                                     ((CH1_RX_DECODER=="Bypassed")&&(CH1_RDATA_WIDTH==32)) ? "32bit_only" :
                                                     ((CH1_RX_DECODER=="Bypassed")&&(CH1_RDATA_WIDTH==40)) ? "40bit_only" :
                                                     ((CH1_RX_DECODER=="8B10B") &&  (CH1_RDATA_WIDTH==8)) ? "8b10b_8bit" :
                                                     ((CH1_RX_DECODER=="8B10B") &&  (CH1_RDATA_WIDTH==16)) ? "8b10b_16bit" :
                                                     ((CH1_RX_DECODER=="64B66B_transparent") &&  (CH1_RDATA_WIDTH==16)) ? "64b66b_16bit" :
                                                     ((CH1_RX_DECODER=="64B66B_transparent") &&  (CH1_RDATA_WIDTH==32)) ? "64b66b_32bit" :
                                                     ((CH1_RX_DECODER=="64B67B_transparent") &&  (CH1_RDATA_WIDTH==16)) ? "64b67b_16bit" :
                                                     ((CH1_RX_DECODER=="64B67B_transparent") &&  (CH1_RDATA_WIDTH==32)) ? "64b67b_32bit" : "8b10b_32bit";
    localparam           CH2_RDATA_WIDTH_TYPE          = ((CH2_RX_DECODER=="Bypassed")&&(CH2_RDATA_WIDTH==8)) ? "8bit_only" :
                                                     ((CH2_RX_DECODER=="Bypassed")&&(CH2_RDATA_WIDTH==10)) ? "10bit_only" :
                                                     ((CH2_RX_DECODER=="Bypassed")&&(CH2_RDATA_WIDTH==16)) ? "16bit_only" :
                                                     ((CH2_RX_DECODER=="Bypassed")&&(CH2_RDATA_WIDTH==20)) ? "20bit_only" :
                                                     ((CH2_RX_DECODER=="Bypassed")&&(CH2_RDATA_WIDTH==32)) ? "32bit_only" :
                                                     ((CH2_RX_DECODER=="Bypassed")&&(CH2_RDATA_WIDTH==40)) ? "40bit_only" :
                                                     ((CH2_RX_DECODER=="8B10B") &&  (CH2_RDATA_WIDTH==8)) ? "8b10b_8bit" :
                                                     ((CH2_RX_DECODER=="8B10B") &&  (CH2_RDATA_WIDTH==16)) ? "8b10b_16bit" :
                                                     ((CH2_RX_DECODER=="64B66B_transparent") &&  (CH2_RDATA_WIDTH==16)) ? "64b66b_16bit" :
                                                     ((CH2_RX_DECODER=="64B66B_transparent") &&  (CH2_RDATA_WIDTH==32)) ? "64b66b_32bit" :
                                                     ((CH2_RX_DECODER=="64B67B_transparent") &&  (CH2_RDATA_WIDTH==16)) ? "64b67b_16bit" :
                                                     ((CH2_RX_DECODER=="64B67B_transparent") &&  (CH2_RDATA_WIDTH==32)) ? "64b67b_32bit" : "8b10b_32bit";
    localparam           CH3_RDATA_WIDTH_TYPE          = ((CH3_RX_DECODER=="Bypassed")&&(CH3_RDATA_WIDTH==8)) ? "8bit_only" :
                                                     ((CH3_RX_DECODER=="Bypassed")&&(CH3_RDATA_WIDTH==10)) ? "10bit_only" :
                                                     ((CH3_RX_DECODER=="Bypassed")&&(CH3_RDATA_WIDTH==16)) ? "16bit_only" :
                                                     ((CH3_RX_DECODER=="Bypassed")&&(CH3_RDATA_WIDTH==20)) ? "20bit_only" :
                                                     ((CH3_RX_DECODER=="Bypassed")&&(CH3_RDATA_WIDTH==32)) ? "32bit_only" :
                                                     ((CH3_RX_DECODER=="Bypassed")&&(CH3_RDATA_WIDTH==40)) ? "40bit_only" :
                                                     ((CH3_RX_DECODER=="8B10B") &&  (CH3_RDATA_WIDTH==8)) ? "8b10b_8bit" :
                                                     ((CH3_RX_DECODER=="8B10B") &&  (CH3_RDATA_WIDTH==16)) ? "8b10b_16bit" :
                                                     ((CH3_RX_DECODER=="64B66B_transparent") &&  (CH3_RDATA_WIDTH==16)) ? "64b66b_16bit" :
                                                     ((CH3_RX_DECODER=="64B66B_transparent") &&  (CH3_RDATA_WIDTH==32)) ? "64b66b_32bit" :
                                                     ((CH3_RX_DECODER=="64B67B_transparent") &&  (CH3_RDATA_WIDTH==16)) ? "64b67b_16bit" :
                                                     ((CH3_RX_DECODER=="64B67B_transparent") &&  (CH3_RDATA_WIDTH==32)) ? "64b67b_32bit" : "8b10b_32bit";
    localparam PCS_CH0_BYPASS_WORD_ALIGN = (CH0_RXPCS_ALIGN == "Bypassed") ? "TRUE" : "FALSE";
    localparam PCS_CH1_BYPASS_WORD_ALIGN = (CH1_RXPCS_ALIGN == "Bypassed") ? "TRUE" : "FALSE";
    localparam PCS_CH2_BYPASS_WORD_ALIGN = (CH2_RXPCS_ALIGN == "Bypassed") ? "TRUE" : "FALSE";
    localparam PCS_CH3_BYPASS_WORD_ALIGN = (CH3_RXPCS_ALIGN == "Bypassed") ? "TRUE" : "FALSE";
    localparam PCS_CH0_BYPASS_BONDING = (CH0_RXPCS_BONDING == "Bypassed") ? "TRUE" : "FALSE";
    localparam PCS_CH1_BYPASS_BONDING = (CH1_RXPCS_BONDING == "Bypassed") ? "TRUE" : "FALSE";
    localparam PCS_CH2_BYPASS_BONDING = (CH2_RXPCS_BONDING == "Bypassed") ? "TRUE" : "FALSE";
    localparam PCS_CH3_BYPASS_BONDING = (CH3_RXPCS_BONDING == "Bypassed") ? "TRUE" : "FALSE";
    localparam PCS_CH0_BYPASS_CTC = (CH0_RXPCS_CTC == "Bypassed") ? "TRUE" : "FALSE";
    localparam PCS_CH1_BYPASS_CTC = (CH1_RXPCS_CTC == "Bypassed") ? "TRUE" : "FALSE";
    localparam PCS_CH2_BYPASS_CTC = (CH2_RXPCS_CTC == "Bypassed") ? "TRUE" : "FALSE";
    localparam PCS_CH3_BYPASS_CTC = (CH3_RXPCS_CTC == "Bypassed") ? "TRUE" : "FALSE";
    localparam           PCS_CH0_ALIGN_MODE            = (CH0_RXPCS_ALIGN=="CUSTOMERIZED_MODE") ? "OUTSIDE" :
                                                     (CH0_RXPCS_ALIGN=="RAPIDIO_MODE") ? "RAPIDIO" :
                                                     (CH0_RXPCS_ALIGN=="XAUI_MODE") ? "10GB" : "1GB";
    localparam           PCS_CH1_ALIGN_MODE            = (CH1_RXPCS_ALIGN=="CUSTOMERIZED_MODE") ? "OUTSIDE" :
                                                     (CH1_RXPCS_ALIGN=="RAPIDIO_MODE") ? "RAPIDIO" :
                                                     (CH1_RXPCS_ALIGN=="XAUI_MODE") ? "10GB" : "1GB";
    localparam           PCS_CH2_ALIGN_MODE            = (CH2_RXPCS_ALIGN=="CUSTOMERIZED_MODE") ? "OUTSIDE" :
                                                     (CH2_RXPCS_ALIGN=="RAPIDIO_MODE") ? "RAPIDIO" :
                                                     (CH2_RXPCS_ALIGN=="XAUI_MODE") ? "10GB" : "1GB";
    localparam           PCS_CH3_ALIGN_MODE            = (CH3_RXPCS_ALIGN=="CUSTOMERIZED_MODE") ? "OUTSIDE" :
                                                     (CH3_RXPCS_ALIGN=="RAPIDIO_MODE") ? "RAPIDIO" :
                                                     (CH3_RXPCS_ALIGN=="XAUI_MODE") ? "10GB" : "1GB";
    localparam integer PCS_CH0_COMMA_REG0 = CH0_RXPCS_COMMA_REG0;
    localparam integer PCS_CH1_COMMA_REG0 = CH1_RXPCS_COMMA_REG0;
    localparam integer PCS_CH2_COMMA_REG0 = CH2_RXPCS_COMMA_REG0;
    localparam integer PCS_CH3_COMMA_REG0 = CH3_RXPCS_COMMA_REG0;
    localparam integer PCS_CH0_COMMA_REG1 = 1023 - CH0_RXPCS_COMMA_REG0;
    localparam integer PCS_CH1_COMMA_REG1 = 1023 - CH1_RXPCS_COMMA_REG0;
    localparam integer PCS_CH2_COMMA_REG1 = 1023 - CH2_RXPCS_COMMA_REG0;
    localparam integer PCS_CH3_COMMA_REG1 = 1023 - CH3_RXPCS_COMMA_REG0;
    localparam integer PCS_CH0_RAPID_IMAX = 5;
    localparam integer PCS_CH1_RAPID_IMAX = 5;
    localparam integer PCS_CH2_RAPID_IMAX = 5;
    localparam integer PCS_CH3_RAPID_IMAX = 5;
    localparam integer PCS_CH0_RAPID_VMIN_1 = 250;
    localparam integer PCS_CH1_RAPID_VMIN_1 = 250;
    localparam integer PCS_CH2_RAPID_VMIN_1 = 250;
    localparam integer PCS_CH3_RAPID_VMIN_1 = 250;
    localparam integer PCS_CH0_RAPID_VMIN_2 = 1;
    localparam integer PCS_CH1_RAPID_VMIN_2 = 1;
    localparam integer PCS_CH2_RAPID_VMIN_2 = 1;
    localparam integer PCS_CH3_RAPID_VMIN_2 = 1;
    localparam integer PCS_CH0_COMMA_MASK = CH0_RXPCS_COMMA_MASK;
    localparam integer PCS_CH1_COMMA_MASK = CH1_RXPCS_COMMA_MASK;
    localparam integer PCS_CH2_COMMA_MASK = CH2_RXPCS_COMMA_MASK;
    localparam integer PCS_CH3_COMMA_MASK = CH3_RXPCS_COMMA_MASK;
    localparam           PCS_CH0_CEB_MODE              = (CH0_RXPCS_BONDING=="CUSTOMERIZED_MODE") ? "OUTSIDE" :
                                                     (CH0_RXPCS_BONDING=="RAPIDIO_MODE") ? "RAPIDIO" : "10GB";
    localparam           PCS_CH1_CEB_MODE              = (CH1_RXPCS_BONDING=="CUSTOMERIZED_MODE") ? "OUTSIDE" :
                                                     (CH1_RXPCS_BONDING=="RAPIDIO_MODE") ? "RAPIDIO" : "10GB";
    localparam           PCS_CH2_CEB_MODE              = (CH2_RXPCS_BONDING=="CUSTOMERIZED_MODE") ? "OUTSIDE" :
                                                     (CH2_RXPCS_BONDING=="RAPIDIO_MODE") ? "RAPIDIO" : "10GB";
    localparam           PCS_CH3_CEB_MODE              = (CH3_RXPCS_BONDING=="CUSTOMERIZED_MODE") ? "OUTSIDE" :
                                                     (CH3_RXPCS_BONDING=="RAPIDIO_MODE") ? "RAPIDIO" : "10GB";
    localparam           PCS_CH0_CTC_MODE              = ((CH0_RXPCS_CTC=="CUSTOMERIZED_4BYTE")||(CH0_RXPCS_CTC=="PCIE_4BYTE")) ? "4SKIP" :
                                                     ((CH0_RXPCS_CTC=="CUSTOMERIZED_2BYTE")||(CH0_RXPCS_CTC=="GE"  )) ? "2SKIP" :
                                                      (CH0_RXPCS_CTC=="PCIE_2BYTE") ? "PCIE_2BYTE" : "1SKIP";
    localparam           PCS_CH1_CTC_MODE              = ((CH1_RXPCS_CTC=="CUSTOMERIZED_4BYTE")||(CH1_RXPCS_CTC=="PCIE_4BYTE")) ? "4SKIP" :
                                                     ((CH1_RXPCS_CTC=="CUSTOMERIZED_2BYTE")||(CH1_RXPCS_CTC=="GE"  )) ? "2SKIP" :
                                                      (CH1_RXPCS_CTC=="PCIE_2BYTE") ? "PCIE_2BYTE" : "1SKIP";
    localparam           PCS_CH2_CTC_MODE              = ((CH2_RXPCS_CTC=="CUSTOMERIZED_4BYTE")||(CH2_RXPCS_CTC=="PCIE_4BYTE")) ? "4SKIP" :
                                                     ((CH2_RXPCS_CTC=="CUSTOMERIZED_2BYTE")||(CH2_RXPCS_CTC=="GE"  )) ? "2SKIP" :
                                                      (CH2_RXPCS_CTC=="PCIE_2BYTE") ? "PCIE_2BYTE" : "1SKIP";
    localparam           PCS_CH3_CTC_MODE              = ((CH3_RXPCS_CTC=="CUSTOMERIZED_4BYTE")||(CH3_RXPCS_CTC=="PCIE_4BYTE")) ? "4SKIP" :
                                                     ((CH3_RXPCS_CTC=="CUSTOMERIZED_2BYTE")||(CH3_RXPCS_CTC=="GE"  )) ? "2SKIP" :
                                                      (CH3_RXPCS_CTC=="PCIE_2BYTE") ? "PCIE_2BYTE" : "1SKIP";
    localparam integer PCS_CH0_SKIP_REG0 = CH0_RXPCS_SKIP_REG0;
    localparam integer PCS_CH1_SKIP_REG0 = CH1_RXPCS_SKIP_REG0;
    localparam integer PCS_CH2_SKIP_REG0 = CH2_RXPCS_SKIP_REG0;
    localparam integer PCS_CH3_SKIP_REG0 = CH3_RXPCS_SKIP_REG0;
    localparam integer PCS_CH0_SKIP_REG1 = CH0_RXPCS_SKIP_REG1;
    localparam integer PCS_CH1_SKIP_REG1 = CH1_RXPCS_SKIP_REG1;
    localparam integer PCS_CH2_SKIP_REG1 = CH2_RXPCS_SKIP_REG1;
    localparam integer PCS_CH3_SKIP_REG1 = CH3_RXPCS_SKIP_REG1;
    localparam integer PCS_CH0_SKIP_REG2 = CH0_RXPCS_SKIP_REG2;
    localparam integer PCS_CH1_SKIP_REG2 = CH1_RXPCS_SKIP_REG2;
    localparam integer PCS_CH2_SKIP_REG2 = CH2_RXPCS_SKIP_REG2;
    localparam integer PCS_CH3_SKIP_REG2 = CH3_RXPCS_SKIP_REG2;
    localparam integer PCS_CH0_SKIP_REG3 = CH0_RXPCS_SKIP_REG3;
    localparam integer PCS_CH1_SKIP_REG3 = CH1_RXPCS_SKIP_REG3;
    localparam integer PCS_CH2_SKIP_REG3 = CH2_RXPCS_SKIP_REG3;
    localparam integer PCS_CH3_SKIP_REG3 = CH3_RXPCS_SKIP_REG3;
    localparam PCS_CH0_GE_AUTO_EN = (CH0_RXPCS_CTC == "GE") ? "TRUE" : "FALSE";
    localparam PCS_CH1_GE_AUTO_EN = (CH1_RXPCS_CTC == "GE") ? "TRUE" : "FALSE";
    localparam PCS_CH2_GE_AUTO_EN = (CH2_RXPCS_CTC == "GE") ? "TRUE" : "FALSE";
    localparam PCS_CH3_GE_AUTO_EN = (CH3_RXPCS_CTC == "GE") ? "TRUE" : "FALSE";
    localparam integer PCS_CH0_A_REG = CH0_RXPCS_A_REG;
    localparam integer PCS_CH1_A_REG = CH1_RXPCS_A_REG;
    localparam integer PCS_CH2_A_REG = CH2_RXPCS_A_REG;
    localparam integer PCS_CH3_A_REG = CH3_RXPCS_A_REG;
    localparam PCS_CH0_PCIE_SLAVE = "MASTER";
    localparam PCS_CH1_PCIE_SLAVE = (CH0_PROTOCOL == "PCIEx4" || CH0_PROTOCOL == "PCIEx2") ? "SLAVE" : "MASTER";
    localparam PCS_CH2_PCIE_SLAVE = (CH0_PROTOCOL == "PCIEx4") ? "SLAVE" : "MASTER";
    localparam PCS_CH3_PCIE_SLAVE = (CH0_PROTOCOL == "PCIEx4" || CH2_PROTOCOL == "PCIEx2") ? "SLAVE" : "MASTER";
    localparam integer PCS_CH0_SLAVE = 0;
    localparam integer PCS_CH1_SLAVE = (PCS_CH1_BYPASS_BONDING == "FALSE") ? 1 : 0;
    localparam   integer PCS_CH2_SLAVE                 = (CH0_PROTOCOL=="CUSTOMERIZEDx4" && PCS_CH2_BYPASS_BONDING=="FALSE") ? 1 :
                                                     (CH0_PROTOCOL=="XAUI" && PCS_CH2_BYPASS_BONDING=="FALSE") ? 1 : 0;
    localparam   integer PCS_CH3_SLAVE                 = (CH0_PROTOCOL=="CUSTOMERIZEDx4" && PCS_CH3_BYPASS_BONDING=="FALSE") ? 1 :
                                                     (CH0_PROTOCOL=="XAUI" && PCS_CH3_BYPASS_BONDING=="FALSE") ? 1 :
                                                     (CH2_PROTOCOL=="CUSTOMERIZEDx2" && PCS_CH3_BYPASS_BONDING=="FALSE") ? 1 : 0;
    localparam PCS_CH0_TX_SLAVE = "MASTER";
    localparam           PCS_CH1_TX_SLAVE              = (CH0_PROTOCOL=="CUSTOMERIZEDx4") ? "SLAVE" :
                                                     (CH0_PROTOCOL=="PCIEx4") ? "SLAVE" :
                                                     (CH0_PROTOCOL=="XAUI") ? "SLAVE" :
                                                     (CH0_PROTOCOL=="CUSTOMERIZEDx2" || CH0_PROTOCOL=="PCIEx2") ? "SLAVE" :
                                                     "MASTER";
    localparam           PCS_CH2_TX_SLAVE               = (CH0_PROTOCOL=="CUSTOMERIZEDx4") ? "SLAVE" :
                                                     (CH0_PROTOCOL=="PCIEx4") ? "SLAVE" :
                                                     (CH0_PROTOCOL=="XAUI") ? "SLAVE" : "MASTER";
    localparam           PCS_CH3_TX_SLAVE               = (CH0_PROTOCOL=="CUSTOMERIZEDx4") ? "SLAVE" :
                                                     (CH0_PROTOCOL=="PCIEx4") ? "SLAVE" :
                                                     (CH0_PROTOCOL=="XAUI") ? "SLAVE" :
                                                     (CH2_PROTOCOL=="CUSTOMERIZEDx2" || CH2_PROTOCOL=="PCIEx2") ? "SLAVE" : "MASTER";
    localparam integer PCS_CH0_MASTER_CHECK_OFFSET = 4;
    localparam integer PCS_CH1_MASTER_CHECK_OFFSET = 4;
    localparam integer PCS_CH2_MASTER_CHECK_OFFSET = 4;
    localparam integer PCS_CH3_MASTER_CHECK_OFFSET = 4;
    localparam integer PCS_CH0_DELAY_SET = 3;
    localparam integer PCS_CH1_DELAY_SET = 2;  // 通道 0 的 PCIe 双通道配置
    localparam integer PCS_CH2_DELAY_SET = (CH2_PROTOCOL == "CUSTOMERIZEDx2") ? 3 : 1;
    localparam   integer PCS_CH3_DELAY_SET             = (CH2_PROTOCOL=="CUSTOMERIZEDx2") ? 2 : 0; // 通道 2 的 PCIe 双通道配置
    localparam PCS_CH0_SEACH_OFFSET = CH0_RXPCS_BONDING_RANGE;
    localparam PCS_CH1_SEACH_OFFSET = CH1_RXPCS_BONDING_RANGE;
    localparam PCS_CH2_SEACH_OFFSET = CH2_RXPCS_BONDING_RANGE;
    localparam PCS_CH3_SEACH_OFFSET = CH3_RXPCS_BONDING_RANGE;
    localparam integer PCS_CH0_CEB_RAPIDLS_MMAX = 5;
    localparam integer PCS_CH1_CEB_RAPIDLS_MMAX = 5;
    localparam integer PCS_CH2_CEB_RAPIDLS_MMAX = 5;
    localparam integer PCS_CH3_CEB_RAPIDLS_MMAX = 5;
    localparam PCS_CH0_PMA_TX2RX_PLOOP_EN = CH0_DEBUG_BUS;  // 使能选项：开启或关闭。
    localparam PCS_CH1_PMA_TX2RX_PLOOP_EN = CH1_DEBUG_BUS;  // 使能选项：开启或关闭。
    localparam PCS_CH2_PMA_TX2RX_PLOOP_EN = CH2_DEBUG_BUS;  // 使能选项：开启或关闭。
    localparam PCS_CH3_PMA_TX2RX_PLOOP_EN = CH3_DEBUG_BUS;  // 使能选项：开启或关闭。
    localparam PCS_CH0_PMA_TX2RX_SLOOP_EN = CH0_DEBUG_BUS;  // 使能选项：开启或关闭。
    localparam PCS_CH1_PMA_TX2RX_SLOOP_EN = CH1_DEBUG_BUS;  // 使能选项：开启或关闭。
    localparam PCS_CH2_PMA_TX2RX_SLOOP_EN = CH2_DEBUG_BUS;  // 使能选项：开启或关闭。
    localparam PCS_CH3_PMA_TX2RX_SLOOP_EN = CH3_DEBUG_BUS;  // 使能选项：开启或关闭。
    localparam PCS_CH0_PMA_RX2TX_PLOOP_EN = CH0_DEBUG_BUS;  // 使能选项：开启或关闭。
    localparam PCS_CH1_PMA_RX2TX_PLOOP_EN = CH1_DEBUG_BUS;  // 使能选项：开启或关闭。
    localparam PCS_CH2_PMA_RX2TX_PLOOP_EN = CH2_DEBUG_BUS;  // 使能选项：开启或关闭。
    localparam PCS_CH3_PMA_RX2TX_PLOOP_EN = CH3_DEBUG_BUS;  // 使能选项：开启或关闭。

    localparam PMA_CH0_REG_TX_BUSWIDTH_OW = "TRUE";
    localparam PMA_CH1_REG_TX_BUSWIDTH_OW = "TRUE";
    localparam PMA_CH2_REG_TX_BUSWIDTH_OW = "TRUE";
    localparam PMA_CH3_REG_TX_BUSWIDTH_OW = "TRUE";
    localparam PMA_CH0_REG_RX_BUSWIDTH_EN = "TRUE";
    localparam PMA_CH1_REG_RX_BUSWIDTH_EN = "TRUE";
    localparam PMA_CH2_REG_RX_BUSWIDTH_EN = "TRUE";
    localparam PMA_CH3_REG_RX_BUSWIDTH_EN = "TRUE";
    localparam integer PMA_CH0_REG_RX_TERM_MODE_CTRL = CH0_RXPMA_RTERM;
    localparam integer PMA_CH1_REG_RX_TERM_MODE_CTRL = CH1_RXPMA_RTERM;
    localparam integer PMA_CH2_REG_RX_TERM_MODE_CTRL = CH2_RXPMA_RTERM;
    localparam integer PMA_CH3_REG_RX_TERM_MODE_CTRL = CH3_RXPMA_RTERM;
    localparam integer PMA_CH0_REG_RX_RESERVED_361_354 = 0;
    localparam integer PMA_CH1_REG_RX_RESERVED_361_354 = 0;
    localparam integer PMA_CH2_REG_RX_RESERVED_361_354 = 0;
    localparam integer PMA_CH3_REG_RX_RESERVED_361_354 = 0;
    localparam PMA_CH0_REG_RX_HIGHZ = "FALSE";
    localparam PMA_CH1_REG_RX_HIGHZ = "FALSE";
    localparam PMA_CH2_REG_RX_HIGHZ = "FALSE";
    localparam PMA_CH3_REG_RX_HIGHZ = "FALSE";
    localparam PMA_CH0_REG_RX_HIGHZ_EN = "FALSE";
    localparam PMA_CH1_REG_RX_HIGHZ_EN = "FALSE";
    localparam PMA_CH2_REG_RX_HIGHZ_EN = "FALSE";
    localparam PMA_CH3_REG_RX_HIGHZ_EN = "FALSE";
    localparam           PMA_CH0_REG_CDR_LOCK_TIMER    = (CH0_PROTOCOL=="PCIEx1" || CH0_PROTOCOL=="PCIEx2" || CH0_PROTOCOL=="PCIEx4") ? "1_2U" : "25_6U";
    localparam           PMA_CH1_REG_CDR_LOCK_TIMER    = (CH1_PROTOCOL=="PCIEx1" || CH1_PROTOCOL=="PCIEx2" || CH1_PROTOCOL=="PCIEx4") ? "1_2U" : "25_6U";
    localparam           PMA_CH2_REG_CDR_LOCK_TIMER    = (CH2_PROTOCOL=="PCIEx1" || CH2_PROTOCOL=="PCIEx2" || CH2_PROTOCOL=="PCIEx4") ? "1_2U" : "25_6U";
    localparam           PMA_CH3_REG_CDR_LOCK_TIMER    = (CH3_PROTOCOL=="PCIEx1" || CH3_PROTOCOL=="PCIEx2" || CH3_PROTOCOL=="PCIEx4") ? "1_2U" : "25_6U";
    localparam PMA_CH0_REG_PD_PRE = CH0_PRE_CURSOR_EN == "TRUE" ? "FALSE" : "TRUE";
    localparam PMA_CH1_REG_PD_PRE = CH1_PRE_CURSOR_EN == "TRUE" ? "FALSE" : "TRUE";
    localparam PMA_CH2_REG_PD_PRE = CH2_PRE_CURSOR_EN == "TRUE" ? "FALSE" : "TRUE";
    localparam PMA_CH3_REG_PD_PRE = CH3_PRE_CURSOR_EN == "TRUE" ? "FALSE" : "TRUE";
    localparam integer PMA_CH0_REG_TX_CFG_PRE = CH0_PRE_CURSOR_EMPHASIS;
    localparam integer PMA_CH1_REG_TX_CFG_PRE = CH1_PRE_CURSOR_EMPHASIS;
    localparam integer PMA_CH2_REG_TX_CFG_PRE = CH2_PRE_CURSOR_EMPHASIS;
    localparam integer PMA_CH3_REG_TX_CFG_PRE = CH3_PRE_CURSOR_EMPHASIS;
    localparam PMA_CH0_REG_TX_PD_POST = (CH0_POST_CURSOR_EN == "TRUE" || CH0_FFE_CTRL_EN == "TRUE") ? "ON" : "OFF";
    localparam PMA_CH1_REG_TX_PD_POST = (CH1_POST_CURSOR_EN == "TRUE" || CH1_FFE_CTRL_EN == "TRUE") ? "ON" : "OFF";
    localparam PMA_CH2_REG_TX_PD_POST = (CH2_POST_CURSOR_EN == "TRUE" || CH2_FFE_CTRL_EN == "TRUE") ? "ON" : "OFF";
    localparam PMA_CH3_REG_TX_PD_POST = (CH3_POST_CURSOR_EN == "TRUE" || CH3_FFE_CTRL_EN == "TRUE") ? "ON" : "OFF";
    localparam integer PMA_CH0_REG_CFG_POST = CH0_POST_CURSOR_EMPHASIS;
    localparam integer PMA_CH1_REG_CFG_POST = CH1_POST_CURSOR_EMPHASIS;
    localparam integer PMA_CH2_REG_CFG_POST = CH2_POST_CURSOR_EMPHASIS;
    localparam integer PMA_CH3_REG_CFG_POST = CH3_POST_CURSOR_EMPHASIS;
    localparam integer PMA_CH0_REG_CFG_POST1 = CH0_POST1_CURSOR_EMPHASIS;
    localparam integer PMA_CH1_REG_CFG_POST1 = CH1_POST1_CURSOR_EMPHASIS;
    localparam integer PMA_CH2_REG_CFG_POST1 = CH2_POST1_CURSOR_EMPHASIS;
    localparam integer PMA_CH3_REG_CFG_POST1 = CH3_POST1_CURSOR_EMPHASIS;
    localparam integer PMA_CH0_REG_CFG_POST2 = CH0_POST2_CURSOR_EMPHASIS;
    localparam integer PMA_CH1_REG_CFG_POST2 = CH1_POST2_CURSOR_EMPHASIS;
    localparam integer PMA_CH2_REG_CFG_POST2 = CH2_POST2_CURSOR_EMPHASIS;
    localparam integer PMA_CH3_REG_CFG_POST2 = CH3_POST2_CURSOR_EMPHASIS;
    localparam integer PMA_CH0_REG_RX_RESERVED_353_346 = CH0_RX_CLK_SLIP_EN == "TRUE" ? 1 : 0;
    localparam integer PMA_CH1_REG_RX_RESERVED_353_346 = CH1_RX_CLK_SLIP_EN == "TRUE" ? 1 : 0;
    localparam integer PMA_CH2_REG_RX_RESERVED_353_346 = CH2_RX_CLK_SLIP_EN == "TRUE" ? 1 : 0;
    localparam integer PMA_CH3_REG_RX_RESERVED_353_346 = CH3_RX_CLK_SLIP_EN == "TRUE" ? 1 : 0;

    localparam           PMA_PLL0_REG_REFCLK_PAD_SEL   = (PLL0_REF_SEL=="Fabric_REFCK0" || PLL0_REF_SEL=="Fabric_REFCK1") ? "TRUE" : "FALSE";
    localparam           PMA_PLL1_REG_REFCLK_PAD_SEL   = (PLL1_REF_SEL=="Fabric_REFCK0" || PLL1_REF_SEL=="Fabric_REFCK1") ? "TRUE" : "FALSE";

    localparam PMA_PLL0_PARM_PLL_POWERUP = "ON";
    localparam PMA_PLL0_REG_PLL_LOCKDET_MODE = "FALSE";
    localparam integer PMA_PLL0_REG_PLL_LOCKDET_FBCT = 3;
    localparam integer PMA_PLL0_REG_PLL_LOCKDET_ITER = 0;
    localparam integer PMA_PLL0_REG_PLL_LOCKDET_REFCT = 3;
    localparam integer PMA_PLL0_REG_PLL_REFDIV = (PLL0_M == 2) ? 0 : 16;  // 取值 16 表示 M=1。
    localparam integer PMA_PLL0_REG_PLL_FBDIV = (PLL0_N2 == 1 && PLL0_N1 == 4) ? 6'b010000 :  // N1*N2 = 4
    (PLL0_N2 == 1 && PLL0_N1 == 5) ? 6'b110000 :  // N1*N2 = 5
    (PLL0_N2 == 2 && PLL0_N1 == 4) ? 6'b000000 :  // N1*N2 = 8
    (PLL0_N2 == 2 && PLL0_N1 == 5) ? 6'b100000 :  // N1*N2 = 10
    (PLL0_N2 == 3 && PLL0_N1 == 4) ? 6'b000001 :  // N1*N2 = 12
    (PLL0_N2 == 3 && PLL0_N1 == 5) ? 6'b100001 :  // N1*N2 = 15
    (PLL0_N2 == 4 && PLL0_N1 == 4) ? 6'b000100 :  // N1*N2 = 16
    (PLL0_N2 == 5 && PLL0_N1 == 4) ? 6'b000011 :  // N1*N2 = 20
    (PLL0_N2 == 4 && PLL0_N1 == 5) ? 6'b100100 :  // N1*N2 = 20
    (PLL0_N2 == 6 && PLL0_N1 == 4) ? 6'b000101 :  // N1*N2 = 24
    (PLL0_N2 == 5 && PLL0_N1 == 5) ? 6'b100011 :  // N1*N2 = 25
    (PLL0_N2 == 6 && PLL0_N1 == 5) ? 6'b100101 :  // N1*N2 = 30
    (PLL0_N2 == 8 && PLL0_N1 == 4) ? 6'b000110 :  // N1*N2 = 32
    (PLL0_N2 == 8 && PLL0_N1 == 5) ? 6'b100110 : 6'b100111;  // N1×N2 取 40 或 50。

    localparam PMA_PLL1_PARM_PLL_POWERUP = PLL_NUM == 2 ? "ON" : "OFF";
    localparam PMA_PLL1_REG_PLL_LOCKDET_MODE = "FALSE";
    localparam integer PMA_PLL1_REG_PLL_LOCKDET_FBCT = 3;
    localparam integer PMA_PLL1_REG_PLL_LOCKDET_ITER = 0;
    localparam integer PMA_PLL1_REG_PLL_LOCKDET_REFCT = 3;
    localparam integer PMA_PLL1_REG_PLL_REFDIV = (PLL1_M == 2) ? 0 : 16;  // 取值 16 表示 M=1。
    localparam integer PMA_PLL1_REG_PLL_FBDIV = (PLL1_N2 == 1 && PLL1_N1 == 4) ? 6'b010000 :  // N1*N2 = 4
    (PLL1_N2 == 1 && PLL1_N1 == 5) ? 6'b110000 :  // N1*N2 = 5
    (PLL1_N2 == 2 && PLL1_N1 == 4) ? 6'b000000 :  // N1*N2 = 8
    (PLL1_N2 == 2 && PLL1_N1 == 5) ? 6'b100000 :  // N1*N2 = 10
    (PLL1_N2 == 3 && PLL1_N1 == 4) ? 6'b000001 :  // N1*N2 = 12
    (PLL1_N2 == 3 && PLL1_N1 == 5) ? 6'b100001 :  // N1*N2 = 15
    (PLL1_N2 == 4 && PLL1_N1 == 4) ? 6'b000100 :  // N1*N2 = 16
    (PLL1_N2 == 5 && PLL1_N1 == 4) ? 6'b000011 :  // N1*N2 = 20
    (PLL1_N2 == 4 && PLL1_N1 == 5) ? 6'b100100 :  // N1*N2 = 20
    (PLL1_N2 == 6 && PLL1_N1 == 4) ? 6'b000101 :  // N1*N2 = 24
    (PLL1_N2 == 5 && PLL1_N1 == 5) ? 6'b100011 :  // N1*N2 = 25
    (PLL1_N2 == 6 && PLL1_N1 == 5) ? 6'b100101 :  // N1*N2 = 30
    (PLL1_N2 == 8 && PLL1_N1 == 4) ? 6'b000110 :  // N1*N2 = 32
    (PLL1_N2 == 8 && PLL1_N1 == 5) ? 6'b100110 : 6'b100111;  // N1×N2 取 40 或 50。

    //---------------------------------------------------
    localparam PCS_CH0_TX_BYPASS_ENC  =  CH0_TDATA_WIDTH_TYPE == "8b10b_8bit"   ? "FALSE" :
                                    CH0_TDATA_WIDTH_TYPE == "8b10b_16bit"  ? "FALSE" :
                                    CH0_TDATA_WIDTH_TYPE == "8b10b_32bit"  ? "FALSE" : "TRUE";
    localparam PCS_CH1_TX_BYPASS_ENC  =  CH1_TDATA_WIDTH_TYPE == "8b10b_8bit"   ? "FALSE" :
                                    CH1_TDATA_WIDTH_TYPE == "8b10b_16bit"  ? "FALSE" :
                                    CH1_TDATA_WIDTH_TYPE == "8b10b_32bit"  ? "FALSE" : "TRUE";
    localparam PCS_CH2_TX_BYPASS_ENC  =  CH2_TDATA_WIDTH_TYPE == "8b10b_8bit"   ? "FALSE" :
                                    CH2_TDATA_WIDTH_TYPE == "8b10b_16bit"  ? "FALSE" :
                                    CH2_TDATA_WIDTH_TYPE == "8b10b_32bit"  ? "FALSE" : "TRUE";
    localparam PCS_CH3_TX_BYPASS_ENC  =  CH3_TDATA_WIDTH_TYPE == "8b10b_8bit"   ? "FALSE" :
                                    CH3_TDATA_WIDTH_TYPE == "8b10b_16bit"  ? "FALSE" :
                                    CH3_TDATA_WIDTH_TYPE == "8b10b_32bit"  ? "FALSE" : "TRUE";

    localparam PCS_CH0_TX_BYPASS_GEAR = CH0_TDATA_WIDTH_TYPE == "32bit_only"  ? "FALSE" :
                                    CH0_TDATA_WIDTH_TYPE == "40bit_only"  ? "FALSE" :
                                    CH0_TDATA_WIDTH_TYPE == "8b10b_32bit" ? "FALSE" :
                                    CH0_TDATA_WIDTH_TYPE == "64b66b_16bit"? "FALSE" :
                                    CH0_TDATA_WIDTH_TYPE == "64b66b_32bit"? "FALSE" :
                                    CH0_TDATA_WIDTH_TYPE == "64b67b_16bit"? "FALSE" :
                                    CH0_TDATA_WIDTH_TYPE == "64b67b_32bit"? "FALSE" : "TRUE";
    localparam PCS_CH1_TX_BYPASS_GEAR = CH1_TDATA_WIDTH_TYPE == "32bit_only"  ? "FALSE" :
                                    CH1_TDATA_WIDTH_TYPE == "40bit_only"  ? "FALSE" :
                                    CH1_TDATA_WIDTH_TYPE == "8b10b_32bit" ? "FALSE" :
                                    CH1_TDATA_WIDTH_TYPE == "64b66b_16bit"? "FALSE" :
                                    CH1_TDATA_WIDTH_TYPE == "64b66b_32bit"? "FALSE" :
                                    CH1_TDATA_WIDTH_TYPE == "64b67b_16bit"? "FALSE" :
                                    CH1_TDATA_WIDTH_TYPE == "64b67b_32bit"? "FALSE" : "TRUE";
    localparam PCS_CH2_TX_BYPASS_GEAR = CH2_TDATA_WIDTH_TYPE == "32bit_only"  ? "FALSE" :
                                    CH2_TDATA_WIDTH_TYPE == "40bit_only"  ? "FALSE" :
                                    CH2_TDATA_WIDTH_TYPE == "8b10b_32bit" ? "FALSE" :
                                    CH2_TDATA_WIDTH_TYPE == "64b66b_16bit"? "FALSE" :
                                    CH2_TDATA_WIDTH_TYPE == "64b66b_32bit"? "FALSE" :
                                    CH2_TDATA_WIDTH_TYPE == "64b67b_16bit"? "FALSE" :
                                    CH2_TDATA_WIDTH_TYPE == "64b67b_32bit"? "FALSE" : "TRUE";
    localparam PCS_CH3_TX_BYPASS_GEAR = CH3_TDATA_WIDTH_TYPE == "32bit_only"  ? "FALSE" :
                                    CH3_TDATA_WIDTH_TYPE == "40bit_only"  ? "FALSE" :
                                    CH3_TDATA_WIDTH_TYPE == "8b10b_32bit" ? "FALSE" :
                                    CH3_TDATA_WIDTH_TYPE == "64b66b_16bit"? "FALSE" :
                                    CH3_TDATA_WIDTH_TYPE == "64b66b_32bit"? "FALSE" :
                                    CH3_TDATA_WIDTH_TYPE == "64b67b_16bit"? "FALSE" :
                                    CH3_TDATA_WIDTH_TYPE == "64b67b_32bit"? "FALSE" : "TRUE";

    localparam PCS_CH0_TX_PCS_CLK_EN_SEL =CH0_TDATA_WIDTH_TYPE == "32bit_only"  ? "TRUE" :
                                      CH0_TDATA_WIDTH_TYPE == "40bit_only"  ? "TRUE" :
                                      CH0_TDATA_WIDTH_TYPE == "8b10b_32bit" ? "TRUE" :
                                      CH0_TDATA_WIDTH_TYPE == "64b66b_32bit"? "TRUE" :
                                      CH0_TDATA_WIDTH_TYPE == "64b67b_32bit"? "TRUE" :
                                      TX0_CLK2_FR_CORE     == "TRUE"        ? "TRUE" : "FALSE";
    localparam PCS_CH1_TX_PCS_CLK_EN_SEL =CH1_TDATA_WIDTH_TYPE == "32bit_only"  ? "TRUE" :
                                      CH1_TDATA_WIDTH_TYPE == "40bit_only"  ? "TRUE" :
                                      CH1_TDATA_WIDTH_TYPE == "8b10b_32bit" ? "TRUE" :
                                      CH1_TDATA_WIDTH_TYPE == "64b66b_32bit"? "TRUE" :
                                      CH1_TDATA_WIDTH_TYPE == "64b67b_32bit"? "TRUE" :
                                      TX1_CLK2_FR_CORE     == "TRUE"        ? "TRUE" : "FALSE";
    localparam PCS_CH2_TX_PCS_CLK_EN_SEL =CH2_TDATA_WIDTH_TYPE == "32bit_only"  ? "TRUE" :
                                      CH2_TDATA_WIDTH_TYPE == "40bit_only"  ? "TRUE" :
                                      CH2_TDATA_WIDTH_TYPE == "8b10b_32bit" ? "TRUE" :
                                      CH2_TDATA_WIDTH_TYPE == "64b66b_32bit"? "TRUE" :
                                      CH2_TDATA_WIDTH_TYPE == "64b67b_32bit"? "TRUE" :
                                      TX2_CLK2_FR_CORE     == "TRUE"        ? "TRUE" : "FALSE";
    localparam PCS_CH3_TX_PCS_CLK_EN_SEL =CH3_TDATA_WIDTH_TYPE == "32bit_only"  ? "TRUE" :
                                      CH3_TDATA_WIDTH_TYPE == "40bit_only"  ? "TRUE" :
                                      CH3_TDATA_WIDTH_TYPE == "8b10b_32bit" ? "TRUE" :
                                      CH3_TDATA_WIDTH_TYPE == "64b66b_32bit"? "TRUE" :
                                      CH3_TDATA_WIDTH_TYPE == "64b67b_32bit"? "TRUE" :
                                      TX3_CLK2_FR_CORE     == "TRUE"        ? "TRUE" : "FALSE";

    localparam PCS_CH0_TX_BRIDGE_TCLK_SEL = TX0_CLK2_FR_CORE == "TRUE" ? "TCLK2" : "TCLK";
    localparam PCS_CH1_TX_BRIDGE_TCLK_SEL = TX1_CLK2_FR_CORE == "TRUE" ? "TCLK2" : "TCLK";
    localparam PCS_CH2_TX_BRIDGE_TCLK_SEL = TX2_CLK2_FR_CORE == "TRUE" ? "TCLK2" : "TCLK";
    localparam PCS_CH3_TX_BRIDGE_TCLK_SEL = TX3_CLK2_FR_CORE == "TRUE" ? "TCLK2" : "TCLK";

    localparam PCS_CH0_PCS_TCLK_SEL = "PMA_TCLK";
    localparam PCS_CH1_PCS_TCLK_SEL = "PMA_TCLK";
    localparam PCS_CH2_PCS_TCLK_SEL = "PMA_TCLK";
    localparam PCS_CH3_PCS_TCLK_SEL = "PMA_TCLK";

    localparam PCS_CH0_TX_GEAR_CLK_EN_SEL = TX0_CLK2_FR_CORE == "TRUE" ? "TRUE" : "FALSE";
    localparam PCS_CH1_TX_GEAR_CLK_EN_SEL = TX1_CLK2_FR_CORE == "TRUE" ? "TRUE" : "FALSE";
    localparam PCS_CH2_TX_GEAR_CLK_EN_SEL = TX2_CLK2_FR_CORE == "TRUE" ? "TRUE" : "FALSE";
    localparam PCS_CH3_TX_GEAR_CLK_EN_SEL = TX3_CLK2_FR_CORE == "TRUE" ? "TRUE" : "FALSE";

    localparam PCS_CH0_GEAR_TCLK_SEL = TX0_CLK2_FR_CORE == "TRUE" ? "TCLK2" : "PMA_TCLK";
    localparam PCS_CH1_GEAR_TCLK_SEL = TX1_CLK2_FR_CORE == "TRUE" ? "TCLK2" : "PMA_TCLK";
    localparam PCS_CH2_GEAR_TCLK_SEL = TX2_CLK2_FR_CORE == "TRUE" ? "TCLK2" : "PMA_TCLK";
    localparam PCS_CH3_GEAR_TCLK_SEL = TX3_CLK2_FR_CORE == "TRUE" ? "TCLK2" : "PMA_TCLK";

    localparam PCS_CH0_TX_BRIDGE_GEAR_SEL = TX0_CLK2_FR_CORE == "TRUE" ? "TRUE" : "FALSE";
    localparam PCS_CH1_TX_BRIDGE_GEAR_SEL = TX1_CLK2_FR_CORE == "TRUE" ? "TRUE" : "FALSE";
    localparam PCS_CH2_TX_BRIDGE_GEAR_SEL = TX2_CLK2_FR_CORE == "TRUE" ? "TRUE" : "FALSE";
    localparam PCS_CH3_TX_BRIDGE_GEAR_SEL = TX3_CLK2_FR_CORE == "TRUE" ? "TRUE" : "FALSE";

    localparam PCS_CH0_TX_BYPASS_BRIDGE_UINT = "FALSE";
    localparam PCS_CH1_TX_BYPASS_BRIDGE_UINT = "FALSE";
    localparam PCS_CH2_TX_BYPASS_BRIDGE_UINT = "FALSE";
    localparam PCS_CH3_TX_BYPASS_BRIDGE_UINT = "FALSE";

    localparam PCS_CH0_TX_BYPASS_BRIDGE_FIFO = "FALSE";
    localparam PCS_CH1_TX_BYPASS_BRIDGE_FIFO = "FALSE";
    localparam PCS_CH2_TX_BYPASS_BRIDGE_FIFO = "FALSE";
    localparam PCS_CH3_TX_BYPASS_BRIDGE_FIFO = "FALSE";

    localparam PCS_CH0_TX_TCLK2FABRIC_SEL 	= CH0_TDATA_WIDTH_TYPE == "32bit_only"  ? "TRUE" :
                                          CH0_TDATA_WIDTH_TYPE == "40bit_only"  ? "TRUE" :
                                          CH0_TDATA_WIDTH_TYPE == "8b10b_32bit" ? "TRUE" :
                                          CH0_TDATA_WIDTH_TYPE == "64b66b_32bit"? "TRUE" :
                                          CH0_TDATA_WIDTH_TYPE == "64b67b_32bit"? "TRUE" : "FALSE";
    localparam PCS_CH1_TX_TCLK2FABRIC_SEL 	= PCIE_CLK_MODE_EN_1   == "TRUE"        ? "FALSE":
                                          CH1_TDATA_WIDTH_TYPE == "32bit_only"  ? "TRUE" :
                                          CH1_TDATA_WIDTH_TYPE == "40bit_only"  ? "TRUE" :
                                          CH1_TDATA_WIDTH_TYPE == "8b10b_32bit" ? "TRUE" :
                                          CH1_TDATA_WIDTH_TYPE == "64b66b_32bit"? "TRUE" :
                                          CH1_TDATA_WIDTH_TYPE == "64b67b_32bit"? "TRUE" : "FALSE";
    localparam PCS_CH2_TX_TCLK2FABRIC_SEL 	= CH2_TDATA_WIDTH_TYPE == "32bit_only"  ? "TRUE" :
                                          CH2_TDATA_WIDTH_TYPE == "40bit_only"  ? "TRUE" :
                                          CH2_TDATA_WIDTH_TYPE == "8b10b_32bit" ? "TRUE" :
                                          CH2_TDATA_WIDTH_TYPE == "64b66b_32bit"? "TRUE" :
                                          CH2_TDATA_WIDTH_TYPE == "64b67b_32bit"? "TRUE" : "FALSE";
    localparam PCS_CH3_TX_TCLK2FABRIC_SEL 	= PCIE_CLK_MODE_EN_3   == "TRUE"        ? "FALSE":
                                          CH3_TDATA_WIDTH_TYPE == "32bit_only"  ? "TRUE" :
                                          CH3_TDATA_WIDTH_TYPE == "40bit_only"  ? "TRUE" :
                                          CH3_TDATA_WIDTH_TYPE == "8b10b_32bit" ? "TRUE" :
                                          CH3_TDATA_WIDTH_TYPE == "64b66b_32bit"? "TRUE" :
                                          CH3_TDATA_WIDTH_TYPE == "64b67b_32bit"? "TRUE" : "FALSE";

    localparam PCS_CH0_TX_OUTZZ = "FALSE";
    localparam PCS_CH1_TX_OUTZZ = "FALSE";
    localparam PCS_CH2_TX_OUTZZ = "FALSE";
    localparam PCS_CH3_TX_OUTZZ = "FALSE";

    localparam PCS_CH0_DATA_WIDTH_MODE      = CH0_TDATA_WIDTH_TYPE == "8bit_only"   ? "X8"  :
                                      CH0_TDATA_WIDTH_TYPE == "10bit_only"  ? "X10" :
                                      CH0_TDATA_WIDTH_TYPE == "8b10b_8bit"  ? "X10" :
                                      CH0_TDATA_WIDTH_TYPE == "16bit_only"  ? "X16" :
                                      CH0_TDATA_WIDTH_TYPE == "20bit_only"  ? "X20" :
                                      CH0_TDATA_WIDTH_TYPE == "8b10b_16bit" ? "X20" :
                                      CH0_TDATA_WIDTH_TYPE == "32bit_only"  ? "X16" :
                                      CH0_TDATA_WIDTH_TYPE == "64b66b_16bit"? "X16" :
                                      CH0_TDATA_WIDTH_TYPE == "64b66b_32bit"? "X16" :
                                      CH0_TDATA_WIDTH_TYPE == "64b67b_16bit"? "X16" :
                                      CH0_TDATA_WIDTH_TYPE == "64b67b_32bit"? "X16" : "X20";
    localparam PCS_CH1_DATA_WIDTH_MODE 	= CH1_TDATA_WIDTH_TYPE == "8bit_only"   ? "X8"  :
                                      CH1_TDATA_WIDTH_TYPE == "10bit_only"  ? "X10" :
                                      CH1_TDATA_WIDTH_TYPE == "8b10b_8bit"  ? "X10" :
                                      CH1_TDATA_WIDTH_TYPE == "16bit_only"  ? "X16" :
                                      CH1_TDATA_WIDTH_TYPE == "20bit_only"  ? "X20" :
                                      CH1_TDATA_WIDTH_TYPE == "8b10b_16bit" ? "X20" :
                                      CH1_TDATA_WIDTH_TYPE == "32bit_only"  ? "X16" :
                                      CH1_TDATA_WIDTH_TYPE == "64b66b_16bit"? "X16" :
                                      CH1_TDATA_WIDTH_TYPE == "64b66b_32bit"? "X16" :
                                      CH1_TDATA_WIDTH_TYPE == "64b67b_16bit"? "X16" :
                                      CH1_TDATA_WIDTH_TYPE == "64b67b_32bit"? "X16" : "X20";
    localparam PCS_CH2_DATA_WIDTH_MODE 	= CH2_TDATA_WIDTH_TYPE == "8bit_only"   ? "X8"  :
                                      CH2_TDATA_WIDTH_TYPE == "10bit_only"  ? "X10" :
                                      CH2_TDATA_WIDTH_TYPE == "8b10b_8bit"  ? "X10" :
                                      CH2_TDATA_WIDTH_TYPE == "16bit_only"  ? "X16" :
                                      CH2_TDATA_WIDTH_TYPE == "20bit_only"  ? "X20" :
                                      CH2_TDATA_WIDTH_TYPE == "8b10b_16bit" ? "X20" :
                                      CH2_TDATA_WIDTH_TYPE == "32bit_only"  ? "X16" :
                                      CH2_TDATA_WIDTH_TYPE == "64b66b_16bit"? "X16" :
                                      CH2_TDATA_WIDTH_TYPE == "64b66b_32bit"? "X16" :
                                      CH2_TDATA_WIDTH_TYPE == "64b67b_16bit"? "X16" :
                                      CH2_TDATA_WIDTH_TYPE == "64b67b_32bit"? "X16" : "X20";
    localparam PCS_CH3_DATA_WIDTH_MODE 	= CH3_TDATA_WIDTH_TYPE == "8bit_only"   ? "X8"  :
                                      CH3_TDATA_WIDTH_TYPE == "10bit_only"  ? "X10" :
                                      CH3_TDATA_WIDTH_TYPE == "8b10b_8bit"  ? "X10" :
                                      CH3_TDATA_WIDTH_TYPE == "16bit_only"  ? "X16" :
                                      CH3_TDATA_WIDTH_TYPE == "20bit_only"  ? "X20" :
                                      CH3_TDATA_WIDTH_TYPE == "8b10b_16bit" ? "X20" :
                                      CH3_TDATA_WIDTH_TYPE == "32bit_only"  ? "X16" :
                                      CH3_TDATA_WIDTH_TYPE == "64b66b_16bit"? "X16" :
                                      CH3_TDATA_WIDTH_TYPE == "64b66b_32bit"? "X16" :
                                      CH3_TDATA_WIDTH_TYPE == "64b67b_16bit"? "X16" :
                                      CH3_TDATA_WIDTH_TYPE == "64b67b_32bit"? "X16" : "X20";

    localparam PCS_CH0_ENC_DUAL = CH0_TDATA_WIDTH_TYPE == "8b10b_8bit" ? "FALSE" : "TRUE";
    localparam PCS_CH1_ENC_DUAL = CH1_TDATA_WIDTH_TYPE == "8b10b_8bit" ? "FALSE" : "TRUE";
    localparam PCS_CH2_ENC_DUAL = CH2_TDATA_WIDTH_TYPE == "8b10b_8bit" ? "FALSE" : "TRUE";
    localparam PCS_CH3_ENC_DUAL = CH3_TDATA_WIDTH_TYPE == "8b10b_8bit" ? "FALSE" : "TRUE";

    localparam PCS_CH0_TX_GEAR_SPLIT =CH0_TDATA_WIDTH_TYPE == "32bit_only"  ? "TRUE" :
                                  CH0_TDATA_WIDTH_TYPE == "40bit_only"  ? "TRUE" :
                                  CH0_TDATA_WIDTH_TYPE == "8b10b_32bit" ? "TRUE" :
                                  CH0_TDATA_WIDTH_TYPE == "64b66b_32bit"? "TRUE" :
                                  CH0_TDATA_WIDTH_TYPE == "64b67b_32bit"? "TRUE" : "FALSE";
    localparam PCS_CH1_TX_GEAR_SPLIT =CH1_TDATA_WIDTH_TYPE == "32bit_only"  ? "TRUE" :
                                  CH1_TDATA_WIDTH_TYPE == "40bit_only"  ? "TRUE" :
                                  CH1_TDATA_WIDTH_TYPE == "8b10b_32bit" ? "TRUE" :
                                  CH1_TDATA_WIDTH_TYPE == "64b66b_32bit"? "TRUE" :
                                  CH1_TDATA_WIDTH_TYPE == "64b67b_32bit"? "TRUE" : "FALSE";
    localparam PCS_CH2_TX_GEAR_SPLIT =CH2_TDATA_WIDTH_TYPE == "32bit_only"  ? "TRUE" :
                                  CH2_TDATA_WIDTH_TYPE == "40bit_only"  ? "TRUE" :
                                  CH2_TDATA_WIDTH_TYPE == "8b10b_32bit" ? "TRUE" :
                                  CH2_TDATA_WIDTH_TYPE == "64b66b_32bit"? "TRUE" :
                                  CH2_TDATA_WIDTH_TYPE == "64b67b_32bit"? "TRUE" : "FALSE";
    localparam PCS_CH3_TX_GEAR_SPLIT =CH3_TDATA_WIDTH_TYPE == "32bit_only"  ? "TRUE" :
                                  CH3_TDATA_WIDTH_TYPE == "40bit_only"  ? "TRUE" :
                                  CH3_TDATA_WIDTH_TYPE == "8b10b_32bit" ? "TRUE" :
                                  CH3_TDATA_WIDTH_TYPE == "64b66b_32bit"? "TRUE" :
                                  CH3_TDATA_WIDTH_TYPE == "64b67b_32bit"? "TRUE" : "FALSE";
    localparam PMA_CH0_TXDATA_WIDTH  = CH0_TDATA_WIDTH_TYPE == "8bit_only"   ? "8BIT"  :
                                  CH0_TDATA_WIDTH_TYPE == "10bit_only"  ? "10BIT" :
                                  CH0_TDATA_WIDTH_TYPE == "8b10b_8bit"  ? "10BIT" :
                                  CH0_TDATA_WIDTH_TYPE == "16bit_only"  ? "16BIT" :
                                  CH0_TDATA_WIDTH_TYPE == "20bit_only"  ? "20BIT" :
                                  CH0_TDATA_WIDTH_TYPE == "8b10b_16bit" ? "20BIT" :
                                  CH0_TDATA_WIDTH_TYPE == "32bit_only"  ? "16BIT" :
                                  CH0_TDATA_WIDTH_TYPE == "64b66b_16bit"? "16BIT" :
                                  CH0_TDATA_WIDTH_TYPE == "64b66b_32bit"? "16BIT" :
                                  CH0_TDATA_WIDTH_TYPE == "64b67b_16bit"? "16BIT" :
                                  CH0_TDATA_WIDTH_TYPE == "64b67b_32bit"? "16BIT" : "20BIT";
    localparam PMA_CH1_TXDATA_WIDTH  =CH1_TDATA_WIDTH_TYPE == "8bit_only"   ? "8BIT"  :
                                  CH1_TDATA_WIDTH_TYPE == "10bit_only"  ? "10BIT" :
                                  CH1_TDATA_WIDTH_TYPE == "8b10b_8bit"  ? "10BIT" :
                                  CH1_TDATA_WIDTH_TYPE == "16bit_only"  ? "16BIT" :
                                  CH1_TDATA_WIDTH_TYPE == "20bit_only"  ? "20BIT" :
                                  CH1_TDATA_WIDTH_TYPE == "8b10b_16bit" ? "20BIT" :
                                  CH1_TDATA_WIDTH_TYPE == "32bit_only"  ? "16BIT" :
                                  CH1_TDATA_WIDTH_TYPE == "64b66b_16bit"? "16BIT" :
                                  CH1_TDATA_WIDTH_TYPE == "64b66b_32bit"? "16BIT" :
                                  CH1_TDATA_WIDTH_TYPE == "64b67b_16bit"? "16BIT" :
                                  CH1_TDATA_WIDTH_TYPE == "64b67b_32bit"? "16BIT" : "20BIT";
    localparam PMA_CH2_TXDATA_WIDTH  =CH2_TDATA_WIDTH_TYPE == "8bit_only"   ? "8BIT"  :
                                  CH2_TDATA_WIDTH_TYPE == "10bit_only"  ? "10BIT" :
                                  CH2_TDATA_WIDTH_TYPE == "8b10b_8bit"  ? "10BIT" :
                                  CH2_TDATA_WIDTH_TYPE == "16bit_only"  ? "16BIT" :
                                  CH2_TDATA_WIDTH_TYPE == "20bit_only"  ? "20BIT" :
                                  CH2_TDATA_WIDTH_TYPE == "8b10b_16bit" ? "20BIT" :
                                  CH2_TDATA_WIDTH_TYPE == "32bit_only"  ? "16BIT" :
                                  CH2_TDATA_WIDTH_TYPE == "64b66b_16bit"? "16BIT" :
                                  CH2_TDATA_WIDTH_TYPE == "64b66b_32bit"? "16BIT" :
                                  CH2_TDATA_WIDTH_TYPE == "64b67b_16bit"? "16BIT" :
                                  CH2_TDATA_WIDTH_TYPE == "64b67b_32bit"? "16BIT" : "20BIT";
    localparam PMA_CH3_TXDATA_WIDTH  =CH3_TDATA_WIDTH_TYPE == "8bit_only"   ? "8BIT"  :
                                  CH3_TDATA_WIDTH_TYPE == "10bit_only"  ? "10BIT" :
                                  CH3_TDATA_WIDTH_TYPE == "8b10b_8bit"  ? "10BIT" :
                                  CH3_TDATA_WIDTH_TYPE == "16bit_only"  ? "16BIT" :
                                  CH3_TDATA_WIDTH_TYPE == "20bit_only"  ? "20BIT" :
                                  CH3_TDATA_WIDTH_TYPE == "8b10b_16bit" ? "20BIT" :
                                  CH3_TDATA_WIDTH_TYPE == "32bit_only"  ? "16BIT" :
                                  CH3_TDATA_WIDTH_TYPE == "64b66b_16bit"? "16BIT" :
                                  CH3_TDATA_WIDTH_TYPE == "64b66b_32bit"? "16BIT" :
                                  CH3_TDATA_WIDTH_TYPE == "64b67b_16bit"? "16BIT" :
                                  CH3_TDATA_WIDTH_TYPE == "64b67b_32bit"? "16BIT" : "20BIT";

    localparam PMA_CH0_REG_TX_PRBS_GEN_WIDTH_SEL = PMA_CH0_TXDATA_WIDTH;
    localparam PMA_CH1_REG_TX_PRBS_GEN_WIDTH_SEL = PMA_CH1_TXDATA_WIDTH;
    localparam PMA_CH2_REG_TX_PRBS_GEN_WIDTH_SEL = PMA_CH2_TXDATA_WIDTH;
    localparam PMA_CH3_REG_TX_PRBS_GEN_WIDTH_SEL = PMA_CH3_TXDATA_WIDTH;

    localparam PCS_CH0_TX_64B66B_67B = CH0_TX_ENCODER == "64B66B_transparent" ? "64B_66B"  :
                                   CH0_TX_ENCODER == "64B67B_transparent" ? "64B_67B"  : "NORMAL";
    localparam PCS_CH1_TX_64B66B_67B = CH1_TX_ENCODER == "64B66B_transparent" ? "64B_66B"  :
                                   CH1_TX_ENCODER == "64B67B_transparent" ? "64B_67B"  : "NORMAL";
    localparam PCS_CH2_TX_64B66B_67B = CH2_TX_ENCODER == "64B66B_transparent" ? "64B_66B"  :
                                   CH2_TX_ENCODER == "64B67B_transparent" ? "64B_67B"  : "NORMAL";
    localparam PCS_CH3_TX_64B66B_67B = CH3_TX_ENCODER == "64B66B_transparent" ? "64B_66B"  :
                                   CH3_TX_ENCODER == "64B67B_transparent" ? "64B_67B"  : "NORMAL";
    //---------------------------------------------------
    localparam PCS_CH0_BYPASS_DENC  = CH0_RDATA_WIDTH_TYPE == "8b10b_8bit"   ? "FALSE" :
                                 CH0_RDATA_WIDTH_TYPE == "8b10b_16bit"  ? "FALSE" :
                                 CH0_RDATA_WIDTH_TYPE == "8b10b_32bit"  ? "FALSE" : "TRUE";
    localparam PCS_CH1_BYPASS_DENC  = CH1_RDATA_WIDTH_TYPE == "8b10b_8bit"   ? "FALSE" :
                                 CH1_RDATA_WIDTH_TYPE == "8b10b_16bit"  ? "FALSE" :
                                 CH1_RDATA_WIDTH_TYPE == "8b10b_32bit"  ? "FALSE" : "TRUE";
    localparam PCS_CH2_BYPASS_DENC  = CH2_RDATA_WIDTH_TYPE == "8b10b_8bit"   ? "FALSE" :
                                 CH2_RDATA_WIDTH_TYPE == "8b10b_16bit"  ? "FALSE" :
                                 CH2_RDATA_WIDTH_TYPE == "8b10b_32bit"  ? "FALSE" : "TRUE";
    localparam PCS_CH3_BYPASS_DENC  = CH3_RDATA_WIDTH_TYPE == "8b10b_8bit"   ? "FALSE" :
                                 CH3_RDATA_WIDTH_TYPE == "8b10b_16bit"  ? "FALSE" :
                                 CH3_RDATA_WIDTH_TYPE == "8b10b_32bit"  ? "FALSE" : "TRUE";

    localparam PCS_CH0_SAMP_16B     =  CH0_RDATA_WIDTH_TYPE == "8bit_only"   ? "X16" :
                                  CH0_RDATA_WIDTH_TYPE == "16bit_only"  ? "X16" :
                                  CH0_RDATA_WIDTH_TYPE == "32bit_only"  ? "X16" :
                                  CH0_RDATA_WIDTH_TYPE == "64b66b_16bit"? "X16" :
                                  CH0_RDATA_WIDTH_TYPE == "64b66b_32bit"? "X16" :
                                  CH0_RDATA_WIDTH_TYPE == "64b67b_16bit"? "X16" :
                                  CH0_RDATA_WIDTH_TYPE == "64b67b_32bit"? "X16" : "X20";
    localparam PCS_CH1_SAMP_16B     =  CH1_RDATA_WIDTH_TYPE == "8bit_only"   ? "X16" :
                                  CH1_RDATA_WIDTH_TYPE == "16bit_only"  ? "X16" :
                                  CH1_RDATA_WIDTH_TYPE == "32bit_only"  ? "X16" :
                                  CH1_RDATA_WIDTH_TYPE == "64b66b_16bit"? "X16" :
                                  CH1_RDATA_WIDTH_TYPE == "64b66b_32bit"? "X16" :
                                  CH1_RDATA_WIDTH_TYPE == "64b67b_16bit"? "X16" :
                                  CH1_RDATA_WIDTH_TYPE == "64b67b_32bit"? "X16" : "X20";
    localparam PCS_CH2_SAMP_16B     =  CH2_RDATA_WIDTH_TYPE == "8bit_only"   ? "X16" :
                                  CH2_RDATA_WIDTH_TYPE == "16bit_only"  ? "X16" :
                                  CH2_RDATA_WIDTH_TYPE == "32bit_only"  ? "X16" :
                                  CH2_RDATA_WIDTH_TYPE == "64b66b_16bit"? "X16" :
                                  CH2_RDATA_WIDTH_TYPE == "64b66b_32bit"? "X16" :
                                  CH2_RDATA_WIDTH_TYPE == "64b67b_16bit"? "X16" :
                                  CH2_RDATA_WIDTH_TYPE == "64b67b_32bit"? "X16" : "X20";
    localparam PCS_CH3_SAMP_16B     =  CH3_RDATA_WIDTH_TYPE == "8bit_only"   ? "X16" :
                                  CH3_RDATA_WIDTH_TYPE == "16bit_only"  ? "X16" :
                                  CH3_RDATA_WIDTH_TYPE == "32bit_only"  ? "X16" :
                                  CH3_RDATA_WIDTH_TYPE == "64b66b_16bit"? "X16" :
                                  CH3_RDATA_WIDTH_TYPE == "64b66b_32bit"? "X16" :
                                  CH3_RDATA_WIDTH_TYPE == "64b67b_16bit"? "X16" :
                                  CH3_RDATA_WIDTH_TYPE == "64b67b_32bit"? "X16" : "X20";

    localparam PCS_CH0_DATA_MODE    =  CH0_RDATA_WIDTH_TYPE == "8bit_only"   ? "X8"  :
                                  CH0_RDATA_WIDTH_TYPE == "10bit_only"  ? "X10" :
                                  CH0_RDATA_WIDTH_TYPE == "8b10b_8bit"  ? "X10" :
                                  CH0_RDATA_WIDTH_TYPE == "16bit_only"  ? "X16" :
                                  CH0_RDATA_WIDTH_TYPE == "20bit_only"  ? "X20" :
                                  CH0_RDATA_WIDTH_TYPE == "8b10b_16bit" ? "X20" :
                                  CH0_RDATA_WIDTH_TYPE == "32bit_only"  ? "X16" :
                                  CH0_RDATA_WIDTH_TYPE == "64b66b_16bit"? "X16" :
                                  CH0_RDATA_WIDTH_TYPE == "64b66b_32bit"? "X16" :
                                  CH0_RDATA_WIDTH_TYPE == "64b67b_16bit"? "X16" :
                                  CH0_RDATA_WIDTH_TYPE == "64b67b_32bit"? "X16" : "X20";
    localparam PCS_CH1_DATA_MODE    =  CH1_RDATA_WIDTH_TYPE == "8bit_only"   ? "X8"  :
                                  CH1_RDATA_WIDTH_TYPE == "10bit_only"  ? "X10" :
                                  CH1_RDATA_WIDTH_TYPE == "8b10b_8bit"  ? "X10" :
                                  CH1_RDATA_WIDTH_TYPE == "16bit_only"  ? "X16" :
                                  CH1_RDATA_WIDTH_TYPE == "20bit_only"  ? "X20" :
                                  CH1_RDATA_WIDTH_TYPE == "8b10b_16bit" ? "X20" :
                                  CH1_RDATA_WIDTH_TYPE == "32bit_only"  ? "X16" :
                                  CH1_RDATA_WIDTH_TYPE == "64b66b_16bit"? "X16" :
                                  CH1_RDATA_WIDTH_TYPE == "64b66b_32bit"? "X16" :
                                  CH1_RDATA_WIDTH_TYPE == "64b67b_16bit"? "X16" :
                                  CH1_RDATA_WIDTH_TYPE == "64b67b_32bit"? "X16" : "X20";
    localparam PCS_CH2_DATA_MODE    =  CH2_RDATA_WIDTH_TYPE == "8bit_only"   ? "X8"  :
                                  CH2_RDATA_WIDTH_TYPE == "10bit_only"  ? "X10" :
                                  CH2_RDATA_WIDTH_TYPE == "8b10b_8bit"  ? "X10" :
                                  CH2_RDATA_WIDTH_TYPE == "16bit_only"  ? "X16" :
                                  CH2_RDATA_WIDTH_TYPE == "20bit_only"  ? "X20" :
                                  CH2_RDATA_WIDTH_TYPE == "8b10b_16bit" ? "X20" :
                                  CH2_RDATA_WIDTH_TYPE == "32bit_only"  ? "X16" :
                                  CH2_RDATA_WIDTH_TYPE == "64b66b_16bit"? "X16" :
                                  CH2_RDATA_WIDTH_TYPE == "64b66b_32bit"? "X16" :
                                  CH2_RDATA_WIDTH_TYPE == "64b67b_16bit"? "X16" :
                                  CH2_RDATA_WIDTH_TYPE == "64b67b_32bit"? "X16" : "X20";
    localparam PCS_CH3_DATA_MODE    =  CH3_RDATA_WIDTH_TYPE == "8bit_only"   ? "X8"  :
                                  CH3_RDATA_WIDTH_TYPE == "10bit_only"  ? "X10" :
                                  CH3_RDATA_WIDTH_TYPE == "8b10b_8bit"  ? "X10" :
                                  CH3_RDATA_WIDTH_TYPE == "16bit_only"  ? "X16" :
                                  CH3_RDATA_WIDTH_TYPE == "20bit_only"  ? "X20" :
                                  CH3_RDATA_WIDTH_TYPE == "8b10b_16bit" ? "X20" :
                                  CH3_RDATA_WIDTH_TYPE == "32bit_only"  ? "X16" :
                                  CH3_RDATA_WIDTH_TYPE == "64b66b_16bit"? "X16" :
                                  CH3_RDATA_WIDTH_TYPE == "64b66b_32bit"? "X16" :
                                  CH3_RDATA_WIDTH_TYPE == "64b67b_16bit"? "X16" :
                                  CH3_RDATA_WIDTH_TYPE == "64b67b_32bit"? "X16" : "X20";

    localparam PCS_CH0_SPLIT        =  CH0_RDATA_WIDTH_TYPE == "8bit_only"   ? "TRUE" :
                                  CH0_RDATA_WIDTH_TYPE == "10bit_only"   ? "TRUE" :
                                  CH0_RDATA_WIDTH_TYPE == "8b10b_8bit"   ? "TRUE" :
                                  CH0_RDATA_WIDTH_TYPE == "64b66b_16bit" ? "TRUE" :
                                  CH0_RDATA_WIDTH_TYPE == "64b67b_16bit" ? "TRUE" : "FALSE";
    localparam PCS_CH1_SPLIT        =  CH1_RDATA_WIDTH_TYPE == "8bit_only"   ? "TRUE" :
                                  CH1_RDATA_WIDTH_TYPE == "10bit_only"   ? "TRUE" :
                                  CH1_RDATA_WIDTH_TYPE == "8b10b_8bit"   ? "TRUE" :
                                  CH1_RDATA_WIDTH_TYPE == "64b66b_16bit" ? "TRUE" :
                                  CH1_RDATA_WIDTH_TYPE == "64b67b_16bit" ? "TRUE" : "FALSE";
    localparam PCS_CH2_SPLIT        =  CH2_RDATA_WIDTH_TYPE == "8bit_only"   ? "TRUE" :
                                  CH2_RDATA_WIDTH_TYPE == "10bit_only"   ? "TRUE" :
                                  CH2_RDATA_WIDTH_TYPE == "8b10b_8bit"   ? "TRUE" :
                                  CH2_RDATA_WIDTH_TYPE == "64b66b_16bit" ? "TRUE" :
                                  CH2_RDATA_WIDTH_TYPE == "64b67b_16bit" ? "TRUE" : "FALSE";
    localparam PCS_CH3_SPLIT        =  CH3_RDATA_WIDTH_TYPE == "8bit_only"   ? "TRUE" :
                                  CH3_RDATA_WIDTH_TYPE == "10bit_only"   ? "TRUE" :
                                  CH3_RDATA_WIDTH_TYPE == "8b10b_8bit"   ? "TRUE" :
                                  CH3_RDATA_WIDTH_TYPE == "64b66b_16bit" ? "TRUE" :
                                  CH3_RDATA_WIDTH_TYPE == "64b67b_16bit" ? "TRUE" : "FALSE";

    localparam PCS_CH0_COMMA_DET_MODE = CH0_RX_CLK_SLIP_EN == "TRUE" ? "RX_CLK_SLIP" : "COMMA_PATTERN";
    localparam PCS_CH1_COMMA_DET_MODE = CH1_RX_CLK_SLIP_EN == "TRUE" ? "RX_CLK_SLIP" : "COMMA_PATTERN";
    localparam PCS_CH2_COMMA_DET_MODE = CH2_RX_CLK_SLIP_EN == "TRUE" ? "RX_CLK_SLIP" : "COMMA_PATTERN";
    localparam PCS_CH3_COMMA_DET_MODE = CH3_RX_CLK_SLIP_EN == "TRUE" ? "RX_CLK_SLIP" : "COMMA_PATTERN";

    localparam PCS_CH0_DEC_DUAL     =  CH0_RDATA_WIDTH_TYPE == "8b10b_8bit"   ? "TRUE" :
                                  CH0_RDATA_WIDTH_TYPE == "8b10b_16bit"  ? "TRUE" :
                                  CH0_RDATA_WIDTH_TYPE == "8b10b_32bit"  ? "TRUE" : "FALSE";
    localparam PCS_CH1_DEC_DUAL     =  CH1_RDATA_WIDTH_TYPE == "8b10b_8bit"   ? "TRUE" :
                                  CH1_RDATA_WIDTH_TYPE == "8b10b_16bit"  ? "TRUE" :
                                  CH1_RDATA_WIDTH_TYPE == "8b10b_32bit"  ? "TRUE" : "FALSE";
    localparam PCS_CH2_DEC_DUAL     =  CH2_RDATA_WIDTH_TYPE == "8b10b_8bit"   ? "TRUE" :
                                  CH2_RDATA_WIDTH_TYPE == "8b10b_16bit"  ? "TRUE" :
                                  CH2_RDATA_WIDTH_TYPE == "8b10b_32bit"  ? "TRUE" : "FALSE";
    localparam PCS_CH3_DEC_DUAL     =  CH3_RDATA_WIDTH_TYPE == "8b10b_8bit"   ? "TRUE" :
                                  CH3_RDATA_WIDTH_TYPE == "8b10b_16bit"  ? "TRUE" :
                                  CH3_RDATA_WIDTH_TYPE == "8b10b_32bit"  ? "TRUE" : "FALSE";

    localparam PCS_CH0_PCS_RCLK_EN = CH0_RDATA_WIDTH_TYPE == "8b10b_8bit" ? "TRUE" : "FALSE";
    localparam PCS_CH1_PCS_RCLK_EN = CH1_RDATA_WIDTH_TYPE == "8b10b_8bit" ? "TRUE" : "FALSE";
    localparam PCS_CH2_PCS_RCLK_EN = CH2_RDATA_WIDTH_TYPE == "8b10b_8bit" ? "TRUE" : "FALSE";
    localparam PCS_CH3_PCS_RCLK_EN = CH3_RDATA_WIDTH_TYPE == "8b10b_8bit" ? "TRUE" : "FALSE";

    localparam PCS_CH0_CB_RCLK_EN = CH0_RDATA_WIDTH_TYPE == "8b10b_8bit" ? "TRUE" : "FALSE";
    localparam PCS_CH1_CB_RCLK_EN = CH1_RDATA_WIDTH_TYPE == "8b10b_8bit" ? "TRUE" : "FALSE";
    localparam PCS_CH2_CB_RCLK_EN = CH2_RDATA_WIDTH_TYPE == "8b10b_8bit" ? "TRUE" : "FALSE";
    localparam PCS_CH3_CB_RCLK_EN = CH3_RDATA_WIDTH_TYPE == "8b10b_8bit" ? "TRUE" : "FALSE";

    localparam PCS_CH0_AFTER_CTC_RCLK_EN = CH0_RDATA_WIDTH_TYPE == "8b10b_8bit" ? "TRUE" : "FALSE";
    localparam PCS_CH1_AFTER_CTC_RCLK_EN = CH1_RDATA_WIDTH_TYPE == "8b10b_8bit" ? "TRUE" : "FALSE";
    localparam PCS_CH2_AFTER_CTC_RCLK_EN = CH2_RDATA_WIDTH_TYPE == "8b10b_8bit" ? "TRUE" : "FALSE";
    localparam PCS_CH3_AFTER_CTC_RCLK_EN = CH3_RDATA_WIDTH_TYPE == "8b10b_8bit" ? "TRUE" : "FALSE";

    localparam PCS_CH0_AFTER_CTC_RCLK_EN_GB   =  CH0_RDATA_WIDTH_TYPE == "32bit_only"  ? "TRUE" :
                                            CH0_RDATA_WIDTH_TYPE == "40bit_only"  ? "TRUE" :
                                            CH0_RDATA_WIDTH_TYPE == "8b10b_32bit" ? "TRUE" :
                                            CH0_RDATA_WIDTH_TYPE == "64b66b_32bit"? "TRUE" :
                                            CH0_RDATA_WIDTH_TYPE == "64b67b_32bit"? "TRUE" : "FALSE";
    localparam PCS_CH1_AFTER_CTC_RCLK_EN_GB   =  CH1_RDATA_WIDTH_TYPE == "32bit_only"  ? "TRUE" :
                                            CH1_RDATA_WIDTH_TYPE == "40bit_only"  ? "TRUE" :
                                            CH1_RDATA_WIDTH_TYPE == "8b10b_32bit" ? "TRUE" :
                                            CH1_RDATA_WIDTH_TYPE == "64b66b_32bit"? "TRUE" :
                                            CH1_RDATA_WIDTH_TYPE == "64b67b_32bit"? "TRUE" : "FALSE";
    localparam PCS_CH2_AFTER_CTC_RCLK_EN_GB   =  CH2_RDATA_WIDTH_TYPE == "32bit_only"  ? "TRUE" :
                                            CH2_RDATA_WIDTH_TYPE == "40bit_only"  ? "TRUE" :
                                            CH2_RDATA_WIDTH_TYPE == "8b10b_32bit" ? "TRUE" :
                                            CH2_RDATA_WIDTH_TYPE == "64b66b_32bit"? "TRUE" :
                                            CH2_RDATA_WIDTH_TYPE == "64b67b_32bit"? "TRUE" : "FALSE";
    localparam PCS_CH3_AFTER_CTC_RCLK_EN_GB   =  CH3_RDATA_WIDTH_TYPE == "32bit_only"  ? "TRUE" :
                                            CH3_RDATA_WIDTH_TYPE == "40bit_only"  ? "TRUE" :
                                            CH3_RDATA_WIDTH_TYPE == "8b10b_32bit" ? "TRUE" :
                                            CH3_RDATA_WIDTH_TYPE == "64b66b_32bit"? "TRUE" :
                                            CH3_RDATA_WIDTH_TYPE == "64b67b_32bit"? "TRUE" : "FALSE";

    localparam PMA_CH0_SIPO_BIT_SETTING  = CH0_RDATA_WIDTH_TYPE == "8bit_only"   ? "8BIT"  :
                                      CH0_RDATA_WIDTH_TYPE == "10bit_only"  ? "10BIT" :
                                      CH0_RDATA_WIDTH_TYPE == "8b10b_8bit"  ? "10BIT" :
                                      CH0_RDATA_WIDTH_TYPE == "16bit_only"  ? "16BIT" :
                                      CH0_RDATA_WIDTH_TYPE == "20bit_only"  ? "20BIT" :
                                      CH0_RDATA_WIDTH_TYPE == "8b10b_16bit" ? "20BIT" :
                                      CH0_RDATA_WIDTH_TYPE == "32bit_only"  ? "16BIT" :
                                      CH0_RDATA_WIDTH_TYPE == "64b66b_16bit"? "16BIT" :
                                      CH0_RDATA_WIDTH_TYPE == "64b66b_32bit"? "16BIT" :
                                      CH0_RDATA_WIDTH_TYPE == "64b67b_16bit"? "16BIT" :
                                      CH0_RDATA_WIDTH_TYPE == "64b67b_32bit"? "16BIT" : "20BIT";
    localparam PMA_CH1_SIPO_BIT_SETTING  = CH1_RDATA_WIDTH_TYPE == "8bit_only"   ? "8BIT"  :
                                      CH1_RDATA_WIDTH_TYPE == "10bit_only"  ? "10BIT" :
                                      CH1_RDATA_WIDTH_TYPE == "8b10b_8bit"  ? "10BIT" :
                                      CH1_RDATA_WIDTH_TYPE == "16bit_only"  ? "16BIT" :
                                      CH1_RDATA_WIDTH_TYPE == "20bit_only"  ? "20BIT" :
                                      CH1_RDATA_WIDTH_TYPE == "8b10b_16bit" ? "20BIT" :
                                      CH1_RDATA_WIDTH_TYPE == "32bit_only"  ? "16BIT" :
                                      CH1_RDATA_WIDTH_TYPE == "64b66b_16bit"? "16BIT" :
                                      CH1_RDATA_WIDTH_TYPE == "64b66b_32bit"? "16BIT" :
                                      CH1_RDATA_WIDTH_TYPE == "64b67b_16bit"? "16BIT" :
                                      CH1_RDATA_WIDTH_TYPE == "64b67b_32bit"? "16BIT" : "20BIT";
    localparam PMA_CH2_SIPO_BIT_SETTING  = CH2_RDATA_WIDTH_TYPE == "8bit_only"   ? "8BIT"  :
                                      CH2_RDATA_WIDTH_TYPE == "10bit_only"  ? "10BIT" :
                                      CH2_RDATA_WIDTH_TYPE == "8b10b_8bit"  ? "10BIT" :
                                      CH2_RDATA_WIDTH_TYPE == "16bit_only"  ? "16BIT" :
                                      CH2_RDATA_WIDTH_TYPE == "20bit_only"  ? "20BIT" :
                                      CH2_RDATA_WIDTH_TYPE == "8b10b_16bit" ? "20BIT" :
                                      CH2_RDATA_WIDTH_TYPE == "32bit_only"  ? "16BIT" :
                                      CH2_RDATA_WIDTH_TYPE == "64b66b_16bit"? "16BIT" :
                                      CH2_RDATA_WIDTH_TYPE == "64b66b_32bit"? "16BIT" :
                                      CH2_RDATA_WIDTH_TYPE == "64b67b_16bit"? "16BIT" :
                                      CH2_RDATA_WIDTH_TYPE == "64b67b_32bit"? "16BIT" : "20BIT";
    localparam PMA_CH3_SIPO_BIT_SETTING  = CH3_RDATA_WIDTH_TYPE == "8bit_only"   ? "8BIT"  :
                                      CH3_RDATA_WIDTH_TYPE == "10bit_only"  ? "10BIT" :
                                      CH3_RDATA_WIDTH_TYPE == "8b10b_8bit"  ? "10BIT" :
                                      CH3_RDATA_WIDTH_TYPE == "16bit_only"  ? "16BIT" :
                                      CH3_RDATA_WIDTH_TYPE == "20bit_only"  ? "20BIT" :
                                      CH3_RDATA_WIDTH_TYPE == "8b10b_16bit" ? "20BIT" :
                                      CH3_RDATA_WIDTH_TYPE == "32bit_only"  ? "16BIT" :
                                      CH3_RDATA_WIDTH_TYPE == "64b66b_16bit"? "16BIT" :
                                      CH3_RDATA_WIDTH_TYPE == "64b66b_32bit"? "16BIT" :
                                      CH3_RDATA_WIDTH_TYPE == "64b67b_16bit"? "16BIT" :
                                      CH3_RDATA_WIDTH_TYPE == "64b67b_32bit"? "16BIT" : "20BIT";

    localparam PMA_CH0_REG_PRBS_CHK_WIDTH_SEL = PMA_CH0_SIPO_BIT_SETTING;
    localparam PMA_CH1_REG_PRBS_CHK_WIDTH_SEL = PMA_CH1_SIPO_BIT_SETTING;
    localparam PMA_CH2_REG_PRBS_CHK_WIDTH_SEL = PMA_CH2_SIPO_BIT_SETTING;
    localparam PMA_CH3_REG_PRBS_CHK_WIDTH_SEL = PMA_CH3_SIPO_BIT_SETTING;

    localparam PMA_CH0_REG_RX_DATAPATH_PD_EN = "TRUE";
    localparam PMA_CH1_REG_RX_DATAPATH_PD_EN = "TRUE";
    localparam PMA_CH2_REG_RX_DATAPATH_PD_EN = "TRUE";
    localparam PMA_CH3_REG_RX_DATAPATH_PD_EN = "TRUE";
    localparam PMA_CH0_REG_RX_SIGDET_VTH = "72MV";
    localparam PMA_CH1_REG_RX_SIGDET_VTH = "72MV";
    localparam PMA_CH2_REG_RX_SIGDET_VTH = "72MV";
    localparam PMA_CH3_REG_RX_SIGDET_VTH = "72MV";

    localparam PMA_CH0_REG_TX_SATA_EN = "FALSE";
    localparam PMA_CH1_REG_TX_SATA_EN = "FALSE";
    localparam PMA_CH2_REG_TX_SATA_EN = "FALSE";
    localparam PMA_CH3_REG_TX_SATA_EN = "FALSE";
    // SATA 带外信号配置
    localparam   integer PMA_CH0_REG_OOB_COMWAKE_GAP_MIN = (((CH0_RX_RATE == 6.0) && (PMA_CH0_SIPO_BIT_SETTING == "20BIT")) || ((CH0_RX_RATE == 3.0) && (PMA_CH0_SIPO_BIT_SETTING == "10BIT" ))) ? 29 :
                                                       (((CH0_RX_RATE == 3.0) && (PMA_CH0_SIPO_BIT_SETTING == "20BIT")) || ((CH0_RX_RATE == 1.5) && (PMA_CH0_SIPO_BIT_SETTING == "10BIT" ))) ? 12 :
                                                        ((CH0_RX_RATE == 1.5) && (PMA_CH0_SIPO_BIT_SETTING == "20BIT")) ? 6 : 3;
    localparam   integer PMA_CH1_REG_OOB_COMWAKE_GAP_MIN = (((CH1_RX_RATE == 6.0) && (PMA_CH1_SIPO_BIT_SETTING == "20BIT")) || ((CH1_RX_RATE == 3.0) && (PMA_CH1_SIPO_BIT_SETTING == "10BIT" ))) ? 29 :
                                                       (((CH1_RX_RATE == 3.0) && (PMA_CH1_SIPO_BIT_SETTING == "20BIT")) || ((CH1_RX_RATE == 1.5) && (PMA_CH1_SIPO_BIT_SETTING == "10BIT" ))) ? 12 :
                                                        ((CH1_RX_RATE == 1.5) && (PMA_CH1_SIPO_BIT_SETTING == "20BIT")) ? 6 : 3;
    localparam   integer PMA_CH2_REG_OOB_COMWAKE_GAP_MIN = (((CH2_RX_RATE == 6.0) && (PMA_CH2_SIPO_BIT_SETTING == "20BIT")) || ((CH2_RX_RATE == 3.0) && (PMA_CH2_SIPO_BIT_SETTING == "10BIT" ))) ? 29 :
                                                       (((CH2_RX_RATE == 3.0) && (PMA_CH2_SIPO_BIT_SETTING == "20BIT")) || ((CH2_RX_RATE == 1.5) && (PMA_CH2_SIPO_BIT_SETTING == "10BIT" ))) ? 12 :
                                                        ((CH2_RX_RATE == 1.5) && (PMA_CH2_SIPO_BIT_SETTING == "20BIT")) ? 6 : 3;
    localparam   integer PMA_CH3_REG_OOB_COMWAKE_GAP_MIN = (((CH3_RX_RATE == 6.0) && (PMA_CH3_SIPO_BIT_SETTING == "20BIT")) || ((CH3_RX_RATE == 3.0) && (PMA_CH3_SIPO_BIT_SETTING == "10BIT" ))) ? 29 :
                                                       (((CH3_RX_RATE == 3.0) && (PMA_CH3_SIPO_BIT_SETTING == "20BIT")) || ((CH3_RX_RATE == 1.5) && (PMA_CH3_SIPO_BIT_SETTING == "10BIT" ))) ? 12 :
                                                        ((CH3_RX_RATE == 1.5) && (PMA_CH3_SIPO_BIT_SETTING == "20BIT")) ? 6 : 3;

    localparam   integer PMA_CH0_REG_OOB_COMWAKE_GAP_MAX = (((CH0_RX_RATE == 6.0) && (PMA_CH0_SIPO_BIT_SETTING == "20BIT")) || ((CH0_RX_RATE == 3.0) && (PMA_CH0_SIPO_BIT_SETTING == "10BIT" ))) ? 35 :
                                                       (((CH0_RX_RATE == 3.0) && (PMA_CH0_SIPO_BIT_SETTING == "20BIT")) || ((CH0_RX_RATE == 1.5) && (PMA_CH0_SIPO_BIT_SETTING == "10BIT" ))) ? 19 :
                                                        ((CH0_RX_RATE == 1.5) && (PMA_CH0_SIPO_BIT_SETTING == "20BIT")) ? 9 : 11;
    localparam   integer PMA_CH1_REG_OOB_COMWAKE_GAP_MAX = (((CH1_RX_RATE == 6.0) && (PMA_CH1_SIPO_BIT_SETTING == "20BIT")) || ((CH1_RX_RATE == 3.0) && (PMA_CH1_SIPO_BIT_SETTING == "10BIT" ))) ? 35 :
                                                       (((CH1_RX_RATE == 3.0) && (PMA_CH1_SIPO_BIT_SETTING == "20BIT")) || ((CH1_RX_RATE == 1.5) && (PMA_CH1_SIPO_BIT_SETTING == "10BIT" ))) ? 19 :
                                                        ((CH1_RX_RATE == 1.5) && (PMA_CH1_SIPO_BIT_SETTING == "20BIT")) ? 9 : 11;
    localparam   integer PMA_CH2_REG_OOB_COMWAKE_GAP_MAX = (((CH2_RX_RATE == 6.0) && (PMA_CH2_SIPO_BIT_SETTING == "20BIT")) || ((CH2_RX_RATE == 3.0) && (PMA_CH2_SIPO_BIT_SETTING == "10BIT" ))) ? 35 :
                                                       (((CH2_RX_RATE == 3.0) && (PMA_CH2_SIPO_BIT_SETTING == "20BIT")) || ((CH2_RX_RATE == 1.5) && (PMA_CH2_SIPO_BIT_SETTING == "10BIT" ))) ? 19 :
                                                        ((CH2_RX_RATE == 1.5) && (PMA_CH2_SIPO_BIT_SETTING == "20BIT")) ? 9 : 11;
    localparam   integer PMA_CH3_REG_OOB_COMWAKE_GAP_MAX = (((CH3_RX_RATE == 6.0) && (PMA_CH3_SIPO_BIT_SETTING == "20BIT")) || ((CH3_RX_RATE == 3.0) && (PMA_CH3_SIPO_BIT_SETTING == "10BIT" ))) ? 35 :
                                                       (((CH3_RX_RATE == 3.0) && (PMA_CH3_SIPO_BIT_SETTING == "20BIT")) || ((CH3_RX_RATE == 1.5) && (PMA_CH3_SIPO_BIT_SETTING == "10BIT" ))) ? 19 :
                                                        ((CH3_RX_RATE == 1.5) && (PMA_CH3_SIPO_BIT_SETTING == "20BIT")) ? 9 : 11;

    localparam   integer PMA_CH0_REG_OOB_COMINIT_GAP_MIN = (((CH0_RX_RATE == 6.0) && (PMA_CH0_SIPO_BIT_SETTING == "20BIT")) || ((CH0_RX_RATE == 3.0) && (PMA_CH0_SIPO_BIT_SETTING == "10BIT" ))) ? 90 :
                                                       (((CH0_RX_RATE == 3.0) && (PMA_CH0_SIPO_BIT_SETTING == "20BIT")) || ((CH0_RX_RATE == 1.5) && (PMA_CH0_SIPO_BIT_SETTING == "10BIT" ))) ? 44 :
                                                        ((CH0_RX_RATE == 1.5) && (PMA_CH0_SIPO_BIT_SETTING == "20BIT")) ? 22 : 15;
    localparam   integer PMA_CH1_REG_OOB_COMINIT_GAP_MIN = (((CH1_RX_RATE == 6.0) && (PMA_CH1_SIPO_BIT_SETTING == "20BIT")) || ((CH1_RX_RATE == 3.0) && (PMA_CH1_SIPO_BIT_SETTING == "10BIT" ))) ? 90 :
                                                       (((CH1_RX_RATE == 3.0) && (PMA_CH1_SIPO_BIT_SETTING == "20BIT")) || ((CH1_RX_RATE == 1.5) && (PMA_CH1_SIPO_BIT_SETTING == "10BIT" ))) ? 44 :
                                                        ((CH1_RX_RATE == 1.5) && (PMA_CH1_SIPO_BIT_SETTING == "20BIT")) ? 22 : 15;
    localparam   integer PMA_CH2_REG_OOB_COMINIT_GAP_MIN = (((CH2_RX_RATE == 6.0) && (PMA_CH2_SIPO_BIT_SETTING == "20BIT")) || ((CH2_RX_RATE == 3.0) && (PMA_CH2_SIPO_BIT_SETTING == "10BIT" ))) ? 90 :
                                                       (((CH2_RX_RATE == 3.0) && (PMA_CH2_SIPO_BIT_SETTING == "20BIT")) || ((CH2_RX_RATE == 1.5) && (PMA_CH2_SIPO_BIT_SETTING == "10BIT" ))) ? 44 :
                                                        ((CH2_RX_RATE == 1.5) && (PMA_CH2_SIPO_BIT_SETTING == "20BIT")) ? 22 : 15;
    localparam   integer PMA_CH3_REG_OOB_COMINIT_GAP_MIN = (((CH3_RX_RATE == 6.0) && (PMA_CH3_SIPO_BIT_SETTING == "20BIT")) || ((CH3_RX_RATE == 3.0) && (PMA_CH3_SIPO_BIT_SETTING == "10BIT" ))) ? 90 :
                                                       (((CH3_RX_RATE == 3.0) && (PMA_CH3_SIPO_BIT_SETTING == "20BIT")) || ((CH3_RX_RATE == 1.5) && (PMA_CH3_SIPO_BIT_SETTING == "10BIT" ))) ? 44 :
                                                        ((CH3_RX_RATE == 1.5) && (PMA_CH3_SIPO_BIT_SETTING == "20BIT")) ? 22 : 15;

    localparam   integer PMA_CH0_REG_OOB_COMINIT_GAP_MAX = (((CH0_RX_RATE == 6.0) && (PMA_CH0_SIPO_BIT_SETTING == "20BIT")) || ((CH0_RX_RATE == 3.0) && (PMA_CH0_SIPO_BIT_SETTING == "10BIT" ))) ? 102:
                                                       (((CH0_RX_RATE == 3.0) && (PMA_CH0_SIPO_BIT_SETTING == "20BIT")) || ((CH0_RX_RATE == 1.5) && (PMA_CH0_SIPO_BIT_SETTING == "10BIT" ))) ? 52 :
                                                        ((CH0_RX_RATE == 1.5) && (PMA_CH0_SIPO_BIT_SETTING == "20BIT")) ? 26 : 35;
    localparam   integer PMA_CH1_REG_OOB_COMINIT_GAP_MAX = (((CH1_RX_RATE == 6.0) && (PMA_CH1_SIPO_BIT_SETTING == "20BIT")) || ((CH1_RX_RATE == 3.0) && (PMA_CH1_SIPO_BIT_SETTING == "10BIT" ))) ? 102:
                                                       (((CH1_RX_RATE == 3.0) && (PMA_CH1_SIPO_BIT_SETTING == "20BIT")) || ((CH1_RX_RATE == 1.5) && (PMA_CH1_SIPO_BIT_SETTING == "10BIT" ))) ? 52 :
                                                        ((CH1_RX_RATE == 1.5) && (PMA_CH1_SIPO_BIT_SETTING == "20BIT")) ? 26 : 35;
    localparam   integer PMA_CH2_REG_OOB_COMINIT_GAP_MAX = (((CH2_RX_RATE == 6.0) && (PMA_CH2_SIPO_BIT_SETTING == "20BIT")) || ((CH2_RX_RATE == 3.0) && (PMA_CH2_SIPO_BIT_SETTING == "10BIT" ))) ? 102:
                                                       (((CH2_RX_RATE == 3.0) && (PMA_CH2_SIPO_BIT_SETTING == "20BIT")) || ((CH2_RX_RATE == 1.5) && (PMA_CH2_SIPO_BIT_SETTING == "10BIT" ))) ? 52 :
                                                        ((CH2_RX_RATE == 1.5) && (PMA_CH2_SIPO_BIT_SETTING == "20BIT")) ? 26 : 35;
    localparam   integer PMA_CH3_REG_OOB_COMINIT_GAP_MAX = (((CH3_RX_RATE == 6.0) && (PMA_CH3_SIPO_BIT_SETTING == "20BIT")) || ((CH3_RX_RATE == 3.0) && (PMA_CH3_SIPO_BIT_SETTING == "10BIT" ))) ? 102:
                                                       (((CH3_RX_RATE == 3.0) && (PMA_CH3_SIPO_BIT_SETTING == "20BIT")) || ((CH3_RX_RATE == 1.5) && (PMA_CH3_SIPO_BIT_SETTING == "10BIT" ))) ? 52 :
                                                        ((CH3_RX_RATE == 1.5) && (PMA_CH3_SIPO_BIT_SETTING == "20BIT")) ? 26 : 35;

    localparam PCS_CH0_BYPASS_GEAR   =  CH0_RDATA_WIDTH_TYPE == "16bit_only"  ? "TRUE" :
                                   CH0_RDATA_WIDTH_TYPE == "20bit_only"  ? "TRUE" :
                                   CH0_RDATA_WIDTH_TYPE == "8b10b_16bit" ? "TRUE" : "FALSE";
    localparam PCS_CH1_BYPASS_GEAR   =  CH1_RDATA_WIDTH_TYPE == "16bit_only"  ? "TRUE" :
                                   CH1_RDATA_WIDTH_TYPE == "20bit_only"  ? "TRUE" :
                                   CH1_RDATA_WIDTH_TYPE == "8b10b_16bit" ? "TRUE" : "FALSE";
    localparam PCS_CH2_BYPASS_GEAR   =  CH2_RDATA_WIDTH_TYPE == "16bit_only"  ? "TRUE" :
                                   CH2_RDATA_WIDTH_TYPE == "20bit_only"  ? "TRUE" :
                                   CH2_RDATA_WIDTH_TYPE == "8b10b_16bit" ? "TRUE" : "FALSE";
    localparam PCS_CH3_BYPASS_GEAR   =  CH3_RDATA_WIDTH_TYPE == "16bit_only"  ? "TRUE" :
                                   CH3_RDATA_WIDTH_TYPE == "20bit_only"  ? "TRUE" :
                                   CH3_RDATA_WIDTH_TYPE == "8b10b_16bit" ? "TRUE" : "FALSE";

    localparam PCS_CH0_BYPASS_BRIDGE = RX0_CLK2_FR_CORE == "TRUE" ? "TRUE" : "FALSE";
    localparam PCS_CH1_BYPASS_BRIDGE = RX1_CLK2_FR_CORE == "TRUE" ? "TRUE" : "FALSE";
    localparam PCS_CH2_BYPASS_BRIDGE = RX2_CLK2_FR_CORE == "TRUE" ? "TRUE" : "FALSE";
    localparam PCS_CH3_BYPASS_BRIDGE = RX3_CLK2_FR_CORE == "TRUE" ? "TRUE" : "FALSE";

    localparam PCS_CH0_BYPASS_BRIDGE_FIFO = "FALSE";
    localparam PCS_CH1_BYPASS_BRIDGE_FIFO = "FALSE";
    localparam PCS_CH2_BYPASS_BRIDGE_FIFO = "FALSE";
    localparam PCS_CH3_BYPASS_BRIDGE_FIFO = "FALSE";

    localparam PCS_CH0_PCS_RCLK_SEL = "PMA_RCLK";
    localparam PCS_CH1_PCS_RCLK_SEL = "PMA_RCLK";
    localparam PCS_CH2_PCS_RCLK_SEL = "PMA_RCLK";
    localparam PCS_CH3_PCS_RCLK_SEL = "PMA_RCLK";

    localparam PCS_CH0_CB_RCLK_SEL = PCS_CH0_BYPASS_BONDING == "FALSE" ? "MCB_RCLK" : "PMA_RCLK";
    localparam PCS_CH1_CB_RCLK_SEL = PCS_CH1_BYPASS_BONDING == "FALSE" ? "MCB_RCLK" : "PMA_RCLK";
    localparam PCS_CH2_CB_RCLK_SEL = PCS_CH2_BYPASS_BONDING == "FALSE" ? "MCB_RCLK" : "PMA_RCLK";
    localparam PCS_CH3_CB_RCLK_SEL = PCS_CH3_BYPASS_BONDING == "FALSE" ? "MCB_RCLK" : "PMA_RCLK";

    localparam PCS_CH0_AFTER_CTC_RCLK_SEL = RX0_CLK2_FR_CORE   == "TRUE"      ? "RCLK2"    :
                                        PCS_CH0_BYPASS_CTC == "FALSE"     ? "PMA_TCLK" :
                                        PCS_CH0_BYPASS_BONDING == "FALSE" ? "MCB_RCLK" : "PMA_RCLK";
    localparam PCS_CH1_AFTER_CTC_RCLK_SEL = RX1_CLK2_FR_CORE   == "TRUE"      ? "RCLK2"    :
                                        PCS_CH1_BYPASS_CTC == "FALSE"     ? "PMA_TCLK" :
                                        PCS_CH1_BYPASS_BONDING == "FALSE" ? "MCB_RCLK" : "PMA_RCLK";
    localparam PCS_CH2_AFTER_CTC_RCLK_SEL = RX2_CLK2_FR_CORE   == "TRUE"      ? "RCLK2"    :
                                        PCS_CH2_BYPASS_CTC == "FALSE"     ? "PMA_TCLK" :
                                        PCS_CH2_BYPASS_BONDING == "FALSE" ? "MCB_RCLK" : "PMA_RCLK";
    localparam PCS_CH3_AFTER_CTC_RCLK_SEL = RX1_CLK2_FR_CORE   == "TRUE"      ? "RCLK2"    :
                                        PCS_CH3_BYPASS_CTC == "FALSE"     ? "PMA_TCLK" :
                                        PCS_CH3_BYPASS_BONDING == "FALSE" ? "MCB_RCLK" : "PMA_RCLK";

    localparam PCS_CH0_RX_64B66B_67B = CH0_RX_DECODER == "64B66B_transparent" ? "64B_66B"  :
                                   CH0_RX_DECODER == "64B67B_transparent" ? "64B_67B"  : "NORMAL";
    localparam PCS_CH1_RX_64B66B_67B = CH1_RX_DECODER == "64B66B_transparent" ? "64B_66B"  :
                                   CH1_RX_DECODER == "64B67B_transparent" ? "64B_67B"  : "NORMAL";
    localparam PCS_CH2_RX_64B66B_67B = CH2_RX_DECODER == "64B66B_transparent" ? "64B_66B"  :
                                   CH2_RX_DECODER == "64B67B_transparent" ? "64B_67B"  : "NORMAL";
    localparam PCS_CH3_RX_64B66B_67B = CH3_RX_DECODER == "64B66B_transparent" ? "64B_66B"  :
                                   CH3_RX_DECODER == "64B67B_transparent" ? "64B_67B"  : "NORMAL";

    //---------------------------------------------------

    // 内部复位参数
    localparam FREE_CLOCK_FREQ = (FREE_FRQ == 0) ? 100.0 : FREE_FRQ;
    localparam CH0_TX_ENABLE = ((CH0_EN == "Fullduplex") || (CH0_EN == "TX_only")) ? "TRUE" : "FALSE";
    localparam CH1_TX_ENABLE = ((CH1_EN == "Fullduplex") || (CH1_EN == "TX_only")) ? "TRUE" : "FALSE";
    localparam CH2_TX_ENABLE = ((CH2_EN == "Fullduplex") || (CH2_EN == "TX_only")) ? "TRUE" : "FALSE";
    localparam CH3_TX_ENABLE = ((CH3_EN == "Fullduplex") || (CH3_EN == "TX_only")) ? "TRUE" : "FALSE";
    localparam CH0_RX_ENABLE = ((CH0_EN == "Fullduplex") || (CH0_EN == "RX_only")) ? "TRUE" : "FALSE";
    localparam CH1_RX_ENABLE = ((CH1_EN == "Fullduplex") || (CH1_EN == "RX_only")) ? "TRUE" : "FALSE";
    localparam CH2_RX_ENABLE = ((CH2_EN == "Fullduplex") || (CH2_EN == "RX_only")) ? "TRUE" : "FALSE";
    localparam CH3_RX_ENABLE = ((CH3_EN == "Fullduplex") || (CH3_EN == "RX_only")) ? "TRUE" : "FALSE";
    localparam CH0_MULT_LANE_MODE      = ((CH0_PROTOCOL=="CUSTOMERIZEDx4")||(CH0_PROTOCOL=="PCIEx4")||(CH0_PROTOCOL=="XAUI")) ? 4 :
                                      ((CH0_PROTOCOL=="CUSTOMERIZEDx2")||(CH0_PROTOCOL=="PCIEx2")) ? 2 : 1;
    localparam CH1_MULT_LANE_MODE      = ((CH0_PROTOCOL=="CUSTOMERIZEDx4")||(CH0_PROTOCOL=="PCIEx4")||(CH0_PROTOCOL=="XAUI")) ? 4 :
                                      ((CH0_PROTOCOL=="CUSTOMERIZEDx2")||(CH0_PROTOCOL=="PCIEx2")) ? 2 : 1;
    localparam CH2_MULT_LANE_MODE      = ((CH0_PROTOCOL=="CUSTOMERIZEDx4")||(CH0_PROTOCOL=="PCIEx4")||(CH0_PROTOCOL=="XAUI")) ? 4 :
                                      ((CH2_PROTOCOL=="CUSTOMERIZEDx2")||(CH2_PROTOCOL=="PCIEx2")) ? 2 : 1;
    localparam CH3_MULT_LANE_MODE      = ((CH0_PROTOCOL=="CUSTOMERIZEDx4")||(CH0_PROTOCOL=="PCIEx4")||(CH0_PROTOCOL=="XAUI")) ? 4 :
                                      ((CH2_PROTOCOL=="CUSTOMERIZEDx2")||(CH2_PROTOCOL=="PCIEx2")) ? 2 : 1;
    localparam CHANNEL0_EN = (CH0_TX_ENABLE == "TRUE" || CH0_RX_ENABLE == "TRUE") ? "TRUE" : "FALSE";
    localparam CHANNEL1_EN = (CH1_TX_ENABLE == "TRUE" || CH1_RX_ENABLE == "TRUE") ? "TRUE" : "FALSE";
    localparam CHANNEL2_EN = (CH2_TX_ENABLE == "TRUE" || CH2_RX_ENABLE == "TRUE") ? "TRUE" : "FALSE";
    localparam CHANNEL3_EN = (CH3_TX_ENABLE == "TRUE" || CH3_RX_ENABLE == "TRUE") ? "TRUE" : "FALSE";
    localparam TX_CHANNEL0_PLL = CH0_TX_PLL_SEL == "PLL1" ? 1 : 0;
    localparam TX_CHANNEL1_PLL = CH1_TX_PLL_SEL == "PLL1" ? 1 : 0;
    localparam TX_CHANNEL2_PLL = CH2_TX_PLL_SEL == "PLL1" ? 1 : 0;
    localparam TX_CHANNEL3_PLL = CH3_TX_PLL_SEL == "PLL1" ? 1 : 0;
    localparam RX_CHANNEL0_PLL = CH0_RX_PLL_SEL == "PLL1" ? 1 : 0;
    localparam RX_CHANNEL1_PLL = CH1_RX_PLL_SEL == "PLL1" ? 1 : 0;
    localparam RX_CHANNEL2_PLL = CH2_RX_PLL_SEL == "PLL1" ? 1 : 0;
    localparam RX_CHANNEL3_PLL = CH3_RX_PLL_SEL == "PLL1" ? 1 : 0;
    localparam PCS_CH0_BYPASS_ALIGN    = (CH0_RXPCS_ALIGN=="Bypassed" || CH0_RXPCS_ALIGN=="CUSTOMERIZED_MODE" || CH0_RX_CLK_SLIP_EN=="TRUE") ? "TRUE" : "FALSE";
    localparam PCS_CH1_BYPASS_ALIGN    = (CH1_RXPCS_ALIGN=="Bypassed" || CH1_RXPCS_ALIGN=="CUSTOMERIZED_MODE" || CH1_RX_CLK_SLIP_EN=="TRUE") ? "TRUE" : "FALSE";
    localparam PCS_CH2_BYPASS_ALIGN    = (CH2_RXPCS_ALIGN=="Bypassed" || CH2_RXPCS_ALIGN=="CUSTOMERIZED_MODE" || CH2_RX_CLK_SLIP_EN=="TRUE") ? "TRUE" : "FALSE";
    localparam PCS_CH3_BYPASS_ALIGN    = (CH3_RXPCS_ALIGN=="Bypassed" || CH3_RXPCS_ALIGN=="CUSTOMERIZED_MODE" || CH3_RX_CLK_SLIP_EN=="TRUE") ? "TRUE" : "FALSE";
    localparam PCS_CH0_BYPASS_BOND     = (CH0_RXPCS_BONDING=="Bypassed" || CH0_RXPCS_BONDING=="CUSTOMERIZED_MODE") ? "TRUE" : "FALSE";
    localparam PCS_CH1_BYPASS_BOND     = (CH1_RXPCS_BONDING=="Bypassed" || CH1_RXPCS_BONDING=="CUSTOMERIZED_MODE") ? "TRUE" : "FALSE";
    localparam PCS_CH2_BYPASS_BOND     = (CH2_RXPCS_BONDING=="Bypassed" || CH2_RXPCS_BONDING=="CUSTOMERIZED_MODE") ? "TRUE" : "FALSE";
    localparam PCS_CH3_BYPASS_BOND     = (CH3_RXPCS_BONDING=="Bypassed" || CH3_RXPCS_BONDING=="CUSTOMERIZED_MODE") ? "TRUE" : "FALSE";

    // PLL 速率切换时钟选择参数
    localparam PLL0_TXPCLK_PLL_SEL     = (CH0_TX_PLL_SEL=="PLL0" && CH0_TX_ENABLE=="TRUE") ? 0 :
                                     (CH1_TX_PLL_SEL=="PLL0" && CH1_TX_ENABLE=="TRUE") ? 1 :
                                     (CH2_TX_PLL_SEL=="PLL0" && CH2_TX_ENABLE=="TRUE") ? 2 :
                                     (CH3_TX_PLL_SEL=="PLL0" && CH3_TX_ENABLE=="TRUE") ? 3 :
                                     (CHANNEL0_EN=="TRUE") ? 0 :
                                     (CHANNEL1_EN=="TRUE") ? 1 :
                                     (CHANNEL2_EN=="TRUE") ? 2 : 3;
    localparam PLL1_TXPCLK_PLL_SEL     = (CH0_TX_PLL_SEL=="PLL1" && CH0_TX_ENABLE=="TRUE") ? 0 :
                                     (CH1_TX_PLL_SEL=="PLL1" && CH1_TX_ENABLE=="TRUE") ? 1 :
                                     (CH2_TX_PLL_SEL=="PLL1" && CH2_TX_ENABLE=="TRUE") ? 2 :
                                     (CH3_TX_PLL_SEL=="PLL1" && CH3_TX_ENABLE=="TRUE") ? 3 :
                                     (CHANNEL0_EN=="TRUE") ? 0 :
                                     (CHANNEL1_EN=="TRUE") ? 1 :
                                     (CHANNEL2_EN=="TRUE") ? 2 : 3;

    // 内部复位与 HSST 连线
    wire         P_PLL_READY_0;
    wire         P_PLL_READY_1;
    wire         P_RX_SIGDET_STATUS_0;
    wire         P_RX_SIGDET_STATUS_1;
    wire         P_RX_SIGDET_STATUS_2;
    wire         P_RX_SIGDET_STATUS_3;
    wire         P_LX_CDR_ALIGN_0;
    wire         P_LX_CDR_ALIGN_1;
    wire         P_LX_CDR_ALIGN_2;
    wire         P_LX_CDR_ALIGN_3;
    wire         P_PCS_LSM_SYNCED_0;
    wire         P_PCS_LSM_SYNCED_1;
    wire         P_PCS_LSM_SYNCED_2;
    wire         P_PCS_LSM_SYNCED_3;
    wire         P_PCS_RX_MCB_STATUS_0;
    wire         P_PCS_RX_MCB_STATUS_1;
    wire         P_PCS_RX_MCB_STATUS_2;
    wire         P_PCS_RX_MCB_STATUS_3;
    wire         P_PLLPOWERDOWN_0;
    wire         P_PLLPOWERDOWN_1;
    wire         P_PLL_RST_0;
    wire         P_PLL_RST_1;
    wire         P_LANE_SYNC_0;
    wire         P_LANE_SYNC_1;
    wire         P_RATE_CHANGE_TCLK_ON_0;
    wire         P_RATE_CHANGE_TCLK_ON_1;
    wire         P_TX_LANE_PD_CLKPATH_0;
    wire         P_TX_LANE_PD_CLKPATH_1;
    wire         P_TX_LANE_PD_CLKPATH_2;
    wire         P_TX_LANE_PD_CLKPATH_3;
    wire         P_TX_LANE_PD_PISO_0;
    wire         P_TX_LANE_PD_PISO_1;
    wire         P_TX_LANE_PD_PISO_2;
    wire         P_TX_LANE_PD_PISO_3;
    wire         P_TX_LANE_PD_DRIVER_0;
    wire         P_TX_LANE_PD_DRIVER_1;
    wire         P_TX_LANE_PD_DRIVER_2;
    wire         P_TX_LANE_PD_DRIVER_3;
    wire [2 : 0] P_TX_RATE_0;
    wire [2 : 0] P_TX_RATE_1;
    wire [2 : 0] P_TX_RATE_2;
    wire [2 : 0] P_TX_RATE_3;
    wire         P_TX_PMA_RST_0;
    wire         P_TX_PMA_RST_1;
    wire         P_TX_PMA_RST_2;
    wire         P_TX_PMA_RST_3;
    wire         P_PCS_TX_RST_0;
    wire         P_PCS_TX_RST_1;
    wire         P_PCS_TX_RST_2;
    wire         P_PCS_TX_RST_3;
    wire         P_RX_PMA_RST_0;
    wire         P_RX_PMA_RST_1;
    wire         P_RX_PMA_RST_2;
    wire         P_RX_PMA_RST_3;
    wire         P_LANE_PD_0;
    wire         P_LANE_PD_1;
    wire         P_LANE_PD_2;
    wire         P_LANE_PD_3;
    wire         P_LANE_RST_0;
    wire         P_LANE_RST_1;
    wire         P_LANE_RST_2;
    wire         P_LANE_RST_3;
    wire         P_RX_LANE_PD_0;
    wire         P_RX_LANE_PD_1;
    wire         P_RX_LANE_PD_2;
    wire         P_RX_LANE_PD_3;
    wire         P_PCS_RX_RST_0;
    wire         P_PCS_RX_RST_1;
    wire         P_PCS_RX_RST_2;
    wire         P_PCS_RX_RST_3;
    wire [2 : 0] P_RX_RATE_0;
    wire [2 : 0] P_RX_RATE_1;
    wire [2 : 0] P_RX_RATE_2;
    wire [2 : 0] P_RX_RATE_3;
    wire         P_PCS_CB_RST_0;
    wire         P_PCS_CB_RST_1;
    wire         P_PCS_CB_RST_2;
    wire         P_PCS_CB_RST_3;
    wire         P_RESCAL_RST_I_0 = 1'b0;
    wire         P_RESCAL_RST_I_1 = 1'b0;
    wire         i_force_rxfsm_det_0;
    wire         i_force_rxfsm_det_1;
    wire         i_force_rxfsm_det_2;
    wire         i_force_rxfsm_det_3;
    wire         i_force_rxfsm_cdr_0;
    wire         i_force_rxfsm_cdr_1;
    wire         i_force_rxfsm_cdr_2;
    wire         i_force_rxfsm_cdr_3;
    wire         i_force_rxfsm_lsm_0;
    wire         i_force_rxfsm_lsm_1;
    wire         i_force_rxfsm_lsm_2;
    wire         i_force_rxfsm_lsm_3;

    wire         i_free_clk = 1'b0;
    wire         i_pll_rst_0 = 1'b0;
    wire         i_pll_rst_1 = 1'b0;
    wire         i_wtchdg_clr_0 = 1'b0;
    wire         i_wtchdg_clr_1 = 1'b0;
    wire         i_txlane_rst_0 = 1'b0;
    wire         i_txlane_rst_1 = 1'b0;
    wire         i_txlane_rst_2 = 1'b0;
    wire         i_txlane_rst_3 = 1'b0;
    wire         i_rxlane_rst_0 = 1'b0;
    wire         i_rxlane_rst_1 = 1'b0;
    wire         i_rxlane_rst_2 = 1'b0;
    wire         i_rxlane_rst_3 = 1'b0;
    wire         i_tx_rate_chng_0 = 1'b0;
    wire         i_tx_rate_chng_1 = 1'b0;
    wire         i_tx_rate_chng_2 = 1'b0;
    wire         i_tx_rate_chng_3 = 1'b0;
    wire [  1:0] i_txckdiv_0 = P_LX_TX_CKDIV_0;
    wire [  1:0] i_txckdiv_1 = P_LX_TX_CKDIV_1;
    wire [  1:0] i_txckdiv_2 = P_LX_TX_CKDIV_2;
    wire [  1:0] i_txckdiv_3 = P_LX_TX_CKDIV_3;
    wire         i_rx_rate_chng_0 = 1'b0;
    wire         i_rx_rate_chng_1 = 1'b0;
    wire         i_rx_rate_chng_2 = 1'b0;
    wire         i_rx_rate_chng_3 = 1'b0;
    wire [  1:0] i_rxckdiv_0 = LX_RX_CKDIV_0;
    wire [  1:0] i_rxckdiv_1 = LX_RX_CKDIV_1;
    wire [  1:0] i_rxckdiv_2 = LX_RX_CKDIV_2;
    wire [  1:0] i_rxckdiv_3 = LX_RX_CKDIV_3;
    wire         i_pcs_cb_rst_0 = 1'b0;
    wire         i_hsst_fifo_clr_0 = 1'b0;
    assign i_force_rxfsm_det_0 = 1'b0;
    assign i_force_rxfsm_cdr_0 = 1'b0;
    assign i_force_rxfsm_lsm_0 = 1'b0;
    wire i_pcs_cb_rst_1 = 1'b0;
    wire i_hsst_fifo_clr_1 = 1'b0;
    assign i_force_rxfsm_det_1 = 1'b0;
    assign i_force_rxfsm_cdr_1 = 1'b0;
    assign i_force_rxfsm_lsm_1 = 1'b0;
    wire i_pcs_cb_rst_2 = 1'b0;
    wire i_hsst_fifo_clr_2 = 1'b0;
    assign i_force_rxfsm_det_2 = 1'b0;
    assign i_force_rxfsm_cdr_2 = 1'b0;
    assign i_force_rxfsm_lsm_2 = 1'b0;
    wire i_pcs_cb_rst_3 = 1'b0;
    wire i_hsst_fifo_clr_3 = 1'b0;
    assign i_force_rxfsm_det_3 = 1'b0;
    assign i_force_rxfsm_cdr_3 = 1'b0;
    assign i_force_rxfsm_lsm_3 = 1'b0;
    wire [1:0] o_wtchdg_st_0;
    wire [1:0] o_wtchdg_st_1;
    wire       o_pll_done_0;
    wire       o_pll_done_1;
    wire       o_txlane_done_0;
    wire       o_txlane_done_1;
    wire       o_txlane_done_2;
    wire       o_txlane_done_3;
    wire       o_tx_ckdiv_done_0;
    wire       o_tx_ckdiv_done_1;
    wire       o_tx_ckdiv_done_2;
    wire       o_tx_ckdiv_done_3;
    wire       o_rxlane_done_0;
    wire       o_rxlane_done_1;
    wire       o_rxlane_done_2;
    wire       o_rxlane_done_3;
    wire       o_rx_ckdiv_done_0;
    wire       o_rx_ckdiv_done_1;
    wire       o_rx_ckdiv_done_2;
    wire       o_rx_ckdiv_done_3;
    wire       i_p_pllpowerdown_1 = 1'b1;
    wire       i_p_tx_lane_pd_clkpath_2 = 1'b1;
    wire       i_p_tx_lane_pd_clkpath_3 = 1'b1;
    wire       i_p_tx_lane_pd_piso_2 = 1'b1;
    wire       i_p_tx_lane_pd_piso_3 = 1'b1;
    wire       i_p_tx_lane_pd_driver_2 = 1'b1;
    wire       i_p_tx_lane_pd_driver_3 = 1'b1;
    wire       i_p_lane_pd_2 = 1'b1;
    wire       i_p_lane_pd_3 = 1'b1;
    wire       i_p_lane_rst_2 = 1'b0;
    wire       i_p_lane_rst_3 = 1'b0;
    wire       i_p_rx_lane_pd_2 = 1'b1;
    wire       i_p_rx_lane_pd_3 = 1'b1;
    wire       o_p_clk2core_tx_2;
    wire       o_p_clk2core_tx_3;
    wire       i_p_tx2_clk_fr_core = 1'b0;
    wire       i_p_tx3_clk_fr_core = 1'b0;
    wire       i_p_tx0_clk2_fr_core = 1'b0;
    wire       i_p_tx1_clk2_fr_core = 1'b0;
    wire       i_p_tx2_clk2_fr_core = 1'b0;
    wire       i_p_tx3_clk2_fr_core = 1'b0;
    wire       i_pll_lock_tx_0 = 1'b1;
    wire       i_pll_lock_tx_1 = 1'b1;
    wire       i_pll_lock_tx_2 = 1'b1;
    wire       i_pll_lock_tx_3 = 1'b1;
    wire       o_p_clk2core_rx_0;
    wire       o_p_clk2core_rx_1;
    wire       o_p_clk2core_rx_2;
    wire       o_p_clk2core_rx_3;
    wire       i_p_rx2_clk_fr_core = 1'b0;
    wire       i_p_rx3_clk_fr_core = 1'b0;
    wire       i_p_rx2_clk2_fr_core = 1'b0;
    wire       i_p_rx3_clk2_fr_core = 1'b0;
    wire       i_pll_lock_rx_2 = 1'b1;
    wire       i_pll_lock_rx_3 = 1'b1;
    wire       o_p_refck2core_1;
    wire       i_p_pll_rst_1 = 1'b1;
    wire       i_p_tx_pma_rst_2 = 1'b1;
    wire       i_p_tx_pma_rst_3 = 1'b1;
    wire       i_p_pcs_tx_rst_2 = 1'b1;
    wire       i_p_pcs_tx_rst_3 = 1'b1;
    wire       i_p_rx_pma_rst_2 = 1'b1;
    wire       i_p_rx_pma_rst_3 = 1'b1;
    wire       i_p_pcs_rx_rst_2 = 1'b1;
    wire       i_p_pcs_rx_rst_3 = 1'b1;
    wire       i_p_pcs_cb_rst_2 = 1'b0;
    wire       i_p_pcs_cb_rst_3 = 1'b0;
    wire [2:0] i_p_lx_margin_ctl_2 = 3'b0;
    wire [2:0] i_p_lx_margin_ctl_3 = 3'b0;
    wire       i_p_lx_swing_ctl_2 = 1'b0;
    wire       i_p_lx_swing_ctl_3 = 1'b0;
    wire [1:0] i_p_lx_deemp_ctl_2 = 2'b0;
    wire [1:0] i_p_lx_deemp_ctl_3 = 2'b0;
    wire       i_p_rx_highz_0 = 1'b0;
    wire       i_p_rx_highz_1 = 1'b0;
    wire       i_p_rx_highz_2 = 1'b0;
    wire       i_p_rx_highz_3 = 1'b0;
    wire       i_p_lane_sync_1 = 1'b0;
    wire       i_p_rate_change_tclk_on_1 = 1'b1;
    wire [1:0] i_p_tx_ckdiv_2 = P_LX_TX_CKDIV_2;
    wire [1:0] i_p_tx_ckdiv_3 = P_LX_TX_CKDIV_3;
    wire [1:0] i_p_lx_rx_ckdiv_2 = LX_RX_CKDIV_2;
    wire [1:0] i_p_lx_rx_ckdiv_3 = LX_RX_CKDIV_3;
    wire [1:0] i_p_lx_elecidle_en_2 = 2'b0;
    wire [1:0] i_p_lx_elecidle_en_3 = 2'b0;
    assign o_p_pll_lock_0      = P_PLL_READY_0;
    assign o_p_rx_sigdet_sta_0 = P_RX_SIGDET_STATUS_0;
    assign o_p_rx_sigdet_sta_1 = P_RX_SIGDET_STATUS_1;
    assign o_p_lx_cdr_align_0  = P_LX_CDR_ALIGN_0;
    assign o_p_lx_cdr_align_1  = P_LX_CDR_ALIGN_1;
    wire [1:0] o_p_lx_oob_sta_0;
    wire [1:0] o_p_lx_oob_sta_1;
    wire [1:0] o_p_lx_oob_sta_2;
    wire [1:0] o_p_lx_oob_sta_3;
    wire       i_p_lx_rxdct_en_2 = 1'b0;
    wire       i_p_lx_rxdct_en_3 = 1'b0;
    wire       o_p_lx_rxdct_out_2;
    wire       o_p_lx_rxdct_out_3;
    wire       i_p_rxgear_slip_0 = 1'b0;
    wire       i_p_rxgear_slip_1 = 1'b0;
    wire       i_p_rxgear_slip_2 = 1'b0;
    wire       i_p_rxgear_slip_3 = 1'b0;
    wire       i_p_pcs_word_align_en_0 = 1'b0;
    wire       i_p_pcs_word_align_en_1 = 1'b0;
    wire       i_p_pcs_word_align_en_2 = 1'b0;
    wire       i_p_pcs_word_align_en_3 = 1'b0;
    wire       i_p_pcs_mcb_ext_en_0 = 1'b0;
    wire       i_p_pcs_mcb_ext_en_1 = 1'b0;
    wire       i_p_pcs_mcb_ext_en_2 = 1'b0;
    wire       i_p_pcs_mcb_ext_en_3 = 1'b0;
    assign o_p_pcs_lsm_synced_0 = P_PCS_LSM_SYNCED_0;
    assign o_p_pcs_lsm_synced_1 = P_PCS_LSM_SYNCED_1;
    wire i_p_pcs_nearend_loop_2 = 1'b0;
    wire i_p_pcs_farend_loop_2 = 1'b0;
    wire i_p_pma_nearend_ploop_2 = 1'b0;
    wire i_p_pma_nearend_sloop_2 = 1'b0;
    wire i_p_pma_farend_ploop_2 = 1'b0;
    wire i_p_pcs_nearend_loop_3 = 1'b0;
    wire i_p_pcs_farend_loop_3 = 1'b0;
    wire i_p_pma_nearend_ploop_3 = 1'b0;
    wire i_p_pma_nearend_sloop_3 = 1'b0;
    wire i_p_pma_farend_ploop_3 = 1'b0;
    wire i_p_rx_polarity_invert_2 = 1'b0;
    wire i_p_rx_polarity_invert_3 = 1'b0;
    wire i_p_tx_beacon_en_2 = 1'b0;
    wire i_p_tx_beacon_en_3 = 1'b0;
    wire [45:0] i_p_tdata_0 = {
        i_p_lx_elecidle_en_0,
        i_txk_0[3],
        i_tdispctrl_0[3],
        i_tdispsel_0[3],
        i_txd_0[31:24],
        i_txk_0[2],
        i_tdispctrl_0[2],
        i_tdispsel_0[2],
        i_txd_0[23:16],
        i_txk_0[1],
        i_tdispctrl_0[1],
        i_tdispsel_0[1],
        i_txd_0[15:8],
        i_txk_0[0],
        i_tdispctrl_0[0],
        i_tdispsel_0[0],
        i_txd_0[7:0]
    };
    wire [45:0] i_p_tdata_1 = {
        i_p_lx_elecidle_en_1,
        i_txk_1[3],
        i_tdispctrl_1[3],
        i_tdispsel_1[3],
        i_txd_1[31:24],
        i_txk_1[2],
        i_tdispctrl_1[2],
        i_tdispsel_1[2],
        i_txd_1[23:16],
        i_txk_1[1],
        i_tdispctrl_1[1],
        i_tdispsel_1[1],
        i_txd_1[15:8],
        i_txk_1[0],
        i_tdispctrl_1[0],
        i_tdispsel_1[0],
        i_txd_1[7:0]
    };
    wire [45:0] i_p_tdata_2 = 46'b0;
    wire [45:0] i_p_tdata_3 = 46'b0;
    wire [46:0] o_p_rdata_0;

    assign o_rxstatus_0 = o_p_rdata_0[46:44];
    assign o_rxd_0      = {o_p_rdata_0[40:33], o_p_rdata_0[29:22], o_p_rdata_0[18:11], o_p_rdata_0[7:0]};
    assign o_rdisper_0  = {o_p_rdata_0[41], o_p_rdata_0[30], o_p_rdata_0[19], o_p_rdata_0[8]};
    assign o_rdecer_0   = {o_p_rdata_0[42], o_p_rdata_0[31], o_p_rdata_0[20], o_p_rdata_0[9]};
    assign o_rxk_0      = {o_p_rdata_0[43], o_p_rdata_0[32], o_p_rdata_0[21], o_p_rdata_0[10]};
    wire [46:0] o_p_rdata_1;

    assign o_rxstatus_1 = o_p_rdata_1[46:44];
    assign o_rxd_1      = {o_p_rdata_1[40:33], o_p_rdata_1[29:22], o_p_rdata_1[18:11], o_p_rdata_1[7:0]};
    assign o_rdisper_1  = {o_p_rdata_1[41], o_p_rdata_1[30], o_p_rdata_1[19], o_p_rdata_1[8]};
    assign o_rdecer_1   = {o_p_rdata_1[42], o_p_rdata_1[31], o_p_rdata_1[20], o_p_rdata_1[9]};
    assign o_rxk_1      = {o_p_rdata_1[43], o_p_rdata_1[32], o_p_rdata_1[21], o_p_rdata_1[10]};
    wire [46:0] o_p_rdata_2;

    wire [46:0] o_p_rdata_3;

    ipm2l_hsstlp_rst_v1_6 #(
        .INNER_RST_EN(INNER_RST_EN),  // TRUE：HSST 自动控制复位；FALSE：用户控制复位。
        .FREE_CLOCK_FREQ(FREE_CLOCK_FREQ),  // 自由运行时钟频率来自配置界面，范围 0～200 MHz。
        .CH0_TX_ENABLE(CH0_TX_ENABLE),  // 通道 0 发送复位逻辑使能。
        .CH1_TX_ENABLE(CH1_TX_ENABLE),  // 通道 1 发送复位逻辑使能。
        .CH2_TX_ENABLE(CH2_TX_ENABLE),  // 通道 2 发送复位逻辑使能。
        .CH3_TX_ENABLE(CH3_TX_ENABLE),  // 通道 3 发送复位逻辑使能。
        .CH0_RX_ENABLE(CH0_RX_ENABLE),  // 通道 0 接收复位逻辑使能。
        .CH1_RX_ENABLE(CH1_RX_ENABLE),  // 通道 1 接收复位逻辑使能。
        .CH2_RX_ENABLE(CH2_RX_ENABLE),  // 通道 2 接收复位逻辑使能。
        .CH3_RX_ENABLE(CH3_RX_ENABLE),  // 通道 3 接收复位逻辑使能。
        .CH0_MULT_LANE_MODE(CH0_MULT_LANE_MODE),  // 通道 0 配置：1 单通道，2 双通道，4 四通道。
        .CH1_MULT_LANE_MODE(CH1_MULT_LANE_MODE),  // 通道 1 配置：1 单通道，2 双通道，4 四通道。
        .CH2_MULT_LANE_MODE(CH2_MULT_LANE_MODE),  // 通道 2 配置：1 单通道，2 双通道，4 四通道。
        .CH3_MULT_LANE_MODE(CH3_MULT_LANE_MODE),  // 通道 3 配置：1 单通道，2 双通道，4 四通道。
        .CH0_RXPCS_ALIGN_TIMER(CH0_RXPCS_ALIGN_TIMER),  // 字对齐等待超时后复位接收 PMA。
        .CH1_RXPCS_ALIGN_TIMER(CH1_RXPCS_ALIGN_TIMER),  // 字对齐等待超时后复位接收 PMA。
        .CH2_RXPCS_ALIGN_TIMER(CH2_RXPCS_ALIGN_TIMER),  // 字对齐等待超时后复位接收 PMA。
        .CH3_RXPCS_ALIGN_TIMER(CH3_RXPCS_ALIGN_TIMER),  // 字对齐等待超时后复位接收 PMA。
        .PCS_CH0_BYPASS_WORD_ALIGN(PCS_CH0_BYPASS_ALIGN),  // 通道 0 字对齐或外部模式旁路使能。
        .PCS_CH1_BYPASS_WORD_ALIGN(PCS_CH1_BYPASS_ALIGN),  // 通道 1 字对齐或外部模式旁路使能。
        .PCS_CH2_BYPASS_WORD_ALIGN(PCS_CH2_BYPASS_ALIGN),  // 通道 2 字对齐或外部模式旁路使能。
        .PCS_CH3_BYPASS_WORD_ALIGN(PCS_CH3_BYPASS_ALIGN),  // 通道 3 字对齐或外部模式旁路使能。
        .PCS_CH0_BYPASS_BONDING(PCS_CH0_BYPASS_BOND),  // 通道 0 通道绑定旁路使能。
        .PCS_CH1_BYPASS_BONDING(PCS_CH1_BYPASS_BOND),  // 通道 1 通道绑定旁路使能。
        .PCS_CH2_BYPASS_BONDING(PCS_CH2_BYPASS_BOND),  // 通道 2 通道绑定旁路使能。
        .PCS_CH3_BYPASS_BONDING(PCS_CH3_BYPASS_BOND),  // 通道 3 通道绑定旁路使能。
        .PCS_CH0_BYPASS_CTC(PCS_CH0_BYPASS_CTC),  // 通道 0 时钟补偿旁路使能。
        .PCS_CH1_BYPASS_CTC(PCS_CH1_BYPASS_CTC),  // 通道 1 时钟补偿旁路使能。
        .PCS_CH2_BYPASS_CTC(PCS_CH2_BYPASS_CTC),  // 通道 2 时钟补偿旁路使能。
        .PCS_CH3_BYPASS_CTC(PCS_CH3_BYPASS_CTC),  // 通道 3 时钟补偿旁路使能。
        .P_LX_TX_CKDIV_0(P_LX_TX_CKDIV_0),  // 发送端初始时钟分频值
        .P_LX_TX_CKDIV_1(P_LX_TX_CKDIV_1),  // 发送端初始时钟分频值
        .P_LX_TX_CKDIV_2(P_LX_TX_CKDIV_2),  // 发送端初始时钟分频值
        .P_LX_TX_CKDIV_3(P_LX_TX_CKDIV_3),  // 发送端初始时钟分频值
        .LX_RX_CKDIV_0(LX_RX_CKDIV_0),  // 接收端初始时钟分频值
        .LX_RX_CKDIV_1(LX_RX_CKDIV_1),  // 接收端初始时钟分频值
        .LX_RX_CKDIV_2(LX_RX_CKDIV_2),  // 接收端初始时钟分频值
        .LX_RX_CKDIV_3(LX_RX_CKDIV_3),  // 接收端初始时钟分频值
        .CH0_TX_PLL_SEL(TX_CHANNEL0_PLL),  // 通道 0 时钟选择：1 为 PLL1，0 为 PLL0。
        .CH1_TX_PLL_SEL(TX_CHANNEL1_PLL),  // 通道 1 时钟选择：1 为 PLL1，0 为 PLL0。
        .CH2_TX_PLL_SEL(TX_CHANNEL2_PLL),  // 通道 2 时钟选择：1 为 PLL1，0 为 PLL0。
        .CH3_TX_PLL_SEL(TX_CHANNEL3_PLL),  // 通道 3 时钟选择：1 为 PLL1，0 为 PLL0。
        .CH0_RX_PLL_SEL(RX_CHANNEL0_PLL),  // 通道 0 时钟选择：1 为 PLL1，0 为 PLL0。
        .CH1_RX_PLL_SEL(RX_CHANNEL1_PLL),  // 通道 1 时钟选择：1 为 PLL1，0 为 PLL0。
        .CH2_RX_PLL_SEL(RX_CHANNEL2_PLL),  // 通道 2 时钟选择：1 为 PLL1，0 为 PLL0。
        .CH3_RX_PLL_SEL(RX_CHANNEL3_PLL),  // 通道 3 时钟选择：1 为 PLL1，0 为 PLL0。
        .PLL_NUBER(PLL_NUM),  // 取值为 1 或 2。
        .PCS_TX_CLK_EXPLL_USE_CH0(TX0_CLK2_FR_CORE),
        .PCS_TX_CLK_EXPLL_USE_CH1(TX0_CLK2_FR_CORE),
        .PCS_TX_CLK_EXPLL_USE_CH2(TX0_CLK2_FR_CORE),
        .PCS_TX_CLK_EXPLL_USE_CH3(TX0_CLK2_FR_CORE),
        .PCS_RX_CLK_EXPLL_USE_CH0(RX0_CLK2_FR_CORE),
        .PCS_RX_CLK_EXPLL_USE_CH1(RX1_CLK2_FR_CORE),
        .PCS_RX_CLK_EXPLL_USE_CH2(RX2_CLK2_FR_CORE),
        .PCS_RX_CLK_EXPLL_USE_CH3(RX3_CLK2_FR_CORE)
    ) U_IPM2L_HSSTLP_RST (
        // 两者均需要
        .i_pll_lock_tx_0          (i_pll_lock_tx_0),
        .i_pll_lock_tx_1          (i_pll_lock_tx_1),
        .i_pll_lock_tx_2          (i_pll_lock_tx_2),
        .i_pll_lock_tx_3          (i_pll_lock_tx_3),
        .i_pll_lock_rx_0          (i_pll_lock_rx_0),
        .i_pll_lock_rx_1          (i_pll_lock_rx_1),
        .i_pll_lock_rx_2          (i_pll_lock_rx_2),
        .i_pll_lock_rx_3          (i_pll_lock_rx_3),
        // 用户侧接口
        // 启用内部复位
        .i_free_clk               (i_free_clk),
        .i_pll_rst_0              (i_pll_rst_0),
        .i_pll_rst_1              (i_pll_rst_1),
        .i_wtchdg_clr_0           (i_wtchdg_clr_0),
        .i_wtchdg_clr_1           (i_wtchdg_clr_1),
        .i_txlane_rst_0           (i_txlane_rst_0),
        .i_txlane_rst_1           (i_txlane_rst_1),
        .i_txlane_rst_2           (i_txlane_rst_2),
        .i_txlane_rst_3           (i_txlane_rst_3),
        .i_rxlane_rst_0           (i_rxlane_rst_0),
        .i_rxlane_rst_1           (i_rxlane_rst_1),
        .i_rxlane_rst_2           (i_rxlane_rst_2),
        .i_rxlane_rst_3           (i_rxlane_rst_3),
        .i_tx_rate_chng_0         (i_tx_rate_chng_0),
        .i_tx_rate_chng_1         (i_tx_rate_chng_1),
        .i_tx_rate_chng_2         (i_tx_rate_chng_2),
        .i_tx_rate_chng_3         (i_tx_rate_chng_3),
        .i_rx_rate_chng_0         (i_rx_rate_chng_0),
        .i_rx_rate_chng_1         (i_rx_rate_chng_1),
        .i_rx_rate_chng_2         (i_rx_rate_chng_2),
        .i_rx_rate_chng_3         (i_rx_rate_chng_3),
        .i_txckdiv_0              (i_txckdiv_0),
        .i_txckdiv_1              (i_txckdiv_1),
        .i_txckdiv_2              (i_txckdiv_2),
        .i_txckdiv_3              (i_txckdiv_3),
        .i_rxckdiv_0              (i_rxckdiv_0),
        .i_rxckdiv_1              (i_rxckdiv_1),
        .i_rxckdiv_2              (i_rxckdiv_2),
        .i_rxckdiv_3              (i_rxckdiv_3),
        .i_pcs_cb_rst_0           (i_pcs_cb_rst_0),
        .i_pcs_cb_rst_1           (i_pcs_cb_rst_1),
        .i_pcs_cb_rst_2           (i_pcs_cb_rst_2),
        .i_pcs_cb_rst_3           (i_pcs_cb_rst_3),
        .i_hsstlp_fifo_clr_0      (i_hsst_fifo_clr_0),
        .i_hsstlp_fifo_clr_1      (i_hsst_fifo_clr_1),
        .i_hsstlp_fifo_clr_2      (i_hsst_fifo_clr_2),
        .i_hsstlp_fifo_clr_3      (i_hsst_fifo_clr_3),
        .i_force_rxfsm_det_0      (i_force_rxfsm_det_0),
        .i_force_rxfsm_lsm_0      (i_force_rxfsm_lsm_0),
        .i_force_rxfsm_cdr_0      (i_force_rxfsm_cdr_0),
        .i_force_rxfsm_det_1      (i_force_rxfsm_det_1),
        .i_force_rxfsm_lsm_1      (i_force_rxfsm_lsm_1),
        .i_force_rxfsm_cdr_1      (i_force_rxfsm_cdr_1),
        .i_force_rxfsm_det_2      (i_force_rxfsm_det_2),
        .i_force_rxfsm_lsm_2      (i_force_rxfsm_lsm_2),
        .i_force_rxfsm_cdr_2      (i_force_rxfsm_cdr_2),
        .i_force_rxfsm_det_3      (i_force_rxfsm_det_3),
        .i_force_rxfsm_lsm_3      (i_force_rxfsm_lsm_3),
        .i_force_rxfsm_cdr_3      (i_force_rxfsm_cdr_3),
        .o_wtchdg_st_0            (o_wtchdg_st_0),
        .o_wtchdg_st_1            (o_wtchdg_st_1),
        .o_pll_done_0             (o_pll_done_0),
        .o_pll_done_1             (o_pll_done_1),
        .o_txlane_done_0          (o_txlane_done_0),
        .o_txlane_done_1          (o_txlane_done_1),
        .o_txlane_done_2          (o_txlane_done_2),
        .o_txlane_done_3          (o_txlane_done_3),
        .o_tx_ckdiv_done_0        (o_tx_ckdiv_done_0),
        .o_tx_ckdiv_done_1        (o_tx_ckdiv_done_1),
        .o_tx_ckdiv_done_2        (o_tx_ckdiv_done_2),
        .o_tx_ckdiv_done_3        (o_tx_ckdiv_done_3),
        .o_rxlane_done_0          (o_rxlane_done_0),
        .o_rxlane_done_1          (o_rxlane_done_1),
        .o_rxlane_done_2          (o_rxlane_done_2),
        .o_rxlane_done_3          (o_rxlane_done_3),
        .o_rx_ckdiv_done_0        (o_rx_ckdiv_done_0),
        .o_rx_ckdiv_done_1        (o_rx_ckdiv_done_1),
        .o_rx_ckdiv_done_2        (o_rx_ckdiv_done_2),
        .o_rx_ckdiv_done_3        (o_rx_ckdiv_done_3),
        // 禁用内部复位
        .i_f_pllpowerdown_0       (i_p_pllpowerdown_0),
        .i_f_pllpowerdown_1       (i_p_pllpowerdown_1),
        .i_f_pll_rst_0            (i_p_pll_rst_0),
        .i_f_pll_rst_1            (i_p_pll_rst_1),
        .i_f_lane_sync_0          (i_p_lane_sync_0),
        .i_f_lane_sync_1          (i_p_lane_sync_1),
        .i_f_rate_change_tclk_on_0(i_p_rate_change_tclk_on_0),
        .i_f_rate_change_tclk_on_1(i_p_rate_change_tclk_on_1),
        .i_f_tx_lane_pd_clkpath_0 (i_p_tx_lane_pd_clkpath_0),
        .i_f_tx_lane_pd_clkpath_1 (i_p_tx_lane_pd_clkpath_1),
        .i_f_tx_lane_pd_clkpath_2 (i_p_tx_lane_pd_clkpath_2),
        .i_f_tx_lane_pd_clkpath_3 (i_p_tx_lane_pd_clkpath_3),
        .i_f_tx_pma_rst_0         (i_p_tx_pma_rst_0),
        .i_f_tx_pma_rst_1         (i_p_tx_pma_rst_1),
        .i_f_tx_pma_rst_2         (i_p_tx_pma_rst_2),
        .i_f_tx_pma_rst_3         (i_p_tx_pma_rst_3),
        .i_f_tx_lane_pd_piso_0    (i_p_tx_lane_pd_piso_0),
        .i_f_tx_lane_pd_piso_1    (i_p_tx_lane_pd_piso_1),
        .i_f_tx_lane_pd_piso_2    (i_p_tx_lane_pd_piso_2),
        .i_f_tx_lane_pd_piso_3    (i_p_tx_lane_pd_piso_3),
        .i_f_tx_lane_pd_driver_0  (i_p_tx_lane_pd_driver_0),
        .i_f_tx_lane_pd_driver_1  (i_p_tx_lane_pd_driver_1),
        .i_f_tx_lane_pd_driver_2  (i_p_tx_lane_pd_driver_2),
        .i_f_tx_lane_pd_driver_3  (i_p_tx_lane_pd_driver_3),
        .i_f_tx_ckdiv_0           (i_p_tx_ckdiv_0),
        .i_f_tx_ckdiv_1           (i_p_tx_ckdiv_1),
        .i_f_tx_ckdiv_2           (i_p_tx_ckdiv_2),
        .i_f_tx_ckdiv_3           (i_p_tx_ckdiv_3),
        .i_f_pcs_tx_rst_0         (i_p_pcs_tx_rst_0),
        .i_f_pcs_tx_rst_1         (i_p_pcs_tx_rst_1),
        .i_f_pcs_tx_rst_2         (i_p_pcs_tx_rst_2),
        .i_f_pcs_tx_rst_3         (i_p_pcs_tx_rst_3),
        .i_f_lane_pd_0            (i_p_lane_pd_0),
        .i_f_lane_pd_1            (i_p_lane_pd_1),
        .i_f_lane_pd_2            (i_p_lane_pd_2),
        .i_f_lane_pd_3            (i_p_lane_pd_3),
        .i_f_lane_rst_0           (i_p_lane_rst_0),
        .i_f_lane_rst_1           (i_p_lane_rst_1),
        .i_f_lane_rst_2           (i_p_lane_rst_2),
        .i_f_lane_rst_3           (i_p_lane_rst_3),
        .i_f_rx_lane_pd_0         (i_p_rx_lane_pd_0),
        .i_f_rx_lane_pd_1         (i_p_rx_lane_pd_1),
        .i_f_rx_lane_pd_2         (i_p_rx_lane_pd_2),
        .i_f_rx_lane_pd_3         (i_p_rx_lane_pd_3),
        .i_f_rx_pma_rst_0         (i_p_rx_pma_rst_0),
        .i_f_rx_pma_rst_1         (i_p_rx_pma_rst_1),
        .i_f_rx_pma_rst_2         (i_p_rx_pma_rst_2),
        .i_f_rx_pma_rst_3         (i_p_rx_pma_rst_3),
        .i_f_pcs_rx_rst_0         (i_p_pcs_rx_rst_0),
        .i_f_pcs_rx_rst_1         (i_p_pcs_rx_rst_1),
        .i_f_pcs_rx_rst_2         (i_p_pcs_rx_rst_2),
        .i_f_pcs_rx_rst_3         (i_p_pcs_rx_rst_3),
        .i_f_lx_rx_ckdiv_0        (i_p_lx_rx_ckdiv_0),
        .i_f_lx_rx_ckdiv_1        (i_p_lx_rx_ckdiv_1),
        .i_f_lx_rx_ckdiv_2        (i_p_lx_rx_ckdiv_2),
        .i_f_lx_rx_ckdiv_3        (i_p_lx_rx_ckdiv_3),
        .i_f_pcs_cb_rst_0         (i_p_pcs_cb_rst_0),
        .i_f_pcs_cb_rst_1         (i_p_pcs_cb_rst_1),
        .i_f_pcs_cb_rst_2         (i_p_pcs_cb_rst_2),
        .i_f_pcs_cb_rst_3         (i_p_pcs_cb_rst_3),

        // HSST 侧接口
        .P_PLL_READY_0          (P_PLL_READY_0),
        .P_PLL_READY_1          (P_PLL_READY_1),
        .P_RX_SIGDET_STATUS_0   (P_RX_SIGDET_STATUS_0),
        .P_RX_SIGDET_STATUS_1   (P_RX_SIGDET_STATUS_1),
        .P_RX_SIGDET_STATUS_2   (P_RX_SIGDET_STATUS_2),
        .P_RX_SIGDET_STATUS_3   (P_RX_SIGDET_STATUS_3),
        .P_RX_READY_0           (P_LX_CDR_ALIGN_0),
        .P_RX_READY_1           (P_LX_CDR_ALIGN_1),
        .P_RX_READY_2           (P_LX_CDR_ALIGN_2),
        .P_RX_READY_3           (P_LX_CDR_ALIGN_3),
        .P_PCS_LSM_SYNCED_0     (P_PCS_LSM_SYNCED_0),
        .P_PCS_LSM_SYNCED_1     (P_PCS_LSM_SYNCED_1),
        .P_PCS_LSM_SYNCED_2     (P_PCS_LSM_SYNCED_2),
        .P_PCS_LSM_SYNCED_3     (P_PCS_LSM_SYNCED_3),
        .P_PCS_RX_MCB_STATUS_0  (P_PCS_RX_MCB_STATUS_0),
        .P_PCS_RX_MCB_STATUS_1  (P_PCS_RX_MCB_STATUS_1),
        .P_PCS_RX_MCB_STATUS_2  (P_PCS_RX_MCB_STATUS_2),
        .P_PCS_RX_MCB_STATUS_3  (P_PCS_RX_MCB_STATUS_3),
        .P_PLLPOWERDOWN_0       (P_PLLPOWERDOWN_0),
        .P_PLLPOWERDOWN_1       (P_PLLPOWERDOWN_1),
        .P_PLL_RST_0            (P_PLL_RST_0),
        .P_PLL_RST_1            (P_PLL_RST_1),
        .P_LANE_SYNC_0          (P_LANE_SYNC_0),
        .P_LANE_SYNC_1          (P_LANE_SYNC_1),
        .P_RATE_CHANGE_TCLK_ON_0(P_RATE_CHANGE_TCLK_ON_0),
        .P_RATE_CHANGE_TCLK_ON_1(P_RATE_CHANGE_TCLK_ON_1),
        .P_TX_LANE_PD_CLKPATH_0 (P_TX_LANE_PD_CLKPATH_0),
        .P_TX_LANE_PD_CLKPATH_1 (P_TX_LANE_PD_CLKPATH_1),
        .P_TX_LANE_PD_CLKPATH_2 (P_TX_LANE_PD_CLKPATH_2),
        .P_TX_LANE_PD_CLKPATH_3 (P_TX_LANE_PD_CLKPATH_3),
        .P_TX_LANE_PD_PISO_0    (P_TX_LANE_PD_PISO_0),
        .P_TX_LANE_PD_PISO_1    (P_TX_LANE_PD_PISO_1),
        .P_TX_LANE_PD_PISO_2    (P_TX_LANE_PD_PISO_2),
        .P_TX_LANE_PD_PISO_3    (P_TX_LANE_PD_PISO_3),
        .P_TX_LANE_PD_DRIVER_0  (P_TX_LANE_PD_DRIVER_0),
        .P_TX_LANE_PD_DRIVER_1  (P_TX_LANE_PD_DRIVER_1),
        .P_TX_LANE_PD_DRIVER_2  (P_TX_LANE_PD_DRIVER_2),
        .P_TX_LANE_PD_DRIVER_3  (P_TX_LANE_PD_DRIVER_3),
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
        .P_RX_PMA_RST_0         (P_RX_PMA_RST_0),
        .P_RX_PMA_RST_1         (P_RX_PMA_RST_1),
        .P_RX_PMA_RST_2         (P_RX_PMA_RST_2),
        .P_RX_PMA_RST_3         (P_RX_PMA_RST_3),
        .P_LANE_PD_0            (P_LANE_PD_0),
        .P_LANE_PD_1            (P_LANE_PD_1),
        .P_LANE_PD_2            (P_LANE_PD_2),
        .P_LANE_PD_3            (P_LANE_PD_3),
        .P_LANE_RST_0           (P_LANE_RST_0),
        .P_LANE_RST_1           (P_LANE_RST_1),
        .P_LANE_RST_2           (P_LANE_RST_2),
        .P_LANE_RST_3           (P_LANE_RST_3),
        .P_RX_LANE_PD_0         (P_RX_LANE_PD_0),
        .P_RX_LANE_PD_1         (P_RX_LANE_PD_1),
        .P_RX_LANE_PD_2         (P_RX_LANE_PD_2),
        .P_RX_LANE_PD_3         (P_RX_LANE_PD_3),
        .P_PCS_RX_RST_0         (P_PCS_RX_RST_0),
        .P_PCS_RX_RST_1         (P_PCS_RX_RST_1),
        .P_PCS_RX_RST_2         (P_PCS_RX_RST_2),
        .P_PCS_RX_RST_3         (P_PCS_RX_RST_3),
        .P_RX_RATE_0            (P_RX_RATE_0),
        .P_RX_RATE_1            (P_RX_RATE_1),
        .P_RX_RATE_2            (P_RX_RATE_2),
        .P_RX_RATE_3            (P_RX_RATE_3),
        .P_PCS_CB_RST_0         (P_PCS_CB_RST_0),
        .P_PCS_CB_RST_1         (P_PCS_CB_RST_1),
        .P_PCS_CB_RST_2         (P_PCS_CB_RST_2),
        .P_PCS_CB_RST_3         (P_PCS_CB_RST_3)
    );

    ipm2l_hsstlp_wrapper_v1_6 #(
        // 全局参数
        .PLL0_EN            (PLL0_EN),              // PLL0 使能
        .PLL1_EN            (PLL1_EN),              // PLL1 使能
        .CH0_EN             (CH0_EN),               // 取值：全双工、仅发送、仅接收或禁用。
        .CH1_EN             (CH1_EN),               // 取值：全双工、仅发送、仅接收或禁用。
        .CH2_EN             (CH2_EN),               // 取值：全双工、仅发送、仅接收或禁用。
        .CH3_EN             (CH3_EN),               // 取值：全双工、仅发送、仅接收或禁用。
        .CHANNEL0_EN        (CHANNEL0_EN),          // 通道 0 使能。
        .CHANNEL1_EN        (CHANNEL1_EN),          // 通道 1 使能。
        .CHANNEL2_EN        (CHANNEL2_EN),          // 通道 2 使能。
        .CHANNEL3_EN        (CHANNEL3_EN),          // 通道 3 使能。
        .TX_CHANNEL0_PLL    (TX_CHANNEL0_PLL),      // 0 选择 PLL0，1 选择 PLL1。
        .TX_CHANNEL1_PLL    (TX_CHANNEL1_PLL),      // 0 选择 PLL0，1 选择 PLL1。
        .TX_CHANNEL2_PLL    (TX_CHANNEL2_PLL),      // 0 选择 PLL0，1 选择 PLL1。
        .TX_CHANNEL3_PLL    (TX_CHANNEL3_PLL),      // 0 选择 PLL0，1 选择 PLL1。
        .RX_CHANNEL0_PLL    (RX_CHANNEL0_PLL),      // 0 选择 PLL0，1 选择 PLL1。
        .RX_CHANNEL1_PLL    (RX_CHANNEL1_PLL),      // 0 选择 PLL0，1 选择 PLL1。
        .RX_CHANNEL2_PLL    (RX_CHANNEL2_PLL),      // 0 选择 PLL0，1 选择 PLL1。
        .RX_CHANNEL3_PLL    (RX_CHANNEL3_PLL),      // 0 选择 PLL0，1 选择 PLL1。
        .CH0_MULT_LANE_MODE (CH0_MULT_LANE_MODE),   // 通道 0 配置：1 单通道，2 双通道，4 四通道。
        .CH1_MULT_LANE_MODE (CH1_MULT_LANE_MODE),   // 通道 1 配置：1 单通道，2 双通道，4 四通道。
        .CH2_MULT_LANE_MODE (CH2_MULT_LANE_MODE),   // 通道 2 配置：1 单通道，2 双通道，4 四通道。
        .CH3_MULT_LANE_MODE (CH3_MULT_LANE_MODE),   // 通道 3 配置：1 单通道，2 双通道，4 四通道。
        .PLL0_TXPCLK_PLL_SEL(PLL0_TXPCLK_PLL_SEL),  // PLL0 时钟来自通道 0。
        .PLL1_TXPCLK_PLL_SEL(PLL1_TXPCLK_PLL_SEL),  // PLL1 时钟来自通道 0。

        .PCS_CH0_BYPASS_WORD_ALIGN(PCS_CH0_BYPASS_WORD_ALIGN),  // 字对齐旁路使能
        .PCS_CH0_BYPASS_DENC(PCS_CH0_BYPASS_DENC),  // 8b/10b 解码旁路使能
        .PCS_CH0_BYPASS_BONDING(PCS_CH0_BYPASS_BONDING),  // 通道绑定旁路使能
        .PCS_CH0_BYPASS_CTC(PCS_CH0_BYPASS_CTC),  // 时钟补偿旁路使能
        .PCS_CH0_BYPASS_GEAR(PCS_CH0_BYPASS_GEAR),  // 使能选项：开启或关闭。
        .PCS_CH0_BYPASS_BRIDGE(PCS_CH0_BYPASS_BRIDGE),  // 接收桥接单元旁路使能
        .PCS_CH0_BYPASS_BRIDGE_FIFO(PCS_CH0_BYPASS_BRIDGE_FIFO),  // 接收桥接 FIFO 旁路使能
        .PCS_CH0_DATA_MODE(PCS_CH0_DATA_MODE),  // 数据宽度：8、10、16 或 20 位。
        .PCS_CH0_ALIGN_MODE(PCS_CH0_ALIGN_MODE),  // 协议模式：1GB、10GB、RAPIDIO 或外部模式。
        .PCS_CH0_SAMP_16B(PCS_CH0_SAMP_16B),  // X16 用于 8、16、32 位数据，X20 用于其他位宽。
        .PCS_CH0_COMMA_REG0(PCS_CH0_COMMA_REG0),  // 字对齐逗号码的 10 位取值
        .PCS_CH0_COMMA_MASK(PCS_CH0_COMMA_MASK),  // 通道 0 两个逗号码寄存器的比较掩码
        .PCS_CH0_CEB_MODE(PCS_CH0_CEB_MODE),  // 选择 10GB、RAPIDIO 或外部通道绑定状态机。
        .PCS_CH0_CTC_MODE                  (PCS_CH0_CTC_MODE                    ),// 跳过字符增删数量：00 为 1，01 为 2，10 保留，11 为 4。
        .PCS_CH0_A_REG(PCS_CH0_A_REG),  // 8 位通道绑定特殊码
        .PCS_CH0_GE_AUTO_EN(PCS_CH0_GE_AUTO_EN),  // GE 模式下将 C 字符转换为 I2 字符以支持时钟补偿。
        .PCS_CH0_SKIP_REG0(PCS_CH0_SKIP_REG0),  // 第一个 10 位跳过字符
        .PCS_CH0_SKIP_REG1(PCS_CH0_SKIP_REG1),  // 第二个 10 位跳过字符
        .PCS_CH0_SKIP_REG2(PCS_CH0_SKIP_REG2),  // 第三个 10 位跳过字符
        .PCS_CH0_SKIP_REG3(PCS_CH0_SKIP_REG3),  // 第四个 10 位跳过字符
        .PCS_CH0_DEC_DUAL(PCS_CH0_DEC_DUAL),  // 8b/10b 解码配置：选择双解码器或单解码器。
        .PCS_CH0_SPLIT                     (PCS_CH0_SPLIT                       ),// TRUE 用于 8 位、10 位或 8b/10b 的 8 位数据，其余位宽为 FALSE。
        .PCS_CH0_COMMA_DET_MODE(PCS_CH0_COMMA_DET_MODE),  // 参数选项："RX_CLK_SLIP" "COMMA_PATTERN"
        .PCS_CH0_PCS_RCLK_SEL              (PCS_CH0_PCS_RCLK_SEL                ),// 编码 00 选 pma_rclk，01 选 pma_tclk，10 选 mcb_rclk，11 保留；本项不使用 01。
        .PCS_CH0_CB_RCLK_SEL               (PCS_CH0_CB_RCLK_SEL                 ),// 编码 00 选 pma_rclk，01 选 pma_tclk，10 选 mcb_rclk，11 保留；本项不使用 01。
        .PCS_CH0_AFTER_CTC_RCLK_SEL        (PCS_CH0_AFTER_CTC_RCLK_SEL          ),// 编码 00 选 pma_rclk，01 选 pma_tclk，10 选 mcb_rclk，11 保留。
        .PCS_CH0_PCS_RCLK_EN               (PCS_CH0_PCS_RCLK_EN                 ),// TRUE 用于 8 位、10 位或 8b/10b 的 8 位数据，其余位宽为 FALSE。
        .PCS_CH0_CB_RCLK_EN                (PCS_CH0_CB_RCLK_EN                  ),// TRUE 用于 8 位、10 位或 8b/10b 的 8 位数据，其余位宽为 FALSE。
        .PCS_CH0_AFTER_CTC_RCLK_EN         (PCS_CH0_AFTER_CTC_RCLK_EN           ),// TRUE 用于 8 位、10 位或 8b/10b 的 8 位数据，其余位宽为 FALSE。
        .PCS_CH0_AFTER_CTC_RCLK_EN_GB      (PCS_CH0_AFTER_CTC_RCLK_EN_GB        ),// TRUE 用于 32 位、40 位或 8b/10b 的 32 位数据，其余位宽为 FALSE。
        .PCS_CH0_SLAVE(PCS_CH0_SLAVE),  // 1 为从通道，0 为主通道。
        .PCS_CH0_PCIE_SLAVE(PCS_CH0_PCIE_SLAVE),  // 1 为从通道，0 为主通道。
        .PCS_CH0_RX_64B66B_67B(PCS_CH0_RX_64B66B_67B),  // 编码模式：普通、64b/66b 或 64b/67b。
        .PCS_CH0_TX_BRIDGE_GEAR_SEL        (PCS_CH0_TX_BRIDGE_GEAR_SEL          ),// TRUE 优先使用发送齿轮箱，FALSE 优先使用发送桥接单元。
        .PCS_CH0_TX_BYPASS_BRIDGE_UINT     (PCS_CH0_TX_BYPASS_BRIDGE_UINT       ),// TRUE 旁路发送桥，FALSE 使用发送桥。
        .PCS_CH0_TX_BYPASS_BRIDGE_FIFO     (PCS_CH0_TX_BYPASS_BRIDGE_FIFO       ),// TRUE 旁路发送桥 FIFO，FALSE 使用发送桥 FIFO。
        .PCS_CH0_TX_BYPASS_GEAR(PCS_CH0_TX_BYPASS_GEAR),  // 32 位、40 位或 8b/10b 的 32 位数据使用 FALSE。
        .PCS_CH0_TX_BYPASS_ENC(PCS_CH0_TX_BYPASS_ENC),  // 使能选项：开启或关闭。
        .PCS_CH0_TX_GEAR_SPLIT(PCS_CH0_TX_GEAR_SPLIT),  // 32 位、40 位或 8b/10b 的 32 位数据使用 TRUE。
        .PCS_CH0_TX_PCS_CLK_EN_SEL         (PCS_CH0_TX_PCS_CLK_EN_SEL           ),// 32 位、40 位或 8b/10b 的 32 位数据使用 TRUE。
        .PCS_CH0_TX_BRIDGE_TCLK_SEL(PCS_CH0_TX_BRIDGE_TCLK_SEL),  // 参数选项："TCLK" "TCLK2"
        .PCS_CH0_PCS_TCLK_SEL(PCS_CH0_PCS_TCLK_SEL),  // 参数选项："PMA_TCLK" "TCLK"
        .PCS_CH0_TX_SLAVE(PCS_CH0_TX_SLAVE),  // 1 为从通道，0 为主通道。
        .PCS_CH0_TX_GEAR_CLK_EN_SEL(PCS_CH0_TX_GEAR_CLK_EN_SEL),  // 使能选项：开启或关闭。
        .PCS_CH0_DATA_WIDTH_MODE           (PCS_CH0_DATA_WIDTH_MODE             ),// X20：20 位、40 位或 8b/10b 的 16/32 位；X16：16/32 位；X10：10 位或 8b/10b 的 8 位；X8：8 位。
        .PCS_CH0_TX_64B66B_67B(PCS_CH0_TX_64B66B_67B),  // 编码模式：普通、64b/66b 或 64b/67b。
        .PCS_CH0_GEAR_TCLK_SEL(PCS_CH0_GEAR_TCLK_SEL),  // 参数选项："PMA_TCLK" "TCLK2"
        .PCS_CH0_TX_TCLK2FABRIC_SEL        (PCS_CH0_TX_TCLK2FABRIC_SEL          ),// 32 位、40 位或 8b/10b 的 32 位数据使用 TRUE。
        .PCS_CH0_TX_OUTZZ(PCS_CH0_TX_OUTZZ),  // 1 用于 16/32 位，0 用于 20/40 位。
        .PCS_CH0_ENC_DUAL(PCS_CH0_ENC_DUAL),  // 使能选项：开启或关闭。
        .PCS_CH0_COMMA_REG1(PCS_CH0_COMMA_REG1),  // 字对齐逗号码的 10 位取值
        .PCS_CH0_RAPID_IMAX(PCS_CH0_RAPID_IMAX),  // 取值范围：0～7。
        .PCS_CH0_RAPID_VMIN_1(PCS_CH0_RAPID_VMIN_1),  // 取值范围：0～255。
        .PCS_CH0_RAPID_VMIN_2(PCS_CH0_RAPID_VMIN_2),  // 取值范围：0～255。
        .PCS_CH0_MASTER_CHECK_OFFSET(PCS_CH0_MASTER_CHECK_OFFSET),  // 用于通道绑定
        .PCS_CH0_DELAY_SET(PCS_CH0_DELAY_SET),  // 默认值由主通道编号决定。
        .PCS_CH0_SEACH_OFFSET              (PCS_CH0_SEACH_OFFSET                ),// 通道绑定范围为 20～70 位，间隔 10 位；对齐范围 81 UI。
        .PCS_CH0_CEB_RAPIDLS_MMAX(PCS_CH0_CEB_RAPIDLS_MMAX),  // 取值范围：0～7。
        .PCS_CH0_PMA_TX2RX_PLOOP_EN(PCS_CH0_PMA_TX2RX_PLOOP_EN),  // 使能选项：开启或关闭。
        .PCS_CH0_PMA_TX2RX_SLOOP_EN(PCS_CH0_PMA_TX2RX_SLOOP_EN),  // 使能选项：开启或关闭。
        .PCS_CH0_PMA_RX2TX_PLOOP_EN(PCS_CH0_PMA_RX2TX_PLOOP_EN),  // 使能选项：开启或关闭。
        .PCS_CH1_BYPASS_WORD_ALIGN(PCS_CH1_BYPASS_WORD_ALIGN),  // 字对齐旁路使能
        .PCS_CH1_BYPASS_DENC(PCS_CH1_BYPASS_DENC),  // 8b/10b 解码旁路使能
        .PCS_CH1_BYPASS_BONDING(PCS_CH1_BYPASS_BONDING),  // 通道绑定旁路使能
        .PCS_CH1_BYPASS_CTC(PCS_CH1_BYPASS_CTC),  // 时钟补偿旁路使能
        .PCS_CH1_BYPASS_GEAR(PCS_CH1_BYPASS_GEAR),  // 使能选项：开启或关闭。
        .PCS_CH1_BYPASS_BRIDGE(PCS_CH1_BYPASS_BRIDGE),  // 接收桥接单元旁路使能
        .PCS_CH1_BYPASS_BRIDGE_FIFO(PCS_CH1_BYPASS_BRIDGE_FIFO),  // 接收桥接 FIFO 旁路使能
        .PCS_CH1_DATA_MODE(PCS_CH1_DATA_MODE),  // 数据宽度：8、10、16 或 20 位。
        .PCS_CH1_ALIGN_MODE(PCS_CH1_ALIGN_MODE),  // 协议模式：1GB、10GB、RAPIDIO 或外部模式。
        .PCS_CH1_SAMP_16B(PCS_CH1_SAMP_16B),  // X16 用于 8、16、32 位数据，X20 用于其他位宽。
        .PCS_CH1_COMMA_REG0(PCS_CH1_COMMA_REG0),  // 字对齐逗号码的 10 位取值
        .PCS_CH1_COMMA_MASK(PCS_CH1_COMMA_MASK),  // 通道 1 两个逗号码寄存器的比较掩码
        .PCS_CH1_CEB_MODE(PCS_CH1_CEB_MODE),  // 选择 10GB、RAPIDIO 或外部通道绑定状态机。
        .PCS_CH1_CTC_MODE                  (PCS_CH1_CTC_MODE                    ),// 跳过字符增删数量：00 为 1，01 为 2，10 保留，11 为 4。
        .PCS_CH1_A_REG(PCS_CH1_A_REG),  // 8 位通道绑定特殊码
        .PCS_CH1_GE_AUTO_EN(PCS_CH1_GE_AUTO_EN),  // GE 模式下将 C 字符转换为 I2 字符以支持时钟补偿。
        .PCS_CH1_SKIP_REG0(PCS_CH1_SKIP_REG0),  // 第一个 10 位跳过字符
        .PCS_CH1_SKIP_REG1(PCS_CH1_SKIP_REG1),  // 第二个 10 位跳过字符
        .PCS_CH1_SKIP_REG2(PCS_CH1_SKIP_REG2),  // 第三个 10 位跳过字符
        .PCS_CH1_SKIP_REG3(PCS_CH1_SKIP_REG3),  // 第四个 10 位跳过字符
        .PCS_CH1_DEC_DUAL(PCS_CH1_DEC_DUAL),  // 8b/10b 解码配置：选择双解码器或单解码器。
        .PCS_CH1_SPLIT                     (PCS_CH1_SPLIT                       ),// TRUE 用于 8 位、10 位或 8b/10b 的 8 位数据，其余位宽为 FALSE。
        .PCS_CH1_COMMA_DET_MODE(PCS_CH1_COMMA_DET_MODE),  // 参数选项："RX_CLK_SLIP" "COMMA_PATTERN"
        .PCS_CH1_PCS_RCLK_SEL              (PCS_CH1_PCS_RCLK_SEL                ),// 编码 00 选 pma_rclk，01 选 pma_tclk，10 选 mcb_rclk，11 保留；本项不使用 01。
        .PCS_CH1_CB_RCLK_SEL               (PCS_CH1_CB_RCLK_SEL                 ),// 编码 00 选 pma_rclk，01 选 pma_tclk，10 选 mcb_rclk，11 保留；本项不使用 01。
        .PCS_CH1_AFTER_CTC_RCLK_SEL        (PCS_CH1_AFTER_CTC_RCLK_SEL          ),// 编码 00 选 pma_rclk，01 选 pma_tclk，10 选 mcb_rclk，11 保留。
        .PCS_CH1_PCS_RCLK_EN               (PCS_CH1_PCS_RCLK_EN                 ),// TRUE 用于 8 位、10 位或 8b/10b 的 8 位数据，其余位宽为 FALSE。
        .PCS_CH1_CB_RCLK_EN                (PCS_CH1_CB_RCLK_EN                  ),// TRUE 用于 8 位、10 位或 8b/10b 的 8 位数据，其余位宽为 FALSE。
        .PCS_CH1_AFTER_CTC_RCLK_EN         (PCS_CH1_AFTER_CTC_RCLK_EN           ),// TRUE 用于 8 位、10 位或 8b/10b 的 8 位数据，其余位宽为 FALSE。
        .PCS_CH1_AFTER_CTC_RCLK_EN_GB      (PCS_CH1_AFTER_CTC_RCLK_EN_GB        ),// TRUE 用于 32 位、40 位或 8b/10b 的 32 位数据，其余位宽为 FALSE。
        .PCS_CH1_SLAVE(PCS_CH1_SLAVE),  // 1 为从通道，0 为主通道。
        .PCS_CH1_PCIE_SLAVE(PCS_CH1_PCIE_SLAVE),  // 1 为从通道，0 为主通道。
        .PCS_CH1_RX_64B66B_67B(PCS_CH1_RX_64B66B_67B),  // 编码模式：普通、64b/66b 或 64b/67b。
        .PCS_CH1_TX_BRIDGE_GEAR_SEL        (PCS_CH1_TX_BRIDGE_GEAR_SEL          ),// TRUE 优先使用发送齿轮箱，FALSE 优先使用发送桥接单元。
        .PCS_CH1_TX_BYPASS_BRIDGE_UINT     (PCS_CH1_TX_BYPASS_BRIDGE_UINT       ),// TRUE 旁路发送桥，FALSE 使用发送桥。
        .PCS_CH1_TX_BYPASS_BRIDGE_FIFO     (PCS_CH1_TX_BYPASS_BRIDGE_FIFO       ),// TRUE 旁路发送桥 FIFO，FALSE 使用发送桥 FIFO。
        .PCS_CH1_TX_BYPASS_GEAR(PCS_CH1_TX_BYPASS_GEAR),  // 32 位、40 位或 8b/10b 的 32 位数据使用 FALSE。
        .PCS_CH1_TX_BYPASS_ENC(PCS_CH1_TX_BYPASS_ENC),  // 使能选项：开启或关闭。
        .PCS_CH1_TX_GEAR_SPLIT(PCS_CH1_TX_GEAR_SPLIT),  // 32 位、40 位或 8b/10b 的 32 位数据使用 TRUE。
        .PCS_CH1_TX_PCS_CLK_EN_SEL         (PCS_CH1_TX_PCS_CLK_EN_SEL           ),// 32 位、40 位或 8b/10b 的 32 位数据使用 TRUE。
        .PCS_CH1_TX_BRIDGE_TCLK_SEL(PCS_CH1_TX_BRIDGE_TCLK_SEL),  // 参数选项："PCS_TCLK" "TCLK"
        .PCS_CH1_PCS_TCLK_SEL(PCS_CH1_PCS_TCLK_SEL),  // 参数选项："PMA_TCLK" "TCLK"
        .PCS_CH1_TX_SLAVE(PCS_CH1_TX_SLAVE),  // 1 为从通道，0 为主通道。
        .PCS_CH1_TX_GEAR_CLK_EN_SEL(PCS_CH1_TX_GEAR_CLK_EN_SEL),  // 使能选项：开启或关闭。
        .PCS_CH1_DATA_WIDTH_MODE           (PCS_CH1_DATA_WIDTH_MODE             ),// X20：20 位、40 位或 8b/10b 的 16/32 位；X16：16/32 位；X10：10 位或 8b/10b 的 8 位；X8：8 位。
        .PCS_CH1_TX_64B66B_67B(PCS_CH1_TX_64B66B_67B),  // 编码模式：普通、64b/66b 或 64b/67b。
        .PCS_CH1_GEAR_TCLK_SEL(PCS_CH1_GEAR_TCLK_SEL),  // 参数选项："PMA_TCLK" "TCLK2"
        .PCS_CH1_TX_TCLK2FABRIC_SEL        (PCS_CH1_TX_TCLK2FABRIC_SEL          ),// 32 位、40 位或 8b/10b 的 32 位数据使用 TRUE。
        .PCS_CH1_TX_OUTZZ(PCS_CH1_TX_OUTZZ),  // 1 用于 16/32 位，0 用于 20/40 位。
        .PCS_CH1_ENC_DUAL(PCS_CH1_ENC_DUAL),  // 使能选项：开启或关闭。
        .PCS_CH1_COMMA_REG1(PCS_CH1_COMMA_REG1),  // 字对齐逗号码的 10 位取值
        .PCS_CH1_RAPID_IMAX(PCS_CH1_RAPID_IMAX),  // 取值范围：0～7。
        .PCS_CH1_RAPID_VMIN_1(PCS_CH1_RAPID_VMIN_1),  // 取值范围：0～255。
        .PCS_CH1_RAPID_VMIN_2(PCS_CH1_RAPID_VMIN_2),  // 取值范围：0～255。
        .PCS_CH1_MASTER_CHECK_OFFSET(PCS_CH1_MASTER_CHECK_OFFSET),  // 用于通道绑定
        .PCS_CH1_DELAY_SET(PCS_CH1_DELAY_SET),  // 默认值由主通道编号决定。
        .PCS_CH1_SEACH_OFFSET              (PCS_CH1_SEACH_OFFSET                ),// 通道绑定范围为 20～70 位，间隔 10 位；对齐范围 81 UI。
        .PCS_CH1_CEB_RAPIDLS_MMAX(PCS_CH1_CEB_RAPIDLS_MMAX),  // 取值范围：0～7。
        .PCS_CH1_PMA_TX2RX_PLOOP_EN(PCS_CH1_PMA_TX2RX_PLOOP_EN),  // 使能选项：开启或关闭。
        .PCS_CH1_PMA_TX2RX_SLOOP_EN(PCS_CH1_PMA_TX2RX_SLOOP_EN),  // 使能选项：开启或关闭。
        .PCS_CH1_PMA_RX2TX_PLOOP_EN(PCS_CH1_PMA_RX2TX_PLOOP_EN),  // 使能选项：开启或关闭。
        .PCS_CH2_BYPASS_WORD_ALIGN(PCS_CH2_BYPASS_WORD_ALIGN),  // 字对齐旁路使能
        .PCS_CH2_BYPASS_DENC(PCS_CH2_BYPASS_DENC),  // 8b/10b 解码旁路使能
        .PCS_CH2_BYPASS_BONDING(PCS_CH2_BYPASS_BONDING),  // 通道绑定旁路使能
        .PCS_CH2_BYPASS_CTC(PCS_CH2_BYPASS_CTC),  // 时钟补偿旁路使能
        .PCS_CH2_BYPASS_GEAR(PCS_CH2_BYPASS_GEAR),  // 使能选项：开启或关闭。
        .PCS_CH2_BYPASS_BRIDGE(PCS_CH2_BYPASS_BRIDGE),  // 接收桥接单元旁路使能
        .PCS_CH2_BYPASS_BRIDGE_FIFO(PCS_CH2_BYPASS_BRIDGE_FIFO),  // 接收桥接 FIFO 旁路使能
        .PCS_CH2_DATA_MODE(PCS_CH2_DATA_MODE),  // 数据宽度：8、10、16 或 20 位。
        .PCS_CH2_ALIGN_MODE(PCS_CH2_ALIGN_MODE),  // 协议模式：1GB、10GB、RAPIDIO 或外部模式。
        .PCS_CH2_SAMP_16B(PCS_CH2_SAMP_16B),  // X16 用于 8、16、32 位数据，X20 用于其他位宽。
        .PCS_CH2_COMMA_REG0(PCS_CH2_COMMA_REG0),  // 字对齐逗号码的 10 位取值
        .PCS_CH2_COMMA_MASK(PCS_CH2_COMMA_MASK),  // 通道 2 两个逗号码寄存器的比较掩码
        .PCS_CH2_CEB_MODE(PCS_CH2_CEB_MODE),  // 选择 10GB、RAPIDIO 或外部通道绑定状态机。
        .PCS_CH2_CTC_MODE                  (PCS_CH2_CTC_MODE                    ),// 跳过字符增删数量：00 为 1，01 为 2，10 保留，11 为 4。
        .PCS_CH2_A_REG(PCS_CH2_A_REG),  // 8 位通道绑定特殊码
        .PCS_CH2_GE_AUTO_EN(PCS_CH2_GE_AUTO_EN),  // GE 模式下将 C 字符转换为 I2 字符以支持时钟补偿。
        .PCS_CH2_SKIP_REG0(PCS_CH2_SKIP_REG0),  // 第一个 10 位跳过字符
        .PCS_CH2_SKIP_REG1(PCS_CH2_SKIP_REG1),  // 第二个 10 位跳过字符
        .PCS_CH2_SKIP_REG2(PCS_CH2_SKIP_REG2),  // 第三个 10 位跳过字符
        .PCS_CH2_SKIP_REG3(PCS_CH2_SKIP_REG3),  // 第四个 10 位跳过字符
        .PCS_CH2_DEC_DUAL(PCS_CH2_DEC_DUAL),  // 8b/10b 解码配置：选择双解码器或单解码器。
        .PCS_CH2_SPLIT                     (PCS_CH2_SPLIT                       ),// TRUE 用于 8 位、10 位或 8b/10b 的 8 位数据，其余位宽为 FALSE。
        .PCS_CH2_COMMA_DET_MODE(PCS_CH2_COMMA_DET_MODE),  // 参数选项："RX_CLK_SLIP" "COMMA_PATTERN"
        .PCS_CH2_PCS_RCLK_SEL              (PCS_CH2_PCS_RCLK_SEL                ),// 编码 00 选 pma_rclk，01 选 pma_tclk，10 选 mcb_rclk，11 保留；本项不使用 01。
        .PCS_CH2_CB_RCLK_SEL               (PCS_CH2_CB_RCLK_SEL                 ),// 编码 00 选 pma_rclk，01 选 pma_tclk，10 选 mcb_rclk，11 保留；本项不使用 01。
        .PCS_CH2_AFTER_CTC_RCLK_SEL        (PCS_CH2_AFTER_CTC_RCLK_SEL          ),// 编码 00 选 pma_rclk，01 选 pma_tclk，10 选 mcb_rclk，11 保留。
        .PCS_CH2_PCS_RCLK_EN               (PCS_CH2_PCS_RCLK_EN                 ),// TRUE 用于 8 位、10 位或 8b/10b 的 8 位数据，其余位宽为 FALSE。
        .PCS_CH2_CB_RCLK_EN                (PCS_CH2_CB_RCLK_EN                  ),// TRUE 用于 8 位、10 位或 8b/10b 的 8 位数据，其余位宽为 FALSE。
        .PCS_CH2_AFTER_CTC_RCLK_EN         (PCS_CH2_AFTER_CTC_RCLK_EN           ),// TRUE 用于 8 位、10 位或 8b/10b 的 8 位数据，其余位宽为 FALSE。
        .PCS_CH2_AFTER_CTC_RCLK_EN_GB      (PCS_CH2_AFTER_CTC_RCLK_EN_GB        ),// TRUE 用于 32 位、40 位或 8b/10b 的 32 位数据，其余位宽为 FALSE。
        .PCS_CH2_SLAVE(PCS_CH2_SLAVE),  // 1 为从通道，0 为主通道。
        .PCS_CH2_PCIE_SLAVE(PCS_CH2_PCIE_SLAVE),  // 1 为从通道，0 为主通道。
        .PCS_CH2_RX_64B66B_67B(PCS_CH2_RX_64B66B_67B),  // 编码模式：普通、64b/66b 或 64b/67b。
        .PCS_CH2_TX_BRIDGE_GEAR_SEL        (PCS_CH2_TX_BRIDGE_GEAR_SEL          ),// TRUE 优先使用发送齿轮箱，FALSE 优先使用发送桥接单元。
        .PCS_CH2_TX_BYPASS_BRIDGE_UINT     (PCS_CH2_TX_BYPASS_BRIDGE_UINT       ),// TRUE 旁路发送桥，FALSE 使用发送桥。
        .PCS_CH2_TX_BYPASS_BRIDGE_FIFO     (PCS_CH2_TX_BYPASS_BRIDGE_FIFO       ),// TRUE 旁路发送桥 FIFO，FALSE 使用发送桥 FIFO。
        .PCS_CH2_TX_BYPASS_GEAR(PCS_CH2_TX_BYPASS_GEAR),  // 32 位、40 位或 8b/10b 的 32 位数据使用 FALSE。
        .PCS_CH2_TX_BYPASS_ENC(PCS_CH2_TX_BYPASS_ENC),  // 使能选项：开启或关闭。
        .PCS_CH2_TX_GEAR_SPLIT(PCS_CH2_TX_GEAR_SPLIT),  // 32 位、40 位或 8b/10b 的 32 位数据使用 TRUE。
        .PCS_CH2_TX_PCS_CLK_EN_SEL         (PCS_CH2_TX_PCS_CLK_EN_SEL           ),// 32 位、40 位或 8b/10b 的 32 位数据使用 TRUE。
        .PCS_CH2_TX_BRIDGE_TCLK_SEL(PCS_CH2_TX_BRIDGE_TCLK_SEL),  // 参数选项："PCS_TCLK" "TCLK"
        .PCS_CH2_PCS_TCLK_SEL(PCS_CH2_PCS_TCLK_SEL),  // 参数选项："PMA_TCLK" "TCLK"
        .PCS_CH2_TX_SLAVE(PCS_CH2_TX_SLAVE),  // 1 为从通道，0 为主通道。
        .PCS_CH2_TX_GEAR_CLK_EN_SEL(PCS_CH2_TX_GEAR_CLK_EN_SEL),  // 使能选项：开启或关闭。
        .PCS_CH2_DATA_WIDTH_MODE           (PCS_CH2_DATA_WIDTH_MODE             ),// X20：20 位、40 位或 8b/10b 的 16/32 位；X16：16/32 位；X10：10 位或 8b/10b 的 8 位；X8：8 位。
        .PCS_CH2_TX_64B66B_67B(PCS_CH2_TX_64B66B_67B),  // 编码模式：普通、64b/66b 或 64b/67b。
        .PCS_CH2_GEAR_TCLK_SEL(PCS_CH2_GEAR_TCLK_SEL),  // 参数选项："PMA_TCLK" "TCLK2"
        .PCS_CH2_TX_TCLK2FABRIC_SEL        (PCS_CH2_TX_TCLK2FABRIC_SEL          ),// 32 位、40 位或 8b/10b 的 32 位数据使用 TRUE。
        .PCS_CH2_TX_OUTZZ(PCS_CH2_TX_OUTZZ),  // 1 用于 16/32 位，0 用于 20/40 位。
        .PCS_CH2_ENC_DUAL(PCS_CH2_ENC_DUAL),  // 使能选项：开启或关闭。
        .PCS_CH2_COMMA_REG1(PCS_CH2_COMMA_REG1),  // 字对齐逗号码的 10 位取值
        .PCS_CH2_RAPID_IMAX(PCS_CH2_RAPID_IMAX),  // 取值范围：0～7。
        .PCS_CH2_RAPID_VMIN_1(PCS_CH2_RAPID_VMIN_1),  // 取值范围：0～255。
        .PCS_CH2_RAPID_VMIN_2(PCS_CH2_RAPID_VMIN_2),  // 取值范围：0～255。
        .PCS_CH2_MASTER_CHECK_OFFSET(PCS_CH2_MASTER_CHECK_OFFSET),  // 用于通道绑定
        .PCS_CH2_DELAY_SET(PCS_CH2_DELAY_SET),  // 默认值由主通道编号决定。
        .PCS_CH2_SEACH_OFFSET              (PCS_CH2_SEACH_OFFSET                ),// 通道绑定范围为 20～70 位，间隔 10 位；对齐范围 81 UI。
        .PCS_CH2_CEB_RAPIDLS_MMAX(PCS_CH2_CEB_RAPIDLS_MMAX),  // 取值范围：0～7。
        .PCS_CH2_PMA_TX2RX_PLOOP_EN(PCS_CH2_PMA_TX2RX_PLOOP_EN),  // 使能选项：开启或关闭。
        .PCS_CH2_PMA_TX2RX_SLOOP_EN(PCS_CH2_PMA_TX2RX_SLOOP_EN),  // 使能选项：开启或关闭。
        .PCS_CH2_PMA_RX2TX_PLOOP_EN(PCS_CH2_PMA_RX2TX_PLOOP_EN),  // 使能选项：开启或关闭。
        .PCS_CH3_BYPASS_WORD_ALIGN(PCS_CH3_BYPASS_WORD_ALIGN),  // 字对齐旁路使能
        .PCS_CH3_BYPASS_DENC(PCS_CH3_BYPASS_DENC),  // 8b/10b 解码旁路使能
        .PCS_CH3_BYPASS_BONDING(PCS_CH3_BYPASS_BONDING),  // 通道绑定旁路使能
        .PCS_CH3_BYPASS_CTC(PCS_CH3_BYPASS_CTC),  // 时钟补偿旁路使能
        .PCS_CH3_BYPASS_GEAR(PCS_CH3_BYPASS_GEAR),  // 使能选项：开启或关闭。
        .PCS_CH3_BYPASS_BRIDGE(PCS_CH3_BYPASS_BRIDGE),  // 接收桥接单元旁路使能
        .PCS_CH3_BYPASS_BRIDGE_FIFO(PCS_CH3_BYPASS_BRIDGE_FIFO),  // 接收桥接 FIFO 旁路使能
        .PCS_CH3_DATA_MODE(PCS_CH3_DATA_MODE),  // 数据宽度：8、10、16 或 20 位。
        .PCS_CH3_ALIGN_MODE(PCS_CH3_ALIGN_MODE),  // 协议模式：1GB、10GB、RAPIDIO 或外部模式。
        .PCS_CH3_SAMP_16B(PCS_CH3_SAMP_16B),  // X16 用于 8、16、32 位数据，X20 用于其他位宽。
        .PCS_CH3_COMMA_REG0(PCS_CH3_COMMA_REG0),  // 字对齐逗号码的 10 位取值
        .PCS_CH3_COMMA_MASK(PCS_CH3_COMMA_MASK),  // 通道 3 两个逗号码寄存器的比较掩码
        .PCS_CH3_CEB_MODE(PCS_CH3_CEB_MODE),  // 选择 10GB、RAPIDIO 或外部通道绑定状态机。
        .PCS_CH3_CTC_MODE                  (PCS_CH3_CTC_MODE                    ),// 跳过字符增删数量：00 为 1，01 为 2，10 保留，11 为 4。
        .PCS_CH3_A_REG(PCS_CH3_A_REG),  // 8 位通道绑定特殊码
        .PCS_CH3_GE_AUTO_EN(PCS_CH3_GE_AUTO_EN),  // GE 模式下将 C 字符转换为 I2 字符以支持时钟补偿。
        .PCS_CH3_SKIP_REG0(PCS_CH3_SKIP_REG0),  // 第一个 10 位跳过字符
        .PCS_CH3_SKIP_REG1(PCS_CH3_SKIP_REG1),  // 第二个 10 位跳过字符
        .PCS_CH3_SKIP_REG2(PCS_CH3_SKIP_REG2),  // 第三个 10 位跳过字符
        .PCS_CH3_SKIP_REG3(PCS_CH3_SKIP_REG3),  // 第四个 10 位跳过字符
        .PCS_CH3_DEC_DUAL(PCS_CH3_DEC_DUAL),  // 8b/10b 解码配置：选择双解码器或单解码器。
        .PCS_CH3_SPLIT                     (PCS_CH3_SPLIT                       ),// TRUE 用于 8 位、10 位或 8b/10b 的 8 位数据，其余位宽为 FALSE。
        .PCS_CH3_COMMA_DET_MODE(PCS_CH3_COMMA_DET_MODE),  // 参数选项："RX_CLK_SLIP" "COMMA_PATTERN"
        .PCS_CH3_PCS_RCLK_SEL              (PCS_CH3_PCS_RCLK_SEL                ),// 编码 00 选 pma_rclk，01 选 pma_tclk，10 选 mcb_rclk，11 保留；本项不使用 01。
        .PCS_CH3_CB_RCLK_SEL               (PCS_CH3_CB_RCLK_SEL                 ),// 编码 00 选 pma_rclk，01 选 pma_tclk，10 选 mcb_rclk，11 保留；本项不使用 01。
        .PCS_CH3_AFTER_CTC_RCLK_SEL        (PCS_CH3_AFTER_CTC_RCLK_SEL          ),// 编码 00 选 pma_rclk，01 选 pma_tclk，10 选 mcb_rclk，11 保留。
        .PCS_CH3_PCS_RCLK_EN               (PCS_CH3_PCS_RCLK_EN                 ),// TRUE 用于 8 位、10 位或 8b/10b 的 8 位数据，其余位宽为 FALSE。
        .PCS_CH3_CB_RCLK_EN                (PCS_CH3_CB_RCLK_EN                  ),// TRUE 用于 8 位、10 位或 8b/10b 的 8 位数据，其余位宽为 FALSE。
        .PCS_CH3_AFTER_CTC_RCLK_EN         (PCS_CH3_AFTER_CTC_RCLK_EN           ),// TRUE 用于 8 位、10 位或 8b/10b 的 8 位数据，其余位宽为 FALSE。
        .PCS_CH3_AFTER_CTC_RCLK_EN_GB      (PCS_CH3_AFTER_CTC_RCLK_EN_GB        ),// TRUE 用于 32 位、40 位或 8b/10b 的 32 位数据，其余位宽为 FALSE。
        .PCS_CH3_SLAVE(PCS_CH3_SLAVE),  // 1 为从通道，0 为主通道。
        .PCS_CH3_PCIE_SLAVE(PCS_CH3_PCIE_SLAVE),  // 1 为从通道，0 为主通道。
        .PCS_CH3_RX_64B66B_67B(PCS_CH3_RX_64B66B_67B),  // 编码模式：普通、64b/66b 或 64b/67b。
        .PCS_CH3_TX_BRIDGE_GEAR_SEL        (PCS_CH3_TX_BRIDGE_GEAR_SEL          ),// TRUE 优先使用发送齿轮箱，FALSE 优先使用发送桥接单元。
        .PCS_CH3_TX_BYPASS_BRIDGE_UINT     (PCS_CH3_TX_BYPASS_BRIDGE_UINT       ),// TRUE 旁路发送桥，FALSE 使用发送桥。
        .PCS_CH3_TX_BYPASS_BRIDGE_FIFO     (PCS_CH3_TX_BYPASS_BRIDGE_FIFO       ),// TRUE 旁路发送桥 FIFO，FALSE 使用发送桥 FIFO。
        .PCS_CH3_TX_BYPASS_GEAR(PCS_CH3_TX_BYPASS_GEAR),  // 32 位、40 位或 8b/10b 的 32 位数据使用 FALSE。
        .PCS_CH3_TX_BYPASS_ENC(PCS_CH3_TX_BYPASS_ENC),  // 使能选项：开启或关闭。
        .PCS_CH3_TX_GEAR_SPLIT(PCS_CH3_TX_GEAR_SPLIT),  // 32 位、40 位或 8b/10b 的 32 位数据使用 TRUE。
        .PCS_CH3_TX_PCS_CLK_EN_SEL         (PCS_CH3_TX_PCS_CLK_EN_SEL           ),// 32 位、40 位或 8b/10b 的 32 位数据使用 TRUE。
        .PCS_CH3_TX_BRIDGE_TCLK_SEL(PCS_CH3_TX_BRIDGE_TCLK_SEL),  // 参数选项："PCS_TCLK" "TCLK"
        .PCS_CH3_PCS_TCLK_SEL(PCS_CH3_PCS_TCLK_SEL),  // 参数选项："PMA_TCLK" "TCLK"
        .PCS_CH3_TX_SLAVE(PCS_CH3_TX_SLAVE),  // 1 为从通道，0 为主通道。
        .PCS_CH3_TX_GEAR_CLK_EN_SEL(PCS_CH3_TX_GEAR_CLK_EN_SEL),  // 使能选项：开启或关闭。
        .PCS_CH3_DATA_WIDTH_MODE           (PCS_CH3_DATA_WIDTH_MODE             ),// X20：20 位、40 位或 8b/10b 的 16/32 位；X16：16/32 位；X10：10 位或 8b/10b 的 8 位；X8：8 位。
        .PCS_CH3_TX_64B66B_67B(PCS_CH3_TX_64B66B_67B),  // 编码模式：普通、64b/66b 或 64b/67b。
        .PCS_CH3_GEAR_TCLK_SEL(PCS_CH3_GEAR_TCLK_SEL),  // 参数选项："PMA_TCLK" "TCLK2"
        .PCS_CH3_TX_TCLK2FABRIC_SEL        (PCS_CH3_TX_TCLK2FABRIC_SEL          ),// 32 位、40 位或 8b/10b 的 32 位数据使用 TRUE。
        .PCS_CH3_TX_OUTZZ(PCS_CH3_TX_OUTZZ),  // 1 用于 16/32 位，0 用于 20/40 位。
        .PCS_CH3_ENC_DUAL(PCS_CH3_ENC_DUAL),  // 使能选项：开启或关闭。
        .PCS_CH3_COMMA_REG1(PCS_CH3_COMMA_REG1),  // 字对齐逗号码的 10 位取值
        .PCS_CH3_RAPID_IMAX(PCS_CH3_RAPID_IMAX),  // 取值范围：0～7。
        .PCS_CH3_RAPID_VMIN_1(PCS_CH3_RAPID_VMIN_1),  // 取值范围：0～255。
        .PCS_CH3_RAPID_VMIN_2(PCS_CH3_RAPID_VMIN_2),  // 取值范围：0～255。
        .PCS_CH3_MASTER_CHECK_OFFSET(PCS_CH3_MASTER_CHECK_OFFSET),  // 用于通道绑定
        .PCS_CH3_DELAY_SET(PCS_CH3_DELAY_SET),  // 默认值由主通道编号决定。
        .PCS_CH3_SEACH_OFFSET              (PCS_CH3_SEACH_OFFSET                ),// 通道绑定范围为 20～70 位，间隔 10 位；对齐范围 81 UI。
        .PCS_CH3_CEB_RAPIDLS_MMAX(PCS_CH3_CEB_RAPIDLS_MMAX),  // 取值范围：0～7。
        .PCS_CH3_PMA_TX2RX_PLOOP_EN(PCS_CH3_PMA_TX2RX_PLOOP_EN),  // 使能选项：开启或关闭。
        .PCS_CH3_PMA_TX2RX_SLOOP_EN(PCS_CH3_PMA_TX2RX_SLOOP_EN),  // 使能选项：开启或关闭。
        .PCS_CH3_PMA_RX2TX_PLOOP_EN(PCS_CH3_PMA_RX2TX_PLOOP_EN),  // 使能选项：开启或关闭。

        .PMA_CH0_REG_TX_BUSWIDTH           (PMA_CH0_TXDATA_WIDTH                ),// 位宽编码：00 为 8 位，01 为 10 位，10 为 16 位，11 为 20 位。
        .PMA_CH0_REG_TX_BUSWIDTH_OW        (PMA_CH0_REG_TX_BUSWIDTH_OW          ),// TRUE 使用发送位宽寄存器，FALSE 使用 pma_tx_buswidth 端口。
        .PMA_CH0_REG_RX_BUSWIDTH           (PMA_CH0_SIPO_BIT_SETTING            ),// 位宽编码：00 为 8 位，01 为 10 位，10 为 16 位，11 为 20 位。
        .PMA_CH0_REG_RX_BUSWIDTH_EN        (PMA_CH0_REG_RX_BUSWIDTH_EN          ),// TRUE 使用接收位宽寄存器，FALSE 使用 pma_rx_buswidth 端口。
        .PMA_CH0_REG_RX_TERM_MODE_CTRL     (PMA_CH0_REG_RX_TERM_MODE_CTRL       ),// 终端编码范围 0～7；中间位选择交流或直流耦合，最低位选择悬空或接地终端。
        .PMA_CH0_REG_RX_RESERVED_361_354   (PMA_CH0_REG_RX_RESERVED_361_354     ),// 8 位配置：最高位为 1 时接 VDDA 终端，为 0 时禁用该终端。
        .PMA_CH0_REG_RX_HIGHZ(PMA_CH0_REG_RX_HIGHZ),  // 高阻终端控制：TRUE 启用，FALSE 禁用。
        .PMA_CH0_REG_RX_HIGHZ_EN(PMA_CH0_REG_RX_HIGHZ_EN),  // 从寄存器控制接收高阻状态。
        .PMA_CH0_REG_CDR_LOCK_TIMER        (PMA_CH0_REG_CDR_LOCK_TIMER          ),// 参数选项："0_8U" "1_2U" "1_6U" "2_4U" 3_2U" "4_8U" "12_8U" "25_6U"
        .PMA_CH0_REG_RX_RESERVED_353_346(PMA_CH0_REG_RX_RESERVED_353_346),  // 取值范围：0～255。
        .PMA_CH0_REG_CFG_POST(PMA_CH0_REG_CFG_POST),  // 发送去加重寄存器范围：0～31。
        .PMA_CH0_REG_TX_CFG_POST1(PMA_CH0_REG_CFG_POST1),  // 发送去加重寄存器范围：0～31。
        .PMA_CH0_REG_TX_CFG_POST2(PMA_CH0_REG_CFG_POST2),  // 发送去加重寄存器范围：0～31。
        .PMA_CH0_REG_TX_CFG_PRE(PMA_CH0_REG_TX_CFG_PRE),  // 发送去加重寄存器范围：0～31。
        .PMA_CH0_REG_PD_PRE(PMA_CH0_REG_PD_PRE),  // 使能选项：开启或关闭。
        .PMA_CH0_REG_TX_PD_POST(PMA_CH0_REG_TX_PD_POST),  // 使能选项：开启或关闭。
        .PMA_CH0_REG_TX_SATA_EN(PMA_CH0_REG_TX_SATA_EN),  // 使能选项：开启或关闭。
        .PMA_CH0_REG_OOB_COMWAKE_GAP_MIN(PMA_CH0_REG_OOB_COMWAKE_GAP_MIN),  // 取值范围：0～63。
        .PMA_CH0_REG_OOB_COMWAKE_GAP_MAX(PMA_CH0_REG_OOB_COMWAKE_GAP_MAX),  // 取值范围：0～63。
        .PMA_CH0_REG_OOB_COMINIT_GAP_MIN(PMA_CH0_REG_OOB_COMINIT_GAP_MIN),  // 取值范围：0～255。
        .PMA_CH0_REG_OOB_COMINIT_GAP_MAX(PMA_CH0_REG_OOB_COMINIT_GAP_MAX),  // 取值范围：0～255。
        .PMA_CH0_REG_TX_PRBS_GEN_WIDTH_SEL (PMA_CH0_REG_TX_PRBS_GEN_WIDTH_SEL   ),// 位宽选项：8、10、16 或 20 位。
        .PMA_CH0_REG_PRBS_CHK_WIDTH_SEL(PMA_CH0_REG_PRBS_CHK_WIDTH_SEL),  // 位宽选项：8、10、16 或 20 位。
        .PMA_CH0_REG_RX_SIGDET_VTH(PMA_CH0_REG_RX_SIGDET_VTH),  // 信号检测门限：45、54、63 或 72 mV。
        .PMA_CH0_REG_RX_DATAPATH_PD_EN(PMA_CH0_REG_RX_DATAPATH_PD_EN),  // 使能选项：开启或关闭。
        .PMA_CH1_REG_TX_BUSWIDTH           (PMA_CH1_TXDATA_WIDTH                ),// 位宽编码：00 为 8 位，01 为 10 位，10 为 16 位，11 为 20 位。
        .PMA_CH1_REG_TX_BUSWIDTH_OW        (PMA_CH1_REG_TX_BUSWIDTH_OW          ),// TRUE 使用发送位宽寄存器，FALSE 使用 pma_tx_buswidth 端口。
        .PMA_CH1_REG_RX_BUSWIDTH           (PMA_CH1_SIPO_BIT_SETTING            ),// 位宽编码：00 为 8 位，01 为 10 位，10 为 16 位，11 为 20 位。
        .PMA_CH1_REG_RX_BUSWIDTH_EN        (PMA_CH1_REG_RX_BUSWIDTH_EN          ),// TRUE 使用接收位宽寄存器，FALSE 使用 pma_rx_buswidth 端口。
        .PMA_CH1_REG_RX_TERM_MODE_CTRL     (PMA_CH1_REG_RX_TERM_MODE_CTRL       ),// 终端编码范围 0～7；中间位选择交流或直流耦合，最低位选择悬空或接地终端。
        .PMA_CH1_REG_RX_RESERVED_361_354   (PMA_CH1_REG_RX_RESERVED_361_354     ),// 8 位配置：最高位为 1 时接 VDDA 终端，为 0 时禁用该终端。
        .PMA_CH1_REG_RX_HIGHZ(PMA_CH1_REG_RX_HIGHZ),  // 高阻终端控制：TRUE 启用，FALSE 禁用。
        .PMA_CH1_REG_RX_HIGHZ_EN(PMA_CH1_REG_RX_HIGHZ_EN),  // 从寄存器控制接收高阻状态。
        .PMA_CH1_REG_CDR_LOCK_TIMER        (PMA_CH1_REG_CDR_LOCK_TIMER          ),// 参数选项："0_8U" "1_2U" "1_6U" "2_4U" 3_2U" "4_8U" "12_8U" "25_6U"
        .PMA_CH1_REG_RX_RESERVED_353_346(PMA_CH1_REG_RX_RESERVED_353_346),  // 取值范围：0～255。
        .PMA_CH1_REG_CFG_POST(PMA_CH1_REG_CFG_POST),  // 发送去加重寄存器范围：0～31。
        .PMA_CH1_REG_TX_CFG_POST1(PMA_CH1_REG_CFG_POST1),  // 发送去加重寄存器范围：0～31。
        .PMA_CH1_REG_TX_CFG_POST2(PMA_CH1_REG_CFG_POST2),  // 发送去加重寄存器范围：0～31。
        .PMA_CH1_REG_TX_CFG_PRE(PMA_CH1_REG_TX_CFG_PRE),  // 发送去加重寄存器范围：0～31。
        .PMA_CH1_REG_PD_PRE(PMA_CH1_REG_PD_PRE),  // 使能选项：开启或关闭。
        .PMA_CH1_REG_TX_PD_POST(PMA_CH1_REG_TX_PD_POST),  // 使能选项：开启或关闭。
        .PMA_CH1_REG_TX_SATA_EN(PMA_CH1_REG_TX_SATA_EN),  // 使能选项：开启或关闭。
        .PMA_CH1_REG_OOB_COMWAKE_GAP_MIN(PMA_CH1_REG_OOB_COMWAKE_GAP_MIN),  // 取值范围：0～63。
        .PMA_CH1_REG_OOB_COMWAKE_GAP_MAX(PMA_CH1_REG_OOB_COMWAKE_GAP_MAX),  // 取值范围：0～63。
        .PMA_CH1_REG_OOB_COMINIT_GAP_MIN(PMA_CH1_REG_OOB_COMINIT_GAP_MIN),  // 取值范围：0～255。
        .PMA_CH1_REG_OOB_COMINIT_GAP_MAX(PMA_CH1_REG_OOB_COMINIT_GAP_MAX),  // 取值范围：0～255。
        .PMA_CH1_REG_TX_PRBS_GEN_WIDTH_SEL (PMA_CH1_REG_TX_PRBS_GEN_WIDTH_SEL   ),// 位宽选项：8、10、16 或 20 位。
        .PMA_CH1_REG_PRBS_CHK_WIDTH_SEL(PMA_CH1_REG_PRBS_CHK_WIDTH_SEL),  // 位宽选项：8、10、16 或 20 位。
        .PMA_CH1_REG_RX_SIGDET_VTH(PMA_CH1_REG_RX_SIGDET_VTH),  // 信号检测门限：45、54、63 或 72 mV。
        .PMA_CH1_REG_RX_DATAPATH_PD_EN(PMA_CH1_REG_RX_DATAPATH_PD_EN),  // 使能选项：开启或关闭。
        .PMA_CH2_REG_TX_BUSWIDTH           (PMA_CH2_TXDATA_WIDTH                ),// 位宽编码：00 为 8 位，01 为 10 位，10 为 16 位，11 为 20 位。
        .PMA_CH2_REG_TX_BUSWIDTH_OW        (PMA_CH2_REG_TX_BUSWIDTH_OW          ),// TRUE 使用发送位宽寄存器，FALSE 使用 pma_tx_buswidth 端口。
        .PMA_CH2_REG_RX_BUSWIDTH           (PMA_CH2_SIPO_BIT_SETTING            ),// 位宽编码：00 为 8 位，01 为 10 位，10 为 16 位，11 为 20 位。
        .PMA_CH2_REG_RX_BUSWIDTH_EN        (PMA_CH2_REG_RX_BUSWIDTH_EN          ),// TRUE 使用接收位宽寄存器，FALSE 使用 pma_rx_buswidth 端口。
        .PMA_CH2_REG_RX_TERM_MODE_CTRL     (PMA_CH2_REG_RX_TERM_MODE_CTRL       ),// 终端编码范围 0～7；中间位选择交流或直流耦合，最低位选择悬空或接地终端。
        .PMA_CH2_REG_RX_RESERVED_361_354   (PMA_CH2_REG_RX_RESERVED_361_354     ),// 8 位配置：最高位为 1 时接 VDDA 终端，为 0 时禁用该终端。
        .PMA_CH2_REG_RX_HIGHZ(PMA_CH2_REG_RX_HIGHZ),  // 高阻终端控制：TRUE 启用，FALSE 禁用。
        .PMA_CH2_REG_RX_HIGHZ_EN(PMA_CH2_REG_RX_HIGHZ_EN),  // 从寄存器控制接收高阻状态。
        .PMA_CH2_REG_CDR_LOCK_TIMER        (PMA_CH2_REG_CDR_LOCK_TIMER          ),// 参数选项："0_8U" "1_2U" "1_6U" "2_4U" 3_2U" "4_8U" "12_8U" "25_6U"
        .PMA_CH2_REG_RX_RESERVED_353_346(PMA_CH2_REG_RX_RESERVED_353_346),  // 取值范围：0～255。
        .PMA_CH2_REG_CFG_POST(PMA_CH2_REG_CFG_POST),  // 发送去加重寄存器范围：0～31。
        .PMA_CH2_REG_TX_CFG_POST1(PMA_CH2_REG_CFG_POST1),  // 发送去加重寄存器范围：0～31。
        .PMA_CH2_REG_TX_CFG_POST2(PMA_CH2_REG_CFG_POST2),  // 发送去加重寄存器范围：0～31。
        .PMA_CH2_REG_TX_CFG_PRE(PMA_CH2_REG_TX_CFG_PRE),  // 发送去加重寄存器范围：0～31。
        .PMA_CH2_REG_PD_PRE(PMA_CH2_REG_PD_PRE),  // 使能选项：开启或关闭。
        .PMA_CH2_REG_TX_PD_POST(PMA_CH2_REG_TX_PD_POST),  // 使能选项：开启或关闭。
        .PMA_CH2_REG_TX_SATA_EN(PMA_CH2_REG_TX_SATA_EN),  // 使能选项：开启或关闭。
        .PMA_CH2_REG_OOB_COMWAKE_GAP_MIN(PMA_CH2_REG_OOB_COMWAKE_GAP_MIN),  // 取值范围：0～63。
        .PMA_CH2_REG_OOB_COMWAKE_GAP_MAX(PMA_CH2_REG_OOB_COMWAKE_GAP_MAX),  // 取值范围：0～63。
        .PMA_CH2_REG_OOB_COMINIT_GAP_MIN(PMA_CH2_REG_OOB_COMINIT_GAP_MIN),  // 取值范围：0～255。
        .PMA_CH2_REG_OOB_COMINIT_GAP_MAX(PMA_CH2_REG_OOB_COMINIT_GAP_MAX),  // 取值范围：0～255。
        .PMA_CH2_REG_TX_PRBS_GEN_WIDTH_SEL (PMA_CH2_REG_TX_PRBS_GEN_WIDTH_SEL   ),// 位宽选项：8、10、16 或 20 位。
        .PMA_CH2_REG_PRBS_CHK_WIDTH_SEL(PMA_CH2_REG_PRBS_CHK_WIDTH_SEL),  // 位宽选项：8、10、16 或 20 位。
        .PMA_CH2_REG_RX_SIGDET_VTH(PMA_CH2_REG_RX_SIGDET_VTH),  // 信号检测门限：45、54、63 或 72 mV。
        .PMA_CH2_REG_RX_DATAPATH_PD_EN(PMA_CH2_REG_RX_DATAPATH_PD_EN),  // 使能选项：开启或关闭。
        .PMA_CH3_REG_TX_BUSWIDTH           (PMA_CH3_TXDATA_WIDTH                ),// 位宽编码：00 为 8 位，01 为 10 位，10 为 16 位，11 为 20 位。
        .PMA_CH3_REG_TX_BUSWIDTH_OW        (PMA_CH3_REG_TX_BUSWIDTH_OW          ),// TRUE 使用发送位宽寄存器，FALSE 使用 pma_tx_buswidth 端口。
        .PMA_CH3_REG_RX_BUSWIDTH           (PMA_CH3_SIPO_BIT_SETTING            ),// 位宽编码：00 为 8 位，01 为 10 位，10 为 16 位，11 为 20 位。
        .PMA_CH3_REG_RX_BUSWIDTH_EN        (PMA_CH3_REG_RX_BUSWIDTH_EN          ),// TRUE 使用接收位宽寄存器，FALSE 使用 pma_rx_buswidth 端口。
        .PMA_CH3_REG_RX_TERM_MODE_CTRL     (PMA_CH3_REG_RX_TERM_MODE_CTRL       ),// 终端编码范围 0～7；中间位选择交流或直流耦合，最低位选择悬空或接地终端。
        .PMA_CH3_REG_RX_RESERVED_361_354   (PMA_CH3_REG_RX_RESERVED_361_354     ),// 8 位配置：最高位为 1 时接 VDDA 终端，为 0 时禁用该终端。
        .PMA_CH3_REG_RX_HIGHZ(PMA_CH3_REG_RX_HIGHZ),  // 高阻终端控制：TRUE 启用，FALSE 禁用。
        .PMA_CH3_REG_RX_HIGHZ_EN(PMA_CH3_REG_RX_HIGHZ_EN),  // 从寄存器控制接收高阻状态。
        .PMA_CH3_REG_CDR_LOCK_TIMER        (PMA_CH3_REG_CDR_LOCK_TIMER          ),// 参数选项："0_8U" "1_2U" "1_6U" "2_4U" 3_2U" "4_8U" "12_8U" "25_6U"
        .PMA_CH3_REG_RX_RESERVED_353_346(PMA_CH3_REG_RX_RESERVED_353_346),  // 取值范围：0～255。
        .PMA_CH3_REG_CFG_POST(PMA_CH3_REG_CFG_POST),  // 发送去加重寄存器范围：0～31。
        .PMA_CH3_REG_TX_CFG_POST1(PMA_CH3_REG_CFG_POST1),  // 发送去加重寄存器范围：0～31。
        .PMA_CH3_REG_TX_CFG_POST2(PMA_CH3_REG_CFG_POST2),  // 发送去加重寄存器范围：0～31。
        .PMA_CH3_REG_TX_CFG_PRE(PMA_CH3_REG_TX_CFG_PRE),  // 发送去加重寄存器范围：0～31。
        .PMA_CH3_REG_PD_PRE(PMA_CH3_REG_PD_PRE),  // 使能选项：开启或关闭。
        .PMA_CH3_REG_TX_PD_POST(PMA_CH3_REG_TX_PD_POST),  // 使能选项：开启或关闭。
        .PMA_CH3_REG_TX_SATA_EN(PMA_CH3_REG_TX_SATA_EN),  // 使能选项：开启或关闭。
        .PMA_CH3_REG_OOB_COMWAKE_GAP_MIN(PMA_CH3_REG_OOB_COMWAKE_GAP_MIN),  // 取值范围：0～63。
        .PMA_CH3_REG_OOB_COMWAKE_GAP_MAX(PMA_CH3_REG_OOB_COMWAKE_GAP_MAX),  // 取值范围：0～63。
        .PMA_CH3_REG_OOB_COMINIT_GAP_MIN(PMA_CH3_REG_OOB_COMINIT_GAP_MIN),  // 取值范围：0～255。
        .PMA_CH3_REG_OOB_COMINIT_GAP_MAX(PMA_CH3_REG_OOB_COMINIT_GAP_MAX),  // 取值范围：0～255。
        .PMA_CH3_REG_TX_PRBS_GEN_WIDTH_SEL (PMA_CH3_REG_TX_PRBS_GEN_WIDTH_SEL   ),// 位宽选项：8、10、16 或 20 位。
        .PMA_CH3_REG_PRBS_CHK_WIDTH_SEL(PMA_CH3_REG_PRBS_CHK_WIDTH_SEL),  // 位宽选项：8、10、16 或 20 位。
        .PMA_CH3_REG_RX_SIGDET_VTH(PMA_CH3_REG_RX_SIGDET_VTH),  // 信号检测门限：45、54、63 或 72 mV。
        .PMA_CH3_REG_RX_DATAPATH_PD_EN(PMA_CH3_REG_RX_DATAPATH_PD_EN),  // 使能选项：开启或关闭。

        .PMA_PLL0_PARM_PLL_POWERUP(PMA_PLL0_PARM_PLL_POWERUP),  // PLL0 使能：ON 启用，OFF 关闭。
        .PMA_PLL0_REG_PLL_LOCKDET_MODE(PMA_PLL0_REG_PLL_LOCKDET_MODE),  // 锁定模式
        .PMA_PLL0_REG_PLL_LOCKDET_FBCT(PMA_PLL0_REG_PLL_LOCKDET_FBCT),
        .PMA_PLL0_REG_PLL_LOCKDET_ITER(PMA_PLL0_REG_PLL_LOCKDET_ITER),
        .PMA_PLL0_REG_PLL_LOCKDET_REFCT(PMA_PLL0_REG_PLL_LOCKDET_REFCT),
        .PMA_PLL0_REG_PLL_REFDIV(PMA_PLL0_REG_PLL_REFDIV),
        .PMA_PLL0_REG_PLL_FBDIV(PMA_PLL0_REG_PLL_FBDIV),  // N1*N2
        .PMA_PLL0_REG_REFCLK_PAD_SEL       (PMA_PLL0_REG_REFCLK_PAD_SEL         ),// TRUE 使用逻辑数字时钟，FALSE 使用引脚参考时钟。
        .PMA_PLL1_PARM_PLL_POWERUP(PMA_PLL1_PARM_PLL_POWERUP),  // PLL0 使能：ON 启用，OFF 关闭。
        .PMA_PLL1_REG_PLL_LOCKDET_MODE(PMA_PLL1_REG_PLL_LOCKDET_MODE),  // 锁定模式
        .PMA_PLL1_REG_PLL_LOCKDET_FBCT(PMA_PLL1_REG_PLL_LOCKDET_FBCT),
        .PMA_PLL1_REG_PLL_LOCKDET_ITER(PMA_PLL1_REG_PLL_LOCKDET_ITER),
        .PMA_PLL1_REG_PLL_LOCKDET_REFCT(PMA_PLL1_REG_PLL_LOCKDET_REFCT),
        .PMA_PLL1_REG_PLL_REFDIV(PMA_PLL1_REG_PLL_REFDIV),
        .PMA_PLL1_REG_PLL_FBDIV(PMA_PLL1_REG_PLL_FBDIV),  // N1*N2
        .PMA_PLL1_REG_REFCLK_PAD_SEL       (PMA_PLL1_REG_REFCLK_PAD_SEL         ) // TRUE 使用逻辑数字时钟，FALSE 使用引脚参考时钟。

    ) U_GTP_HSSTLP_WRAPPER (

        .p_cfg_clk   (i_p_cfg_clk),
        .p_cfg_rst   (i_p_cfg_rst),
        .p_cfg_psel  (i_p_cfg_psel),
        .p_cfg_enable(i_p_cfg_enable),
        .p_cfg_write (i_p_cfg_write),
        .p_cfg_addr  (i_p_cfg_addr),
        .p_cfg_wdata (i_p_cfg_wdata),
        .p_cfg_rdata (o_p_cfg_rdata),
        .p_cfg_int   (o_p_cfg_int),
        .p_cfg_ready (o_p_cfg_ready),

        .P_PLLPOWERDOWN_0       (P_PLLPOWERDOWN_0),
        .P_PLL_RST_0            (P_PLL_RST_0),
        .P_RESCAL_RST_I_0       (P_RESCAL_RST_I_0),
        .P_LANE_SYNC_0          (P_LANE_SYNC_0),
        .P_RATE_CHANGE_TCLK_ON_0(P_RATE_CHANGE_TCLK_ON_0),

        .P_PLL_REF_CLK_0(1'b0),

        .P_REFCK2CORE_0(o_p_refck2core_0),
        .P_PLL_READY_0 (P_PLL_READY_0),

        .REFCLK_CML_N_0(i_p_refckn_0),
        .REFCLK_CML_P_0(i_p_refckp_0),

        .P_PLLPOWERDOWN_1       (P_PLLPOWERDOWN_1),
        .P_PLL_RST_1            (P_PLL_RST_1),
        .P_RESCAL_RST_I_1       (P_RESCAL_RST_I_1),
        .P_LANE_SYNC_1          (P_LANE_SYNC_1),
        .P_RATE_CHANGE_TCLK_ON_1(P_RATE_CHANGE_TCLK_ON_1),

        .P_PLL_REF_CLK_1(1'b0),

        .P_REFCK2CORE_1(o_p_refck2core_1),
        .P_PLL_READY_1 (P_PLL_READY_1),

        .P_TX_PMA_RST_0        (P_TX_PMA_RST_0),
        .P_TX_LANE_PD_CLKPATH_0(P_TX_LANE_PD_CLKPATH_0),
        .P_TX_LANE_PD_PISO_0   (P_TX_LANE_PD_PISO_0),
        .P_TX_LANE_PD_DRIVER_0 (P_TX_LANE_PD_DRIVER_0),
        .P_LANE_PD_0           (P_LANE_PD_0),
        .P_LANE_RST_0          (P_LANE_RST_0),
        .P_RX_LANE_PD_0        (P_RX_LANE_PD_0),
        .P_TCLK2FABRIC_0       (o_p_clk2core_tx_0),
        .P_TX_CLK_FR_CORE_0    (i_p_tx0_clk_fr_core),
        .P_TCLK2_FR_CORE_0     (i_p_tx0_clk2_fr_core),
        .P_RCLK2FABRIC_0       (o_p_clk2core_rx_0),
        .P_RX_CLK_FR_CORE_0    (i_p_rx0_clk_fr_core),
        .P_RCLK2_FR_CORE_0     (i_p_rx0_clk2_fr_core),
        .P_RX_PMA_RST_0        (P_RX_PMA_RST_0),
        .P_PCS_TX_RST_0        (P_PCS_TX_RST_0),
        .P_PCS_RX_RST_0        (P_PCS_RX_RST_0),
        .P_PCS_CB_RST_0        (P_PCS_CB_RST_0),
        .P_TX_MARGIN_0         (i_p_lx_margin_ctl_0),
        .P_TX_SWING_0          (i_p_lx_swing_ctl_0),
        .P_TX_DEEMP_0          (i_p_lx_deemp_ctl_0),
        .P_RX_HIGHZ_0          (i_p_rx_highz_0),
        .P_PCS_WORD_ALIGN_EN_0 (i_p_pcs_word_align_en_0),
        .P_RX_POLARITY_INVERT_0(i_p_rx_polarity_invert_0),
        .P_PCS_MCB_EXT_EN_0    (i_p_pcs_mcb_ext_en_0),
        .P_PCS_NEAREND_LOOP_0  (i_p_pcs_nearend_loop_0),
        .P_PCS_FAREND_LOOP_0   (i_p_pcs_farend_loop_0),
        .P_PMA_NEAREND_PLOOP_0 (i_p_pma_nearend_ploop_0),
        .P_PMA_NEAREND_SLOOP_0 (i_p_pma_nearend_sloop_0),
        .P_PMA_FAREND_PLOOP_0  (i_p_pma_farend_ploop_0),
        .P_TX_BEACON_EN_0      (i_p_tx_beacon_en_0),
        .P_RXGEAR_SLIP_0       (i_p_rxgear_slip_0),
        .P_TX_RATE_0           (P_TX_RATE_0),
        .P_RX_RATE_0           (P_RX_RATE_0),
        .P_RX_SIGDET_STATUS_0  (P_RX_SIGDET_STATUS_0),
        .P_RX_READY_0          (P_LX_CDR_ALIGN_0),
        .P_RX_SATA_COMINIT_0   (o_p_lx_oob_sta_0[0]),
        .P_RX_SATA_COMWAKE_0   (o_p_lx_oob_sta_0[1]),
        .P_TX_RXDET_REQ_0      (i_p_lx_rxdct_en_0),
        .P_TX_RXDET_STATUS_0   (o_p_lx_rxdct_out_0),
        .P_PCS_LSM_SYNCED_0    (P_PCS_LSM_SYNCED_0),
        .P_PCS_RX_MCB_STATUS_0 (P_PCS_RX_MCB_STATUS_0),
        .P_TDATA_0             (i_p_tdata_0),
        .P_RDATA_0             (o_p_rdata_0),
        .P_TX_SDN_0            (o_p_l0txn),
        .P_TX_SDP_0            (o_p_l0txp),

        .P_RX_SDN_0            (i_p_l0rxn),
        .P_RX_SDP_0            (i_p_l0rxp),
        .P_TX_PMA_RST_1        (P_TX_PMA_RST_1),
        .P_TX_LANE_PD_CLKPATH_1(P_TX_LANE_PD_CLKPATH_1),
        .P_TX_LANE_PD_PISO_1   (P_TX_LANE_PD_PISO_1),
        .P_TX_LANE_PD_DRIVER_1 (P_TX_LANE_PD_DRIVER_1),
        .P_LANE_PD_1           (P_LANE_PD_1),
        .P_LANE_RST_1          (P_LANE_RST_1),
        .P_RX_LANE_PD_1        (P_RX_LANE_PD_1),
        .P_TCLK2FABRIC_1       (o_p_clk2core_tx_1),
        .P_TX_CLK_FR_CORE_1    (i_p_tx1_clk_fr_core),
        .P_TCLK2_FR_CORE_1     (i_p_tx1_clk2_fr_core),
        .P_RCLK2FABRIC_1       (o_p_clk2core_rx_1),
        .P_RX_CLK_FR_CORE_1    (i_p_rx1_clk_fr_core),
        .P_RCLK2_FR_CORE_1     (i_p_rx1_clk2_fr_core),
        .P_RX_PMA_RST_1        (P_RX_PMA_RST_1),
        .P_PCS_TX_RST_1        (P_PCS_TX_RST_1),
        .P_PCS_RX_RST_1        (P_PCS_RX_RST_1),
        .P_PCS_CB_RST_1        (P_PCS_CB_RST_1),
        .P_TX_MARGIN_1         (i_p_lx_margin_ctl_1),
        .P_TX_SWING_1          (i_p_lx_swing_ctl_1),
        .P_TX_DEEMP_1          (i_p_lx_deemp_ctl_1),
        .P_RX_HIGHZ_1          (i_p_rx_highz_1),
        .P_PCS_WORD_ALIGN_EN_1 (i_p_pcs_word_align_en_1),
        .P_RX_POLARITY_INVERT_1(i_p_rx_polarity_invert_1),
        .P_PCS_MCB_EXT_EN_1    (i_p_pcs_mcb_ext_en_1),
        .P_PCS_NEAREND_LOOP_1  (i_p_pcs_nearend_loop_1),
        .P_PCS_FAREND_LOOP_1   (i_p_pcs_farend_loop_1),
        .P_PMA_NEAREND_PLOOP_1 (i_p_pma_nearend_ploop_1),
        .P_PMA_NEAREND_SLOOP_1 (i_p_pma_nearend_sloop_1),
        .P_PMA_FAREND_PLOOP_1  (i_p_pma_farend_ploop_1),
        .P_TX_BEACON_EN_1      (i_p_tx_beacon_en_1),
        .P_RXGEAR_SLIP_1       (i_p_rxgear_slip_1),
        .P_TX_RATE_1           (P_TX_RATE_1),
        .P_RX_RATE_1           (P_RX_RATE_1),
        .P_RX_SIGDET_STATUS_1  (P_RX_SIGDET_STATUS_1),
        .P_RX_READY_1          (P_LX_CDR_ALIGN_1),
        .P_RX_SATA_COMINIT_1   (o_p_lx_oob_sta_1[0]),
        .P_RX_SATA_COMWAKE_1   (o_p_lx_oob_sta_1[1]),
        .P_TX_RXDET_REQ_1      (i_p_lx_rxdct_en_1),
        .P_TX_RXDET_STATUS_1   (o_p_lx_rxdct_out_1),
        .P_PCS_LSM_SYNCED_1    (P_PCS_LSM_SYNCED_1),
        .P_PCS_RX_MCB_STATUS_1 (P_PCS_RX_MCB_STATUS_1),
        .P_TDATA_1             (i_p_tdata_1),
        .P_RDATA_1             (o_p_rdata_1),
        .P_TX_SDN_1            (o_p_l1txn),
        .P_TX_SDP_1            (o_p_l1txp),

        .P_RX_SDN_1            (i_p_l1rxn),
        .P_RX_SDP_1            (i_p_l1rxp),
        .P_TX_PMA_RST_2        (P_TX_PMA_RST_2),
        .P_TX_LANE_PD_CLKPATH_2(P_TX_LANE_PD_CLKPATH_2),
        .P_TX_LANE_PD_PISO_2   (P_TX_LANE_PD_PISO_2),
        .P_TX_LANE_PD_DRIVER_2 (P_TX_LANE_PD_DRIVER_2),
        .P_LANE_PD_2           (P_LANE_PD_2),
        .P_LANE_RST_2          (P_LANE_RST_2),
        .P_RX_LANE_PD_2        (P_RX_LANE_PD_2),
        .P_TCLK2FABRIC_2       (o_p_clk2core_tx_2),
        .P_TX_CLK_FR_CORE_2    (i_p_tx2_clk_fr_core),
        .P_TCLK2_FR_CORE_2     (i_p_tx2_clk2_fr_core),
        .P_RCLK2FABRIC_2       (o_p_clk2core_rx_2),
        .P_RX_CLK_FR_CORE_2    (i_p_rx2_clk_fr_core),
        .P_RCLK2_FR_CORE_2     (i_p_rx2_clk2_fr_core),
        .P_RX_PMA_RST_2        (P_RX_PMA_RST_2),
        .P_PCS_TX_RST_2        (P_PCS_TX_RST_2),
        .P_PCS_RX_RST_2        (P_PCS_RX_RST_2),
        .P_PCS_CB_RST_2        (P_PCS_CB_RST_2),
        .P_TX_MARGIN_2         (i_p_lx_margin_ctl_2),
        .P_TX_SWING_2          (i_p_lx_swing_ctl_2),
        .P_TX_DEEMP_2          (i_p_lx_deemp_ctl_2),
        .P_RX_HIGHZ_2          (i_p_rx_highz_2),
        .P_PCS_WORD_ALIGN_EN_2 (i_p_pcs_word_align_en_2),
        .P_RX_POLARITY_INVERT_2(i_p_rx_polarity_invert_2),
        .P_PCS_MCB_EXT_EN_2    (i_p_pcs_mcb_ext_en_2),
        .P_PCS_NEAREND_LOOP_2  (i_p_pcs_nearend_loop_2),
        .P_PCS_FAREND_LOOP_2   (i_p_pcs_farend_loop_2),
        .P_PMA_NEAREND_PLOOP_2 (i_p_pma_nearend_ploop_2),
        .P_PMA_NEAREND_SLOOP_2 (i_p_pma_nearend_sloop_2),
        .P_PMA_FAREND_PLOOP_2  (i_p_pma_farend_ploop_2),
        .P_TX_BEACON_EN_2      (i_p_tx_beacon_en_2),
        .P_RXGEAR_SLIP_2       (i_p_rxgear_slip_2),
        .P_TX_RATE_2           (P_TX_RATE_2),
        .P_RX_RATE_2           (P_RX_RATE_2),
        .P_RX_SIGDET_STATUS_2  (P_RX_SIGDET_STATUS_2),
        .P_RX_READY_2          (P_LX_CDR_ALIGN_2),
        .P_RX_SATA_COMINIT_2   (o_p_lx_oob_sta_2[0]),
        .P_RX_SATA_COMWAKE_2   (o_p_lx_oob_sta_2[1]),
        .P_TX_RXDET_REQ_2      (i_p_lx_rxdct_en_2),
        .P_TX_RXDET_STATUS_2   (o_p_lx_rxdct_out_2),
        .P_PCS_LSM_SYNCED_2    (P_PCS_LSM_SYNCED_2),
        .P_PCS_RX_MCB_STATUS_2 (P_PCS_RX_MCB_STATUS_2),
        .P_TDATA_2             (i_p_tdata_2),
        .P_RDATA_2             (o_p_rdata_2),
        .P_TX_SDN_2            (o_p_l2txn),
        .P_TX_SDP_2            (o_p_l2txp),

        .P_TX_PMA_RST_3        (P_TX_PMA_RST_3),
        .P_TX_LANE_PD_CLKPATH_3(P_TX_LANE_PD_CLKPATH_3),
        .P_TX_LANE_PD_PISO_3   (P_TX_LANE_PD_PISO_3),
        .P_TX_LANE_PD_DRIVER_3 (P_TX_LANE_PD_DRIVER_3),
        .P_LANE_PD_3           (P_LANE_PD_3),
        .P_LANE_RST_3          (P_LANE_RST_3),
        .P_RX_LANE_PD_3        (P_RX_LANE_PD_3),
        .P_TCLK2FABRIC_3       (o_p_clk2core_tx_3),
        .P_TX_CLK_FR_CORE_3    (i_p_tx3_clk_fr_core),
        .P_TCLK2_FR_CORE_3     (i_p_tx3_clk2_fr_core),
        .P_RCLK2FABRIC_3       (o_p_clk2core_rx_3),
        .P_RX_CLK_FR_CORE_3    (i_p_rx3_clk_fr_core),
        .P_RCLK2_FR_CORE_3     (i_p_rx3_clk2_fr_core),
        .P_RX_PMA_RST_3        (P_RX_PMA_RST_3),
        .P_PCS_TX_RST_3        (P_PCS_TX_RST_3),
        .P_PCS_RX_RST_3        (P_PCS_RX_RST_3),
        .P_PCS_CB_RST_3        (P_PCS_CB_RST_3),
        .P_TX_MARGIN_3         (i_p_lx_margin_ctl_3),
        .P_TX_SWING_3          (i_p_lx_swing_ctl_3),
        .P_TX_DEEMP_3          (i_p_lx_deemp_ctl_3),
        .P_RX_HIGHZ_3          (i_p_rx_highz_3),
        .P_PCS_WORD_ALIGN_EN_3 (i_p_pcs_word_align_en_3),
        .P_RX_POLARITY_INVERT_3(i_p_rx_polarity_invert_3),
        .P_PCS_MCB_EXT_EN_3    (i_p_pcs_mcb_ext_en_3),
        .P_PCS_NEAREND_LOOP_3  (i_p_pcs_nearend_loop_3),
        .P_PCS_FAREND_LOOP_3   (i_p_pcs_farend_loop_3),
        .P_PMA_NEAREND_PLOOP_3 (i_p_pma_nearend_ploop_3),
        .P_PMA_NEAREND_SLOOP_3 (i_p_pma_nearend_sloop_3),
        .P_PMA_FAREND_PLOOP_3  (i_p_pma_farend_ploop_3),
        .P_TX_BEACON_EN_3      (i_p_tx_beacon_en_3),
        .P_RXGEAR_SLIP_3       (i_p_rxgear_slip_3),
        .P_TX_RATE_3           (P_TX_RATE_3),
        .P_RX_RATE_3           (P_RX_RATE_3),
        .P_RX_SIGDET_STATUS_3  (P_RX_SIGDET_STATUS_3),
        .P_RX_READY_3          (P_LX_CDR_ALIGN_3),
        .P_RX_SATA_COMINIT_3   (o_p_lx_oob_sta_3[0]),
        .P_RX_SATA_COMWAKE_3   (o_p_lx_oob_sta_3[1]),
        .P_TX_RXDET_REQ_3      (i_p_lx_rxdct_en_3),
        .P_TX_RXDET_STATUS_3   (o_p_lx_rxdct_out_3),
        .P_PCS_LSM_SYNCED_3    (P_PCS_LSM_SYNCED_3),
        .P_PCS_RX_MCB_STATUS_3 (P_PCS_RX_MCB_STATUS_3),
        .P_TDATA_3             (i_p_tdata_3),
        .P_RDATA_3             (o_p_rdata_3),

        .P_TX_SDN_3(o_p_l3txn),
        .P_TX_SDP_3(o_p_l3txp)
    );

endmodule
