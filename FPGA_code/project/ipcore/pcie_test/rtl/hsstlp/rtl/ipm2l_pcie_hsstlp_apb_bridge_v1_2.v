//---------------------------------------------------

// Copyright (c) 2019 PANGO MICROSYSTEMS, INC
// ALL RIGHTS REVERVED.

// THE SOURCE CODE CONTAINED HEREIN IS PROPRIETARY TO PANGO MICROSYSTEMS, INC.
// IT SHALL NOT BE REPRODUCED OR DISCLOSED IN WHOLE OR IN PART OR USED BY
// PARTIES WITHOUT WRITTEN AUTHORIZATION FROM THE OWNER.

//---------------------------------------------------

//---------------------------------------------------
`timescale 1ns / 100fs

module ipm2l_hsstlp_apb_bridge_v1_2 #(
    // 全局参数
    parameter PLL0_EN     = "FALSE",  // PLL0 使能
    parameter PLL1_EN     = "FALSE",  // PLL1 使能
    parameter CHANNEL0_EN = "FALSE",  // 通道 0 使能。
    parameter CHANNEL1_EN = "FALSE",  // 通道 1 使能。
    parameter CHANNEL2_EN = "FALSE",  // 通道 2 使能。
    parameter CHANNEL3_EN = "FALSE"   // 通道 3 使能。
) (
    // 逻辑侧端口
    input  wire        p_cfg_clk,
    input  wire        p_cfg_rst,
    input  wire        p_cfg_psel,
    input  wire        p_cfg_enable,
    input  wire        p_cfg_write,
    input  wire [15:0] p_cfg_addr,
    input  wire [ 7:0] p_cfg_wdata,
    output reg         p_cfg_ready,
    output reg  [ 7:0] p_cfg_rdata,
    output reg         p_cfg_int,
    // PLL0 端口
    input  wire        P_CFG_READY_PLL_0,
    input  wire [ 7:0] P_CFG_RDATA_PLL_0,
    input  wire        P_CFG_INT_PLL_0,
    output wire        P_CFG_RST_PLL_0,
    output wire        P_CFG_CLK_PLL_0,
    output reg         P_CFG_PSEL_PLL_0,
    output reg         P_CFG_ENABLE_PLL_0,
    output reg         P_CFG_WRITE_PLL_0,
    output wire [11:0] P_CFG_ADDR_PLL_0,
    output wire [ 7:0] P_CFG_WDATA_PLL_0,
    // PLL1 端口
    input  wire        P_CFG_READY_PLL_1,
    input  wire [ 7:0] P_CFG_RDATA_PLL_1,
    input  wire        P_CFG_INT_PLL_1,
    output wire        P_CFG_RST_PLL_1,
    output wire        P_CFG_CLK_PLL_1,
    output reg         P_CFG_PSEL_PLL_1,
    output reg         P_CFG_ENABLE_PLL_1,
    output reg         P_CFG_WRITE_PLL_1,
    output wire [11:0] P_CFG_ADDR_PLL_1,
    output wire [ 7:0] P_CFG_WDATA_PLL_1,
    // 通道 0 端口
    input  wire        P_CFG_READY_0,
    input  wire [ 7:0] P_CFG_RDATA_0,
    input  wire        P_CFG_INT_0,
    output wire        P_CFG_CLK_0,
    output wire        P_CFG_RST_0,
    output reg         P_CFG_PSEL_0,
    output reg         P_CFG_ENABLE_0,
    output reg         P_CFG_WRITE_0,
    output wire [11:0] P_CFG_ADDR_0,
    output wire [ 7:0] P_CFG_WDATA_0,
    // 通道 1 端口
    input  wire        P_CFG_READY_1,
    input  wire [ 7:0] P_CFG_RDATA_1,
    input  wire        P_CFG_INT_1,
    output wire        P_CFG_CLK_1,
    output wire        P_CFG_RST_1,
    output reg         P_CFG_PSEL_1,
    output reg         P_CFG_ENABLE_1,
    output reg         P_CFG_WRITE_1,
    output wire [11:0] P_CFG_ADDR_1,
    output wire [ 7:0] P_CFG_WDATA_1,
    // 通道 2 端口
    input  wire        P_CFG_READY_2,
    input  wire [ 7:0] P_CFG_RDATA_2,
    input  wire        P_CFG_INT_2,
    output wire        P_CFG_CLK_2,
    output wire        P_CFG_RST_2,
    output reg         P_CFG_PSEL_2,
    output reg         P_CFG_ENABLE_2,
    output reg         P_CFG_WRITE_2,
    output wire [11:0] P_CFG_ADDR_2,
    output wire [ 7:0] P_CFG_WDATA_2,
    // 通道 3 端口
    input  wire        P_CFG_READY_3,
    input  wire [ 7:0] P_CFG_RDATA_3,
    input  wire        P_CFG_INT_3,
    output wire        P_CFG_CLK_3,
    output wire        P_CFG_RST_3,
    output reg         P_CFG_PSEL_3,
    output reg         P_CFG_ENABLE_3,
    output reg         P_CFG_WRITE_3,
    output wire [11:0] P_CFG_ADDR_3,
    output wire [ 7:0] P_CFG_WDATA_3
);

    // 主逻辑

    // 配置时钟与复位
    assign P_CFG_CLK_PLL_0   = p_cfg_clk;
    assign P_CFG_CLK_PLL_1   = p_cfg_clk;
    assign P_CFG_CLK_0       = p_cfg_clk;
    assign P_CFG_CLK_1       = p_cfg_clk;
    assign P_CFG_CLK_2       = p_cfg_clk;
    assign P_CFG_CLK_3       = p_cfg_clk;

    assign P_CFG_RST_PLL_0   = p_cfg_rst;
    assign P_CFG_RST_PLL_1   = p_cfg_rst;
    assign P_CFG_RST_0       = p_cfg_rst;
    assign P_CFG_RST_1       = p_cfg_rst;
    assign P_CFG_RST_2       = p_cfg_rst;
    assign P_CFG_RST_3       = p_cfg_rst;

    assign P_CFG_ADDR_PLL_0  = p_cfg_addr[11:0];
    assign P_CFG_WDATA_PLL_0 = p_cfg_wdata;
    assign P_CFG_ADDR_PLL_1  = p_cfg_addr[11:0];
    assign P_CFG_WDATA_PLL_1 = p_cfg_wdata;
    assign P_CFG_ADDR_0      = p_cfg_addr[11:0];
    assign P_CFG_WDATA_0     = p_cfg_wdata;
    assign P_CFG_ADDR_1      = p_cfg_addr[11:0];
    assign P_CFG_WDATA_1     = p_cfg_wdata;
    assign P_CFG_ADDR_2      = p_cfg_addr[11:0];
    assign P_CFG_WDATA_2     = p_cfg_wdata;
    assign P_CFG_ADDR_3      = p_cfg_addr[11:0];
    assign P_CFG_WDATA_3     = p_cfg_wdata;

    always @(*) begin
        P_CFG_PSEL_PLL_0   = 1'b0;
        P_CFG_ENABLE_PLL_0 = 1'b0;
        P_CFG_WRITE_PLL_0  = 1'b0;
        P_CFG_PSEL_PLL_1   = 1'b0;
        P_CFG_ENABLE_PLL_1 = 1'b0;
        P_CFG_WRITE_PLL_1  = 1'b0;
        P_CFG_PSEL_0       = 1'b0;
        P_CFG_ENABLE_0     = 1'b0;
        P_CFG_WRITE_0      = 1'b0;
        P_CFG_PSEL_1       = 1'b0;
        P_CFG_ENABLE_1     = 1'b0;
        P_CFG_WRITE_1      = 1'b0;
        P_CFG_PSEL_2       = 1'b0;
        P_CFG_ENABLE_2     = 1'b0;
        P_CFG_WRITE_2      = 1'b0;
        P_CFG_PSEL_3       = 1'b0;
        P_CFG_ENABLE_3     = 1'b0;
        P_CFG_WRITE_3      = 1'b0;
        p_cfg_ready        = 1'b0;
        p_cfg_rdata        = 8'b0;
        p_cfg_int          = 1'b0;
        case (p_cfg_addr[15:12])
            4'b0000: begin
                P_CFG_PSEL_0   = p_cfg_psel;
                P_CFG_ENABLE_0 = p_cfg_enable;
                P_CFG_WRITE_0  = p_cfg_write;
                p_cfg_ready    = CHANNEL0_EN == "FALSE" ? 1'b1 : P_CFG_READY_0;
                p_cfg_rdata    = P_CFG_RDATA_0;
            end
            4'b0001: begin
                P_CFG_PSEL_1   = p_cfg_psel;
                P_CFG_ENABLE_1 = p_cfg_enable;
                P_CFG_WRITE_1  = p_cfg_write;
                p_cfg_ready    = CHANNEL1_EN == "FALSE" ? 1'b1 : P_CFG_READY_1;
                p_cfg_rdata    = P_CFG_RDATA_1;
            end
            4'b0010: begin
                P_CFG_PSEL_2   = p_cfg_psel;
                P_CFG_ENABLE_2 = p_cfg_enable;
                P_CFG_WRITE_2  = p_cfg_write;
                p_cfg_ready    = CHANNEL2_EN == "FALSE" ? 1'b1 : P_CFG_READY_2;
                p_cfg_rdata    = P_CFG_RDATA_2;
            end
            4'b0011: begin
                P_CFG_PSEL_3   = p_cfg_psel;
                P_CFG_ENABLE_3 = p_cfg_enable;
                P_CFG_WRITE_3  = p_cfg_write;
                p_cfg_ready    = CHANNEL3_EN == "FALSE" ? 1'b1 : P_CFG_READY_3;
                p_cfg_rdata    = P_CFG_RDATA_3;
            end
            4'b0100: begin
                P_CFG_PSEL_PLL_0   = p_cfg_psel;
                P_CFG_ENABLE_PLL_0 = p_cfg_enable;
                P_CFG_WRITE_PLL_0  = p_cfg_write;
                p_cfg_ready        = PLL0_EN == "FALSE" ? 1'b1 : P_CFG_READY_PLL_0;
                p_cfg_rdata        = P_CFG_RDATA_PLL_0;
            end
            4'b0101: begin
                P_CFG_PSEL_PLL_1   = p_cfg_psel;
                P_CFG_ENABLE_PLL_1 = p_cfg_enable;
                P_CFG_WRITE_PLL_1  = p_cfg_write;
                p_cfg_ready        = PLL1_EN == "FALSE" ? 1'b1 : P_CFG_READY_PLL_1;
                p_cfg_rdata        = P_CFG_RDATA_PLL_1;
            end
        endcase
    end

endmodule
