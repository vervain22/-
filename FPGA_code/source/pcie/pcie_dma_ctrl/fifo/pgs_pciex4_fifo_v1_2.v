//---------------------------------------------------
// Copyright (c) 2015 PANGO MICROSYSTEMS, INC
// ALL RIGHTS REVERVED.
//---------------------------------------------------

`timescale 1ns / 1ps

module pgs_pciex4_fifo_v1_2 #(
    parameter ADDR_WIDTH = 10,  // FIFO 地址位宽：4～10
    parameter DATA_WIDTH = 32,  // 写数据位宽：1～256
    parameter OUT_REG    = 0
) (
    input clk,
    input rst_n,

    input  [DATA_WIDTH-1 : 0] wr_data,
    input                     wr_en,
    output                    full,

    output [DATA_WIDTH-1 : 0] rd_data,
    input                     rd_en,
    output                    empty
);

    wire [ADDR_WIDTH-1 : 0] wr_addr;
    wire [ADDR_WIDTH-1 : 0] rd_addr;
    wire                    wr_en_tmp;
    wire                    rd_en_tmp;

    assign wr_en_tmp = wr_en & (~full);
    assign rd_en_tmp = rd_en & (~empty);

    // 简单双口 RAM 例化
    ipm_distributed_sdpram_v1_2_distributed_fifo #(
        .ADDR_WIDTH(ADDR_WIDTH),  // 地址宽度范围：4～10
        .DATA_WIDTH(DATA_WIDTH),  // 数据位宽范围：4～256
        .RST_TYPE  ("ASYNC"),     // 复位类型：ASYNC_RESET 异步，SYNC_RESET 同步。
        .OUT_REG   (OUT_REG)
    ) ipm_distributed_sdpram_distributed_fifo (
        .wr_data(wr_data),
        .wr_addr(wr_addr),
        .rd_addr(rd_addr),
        .wr_clk (clk),
        .rd_clk (clk),
        .wr_en  (wr_en_tmp),
        .rst    (~rst_n),
        .rd_data(rd_data)
    );

    pgs_pciex4_fifo_ctrl #(
        .ADDR_WIDTH(ADDR_WIDTH)
    ) pgs_pciex4_fifo_ctrl (
        .clk    (clk),        // 写时钟
        .w_en   (wr_en_tmp),  // 写使能，高电平有效。
        .wr_addr(wr_addr),    // 写地址及写端复位
        .wfull  (full),       // 写满标志，高电平有效。
        .r_en   (rd_en_tmp),  // 读使能，高电平有效。
        .rd_addr(rd_addr),    // 读地址
        .rst_n  (rst_n),      // 读端复位
        .rempty (empty)       // 读空标志，高电平有效。
    );

endmodule
