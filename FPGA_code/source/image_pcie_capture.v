`timescale 1ns / 1ps

module image_pcie_capture #(

    parameter MEM_ROW_WIDTH = 15,

    parameter MEM_COLUMN_WIDTH = 10,

    parameter MEM_BANK_WIDTH = 3,

    parameter MEM_DQ_WIDTH = 16,

    parameter MEM_DQS_WIDTH = 2

) (
    input free_clk,
    input board_rst_n,

    // DDR3接口
    output                      mem_cs_n,
    output                      mem_rst_n,
    output                      mem_ck,
    output                      mem_ck_n,
    output                      mem_cke,
    output                      mem_ras_n,
    output                      mem_cas_n,
    output                      mem_we_n,
    output                      mem_odt,
    output [ MEM_ROW_WIDTH-1:0] mem_a,
    output [MEM_BANK_WIDTH-1:0] mem_ba,
    inout  [MEM_DQ_WIDTH/8-1:0] mem_dqs,
    inout  [MEM_DQ_WIDTH/8-1:0] mem_dqs_n,
    inout  [  MEM_DQ_WIDTH-1:0] mem_dq,
    output [MEM_DQ_WIDTH/8-1:0] mem_dm,

    // PCIe接口
    input             ref_clk_p,  // 输入参考时钟
    input             ref_clk_n,
    input             perst_n,    // PCIe模块复位
    input       [1:0] rxn,        // PCIe模块接收
    input       [1:0] rxp,
    output wire [1:0] txn,        // PCIe模块发送
    output wire [1:0] txp,

    // LED指示信号
    output reg heart_beat_led,
    output reg pclk_led,
    output reg ref_led,
    output reg hdmi_led,        // HDMI 状态指示灯

    // HDMI输入接口
    output hd_scl,
    inout  hd_sda,
    output rx_rst_n,

    input       pixclk_in  /*synthesis PAP_MARK_DEBUG="true"*/,
    input       vs_in  /*synthesis PAP_MARK_DEBUG="true"*/,
    input       de_in  /*synthesis PAP_MARK_DEBUG="true"*/,
    input [7:0] r_in  /*synthesis PAP_MARK_DEBUG="true"*/,
    input [7:0] g_in  /*synthesis PAP_MARK_DEBUG="true"*/,
    input [7:0] b_in  /*synthesis PAP_MARK_DEBUG="true"*/,

    // FMC J2 摄像头接口
    inout        cmos_fmc_scl,
    inout        cmos_fmc_sda,
    input        cmos_fmc_vsync,
    input        cmos_fmc_href,
    input        cmos_fmc_pclk,
    input  [7:0] cmos_fmc_data,
    output       cmos_fmc_reset

);

    //---------------------------------------------------
    // HDMI输入控制信号定义
    //---------------------------------------------------
    wire        cfg_clk;  // 配置时钟
    wire        locked;  // PLL 锁定信号
    wire        init_over;  // 初始化完成信号
    wire        rx_init_done;
    (* ASYNC_REG = "TRUE" *)reg         rx_init_done_pix_d1  /* synthesis syn_keep = 1 */ = 1'b0;
    (* ASYNC_REG = "TRUE" *)reg         rx_init_done_pix_d2  /* synthesis syn_keep = 1 */ = 1'b0;
    reg  [15:0] rstn_1ms;  // 1ms 复位延时计数器

    wire        rstn_out;
    wire        rx_init_done_pix;

    //---------------------------------------------------
    // 图像预处理输出信号
    //---------------------------------------------------
    wire        pre_vsync  /*synthesis PAP_MARK_DEBUG="true"*/;
    wire        pre_de  /*synthesis PAP_MARK_DEBUG="true"*/;
    wire [15:0] pre_data  /*synthesis PAP_MARK_DEBUG="true"*/;
    wire [ 7:0] source_frame_count_pcie  /*synthesis PAP_MARK_DEBUG="true"*/;

    // FMC 摄像头采集信号，送入四宫格帧缓存。
    wire        fmc_init_done;
    wire        fmc_pixel_clk;
    wire        fmc_frame_valid;
    wire        fmc_frame_sync;
    wire [15:0] fmc_pixel_data;
    parameter CTRL_ADDR_WIDTH = MEM_ROW_WIDTH + MEM_BANK_WIDTH + MEM_COLUMN_WIDTH;
    parameter TH_1S = 27'd33000000;
    parameter REM_DQS_WIDTH = 9 - MEM_DQS_WIDTH;

    wire                        ddrphy_cpd_lock;
    wire                        ddr_init_done  /*synthesis PAP_MARK_DEBUG="true"*/;
    wire                        pll_lock;
    wire                        core_clk;
    wire [ CTRL_ADDR_WIDTH-1:0] axi_awaddr  /*synthesis PAP_MARK_DEBUG="true"*/;
    wire                        axi_awuser_ap;
    wire [                 3:0] axi_awuser_id;
    wire [                 3:0] axi_awlen;
    wire                        axi_awready  /*synthesis PAP_MARK_DEBUG="true"*/;
    wire                        axi_awvalid  /*synthesis PAP_MARK_DEBUG="true"*/;
    wire [  MEM_DQ_WIDTH*8-1:0] axi_wdata;
    wire [MEM_DQ_WIDTH*8/8-1:0] axi_wstrb;
    wire                        axi_wready  /*synthesis PAP_MARK_DEBUG="true"*/;
    wire [                 3:0] axi_wusero_id;
    wire                        axi_wusero_last;
    wire                        axi_ctrl_wlast  /*synthesis PAP_MARK_DEBUG="true"*/;
    wire                        axi_ctrl_wvalid  /*synthesis PAP_MARK_DEBUG="true"*/;
    wire [ CTRL_ADDR_WIDTH-1:0] axi_araddr  /*synthesis PAP_MARK_DEBUG="true"*/;
    wire                        axi_aruser_ap;
    wire [                 3:0] axi_aruser_id;
    wire [                 3:0] axi_arlen;
    wire                        axi_arready  /*synthesis PAP_MARK_DEBUG="true"*/;
    wire                        axi_arvalid  /*synthesis PAP_MARK_DEBUG="true"*/;
    wire [  MEM_DQ_WIDTH*8-1:0] axi_rdata  /* synthesis syn_keep = 1 */;
    wire                        axi_rvalid  /*synthesis PAP_MARK_DEBUG="true"*/;
    wire [                 3:0] axi_rid;
    wire                        axi_rlast  /*synthesis PAP_MARK_DEBUG="true"*/;
    wire                        resetn;
    reg  [                26:0] cnt;
    wire [                 7:0] err_cnt;
    wire                        free_clk_g;

    // PCIe相关信号定义
    localparam DEVICE_TYPE = 3'b000;  // IPC可选枚举值：3'b000、3'b001、3'b100
    localparam AXIS_SLAVE_NUM = 3;  // IPC可选枚举值：1、2、3

    // PCIe 状态指示信号

    // 测试单元模式信号
    wire pcie_cfg_ctrl_en;
    wire axis_master_tready_cfg;

    wire cfg_axis_slave0_tvalid;
    wire [127:0] cfg_axis_slave0_tdata;
    wire cfg_axis_slave0_tlast;
    wire cfg_axis_slave0_tuser;

    // 复用选择相关信号
    wire axis_master_tready_mem;
    wire axis_master_tvalid_mem;
    wire [127:0] axis_master_tdata_mem;
    wire [3:0] axis_master_tkeep_mem;

    wire axis_master_tlast_mem;
    wire [7:0] axis_master_tuser_mem;

    wire cross_4kb_boundary;

    wire dma_axis_slave0_tvalid;
    wire [127:0] dma_axis_slave0_tdata;
    wire dma_axis_slave0_tlast;
    wire dma_axis_slave0_tuser;

    // 复位去抖和同步信号
    wire sync_button_rst_n;
    wire ref_core_rst_n;
    wire sync_perst_n;
    wire s_pclk_rstn;

    // 内部信号
    wire pclk_div2  /*synthesis PAP_MARK_DEBUG="1"*/;  // 用户时钟，x2 5gt/s时，为125MHZ 2.5gt/s时为62.5
    wire pclk  /*synthesis PAP_MARK_DEBUG="1"*/;  // 用户时钟，x2 5gt/s时，为125MHZ 2.5gt/s时为62.5
    wire ref_clk;
    wire core_rst_n;

    wire axis_master_tvalid;
    wire axis_master_tready;
    wire [127:0] axis_master_tdata;
    wire [3:0] axis_master_tkeep;
    wire axis_master_tlast;
    wire [7:0] axis_master_tuser;

    // AXI4-Stream从接口0
    wire axis_slave0_tready;
    wire axis_slave0_tvalid;
    wire [127:0] axis_slave0_tdata;
    wire axis_slave0_tlast;
    wire axis_slave0_tuser;
    // AXI4-Stream从接口1
    wire axis_slave1_tready;
    wire axis_slave1_tvalid;
    wire [127:0] axis_slave1_tdata;
    wire axis_slave1_tlast;
    wire axis_slave1_tuser;
    // AXI4-Stream从接口2
    wire axis_slave2_tready;
    wire axis_slave2_tvalid;
    wire [127:0] axis_slave2_tdata;
    wire axis_slave2_tlast;
    wire axis_slave2_tuser;

    wire [7:0] cfg_pbus_num;
    wire [4:0] cfg_pbus_dev_num;
    wire [2:0] cfg_max_rd_req_size;
    wire [2:0] cfg_max_payload_size;
    wire cfg_rcb;

    wire cfg_ido_req_en;
    wire cfg_ido_cpl_en;
    wire [7:0] xadm_ph_cdts;
    wire [11:0] xadm_pd_cdts;
    wire [7:0] xadm_nph_cdts;
    wire [11:0] xadm_npd_cdts;
    wire [7:0] xadm_cplh_cdts;
    wire [11:0] xadm_cpld_cdts;

    wire [4:0] smlh_ltssm_state  /*synthesis PAP_MARK_DEBUG="1"*/;  // PCIe链路状态机

    // LED闪烁控制信号
    reg [22:0] ref_led_cnt;
    reg [26:0] pclk_led_cnt;
    wire smlh_link_up;
    wire rdlh_link_up  /*synthesis PAP_MARK_DEBUG="1"*/;

    // UART转APB 32位总线信号
    wire uart_p_sel;
    wire [3:0] uart_p_strb;
    wire [15:0] uart_p_addr;
    wire [31:0] uart_p_wdata;
    wire uart_p_ce;
    wire uart_p_we;
    wire uart_p_rdy;
    wire [31:0] uart_p_rdata;

    // APB总线信号
    wire [3:0] p_strb;
    wire [15:0] p_addr;
    wire [31:0] p_wdata;
    wire p_ce;
    wire p_we;

    // APB复用选择信号
    // 0~5：HSSTLP，6：保留，7：PCIe
    // 8：配置空间
    // DMA 状态编码：9
    wire p_sel_pcie;
    wire p_sel_cfg;
    wire p_sel_dma;

    wire [31:0] p_rdata_pcie;
    wire [31:0] p_rdata_cfg;
    wire [31:0] p_rdata_dma;

    wire p_rdy_pcie;
    wire p_rdy_cfg;
    wire p_rdy_dma;

    assign cfg_ido_req_en = 1'b0;
    assign cfg_ido_cpl_en = 1'b0;
    assign xadm_ph_cdts   = 8'b0;
    assign xadm_pd_cdts   = 12'b0;
    assign xadm_nph_cdts  = 8'b0;
    assign xadm_npd_cdts  = 12'b0;
    assign xadm_cplh_cdts = 8'b0;
    assign xadm_cpld_cdts = 12'b0;

    // AXI相关信号
    reg          ch0_rframe_req;
    wire         ch0_rframe_req_ack;
    wire         ch0_rframe_data_en;
    wire [127:0] ch0_rframe_data;
    wire         ch0_rframe_data_valid;

    // DMA相关信号
    // DMA控制寄存器基地址 = 0x8000
    wire         o_dma_write_data_req;
    wire [ 11:0] o_dma_write_addr;
    wire [127:0] i_dma_write_data;
    wire         fpga_frame_read_start;

    //---------------------------------------------------
    // 生成配置时钟
    //---------------------------------------------------
    clk_1080p_gen u_PLL_CLK (
        .clkout0(cfg_clk),
        .lock   (locked),
        .clkin1 (free_clk)
    );

    //---------------------------------------------------
    // HDMI接收芯片配置（MS72xx）
    //---------------------------------------------------
    ms72xx_ctl ms72xx_ctl (
        .clk  (cfg_clk),  // 输入：clk
        .rst_n(rstn_out), // 输入：复位信号

        .init_over_rx(rx_init_done),
        .init_over   (init_over),     // 输出：初始化完成信号
        .iic_scl     (hd_scl),        // 输出：IIC时钟
        .iic_sda     (hd_sda)         // 双向：IIC数据
    );

    //---------------------------------------------------
    // 复位序列生成
    //---------------------------------------------------
    always @(posedge cfg_clk) begin
        if (!locked) rstn_1ms <= 16'd0;
        else begin
            if (rstn_1ms == 16'h2710) rstn_1ms <= rstn_1ms;
            else rstn_1ms <= rstn_1ms + 1'b1;
        end
    end
    assign rstn_out = (rstn_1ms == 16'h2710);
    assign rx_rst_n = rstn_out;

    //---------------------------------------------------
    // 图像预处理模块例化
    //---------------------------------------------------
    wire [23:0] pre_rgb888;
    wire hdmi_observe_vs, hdmi_observe_de;
    wire [23:0] hdmi_observe_rgb;
    preprocess u_preprocess (

        .clk          (pixclk_in),
        .rst_n        (rx_init_done_pix),
        .in_vsync     (vs_in),
        .in_de        (de_in),
        .in_data      ({r_in, g_in, b_in}),
        .out_vsync    (pre_vsync),
        .out_de       (pre_de),
        .out_data     (pre_data),
        .out_rgb888   (pre_rgb888),
        .observe_vsync(hdmi_observe_vs),
        .observe_de   (hdmi_observe_de),
        .observe_rgb  (hdmi_observe_rgb)
    );

    // HDMI 和摄像头均保留 640×360 有效像素。
    wire hdmi_640_vs, hdmi_640_valid, hdmi_640_complete;
    wire cam_640_vs, cam_640_valid, cam_640_complete;
    wire camera_base_vs, camera_base_valid;
    wire [15:0] camera_base_data;
    wire [15:0] hdmi_640_data, cam_640_data;
    video_box_downscale_rgb888 #(
        .INPUT_WIDTH(1920),
        .INPUT_HEIGHT(1080),
        .DIV(3)
    ) u_hdmi_640 (
        // pre_vsync 在最后一个增强像素之后发出，不能直接触发下一帧 DDR 写请求。
        // 均值缩放的末像素在帧尾输出，过早发出下一帧请求会中断尚未完成的突发写入。
        // HDMI VS 在垂直消隐期间上升，此时像素流水线尾部已输出完成。
        .clk(pixclk_in),
        .rst_n(rx_init_done_pix),
        .frame_sync(vs_in),
        .in_valid(pre_de),
        .in_data(pre_rgb888),
        .out_frame_sync(hdmi_640_vs),
        .out_valid(hdmi_640_valid),
        .out_data(hdmi_640_data),
        .frame_complete(hdmi_640_complete)
    );

    wire paired_hdmi_vs, paired_hdmi_valid;
    wire base_lane_vs, base_lane_valid;
    wire [31:0] base_lane_data;
    wire [31:0] paired_hdmi_data, paired_hdmi_errors;
    wire base_hdmi_vs, base_hdmi_valid;
    wire [31:0] base_hdmi_data, base_hdmi_errors, lane_aux_errors;
    color_pair_stream u_color_pair_stream (
        .clk(pixclk_in),
        .rst_n(rx_init_done_pix),
        .raw_vs(hdmi_observe_vs),
        .raw_de(hdmi_observe_de),
        .raw_rgb(hdmi_observe_rgb),
        .image_vs(hdmi_640_vs),
        .image_valid(hdmi_640_valid),
        .image_data(hdmi_640_data),
        .pair_vs(base_hdmi_vs),
        .pair_valid(base_hdmi_valid),
        .pair_data(base_hdmi_data),
        .pair_errors(base_hdmi_errors)
    );
    lane_aux_stream u_lane_aux_stream (
        .clk(pixclk_in),
        .rst_n(rx_init_done_pix),
        .in_vs(base_hdmi_vs),
        .in_valid(base_hdmi_valid),
        .in_data(base_hdmi_data),
        .out_vs(base_lane_vs),
        .out_valid(base_lane_valid),
        .out_data(base_lane_data),
        .errors(lane_aux_errors)
    );

    detail_stream u_hdmi_detail (
        .clk(pixclk_in),
        .rst_n(rx_init_done_pix),
        .in_vs(base_lane_vs),
        .in_valid(base_lane_valid),
        .in_data(base_lane_data),
        .out_vs(paired_hdmi_vs),
        .out_valid(paired_hdmi_valid),
        .out_data(paired_hdmi_data)
    );
    assign paired_hdmi_errors = base_hdmi_errors + lane_aux_errors;
    ov5640_single_capture u_ov5640_fmc (
        .sys_clk    (free_clk),
        .rst_n      (board_rst_n),
        .cmos_scl   (cmos_fmc_scl),
        .cmos_sda   (cmos_fmc_sda),
        .cmos_vsync (cmos_fmc_vsync),
        .cmos_href  (cmos_fmc_href),
        .cmos_pclk  (cmos_fmc_pclk),
        .cmos_data  (cmos_fmc_data),
        .cmos_reset (cmos_fmc_reset),
        .init_done  (fmc_init_done),
        .pixel_clk  (fmc_pixel_clk),
        .frame_valid(fmc_frame_valid),
        .frame_sync (fmc_frame_sync),
        .pixel_data (fmc_pixel_data)
    );
    // 摄像头使用抽样缩放，HDMI 使用 RGB888 均值缩放，输出均为 640×360。
    // HDMI 保留 RGB888 均值缩放，摄像头输出尺寸为 640×360。
    video_decimate_integer #(
        .INPUT_WIDTH(1280),
        .INPUT_HEIGHT(720),
        .DIV(2)
    ) u_camera_640 (
        .clk(fmc_pixel_clk),
        .rst_n(board_rst_n & fmc_init_done),
        .frame_sync(fmc_frame_sync),
        .in_valid(fmc_frame_valid),
        .in_data(fmc_pixel_data),
        .out_frame_sync(camera_base_vs),
        .out_valid(camera_base_valid),
        .out_data(camera_base_data),
        .frame_complete(cam_640_complete)
    );

    // 两路观测来自同一输入流，不增加 DMA 数据量或运行时切换。
    tone_stream #(
        .DATA_WIDTH(16)
    ) u_camera_tone (
        .clk(fmc_pixel_clk),
        .rst_n(board_rst_n & fmc_init_done),
        .in_vs(camera_base_vs),
        .in_valid(camera_base_valid),
        .in_data(camera_base_data),
        .out_vs(cam_640_vs),
        .out_valid(cam_640_valid),
        .out_data(cam_640_data)
    );
    // 四个通道均完成一帧 DDR 写入后才允许 DMA 传输。
    wire [3:0] ddr_frame_ready;
    wire [3:0] ddr_read_frame_loaded;
    (* ASYNC_REG="TRUE" *) reg [3:0] read_loaded_meta, read_loaded_sync;
    always @(posedge pclk_div2) begin
        if (!core_rst_n) begin
            read_loaded_meta <= 0;
            read_loaded_sync <= 0;
        end else begin
            read_loaded_meta <= {ddr_read_frame_loaded[3:2], ddr_read_frame_loaded[0], ddr_read_frame_loaded[0]};
            read_loaded_sync <= read_loaded_meta;
        end
    end
    (* ASYNC_REG="TRUE" *) reg [3:0] source_valid_meta, source_valid_sync;
    always @(posedge pclk_div2) begin
        if (!core_rst_n) begin
            source_valid_meta <= 0;
            source_valid_sync <= 0;
        end else begin
            source_valid_meta <= {ddr_frame_ready[3:2], ddr_frame_ready[0], ddr_frame_ready[0]};
            source_valid_sync <= source_valid_meta;
        end
    end
    frame_event_cdc u_source_frame_event_cdc (
        .src_clk  (pixclk_in),
        .src_rst_n(rx_init_done_pix),
        .src_event(hdmi_640_complete),
        .dst_clk  (pclk_div2),
        .dst_rst_n(core_rst_n),
        .dst_count(source_frame_count_pcie)
    );
    wire [3:0] ddr_read_req, ddr_read_ack, ddr_line_full, ddr_read_en;
    wire [127:0] ddr_ch0_data, ddr_ch1_data, ddr_ch2_data, ddr_ch3_data;
    wire ddr_read_busy, ddr_read_ready;
    ddr_read_start u_ddr_read_start (
        .clk(pclk_div2),
        .rst_n(core_rst_n & ddr_init_done),
        .start(fpga_frame_read_start),
        .ack_async(ddr_read_ack | 4'b0010),
        .line_full(ddr_line_full | 4'b0010),
        .request(ddr_read_req),
        .busy(ddr_read_busy),
        .ready(ddr_read_ready)
    );
    pcie_img_select #(
        .PAIRED_HDMI(1)
    ) u_ddr_quad_select (
        .clk(pclk_div2),
        .rst_n(core_rst_n),
        .dma_sim_vs(ddr_read_busy),
        .line_full_flag(&(ddr_line_full | 4'b0010)),
        .ch0_data_req(ddr_read_en[0]),
        .ch0_data(ddr_ch0_data),
        .ch1_data_req(ddr_read_en[1]),
        .ch1_data(ddr_ch1_data),
        .ch2_data_req(ddr_read_en[2]),
        .ch2_data(ddr_ch2_data),
        .ch3_data_req(ddr_read_en[3]),
        .ch3_data(ddr_ch3_data),
        .dma_wr_data_req(o_dma_write_data_req),
        .dma_wr_data(i_dma_write_data)
    );

    //---------------------------------------------------
    // DDR3 IP例化
    //---------------------------------------------------
    always @(posedge core_clk or negedge ddr_init_done) begin
        if (!ddr_init_done) cnt <= 27'd0;
        else if (cnt >= TH_1S) cnt <= 27'd0;
        else cnt <= cnt + 27'd1;
    end

    always @(posedge core_clk or negedge ddr_init_done) begin
        if (!ddr_init_done) heart_beat_led <= 1'd1;
        else if (cnt >= TH_1S) heart_beat_led <= ~heart_beat_led;
    end
    ddr3 #(
        .MEM_ROW_WIDTH   (MEM_ROW_WIDTH),
        .MEM_COLUMN_WIDTH(MEM_COLUMN_WIDTH),
        .MEM_BANK_WIDTH  (MEM_BANK_WIDTH),
        .MEM_DQ_WIDTH    (MEM_DQ_WIDTH),
        .MEM_DM_WIDTH    (MEM_DQS_WIDTH),
        .MEM_DQS_WIDTH   (MEM_DQS_WIDTH),
        .CTRL_ADDR_WIDTH (CTRL_ADDR_WIDTH)
    ) I_ips_ddr_top (
        .ref_clk        (free_clk),
        .resetn         (board_rst_n),
        .core_clk       (core_clk),
        .pll_lock       (pll_lock),
        .phy_pll_lock   (phy_pll_lock),
        .gpll_lock      (gpll_lock),
        .rst_gpll_lock  (rst_gpll_lock),
        .ddrphy_cpd_lock(ddrphy_cpd_lock),
        .ddr_init_done  (ddr_init_done),

        .axi_awaddr   (axi_awaddr),
        .axi_awuser_ap(axi_awuser_ap),
        .axi_awuser_id(axi_awuser_id),
        .axi_awlen    (axi_awlen),
        .axi_awready  (axi_awready),
        .axi_awvalid  (axi_awvalid),

        .axi_wdata      (axi_wdata),
        .axi_wstrb      (axi_wstrb),
        .axi_wready     (axi_wready),
        .axi_wusero_id  (axi_wusero_id),
        .axi_wusero_last(axi_wusero_last),

        .axi_araddr   (axi_araddr),
        .axi_aruser_ap(axi_aruser_ap),
        .axi_aruser_id(axi_aruser_id),
        .axi_arlen    (axi_arlen),
        .axi_arready  (axi_arready),
        .axi_arvalid  (axi_arvalid),

        .axi_rdata (axi_rdata),
        .axi_rid   (axi_rid),
        .axi_rlast (axi_rlast),
        .axi_rvalid(axi_rvalid),

        .apb_clk   (1'b0),
        .apb_rst_n (1'b0),
        .apb_sel   (1'b0),
        .apb_enable(1'b0),
        .apb_addr  (8'd0),
        .apb_write (1'b0),
        .apb_ready (),
        .apb_wdata (16'd0),
        .apb_rdata (),

        .mem_cs_n(mem_cs_n),

        .mem_rst_n(mem_rst_n),
        .mem_ck   (mem_ck),
        .mem_ck_n (mem_ck_n),
        .mem_cke  (mem_cke),
        .mem_ras_n(mem_ras_n),
        .mem_cas_n(mem_cas_n),
        .mem_we_n (mem_we_n),
        .mem_odt  (mem_odt),
        .mem_a    (mem_a),
        .mem_ba   (mem_ba),
        .mem_dqs  (mem_dqs),
        .mem_dqs_n(mem_dqs_n),
        .mem_dq   (mem_dq),
        .mem_dm   (mem_dm),

        // 调试接口
        .dbg_gate_start   (1'b0),
        .dbg_cpd_start    (1'b0),
        .dbg_ddrphy_rst_n (1'b1),
        .dbg_gpll_scan_rst(1'b0),

        .samp_position_dyn_adj  (1'b0),
        .init_samp_position_even(16'd0),
        .init_samp_position_odd (16'd0),

        .wrcal_position_dyn_adj(1'b0),
        .init_wrcal_position   (16'd0),

        .force_read_clk_ctrl(1'b0),
        .init_slip_step     (8'd0),
        .init_read_clk_ctrl (6'd0),

        .debug_calib_ctrl    (),
        .dbg_dll_upd_state   (),
        .dbg_slice_status    (),
        .dbg_slice_state     (),
        .debug_data          (),
        .debug_gpll_dps_phase(),

        .dbg_rst_dps_state   (),
        .dbg_tran_err_rst_cnt(),
        .dbg_ddrphy_init_fail(),

        .debug_cpd_offset_adj(1'b0),
        .debug_cpd_offset_dir(1'b0),
        .debug_cpd_offset    (10'd0),
        .debug_dps_cnt_dir0  (),
        .debug_dps_cnt_dir1  (),

        .ck_dly_en       (1'b0),
        .init_ck_dly_step(8'd0),
        .ck_dly_set_bin  (),

        .align_error    (),
        .debug_rst_state(),
        .debug_cpd_state()

    );

    //---------------------------------------------------
    // AXI控制器例化
    //---------------------------------------------------
    wire [31:0] ddr_awaddr_bytes, ddr_araddr_bytes;
    wire [7:0] ddr_awlen, ddr_arlen;
    wire ddr_awid, ddr_arid;
    assign axi_awaddr = ddr_awaddr_bytes[CTRL_ADDR_WIDTH-1:0];
    assign axi_araddr = ddr_araddr_bytes[CTRL_ADDR_WIDTH-1:0];
    assign axi_awlen = ddr_awlen[3:0];
    assign axi_arlen = ddr_arlen[3:0];
    assign axi_awuser_id = {3'd0, ddr_awid};
    assign axi_aruser_id = {3'd0, ddr_arid};
    assign axi_awuser_ap = 1'b0;
    assign axi_aruser_ap = 1'b0;
    axi_ctrl_256_burst #(
        .FRAME_LEN  (28'd28800),
        .PAIRED_HDMI(1)
    ) u_ddr_frame_ctrl (
        .ARESETN(ddr_init_done),
        .ACLK(core_clk),
        .key(8'd0),
        .frame_ready(ddr_frame_ready),
        .read_frame_loaded(ddr_read_frame_loaded),
        .M_AXI_AWID(ddr_awid),
        .M_AXI_AWADDR(ddr_awaddr_bytes),
        .M_AXI_AWLEN(ddr_awlen),
        .M_AXI_AWVALID(axi_awvalid),
        .M_AXI_AWREADY(axi_awready),
        .M_AXI_WDATA(axi_wdata),
        .M_AXI_WSTRB(axi_wstrb),
        .M_AXI_WLAST(axi_ctrl_wlast),
        .M_AXI_WVALID(axi_ctrl_wvalid),
        .M_AXI_WREADY(axi_wready),
        .M_AXI_BID(1'b0),
        .M_AXI_BRESP(2'b0),
        .M_AXI_BUSER(1'b0),
        .M_AXI_BVALID(1'b1),
        .M_AXI_ARID(ddr_arid),
        .M_AXI_ARADDR(ddr_araddr_bytes),
        .M_AXI_ARLEN(ddr_arlen),
        .M_AXI_ARVALID(axi_arvalid),
        .M_AXI_ARREADY(axi_arready),
        .M_AXI_RID(1'b0),
        .M_AXI_RDATA(axi_rdata),
        .M_AXI_RRESP(2'b0),
        .M_AXI_RLAST(axi_rlast),
        .M_AXI_RUSER(1'b0),
        .M_AXI_RVALID(axi_rvalid),
        .ch0_wframe_pclk(pixclk_in),
        .ch0_wframe_rst_n(rx_init_done_pix),
        .ch0_wframe_vsync(paired_hdmi_vs),
        .ch0_wframe_data_valid(paired_hdmi_valid),
        .ch0_wframe_data(paired_hdmi_data),
        .ch0_rframe_pclk(pclk_div2),
        .ch0_rframe_rst_n(core_rst_n),
        .ch0_rframe_vsync(ddr_read_req[0]),
        .ch0_rframe_req(ddr_read_req[0]),
        .ch0_rframe_req_ack(ddr_read_ack[0]),
        .ch0_rframe_data_en(ddr_read_en[0]),
        .ch0_rframe_data(ddr_ch0_data),
        .ch0_read_line_full(ddr_line_full[0]),
        .ch1_wframe_pclk(pixclk_in),
        .ch1_wframe_rst_n(rx_init_done_pix),
        .ch1_wframe_vsync(1'b0),
        .ch1_wframe_data_valid(1'b0),
        .ch1_wframe_data(hdmi_640_data),
        .ch1_rframe_pclk(pclk_div2),
        .ch1_rframe_rst_n(core_rst_n),
        .ch1_rframe_vsync(ddr_read_req[1]),
        .ch1_rframe_req(1'b0),
        .ch1_rframe_req_ack(ddr_read_ack[1]),
        .ch1_rframe_data_en(ddr_read_en[1]),
        .ch1_rframe_data(ddr_ch1_data),
        .ch1_read_line_full(ddr_line_full[1]),
        .ch2_wframe_pclk(fmc_pixel_clk),
        .ch2_wframe_rst_n((board_rst_n & fmc_init_done)),
        .ch2_wframe_vsync(cam_640_vs),
        .ch2_wframe_data_valid(cam_640_valid),
        .ch2_wframe_data(cam_640_data),
        .ch2_rframe_pclk(pclk_div2),
        .ch2_rframe_rst_n(core_rst_n),
        .ch2_rframe_vsync(ddr_read_req[2]),
        .ch2_rframe_req(ddr_read_req[2]),
        .ch2_rframe_req_ack(ddr_read_ack[2]),
        .ch2_rframe_data_en(ddr_read_en[2]),
        .ch2_rframe_data(ddr_ch2_data),
        .ch2_read_line_full(ddr_line_full[2]),
        .ch3_wframe_pclk(fmc_pixel_clk),
        .ch3_wframe_rst_n((board_rst_n & fmc_init_done)),
        .ch3_wframe_vsync(cam_640_vs),
        .ch3_wframe_data_valid(cam_640_valid),
        .ch3_wframe_data(cam_640_data),
        .ch3_rframe_pclk(pclk_div2),
        .ch3_rframe_rst_n(core_rst_n),
        .ch3_rframe_vsync(ddr_read_req[3]),
        .ch3_rframe_req(ddr_read_req[3]),
        .ch3_rframe_req_ack(ddr_read_ack[3]),
        .ch3_rframe_data_en(ddr_read_en[3]),
        .ch3_rframe_data(ddr_ch3_data),
        .ch3_read_line_full(ddr_line_full[3])
    );

    //---------------------------------------------------
    // PCIe模块
    //---------------------------------------------------
    // 复位去抖
    hsst_rst_cross_sync_v1_0 #(
`ifdef IPS2L_PCIE_SPEEDUP_SIM
        .RST_CNTR_VALUE(16'h10)
`else
        .RST_CNTR_VALUE(16'hC000)
`endif
    ) u_refclk_buttonrstn_debounce (
        .clk     (ref_clk),
        .rstn_in (board_rst_n),
        .rstn_out(sync_button_rst_n)
    );

    hsst_rst_cross_sync_v1_0 #(
