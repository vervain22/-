
module axi_ctrl_256_burst #(
    parameter PAIRED_HDMI     = 0,
    parameter MEM_DATA_BITS   = 128,
    parameter DATA_WIDTH      = 128,
    parameter READ_DATA_BITS  = 128,
    parameter WRITE_DATA_BITS = 16,
    parameter ADDR_BITS       = 28,
    parameter BUSRT_BITS      = 10,
    parameter BURST_SIZE      = 256,
    parameter FRAME_LEN       = 28'd28800  // 帧字数：1920×1080×16/128=259200
) (
    // 时钟与复位
    input ARESETN,
    input ACLK,

    // AXI 主接口写地址
    output [ 0:0] M_AXI_AWID,
    output [31:0] M_AXI_AWADDR,
    output [ 7:0] M_AXI_AWLEN,    // 突发长度：0～255
    output [ 2:0] M_AXI_AWSIZE,   // 突发大小编码：100
    output [ 1:0] M_AXI_AWBURST,  // 突发类型：固定为 2'b01，地址递增
    output        M_AXI_AWLOCK,   // 锁定属性：固定为 2'b00
    output [ 3:0] M_AXI_AWCACHE,  // 缓存属性：固定为 2'b0011
    output [ 2:0] M_AXI_AWPROT,   // 保护属性：固定为 2'b000
    output [ 3:0] M_AXI_AWQOS,    // 服务质量：固定为 2'b0000
    output [ 0:0] M_AXI_AWUSER,   // 用户信息：固定为 32'd0
    output        M_AXI_AWVALID,
    input         M_AXI_AWREADY,

    // AXI 主接口写数据
    output [  DATA_WIDTH-1:0] M_AXI_WDATA,
    output [DATA_WIDTH/8-1:0] M_AXI_WSTRB,
    output                    M_AXI_WLAST,
    output [             0:0] M_AXI_WUSER,
    output                    M_AXI_WVALID,
    input                     M_AXI_WREADY,

    // AXI 主接口写应答
    input  [0:0] M_AXI_BID,
    input  [1:0] M_AXI_BRESP,
    input  [0:0] M_AXI_BUSER,
    input        M_AXI_BVALID,
    output       M_AXI_BREADY,

    // AXI 主接口读地址
    output [ 0:0] M_AXI_ARID,
    output [31:0] M_AXI_ARADDR,
    output [ 7:0] M_AXI_ARLEN,
    output [ 2:0] M_AXI_ARSIZE,
    output [ 1:0] M_AXI_ARBURST,
    output [ 1:0] M_AXI_ARLOCK,
    output [ 3:0] M_AXI_ARCACHE,
    output [ 2:0] M_AXI_ARPROT,
    output [ 3:0] M_AXI_ARQOS,
    output [ 0:0] M_AXI_ARUSER,
    output        M_AXI_ARVALID,
    input         M_AXI_ARREADY,

    // AXI 主接口读数据
    input  [           0:0] M_AXI_RID,
    input  [DATA_WIDTH-1:0] M_AXI_RDATA,
    input  [           1:0] M_AXI_RRESP,
    input                   M_AXI_RLAST,
    input  [           0:0] M_AXI_RUSER,
    input                   M_AXI_RVALID,
    output                  M_AXI_RREADY,

    // 按键输入
    input [7:0] key,
    // 通道 0 读写
    input ch0_wframe_pclk,
    input ch0_wframe_rst_n,
    input ch0_wframe_vsync,  //注意这里使用的场同步信号为高电平
    input ch0_wframe_data_valid,
    input [(PAIRED_HDMI ? 32 : WRITE_DATA_BITS)-1:0] ch0_wframe_data,

    input                       ch0_rframe_pclk,
    input                       ch0_rframe_rst_n,
    input                       ch0_rframe_vsync,
    input                       ch0_rframe_req,
    output                      ch0_rframe_req_ack,
    input                       ch0_rframe_data_en,
    output [READ_DATA_BITS-1:0] ch0_rframe_data,
    output                      ch0_rframe_data_valid,
    output                      ch0_read_line_full,

    // 通道 1 读写
    input                       ch1_wframe_pclk,
    input                       ch1_wframe_rst_n,
    input                       ch1_wframe_vsync,
    input                       ch1_wframe_data_valid,
    input [WRITE_DATA_BITS-1:0] ch1_wframe_data,

    input                       ch1_rframe_pclk,
    input                       ch1_rframe_rst_n,
    input                       ch1_rframe_vsync,
    input                       ch1_rframe_req,
    output                      ch1_rframe_req_ack,
    input                       ch1_rframe_data_en,
    output [READ_DATA_BITS-1:0] ch1_rframe_data,
    output                      ch1_rframe_data_valid,
    output                      ch1_read_line_full,

    // 通道 2 读写
    input                       ch2_wframe_pclk,
    input                       ch2_wframe_rst_n,
    input                       ch2_wframe_vsync,
    input                       ch2_wframe_data_valid,
    input [WRITE_DATA_BITS-1:0] ch2_wframe_data,

    input                       ch2_rframe_pclk,
    input                       ch2_rframe_rst_n,
    input                       ch2_rframe_vsync,
    input                       ch2_rframe_req,
    output                      ch2_rframe_req_ack,
    input                       ch2_rframe_data_en,
    output [READ_DATA_BITS-1:0] ch2_rframe_data,
    output                      ch2_rframe_data_valid,
    output                      ch2_read_line_full,

    // 通道 3 读写
    input                       ch3_wframe_pclk,
    input                       ch3_wframe_rst_n,
    input                       ch3_wframe_vsync,
    input                       ch3_wframe_data_valid,
    input [WRITE_DATA_BITS-1:0] ch3_wframe_data,

    input                           ch3_rframe_pclk,
    input                           ch3_rframe_rst_n,
    input                           ch3_rframe_vsync,
    input                           ch3_rframe_req,
    output                          ch3_rframe_req_ack,
    input                           ch3_rframe_data_en,
    output     [READ_DATA_BITS-1:0] ch3_rframe_data,
    output                          ch3_rframe_data_valid,
    output                          ch3_read_line_full,
    output reg [               3:0] frame_ready,
    output reg [               3:0] read_frame_loaded
);

    //---------------------------------------------------
    //信号定义
    //---------------------------------------------------
    //通道0
    wire                         ch0_wr_burst_data_req;
    wire                         ch0_wr_burst_finish;
    wire                         ch0_rd_burst_finish;
    wire                         ch0_rd_burst_req;
    wire                         ch0_wr_burst_req;
    wire [     BUSRT_BITS - 1:0] ch0_rd_burst_len;
    wire [     BUSRT_BITS - 1:0] ch0_wr_burst_len;
    wire [      ADDR_BITS - 1:0] ch0_rd_burst_addr;
    wire [      ADDR_BITS - 1:0] ch0_wr_burst_addr;
    wire                         ch0_rd_burst_data_valid;
    wire [MEM_DATA_BITS - 1 : 0] ch0_rd_burst_data;
    wire [MEM_DATA_BITS - 1 : 0] ch0_wr_burst_data;

    wire                         ch0_read_req;
    wire                         ch0_read_req_ack;
    wire                         ch0_read_en;
    wire [                 15:0] ch0_read_data;
    wire                         ch0_write_en;
    wire [                 15:0] ch0_write_data;
    wire                         ch0_write_req;
    wire                         ch0_write_req_ack;
    wire [                  1:0] ch0_write_addr_index;
    wire [                  1:0] ch0_read_addr_index;

    //通道1
    wire                         ch1_wr_burst_data_req;
    wire                         ch1_wr_burst_finish;
    wire                         ch1_rd_burst_finish;
    wire                         ch1_rd_burst_req;
    wire                         ch1_wr_burst_req;
    wire [     BUSRT_BITS - 1:0] ch1_rd_burst_len;
    wire [     BUSRT_BITS - 1:0] ch1_wr_burst_len;
    wire [      ADDR_BITS - 1:0] ch1_rd_burst_addr;
    wire [      ADDR_BITS - 1:0] ch1_wr_burst_addr;
    wire                         ch1_rd_burst_data_valid;
    wire [MEM_DATA_BITS - 1 : 0] ch1_rd_burst_data;
    wire [MEM_DATA_BITS - 1 : 0] ch1_wr_burst_data;
    wire                         ch1_read_req;
    wire                         ch1_read_req_ack;
    wire                         ch1_read_en;
    wire [                 15:0] ch1_read_data;
    wire                         ch1_write_en;
    wire [                 15:0] ch1_write_data;
    wire                         ch1_write_req;
    wire                         ch1_write_req_ack;
    wire [                  1:0] ch1_write_addr_index;
    wire [                  1:0] ch1_read_addr_index;

    //通道2
    wire                         ch2_wr_burst_data_req;
    wire                         ch2_wr_burst_finish;
    wire                         ch2_rd_burst_finish;
    wire                         ch2_rd_burst_req;
    wire                         ch2_wr_burst_req;
    wire [     BUSRT_BITS - 1:0] ch2_rd_burst_len;
    wire [     BUSRT_BITS - 1:0] ch2_wr_burst_len;
    wire [      ADDR_BITS - 1:0] ch2_rd_burst_addr;
    wire [      ADDR_BITS - 1:0] ch2_wr_burst_addr;
    wire                         ch2_rd_burst_data_valid;
    wire [MEM_DATA_BITS - 1 : 0] ch2_rd_burst_data;
    wire [MEM_DATA_BITS - 1 : 0] ch2_wr_burst_data;

    wire                         ch2_read_req;
    wire                         ch2_read_req_ack;
    wire                         ch2_read_en;
    wire [                 15:0] ch2_read_data;
    wire                         ch2_write_en;
    wire [                 15:0] ch2_write_data;
    wire                         ch2_write_req;
    wire                         ch2_write_req_ack;
    wire [                  1:0] ch2_write_addr_index;
    wire [                  1:0] ch2_read_addr_index;

    //通道3
    wire                         ch3_wr_burst_data_req;
    wire                         ch3_wr_burst_finish;
    wire                         ch3_rd_burst_finish;
    wire                         ch3_rd_burst_req;
    wire                         ch3_wr_burst_req;
    wire [     BUSRT_BITS - 1:0] ch3_rd_burst_len;
    wire [     BUSRT_BITS - 1:0] ch3_wr_burst_len;
    wire [      ADDR_BITS - 1:0] ch3_rd_burst_addr;
    wire [      ADDR_BITS - 1:0] ch3_wr_burst_addr;
    wire                         ch3_rd_burst_data_valid;
    wire [MEM_DATA_BITS - 1 : 0] ch3_rd_burst_data;
    wire [MEM_DATA_BITS - 1 : 0] ch3_wr_burst_data;

    wire                         ch3_read_req;
    wire                         ch3_read_req_ack;
    wire                         ch3_read_en;
    wire [                 15:0] ch3_read_data;
    wire                         ch3_write_en;
    wire [                 15:0] ch3_write_data;
    wire                         ch3_write_req;
    wire                         ch3_write_req_ack;
    wire [                  1:0] ch3_write_addr_index;
    wire [                  1:0] ch3_read_addr_index;

    wire                         wr_burst_data_req;
    wire                         wr_burst_finish;
    wire                         rd_burst_finish;
    wire                         rd_burst_req;
    wire                         wr_burst_req;
    wire [     BUSRT_BITS - 1:0] rd_burst_len;
    wire [     BUSRT_BITS - 1:0] wr_burst_len;
    wire [      ADDR_BITS - 1:0] rd_burst_addr;
    wire [      ADDR_BITS - 1:0] wr_burst_addr;
    wire                         rd_burst_data_valid;
    wire [MEM_DATA_BITS - 1 : 0] rd_burst_data;
    wire [MEM_DATA_BITS - 1 : 0] wr_burst_data;

    //---------------------------------------------------
    //摄像头的帧开始 就开始切换地址
    //---------------------------------------------------
    // 28800 个数据字全部写入 DDR 后才发布缓存，不在 VSYNC 时提前发布。
    wire [                  3:0] frame_write_finish;
    wire                         ch0_write_overflow;
    (* ASYNC_REG="TRUE" *) reg overflow_meta, overflow_sync;
    always @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            overflow_meta <= 0;
            overflow_sync <= 0;
        end else begin
            overflow_meta <= ch0_write_overflow;
            overflow_sync <= overflow_meta;
        end
    end
    wire [3:0] frame_read_finish;
    (* ASYNC_REG="TRUE" *) reg [3:0] read_req_meta, read_req_sync;
    (* ASYNC_REG="TRUE" *) reg [7:0] write_bank_meta, write_bank_sync;
    reg [7:0] published_bank;
    localparam [ADDR_BITS-1:0] HDMI_LEN   = FRAME_LEN * (PAIRED_HDMI ? 2 : 1);
    localparam [ADDR_BITS-1:0] HDMI_BASE1 = HDMI_LEN, HDMI_BASE2 = HDMI_LEN * 2, HDMI_BASE3 = HDMI_LEN * 3;
    reg [1:0] paired_read_bank;
    reg paired_read_locked, paired_req_d;
    wire [1:0] ch0_bank_for_read = PAIRED_HDMI ? paired_read_bank : published_bank[1:0];
    always @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            paired_read_bank <= 0;
            paired_read_locked <= 0;
            paired_req_d <= 0;
        end else begin
            paired_req_d <= read_req_sync[0];
            if (read_req_sync[0] && !paired_req_d) begin
                paired_read_bank   <= published_bank[1:0];
                paired_read_locked <= 1;
            end else if (frame_read_finish[0]) paired_read_locked <= 0;
        end
    end
    always @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            write_bank_meta <= 0;
            write_bank_sync <= 0;
            published_bank <= 0;
            frame_ready <= 0;
            read_req_meta <= 0;
            read_req_sync <= 0;
            read_frame_loaded <= 0;
        end else begin
            write_bank_meta <= {ch3_write_addr_index, ch2_write_addr_index, ch1_write_addr_index, ch0_write_addr_index};
            write_bank_sync <= write_bank_meta;
            read_req_meta <= {ch3_rframe_req, ch2_rframe_req, ch1_rframe_req, ch0_rframe_req};
            read_req_sync <= read_req_meta;
            read_frame_loaded <= (read_frame_loaded | frame_read_finish) & ~read_req_sync;
            if (frame_write_finish[0] && (!PAIRED_HDMI || !overflow_sync)) begin
                published_bank[1:0] <= write_bank_sync[1:0];
                frame_ready[0] <= 1;
            end
            if (frame_write_finish[1]) begin
                published_bank[3:2] <= write_bank_sync[3:2];
                frame_ready[1] <= 1;
            end
            if (frame_write_finish[2]) begin
                published_bank[5:4] <= write_bank_sync[5:4];
                frame_ready[2] <= 1;
            end
            if (frame_write_finish[3]) begin
                published_bank[7:6] <= write_bank_sync[7:6];
                frame_ready[3] <= 1;
            end
        end
    end
    // 摄像头产生写请求及写缓存编号
    //通道0
    generate
        if (PAIRED_HDMI) begin : Gen_PROTECTED_HDMI
            protected_frame_writer writer (
                .rst(~ch0_wframe_rst_n),
                .pclk(ch0_wframe_pclk),
                .vsync(ch0_wframe_vsync),
                .write_req_ack(ch0_write_req_ack),
                .read_locked(paired_read_locked),
                .read_bank(paired_read_bank),
                .published_valid(frame_ready[0]),
                .published_bank(published_bank[1:0]),
                .write_req(ch0_write_req),
                .write_bank(ch0_write_addr_index)
            );
        end else begin : Gen_ORIGINAL_HDMI
            cmos_write_req_gen writer (
                .rst(~ch0_wframe_rst_n),
                .pclk(ch0_wframe_pclk),
                .cmos_vsync(ch0_wframe_vsync),
                .write_req(ch0_write_req),
                .write_addr_index(ch0_write_addr_index),
                .read_addr_index(),
                .write_req_ack(ch0_write_req_ack)
            );
        end
    endgenerate

    //通道1
    cmos_write_req_gen cmos_write_req_gen_m1 (
        .rst             (~ch1_wframe_rst_n),
        .pclk            (ch1_wframe_pclk),
        .cmos_vsync      (ch1_wframe_vsync),
        .write_req       (ch1_write_req),
        .write_addr_index(ch1_write_addr_index),
        .read_addr_index (),
        .write_req_ack   (ch1_write_req_ack)
    );

    //通道2
    cmos_write_req_gen cmos_write_req_gen_m2 (
        .rst             (~ch2_wframe_rst_n),
        .pclk            (ch2_wframe_pclk),
        .cmos_vsync      (ch2_wframe_vsync),
        .write_req       (ch2_write_req),
        .write_addr_index(ch2_write_addr_index),
        .read_addr_index (),
        .write_req_ack   (ch2_write_req_ack)
    );

    //通道3
    cmos_write_req_gen cmos_write_req_gen_m3 (
        .rst             (~ch3_wframe_rst_n),
        .pclk            (ch3_wframe_pclk),
        .cmos_vsync      (ch3_wframe_vsync),
        .write_req       (ch3_write_req),
        .write_addr_index(ch3_write_addr_index),
        .read_addr_index (),
        .write_req_ack   (ch3_write_req_ack)
    );

    //---------------------------------------------------
    // frame_read_write 模块实例化
    //---------------------------------------------------
    //通道0
    frame_read_write_256_burst #(
        .MEM_DATA_BITS  (MEM_DATA_BITS),
        .READ_DATA_BITS (128),
        .WRITE_DATA_BITS(PAIRED_HDMI ? 32 : 16),
        .ADDR_BITS      (ADDR_BITS),
        .BUSRT_BITS     (BUSRT_BITS),
        .BURST_SIZE     (BURST_SIZE)
    ) frame_read_write_m0 (
        .rst    (~ARESETN),
        .mem_clk(ACLK),

        .wframe_vsync(ch0_wframe_vsync),
        .keys        (key),
        .channel_id  (3'd0),

        .rd_burst_req(ch0_rd_burst_req),
        .rd_burst_len(ch0_rd_burst_len),
        .rd_burst_addr(ch0_rd_burst_addr),
        .rd_burst_data_valid(ch0_rd_burst_data_valid),
        .rd_burst_data(ch0_rd_burst_data),
        .rd_burst_finish(ch0_rd_burst_finish),
        .read_clk(ch0_rframe_pclk),
        .read_req(ch0_rframe_req),
        .read_req_ack(ch0_rframe_req_ack),
        .read_finish(frame_read_finish[0]),
        .read_addr_0(28'd0),  // 首帧缓存编号为 0
        .read_addr_1(HDMI_BASE1),
        .read_addr_2(HDMI_BASE2),
        .read_addr_3(HDMI_BASE3),
        .read_addr_index(ch0_bank_for_read),
        .read_len(HDMI_LEN),  //frame size   1920*1080*16/256=129600  //这里要读4k视频，所以乘4
        .read_en(ch0_rframe_data_en),
        .read_data(ch0_rframe_data),
        .read_data_valid(ch0_rframe_data_valid),
        .read_line_full(ch0_read_line_full),

        .wr_burst_req     (ch0_wr_burst_req),
        .wr_burst_len     (ch0_wr_burst_len),
        .wr_burst_addr    (ch0_wr_burst_addr),
        .wr_burst_data_req(ch0_wr_burst_data_req),
        .wr_burst_data    (ch0_wr_burst_data),
        .wr_burst_finish  (ch0_wr_burst_finish),
        .write_clk        (ch0_wframe_pclk),
        .write_req        (ch0_write_req),
        .write_req_ack    (ch0_write_req_ack),
        .write_finish     (frame_write_finish[0]),
        .write_overflow   (ch0_write_overflow),
        .write_addr_0     (28'd0),
        .write_addr_1     (HDMI_BASE1),
        .write_addr_2     (HDMI_BASE2),
        .write_addr_3     (HDMI_BASE3),
        .write_addr_index (ch0_write_addr_index),
        .write_len        (HDMI_LEN),               //frame size  这里写入4k的一半，所以乘2
        .write_en         (ch0_wframe_data_valid),
        .write_data       (ch0_wframe_data)
    );

    //通道1
    frame_read_write_256_burst #(
        .MEM_DATA_BITS  (MEM_DATA_BITS),
        .READ_DATA_BITS (128),
        .WRITE_DATA_BITS(16),
        .ADDR_BITS      (ADDR_BITS),
        .BUSRT_BITS     (BUSRT_BITS),
        .BURST_SIZE     (BURST_SIZE)
    ) frame_read_write_m1 (
        .rst    (~ARESETN),
        .mem_clk(ACLK),

        .wframe_vsync(ch1_wframe_vsync),
        .keys        (key),
        .channel_id  (3'd1),

        .rd_burst_req       (ch1_rd_burst_req),
        .rd_burst_len       (ch1_rd_burst_len),
        .rd_burst_addr      (ch1_rd_burst_addr),
        .rd_burst_data_valid(ch1_rd_burst_data_valid),
        .rd_burst_data      (ch1_rd_burst_data),
        .rd_burst_finish    (ch1_rd_burst_finish),
        .read_clk           (ch1_rframe_pclk),
        .read_req           (ch1_rframe_req),
        .read_req_ack       (ch1_rframe_req_ack),
        .read_finish        (frame_read_finish[1]),
        .read_addr_0        (FRAME_LEN * 4),            // 首帧缓存编号为 0
        .read_addr_1        (FRAME_LEN * 5),
        .read_addr_2        (FRAME_LEN * 6),
        .read_addr_3        (FRAME_LEN * 7),
        .read_addr_index    (published_bank[3:2]),
        .read_len           (FRAME_LEN),                // 帧字数：1920×1080×16/256=129600
        .read_en            (ch1_rframe_data_en),
        .read_data          (ch1_rframe_data),
        .read_data_valid    (ch1_rframe_data_valid),
        .read_line_full     (ch1_read_line_full),

        .wr_burst_req     (ch1_wr_burst_req),
        .wr_burst_len     (ch1_wr_burst_len),
        .wr_burst_addr    (ch1_wr_burst_addr),
        .wr_burst_data_req(ch1_wr_burst_data_req),
        .wr_burst_data    (ch1_wr_burst_data),
        .wr_burst_finish  (ch1_wr_burst_finish),
        .write_clk        (ch1_wframe_pclk),
        .write_req        (ch1_write_req),
        .write_req_ack    (ch1_write_req_ack),
        .write_finish     (frame_write_finish[1]),
        .write_addr_0     (FRAME_LEN * 4),
        .write_addr_1     (FRAME_LEN * 5),
        .write_addr_2     (FRAME_LEN * 6),
        .write_addr_3     (FRAME_LEN * 7),
        .write_addr_index (ch1_write_addr_index),
        .write_len        (FRAME_LEN),              // 帧数据长度
        .write_en         (ch1_wframe_data_valid),
        .write_data       (ch1_wframe_data)
    );

    //通道2
    frame_read_write_256_burst #(
        .MEM_DATA_BITS  (MEM_DATA_BITS),
        .READ_DATA_BITS (128),
        .WRITE_DATA_BITS(16),
        .ADDR_BITS      (ADDR_BITS),
        .BUSRT_BITS     (BUSRT_BITS),
        .BURST_SIZE     (BURST_SIZE)
    ) frame_read_write_m2 (
        .rst    (~ARESETN),
        .mem_clk(ACLK),

        .wframe_vsync(ch2_wframe_vsync),
        .keys        (key),
        .channel_id  (3'd2),

        .rd_burst_req       (ch2_rd_burst_req),
        .rd_burst_len       (ch2_rd_burst_len),
        .rd_burst_addr      (ch2_rd_burst_addr),
        .rd_burst_data_valid(ch2_rd_burst_data_valid),
        .rd_burst_data      (ch2_rd_burst_data),
        .rd_burst_finish    (ch2_rd_burst_finish),
        .read_clk           (ch2_rframe_pclk),
        .read_req           (ch2_rframe_req),
        .read_req_ack       (ch2_rframe_req_ack),
        .read_finish        (frame_read_finish[2]),
        .read_addr_0        (FRAME_LEN * 8),            // 首帧缓存编号为 0
        .read_addr_1        (FRAME_LEN * 9),
        .read_addr_2        (FRAME_LEN * 10),
        .read_addr_3        (FRAME_LEN * 11),
        .read_addr_index    (published_bank[5:4]),
        .read_len           (FRAME_LEN),                // 帧字数：1920×1080×16/256=129600
        .read_en            (ch2_rframe_data_en),
        .read_data          (ch2_rframe_data),
        .read_data_valid    (ch2_rframe_data_valid),
        .read_line_full     (ch2_read_line_full),

        .wr_burst_req     (ch2_wr_burst_req),
        .wr_burst_len     (ch2_wr_burst_len),
        .wr_burst_addr    (ch2_wr_burst_addr),
        .wr_burst_data_req(ch2_wr_burst_data_req),
        .wr_burst_data    (ch2_wr_burst_data),
        .wr_burst_finish  (ch2_wr_burst_finish),
        .write_clk        (ch2_wframe_pclk),
        .write_req        (ch2_write_req),
        .write_req_ack    (ch2_write_req_ack),
        .write_finish     (frame_write_finish[2]),
        .write_addr_0     (FRAME_LEN * 8),
        .write_addr_1     (FRAME_LEN * 9),
        .write_addr_2     (FRAME_LEN * 10),
        .write_addr_3     (FRAME_LEN * 11),
        .write_addr_index (ch2_write_addr_index),
        .write_len        (FRAME_LEN),              // 帧数据长度
        .write_en         (ch2_wframe_data_valid),
        .write_data       (ch2_wframe_data)
    );

    //通道3
    frame_read_write_256_burst #(
        .MEM_DATA_BITS  (MEM_DATA_BITS),
        .READ_DATA_BITS (128),
        .WRITE_DATA_BITS(16),
        .ADDR_BITS      (ADDR_BITS),
        .BUSRT_BITS     (BUSRT_BITS),
        .BURST_SIZE     (BURST_SIZE)
    ) frame_read_write_m3 (
        .rst    (~ARESETN),
        .mem_clk(ACLK),

        .wframe_vsync(ch3_wframe_vsync),
        .keys        (key),
        .channel_id  (3'd3),

        .rd_burst_req       (ch3_rd_burst_req),
        .rd_burst_len       (ch3_rd_burst_len),
        .rd_burst_addr      (ch3_rd_burst_addr),
        .rd_burst_data_valid(ch3_rd_burst_data_valid),
        .rd_burst_data      (ch3_rd_burst_data),
        .rd_burst_finish    (ch3_rd_burst_finish),
        .read_clk           (ch3_rframe_pclk),
        .read_req           (ch3_rframe_req),
        .read_req_ack       (ch3_rframe_req_ack),
        .read_finish        (frame_read_finish[3]),
        .read_addr_0        (FRAME_LEN * 12),           // 首帧缓存编号为 0
        .read_addr_1        (FRAME_LEN * 13),
        .read_addr_2        (FRAME_LEN * 14),
        .read_addr_3        (FRAME_LEN * 15),
        .read_addr_index    (published_bank[7:6]),
        .read_len           (FRAME_LEN),                // 帧字数：1920×1080×16/256=129600
        .read_en            (ch3_rframe_data_en),
        .read_data          (ch3_rframe_data),
        .read_data_valid    (ch3_rframe_data_valid),
        .read_line_full     (ch3_read_line_full),

        .wr_burst_req     (ch3_wr_burst_req),
        .wr_burst_len     (ch3_wr_burst_len),
        .wr_burst_addr    (ch3_wr_burst_addr),
        .wr_burst_data_req(ch3_wr_burst_data_req),
        .wr_burst_data    (ch3_wr_burst_data),
        .wr_burst_finish  (ch3_wr_burst_finish),
        .write_clk        (ch3_wframe_pclk),
        .write_req        (ch3_write_req),
        .write_req_ack    (ch3_write_req_ack),
        .write_finish     (frame_write_finish[3]),
        .write_addr_0     (FRAME_LEN * 12),
        .write_addr_1     (FRAME_LEN * 13),
        .write_addr_2     (FRAME_LEN * 14),
        .write_addr_3     (FRAME_LEN * 15),
        .write_addr_index (ch3_write_addr_index),
        .write_len        (FRAME_LEN),              // 帧数据长度
        .write_en         (ch3_wframe_data_valid),
        .write_data       (ch3_wframe_data)
    );

    //---------------------------------------------------
    // 通道仲裁模块
    //---------------------------------------------------
    //读仲裁
    mem_read_arbi #(
        .MEM_DATA_BITS(MEM_DATA_BITS),
        .ADDR_BITS    (ADDR_BITS),
        .BUSRT_BITS   (BUSRT_BITS)
    ) mem_read_arbi_m0 (
        .rst_n                  (ARESETN),
        .mem_clk                (ACLK),
        .ch0_rd_burst_req       (ch0_rd_burst_req),
        .ch0_rd_burst_len       (ch0_rd_burst_len),
        .ch0_rd_burst_addr      (ch0_rd_burst_addr),
        .ch0_rd_burst_data_valid(ch0_rd_burst_data_valid),
        .ch0_rd_burst_data      (ch0_rd_burst_data),
        .ch0_rd_burst_finish    (ch0_rd_burst_finish),

        .ch1_rd_burst_req       (ch1_rd_burst_req),
        .ch1_rd_burst_len       (ch1_rd_burst_len),
        .ch1_rd_burst_addr      (ch1_rd_burst_addr),
        .ch1_rd_burst_data_valid(ch1_rd_burst_data_valid),
        .ch1_rd_burst_data      (ch1_rd_burst_data),
        .ch1_rd_burst_finish    (ch1_rd_burst_finish),

        .ch2_rd_burst_req       (ch2_rd_burst_req),
        .ch2_rd_burst_len       (ch2_rd_burst_len),
        .ch2_rd_burst_addr      (ch2_rd_burst_addr),
        .ch2_rd_burst_data_valid(ch2_rd_burst_data_valid),
        .ch2_rd_burst_data      (ch2_rd_burst_data),
        .ch2_rd_burst_finish    (ch2_rd_burst_finish),

        .ch3_rd_burst_req       (ch3_rd_burst_req),
        .ch3_rd_burst_len       (ch3_rd_burst_len),
        .ch3_rd_burst_addr      (ch3_rd_burst_addr),
        .ch3_rd_burst_data_valid(ch3_rd_burst_data_valid),
        .ch3_rd_burst_data      (ch3_rd_burst_data),
        .ch3_rd_burst_finish    (ch3_rd_burst_finish),

        .rd_burst_req       (rd_burst_req),
        .rd_burst_len       (rd_burst_len),
        .rd_burst_addr      (rd_burst_addr),
        .rd_burst_data_valid(rd_burst_data_valid),
        .rd_burst_data      (rd_burst_data),
        .rd_burst_finish    (rd_burst_finish)
    );

    //写仲裁
    mem_write_arbi #(
        .MEM_DATA_BITS(MEM_DATA_BITS),
        .ADDR_BITS    (ADDR_BITS),
        .BUSRT_BITS   (BUSRT_BITS)
    ) mem_write_arbi_m0 (
        .rst_n  (ARESETN),
        .mem_clk(ACLK),

        .ch0_wr_burst_req     (ch0_wr_burst_req),
        .ch0_wr_burst_len     (ch0_wr_burst_len),
        .ch0_wr_burst_addr    (ch0_wr_burst_addr),
        .ch0_wr_burst_data_req(ch0_wr_burst_data_req),
        .ch0_wr_burst_data    (ch0_wr_burst_data),
        .ch0_wr_burst_finish  (ch0_wr_burst_finish),

        .ch1_wr_burst_req     (ch1_wr_burst_req),
        .ch1_wr_burst_len     (ch1_wr_burst_len),
        .ch1_wr_burst_addr    (ch1_wr_burst_addr),
        .ch1_wr_burst_data_req(ch1_wr_burst_data_req),
        .ch1_wr_burst_data    (ch1_wr_burst_data),
        .ch1_wr_burst_finish  (ch1_wr_burst_finish),

        .ch2_wr_burst_req     (ch2_wr_burst_req),
        .ch2_wr_burst_len     (ch2_wr_burst_len),
        .ch2_wr_burst_addr    (ch2_wr_burst_addr),
        .ch2_wr_burst_data_req(ch2_wr_burst_data_req),
        .ch2_wr_burst_data    (ch2_wr_burst_data),
        .ch2_wr_burst_finish  (ch2_wr_burst_finish),

        .ch3_wr_burst_req     (ch3_wr_burst_req),
        .ch3_wr_burst_len     (ch3_wr_burst_len),
        .ch3_wr_burst_addr    (ch3_wr_burst_addr),
        .ch3_wr_burst_data_req(ch3_wr_burst_data_req),
        .ch3_wr_burst_data    (ch3_wr_burst_data),
        .ch3_wr_burst_finish  (ch3_wr_burst_finish),

        .wr_burst_req     (wr_burst_req),
        .wr_burst_len     (wr_burst_len),
        .wr_burst_addr    (wr_burst_addr),
        .wr_burst_data_req(wr_burst_data_req),
        .wr_burst_data    (wr_burst_data),
        .wr_burst_finish  (wr_burst_finish)
    );

    aq_axi_master_256_burst #(
        .DATA_WIDTH(DATA_WIDTH)
    ) u_aq_axi_master (
        .ARESETN      (ARESETN),
        .ACLK         (ACLK),
        .M_AXI_AWID   (M_AXI_AWID),
        .M_AXI_AWADDR (M_AXI_AWADDR),
        .M_AXI_AWLEN  (M_AXI_AWLEN),
        .M_AXI_AWSIZE (M_AXI_AWSIZE),
        .M_AXI_AWBURST(M_AXI_AWBURST),
        .M_AXI_AWLOCK (M_AXI_AWLOCK),
        .M_AXI_AWCACHE(M_AXI_AWCACHE),
        .M_AXI_AWPROT (M_AXI_AWPROT),
        .M_AXI_AWQOS  (M_AXI_AWQOS),
        .M_AXI_AWUSER (M_AXI_AWUSER),
        .M_AXI_AWVALID(M_AXI_AWVALID),
        .M_AXI_AWREADY(M_AXI_AWREADY),
        .M_AXI_WDATA  (M_AXI_WDATA),
        .M_AXI_WSTRB  (M_AXI_WSTRB),
        .M_AXI_WLAST  (M_AXI_WLAST),
        .M_AXI_WUSER  (M_AXI_WUSER),
        .M_AXI_WVALID (M_AXI_WVALID),
        .M_AXI_WREADY (M_AXI_WREADY),
        .M_AXI_BID    (M_AXI_BID),
        .M_AXI_BRESP  (M_AXI_BRESP),
        .M_AXI_BUSER  (M_AXI_BUSER),
        .M_AXI_BVALID (M_AXI_BVALID),

        .M_AXI_BREADY (M_AXI_BREADY),
        .M_AXI_ARID   (M_AXI_ARID),
        .M_AXI_ARADDR (M_AXI_ARADDR),
        .M_AXI_ARLEN  (M_AXI_ARLEN),
        .M_AXI_ARSIZE (M_AXI_ARSIZE),
        .M_AXI_ARBURST(M_AXI_ARBURST),
        .M_AXI_ARLOCK (M_AXI_ARLOCK),
        .M_AXI_ARCACHE(M_AXI_ARCACHE),
        .M_AXI_ARPROT (M_AXI_ARPROT),
        .M_AXI_ARQOS  (M_AXI_ARQOS),
        .M_AXI_ARUSER (M_AXI_ARUSER),
        .M_AXI_ARVALID(M_AXI_ARVALID),
        .M_AXI_ARREADY(M_AXI_ARREADY),
        .M_AXI_RID    (M_AXI_RID),
        .M_AXI_RDATA  (M_AXI_RDATA),
        .M_AXI_RRESP  (M_AXI_RRESP),
        .M_AXI_RLAST  (M_AXI_RLAST),
        .M_AXI_RUSER  (M_AXI_RUSER),
        .M_AXI_RVALID (M_AXI_RVALID),
        .M_AXI_RREADY (M_AXI_RREADY),
        .MASTER_RST   (1'b0),
        .WR_START     (wr_burst_req),

        .WR_ADRS       ({wr_burst_addr[27:0], 4'd0}),
        .WR_LEN        ({18'd0, wr_burst_len, 4'd0}),
        .WR_READY      (),
        .WR_FIFO_RE    (wr_burst_data_req),
        .WR_FIFO_EMPTY (1'b0),
        .WR_FIFO_AEMPTY(1'b0),
        .WR_FIFO_DATA  (wr_burst_data),
        .WR_DONE       (wr_burst_finish),

        .RD_START(rd_burst_req),

        .RD_ADRS      ({rd_burst_addr[27:0], 4'd0}),
        .RD_LEN       ({18'd0, rd_burst_len, 4'd0}),
        .RD_READY     (),
        .RD_FIFO_WE   (rd_burst_data_valid),
        .RD_FIFO_FULL (1'b0),
        .RD_FIFO_AFULL(1'b0),
        .RD_FIFO_DATA (rd_burst_data),
        .RD_DONE      (rd_burst_finish),
        .DEBUG        ()
    );
endmodule

