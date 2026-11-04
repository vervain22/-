//---------------------------------------------------

// Copyright (c) 2019 PANGO MICROSYSTEMS, INC
// ALL RIGHTS REVERVED.

// THE SOURCE CODE CONTAINED HEREIN IS PROPRIETARY TO PANGO MICROSYSTEMS, INC.
// IT SHALL NOT BE REPRODUCED OR DISCLOSED IN WHOLE OR IN PART OR USED BY
// PARTIES WITHOUT WRITTEN AUTHORIZATION FROM THE OWNER.

//---------------------------------------------------

//---------------------------------------------------
module ips2l_pcie_dma_tlp_rcv #(
    parameter DEVICE_TYPE = 3'd0  // 设备类型：0 为 EP，1 为传统 EP，4 为 RC。
) (
    input clk,   // 接口时钟：第一代 62.5 MHz，第二代 125 MHz。
    input rst_n,

    //---------------------------------------------------
    // AXIS 主接口
    input               i_axis_master_tvld,
    output wire         o_axis_master_trdy,
    input       [127:0] i_axis_master_tdata,
    input       [  3:0] i_axis_master_tkeep,
    input               i_axis_master_tlast,
    input       [  7:0] i_axis_master_tuser,
    output reg  [  2:0] o_trgt1_radm_pkt_halt,

    //---------------------------------------------------
    // 连接存储器写控制
    output reg          o_mwr_wr_start,
    output wire [  9:0] o_mwr_length,
    output reg  [  7:0] o_mwr_dwbe,
    output reg  [127:0] o_mwr_data,
    output reg  [  3:0] o_mwr_dw_vld,
    output reg  [ 63:0] o_mwr_addr,
    // 连接完成报文写控制
    output reg          o_cpld_wr_start,
    output wire [  9:0] o_cpld_length,
    output reg  [  6:0] o_cpld_low_addr,
    output reg  [ 11:0] o_cpld_byte_cnt,
    output reg  [127:0] o_cpld_data,
    output reg  [  3:0] o_cpld_dw_vld,
    output reg  [  7:0] o_cpld_tag,
    output reg          o_multicpld_flag,
    // 写 BAR 命中
    output reg  [  1:0] o_bar_hit,
    //---------------------------------------------------
    // 编码 0：命中 BAR0
    // 编码 1：命中 BAR1
    // 编码 2：命中 BAR2
    // 编码 3：保留
    //---------------------------------------------------

    //---------------------------------------------------
    // 连接发送顶层
    output reg  [ 2:0] o_mrd_tc,
    output reg  [ 2:0] o_mrd_attr,
    output wire [ 9:0] o_mrd_length,
    output reg  [15:0] o_mrd_id,
    output reg  [ 7:0] o_mrd_tag,
    output reg  [63:0] o_mrd_addr,

    output reg o_cpld_req_vld,
    input      i_cpld_req_rdy,
    input      i_cpld_tx_rdy,
    // 接收带数据完成报文
    output reg o_cpld_rcv,

    input             i_tag_full,
    //---------------------------------------------------
    // 复位 TLP 计数
    output reg [63:0] o_dma_check_result,
    input             i_tx_restart
    // 来自 DMA 控制器

);

    localparam IDLE     = 2'd0;
    localparam HEAD_RCV = 2'd1;
    localparam DATA_RCV = 2'd2;

    localparam MRD_32   = 8'h0;
    localparam MRD_64   = 8'h20;
    localparam MRDLK_32 = 8'h01;
    localparam MRDLK_64 = 8'h21;
    localparam MWR_32   = 8'h40;
    localparam MWR_64   = 8'h60;
    localparam CPLD     = 8'h4A;
    localparam CPLDLK   = 8'h4B;

    reg  [  1:0] state;
    reg  [  1:0] next_state;

    reg          eop;
    wire [  2:0] tlp_fmt;
    wire [  4:0] tlp_type;
    reg  [  9:0] tlp_length;

    wire         mrd32_rcv;
    wire         mrd64_rcv;
    wire         mrd_rcv;

    wire         mwr32_rcv;
    wire         mwr64_rcv;
    wire         mwr_rcv;
    reg          mwr_data_valid;

    wire         cpld_rcv;
    reg          cpld_data_valid;

    reg          with_data;

    wire [127:0] axis_rx_data;

    reg  [ 11:0] dma_check_cnt;
    reg  [  5:0] data_cnt;

    reg          axis_master_tvld;
    reg          axis_master_tvld_ff;
    reg  [127:0] axis_master_tdata;
    reg  [127:0] axis_master_tdata_ff;
    reg  [  3:0] axis_master_tkeep;
    reg  [  3:0] axis_master_tkeep_ff;
    reg          axis_master_tlast;
    reg          axis_master_tlast_ff;
    reg  [  7:0] axis_master_tuser;
    reg  [  7:0] axis_master_tuser_ff;

    // AXIS 输入寄存
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            axis_master_tvld  <= 1'b0;
            axis_master_tdata <= 128'b0;
            axis_master_tkeep <= 4'b0;
            axis_master_tlast <= 1'b0;
            axis_master_tuser <= 8'b0;

        end else begin
            axis_master_tvld  <= i_axis_master_tvld;
            axis_master_tdata <= i_axis_master_tdata;
            axis_master_tkeep <= i_axis_master_tkeep;
            axis_master_tlast <= i_axis_master_tlast;
            axis_master_tuser <= i_axis_master_tuser;

        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            axis_master_tvld_ff  <= 1'b0;
            axis_master_tdata_ff <= 128'b0;
            axis_master_tkeep_ff <= 4'b0;
            axis_master_tlast_ff <= 1'b0;
            axis_master_tuser_ff <= 8'b0;

        end else begin
            axis_master_tvld_ff  <= axis_master_tvld;
            axis_master_tdata_ff <= axis_master_tdata;
            axis_master_tkeep_ff <= axis_master_tkeep;
            axis_master_tlast_ff <= axis_master_tlast;
            axis_master_tuser_ff <= axis_master_tuser;

        end
    end

    assign o_axis_master_trdy = 1'b1;
    // 报文格式及类型
    assign tlp_fmt    = axis_master_tdata_ff[31:29];
    assign tlp_type   = axis_master_tdata_ff[28:24];

    // 接收存储器读请求
    assign mrd32_rcv = ({tlp_fmt,tlp_type} == MRD_32 || {tlp_fmt,tlp_type} == MRDLK_32) && state == HEAD_RCV;
    assign mrd64_rcv = ({tlp_fmt,tlp_type} == MRD_64 || {tlp_fmt,tlp_type} == MRDLK_64) && state == HEAD_RCV;
    assign mrd_rcv   = mrd32_rcv || mrd64_rcv;
    // 接收存储器写请求
    assign mwr32_rcv = ({tlp_fmt,tlp_type} == MWR_32) && state == HEAD_RCV;
    assign mwr64_rcv = ({tlp_fmt,tlp_type} == MWR_64) && state == HEAD_RCV;
    assign mwr_rcv   = mwr32_rcv || mwr64_rcv;
    // 接收带数据完成报文
    assign cpld_rcv = ({tlp_fmt,tlp_type} == CPLD || {tlp_fmt,tlp_type} == CPLDLK) && state == HEAD_RCV;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) mwr_data_valid <= 1'b0;
        else if (axis_master_tlast_ff) mwr_data_valid <= 1'b0;
        else if (axis_master_tvld_ff && o_axis_master_trdy && state == HEAD_RCV) mwr_data_valid <= mwr_rcv;
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) cpld_data_valid <= 1'b0;
        else if (axis_master_tlast_ff) cpld_data_valid <= 1'b0;
        else if (axis_master_tvld_ff && o_axis_master_trdy && state == HEAD_RCV) cpld_data_valid <= cpld_rcv;
    end

    // 带负载的 TLP
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) with_data <= 1'b0;
        else if (axis_master_tdata[30] && axis_master_tvld && o_axis_master_trdy) with_data <= 1'b1;
        else with_data <= 1'b0;
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) eop <= 1'b0;
        else if (axis_master_tlast && axis_master_tvld && o_axis_master_trdy) eop <= 1'b1;
        else eop <= 1'b0;
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) state <= IDLE;
        else state <= next_state;
    end

    always @(*) begin
        case (state)
            IDLE: begin
                if (axis_master_tvld && o_axis_master_trdy)  // 开始传输
                    next_state = HEAD_RCV;
                else next_state = IDLE;
            end
            HEAD_RCV: begin
                if (with_data) next_state = DATA_RCV;
                else if (~with_data && ~(o_axis_master_trdy && axis_master_tvld))  // 无数据负载
                    next_state = IDLE;
                else next_state = state;
            end
            DATA_RCV: begin
                if (eop && o_axis_master_trdy && axis_master_tvld)  // 连续报文传输
                    next_state = HEAD_RCV;
                else if (eop && ~(o_axis_master_trdy && axis_master_tvld))  // 发送结束
                    next_state = IDLE;
                else next_state = state;
            end
            default: begin
                next_state = IDLE;
            end
        endcase
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // 通用报文头
            tlp_length       <= 10'b0;

            o_mrd_tc         <= 3'b0;
            o_mrd_attr       <= 3'b0;
            o_mrd_id         <= 16'b0;
            o_mrd_tag        <= 8'b0;
            o_mrd_addr       <= 64'b0;

            o_mwr_wr_start   <= 1'b0;
            o_mwr_dwbe       <= 8'b0;
            o_mwr_data       <= 128'b0;
            o_mwr_dw_vld     <= 4'b0;
            o_mwr_addr       <= 64'b0;

            o_cpld_wr_start  <= 1'b0;
            o_cpld_low_addr  <= 7'b0;
            o_cpld_byte_cnt  <= 12'b0;
            o_cpld_data      <= 128'b0;
            o_cpld_dw_vld    <= 4'b0;
            o_cpld_tag       <= 8'b0;
            o_bar_hit        <= 2'b0;
            o_multicpld_flag <= 1'b0;
        end else begin
            case (state)
                IDLE: begin
                    tlp_length       <= 10'b0;

                    o_mrd_tc         <= 3'b0;
                    o_mrd_attr       <= 3'b0;
                    o_mrd_id         <= 16'b0;
                    o_mrd_tag        <= 8'b0;
                    o_mrd_addr       <= 64'b0;

                    o_mwr_wr_start   <= 1'b0;
                    o_mwr_dwbe       <= 8'b0;
                    o_mwr_data       <= 128'b0;
                    o_mwr_dw_vld     <= 4'b0;
                    o_mwr_addr       <= 64'b0;

                    o_cpld_wr_start  <= 1'b0;
                    o_cpld_low_addr  <= 7'b0;
                    o_cpld_byte_cnt  <= 12'b0;
                    o_cpld_data      <= 128'b0;
                    o_cpld_dw_vld    <= 4'b0;
                    o_cpld_tag       <= 8'b0;
                    o_bar_hit        <= 2'b0;
                    o_multicpld_flag <= 1'b0;
                end
                HEAD_RCV: begin

                    tlp_length <= axis_master_tdata_ff[9:0];

                    if (mrd_rcv) begin
                        o_mrd_tc   <= axis_master_tdata_ff[22:20];
                        o_mrd_attr <= {axis_master_tdata_ff[18], axis_master_tdata_ff[13:12]};
                        o_mrd_id   <= axis_master_tdata_ff[63:48];
                        o_mrd_tag  <= axis_master_tdata_ff[47:40];

                        if (mrd32_rcv) o_mrd_addr <= {32'b0, axis_master_tdata_ff[95:66], 2'b0};
                        else if (mrd64_rcv)
                            o_mrd_addr <= {axis_master_tdata_ff[95:64], axis_master_tdata_ff[127:98], 2'b0};

                    end else if (mwr_rcv) begin
                        o_mwr_wr_start <= 1'b0;
                        o_mwr_dwbe     <= axis_master_tdata_ff[39:32];

                        if (mwr32_rcv) o_mwr_addr <= {32'b0, axis_master_tdata_ff[95:66], 2'b0};
                        else if (mwr64_rcv)
                            o_mwr_addr <= {axis_master_tdata_ff[95:64], axis_master_tdata_ff[127:98], 2'b0};
                    end else if (cpld_rcv) begin
                        o_cpld_wr_start  <= 1'b0;
                        o_cpld_byte_cnt  <= axis_master_tdata_ff[41:32];
                        o_cpld_low_addr  <= axis_master_tdata_ff[70:64];
                        o_cpld_tag       <= axis_master_tdata_ff[79:72];
                        o_multicpld_flag <= ~axis_master_tuser_ff[3];
                    end
                end
                DATA_RCV: begin
                    o_bar_hit <= axis_master_tuser_ff[5:4];
                    if (mwr_data_valid) begin
                        o_mwr_wr_start <= 1'b1;
                        o_mwr_data     <= axis_rx_data;
                        o_mwr_dw_vld   <= axis_master_tkeep_ff;
                    end else if (cpld_data_valid) begin
                        o_cpld_wr_start <= 1'b1;
                        o_cpld_data     <= axis_rx_data;
                        o_cpld_dw_vld   <= axis_master_tkeep_ff;
                    end
                end
                default: begin
                    tlp_length       <= 10'b0;

                    o_mrd_tc         <= 3'b0;
                    o_mrd_attr       <= 3'b0;
                    o_mrd_id         <= 16'b0;
                    o_mrd_tag        <= 8'b0;
                    o_mrd_addr       <= 64'b0;

                    o_mwr_wr_start   <= 1'b0;
                    o_mwr_dwbe       <= 8'b0;
                    o_mwr_data       <= 128'b0;
                    o_mwr_dw_vld     <= 4'b0;
                    o_mwr_addr       <= 64'b0;

                    o_cpld_wr_start  <= 1'b0;
                    o_cpld_low_addr  <= 7'b0;
                    o_cpld_byte_cnt  <= 12'b0;
                    o_cpld_data      <= 128'b0;
                    o_cpld_dw_vld    <= 4'b0;
                    o_cpld_tag       <= 8'b0;
                    o_bar_hit        <= 2'b0;
                    o_multicpld_flag <= 1'b0;
                end
            endcase
        end
    end

    assign o_mwr_length  = tlp_length;
    assign o_mrd_length  = tlp_length;
    assign o_cpld_length = tlp_length;

    // 接收存储器读请求后生成完成请求。
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) o_cpld_req_vld <= 1'b0;
        else if ((state == HEAD_RCV) && mrd_rcv) o_cpld_req_vld <= 1'b1;
        else if (i_cpld_req_rdy) o_cpld_req_vld <= 1'b0;
    end

    // 接收完成报文后释放标签。
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) o_cpld_rcv <= 1'b0;
        else if((state == HEAD_RCV) && cpld_rcv && axis_master_tuser_ff[3]) // 多完成报文的末包由 i_axis_master_tuser[3] 标记。
            o_cpld_rcv <= 1'b1;
        else o_cpld_rcv <= 1'b0;
    end

    // o_trgt1_radm_pkt_halt[0] 暂停 VC0 的投递写请求。
    // o_trgt1_radm_pkt_halt[1] 暂停 VC0 的非投递读请求。
    // o_trgt1_radm_pkt_halt[2] 暂停 VC0 的完成报文。
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) o_trgt1_radm_pkt_halt <= 3'b0;
        else o_trgt1_radm_pkt_halt <= {1'b0, ~i_cpld_tx_rdy, i_tag_full};
    end

    // 调试逻辑
    // 仅检查 128 字节传输
    reg  [ 2:0] tlp_data_cnt;
    reg  [13:0] tlp_rx_check_pass_cnt;
    reg  [13:0] tlp_rx_check_error_cnt;
    reg  [13:0] tlp_rx_sum;
    reg  [13:0] multcpld_cnt;
    wire        tlp_rx_vld;
    reg         check_error_flag;
    // 接收 TLP 计数
    reg  [13:0] mwr_rcv_cnt;
    reg  [13:0] mrd_rcv_cnt;
    reg  [13:0] cpld_rcv_cnt;

    assign tlp_rx_vld = axis_master_tvld_ff && o_axis_master_trdy;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) tlp_data_cnt <= 3'b0;
        else if (axis_master_tlast_ff) tlp_data_cnt <= 3'b0;
        else if (cpld_data_valid && tlp_rx_vld) tlp_data_cnt <= tlp_data_cnt + 3'b1;
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) tlp_rx_sum <= 14'b0;
        else if (i_tx_restart) tlp_rx_sum <= 14'b0;
        else if (axis_master_tlast_ff && tlp_rx_vld) tlp_rx_sum <= tlp_rx_sum + 14'b1;
    end

    // 接收 TLP 计数

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) mwr_rcv_cnt <= 14'b0;
        else if (i_tx_restart) mwr_rcv_cnt <= 14'b0;
        else if (mwr_rcv) mwr_rcv_cnt <= mwr_rcv_cnt + 14'b1;
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) mrd_rcv_cnt <= 14'b0;
        else if (i_tx_restart) mrd_rcv_cnt <= 14'b0;
        else if (mrd_rcv) mrd_rcv_cnt <= mrd_rcv_cnt + 14'b1;
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) cpld_rcv_cnt <= 14'b0;
        else if (i_tx_restart) cpld_rcv_cnt <= 14'b0;
        else if (cpld_rcv) cpld_rcv_cnt <= cpld_rcv_cnt + 14'b1;
    end

    // 检查多完成报文标志 i_axis_master_tuser[3]。

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) multcpld_cnt <= 14'b0;
        else if (i_tx_restart) multcpld_cnt <= 14'b0;
        else if (cpld_data_valid && axis_master_tlast_ff && ~axis_master_tuser_ff[3])
            multcpld_cnt <= multcpld_cnt + 14'b1;
    end

    // 校验逻辑
    // DMA 校验

    // 读地址须与写地址一致。
    // 地址须按四个双字对齐。
    // 仅用于 DMA 测试。
    // 不满足上述条件时，校验逻辑不能正常工作。
    generate
        if (DEVICE_TYPE == 3'd4) begin
            always @(posedge clk or negedge rst_n) begin
                if (!rst_n) dma_check_cnt <= 12'b0;
                else if (mwr_rcv) dma_check_cnt <= {axis_master_tdata_ff[79:68]};
                else if (mwr_data_valid) dma_check_cnt <= dma_check_cnt + 12'b1;
            end

            always @(posedge clk or negedge rst_n) begin
                if (!rst_n) data_cnt <= 6'b0;
                else if (mrd_rcv) data_cnt <= 6'd0;
                else if (mwr_data_valid) data_cnt <= data_cnt + 6'b1;
            end

            always @(posedge clk or negedge rst_n) begin
                if (!rst_n) o_dma_check_result <= 64'b0;
                else if (mrd_rcv) o_dma_check_result <= 64'b0;
                else if (mwr_data_valid) o_dma_check_result[data_cnt] <= ~(dma_check_cnt == axis_rx_data[11:0]);
            end
        end else begin
            always @(*) begin
                o_dma_check_result = 64'b0;
            end
        end
    endgenerate
    assign axis_rx_data = endian_convert(axis_master_tdata_ff);
    // 小端顺序转换为大端顺序
    function [127:0] endian_convert;
        input [127:0] data_in;
        begin
            endian_convert[32*0+31:32*0+0] = {
                data_in[32*0+7:32*0+0], data_in[32*0+15:32*0+8], data_in[32*0+23:32*0+16], data_in[32*0+31:32*0+24]
            };
            endian_convert[32*1+31:32*1+0] = {
                data_in[32*1+7:32*1+0], data_in[32*1+15:32*1+8], data_in[32*1+23:32*1+16], data_in[32*1+31:32*1+24]
            };
            endian_convert[32*2+31:32*2+0] = {
                data_in[32*2+7:32*2+0], data_in[32*2+15:32*2+8], data_in[32*2+23:32*2+16], data_in[32*2+31:32*2+24]
            };
            endian_convert[32*3+31:32*3+0] = {
                data_in[32*3+7:32*3+0], data_in[32*3+15:32*3+8], data_in[32*3+23:32*3+16], data_in[32*3+31:32*3+24]
            };
        end
    endfunction

endmodule