`ifdef IPS2L_PCIE_SPEEDUP_SIM
        .RST_CNTR_VALUE(16'h10)
`else
        .RST_CNTR_VALUE(16'hC000)
`endif
    ) u_refclk_perstn_debounce (
        .clk     (ref_clk),
        .rstn_in (perst_n),
        .rstn_out(sync_perst_n)
    );

    hsst_rst_sync_v1_0 u_ref_core_rstn_sync (
        .clk       (ref_clk),
        .rst_n     (core_rst_n),
        .sig_async (1'b1),
        .sig_synced(ref_core_rst_n)
    );

    hsst_rst_sync_v1_0 u_pclk_core_rstn_sync (
        .clk       (pclk),
        .rst_n     (core_rst_n),
        .sig_async (1'b1),
        .sig_synced(s_pclk_rstn)
    );

    always @(posedge ref_clk or negedge sync_perst_n) begin
        if (!sync_perst_n) begin
            ref_led_cnt <= 23'd0;
            ref_led <= 1'b1;
        end else if (smlh_link_up & rdlh_link_up) begin
            ref_led_cnt <= ref_led_cnt + 23'd1;
            if (&ref_led_cnt) ref_led <= ~ref_led;
        end
    end

    always @(posedge pclk or negedge s_pclk_rstn) begin
        if (!s_pclk_rstn) begin
            pclk_led_cnt <= 27'd0;
            pclk_led <= 1'b1;
        end else if (smlh_link_up & rdlh_link_up) begin
            pclk_led_cnt <= pclk_led_cnt + 27'd1;
            if (&pclk_led_cnt) pclk_led <= ~pclk_led;
        end
    end

    //---------------------------------------------------
    // PCIe DMA模块
    //---------------------------------------------------
    // DMA控制寄存器基地址 = 0x8000
    ips2l_pcie_dma #(
        .ASSIST_ENABLE(1),
        .DEVICE_TYPE   (DEVICE_TYPE),
        .AXIS_SLAVE_NUM   (AXIS_SLAVE_NUM)
    ) u_ips2l_pcie_dma (
        .assist_pix_clk  (pixclk_in),
        .assist_pix_rst_n(rx_init_done_pix),
        .assist_vsync    (hdmi_observe_vs),
        .assist_de       (hdmi_observe_de),
        .assist_rgb      (hdmi_observe_rgb),
        .clk             (pclk_div2),
        .rst_n           (core_rst_n),

        // 配置编号
        .i_cfg_pbus_num   (cfg_pbus_num),
        .i_cfg_pbus_dev_num  (cfg_pbus_dev_num),
        .i_cfg_max_rd_req_size (cfg_max_rd_req_size),
        .i_cfg_max_payload_size (cfg_max_payload_size),

        // AXI4-Stream主接口
        .i_axis_master_tvld (axis_master_tvalid_mem),
        .o_axis_master_trdy (axis_master_tready_mem),
        .i_axis_master_tdata(axis_master_tdata_mem),
        .i_axis_master_tkeep(axis_master_tkeep_mem),

        .i_axis_master_tlast(axis_master_tlast_mem),
        .i_axis_master_tuser(axis_master_tuser_mem),

        // AXI4-Stream从接口0
        .i_axis_slave0_trdy (axis_slave0_tready),
        .o_axis_slave0_tvld (dma_axis_slave0_tvalid),
        .o_axis_slave0_tdata(dma_axis_slave0_tdata),
        .o_axis_slave0_tlast(dma_axis_slave0_tlast),
        .o_axis_slave0_tuser(dma_axis_slave0_tuser),

        // AXI4-Stream从接口1
        .i_axis_slave1_trdy (axis_slave1_tready),
        .o_axis_slave1_tvld (axis_slave1_tvalid),
        .o_axis_slave1_tdata(axis_slave1_tdata),
        .o_axis_slave1_tlast(axis_slave1_tlast),
        .o_axis_slave1_tuser(axis_slave1_tuser),

        // AXI4-Stream从接口2
        .i_axis_slave2_trdy (axis_slave2_tready),
        .o_axis_slave2_tvld (axis_slave2_tvalid),
        .o_axis_slave2_tdata(axis_slave2_tdata),
        .o_axis_slave2_tlast(axis_slave2_tlast),
        .o_axis_slave2_tuser(axis_slave2_tuser),

        // 来自PCIe配置侧
        .i_cfg_ido_req_en(cfg_ido_req_en),
        .i_cfg_ido_cpl_en(cfg_ido_cpl_en),
        .i_xadm_ph_cdts  (xadm_ph_cdts),
        .i_xadm_pd_cdts  (xadm_pd_cdts),
        .i_xadm_nph_cdts (xadm_nph_cdts),
        .i_xadm_npd_cdts (xadm_npd_cdts),
        .i_xadm_cplh_cdts(xadm_cplh_cdts),
        .i_xadm_cpld_cdts(xadm_cpld_cdts),

        // APB接口
        .i_apb_psel          (p_sel_dma),
        .i_apb_paddr         (p_addr[8:0]),
        .i_apb_pwdata        (p_wdata),
        .i_apb_pstrb         (p_strb),
        .i_apb_pwrite        (p_we),
        .i_apb_penable       (p_ce),
        .o_apb_prdy          (p_rdy_dma),
        .o_apb_prdata        (p_rdata_dma),
        .o_cross_4kb_boundary(cross_4kb_boundary), // 4KB边界标志

        // DMA写数据接口
        .o_dma_write_data_req(o_dma_write_data_req),
        .o_dma_write_addr    (o_dma_write_addr),
        .i_dma_write_data    (i_dma_write_data),
        .i_source_frame_count(source_frame_count_pcie),
        .i_source_frame_ready(&source_valid_sync),
        .i_frame_read_ready  (ddr_read_ready),
        // HDMI 配对数据仅占用通道 0，通道 1 不启用。
        // 首块发送不等待未启用通道的 FIFO。
        .i_ddr_chunk_ready   (ddr_line_full | read_loaded_sync | 4'b0010),
        .o_fpga_frame_done   (fpga_frame_read_start)
    );

    assign p_rdy_cfg              = 1'b0;
    assign p_rdata_cfg            = 32'b0;

    assign axis_slave0_tvalid     = dma_axis_slave0_tvalid;
    assign axis_slave0_tlast      = dma_axis_slave0_tlast;
    assign axis_slave0_tuser      = dma_axis_slave0_tuser;
    assign axis_slave0_tdata      = dma_axis_slave0_tdata;

    assign axis_master_tvalid_mem = axis_master_tvalid;
    assign axis_master_tdata_mem  = axis_master_tdata;
    assign axis_master_tkeep_mem  = axis_master_tkeep;
    assign axis_master_tlast_mem  = axis_master_tlast;
    assign axis_master_tuser_mem  = axis_master_tuser;

    assign axis_master_tready     = axis_master_tready_mem;

    // PCIe顶层IP：HSSTLP地址范围0x0000~0x6000，PCIe基地址0x7000
    pcie_test u_ips2l_pcie_wrap (
        .button_rst_n  (1'b1),
        .power_up_rst_n(1'b1),
        .perst_n       (1'b1),

        // 时钟和复位信号
        .pclk      (pclk),
        .pclk_div2 (pclk_div2),
        .ref_clk   (ref_clk),
        .ref_clk_n (ref_clk_n),
        .ref_clk_p (ref_clk_p),
        .core_rst_n(core_rst_n),

        // 连接DBI配置空间的APB接口
        .p_sel  (p_sel_pcie),
        .p_strb (uart_p_strb),
        .p_addr (uart_p_addr),
        .p_wdata(uart_p_wdata),
        .p_ce   (uart_p_ce),
        .p_we   (uart_p_we),
        .p_rdy  (p_rdy_pcie),
        .p_rdata(p_rdata_pcie),

        // PHY差分信号
        .rxn              (rxn),
        .rxp              (rxp),
        .txn              (txn),
        .txp              (txp),
        .pcs_nearend_loop ({4{1'b0}}),
        .pma_nearend_ploop({4{1'b0}}),
        .pma_nearend_sloop({4{1'b0}}),

        // AXI4-Stream主接口
        .axis_master_tvalid(axis_master_tvalid),
        .axis_master_tready(axis_master_tready),
        .axis_master_tdata (axis_master_tdata),
        .axis_master_tkeep (axis_master_tkeep),

        .axis_master_tlast(axis_master_tlast),
        .axis_master_tuser(axis_master_tuser),

        // AXI4-Stream从接口0
        .axis_slave0_tready(axis_slave0_tready),
        .axis_slave0_tvalid(axis_slave0_tvalid),
        .axis_slave0_tdata (axis_slave0_tdata),
        .axis_slave0_tlast (axis_slave0_tlast),
        .axis_slave0_tuser (axis_slave0_tuser),

        // AXI4-Stream从接口1
        .axis_slave1_tready(axis_slave1_tready),
        .axis_slave1_tvalid(axis_slave1_tvalid),
        .axis_slave1_tdata (axis_slave1_tdata),
        .axis_slave1_tlast (axis_slave1_tlast),
        .axis_slave1_tuser (axis_slave1_tuser),

        // AXI4-Stream从接口2
        .axis_slave2_tready(axis_slave2_tready),
        .axis_slave2_tvalid(axis_slave2_tvalid),
        .axis_slave2_tdata (axis_slave2_tdata),
        .axis_slave2_tlast (axis_slave2_tlast),
        .axis_slave2_tuser (axis_slave2_tuser),

        .pm_xtlh_block_tlp(),

        .cfg_send_cor_err_mux(),
        .cfg_send_nf_err_mux (),
        .cfg_send_f_err_mux  (),
        .cfg_sys_err_rc      (),
        .cfg_aer_rc_err_mux  (),

        // RADM超时信号
        .radm_cpl_timeout(),

        // 配置信号
        .cfg_max_rd_req_size (cfg_max_rd_req_size),
        .cfg_bus_master_en   (),
        .cfg_max_payload_size(cfg_max_payload_size),
        .cfg_ext_tag_en      (),
        .cfg_rcb             (cfg_rcb),
        .cfg_mem_space_en    (),
        .cfg_pm_no_soft_rst  (),
        .cfg_crs_sw_vis_en   (),
        .cfg_no_snoop_en     (),
        .cfg_relax_order_en  (),
        .cfg_tph_req_en      (),
        .cfg_pf_tph_st_mode  (),
        .rbar_ctrl_update    (),
        .cfg_atomic_req_en   (),

        .cfg_pbus_num    (cfg_pbus_num),
        .cfg_pbus_dev_num(cfg_pbus_dev_num),

        // 调试信号
        .radm_idle                (),
        .radm_q_not_empty         (),
        .radm_qoverflow           (),
        .diag_ctrl_bus            (2'b0),
        .cfg_link_auto_bw_mux     (),
        .cfg_bw_mgt_mux           (),
        .cfg_pme_mux              (),
        .app_ras_des_sd_hold_ltssm(1'b0),
        .app_ras_des_tba_ctrl     (2'b0),

        .dyn_debug_info_sel(4'b0),
        .debug_info_mux    (),

        // 系统状态信号
        .smlh_link_up    (smlh_link_up),     // PCIe链路状态
        .rdlh_link_up    (rdlh_link_up),     // PCIe链路状态
        .smlh_ltssm_state(smlh_ltssm_state)
    );

    //---------------------------------------------------
    // HDMI 状态监控指示灯逻辑
    //---------------------------------------------------
    always @(posedge pclk_div2) begin
        if (!ddr_init_done) ch0_rframe_req <= 1'b0;
        else ch0_rframe_req <= fpga_frame_read_start;
    end

    reg vs_d1, vs_d2;
    wire       vs_edge;
    reg  [5:0] frame_cnt;
    // 终值事件先寄存，再驱动 LED 时钟使能，缩短计数译码到输出引脚的路径。
    // 避免帧计数译码直接驱动长距离输出连线。
    reg        hdmi_led_toggle_pending;

    // 1. 在像素时钟域下，对 VSYNC 信号打两拍，并提取上升沿
    always @(posedge pixclk_in) begin

        if (!rx_init_done_pix) begin
            vs_d1 <= 1'b0;
            vs_d2 <= 1'b0;
        end else begin
            vs_d1 <= vs_in;
            vs_d2 <= vs_d1;
        end
    end

    // 检测上升沿（每传来一帧图像，会产生一个脉冲）
    assign vs_edge = vs_d1 & ~vs_d2;

    // 2. 帧率计数器：如果是 60Hz 视频，每数到 30 帧翻转一次，LED 就会 1秒闪烁一次 (0.5s亮 0.5s灭)
    always @(posedge pixclk_in) begin

        if (!rx_init_done_pix) begin
            frame_cnt <= 6'd0;
            hdmi_led <= 1'b0;
            hdmi_led_toggle_pending <= 1'b0;
        end else begin
            hdmi_led_toggle_pending <= vs_edge && (frame_cnt >= 6'd29);
            if (vs_edge) begin
                if (frame_cnt >= 6'd29) frame_cnt <= 6'd0;
                else frame_cnt <= frame_cnt + 1'b1;
            end
            if (hdmi_led_toggle_pending) hdmi_led <= ~hdmi_led;
        end
    end

    //---------------------------------------------------
    // HDMI配置完成信号跨到像素时钟域的两拍同步
    // 保留原始 rx_init_done 作为输入来源，避免配置时钟域信号直接驱动
    // pixclk_in 域寄存器的复位/使能判断。
    //---------------------------------------------------
    always @(posedge pixclk_in) begin
        if (!board_rst_n) begin
            rx_init_done_pix_d1 <= 1'b0;
            rx_init_done_pix_d2 <= 1'b0;
        end else begin
            rx_init_done_pix_d1 <= rx_init_done;
            rx_init_done_pix_d2 <= rx_init_done_pix_d1;
        end
    end

    assign rx_init_done_pix = rx_init_done_pix_d2;

endmodule

`include "colorframe_rtl.vh"

`include "lane_assist_rtl.vh"

`include "tone_rtl.vh"
