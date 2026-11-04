`timescale 1ns / 1ps

// 单路 FMC OV5640 采集封装。
// 配置链路沿用参考工程，像素输出为经过 8bit DVP 打包后的 RGB565。
module ov5640_single_capture (
    input         sys_clk,
    input         rst_n,
    inout         cmos_scl,
    inout         cmos_sda,
    input         cmos_vsync,
    input         cmos_href,
    input         cmos_pclk,
    input  [ 7:0] cmos_data,
    output        cmos_reset,
    output        init_done,
    output        pixel_clk,
    output        frame_valid,
    output        frame_sync,
    output [15:0] pixel_data
);

    wire camera_rstn;
    wire camera_pwnd;
    wire initial_en;
    wire [15:0] packed_data;
    wire packed_valid;
    // DVP 输入采用三级流水，数据、HREF 和 VSYNC 在同一边沿采样。
    reg [7:0] cmos_data_d1, cmos_data_d2, cmos_data_d0;
    reg cmos_href_d1, cmos_href_d2, cmos_href_d0;
    reg cmos_vsync_d1, cmos_vsync_d2, cmos_vsync_d0;
    // 字节拼接模块对 cmos_pclk 二分频产生 pixel_clk；VSYNC 同步到该时钟域后再送缩放及帧缓存。
    (* ASYNC_REG = "TRUE" *)reg vsync_pix_meta;
    (* ASYNC_REG = "TRUE" *)reg vsync_pix;

    always @(posedge cmos_pclk) begin
        cmos_data_d1  <= cmos_data;
        cmos_data_d2  <= cmos_data_d1;
        cmos_href_d1  <= cmos_href;
        cmos_href_d2  <= cmos_href_d1;
        cmos_vsync_d1 <= cmos_vsync;
        cmos_vsync_d2 <= cmos_vsync_d1;
    end

    always @(posedge cmos_pclk) begin
        cmos_data_d0  <= cmos_data_d2;
        cmos_href_d0  <= cmos_href_d2;
        cmos_vsync_d0 <= cmos_vsync_d2;
    end

    power_on_delay_fmc u_power_on_delay (
        .clk_50M     (sys_clk),
        .reset_n     (rst_n),
        .camera1_rstn(camera_rstn),
        .camera2_rstn(),
        .camera_pwnd (camera_pwnd),
        .initial_en  (initial_en)
    );

    reg_config_fmc u_reg_config (
        .clk_25M      (sys_clk),
        .camera_rstn  (camera_rstn),
        .initial_en   (initial_en),
        .reg_conf_done(init_done),
        .i2c_sclk     (cmos_scl),
        .i2c_sdat     (cmos_sda),
        .clock_20k    (),
        .reg_index    ()
    );

    cmos_8_16bit_fmc u_pack_rgb565 (
        .pclk     (cmos_pclk),
        .rst_n    (rst_n & init_done),
        .de_i     (cmos_href_d0),
        .pdata_i  (cmos_data_d0),
        .vs_i     (cmos_vsync_d0),
        .pixel_clk(pixel_clk),
        .de_o     (packed_valid),
        .pdata_o  (packed_data)
    );

    assign cmos_reset  = camera_rstn;
    assign frame_valid = packed_valid;
    // cmos_vsync_d0 与数据、HREF 等延迟后，再同步到 pixel_clk，供下游检测帧首。
    always @(posedge pixel_clk or negedge rst_n) begin
        if (!rst_n) begin
            vsync_pix_meta <= 1'b0;
            vsync_pix      <= 1'b0;
        end else begin
            vsync_pix_meta <= cmos_vsync_d0;
            vsync_pix      <= vsync_pix_meta;
        end
    end

    assign frame_sync = vsync_pix;
    // OV5640 的 0x60 输出配置采用 BGR565 顺序，交换红蓝分量后供 DDR、PCIe 和 RK 使用。
    assign pixel_data = {packed_data[4:0], packed_data[10:5], packed_data[15:11]};

endmodule
