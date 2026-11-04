//---------------------------------------------------

// Copyright (c) 2019 PANGO MICROSYSTEMS, INC
// ALL RIGHTS REVERVED.

// THE SOURCE CODE CONTAINED HEREIN IS PROPRIETARY TO PANGO MICROSYSTEMS, INC.
// IT SHALL NOT BE REPRODUCED OR DISCLOSED IN WHOLE OR IN PART OR USED BY
// PARTIES WITHOUT WRITTEN AUTHORIZATION FROM THE OWNER.

//---------------------------------------------------

//---------------------------------------------------
module ips2l_pcie_dma_rx_cpld_wr_ctrl #(
    parameter ADDR_WIDTH = 4'd9
) (
    input                        clk,                    // 接口时钟：第一代 62.5 MHz，第二代 125 MHz。
    input                        rst_n,
    input       [           2:0] i_cfg_max_rd_req_size,
    //---------------------------------------------------
    input                        i_cpld_wr_start,
    input       [           9:0] i_cpld_length,
    input       [           6:0] i_cpld_low_addr,
    input       [          11:0] i_cpld_byte_cnt,
    input       [         127:0] i_cpld_data,
    input       [           3:0] i_cpld_dw_vld,
    input       [           7:0] i_cpld_tag,
    input       [           1:0] i_bar_hit,
    input                        i_multicpld_flag,
    //---------------------------------------------------
    // RAM 写控制
    output wire                  o_cpld_wr_en,
    output wire [ADDR_WIDTH-1:0] o_cpld_wr_addr,
    output wire [         127:0] o_cpld_wr_data,
    output wire [          15:0] o_cpld_wr_be,
    output wire [           1:0] o_cpld_wr_bar_hit
);

    reg         wr_start_ff;
    wire        rx_start;

    wire        last_dw;

    wire [ 1:0] last_dw_byte_num;
    reg  [ 3:0] first_dw_be;
    reg  [ 3:0] last_dw_be;
    wire [ 7:0] cpld_dwbe;

    wire [63:0] cpld_addr;  // 128 字节
    reg  [ 9:0] tag_addr;
    reg  [ 9:0] tag_addr_next;

    wire [ 5:0] cpld_tag_use;
    reg  [ 5:0] cpld_tag_use_ff;

    reg         addr_ram_wr_en;

    wire [ 9:0] multicpld_addr;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) wr_start_ff <= 1'b0;
        else wr_start_ff <= i_cpld_wr_start;
    end

    assign rx_start = i_cpld_wr_start & ~wr_start_ff;
    assign last_dw  = ~i_cpld_wr_start & wr_start_ff;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) addr_ram_wr_en <= 1'b0;
        else addr_ram_wr_en <= rx_start;
    end

    // 根据字节计数和低位地址计算双字字节使能。
    always @(*) begin
        case (i_cpld_low_addr[1:0])
            2'd0: first_dw_be = 4'b1111;
            2'd1: first_dw_be = 4'b1110;
            2'd2: first_dw_be = 4'b1100;
            2'd3: first_dw_be = 4'b1000;
            default: first_dw_be = 4'hf;
        endcase
    end

    assign last_dw_byte_num = i_cpld_byte_cnt[1:0] + i_cpld_low_addr[1:0];

    always @(*) begin
        case (last_dw_byte_num)
            2'd0: last_dw_be = 4'b1111;
            2'd1: last_dw_be = 4'b0001;
            2'd2: last_dw_be = 4'b0011;
            2'd3: last_dw_be = 4'b0111;
            default: last_dw_be = 4'hf;
        endcase
    end

    assign cpld_dwbe = {last_dw_be, first_dw_be};

    // 生成写地址
    assign cpld_tag_use = i_cpld_tag[5:0];  // 使用 64 个标签

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) cpld_tag_use_ff <= 6'b0;
        else cpld_tag_use_ff <= cpld_tag_use;  // 128 字节
    end

    // 保存多完成报文的地址指针
    ipm_distributed_sdpram_v1_2 #(
        .ADDR_WIDTH (6),        // 地址宽度范围：4～10
        .DATA_WIDTH (10),       // 数据宽度范围：1～256
        .RST_TYPE   ("ASYNC"),  // 复位类型：ASYNC 异步，SYNC 同步。
        .OUT_REG    (1),
        .INIT_FILE  ("NONE"),   // 初始化文件：NONE 表示不使用文件，否则填写文件名。
        .FILE_FORMAT("BIN")     // 初始化数据格式：BIN 二进制，HEX 十六进制。
    ) u_ipm_distributed_sdpram_v1_2 (
        .wr_data(tag_addr_next),
        .wr_addr(cpld_tag_use_ff),
        .rd_addr(cpld_tag_use),
        .wr_clk (clk),
        .rd_clk (clk),
        .wr_en  (addr_ram_wr_en),
        .rst    (~rst_n),
        .rd_data(multicpld_addr)
    );

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) tag_addr <= 10'b0;
        else if (last_dw) tag_addr <= multicpld_addr;  // 128 字节
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) tag_addr_next <= 10'b0;
        else if (rx_start)
            tag_addr_next <= i_multicpld_flag ? tag_addr + {i_cpld_length[7:0], 2'b0} : 10'b0;  // 128 字节
    end

    assign cpld_addr = (i_cfg_max_rd_req_size == 3'd0) ? {51'b0, {cpld_tag_use_ff, tag_addr[6:0]}} :  // 128 字节
        (i_cfg_max_rd_req_size == 3'd1) ? {50'b0, {cpld_tag_use_ff, tag_addr[7:0]}} :  // 256 字节
        (i_cfg_max_rd_req_size == 3'd2) ? {49'b0, {cpld_tag_use_ff, tag_addr[8:0]}} :  // 512 字节
        (i_cfg_max_rd_req_size == 3'd3) ? {48'b0, {cpld_tag_use_ff, tag_addr[9:0]}} :  // 1024 字节
        {51'b0, {cpld_tag_use_ff, tag_addr[6:0]}};

    //---------------------------------------------------
    ips2l_pcie_dma_wr_ctrl #(
        .ADDR_WIDTH(ADDR_WIDTH)
    ) ips2l_pcie_dma_cpld_wr_ctrl (
        .clk  (clk),   // 接口时钟：第一代 62.5 MHz，第二代 125 MHz。
        .rst_n(rst_n),

        //---------------------------------------------------
        .i_wr_start(i_cpld_wr_start),
        .i_length  (i_cpld_length),
        .i_dwbe    (cpld_dwbe),
        .i_data    (i_cpld_data),
        .i_dw_vld  (i_cpld_dw_vld),
        .i_addr    (cpld_addr),
        .i_bar_hit (i_bar_hit),

        //---------------------------------------------------
        // RAM 写控制
        .o_wr_en     (o_cpld_wr_en),
        .o_wr_addr   (o_cpld_wr_addr),
        .o_wr_data   (o_cpld_wr_data),
        .o_wr_be     (o_cpld_wr_be),
        .o_wr_bar_hit(o_cpld_wr_bar_hit)
    );

endmodule
