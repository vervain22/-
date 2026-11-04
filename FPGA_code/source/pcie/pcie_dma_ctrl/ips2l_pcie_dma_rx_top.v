//---------------------------------------------------

// Copyright (c) 2019 PANGO MICROSYSTEMS, INC
// ALL RIGHTS REVERVED.

// THE SOURCE CODE CONTAINED HEREIN IS PROPRIETARY TO PANGO MICROSYSTEMS, INC.
// IT SHALL NOT BE REPRODUCED OR DISCLOSED IN WHOLE OR IN PART OR USED BY
// PARTIES WITHOUT WRITTEN AUTHORIZATION FROM THE OWNER.

//---------------------------------------------------

//---------------------------------------------------
module ips2l_pcie_dma_rx_top #(
    parameter integer ASSIST_ENABLE = 0,
    parameter         DEVICE_TYPE   = 3'd0,  // 设备类型：0 为 EP，1 为传统 EP，4 为 RC。
    parameter         ADDR_WIDTH    = 4'd9
) (
    input               clk,                    // 接口时钟：第一代 62.5 MHz，第二代 125 MHz。
    input               rst_n,
    input  wire         assist_pix_clk,
    assist_pix_rst_n,
    assist_vsync,
    assist_de,
    input  wire [ 23:0] assist_rgb,
    input       [  2:0] i_cfg_max_rd_req_size,
    //---------------------------------------------------
    // AXIS 主接口
    input               i_axis_master_tvld,
    output wire         o_axis_master_trdy,
    input       [127:0] i_axis_master_tdata,
    input       [  3:0] i_axis_master_tkeep,
    input               i_axis_master_tlast,
    input       [  7:0] i_axis_master_tuser,
    output wire [  2:0] o_trgt1_radm_pkt_halt,

    //---------------------------------------------------
    // BAR0 读接口
    input                        i_bar0_rd_clk_en,
    input       [ADDR_WIDTH-1:0] i_bar0_rd_addr,
    output wire [         127:0] o_bar0_rd_data,

    // BAR2 读接口
    input                        i_bar2_rd_clk_en,
    input       [ADDR_WIDTH-1:0] i_bar2_rd_addr,
    output wire [         127:0] o_bar2_rd_data,

    // BAR1 写接口
    output reg                   o_bar1_wr_en,
    output reg  [ADDR_WIDTH-1:0] o_bar1_wr_addr,
    output reg  [         127:0] o_bar1_wr_data,
    output reg  [          15:0] o_bar1_wr_byte_en,
    //---------------------------------------------------
    // 连接发送顶层
    output wire [           2:0] o_mrd_tc,
    output wire [           2:0] o_mrd_attr,
    output wire [           9:0] o_mrd_length,
    output wire [          15:0] o_mrd_id,
    output wire [           7:0] o_mrd_tag,
    output wire [          63:0] o_mrd_addr,

    output wire        o_cpld_req_vld,
    input              i_cpld_req_rdy,
    input              i_cpld_tx_rdy,
    // 接收带数据完成报文
    output wire        o_cpld_rcv,
    output wire [ 7:0] o_cpld_tag,
    input              i_tag_full,
    // 复位 TLP 计数
    output wire [63:0] o_dma_check_result,
    input              i_tx_restart

);

    wire                  mwr_wr_start;
    wire [           9:0] mwr_length;
    wire [           7:0] mwr_dwbe;
    wire [         127:0] mwr_data;
    wire [           3:0] mwr_dw_vld;
    wire [          63:0] mwr_addr;

    wire                  cpld_wr_start;
    wire [           9:0] cpld_length;
    wire [           6:0] cpld_low_addr;
    wire [          11:0] cpld_byte_cnt;
    wire [         127:0] cpld_data;
    wire [           3:0] cpld_dw_vld;
    wire                  multicpld_flag;

    wire [           1:0] bar_hit;

    // 存储器写入
    wire                  mwr_wr_en;
    wire [ADDR_WIDTH-1:0] mwr_wr_addr;
    wire [         127:0] mwr_wr_data;
    wire [          15:0] mwr_wr_be;
    wire [           1:0] mwr_wr_bar_hit  /*synthesis PAP_MARK_DEBUG="1"*/;
    // 完成报文写入
    wire                  cpld_wr_en;
    wire [ADDR_WIDTH-1:0] cpld_wr_addr;
    wire [         127:0] cpld_wr_data;
    wire [          15:0] cpld_wr_be;
    wire [           1:0] cpld_wr_bar_hit;
    // BAR0 写接口
    reg                   bar0_wr_en  /*synthesis PAP_MARK_DEBUG="1"*/;
    reg  [ADDR_WIDTH-1:0] bar0_wr_addr;
    reg  [         127:0] bar0_wr_data  /*synthesis PAP_MARK_DEBUG="1"*/;
    reg  [          15:0] bar0_wr_byte_en;
    // BAR2 写接口
    wire                  bar2_wr_en;
    wire [ADDR_WIDTH-1:0] bar2_wr_addr;
    wire [         127:0] bar2_wr_data;
    wire [          15:0] bar2_wr_byte_en;

    wire [127:0] legacy_bar0_data, assist_data;
    wire assist_wr_hit = ASSIST_ENABLE && bar0_wr_addr >= 12'h080 && bar0_wr_addr <= 12'h08f;
    wire assist_rd_hit = ASSIST_ENABLE && i_bar0_rd_addr >= 12'h080 && i_bar0_rd_addr <= 12'h08f;
    reg  assist_rd_hit_q;
    generate
        if (ASSIST_ENABLE) begin : g_assist
            always @(posedge clk or negedge rst_n)
                if (!rst_n) assist_rd_hit_q <= 0;
                else if (i_bar0_rd_clk_en) assist_rd_hit_q <= assist_rd_hit;
            roi_assist_subsystem #(
                .PIX_READY_SYNC(1)
            ) u_assist (
                .bus_clk(clk),
                .pix_clk(assist_pix_clk),
                .rst_n(rst_n),
                .pix_ready(assist_pix_rst_n),
                .wr_en(bar0_wr_en && assist_wr_hit),
                .wr_word(bar0_wr_addr[3:0]),
                .wr_data(bar0_wr_data),
                .wr_be(bar0_wr_byte_en),
                .rd_en(i_bar0_rd_clk_en && assist_rd_hit),
                .rd_word(i_bar0_rd_addr[3:0]),
                .rd_data(assist_data),
                .vsync(assist_vsync),
                .de(assist_de),
                .rgb(assist_rgb)
            );
            assign o_bar0_rd_data = assist_rd_hit_q ? assist_data : legacy_bar0_data;
        end else begin : g_no_assist
            assign o_bar0_rd_data = legacy_bar0_data;
            assign assist_data = 128'd0;
        end
    endgenerate

    ips2l_pcie_dma_tlp_rcv #(
        .DEVICE_TYPE(DEVICE_TYPE)
    ) u_ips2l_pcie_dma_tlp_rcv (
        .clk  (clk),   // 接口时钟：第一代 62.5 MHz，第二代 125 MHz。
        .rst_n(rst_n),

        //---------------------------------------------------
        // AXIS 主接口
        .i_axis_master_tvld   (i_axis_master_tvld),
        .o_axis_master_trdy   (o_axis_master_trdy),
        .i_axis_master_tdata  (i_axis_master_tdata),
        .i_axis_master_tkeep  (i_axis_master_tkeep),
        .i_axis_master_tlast  (i_axis_master_tlast),
        .i_axis_master_tuser  (i_axis_master_tuser),
        .o_trgt1_radm_pkt_halt(o_trgt1_radm_pkt_halt),

        //---------------------------------------------------
        // 连接存储器写控制
        .o_mwr_wr_start  (mwr_wr_start),
        .o_mwr_length    (mwr_length),
        .o_mwr_dwbe      (mwr_dwbe),
        .o_mwr_data      (mwr_data),
        .o_mwr_dw_vld    (mwr_dw_vld),
        .o_mwr_addr      (mwr_addr),
        // 连接完成报文写控制
        .o_cpld_wr_start (cpld_wr_start),
        .o_cpld_length   (cpld_length),
        .o_cpld_low_addr (cpld_low_addr),
        .o_cpld_byte_cnt (cpld_byte_cnt),
        .o_cpld_data     (cpld_data),
        .o_cpld_dw_vld   (cpld_dw_vld),
        .o_multicpld_flag(multicpld_flag),
        // 写 BAR 命中
        .o_bar_hit       (bar_hit),
        //---------------------------------------------------
        // 连接发送顶层
        .o_mrd_tc        (o_mrd_tc),
        .o_mrd_attr      (o_mrd_attr),
        .o_mrd_length    (o_mrd_length),
        .o_mrd_id        (o_mrd_id),
        .o_mrd_tag       (o_mrd_tag),
        .o_mrd_addr      (o_mrd_addr),

        .o_cpld_req_vld    (o_cpld_req_vld),
        .i_cpld_req_rdy    (i_cpld_req_rdy),
        .i_cpld_tx_rdy     (i_cpld_tx_rdy),
        // 接收带数据完成报文
        .o_cpld_rcv        (o_cpld_rcv),
        .o_cpld_tag        (o_cpld_tag),
        .i_tag_full        (i_tag_full),
        // 复位 TLP 计数
        .o_dma_check_result(o_dma_check_result),
        .i_tx_restart      (i_tx_restart)

    );

    ips2l_pcie_dma_rx_cpld_wr_ctrl #(
        .ADDR_WIDTH(ADDR_WIDTH)
    ) u_cpld_wr_ctrl (
        .clk                  (clk),                    // 接口时钟：第一代 62.5 MHz，第二代 125 MHz。
        .rst_n                (rst_n),
        .i_cfg_max_rd_req_size(i_cfg_max_rd_req_size),
        //---------------------------------------------------
        .i_cpld_wr_start      (cpld_wr_start),
        .i_cpld_length        (cpld_length),
        .i_cpld_low_addr      (cpld_low_addr),
        .i_cpld_byte_cnt      (cpld_byte_cnt),
        .i_cpld_data          (cpld_data),
        .i_cpld_dw_vld        (cpld_dw_vld),
        .i_cpld_tag           (o_cpld_tag),
        .i_bar_hit            (bar_hit),
        .i_multicpld_flag     (multicpld_flag),
        //---------------------------------------------------
        .o_cpld_wr_en         (cpld_wr_en),
        .o_cpld_wr_addr       (cpld_wr_addr),
        .o_cpld_wr_data       (cpld_wr_data),
        .o_cpld_wr_be         (cpld_wr_be),
        .o_cpld_wr_bar_hit    (cpld_wr_bar_hit)
    );

    ips2l_pcie_dma_rx_mwr_wr_ctrl #(
        .ADDR_WIDTH(ADDR_WIDTH)
    ) u_mwr_wr_ctrl (
        .clk             (clk),            // 接口时钟：第一代 62.5 MHz，第二代 125 MHz。
        .rst_n           (rst_n),
        //---------------------------------------------------
        .i_mwr_wr_start  (mwr_wr_start),
        .i_mwr_length    (mwr_length),
        .i_mwr_dwbe      (mwr_dwbe),
        .i_mwr_data      (mwr_data),
        .i_mwr_dw_vld    (mwr_dw_vld),
        .i_mwr_addr      (mwr_addr),
        .i_bar_hit       (bar_hit),
        //---------------------------------------------------
        .o_mwr_wr_en     (mwr_wr_en),
        .o_mwr_wr_addr   (mwr_wr_addr),
        .o_mwr_wr_data   (mwr_wr_data),
        .o_mwr_wr_be     (mwr_wr_be),
        .o_mwr_wr_bar_hit(mwr_wr_bar_hit)
    );

    // BAR0 接口
    always @(*) begin
        if (mwr_wr_bar_hit == 2'b0) begin
            bar0_wr_en      = mwr_wr_en;
            bar0_wr_addr    = mwr_wr_addr;
            bar0_wr_data    = mwr_wr_data;
            bar0_wr_byte_en = mwr_wr_be;
        end else begin
            bar0_wr_en      = 1'b0;
            bar0_wr_addr    = {ADDR_WIDTH{1'b0}};
            bar0_wr_data    = 128'b0;
            bar0_wr_byte_en = 16'b0;
        end
    end

    // BAR1 接口
    always @(*) begin
        if (bar_hit == 2'b01 && (DEVICE_TYPE == 3'b000 || DEVICE_TYPE == 3'b001)) begin
            o_bar1_wr_en      = 1'b1;
            o_bar1_wr_addr    = mwr_addr[ADDR_WIDTH-1:0];
            o_bar1_wr_data    = mwr_data;
            o_bar1_wr_byte_en = {{4{mwr_dwbe[3]}}, {4{mwr_dwbe[2]}}, {4{mwr_dwbe[1]}}, {4{mwr_dwbe[0]}}};
        end else begin
            o_bar1_wr_en      = 1'b0;
            o_bar1_wr_addr    = {ADDR_WIDTH{1'b0}};
            o_bar1_wr_data    = 128'b0;
            o_bar1_wr_byte_en = 16'b0;
        end
    end

    assign bar2_wr_en      = cpld_wr_en;
    assign bar2_wr_addr    = cpld_wr_addr;
    assign bar2_wr_data    = cpld_wr_data;
    assign bar2_wr_byte_en = cpld_wr_be;

    ips2l_pcie_dma_ram ips2l_pcie_dma_bar0 (
        .wr_data   (bar0_wr_data),
        .wr_addr   (bar0_wr_addr),
        .wr_en     (bar0_wr_en && !assist_wr_hit),
        .wr_byte_en(bar0_wr_byte_en),
        .wr_clk    (clk),
        .wr_rst    (~rst_n),
        .rd_addr   (i_bar0_rd_addr),
        .rd_data   (legacy_bar0_data),
        .rd_clk    (clk),
        .rd_clk_en (i_bar0_rd_clk_en),
        .rd_rst    (~rst_n)
    );

    ips2l_pcie_dma_ram ips2l_pcie_dma_bar2 (
        .wr_data   (bar2_wr_data),
        .wr_addr   (bar2_wr_addr),
        .wr_en     (bar2_wr_en),
        .wr_byte_en(bar2_wr_byte_en),
        .wr_clk    (clk),
        .wr_rst    (~rst_n),
        .rd_addr   (i_bar2_rd_addr),
        .rd_data   (o_bar2_rd_data),
        .rd_clk    (clk),
        .rd_clk_en (i_bar2_rd_clk_en),
        .rd_rst    (~rst_n)
    );

endmodule
