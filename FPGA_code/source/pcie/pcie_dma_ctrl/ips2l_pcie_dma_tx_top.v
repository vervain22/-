//---------------------------------------------------

// Copyright (c) 2019 PANGO MICROSYSTEMS, INC
// ALL RIGHTS REVERVED.

// THE SOURCE CODE CONTAINED HEREIN IS PROPRIETARY TO PANGO MICROSYSTEMS, INC.
// IT SHALL NOT BE REPRODUCED OR DISCLOSED IN WHOLE OR IN PART OR USED BY
// PARTIES WITHOUT WRITTEN AUTHORIZATION FROM THE OWNER.

//---------------------------------------------------

//---------------------------------------------------
module ips2l_pcie_dma_tx_top #(
    parameter DEVICE_TYPE = 3'd0,  // 设备类型：0 为 EP，1 为传统 EP，4 为 RC。
    parameter ADDR_WIDTH  = 4'd9
) (
    input               clk,                     // 接口时钟：第一代 62.5 MHz，第二代 125 MHz。
    input               rst_n,
    input       [  7:0] i_cfg_pbus_num,
    input       [  4:0] i_cfg_pbus_dev_num,
    input       [  2:0] i_cfg_max_rd_req_size,
    input       [  2:0] i_cfg_max_payload_size,
    //---------------------------------------------------
    // AXIS 从接口 0
    input               i_axis_slave0_trdy,
    output wire         o_axis_slave0_tvld,
    output wire [127:0] o_axis_slave0_tdata,
    output wire         o_axis_slave0_tlast,
    output wire         o_axis_slave0_tuser,
    // AXIS 从接口 1
    input               i_axis_slave1_trdy,
    output wire         o_axis_slave1_tvld,
    output wire [127:0] o_axis_slave1_tdata,
    output wire         o_axis_slave1_tlast,
    output wire         o_axis_slave1_tuser,
    // AXIS 从接口 2
    input               i_axis_slave2_trdy,
    output wire         o_axis_slave2_tvld,
    output wire [127:0] o_axis_slave2_tdata,
    output wire         o_axis_slave2_tlast,
    output wire         o_axis_slave2_tuser,
    //---------------------------------------------------
    // 来自 DMA 控制器
    input               i_user_define_data_flag,

    input       i_mwr32_req,
    output wire o_mwr32_req_ack,
    input       i_mwr64_req,
    output wire o_mwr64_req_ack,

    input       i_mrd32_req,
    output wire o_mrd32_req_ack,
    input       i_mrd64_req,
    output wire o_mrd64_req_ack,

    input [ 9:0] i_req_length,
    input [63:0] i_req_addr,
    input [31:0] i_req_data,

    //---------------------------------------------------
    // BAR0 读接口
    output wire                  o_bar0_rd_clk_en  /*synthesis PAP_MARK_DEBUG="1"*/,
    output wire [ADDR_WIDTH-1:0] o_bar0_rd_addr,
    input       [         127:0] i_bar0_rd_data,
    // BAR2 读接口
    output wire                  o_bar2_rd_clk_en,
    output wire [ADDR_WIDTH-1:0] o_bar2_rd_addr,
    input       [         127:0] i_bar2_rd_data,
    //---------------------------------------------------
    // 来自接收顶层
    input       [           2:0] i_mrd_tc,
    input       [           2:0] i_mrd_attr,
    input       [           9:0] i_mrd_length,
    input       [          15:0] i_mrd_id,
    input       [           7:0] i_mrd_tag,
    input       [          63:0] i_mrd_addr,

    input             i_cpld_req_vld,
    output wire       o_cpld_req_rdy,
    output wire       o_cpld_tx_rdy,
    // 接收带数据完成报文
    input             i_cpld_rcv,
    input       [7:0] i_cpld_tag,
    output wire       o_tag_full,

    // 复位 TLP 计数
    input i_tx_restart

);

    wire         mwr_rd_en;
    wire [  9:0] mwr_rd_length;
    wire         mwr_tx_busy;
    wire         mwr_tx_hold;
    wire         mwr_tlp_tx;
    wire         mwr_gen_tlp_start;
    wire [127:0] mwr_rd_data;
    wire         mwr_last_data;

    wire         cpld_rd_en;
    wire [  9:0] cpld_rd_length;
    wire [ 63:0] cpld_rd_addr;
    wire         cpld_tx_hold;
    wire         cpld_tlp_tx;
    wire         cpld_gen_tlp_start;
    wire [127:0] cpld_rd_data;
    wire         cpld_last_data;

    ips2l_pcie_dma_tx_cpld_rd_ctrl #(
        .ADDR_WIDTH(ADDR_WIDTH)
    ) u_ips2l_pcie_dma_tx_cpld_rd_ctrl (
        .clk            (clk),                 // 接口时钟：第一代 62.5 MHz，第二代 125 MHz。
        .rst_n          (rst_n),
        //---------------------------------------------------
        // RAM 接口
        .i_rd_en        (cpld_rd_en),
        .i_rd_length    (cpld_rd_length),
        .i_rd_addr      (cpld_rd_addr),
        .i_cpld_tx_hold (cpld_tx_hold),
        .i_cpld_tlp_tx  (cpld_tlp_tx),
        .o_gen_tlp_start(cpld_gen_tlp_start),
        .o_rd_data      (cpld_rd_data),
        .o_last_data    (cpld_last_data),

        .o_bar_rd_clk_en(o_bar0_rd_clk_en),
        .o_bar_rd_addr  (o_bar0_rd_addr),
        .i_bar_rd_data  (i_bar0_rd_data)
    );

    ips2l_pcie_dma_tx_mwr_rd_ctrl #(
        .ADDR_WIDTH(ADDR_WIDTH)
    ) u_ips2l_pcie_dma_tx_mwr_rd_ctrl (
        .clk            (clk),                // 接口时钟：第一代 62.5 MHz，第二代 125 MHz。
        .rst_n          (rst_n),
        //---------------------------------------------------
        // RAM 接口
        .i_rd_en        (mwr_rd_en),
        .i_rd_length    (mwr_rd_length),
        .i_mwr_tx_busy  (mwr_tx_busy),
        .i_mwr_tx_hold  (mwr_tx_hold),
        .i_mwr_tlp_tx   (mwr_tlp_tx),
        .o_gen_tlp_start(mwr_gen_tlp_start),
        .o_rd_data      (mwr_rd_data),
        .o_last_data    (mwr_last_data),

        .o_bar_rd_clk_en(o_bar2_rd_clk_en),
        .o_bar_rd_addr  (o_bar2_rd_addr),
        .i_bar_rd_data  (i_bar2_rd_data)
    );

    ips2l_pcie_dma_cpld_tx_ctrl u_ips2l_pcie_dma_cpld_tx_ctrl (
        .clk                   (clk),                     // 接口时钟：第一代 62.5 MHz，第二代 125 MHz。
        .rst_n                 (rst_n),
        .i_cfg_pbus_num        (i_cfg_pbus_num),
        .i_cfg_pbus_dev_num    (i_cfg_pbus_dev_num),
        .i_cfg_max_payload_size(i_cfg_max_payload_size),
        //---------------------------------------------------
        // 来自接收接口
        .i_mrd_tc              (i_mrd_tc),
        .i_mrd_attr            (i_mrd_attr),
        .i_mrd_length          (i_mrd_length),
        .i_mrd_id              (i_mrd_id),
        .i_mrd_tag             (i_mrd_tag),
        .i_mrd_addr            (i_mrd_addr),

        .i_cpld_req_vld     (i_cpld_req_vld),
        .o_cpld_req_rdy     (o_cpld_req_rdy),
        .o_cpld_tx_rdy      (o_cpld_tx_rdy),
        //---------------------------------------------------
        // RAM 接口
        .o_rd_en            (cpld_rd_en),
        .o_rd_length        (cpld_rd_length),
        .o_rd_addr          (cpld_rd_addr),
        .o_cpld_tx_hold     (cpld_tx_hold),
        .o_cpld_tlp_tx      (cpld_tlp_tx),
        .i_gen_tlp_start    (cpld_gen_tlp_start),
        .i_rd_data          (cpld_rd_data),
        .i_last_data        (cpld_last_data),
        // AXIS 从接口
        .i_axis_slave0_trdy (i_axis_slave0_trdy),
        .o_axis_slave0_tvld (o_axis_slave0_tvld),
        .o_axis_slave0_tdata(o_axis_slave0_tdata),
        .o_axis_slave0_tlast(o_axis_slave0_tlast),
        .o_axis_slave0_tuser(o_axis_slave0_tuser)
    );

    ips2l_pcie_dma_mrd_tx_ctrl u_ips2l_pcie_dma_mrd_tx_ctrl (
        .clk                  (clk),                    // 接口时钟：第一代 62.5 MHz，第二代 125 MHz。
        .rst_n                (rst_n),
        .i_cfg_pbus_num       (i_cfg_pbus_num),
        .i_cfg_pbus_dev_num   (i_cfg_pbus_dev_num),
        .i_cfg_max_rd_req_size(i_cfg_max_rd_req_size),
        //---------------------------------------------------
        // 来自 DMA 控制器
        .i_mrd32_req          (i_mrd32_req),
        .o_mrd32_req_ack      (o_mrd32_req_ack),
        .i_mrd64_req          (i_mrd64_req),
        .o_mrd64_req_ack      (o_mrd64_req_ack),
        .i_req_length         (i_req_length),
        .i_req_addr           (i_req_addr),
        //---------------------------------------------------
        .i_cpld_rcv           (i_cpld_rcv),
        .i_cpld_tag           (i_cpld_tag),
        .o_tag_full           (o_tag_full),
        // AXIS 从接口
        .i_axis_slave1_trdy   (i_axis_slave1_trdy),
        .o_axis_slave1_tvld   (o_axis_slave1_tvld),
        .o_axis_slave1_tdata  (o_axis_slave1_tdata),
        .o_axis_slave1_tlast  (o_axis_slave1_tlast),
        .o_axis_slave1_tuser  (o_axis_slave1_tuser),

        .i_tx_restart(i_tx_restart)

    );

    ips2l_pcie_dma_mwr_tx_ctrl #(
        .DEVICE_TYPE(DEVICE_TYPE)
    ) u_ips2l_pcie_dma_mwr_tx_ctrl (
        .clk                    (clk),                     // 接口时钟：第一代 62.5 MHz，第二代 125 MHz。
        .rst_n                  (rst_n),
        .i_cfg_pbus_num         (i_cfg_pbus_num),
        .i_cfg_pbus_dev_num     (i_cfg_pbus_dev_num),
        .i_cfg_max_payload_size (i_cfg_max_payload_size),
        //---------------------------------------------------
        // 来自 DMA 控制器
        .i_user_define_data_flag(i_user_define_data_flag),

        .i_mwr32_req    (i_mwr32_req),
        .o_mwr32_req_ack(o_mwr32_req_ack),
        .i_mwr64_req    (i_mwr64_req),
        .o_mwr64_req_ack(o_mwr64_req_ack),

        .i_req_length       (i_req_length),
        .i_req_addr         (i_req_addr),
        .i_req_data         (i_req_data),
        //---------------------------------------------------
        // RAM 接口
        .o_rd_en            (mwr_rd_en),
        .o_rd_length        (mwr_rd_length),
        .i_gen_tlp_start    (mwr_gen_tlp_start),
        .i_rd_data          (mwr_rd_data),
        .i_last_data        (mwr_last_data),
        // AXIS 从接口
        .i_axis_slave2_trdy (i_axis_slave2_trdy),
        .o_axis_slave2_tvld (o_axis_slave2_tvld),
        .o_axis_slave2_tdata(o_axis_slave2_tdata),
        .o_axis_slave2_tlast(o_axis_slave2_tlast),
        .o_axis_slave2_tuser(o_axis_slave2_tuser),
        .o_mwr_tx_busy      (mwr_tx_busy),
        .o_mwr_tx_hold      (mwr_tx_hold),
        .o_mwr_tlp_tx       (mwr_tlp_tx),
        .i_tx_restart       (i_tx_restart)

    );

endmodule
