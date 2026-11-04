//---------------------------------------------------

// Copyright (c) 2014 PANGO MICROSYSTEMS, INC
// ALL RIGHTS REVERVED.

// THE SOURCE CODE CONTAINED HEREIN IS PROPRIETARY TO PANGO MICROSYSTEMS, INC.
// IT SHALL NOT BE REPRODUCED OR DISCLOSED IN WHOLE OR IN PART OR USED BY
// PARTIES WITHOUT WRITTEN AUTHORIZATION FROM THE OWNER.

//---------------------------------------------------

//---------------------------------------------------

`timescale 1 ns / 1 ps

module ipm_distributed_sdpram_v1_2 #(
    parameter ADDR_WIDTH  = 6,        // 地址宽度范围：4～10
    parameter DATA_WIDTH  = 64,       // 数据宽度范围：1～256
    parameter RST_TYPE    = "ASYNC",  // 复位类型：ASYNC 异步，SYNC 同步。
    parameter OUT_REG     = 0,
    parameter INIT_FILE   = "NONE",   // 初始化文件：NONE 表示不使用文件，否则填写文件名。
    parameter FILE_FORMAT = "BIN"     // 初始化数据格式：BIN 二进制，HEX 十六进制。
) (
    input  wire [DATA_WIDTH-1:0] wr_data,
    input  wire [ADDR_WIDTH-1:0] wr_addr,
    input  wire [ADDR_WIDTH-1:0] rd_addr,
    input  wire                  wr_clk,
    input  wire                  rd_clk,
    input  wire                  wr_en,
    input  wire                  rst,
    output wire [DATA_WIDTH-1:0] rd_data
)  /* synthesis syn_ramstyle = "select_ram" */;

    wire                  asyn_rst;
    wire                  syn_rst;
    wire [DATA_WIDTH-1:0] q;
    reg  [DATA_WIDTH-1:0] q_reg;

    reg  [DATA_WIDTH-1:0] mem      [2**ADDR_WIDTH-1:0];

    // 复位控制
    assign asyn_rst = (RST_TYPE == "ASYNC") ? rst : 0;
    assign syn_rst  = (RST_TYPE == "SYNC") ? rst : 0;

    // 简单双口 RAM 初始化
    generate
        integer i, j;
        if (INIT_FILE != "NONE") begin
            if (FILE_FORMAT == "BIN") begin
                initial begin
                    $readmemb(INIT_FILE, mem);
                end
            end else if (FILE_FORMAT == "HEX") begin
                initial begin
                    $readmemh(INIT_FILE, mem);
                end
            end
        end else begin
            initial begin
                for (i = 0; i < 2 ** ADDR_WIDTH; i = i + 1) begin
                    for (j = 0; j < DATA_WIDTH; j = j + 1) begin
                        mem[i][j] = 1'b0;
                    end
                end
            end
        end
    endgenerate

    // 读写控制
    generate
        always @(posedge wr_clk) begin
            if (wr_en) mem[wr_addr] <= wr_data;
        end

        assign q = mem[rd_addr];

        if (RST_TYPE == "ASYNC") begin
            always @(posedge rd_clk or posedge asyn_rst) begin
                if (asyn_rst) q_reg <= {DATA_WIDTH{1'b0}};
                else q_reg <= q;
            end
        end else if (RST_TYPE == "SYNC") begin
            always @(posedge rd_clk) begin
                if (syn_rst) q_reg <= {DATA_WIDTH{1'b0}};
                else q_reg <= q;
            end
        end
    endgenerate

    assign rd_data = (OUT_REG == 1) ? q_reg : q;

endmodule
