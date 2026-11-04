`timescale 1ns / 1ps

module preprocess #(

    // 图像处理参数在综合前确定。
    parameter ENABLE_ENHANCEMENT = 0
) (
    input wire clk,
    input wire rst_n,

    // HDMI输入像素流，RGB888格式：[23:16]R，[15:8]G，[7:0]B

    input wire        in_vsync,
    input wire        in_de,
    input wire [23:0] in_data,

    // 输出到DDR写帧侧的数据流，RGB565格式：[15:11]R，[10:5]G，[4:0]B

    output reg         out_vsync,
    output reg         out_de,
    output reg  [15:0] out_data,
    output reg  [23:0] out_rgb888,     // 与 out_data 使用相同寄存级和有效信号。
    // 原始 RGB888 观测共用主流水线的输入寄存器，在增强及缩放之前取样。
    output wire        observe_vsync,
    output wire        observe_de,
    output wire [23:0] observe_rgb
);

    //---------------------------------------------------
    // 1：帧边界和输出帧参数
    //---------------------------------------------------
    // EOF_PULSE_WIDTH：输出给DDR写帧控制器的帧完成脉冲宽度
    // FRAME_PIXELS：一帧1920x1080图像的有效像素总数
    // VBLANK_GAP_TH：用于区分真正的帧间消隐和普通行间消隐

    localparam [7:0]  EOF_PULSE_WIDTH = 8'd64;
    localparam [15:0] VBLANK_GAP_TH   = 16'd4096;
    localparam [21:0] FRAME_PIXELS    = 22'd2073600;  // 1920 * 1080

    //---------------------------------------------------
    // 2：输入时序寄存
    //---------------------------------------------------
    // 对HDMI输入的DE和RGB数据打一拍，先稳定输入时序，再送入后级预处理
    // frame_start_flag由长消隐后的第一个DE有效周期产生，用作流接口的帧起始标志

    reg        in_de_r;
    reg [23:0] in_data_r;
    reg        in_vsync_r;
    assign observe_vsync = in_vsync_r;
    assign observe_de = in_de_r;
    assign observe_rgb = in_data_r;
    // 亮度与饱和度在输入寄存器前计算，避免与统计累加路径级联。
    // 与 RGB 同边沿寄存，不增加像素或控制信号延迟。
    reg [ 7:0] in_luma_r;
    reg        in_rgb_unsaturated_r;
    reg        frame_start_flag;
    reg [15:0] blank_cnt;
    reg [21:0] out_pixel_cnt;
    reg [ 7:0] eof_pulse_cnt;

    always @(posedge clk) begin
        if (!rst_n) begin
            in_de_r              <= 1'b0;
            in_data_r            <= 24'd0;
            in_vsync_r           <= 0;
            in_luma_r            <= 0;
            in_rgb_unsaturated_r <= 0;
            frame_start_flag     <= 1'b0;
            blank_cnt            <= VBLANK_GAP_TH;
        end else begin
            in_de_r    <= in_de;
            in_data_r  <= in_data;
            in_vsync_r<=in_vsync;
            in_luma_r <= (in_data[23:16] >> 2) + (in_data[15:8] >> 1) + (in_data[7:0] >> 2);
            in_rgb_unsaturated_r <= (in_data[23:16]<8'd245) &&
                                    (in_data[15:8]<8'd245) && (in_data[7:0]<8'd245);

            if (in_de) begin
                blank_cnt <= 16'd0;
            end else if (blank_cnt != 16'hffff) begin
                blank_cnt <= blank_cnt + 16'd1;
            end

            frame_start_flag <= in_de && !in_de_r && (blank_cnt >= VBLANK_GAP_TH);
        end
    end

    //---------------------------------------------------
    // 3：HDMI有效像素时序转流式接口
    //---------------------------------------------------
    // 用寄存后的DE作为valid，将帧起始映射到tuser，将行尾映射到tlast
    // 下游预处理模块保持ready常高，因此不会反压HDMI输入

    wire        s_axis_tvalid = in_de_r;
    wire [23:0] s_axis_tdata = in_data_r;
    wire        s_axis_tuser = in_de_r && frame_start_flag;
    wire        s_axis_tlast = in_de_r && !in_de;
    wire        s_axis_tready;

    wire [23:0] m_axis_tdata;
    wire        m_axis_tvalid;
    wire        m_axis_tuser;
    wire        m_axis_tlast;

    //---------------------------------------------------
    // 4：图像增强流水线实例化
    //---------------------------------------------------
    // preprocess_pipeline输入RGB888像素，输出增强后的RGB888像素
    // 这里保持流式接口，方便插入到DDR/PCIe传输链路前，且不改变传输模块逻辑

    generate
        if (ENABLE_ENHANCEMENT != 0) begin : g_legacy_enhancement
            preprocess_pipeline #(
                .INPUT_STATS_REGISTERED(1)
            ) u_pipeline (
                .clk  (clk),
                .rst_n(rst_n),

                .s_axis_tdata   (s_axis_tdata),
                .s_axis_raw_y   (in_luma_r),
                .s_axis_rgb_unsaturated (in_rgb_unsaturated_r),
                .s_axis_tvalid  (s_axis_tvalid),
                .s_axis_tready  (s_axis_tready),
                .s_axis_tuser   (s_axis_tuser),
                .s_axis_tlast   (s_axis_tlast),

                .m_axis_tdata (m_axis_tdata),
                .m_axis_tvalid(m_axis_tvalid),
                .m_axis_tready(1'b1),
                .m_axis_tuser (m_axis_tuser),
                .m_axis_tlast (m_axis_tlast),

                .awb_gain_r(16'd65535),
                .awb_gain_g(16'd65535),
                .awb_gain_b(16'd65535)
            );
        end else begin : g_raw_bypass
            // 共用同帧判色的寄存输入。
            // 输出寄存及帧尾计数保持原有时序。
            assign s_axis_tready = 1'b1;
            assign m_axis_tdata  = s_axis_tdata;
            assign m_axis_tvalid = s_axis_tvalid;
            assign m_axis_tuser  = s_axis_tuser;
            assign m_axis_tlast  = s_axis_tlast;
        end
    endgenerate

    //---------------------------------------------------
    // 5：RGB888转RGB565，以及安全的帧完成信号生成
    //---------------------------------------------------
    // 输出像素仍按原链路需要打包成RGB565，只改变像素内容，不改变传输格式
    // out_vsync不直接跟随输入vsync，而是在完整输出FRAME_PIXELS个像素后产生EOF脉冲
    // 避免预处理流水线延迟导致帧完成flag提前

    always @(posedge clk) begin
        if (!rst_n) begin
            out_vsync <= 1'b0;
            out_de    <= 1'b0;
            out_data  <= 16'd0;
            out_rgb888 <= 24'd0;
            out_pixel_cnt <= 22'd0;
            eof_pulse_cnt <= 8'd0;
        end else begin
            if (eof_pulse_cnt != 8'd0) eof_pulse_cnt <= eof_pulse_cnt - 8'd1;

            out_vsync <= (eof_pulse_cnt != 8'd0);
            out_de    <= m_axis_tvalid;

            if (m_axis_tvalid) begin
                out_rgb888 <= m_axis_tdata;
                out_data   <= {m_axis_tdata[23:19], m_axis_tdata[15:10], m_axis_tdata[7:3]};

                if (m_axis_tuser) begin
                    out_pixel_cnt <= 22'd1;
                end else if (out_pixel_cnt == (FRAME_PIXELS - 22'd1)) begin
                    out_pixel_cnt <= 22'd0;
                    eof_pulse_cnt <= EOF_PULSE_WIDTH;
                end else begin
                    out_pixel_cnt <= out_pixel_cnt + 22'd1;
                end
            end
        end
    end

endmodule

