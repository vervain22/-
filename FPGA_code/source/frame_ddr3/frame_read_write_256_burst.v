`timescale 1ns / 1ps
module frame_read_write_256_burst #(
    parameter MEM_DATA_BITS   = 64,
    parameter READ_DATA_BITS  = 128,
    parameter WRITE_DATA_BITS = 16,
    parameter ADDR_BITS       = 25,
    parameter BUSRT_BITS      = 10,
    parameter BURST_SIZE      = 16
) (
    input rst,
    input mem_clk, // 外部存储控制器用户接口时钟

    input wframe_vsync,  // 写帧场同步信号

    input [7:0] keys,       //按键输入
    input [2:0] channel_id, //通道标志

    output                             rd_burst_req,         // 向外部存储控制器发出突发读请求
    output     [     BUSRT_BITS - 1:0] rd_burst_len,         // 突发读长度，单位为数据拍而非字节
    output     [      ADDR_BITS - 1:0] rd_burst_addr,        // 突发读基地址
    input                              rd_burst_data_valid,  // 外部存储控制器读数据有效
    input      [  MEM_DATA_BITS - 1:0] rd_burst_data,        // 外部存储控制器读数据
    input                              rd_burst_finish,      // 外部存储控制器突发读完成
    input                              read_clk,             // 数据读取模块时钟
    input                              read_req,             // 读请求保持有效，直到 read_req_ack 应答。
    output                             read_req_ack,         // 数据读取模块请求应答
    output                             read_finish,          // 数据读取模块请求完成
    input      [      ADDR_BITS - 1:0] read_addr_0,          // 读缓存 0 基地址，read_addr_index=0 时选用。
    input      [      ADDR_BITS - 1:0] read_addr_1,          // 读缓存 1 基地址，read_addr_index=1 时选用。
    input      [      ADDR_BITS - 1:0] read_addr_2,          // 读缓存 2 基地址，read_addr_index=2 时选用。
    input      [      ADDR_BITS - 1:0] read_addr_3,          // 读缓存 3 基地址，read_addr_index=3 时选用。
    input      [                  1:0] read_addr_index,      // 根据读缓存编号选择四个基地址之一。
    input      [      ADDR_BITS - 1:0] read_len,             // 数据读取长度
    input                              read_en,              // 请求读取一个数据，下一周期 read_data 有效
    output     [READ_DATA_BITS  - 1:0] read_data,            // 读数据
    output reg                         read_data_valid,      // 读数据有效
    output reg                         read_line_full,       //当读fifo存满一行时，信号拉高

    output wr_burst_req,  // 向外部存储控制器发出突发写请求
    output [BUSRT_BITS - 1:0] wr_burst_len,  // 突发写长度，单位为数据拍而非字节
    output [ADDR_BITS - 1:0] wr_burst_addr,  // 突发写基地址
    input wr_burst_data_req,  // 外部存储控制器提前一周期请求写数据
    output[MEM_DATA_BITS - 1:0]      wr_burst_data/*synthesis PAP_MARK_DEBUG="true"*/,              // 送往外部存储控制器的写数据
    input wr_burst_finish,  // 外部存储控制器突发写完成
    input write_clk,  // 数据写入模块时钟
    input write_req,  // 写请求保持有效，直到写请求应答。
    output write_req_ack,  // 数据写入模块请求应答
    output write_finish,  // 数据写入模块请求完成
    input [ADDR_BITS - 1:0] write_addr_0,  // 写缓存 0 基地址，write_addr_index=0 时选用。
    input [ADDR_BITS - 1:0] write_addr_1,  // 写缓存 1 基地址，write_addr_index=1 时选用。
    input [ADDR_BITS - 1:0] write_addr_2,  // 写缓存 2 基地址，write_addr_index=2 时选用。
    input [ADDR_BITS - 1:0] write_addr_3,  // 写缓存 3 基地址，write_addr_index=3 时选用。
    input [1:0] write_addr_index,  // 根据写缓存编号选择四个基地址之一。
    input [ADDR_BITS - 1:0] write_len,  // 数据写入长度
    input write_en,  // 请求写入一个数据
    input [WRITE_DATA_BITS - 1:0] write_data,  // 写数据
    output reg write_overflow
);
    wire [15:0] wrusedw  /*synthesis PAP_MARK_DEBUG="true"*/;  // 已写入 FIFO 的数据字数
    wire [15:0] rfifo_rdusedw  /*synthesis PAP_MARK_DEBUG="true"*/;  // 读 FIFO 数据字数
    wire [15:0] rdusedw  /*synthesis PAP_MARK_DEBUG="true"*/;  // 待读取的数据字数
    wire        read_fifo_aclr;  // FIFO 异步清零
    wire        write_fifo_aclr;  // FIFO 异步清零

    // FIFO 各端口异步进入复位，并在本地时钟下同步释放。
    // 摄像头及 PCIe 复位不能由 mem_clk 直接释放。
    wire wfifo_wr_reset, wfifo_rd_reset, rfifo_wr_reset, rfifo_rd_reset;
    ddr_fifo_reset_sync u_wfifo_wr_reset (
        .clk(write_clk),
        .async_reset(rst | write_fifo_aclr),
        .reset_out(wfifo_wr_reset)
    );
    ddr_fifo_reset_sync u_wfifo_rd_reset (
        .clk(mem_clk),
        .async_reset(rst | write_fifo_aclr),
        .reset_out(wfifo_rd_reset)
    );
    ddr_fifo_reset_sync u_rfifo_wr_reset (
        .clk(mem_clk),
        .async_reset(rst | read_fifo_aclr),
        .reset_out(rfifo_wr_reset)
    );
    ddr_fifo_reset_sync u_rfifo_rd_reset (
        .clk(read_clk),
        .async_reset(rst | read_fifo_aclr),
        .reset_out(rfifo_rd_reset)
    );

    //---------------------------------------------------
    // write_clk 的复位同步化
    //---------------------------------------------------
    (* ASYNC_REG="TRUE" *)reg write_clk_rst_dly1;
    (* ASYNC_REG="TRUE" *)reg write_clk_rst_dly2;
    (* ASYNC_REG="TRUE" *)reg write_clk_rst_dly3;

    always @(posedge write_clk or posedge rst) begin
        if (rst) begin
            write_clk_rst_dly1 <= 1'b1;
            write_clk_rst_dly2 <= 1'b1;
            write_clk_rst_dly3 <= 1'b1;
        end else begin
            write_clk_rst_dly1 <= 1'b0;
            write_clk_rst_dly2 <= write_clk_rst_dly1;
            write_clk_rst_dly3 <= write_clk_rst_dly2;
        end
    end

    //---------------------------------------------------
    // wframe_vsync上升沿判断
    //---------------------------------------------------
    reg wframe_vsync_dly1;
    reg wframe_vsync_dly2;
    reg wframe_vsync_pos;

    always @(posedge write_clk) begin
        if (write_clk_rst_dly3) begin
            wframe_vsync_dly1 <= 1'b0;
            wframe_vsync_dly2 <= 1'b0;
        end else begin
            wframe_vsync_dly1 <= wframe_vsync;
            wframe_vsync_dly2 <= wframe_vsync_dly1;
        end
    end

    always @(posedge write_clk) begin
        if (write_clk_rst_dly3) begin
            wframe_vsync_pos <= 1'b0;
        end else begin
            if (wframe_vsync_dly1 == 1'b1 && wframe_vsync_dly2 == 1'b0) begin
                wframe_vsync_pos <= 1'b1;
            end else begin
                wframe_vsync_pos <= 1'b0;
            end
        end
    end

    //---------------------------------------------------
    // wframe 控制
    //---------------------------------------------------
    reg                         write_en_dly1;
    reg [WRITE_DATA_BITS - 1:0] write_data_dly1;

    always @(posedge write_clk) begin
        if (write_clk_rst_dly3) begin
            write_en_dly1   <= 1'b0;
            write_data_dly1 <= {WRITE_DATA_BITS{1'b0}};
        end else begin
            write_en_dly1   <= write_en;
            write_data_dly1 <= write_data;
        end
    end

    // 异步 FIFO 例化
    //---------------------------------------------------
    // 注意：
    // 写端口：地址宽度 12，数据宽度 16。
    // 读端口：地址宽度 9，数据宽度 128。
    // 将满阈值：4092
    // 将空阈值：4
    //---------------------------------------------------
    wire paired_fifo_full;
    always @(posedge write_clk) begin
        if (wfifo_wr_reset) write_overflow <= 0;
        else if (write_en_dly1 && paired_fifo_full) write_overflow <= 1;
    end
    generate
        if (WRITE_DATA_BITS == 16) begin : Gen_WFIFO_16i
            assign paired_fifo_full = 1'b0;
            afifo_16i_128o_512 write_buf_16i (
                .wr_clk        (write_clk),
                .wr_rst        (wfifo_wr_reset),
                .wr_en         (write_en_dly1 && !wfifo_wr_reset),
                .wr_data       (write_data_dly1),
                .wr_full       (),
                .wr_water_level(),
                .almost_full   (),
                .rd_clk        (mem_clk),
                .rd_rst        (wfifo_rd_reset),
                .rd_en         (wr_burst_data_req && !wfifo_rd_reset),
                .rd_data       (wr_burst_data),
                .rd_empty      (),
                .rd_water_level(rdusedw[9:0]),
                .almost_empty  ()
            );
        end else if (WRITE_DATA_BITS == 32) begin : Gen_PAIRED_32
            pair_fifo_32to128 u_pair_fifo (
                .wr_clk(write_clk),
                .wr_rst(wfifo_wr_reset),
                .wr_en(write_en_dly1 && !wfifo_wr_reset),
                .wr_data(write_data_dly1),
                .wr_full(paired_fifo_full),
                .rd_clk(mem_clk),
                .rd_rst(wfifo_rd_reset),
                .rd_en(wr_burst_data_req && !wfifo_rd_reset),
                .rd_data(wr_burst_data),
                .rd_water_level(rdusedw[9:0])
            );
        end

    endgenerate

    assign rdusedw[15:10] = 6'd0;

    frame_fifo_write_256_burst #(
        .MEM_DATA_BITS(MEM_DATA_BITS),
        .ADDR_BITS    (ADDR_BITS),
        .BUSRT_BITS   (BUSRT_BITS),
        .BURST_SIZE   (64)
    ) frame_fifo_write_m0 (
        .rst              (rst),
        .mem_clk          (mem_clk),
        .wr_burst_req     (wr_burst_req),
        .wr_burst_len     (wr_burst_len),
        .wr_burst_addr    (wr_burst_addr),
        .wr_burst_data_req(wr_burst_data_req),
        .wr_burst_finish  (wr_burst_finish),
        .write_req        (write_req),
        .write_req_ack    (write_req_ack),
        .write_finish     (write_finish),
        .write_addr_0     (write_addr_0),
        .write_addr_1     (write_addr_1),
        .write_addr_2     (write_addr_2),
        .write_addr_3     (write_addr_3),
        .write_addr_index (write_addr_index),
        .write_len        (write_len),
        .fifo_aclr        (write_fifo_aclr),
        .rdusedw          (rdusedw)

    );

    // 异步 FIFO 例化
    //---------------------------------------------------
    // 注意：
    // 写端口：地址宽度 10，数据宽度 128。
    // 读端口：地址宽度 10，数据宽度 128。
    // 将满阈值：252
    // 将空阈值：4
    //---------------------------------------------------
    generate

        if (READ_DATA_BITS == 128) begin : Gen_RFIFO_128o
            afifo_128i_128o_512 read_buf_128o (
                .wr_clk        (mem_clk),
                .wr_rst        (rfifo_wr_reset),
                .wr_en         (rd_burst_data_valid && !rfifo_wr_reset),
                .wr_data       (rd_burst_data),
                .wr_full       (),
                .wr_water_level(wrusedw[10:0]),
                .almost_full   (),
                .rd_clk        (read_clk),
                .rd_rst        (rfifo_rd_reset),
                .rd_en         (read_en && !rfifo_rd_reset),
                .rd_data       (read_data),
                .rd_empty      (),
                .rd_water_level(rfifo_rdusedw[10:0]),
                .almost_empty  (almost_empty)
            );
        end

    endgenerate

    assign wrusedw[15:11] = 5'b0;
    assign rfifo_rdusedw[15:11] = 5'b0;

    //---------------------------------------------------
    // read_line_full:当可读FIFO存满一行时，信号拉高
    //---------------------------------------------------
    always @(posedge read_clk or posedge rfifo_rd_reset) begin
        if (rfifo_rd_reset == 1'b1) begin
            read_line_full <= 1'b0;
        end
	else if (!rfifo_rd_reset && rfifo_rdusedw[11:0] >= 12'd160 ) begin   // 256*2=512,这里是一次突发结束，因为pcie是128，因此乘2
            read_line_full <= 1'b1;
        end else begin
            read_line_full <= 1'b0;
        end
    end

    always @(posedge read_clk or posedge rfifo_rd_reset) begin
        if (rfifo_rd_reset == 1'b1) begin
            read_data_valid <= 1'b0;
        end else begin
            read_data_valid <= read_en && !rfifo_rd_reset;
        end
    end

    frame_fifo_read_256_burst #(
        .MEM_DATA_BITS(MEM_DATA_BITS),
        .ADDR_BITS    (ADDR_BITS),
        .BUSRT_BITS   (BUSRT_BITS),
        .FIFO_DEPTH   (128),
        .BURST_SIZE   (160)
    ) frame_fifo_read_m0 (
        .rst                (rst),
        .mem_clk            (mem_clk),
        .rd_burst_req       (rd_burst_req),
        .rd_burst_len       (rd_burst_len),
        .rd_burst_addr      (rd_burst_addr),
        .rd_burst_data_valid(rd_burst_data_valid),
        .rd_burst_finish    (rd_burst_finish),
        .read_req           (read_req),
        .read_req_ack       (read_req_ack),
        .read_finish        (read_finish),
        .read_addr_0        (read_addr_0),
        .read_addr_1        (read_addr_1),
        .read_addr_2        (read_addr_2),
        .read_addr_3        (read_addr_3),
        .read_addr_index    (read_addr_index),
        .read_len           (read_len),
        .fifo_aclr          (read_fifo_aclr),
        .wrusedw            (wrusedw)
    );

endmodule

// 异步复位解除后，经过三个本地时钟边沿再释放复位。
// 复位同步模块与帧读写控制模块放在同一源文件。
module ddr_fifo_reset_sync (
    input  clk,
    input  async_reset,
    output reset_out
);
    (* ASYNC_REG="TRUE" *) reg [2:0] reset_pipe;
    always @(posedge clk or posedge async_reset) begin
        if (async_reset) reset_pipe <= 3'b111;
        else reset_pipe <= {reset_pipe[1:0], 1'b0};
    end
    assign reset_out = reset_pipe[2];
endmodule
