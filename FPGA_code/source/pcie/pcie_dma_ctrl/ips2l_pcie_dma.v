module ips2l_pcie_dma #(
    parameter integer ASSIST_ENABLE  = 0,
    parameter         DEVICE_TYPE    = 3'd0,
    parameter integer AXIS_SLAVE_NUM = 3,
    parameter         ADDR_WIDTH     = 4'd12

) (
    input             clk,
    input             rst_n,
    input wire        assist_pix_clk,
    assist_pix_rst_n,
    assist_vsync,
    assist_de,
    input wire [23:0] assist_rgb,

    input [7:0] i_cfg_pbus_num,
    input [4:0] i_cfg_pbus_dev_num,
    input [2:0] i_cfg_max_rd_req_size,
    input [2:0] i_cfg_max_payload_size,

    //---------------------------------------------------
    // AXI-Stream主接口
    input               i_axis_master_tvld,
    output wire         o_axis_master_trdy,
    input       [127:0] i_axis_master_tdata,
    input       [  3:0] i_axis_master_tkeep,
    input               i_axis_master_tlast,
    input       [  7:0] i_axis_master_tuser,
    output wire [  2:0] o_trgt1_radm_pkt_halt,

    //---------------------------------------------------
    // AXI-Stream从接口0
    input               i_axis_slave0_trdy,
    output wire         o_axis_slave0_tvld,
    output wire [127:0] o_axis_slave0_tdata,
    output wire         o_axis_slave0_tlast,
    output wire         o_axis_slave0_tuser,
    // AXI-Stream从接口1
    input               i_axis_slave1_trdy,
    output wire         o_axis_slave1_tvld,
    output wire [127:0] o_axis_slave1_tdata,
    output wire         o_axis_slave1_tlast,
    output wire         o_axis_slave1_tuser,
    // AXI-Stream从接口2
    input               i_axis_slave2_trdy,
    output wire         o_axis_slave2_tvld,
    output wire [127:0] o_axis_slave2_tdata,
    output wire         o_axis_slave2_tlast,
    output wire         o_axis_slave2_tuser,
    //---------------------------------------------------
    // PCIe信用接口
    // 来自PCIe侧
    input               i_cfg_ido_req_en,
    input               i_cfg_ido_cpl_en,
    input       [  7:0] i_xadm_ph_cdts,
    input       [ 11:0] i_xadm_pd_cdts,
    input       [  7:0] i_xadm_nph_cdts,
    input       [ 11:0] i_xadm_npd_cdts,
    input       [  7:0] i_xadm_cplh_cdts,
    input       [ 11:0] i_xadm_cpld_cdts,
    //---------------------------------------------------
    // APB接口
    input               i_apb_psel,
    input       [  8:0] i_apb_paddr,
    input       [ 31:0] i_apb_pwdata,
    input       [  3:0] i_apb_pstrb,
    input               i_apb_pwrite,
    input               i_apb_penable,
    output wire         o_apb_prdy,
    output wire [ 31:0] o_apb_prdata,
    // 4KB边界跨越标志
    output wire         o_cross_4kb_boundary,

    //---------------------------------------------------
    // DMA写用户接口，方向为FPGA到PC
    output                  o_dma_write_data_req,
    output [ADDR_WIDTH-1:0] o_dma_write_addr,
    input  [         127:0] i_dma_write_data,
    input  [           7:0] i_source_frame_count,
    input                   i_source_frame_ready,
    input                   i_frame_read_ready,
    input  [           3:0] i_ddr_chunk_ready,

    //---------------------------------------------------
    // DMA读用户接口，方向为PC到FPGA
    input                   i_dma_read_data_req,
    input  [ADDR_WIDTH-1:0] i_dma_read_addr,
    output [         127:0] o_dma_read_data,

    // 每次发送新帧前产生DDR读帧启动脉冲
    output o_fpga_frame_done

    // 调试接口

);

    // RX到TX的内部连接信号
    wire [           2:0] mrd_tc;
    wire [           2:0] mrd_attr;
    wire [           9:0] mrd_length;
    wire [          15:0] mrd_id;
    wire [           7:0] mrd_tag;
    wire [          63:0] mrd_addr;

    wire                  cpld_req_vld;
    wire                  cpld_req_rdy;
    wire                  cpld_tx_rdy;
    // 完成包接收反馈
    wire                  cpld_rcv;
    wire [           7:0] cpld_tag;
    wire                  tag_full;
    // DMA控制器到TX侧信号
    wire                  user_define_header_flag;
    wire                  user_define_data_flag;
    // MWr请求和应答
    wire                  mwr32_req;
    wire                  mwr32_req_ack;
    wire                  mwr64_req;
    wire                  mwr64_req_ack;
    // MRd请求和应答
    wire                  mrd32_req;
    wire                  mrd32_req_ack;
    wire                  mrd64_req;
    wire                  mrd64_req_ack;
    // 请求信息
    wire [           9:0] req_length;
    wire [          63:0] req_addr;
    wire [          31:0] req_data;

    // AXI-Stream从接口0
    wire                  dma_axis_slave0_trdy;
    wire                  dma_axis_slave0_tvld;
    wire [         127:0] dma_axis_slave0_tdata;
    wire                  dma_axis_slave0_tlast;
    wire                  dma_axis_slave0_tuser;
    // AXI-Stream从接口1
    wire                  dma_axis_slave1_trdy;
    wire                  dma_axis_slave1_tvld;
    wire [         127:0] dma_axis_slave1_tdata;
    wire                  dma_axis_slave1_tlast;
    wire                  dma_axis_slave1_tuser;
    // AXI-Stream从接口2
    wire                  dma_axis_slave2_trdy;
    wire                  dma_axis_slave2_tvld;
    wire [         127:0] dma_axis_slave2_tdata;
    wire                  dma_axis_slave2_tlast;
    wire                  dma_axis_slave2_tuser;

    //---------------------------------------------------
    // BAR0读接口
    wire                  bar0_rd_clk_en  /*synthesis PAP_MARK_DEBUG="1"*/;
    wire [ADDR_WIDTH-1:0] bar0_rd_addr;
    wire [         127:0] bar0_rd_data  /*synthesis PAP_MARK_DEBUG="1"*/;
    // BAR1写接口
    wire                  bar1_wr_en  /*synthesis PAP_MARK_DEBUG="1"*/;
    wire [ADDR_WIDTH-1:0] bar1_wr_addr  /*synthesis PAP_MARK_DEBUG="1"*/;
    wire [         127:0] bar1_wr_data  /*synthesis PAP_MARK_DEBUG="1"*/;
    wire [          15:0] bar1_wr_byte_en  /*synthesis PAP_MARK_DEBUG="1"*/;
    wire                  ctrl_bar1_wr_en;
    wire [ADDR_WIDTH-1:0] ctrl_bar1_wr_addr;
    wire [         127:0] ctrl_bar1_wr_data;
    wire [          15:0] ctrl_bar1_wr_byte_en;
    // BAR2读接口
    wire                  bar2_rd_clk_en;
    wire [ADDR_WIDTH-1:0] bar2_rd_addr;
    wire [         127:0] bar2_rd_data;
    wire [         127:0] dma_write_data_to_tx;
    //---------------------------------------------------
    // TLP计数复位相关信号
    wire                  tx_restart;
    wire [          63:0] dma_check_result;
    // 调试接口 bus

    //---------------------------------------------------
    // 1：RX顶层例化，解析PCIe输入TLP和BAR访问
    //---------------------------------------------------
    // RX侧接收PCIe AXI-Stream主接口数据，解析MRd/MWr/CplD等TLP并输出BAR访问和读请求信息

    ips2l_pcie_dma_rx_top #(
        .ASSIST_ENABLE(ASSIST_ENABLE),
        .DEVICE_TYPE  (DEVICE_TYPE),
        .ADDR_WIDTH   (ADDR_WIDTH)
    ) u_ips2l_pcie_dma_rx_top (
        .clk                  (clk),
        .rst_n                (rst_n),
        .assist_pix_clk       (assist_pix_clk),
        .assist_pix_rst_n     (assist_pix_rst_n),
        .assist_vsync         (assist_vsync),
        .assist_de            (assist_de),
        .assist_rgb           (assist_rgb),
        .i_cfg_max_rd_req_size(i_cfg_max_rd_req_size),
        //---------------------------------------------------
        // AXI-Stream主接口
        .i_axis_master_tvld   (i_axis_master_tvld),
        .o_axis_master_trdy   (o_axis_master_trdy),
        .i_axis_master_tdata  (i_axis_master_tdata),
        .i_axis_master_tkeep  (i_axis_master_tkeep),
        .i_axis_master_tlast  (i_axis_master_tlast),
        .i_axis_master_tuser  (i_axis_master_tuser),
        .o_trgt1_radm_pkt_halt(o_trgt1_radm_pkt_halt),

        //---------------------------------------------------
        // BAR0读接口
        .i_bar0_rd_clk_en (bar0_rd_clk_en),
        .i_bar0_rd_addr   (bar0_rd_addr),
        .o_bar0_rd_data   (bar0_rd_data),
        // BAR2读接口
        .i_bar2_rd_clk_en (i_dma_read_data_req),
        .i_bar2_rd_addr   (i_dma_read_addr),
        .o_bar2_rd_data   (o_dma_read_data),
        // BAR1写接口
        .o_bar1_wr_en     (bar1_wr_en),
        .o_bar1_wr_addr   (bar1_wr_addr),
        .o_bar1_wr_data   (bar1_wr_data),
        .o_bar1_wr_byte_en(bar1_wr_byte_en),
        //---------------------------------------------------
        // 连接发送顶层
        // 读请求接收信息
        .o_mrd_tc         (mrd_tc),
        .o_mrd_attr       (mrd_attr),
        .o_mrd_length     (mrd_length),
        .o_mrd_id         (mrd_id),
        .o_mrd_tag        (mrd_tag),
        .o_mrd_addr       (mrd_addr),

        .o_cpld_req_vld    (cpld_req_vld),
        .i_cpld_req_rdy    (cpld_req_rdy),
        .i_cpld_tx_rdy     (cpld_tx_rdy),
        // 完成包接收反馈
        .o_cpld_rcv        (cpld_rcv),
        .o_cpld_tag        (cpld_tag),
        .i_tag_full        (tag_full),
        // TLP计数复位相关信号
        .o_dma_check_result(dma_check_result),
        .i_tx_restart      (tx_restart)

    );

    //---------------------------------------------------
    // 2：DMA控制器例化，管理APB配置和DMA命令
    //---------------------------------------------------
    // 控制器接收BAR1写入和APB访问，生成MWr/MRd命令请求、地址、长度和跨4KB边界标志

    ips2l_pcie_dma_controller #(
        .DEVICE_TYPE(DEVICE_TYPE),
        .ADDR_WIDTH (ADDR_WIDTH)
    ) u_ips2l_pcie_dma_controller (
        .clk                    (clk),
        .rst_n                  (rst_n),
        //---------------------------------------------------
        // BAR1写接口
        .i_bar1_wr_en           (ctrl_bar1_wr_en),
        .i_bar1_wr_addr         (ctrl_bar1_wr_addr),
        .i_bar1_wr_data         (ctrl_bar1_wr_data),
        .i_bar1_wr_byte_en      (ctrl_bar1_wr_byte_en),
        //---------------------------------------------------
        // APB接口
        .i_apb_psel             (i_apb_psel),
        .i_apb_paddr            (i_apb_paddr),
        .i_apb_pwdata           (i_apb_pwdata),
        .i_apb_pstrb            (i_apb_pstrb),
        .i_apb_pwrite           (i_apb_pwrite),
        .i_apb_penable          (i_apb_penable),
        .o_apb_prdy             (o_apb_prdy),
        .o_apb_prdata           (o_apb_prdata),
        //---------------------------------------------------
        .o_user_define_data_flag(user_define_data_flag),

        //---------------------------------------------------
        // 连接发送顶层
        // MWr请求和应答
        .o_mwr32_req         (mwr32_req),
        .i_mwr32_req_ack     (mwr32_req_ack),
        .o_mwr64_req         (mwr64_req),
        .i_mwr64_req_ack     (mwr64_req_ack),
        // MRd请求和应答
        .o_mrd32_req         (mrd32_req),
        .i_mrd32_req_ack     (mrd32_req_ack),
        .o_mrd64_req         (mrd64_req),
        .i_mrd64_req_ack     (mrd64_req_ack),
        // 请求信息
        .o_req_length        (req_length),
        .o_req_addr          (req_addr),
        .o_req_data          (req_data),
        .o_cross_4kb_boundary(o_cross_4kb_boundary),
        // TLP计数复位相关信号
        .i_dma_check_result  (dma_check_result),
        .o_tx_restart        (tx_restart)
    );

    //---------------------------------------------------
    // 3：TX顶层例化，生成PCIe发包数据
    //---------------------------------------------------
    // TX侧根据DMA命令、BAR读数据和RX侧读请求生成MWr、MRd和CplD发送数据

    ips2l_pcie_dma_tx_top #(

        .ADDR_WIDTH(ADDR_WIDTH)
    ) u_ips2l_pcie_dma_tx_top (
        .clk                    (clk),
        .rst_n                  (rst_n),
        .i_cfg_pbus_num         (i_cfg_pbus_num),
        .i_cfg_pbus_dev_num     (i_cfg_pbus_dev_num),
        .i_cfg_max_rd_req_size  (i_cfg_max_rd_req_size),
        .i_cfg_max_payload_size (i_cfg_max_payload_size),
        //---------------------------------------------------
        // AXI-Stream从接口0
        .i_axis_slave0_trdy     (dma_axis_slave0_trdy),
        .o_axis_slave0_tvld     (dma_axis_slave0_tvld),
        .o_axis_slave0_tdata    (dma_axis_slave0_tdata),
        .o_axis_slave0_tlast    (dma_axis_slave0_tlast),
        .o_axis_slave0_tuser    (dma_axis_slave0_tuser),
        // AXI-Stream从接口1
        .i_axis_slave1_trdy     (dma_axis_slave1_trdy),
        .o_axis_slave1_tvld     (dma_axis_slave1_tvld),
        .o_axis_slave1_tdata    (dma_axis_slave1_tdata),
        .o_axis_slave1_tlast    (dma_axis_slave1_tlast),
        .o_axis_slave1_tuser    (dma_axis_slave1_tuser),
        // AXI-Stream从接口2
        .i_axis_slave2_trdy     (dma_axis_slave2_trdy),
        .o_axis_slave2_tvld     (dma_axis_slave2_tvld),
        .o_axis_slave2_tdata    (dma_axis_slave2_tdata),
        .o_axis_slave2_tlast    (dma_axis_slave2_tlast),
        .o_axis_slave2_tuser    (dma_axis_slave2_tuser),
        //---------------------------------------------------
        // 来自DMA侧_controller
        .i_user_define_data_flag(user_define_data_flag),

        .i_mwr32_req    (mwr32_req),
        .o_mwr32_req_ack(mwr32_req_ack),
        .i_mwr64_req    (mwr64_req),
        .o_mwr64_req_ack(mwr64_req_ack),

        .i_mrd32_req    (mrd32_req),
        .o_mrd32_req_ack(mrd32_req_ack),
        .i_mrd64_req    (mrd64_req),
        .o_mrd64_req_ack(mrd64_req_ack),

        .i_req_length(req_length),
        .i_req_addr  (req_addr),
        .i_req_data  (req_data),

        //---------------------------------------------------
        // BAR0读接口
        .o_bar0_rd_clk_en(bar0_rd_clk_en),
        .o_bar0_rd_addr  (bar0_rd_addr),
        .i_bar0_rd_data  (bar0_rd_data),
        // BAR2读接口
        .o_bar2_rd_clk_en(o_dma_write_data_req),
        .o_bar2_rd_addr  (o_dma_write_addr),
        .i_bar2_rd_data  (dma_write_data_to_tx),
        //---------------------------------------------------
        // 来自RX顶层
        // 读请求接收信息
        .i_mrd_tc        (mrd_tc),
        .i_mrd_attr      (mrd_attr),
        .i_mrd_length    (mrd_length),
        .i_mrd_id        (mrd_id),
        .i_mrd_tag       (mrd_tag),
        .i_mrd_addr      (mrd_addr),

        .i_cpld_req_vld(cpld_req_vld),
        .o_cpld_req_rdy(cpld_req_rdy),
        .o_cpld_tx_rdy (cpld_tx_rdy),
        // 完成包接收反馈
        .i_cpld_rcv    (cpld_rcv),
        .i_cpld_tag    (cpld_tag),
        .o_tag_full    (tag_full),
        // TLP计数复位相关信号
        .i_tx_restart  (tx_restart)
        // 调试接口

    );

    //---------------------------------------------------
    // 4：FPGA主动图像MWr发送参数和状态
    //---------------------------------------------------
    // 这一块是工程新增的图像发送逻辑，用固定2048字节分块把一帧RGB565图像主动写到PC内存
    // 最后再向帧尾标志地址写入序号，让RK端知道完整一帧已经传输完成

    localparam [31:0] C_IMAGE_FRAME_BYTES   = 32'd1843200;
    localparam [15:0] C_IMAGE_CHUNKS        = 16'd900;        // 1843200 / 2048
    localparam [ 9:0] C_CHUNK_DW            = 10'd512;        // 每条MWr命令发送2048字节
    localparam [31:0] C_CHUNK_BYTES         = 32'd2048;
    localparam [21:0] C_FRAME_RESTART_GAP   = 22'd32768;
    // 图像块之间保留短间隔，避免连续 MWr 突发长期占用 RK PCIe 控制器。
    localparam [21:0] C_INTER_CHUNK_GAP     = 22'd64;
    // PCIe 发送未产生预期末拍时终止当前数据块。
    // 125 MHz 时钟下，1000000 周期约为 8 ms。
    localparam [21:0] C_CHUNK_WAIT_TIMEOUT  = 22'd1000000;
    localparam [31:0] C_DMA_MWR_CMD         = 32'h0100_0000;

    localparam [ 3:0] S_IMG_IDLE            = 4'd0;
    localparam [ 3:0] S_IMG_WAIT_GAP        = 4'd1;
    localparam [ 3:0] S_IMG_CHUNK_ADDR_LO   = 4'd2;
    localparam [ 3:0] S_IMG_CHUNK_ADDR_HI   = 4'd3;
    localparam [ 3:0] S_IMG_CHUNK_CMD       = 4'd4;
    localparam [ 3:0] S_IMG_WAIT_CHUNK      = 4'd5;
    localparam [ 3:0] S_IMG_FLAG_ADDR_LO    = 4'd6;
    localparam [ 3:0] S_IMG_FLAG_ADDR_HI    = 4'd7;
    localparam [ 3:0] S_IMG_FLAG_CMD        = 4'd8;
    localparam [ 3:0] S_IMG_WAIT_FLAG       = 4'd9;
    localparam [ 3:0] S_IMG_CHUNK_LO_GAP    = 4'd10;
    localparam [ 3:0] S_IMG_CHUNK_HI_GAP    = 4'd11;
    localparam [ 3:0] S_IMG_FLAG_LO_GAP     = 4'd12;
    localparam [ 3:0] S_IMG_FLAG_HI_GAP     = 4'd13;
    localparam [ 3:0] S_IMG_INTER_CHUNK_GAP = 4'd14;

    reg                   local_bar1_wr_en;
    reg  [ADDR_WIDTH-1:0] local_bar1_wr_addr;
    reg  [         127:0] local_bar1_wr_data;
    reg  [          15:0] local_bar1_wr_byte_en;

    reg  [          63:0] pc_wdata_base_addr0;
    reg  [          63:0] pc_wdata_base_addr1;
    reg                   stream_enable;
    reg                   img_abort_stream;
    reg  [           1:0] slot_busy;
    reg                   active_slot;
    reg                   next_slot;
    reg  [          31:0] slot_frame_word0;
    reg  [          31:0] slot_frame_word1;
    reg  [           3:0] img_state;
    reg  [          15:0] img_chunk_idx;
    reg  [          21:0] img_gap_cnt;
    reg  [          63:0] img_mwr_addr;
    reg  [           5:0] img_tlp_cnt;
    reg  [          21:0] img_wait_timeout_cnt;
    reg                   img_flag_data_phase;
    reg  [           7:0] img_frame_seq;
    reg  [          31:0] img_frame_seq_word;
    reg                   img_frame_start_pulse;
    reg                   img_frame_done_pulse;
    reg  [           7:0] active_source_frame;
    reg  [           7:0] last_sent_source_frame;
    // 主机开始一次新的采集会话时，先发送当前已经写入DDR的完整帧。
    // 这样即使视频帧事件在主机启动前已经发生，也不会让DMA永久等待计数变化。
    reg                   force_first_frame;

    wire                  host_bar1_full_dw_wr;
    wire                  host_stream_start;
    wire                  host_stream_stop;
    wire                  host_frame_ack;
    wire                  host_frame_ack_slot;
    wire                  host_frame_ack_valid;
    wire                  new_source_frame;
    wire                  dma_axis_slave2_tlast_fire;
    wire                  img_frame_end_fire;
    wire [          31:0] img_chunk_cmd_word;
    wire [          31:0] img_flag_cmd_word;
    wire [          63:0] img_flag_addr;
    wire [          63:0] active_slot_base_addr;
    wire [           5:0] img_chunk_tlp_total;
    wire                  frame_outstanding;
    reg  [          31:0] dbg_mwr_status  /*synthesis PAP_MARK_DEBUG="true"*/;
    reg  [          31:0] dbg_mwr_last_wr_data_l32  /*synthesis PAP_MARK_DEBUG="true"*/;

    assign host_bar1_full_dw_wr = (&bar1_wr_byte_en[3:0]) && bar1_wr_en;
    assign host_stream_start          = host_bar1_full_dw_wr &&
                                    (bar1_wr_addr[8:0] == 9'h030) &&
                                    (bar1_wr_data[31:0] == 32'hffff_ffff);
    assign host_stream_stop           = host_bar1_full_dw_wr &&
                                    (bar1_wr_addr[8:0] == 9'h030) &&
                                    (bar1_wr_data[31:0] != 32'hffff_ffff);
    assign host_frame_ack = host_bar1_full_dw_wr && (bar1_wr_addr[8:0] == 9'h034) && (bar1_wr_data[31:0] != 32'd0);
    assign host_frame_ack_slot = bar1_wr_data[8];
    assign host_frame_ack_valid       = host_frame_ack &&
                                    (host_frame_ack_slot ?
                                     (bar1_wr_data[31:0] == slot_frame_word1) :
                                     (bar1_wr_data[31:0] == slot_frame_word0));
    assign new_source_frame = (i_source_frame_count != last_sent_source_frame);
    assign dma_axis_slave2_tlast_fire = dma_axis_slave2_tvld && dma_axis_slave2_trdy && dma_axis_slave2_tlast;
    assign img_frame_end_fire = (img_state == S_IMG_WAIT_FLAG) && dma_axis_slave2_tlast_fire;
    assign img_chunk_cmd_word         = C_DMA_MWR_CMD |
                                    ((|img_mwr_addr[63:32]) ? 32'h0001_0000 : 32'h0) |
                                    {22'd0, (C_CHUNK_DW - 10'd1)};
    assign active_slot_base_addr = active_slot ? pc_wdata_base_addr1 : pc_wdata_base_addr0;
    assign img_flag_addr = active_slot_base_addr + {32'd0, C_IMAGE_FRAME_BYTES};
    assign img_flag_cmd_word = C_DMA_MWR_CMD | ((|img_flag_addr[63:32]) ? 32'h0001_0000 : 32'h0);
    assign img_chunk_tlp_total        = (i_cfg_max_payload_size == 3'd0) ? 6'd16 :
                                    (i_cfg_max_payload_size == 3'd1) ? 6'd8  :
                                    (i_cfg_max_payload_size == 3'd2) ? 6'd4  :
                                    (i_cfg_max_payload_size == 3'd3) ? 6'd2  : 6'd26;
    assign frame_outstanding = |slot_busy;

    assign ctrl_bar1_wr_en = local_bar1_wr_en ? local_bar1_wr_en : bar1_wr_en;
    assign ctrl_bar1_wr_addr = local_bar1_wr_en ? local_bar1_wr_addr : bar1_wr_addr;
    assign ctrl_bar1_wr_data = local_bar1_wr_en ? local_bar1_wr_data : bar1_wr_data;
    assign ctrl_bar1_wr_byte_en = local_bar1_wr_en ? local_bar1_wr_byte_en : bar1_wr_byte_en;

    assign dma_write_data_to_tx = img_flag_data_phase ? {96'd0, img_frame_seq_word} : i_dma_write_data;
    assign o_fpga_frame_done = img_frame_start_pulse;

    //---------------------------------------------------
    // 5：图像MWr调试状态记录
    //---------------------------------------------------
    // 记录主机触发、FPGA本地写配置、图像状态机进度和最后一次写入的数据低32位

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            dbg_mwr_status           <= 32'd0;
            dbg_mwr_last_wr_data_l32 <= 32'd0;
        end else begin
            if (host_bar1_full_dw_wr && (bar1_wr_addr[8:0] == 9'h030) && (bar1_wr_data[31:0] == 32'hffff_ffff))
                dbg_mwr_status[0] <= 1'b1;
            if (stream_enable) dbg_mwr_status[1] <= 1'b1;
            if (img_frame_start_pulse) dbg_mwr_status[2] <= 1'b1;
            if (local_bar1_wr_en) dbg_mwr_status[3] <= 1'b1;
            if (local_bar1_wr_en && (local_bar1_wr_addr[8:0] == 9'h110)) dbg_mwr_status[4] <= 1'b1;
            if (local_bar1_wr_en && (local_bar1_wr_addr[8:0] == 9'h120)) dbg_mwr_status[5] <= 1'b1;
            if (local_bar1_wr_en && (local_bar1_wr_addr[8:0] == 9'h100)) dbg_mwr_status[6] <= 1'b1;
            if (img_frame_done_pulse) dbg_mwr_status[7] <= 1'b1;

            dbg_mwr_status[11:8]  <= img_state;
            dbg_mwr_status[27:12] <= img_chunk_idx;
            dbg_mwr_status[31:28] <= local_bar1_wr_addr[3:0];

            if (local_bar1_wr_en) dbg_mwr_last_wr_data_l32 <= local_bar1_wr_data[31:0];
        end
    end

    //---------------------------------------------------
    // 6：主机写入的PC端图像基地址锁存
    //---------------------------------------------------
    // 主机通过BAR1寄存器写入低32位和高32位地址，本模块锁存为图像MWr目标基地址

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc_wdata_base_addr0 <= 64'd0;
            pc_wdata_base_addr1 <= 64'd0;
        end else begin
            if (host_bar1_full_dw_wr && (bar1_wr_addr[8:0] == 9'h110)) pc_wdata_base_addr0[31:0] <= bar1_wr_data[31:0];

            if (host_bar1_full_dw_wr && (bar1_wr_addr[8:0] == 9'h120)) pc_wdata_base_addr0[63:32] <= bar1_wr_data[31:0];

            if (host_bar1_full_dw_wr && (bar1_wr_addr[8:0] == 9'h038)) pc_wdata_base_addr1[31:0] <= bar1_wr_data[31:0];

            if (host_bar1_full_dw_wr && (bar1_wr_addr[8:0] == 9'h03c)) pc_wdata_base_addr1[63:32] <= bar1_wr_data[31:0];
        end
    end

    //---------------------------------------------------
    // 7：FPGA主动图像MWr触发标志
    //---------------------------------------------------
    // 主机写0xffffffff后持续使能，写0后在当前帧完成后停止

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) stream_enable <= 1'b0;
        else if (img_abort_stream) stream_enable <= 1'b0;
        else if (host_bar1_full_dw_wr && (bar1_wr_addr[8:0] == 9'h030))
            stream_enable <= (bar1_wr_data[31:0] == 32'hffff_ffff);
        else stream_enable <= stream_enable;
    end

    //---------------------------------------------------
    // 8：图像MWr状态机
    //---------------------------------------------------
    // 状态机依次写入目标地址、发送分块MWr命令、等待TLP完成，最后写入帧完成标志

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            local_bar1_wr_en       <= 1'b0;
            local_bar1_wr_addr     <= {ADDR_WIDTH{1'b0}};
            local_bar1_wr_data     <= 128'd0;
            local_bar1_wr_byte_en  <= 16'd0;
            img_state              <= S_IMG_IDLE;
            img_chunk_idx          <= 16'd0;
            img_gap_cnt            <= 22'd0;
            img_mwr_addr           <= 64'd0;
            img_tlp_cnt            <= 6'd0;
            img_wait_timeout_cnt   <= 22'd0;
            img_flag_data_phase    <= 1'b0;
            img_frame_seq          <= 8'd0;
            img_frame_seq_word     <= 32'd0;
            img_frame_start_pulse  <= 1'b0;
            img_frame_done_pulse   <= 1'b0;
            img_abort_stream       <= 1'b0;
            active_source_frame    <= 8'd0;
            last_sent_source_frame <= 8'd0;
            force_first_frame      <= 1'b0;
            slot_busy              <= 2'b00;
            active_slot            <= 1'b0;
            next_slot              <= 1'b0;
            slot_frame_word0       <= 32'd0;
            slot_frame_word1       <= 32'd0;
        end else begin
            local_bar1_wr_en      <= 1'b0;
            local_bar1_wr_addr    <= {ADDR_WIDTH{1'b0}};
            local_bar1_wr_data    <= 128'd0;
            local_bar1_wr_byte_en <= 16'd0;
            img_frame_start_pulse <= 1'b0;
            img_frame_done_pulse  <= 1'b0;
            img_abort_stream      <= 1'b0;

            if (host_stream_start) begin
                slot_busy <= 2'b00;
                next_slot <= 1'b0;
                slot_frame_word0 <= 32'd0;
                slot_frame_word1 <= 32'd0;
                force_first_frame <= 1'b1;
            end else if (host_stream_stop) begin
                slot_busy <= 2'b00;
                force_first_frame <= 1'b0;
            end else if (host_frame_ack_valid) begin
                slot_busy[host_frame_ack_slot] <= 1'b0;
            end

            case (img_state)
                S_IMG_IDLE: begin
                    img_chunk_idx        <= 16'd0;
                    img_mwr_addr         <= active_slot_base_addr;
                    img_tlp_cnt          <= 6'd0;
                    img_wait_timeout_cnt <= 22'd0;
                    img_flag_data_phase  <= 1'b0;
                    img_gap_cnt          <= 22'd0;

                    if (!stream_enable || host_stream_stop) begin
                        last_sent_source_frame <= i_source_frame_count;
                    end else if (i_source_frame_ready && (new_source_frame || force_first_frame) && !slot_busy[next_slot]) begin
                        active_slot           <= next_slot;
                        active_source_frame   <= i_source_frame_count;
                        force_first_frame     <= 1'b0;
                        img_mwr_addr          <= next_slot ? pc_wdata_base_addr1 : pc_wdata_base_addr0;
                        img_gap_cnt           <= C_FRAME_RESTART_GAP;
                        img_frame_start_pulse <= 1'b1;
                        img_state             <= S_IMG_WAIT_GAP;
                    end else if (i_source_frame_ready && (new_source_frame || force_first_frame) && !slot_busy[next_slot ^ 1'b1]) begin
                        active_slot           <= next_slot ^ 1'b1;
                        active_source_frame   <= i_source_frame_count;
                        force_first_frame     <= 1'b0;
                        img_mwr_addr          <= (next_slot ^ 1'b1) ? pc_wdata_base_addr1 : pc_wdata_base_addr0;
                        img_gap_cnt           <= C_FRAME_RESTART_GAP;
                        img_frame_start_pulse <= 1'b1;
                        img_state             <= S_IMG_WAIT_GAP;
                    end
                end

                S_IMG_WAIT_GAP: begin
                    if (img_gap_cnt != 22'd0) img_gap_cnt <= img_gap_cnt - 22'd1;
                    else if (i_frame_read_ready) begin
                        img_wait_timeout_cnt <= 22'd0;
                        img_state <= S_IMG_CHUNK_ADDR_LO;
                    end else if (img_wait_timeout_cnt >= C_CHUNK_WAIT_TIMEOUT) begin
                        img_abort_stream <= 1'b1;
                        img_wait_timeout_cnt <= 22'd0;
                        img_state <= S_IMG_IDLE;
                    end else img_wait_timeout_cnt <= img_wait_timeout_cnt + 22'd1;
                end

                S_IMG_CHUNK_ADDR_LO: begin
                    // 每块使用 128 字；两有效通道均缓存 160 字，或缓存全部剩余数据后再发送。
                    // 两个有效通道均满足缓存条件后再发送。
                    if ((img_chunk_idx < (C_IMAGE_CHUNKS/2)) ?
                    (&i_ddr_chunk_ready[1:0]) : (&i_ddr_chunk_ready[3:2])) begin
                        img_wait_timeout_cnt  <= 22'd0;
                        local_bar1_wr_en      <= 1'b1;
                        local_bar1_wr_addr    <= {{(ADDR_WIDTH - 9) {1'b0}}, 9'h110};
                        local_bar1_wr_data    <= {96'd0, img_mwr_addr[31:0]};
                        local_bar1_wr_byte_en <= 16'hffff;
                        img_state             <= S_IMG_CHUNK_LO_GAP;
                    end else if (img_wait_timeout_cnt >= C_CHUNK_WAIT_TIMEOUT) begin
                        img_abort_stream <= 1'b1;
                        img_wait_timeout_cnt <= 22'd0;
                        img_state <= S_IMG_IDLE;
                    end else img_wait_timeout_cnt <= img_wait_timeout_cnt + 22'd1;
                end

                S_IMG_CHUNK_LO_GAP: begin
                    img_state <= S_IMG_CHUNK_ADDR_HI;
                end

                S_IMG_CHUNK_ADDR_HI: begin
                    local_bar1_wr_en      <= 1'b1;
                    local_bar1_wr_addr    <= {{(ADDR_WIDTH - 9) {1'b0}}, 9'h120};
                    local_bar1_wr_data    <= {96'd0, img_mwr_addr[63:32]};
                    local_bar1_wr_byte_en <= 16'hffff;
                    img_state             <= S_IMG_CHUNK_HI_GAP;
                end

                S_IMG_CHUNK_HI_GAP: begin
                    img_state <= S_IMG_CHUNK_CMD;
                end

                S_IMG_CHUNK_CMD: begin
                    local_bar1_wr_en      <= 1'b1;
                    local_bar1_wr_addr    <= {{(ADDR_WIDTH - 9) {1'b0}}, 9'h100};
                    local_bar1_wr_data    <= {96'd0, img_chunk_cmd_word};
                    local_bar1_wr_byte_en <= 16'hffff;
                    img_tlp_cnt           <= 6'd0;
                    img_wait_timeout_cnt  <= 22'd0;
                    img_state             <= S_IMG_WAIT_CHUNK;
                end

                S_IMG_WAIT_CHUNK: begin
                    if (dma_axis_slave2_tlast_fire) begin
                        img_wait_timeout_cnt <= 22'd0;
                        if (img_tlp_cnt == (img_chunk_tlp_total - 6'd1)) begin
                            img_tlp_cnt <= 6'd0;
                            if (img_chunk_idx == (C_IMAGE_CHUNKS - 16'd1)) begin
                                img_frame_seq_word  <= 32'hA500_0000 |
                                                   (active_slot ? 32'h0000_0100 : 32'h0) |
                                                   {24'd0, active_source_frame};
                                img_flag_data_phase <= 1'b1;
                                img_state <= S_IMG_FLAG_ADDR_LO;
                            end else begin
                                img_chunk_idx <= img_chunk_idx + 16'd1;
                                img_mwr_addr  <= img_mwr_addr + {32'd0, C_CHUNK_BYTES};
                                img_gap_cnt   <= C_INTER_CHUNK_GAP;
                                img_state     <= S_IMG_INTER_CHUNK_GAP;
                            end
                        end else begin
                            img_tlp_cnt <= img_tlp_cnt + 6'd1;
                        end
                    end else if (img_wait_timeout_cnt >= C_CHUNK_WAIT_TIMEOUT) begin
                        // 发送超时后停止发出请求，等待主机重新下发启动命令。
                        img_abort_stream     <= 1'b1;
                        img_wait_timeout_cnt <= 22'd0;
                        img_tlp_cnt          <= 6'd0;
                        img_state            <= S_IMG_IDLE;
                    end else begin
                        img_wait_timeout_cnt <= img_wait_timeout_cnt + 22'd1;
                    end
                end

                S_IMG_INTER_CHUNK_GAP: begin
                    if (img_gap_cnt != 22'd0) img_gap_cnt <= img_gap_cnt - 22'd1;
                    else img_state <= S_IMG_CHUNK_ADDR_LO;
                end

                S_IMG_FLAG_ADDR_LO: begin
                    local_bar1_wr_en      <= 1'b1;
                    local_bar1_wr_addr    <= {{(ADDR_WIDTH - 9) {1'b0}}, 9'h110};
                    local_bar1_wr_data    <= {96'd0, img_flag_addr[31:0]};
                    local_bar1_wr_byte_en <= 16'hffff;
                    img_state             <= S_IMG_FLAG_LO_GAP;
                end

                S_IMG_FLAG_LO_GAP: begin
                    img_state <= S_IMG_FLAG_ADDR_HI;
                end

                S_IMG_FLAG_ADDR_HI: begin
                    local_bar1_wr_en      <= 1'b1;
                    local_bar1_wr_addr    <= {{(ADDR_WIDTH - 9) {1'b0}}, 9'h120};
                    local_bar1_wr_data    <= {96'd0, img_flag_addr[63:32]};
                    local_bar1_wr_byte_en <= 16'hffff;
                    img_state             <= S_IMG_FLAG_HI_GAP;
                end

                S_IMG_FLAG_HI_GAP: begin
                    img_state <= S_IMG_FLAG_CMD;
                end

                S_IMG_FLAG_CMD: begin
                    local_bar1_wr_en      <= 1'b1;
                    local_bar1_wr_addr    <= {{(ADDR_WIDTH - 9) {1'b0}}, 9'h100};
                    local_bar1_wr_data    <= {96'd0, img_flag_cmd_word};
                    local_bar1_wr_byte_en <= 16'hffff;
                    img_wait_timeout_cnt  <= 22'd0;
                    img_state             <= S_IMG_WAIT_FLAG;
                end

                S_IMG_WAIT_FLAG: begin
                    if (dma_axis_slave2_tlast_fire) begin
                        img_wait_timeout_cnt   <= 22'd0;
                        img_frame_seq          <= active_source_frame;
                        last_sent_source_frame <= active_source_frame;
                        slot_busy[active_slot] <= 1'b1;
                        if (active_slot) slot_frame_word1 <= img_frame_seq_word;
                        else slot_frame_word0 <= img_frame_seq_word;
                        next_slot            <= active_slot ^ 1'b1;
                        img_frame_done_pulse <= 1'b1;
                        img_chunk_idx        <= 16'd0;
                        img_mwr_addr         <= active_slot_base_addr;
                        img_flag_data_phase  <= 1'b0;
                        img_gap_cnt          <= C_FRAME_RESTART_GAP;
                        img_state            <= S_IMG_IDLE;
                    end else if (img_wait_timeout_cnt >= C_CHUNK_WAIT_TIMEOUT) begin
                        img_abort_stream     <= 1'b1;
                        img_wait_timeout_cnt <= 22'd0;
                        img_state            <= S_IMG_IDLE;
                    end else begin
                        img_wait_timeout_cnt <= img_wait_timeout_cnt + 22'd1;
                    end
                end

                default: begin
                    img_state <= S_IMG_IDLE;
                end
            endcase
        end
    end

    //---------------------------------------------------
    // 9：AXI-Stream发送通道数量适配
    //---------------------------------------------------
    // 根据AXIS_SLAVE_NUM选择1路、2路或3路发送接口连接方式，未使用通道固定为无效

    generate
        if (AXIS_SLAVE_NUM == 1) begin : axis_slave_num_1
            ips2l_pcie_dma_tlp_tx_mux #(
                .AXIS_SLAVE_NUM(AXIS_SLAVE_NUM)
            ) u_pcie_dma_tlp_tx_mux (
                .clk                    (clk),
                .rst_n                  (rst_n),
                //---------------------------------------------------
                // 来自DMA侧
                // AXI-Stream从接口0
                .o_dma_axis_slave0_trdy (dma_axis_slave0_trdy),
                .i_dma_axis_slave0_tvld (dma_axis_slave0_tvld),
                .i_dma_axis_slave0_tdata(dma_axis_slave0_tdata),
                .i_dma_axis_slave0_tlast(dma_axis_slave0_tlast),
                .i_dma_axis_slave0_tuser(dma_axis_slave0_tuser),
                // AXI-Stream从接口1
                .o_dma_axis_slave1_trdy (dma_axis_slave1_trdy),
                .i_dma_axis_slave1_tvld (dma_axis_slave1_tvld),
                .i_dma_axis_slave1_tdata(dma_axis_slave1_tdata),
                .i_dma_axis_slave1_tlast(dma_axis_slave1_tlast),
                .i_dma_axis_slave1_tuser(dma_axis_slave1_tuser),
                // AXI-Stream从接口2
                .o_dma_axis_slave2_trdy (dma_axis_slave2_trdy),
                .i_dma_axis_slave2_tvld (dma_axis_slave2_tvld),
                .i_dma_axis_slave2_tdata(dma_axis_slave2_tdata),
                .i_dma_axis_slave2_tlast(dma_axis_slave2_tlast),
                .i_dma_axis_slave2_tuser(dma_axis_slave2_tuser),
                // PCIe信用接口
                // 来自PCIe侧
                .i_cfg_ido_req_en       (i_cfg_ido_req_en),
                .i_cfg_ido_cpl_en       (i_cfg_ido_cpl_en),
                .i_xadm_ph_cdts         (i_xadm_ph_cdts),
                .i_xadm_pd_cdts         (i_xadm_pd_cdts),
                .i_xadm_nph_cdts        (i_xadm_nph_cdts),
                .i_xadm_npd_cdts        (i_xadm_npd_cdts),
                .i_xadm_cplh_cdts       (i_xadm_cplh_cdts),
                .i_xadm_cpld_cdts       (i_xadm_cpld_cdts),
                // PCIe侧AXI-Stream从接口0
                .i_pcie_axis_slave_trdy (i_axis_slave0_trdy),
                .o_pcie_axis_slave_tvld (o_axis_slave0_tvld),
                .o_pcie_axis_slave_tdata(o_axis_slave0_tdata),
                .o_pcie_axis_slave_tlast(o_axis_slave0_tlast),
                .o_pcie_axis_slave_tuser(o_axis_slave0_tuser)
            );

            assign o_axis_slave1_tvld  = 1'b0;
            assign o_axis_slave1_tdata = 128'b0;
            assign o_axis_slave1_tlast = 1'b0;
            assign o_axis_slave1_tuser = 1'b0;

            assign o_axis_slave2_tvld  = 1'b0;
            assign o_axis_slave2_tdata = 128'b0;
            assign o_axis_slave2_tlast = 1'b0;
            assign o_axis_slave2_tuser = 1'b0;
        end else if (AXIS_SLAVE_NUM == 2) begin : axis_slave_num_2
            ips2l_pcie_dma_tlp_tx_mux #(
                .AXIS_SLAVE_NUM(AXIS_SLAVE_NUM)
            ) u_pcie_dma_tlp_tx_mux (
                .clk                    (clk),
                .rst_n                  (rst_n),
                //---------------------------------------------------
                // 来自DMA侧
                // AXI-Stream从接口0
                .o_dma_axis_slave0_trdy (),
                .i_dma_axis_slave0_tvld (1'b0),
                .i_dma_axis_slave0_tdata(128'b0),
                .i_dma_axis_slave0_tlast(1'b0),
                .i_dma_axis_slave0_tuser(1'b0),
                // AXI-Stream从接口1
                .o_dma_axis_slave1_trdy (dma_axis_slave1_trdy),
                .i_dma_axis_slave1_tvld (dma_axis_slave1_tvld),
                .i_dma_axis_slave1_tdata(dma_axis_slave1_tdata),
                .i_dma_axis_slave1_tlast(dma_axis_slave1_tlast),
                .i_dma_axis_slave1_tuser(dma_axis_slave1_tuser),
                // AXI-Stream从接口2
                .o_dma_axis_slave2_trdy (dma_axis_slave2_trdy),
                .i_dma_axis_slave2_tvld (dma_axis_slave2_tvld),
                .i_dma_axis_slave2_tdata(dma_axis_slave2_tdata),
                .i_dma_axis_slave2_tlast(dma_axis_slave2_tlast),
                .i_dma_axis_slave2_tuser(dma_axis_slave2_tuser),
                // PCIe信用接口
                // 来自PCIe侧
                .i_cfg_ido_req_en       (i_cfg_ido_req_en),
                .i_cfg_ido_cpl_en       (i_cfg_ido_cpl_en),
                .i_xadm_ph_cdts         (i_xadm_ph_cdts),
                .i_xadm_pd_cdts         (i_xadm_pd_cdts),
                .i_xadm_nph_cdts        (i_xadm_nph_cdts),
                .i_xadm_npd_cdts        (i_xadm_npd_cdts),
                .i_xadm_cplh_cdts       (i_xadm_cplh_cdts),
                .i_xadm_cpld_cdts       (i_xadm_cpld_cdts),
                // PCIe侧AXI-Stream从接口0
                .i_pcie_axis_slave_trdy (i_axis_slave1_trdy),
                .o_pcie_axis_slave_tvld (o_axis_slave1_tvld),
                .o_pcie_axis_slave_tdata(o_axis_slave1_tdata),
                .o_pcie_axis_slave_tlast(o_axis_slave1_tlast),
                .o_pcie_axis_slave_tuser(o_axis_slave1_tuser)
            );

            assign dma_axis_slave0_trdy = i_axis_slave0_trdy;
            assign o_axis_slave0_tvld   = dma_axis_slave0_tvld;
            assign o_axis_slave0_tdata  = dma_axis_slave0_tdata;
            assign o_axis_slave0_tlast  = dma_axis_slave0_tlast;
            assign o_axis_slave0_tuser  = dma_axis_slave0_tuser;

            assign o_axis_slave2_tvld   = 1'b0;
            assign o_axis_slave2_tdata  = 128'b0;
            assign o_axis_slave2_tlast  = 1'b0;
            assign o_axis_slave2_tuser  = 1'b0;
        end else if (AXIS_SLAVE_NUM == 3) begin : axis_slave_num_3
            assign dma_axis_slave0_trdy = i_axis_slave0_trdy;
            assign o_axis_slave0_tvld   = dma_axis_slave0_tvld;
            assign o_axis_slave0_tdata  = dma_axis_slave0_tdata;
            assign o_axis_slave0_tlast  = dma_axis_slave0_tlast;
            assign o_axis_slave0_tuser  = dma_axis_slave0_tuser;

            assign dma_axis_slave1_trdy = i_axis_slave1_trdy;
            assign o_axis_slave1_tvld   = dma_axis_slave1_tvld;
            assign o_axis_slave1_tdata  = dma_axis_slave1_tdata;
            assign o_axis_slave1_tlast  = dma_axis_slave1_tlast;
            assign o_axis_slave1_tuser  = dma_axis_slave1_tuser;

            assign dma_axis_slave2_trdy = i_axis_slave2_trdy;
            assign o_axis_slave2_tvld   = dma_axis_slave2_tvld;
            assign o_axis_slave2_tdata  = dma_axis_slave2_tdata;
            assign o_axis_slave2_tlast  = dma_axis_slave2_tlast;
            assign o_axis_slave2_tuser  = dma_axis_slave2_tuser;
        end
    endgenerate

endmodule
