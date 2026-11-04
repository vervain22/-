`timescale 1ns / 1ps

module preprocess_pipeline #(
    parameter INPUT_STATS_REGISTERED = 0
) (
    input wire clk,
    input wire rst_n,

    // AXI-Stream输入接口

    input  wire [23:0] s_axis_tdata,
    // 附加信息由 preprocess.v 与 s_axis_tdata 同步寄存。
    // 默认参数兼容独立调用和算术参考路径。
    input  wire [ 7:0] s_axis_raw_y,
    input  wire        s_axis_rgb_unsaturated,
    input  wire        s_axis_tvalid,
    output wire        s_axis_tready,
    input  wire        s_axis_tuser,
    input  wire        s_axis_tlast,

    // AXI-Stream输出接口

    output wire [23:0] m_axis_tdata,
    output wire        m_axis_tvalid,
    input  wire        m_axis_tready,
    output wire        m_axis_tuser,
    output wire        m_axis_tlast,

    input wire [15:0] awb_gain_r,
    input wire [15:0] awb_gain_g,
    input wire [15:0] awb_gain_b
);

    //---------------------------------------------------
    // 1：场景类型和帧统计阈值
    //---------------------------------------------------
    // 根据上一帧统计结果，将画面划分为正常、低照、背光、强眩光、低对比度等场景
    // 场景结果会影响下一帧的亮度增强、白平衡强度和细节增强强度

    localparam        SCENE_NORMAL    = 3'd0;
    localparam        SCENE_LOW_LIGHT = 3'd1;
    localparam        SCENE_BACKLIGHT = 3'd2;
    localparam        SCENE_GLARE     = 3'd3;
    localparam        SCENE_LOW_CONTR = 3'd4;

    localparam [21:0] HIST_TAIL_COUNT = 22'd103680;  // 约为1920x1080整帧像素的5%
    localparam [21:0] VALID_MIN_COUNT = 22'd200000;

    //---------------------------------------------------
    // 2：流接口握手策略
    //---------------------------------------------------
    // HDMI输入链路不能暂停，因此本模块始终拉高s_axis_tready

    assign s_axis_tready = 1'b1;

    //---------------------------------------------------
    // 3：工具函数
    //---------------------------------------------------
    // luma_fast使用移位加法快速估计亮度；clamp/add函数负责像素限幅
    // tone_delta和detail_delta生成受限的亮度/细节增强量，避免过增强

    function [7:0] luma_fast;
        input [7:0] r;
        input [7:0] g;
        input [7:0] b;
        begin
            luma_fast = (r >> 2) + (g >> 1) + (b >> 2);
        end
    endfunction

    function [7:0] clamp_s12;
        input signed [11:0] value;
        begin
            if (value < 12'sd0) clamp_s12 = 8'd0;
            else if (value > 12'sd255) clamp_s12 = 8'd255;
            else clamp_s12 = value[7:0];
        end
    endfunction

    function [7:0] add_delta8;
        input [7:0] pix;
        input signed [10:0] delta;
        reg signed [11:0] sum;
        begin
            sum = $signed({4'b0000, pix}) + $signed({delta[10], delta});
            add_delta8 = clamp_s12(sum);
        end
    endfunction

    function signed [8:0] limit_bias;
        input signed [8:0] bias;
        begin
            if (bias > 9'sd18) limit_bias = 9'sd18;
            else if (bias < -9'sd18) limit_bias = -9'sd18;
            else limit_bias = bias;
        end
    endfunction

    function [8:0] abs_s9;
        input signed [8:0] value;
        begin
            if (value < 9'sd0) abs_s9 = -value;
            else abs_s9 = value;
        end
    endfunction

    function signed [10:0] limit_detail;
        input signed [10:0] value;
        begin
            if (value > 11'sd10) limit_detail = 11'sd10;
            else if (value < -11'sd10) limit_detail = -11'sd10;
            else limit_detail = value;
        end
    endfunction

    // 梯度减法独立寄存，后级再求绝对值、场景阈值及限幅。
    function signed [10:0] detail_from_gradient;
        input [7:0] curr_y;
        input signed [8:0] grad;
        input prev_valid;
        input line_first;
        input [2:0] scene;
        reg [8:0] abs_grad;
        reg signed [10:0] d;
        begin
            abs_grad = abs_s9(grad);
            d = 11'sd0;

            if (prev_valid && !line_first && (curr_y > 8'd24) && (curr_y < 8'd238)) begin
                case (scene)
                    SCENE_LOW_LIGHT: begin
                        if (abs_grad > 9'd22) d = $signed({{2{grad[8]}}, grad}) >>> 3;
                    end
                    SCENE_GLARE: begin
                        if ((abs_grad > 9'd18) && (curr_y < 8'd210)) d = $signed({{2{grad[8]}}, grad}) >>> 3;
                    end
                    SCENE_LOW_CONTR: begin
                        if (abs_grad > 9'd8) d = $signed({{2{grad[8]}}, grad}) >>> 2;
                    end
                    SCENE_BACKLIGHT: begin
                        if (abs_grad > 9'd10) d = $signed({{2{grad[8]}}, grad}) >>> 2;
                    end
                    default: begin
                        if (abs_grad > 9'd12) d = $signed({{2{grad[8]}}, grad}) >>> 3;
                    end
                endcase
            end

            detail_from_gradient = limit_detail(d);
        end
    endfunction

    function signed [9:0] tone_delta;
        input [7:0] y;
        input [2:0] scene;
        input [3:0] low_bin;
        input [3:0] high_bin;
        reg signed [9:0] d;
        reg [4:0] y_bin;
        reg [4:0] low_plus2;
        reg [4:0] high_minus1;
        begin
            d = 10'sd0;
            y_bin = {1'b0, y[7:4]};
            low_plus2 = {1'b0, low_bin} + 5'd2;
            high_minus1 = (high_bin == 4'd0) ? 5'd0 : ({1'b0, high_bin} - 5'd1);

            case (scene)
                SCENE_LOW_LIGHT: begin
                    if (y < 8'd80) d = 10'sd14 + $signed({2'b00, ((8'd80 - y) >> 1)});
                    else if (y < 8'd150) d = 10'sd8 + $signed({2'b00, ((8'd150 - y) >> 4)});
                    else if ((y_bin >= high_minus1) && (y > 8'd220)) d = -$signed({2'b00, ((y - 8'd220) >> 1)});
                end
                SCENE_BACKLIGHT: begin
                    if ((y_bin <= low_plus2) && (y < 8'd120)) d = 10'sd8 + $signed({2'b00, ((8'd120 - y) >> 3)});
                    else if ((y_bin >= high_minus1) && (y > 8'd205))
                        d = -10'sd4 - $signed({2'b00, ((y - 8'd205) >> 1)});
                end
                SCENE_GLARE: begin
                    if ((y_bin >= high_minus1) && (y > 8'd200)) d = -10'sd10 - $signed({2'b00, ((y - 8'd200) >> 1)});
                    else if ((y_bin <= low_plus2) && (y < 8'd80)) d = $signed({2'b00, ((8'd80 - y) >> 3)});
                end
                SCENE_LOW_CONTR: begin
                    if (y >= 8'd128) d = 10'sd2 + $signed({2'b00, ((y - 8'd128) >> 2)});
                    else d = -$signed({2'b00, ((8'd128 - y) >> 3)});
                end
                default: begin
                    if ((low_bin <= 4'd2) && (y < 8'd72)) d = $signed({2'b00, ((8'd72 - y) >> 3)});
                    else if ((high_bin >= 4'd14) && (y > 8'd225)) d = -$signed({2'b00, ((y - 8'd225) >> 2)});
                end
            endcase

            tone_delta = d;
        end
    endfunction

    //---------------------------------------------------
    // 4：输入RGB拆分和单像素统计源
    //---------------------------------------------------
    // 将输入RGB888拆成R/G/B三个通道，并计算快速亮度raw_y
    // raw_y用于直方图统计和场景判断；stat_valid_pixel用于筛除过暗/过曝像素
    // 让白平衡统计尽量只参考有效区域

    wire [7:0] raw_r = s_axis_tdata[23:16];
    wire [7:0] raw_g = s_axis_tdata[15:8];
    wire [7:0] raw_b = s_axis_tdata[7:0];
    wire [7:0] raw_y = INPUT_STATS_REGISTERED ? s_axis_raw_y : luma_fast(raw_r, raw_g, raw_b);
    wire [3:0] raw_y_bin = raw_y[7:4];
    wire       stat_valid_pixel =
        (raw_y > 8'd32) && (raw_y < 8'd230) &&
        (INPUT_STATS_REGISTERED ? s_axis_rgb_unsaturated :
         ((raw_r < 8'd245) && (raw_g < 8'd245) && (raw_b < 8'd245)));
    // 统计使能延迟一周期，隔开原始像素比较与累加；不影响像素增强流水线。
    reg stat_valid_pixel_d;

    //---------------------------------------------------
    // 5：帧统计累加器
    //---------------------------------------------------
    // 统计一整帧的亮度和、RGB通道和、有效白平衡像素和、暗像素数量、亮像素数量
    // 以及亮度最大/最小值。这些统计结果会在下一帧起始时用于更新场景和参数

    reg have_stats;
    reg [31:0] y_sum_acc;
    reg [31:0] r_sum_acc;
    reg [31:0] g_sum_acc;
    reg [31:0] b_sum_acc;
    reg [31:0] valid_r_sum_acc;
    reg [31:0] valid_g_sum_acc;
    reg [31:0] valid_b_sum_acc;
    // 累加结果先寄存，再选择帧首或复位值。
    // 控制译码不进入进位链的复位或数据输入。
    // 统计和图像参数的时序保持不变。
    wire [31:0] y_sum_acc_increment  /* synthesis syn_keep = 1 */;
    assign y_sum_acc_increment = y_sum_acc + {24'd0, raw_y};
    wire [31:0] r_sum_acc_increment  /* synthesis syn_keep = 1 */;
    assign r_sum_acc_increment = r_sum_acc + {24'd0, raw_r};
    wire [31:0] g_sum_acc_increment  /* synthesis syn_keep = 1 */;
    assign g_sum_acc_increment = g_sum_acc + {24'd0, raw_g};
    wire [31:0] b_sum_acc_increment  /* synthesis syn_keep = 1 */;
    assign b_sum_acc_increment = b_sum_acc + {24'd0, raw_b};
    wire [31:0] valid_r_sum_acc_increment  /* synthesis syn_keep = 1 */;
    assign valid_r_sum_acc_increment = valid_r_sum_acc + {24'd0, raw_r};
    wire [31:0] valid_g_sum_acc_increment  /* synthesis syn_keep = 1 */;
    assign valid_g_sum_acc_increment = valid_g_sum_acc + {24'd0, raw_g};
    wire [31:0] valid_b_sum_acc_increment  /* synthesis syn_keep = 1 */;
    assign valid_b_sum_acc_increment = valid_b_sum_acc + {24'd0, raw_b};
    reg  [21:0] valid_cnt_acc;
    reg  [21:0] dark_cnt_acc;
    wire [21:0] dark_cnt_increment  /* synthesis syn_keep = 1 */;
    assign dark_cnt_increment = dark_cnt_acc + 22'd1;
    reg  [21:0] bright_cnt_acc;
    // 帧首选择置于 22 位累加进位链之外。
    // 亮像素计数的进位输入与帧首选择分离。
    wire [21:0] bright_cnt_increment  /* synthesis syn_keep = 1 */;
    assign bright_cnt_increment = bright_cnt_acc + 22'd1;
    reg [7:0] y_min_acc;
    reg [7:0] y_max_acc;

    // 16 档亮度直方图，每档覆盖 16 级亮度。
    // 无需整帧缓存即可估计亮度两端分位。

    reg [21:0] hist0;
    reg [21:0] hist1;
    reg [21:0] hist2;
    reg [21:0] hist3;
    reg [21:0] hist4;
    reg [21:0] hist5;
    reg [21:0] hist6;
    reg [21:0] hist7;
    reg [21:0] hist8;
    reg [21:0] hist9;
    reg [21:0] hist10;
    reg [21:0] hist11;
    reg [21:0] hist12;
    reg [21:0] hist13;
    reg [21:0] hist14;
    reg [21:0] hist15;

    // 当前帧使用的平滑参数
    // 参数只在帧起始处根据上一帧统计结果更新，避免画面闪烁

    reg [2:0] scene_mode;
    reg signed [8:0] r_bias;
    reg signed [8:0] b_bias;
    reg [3:0] low_bin_param;
    reg [3:0] high_bin_param;
    reg next_param_valid;
    reg [2:0] next_scene_reg;
    reg signed [8:0] target_r_bias_reg;
    reg signed [8:0] target_b_bias_reg;
    reg [3:0] target_low_bin_reg;
    reg [3:0] target_high_bin_reg;

    // 帧参数计算分两级寄存，隔开统计减法、移位限幅及帧首参数更新。
    reg signed [8:0] awb_diff_r_pipe;
    reg signed [8:0] awb_diff_b_pipe;
    reg [2:0] next_scene_pipe;
    reg [3:0] target_low_bin_pipe;
    reg [3:0] target_high_bin_pipe;
    reg signed [8:0] target_r_bias_pipe;
    reg signed [8:0] target_b_bias_pipe;

    //---------------------------------------------------
    // 6：直方图CDF和亮度分位估计
    //---------------------------------------------------
    // 分别从亮度两端累加直方图，估计 5% 和 95% 分位所在区间。
    // 这些分位信息用于判断低照、过曝和低对比度场景

    wire [3:0] target_low_bin_fast = y_min_acc[7:4];
    wire [3:0] target_high_bin_fast = y_max_acc[7:4];
    wire [3:0] target_range_bin_fast =
        (target_high_bin_fast > target_low_bin_fast) ?
        (target_high_bin_fast - target_low_bin_fast) : 4'd0;

    //---------------------------------------------------
    // 7：基于上一帧统计结果的场景判断
    //---------------------------------------------------
    // 利用均值、亮度范围、暗像素/亮像素数量和直方图两端分布，判断下一帧应采用低照、背光、强眩光、低对比度或正常场景参数
    // 1920*1080接近2^21，因此这里用移位近似均值

    wire [7:0] prev_y_mean = y_sum_acc[28:21];
    wire [7:0] prev_r_mean = r_sum_acc[28:21];
    wire [7:0] prev_g_mean = g_sum_acc[28:21];
    wire [7:0] prev_b_mean = b_sum_acc[28:21];
    wire [7:0] prev_y_range = (y_max_acc > y_min_acc) ? (y_max_acc - y_min_acc) : 8'd0;

    wire prev_backlight = (target_low_bin_fast <= 4'd3) && (target_high_bin_fast >= 4'd13) &&
                          (dark_cnt_acc > 22'd350000) && (bright_cnt_acc > 22'd70000);
    wire prev_low_light = (prev_y_mean < 8'd70) || (target_high_bin_fast < 4'd8) || (dark_cnt_acc > 22'd1000000);
    wire prev_glare = (target_high_bin_fast >= 4'd14) || (bright_cnt_acc > 22'd260000) || (prev_y_mean > 8'd185);
    wire prev_low_contr = (target_range_bin_fast <= 4'd5) || (prev_y_range < 8'd80);

    wire [2:0] next_scene =
        prev_backlight ? SCENE_BACKLIGHT :
        prev_low_light ? SCENE_LOW_LIGHT :
        prev_glare     ? SCENE_GLARE :
        prev_low_contr ? SCENE_LOW_CONTR :
                         SCENE_NORMAL;

    //---------------------------------------------------
    // 8：有效像素白平衡目标和帧间平滑
    //---------------------------------------------------
    // 以G通道作为参考通道，优先使用有效像素统计计算R/B偏移目标
    // 如果有效像素不足，则退回使用整帧均值。r_bias和b_bias会缓慢逼近目标，避免颜色跳变

    wire signed [32:0] full_diff_r_sum = $signed({1'b0, prev_g_mean}) - $signed({1'b0, prev_r_mean});
    wire signed [32:0] full_diff_b_sum = $signed({1'b0, prev_g_mean}) - $signed({1'b0, prev_b_mean});
    wire signed [32:0] valid_diff_r_sum = $signed({1'b0, valid_g_sum_acc}) - $signed({1'b0, valid_r_sum_acc});
    wire signed [32:0] valid_diff_b_sum = $signed({1'b0, valid_g_sum_acc}) - $signed({1'b0, valid_b_sum_acc});
    wire signed [32:0] valid_diff_r_sh  =
        (valid_cnt_acc > 22'd1500000) ? (valid_diff_r_sum >>> 21) :
        (valid_cnt_acc > 22'd750000)  ? (valid_diff_r_sum >>> 20) :
        (valid_cnt_acc > 22'd375000)  ? (valid_diff_r_sum >>> 19) :
                                        (valid_diff_r_sum >>> 18);
    wire signed [32:0] valid_diff_b_sh  =
        (valid_cnt_acc > 22'd1500000) ? (valid_diff_b_sum >>> 21) :
        (valid_cnt_acc > 22'd750000)  ? (valid_diff_b_sum >>> 20) :
        (valid_cnt_acc > 22'd375000)  ? (valid_diff_b_sum >>> 19) :
                                        (valid_diff_b_sum >>> 18);
    wire signed [8:0] awb_diff_r = (valid_cnt_acc > VALID_MIN_COUNT) ? valid_diff_r_sh[8:0] : full_diff_r_sum[8:0];
    wire signed [8:0] awb_diff_b = (valid_cnt_acc > VALID_MIN_COUNT) ? valid_diff_b_sh[8:0] : full_diff_b_sum[8:0];

    wire signed [9:0] r_bias_diff = $signed({target_r_bias_reg[8], target_r_bias_reg}) - $signed({r_bias[8], r_bias});
    wire signed [9:0] b_bias_diff = $signed({target_b_bias_reg[8], target_b_bias_reg}) - $signed({b_bias[8], b_bias});
    wire signed [9:0] r_bias_next = $signed({r_bias[8], r_bias}) + (r_bias_diff >>> 2);
    wire signed [9:0] b_bias_next = $signed({b_bias[8], b_bias}) + (b_bias_diff >>> 2);

    //---------------------------------------------------
    // 9：第一级流水线，白平衡校正
    //---------------------------------------------------
    // 将平滑后的R/B通道偏移作用到当前流式像素，G通道保持为参考通道

    wire signed [10:0] r_bias_ext = {{2{r_bias[8]}}, r_bias};
    wire signed [10:0] b_bias_ext = {{2{b_bias[8]}}, b_bias};
    wire [7:0] awb_r_now = add_delta8(raw_r, r_bias_ext);
    wire [7:0] awb_b_now = add_delta8(raw_b, b_bias_ext);
    // 白平衡限幅与亮度计算之间插入一级 RGB 寄存。

    //---------------------------------------------------
    // 10：图像增强流水线寄存器
    //---------------------------------------------------
    // stage1保存白平衡后的像素；stage2保存全局亮度增强相关数据
    // stage3 保存全局亮度调整后的像素，送入局部细节增强。
    // valid/user/last控制信号与像素数据同步延迟，保证帧起始和行尾对齐

    (* syn_preserve=1 *) reg [7:0] stage1_r;
    (* syn_preserve=1 *) reg [7:0] stage1_g;
    (* syn_preserve=1 *) reg [7:0] stage1_b;
    (* syn_preserve=1 *) reg [7:0] stage1_y;
    reg stage1_valid;
    reg stage1_user;
    reg stage1_last;

    // RGB 与附加信息同步延迟一级，配合白平衡亮度寄存。
    (* syn_preserve=1 *) reg [7:0] awb_luma_r, awb_luma_g, awb_luma_b;
    reg awb_luma_valid, awb_luma_user, awb_luma_last;
    // 色调及细节参数随像素延迟，帧首无消隐时也保持对应关系。
    reg [2:0] pixel_scene_d;
    reg [3:0] pixel_low_bin_d, pixel_high_bin_d;

    reg        [ 7:0] stage2_r;
    reg        [ 7:0] stage2_g;
    reg        [ 7:0] stage2_b;
    reg signed [10:0] stage2_tone;
    reg               stage2_valid;
    reg               stage2_user;
    reg               stage2_last;

    wire       [ 7:0] tone_r_now = add_delta8(stage2_r, stage2_tone);
    wire       [ 7:0] tone_g_now = add_delta8(stage2_g, stage2_tone);
    wire       [ 7:0] tone_b_now = add_delta8(stage2_b, stage2_tone);

    reg        [ 7:0] stage3_r;
    reg        [ 7:0] stage3_g;
    reg        [ 7:0] stage3_b;
    reg        [ 7:0] stage3_y;
    reg               stage3_valid;
    reg               stage3_user;
    reg               stage3_last;

    // 三通道限幅结果先寄存，再计算亮度，避免组合路径过长。
    reg        [ 7:0] tone_pipe_r;
    reg        [ 7:0] tone_pipe_g;
    reg        [ 7:0] tone_pipe_b;
    reg               tone_pipe_valid;
    reg               tone_pipe_user;
    reg               tone_pipe_last;

    // 末级细节增强前再打一拍，避免 stage3_y 直接经过 detail_delta 和
    // 三路限幅加法后驱动输出寄存器，缩短 pix_clk_in 的最长组合路径。
    reg        [ 7:0] stage4_r;
    reg        [ 7:0] stage4_g;
    reg        [ 7:0] stage4_b;
    reg        [ 7:0] stage4_y;
    reg               stage4_valid;
    reg               stage4_user;
    reg               stage4_last;

    // 细节流水：相邻亮度相减、求幅值与场景阈值、限幅、叠加 RGB；控制信号等延迟。
    // prev_detail_y 仅在 stage4_valid 有效时更新，保持相邻像素对应。
    reg        [ 7:0] stage5_r;
    reg        [ 7:0] stage5_g;
    reg        [ 7:0] stage5_b;
    reg               stage5_valid;
    reg               stage5_user;
    reg               stage5_last;
    reg signed [10:0] detail_d11_reg;

    // 亮度差、绝对值、阈值判断及移位限幅分别流水处理。
    // 在同一采样周期锁存全部操作数及场景参数。
    reg signed [ 8:0] detail_grad_reg;
    reg        [ 7:0] detail_y_reg;
    reg detail_prev_valid_reg, detail_user_reg;
    reg [2:0] detail_scene_reg;
    reg [7:0] stage6_r, stage6_g, stage6_b;
    reg stage6_valid, stage6_user, stage6_last;

    reg [7:0] prev_detail_y;
    reg prev_detail_valid;

    // stage2/stage3使用的全局亮度增强量和局部细节增强量

    wire signed [9:0] tone_d10_now = tone_delta(stage1_y, pixel_scene_d, pixel_low_bin_d, pixel_high_bin_d);
    wire signed [10:0] tone_d11_now = {tone_d10_now[9], tone_d10_now};
    wire signed [10:0] detail_d11_now = detail_from_gradient(
        detail_y_reg, detail_grad_reg, detail_prev_valid_reg, detail_user_reg, detail_scene_reg
    );

    reg [23:0] out_tdata_reg;
    reg out_tvalid_reg;
    reg out_tuser_reg;
    reg out_tlast_reg;

    //---------------------------------------------------
    // 11：主时序逻辑，像素流水线和帧统计更新
    //---------------------------------------------------
    // 逐拍推进白平衡、全局亮度调整和局部细节增强流水线。
    // 有效输入期间累加帧统计，下一帧开始时更新场景参数。

    always @(posedge clk) begin
        if (!rst_n) begin
            have_stats            <= 1'b0;
            y_sum_acc             <= 32'd0;
            r_sum_acc             <= 32'd0;
            g_sum_acc             <= 32'd0;
            b_sum_acc             <= 32'd0;
            valid_r_sum_acc       <= 32'd0;
            valid_g_sum_acc       <= 32'd0;
            valid_b_sum_acc       <= 32'd0;
            valid_cnt_acc         <= 22'd0;
            dark_cnt_acc          <= 22'd0;
            bright_cnt_acc        <= 22'd0;
            y_min_acc             <= 8'd255;
            y_max_acc             <= 8'd0;
            scene_mode            <= SCENE_NORMAL;
            r_bias                <= 9'sd0;
            b_bias                <= 9'sd0;
            low_bin_param         <= 4'd1;
            high_bin_param        <= 4'd14;
            next_param_valid      <= 1'b0;
            next_scene_reg        <= SCENE_NORMAL;
            target_r_bias_reg     <= 9'sd0;
            target_b_bias_reg     <= 9'sd0;
            target_low_bin_reg    <= 4'd1;
            target_high_bin_reg   <= 4'd14;
            awb_diff_r_pipe       <= 9'sd0;
            awb_diff_b_pipe       <= 9'sd0;
            next_scene_pipe       <= SCENE_NORMAL;
            target_low_bin_pipe   <= 4'd1;
            target_high_bin_pipe  <= 4'd14;
            target_r_bias_pipe    <= 9'sd0;
            target_b_bias_pipe    <= 9'sd0;
            out_tdata_reg         <= 24'd0;
            out_tvalid_reg        <= 1'b0;
            out_tuser_reg         <= 1'b0;
            out_tlast_reg         <= 1'b0;
            stage1_r              <= 8'd0;
            stage1_g              <= 8'd0;
            stage1_b              <= 8'd0;
            stage1_y              <= 8'd0;
            stage1_valid          <= 1'b0;
            stage1_user           <= 1'b0;
            stage1_last           <= 1'b0;
            awb_luma_r            <= 0;
            awb_luma_g            <= 0;
            awb_luma_b            <= 0;
            awb_luma_valid        <= 0;
            awb_luma_user         <= 0;
            awb_luma_last         <= 0;
            pixel_scene_d         <= SCENE_NORMAL;
            pixel_low_bin_d       <= 4'd1;
            pixel_high_bin_d      <= 4'd14;
            stage2_r              <= 8'd0;
            stage2_g              <= 8'd0;
            stage2_b              <= 8'd0;
            stage2_tone           <= 11'sd0;
            stage2_valid          <= 1'b0;
            stage2_user           <= 1'b0;
            stage2_last           <= 1'b0;
            stage3_r              <= 8'd0;
            stage3_g              <= 8'd0;
            stage3_b              <= 8'd0;
            stage3_y              <= 8'd0;
            stage3_valid          <= 1'b0;
            stage3_user           <= 1'b0;
            stage3_last           <= 1'b0;
            tone_pipe_r           <= 8'd0;
            tone_pipe_g           <= 8'd0;
            tone_pipe_b           <= 8'd0;
            tone_pipe_valid       <= 1'b0;
            tone_pipe_user        <= 1'b0;
            tone_pipe_last        <= 1'b0;
            stage4_r              <= 8'd0;
            stage4_g              <= 8'd0;
            stage4_b              <= 8'd0;
            stage4_y              <= 8'd0;
            stage4_valid          <= 1'b0;
            stage4_user           <= 1'b0;
            stage4_last           <= 1'b0;
            stage5_r              <= 8'd0;
            stage5_g              <= 8'd0;
            stage5_b              <= 8'd0;
            stage5_valid          <= 1'b0;
            stage5_user           <= 1'b0;
            stage5_last           <= 1'b0;
            detail_d11_reg        <= 11'sd0;
            detail_grad_reg       <= 0;
            detail_y_reg          <= 0;
            detail_prev_valid_reg <= 0;
            detail_user_reg       <= 0;
            detail_scene_reg      <= 0;
            stage6_r              <= 0;
            stage6_g              <= 0;
            stage6_b              <= 0;
            stage6_valid          <= 0;
            stage6_user           <= 0;
            stage6_last           <= 0;
            prev_detail_y         <= 8'd0;
            prev_detail_valid     <= 1'b0;
            stat_valid_pixel_d    <= 1'b0;
            hist0                 <= 22'd0;
            hist1                 <= 22'd0;
            hist2                 <= 22'd0;
            hist3                 <= 22'd0;
            hist4                 <= 22'd0;
            hist5                 <= 22'd0;
            hist6                 <= 22'd0;
            hist7                 <= 22'd0;
            hist8                 <= 22'd0;
            hist9                 <= 22'd0;
            hist10                <= 22'd0;
            hist11                <= 22'd0;
            hist12                <= 22'd0;
            hist13                <= 22'd0;
            hist14                <= 22'd0;
            hist15                <= 22'd0;
        end else begin
            stat_valid_pixel_d <= s_axis_tvalid && stat_valid_pixel;

            // 帧参数两级计算：先采样统计值，再限制偏置，帧首读取已寄存结果。
            awb_diff_r_pipe <= awb_diff_r;
            awb_diff_b_pipe <= awb_diff_b;
            next_scene_pipe <= next_scene;
            target_low_bin_pipe <= target_low_bin_fast;
            target_high_bin_pipe <= target_high_bin_fast;
            target_r_bias_pipe <= (next_scene_pipe == SCENE_LOW_LIGHT) ? limit_bias(
                awb_diff_r_pipe >>> 2
            ) : limit_bias(
                awb_diff_r_pipe >>> 1
            );
            target_b_bias_pipe <= (next_scene_pipe == SCENE_LOW_LIGHT) ? limit_bias(
                awb_diff_b_pipe >>> 2
            ) : limit_bias(
                awb_diff_b_pipe >>> 1
            );

            // 像素流水线：控制信号valid/user/last与像素数据同步延迟
            stage1_valid <= s_axis_tvalid;
            stage1_user <= s_axis_tuser;
            stage1_last <= s_axis_tlast;

            if (s_axis_tvalid) begin
                stage1_r <= awb_r_now;
                stage1_g <= raw_g;
                stage1_b <= awb_b_now;

            end

            pixel_scene_d <= scene_mode;
            pixel_low_bin_d <= low_bin_param;
            pixel_high_bin_d <= high_bin_param;
            awb_luma_valid <= stage1_valid;
            awb_luma_user <= stage1_user;
            awb_luma_last <= stage1_last;
            if (stage1_valid) begin
                awb_luma_r <= stage1_r;
                awb_luma_g <= stage1_g;
                awb_luma_b <= stage1_b;
                stage1_y   <= luma_fast(stage1_r, stage1_g, stage1_b);
            end
            stage2_valid <= awb_luma_valid;
            stage2_user  <= awb_luma_user;
            stage2_last  <= awb_luma_last;

            if (awb_luma_valid) begin
                stage2_r    <= awb_luma_r;
                stage2_g    <= awb_luma_g;
                stage2_b    <= awb_luma_b;
                stage2_tone <= tone_d11_now;
            end

            // 三通道色调限幅先寄存，stage3 仅计算亮度，像素顺序不变。
            tone_pipe_valid <= stage2_valid;
            tone_pipe_user  <= stage2_user;
            tone_pipe_last  <= stage2_last;
            if (stage2_valid) begin
                tone_pipe_r <= tone_r_now;
                tone_pipe_g <= tone_g_now;
                tone_pipe_b <= tone_b_now;
            end

            stage3_valid <= tone_pipe_valid;
            stage3_user  <= tone_pipe_user;
            stage3_last  <= tone_pipe_last;

            if (tone_pipe_valid) begin
                stage3_r <= tone_pipe_r;
                stage3_g <= tone_pipe_g;
                stage3_b <= tone_pipe_b;
                stage3_y <= luma_fast(tone_pipe_r, tone_pipe_g, tone_pipe_b);
            end

            stage4_valid <= stage3_valid;
            stage4_user  <= stage3_user;
            stage4_last  <= stage3_last;
            if (stage3_valid) begin
                stage4_r <= stage3_r;
                stage4_g <= stage3_g;
                stage4_b <= stage3_b;
                stage4_y <= stage3_y;
            end

            // 相邻有效像素及场景参数同步采样，RGB 和控制信号增加一级匹配延迟。
            detail_grad_reg <= $signed({1'b0, stage4_y}) - $signed({1'b0, prev_detail_y});
            detail_y_reg <= stage4_y;
            detail_prev_valid_reg <= prev_detail_valid;
            detail_user_reg <= stage4_user;
            detail_scene_reg <= pixel_scene_d;
            detail_d11_reg <= detail_d11_now;
            if (stage4_valid) begin
                prev_detail_y <= stage4_y;
                if (stage4_last) prev_detail_valid <= 1'b0;
                else prev_detail_valid <= 1'b1;
            end

            stage5_valid <= stage4_valid;
            stage5_user  <= stage4_user;
            stage5_last  <= stage4_last;
            if (stage4_valid) begin
                stage5_r <= stage4_r;
                stage5_g <= stage4_g;
                stage5_b <= stage4_b;
            end

            stage6_valid <= stage5_valid;
            stage6_user  <= stage5_user;
            stage6_last  <= stage5_last;
            if (stage5_valid) begin
                stage6_r <= stage5_r;
                stage6_g <= stage5_g;
                stage6_b <= stage5_b;
            end
            out_tvalid_reg <= stage6_valid;
            out_tuser_reg  <= stage6_user;
            out_tlast_reg  <= stage6_last;

            if (stage6_valid) begin
                out_tdata_reg[23:16] <= add_delta8(stage6_r, detail_d11_reg);
                out_tdata_reg[15:8]  <= add_delta8(stage6_g, detail_d11_reg);
                out_tdata_reg[7:0]   <= add_delta8(stage6_b, detail_d11_reg);
            end

            if (s_axis_tvalid) begin
                if (s_axis_tuser) begin
                    if (have_stats) begin

                        if (next_param_valid) begin
                            scene_mode <= next_scene_reg;
                            r_bias     <= limit_bias(r_bias_next[8:0]);
                            b_bias     <= limit_bias(b_bias_next[8:0]);

                            if (target_low_bin_reg > low_bin_param) low_bin_param <= low_bin_param + 4'd1;
                            else if (target_low_bin_reg < low_bin_param) low_bin_param <= low_bin_param - 4'd1;

                            if (target_high_bin_reg > high_bin_param) high_bin_param <= high_bin_param + 4'd1;
                            else if (target_high_bin_reg < high_bin_param) high_bin_param <= high_bin_param - 4'd1;
                        end else begin
                            scene_mode     <= SCENE_NORMAL;
                            r_bias         <= 9'sd0;
                            b_bias         <= 9'sd0;
                            low_bin_param  <= 4'd1;
                            high_bin_param <= 4'd14;
                        end

                        next_param_valid  <= 1'b1;
                        next_scene_reg    <= next_scene_pipe;
                        target_r_bias_reg <= target_r_bias_pipe;
                        target_b_bias_reg <= target_b_bias_pipe;
                        target_low_bin_reg <= target_low_bin_pipe;
                        target_high_bin_reg <= target_high_bin_pipe;
                    end else begin
                        have_stats          <= 1'b1;
                        scene_mode          <= SCENE_NORMAL;
                        r_bias              <= 9'sd0;
                        b_bias              <= 9'sd0;
                        low_bin_param       <= 4'd1;
                        high_bin_param      <= 4'd14;
                        next_param_valid    <= 1'b0;
                        next_scene_reg      <= SCENE_NORMAL;
                        target_r_bias_reg   <= 9'sd0;
                        target_b_bias_reg   <= 9'sd0;
                        target_low_bin_reg  <= 4'd1;
                        target_high_bin_reg <= 4'd14;
                    end

                    y_sum_acc      <= {24'd0, raw_y};
                    r_sum_acc      <= {24'd0, raw_r};
                    g_sum_acc      <= {24'd0, raw_g};
                    b_sum_acc      <= {24'd0, raw_b};
                    dark_cnt_acc   <= (raw_y < 8'd48) ? 22'd1 : 22'd0;
                    bright_cnt_acc <= (raw_y > 8'd220) ? 22'd1 : 22'd0;
                    y_min_acc      <= raw_y;
                    y_max_acc      <= raw_y;
                    hist0          <= (raw_y_bin == 4'd0) ? 22'd1 : 22'd0;
                    hist1          <= (raw_y_bin == 4'd1) ? 22'd1 : 22'd0;
                    hist2          <= (raw_y_bin == 4'd2) ? 22'd1 : 22'd0;
                    hist3          <= (raw_y_bin == 4'd3) ? 22'd1 : 22'd0;
                    hist4          <= (raw_y_bin == 4'd4) ? 22'd1 : 22'd0;
                    hist5          <= (raw_y_bin == 4'd5) ? 22'd1 : 22'd0;
                    hist6          <= (raw_y_bin == 4'd6) ? 22'd1 : 22'd0;
                    hist7          <= (raw_y_bin == 4'd7) ? 22'd1 : 22'd0;
                    hist8          <= (raw_y_bin == 4'd8) ? 22'd1 : 22'd0;
                    hist9          <= (raw_y_bin == 4'd9) ? 22'd1 : 22'd0;
                    hist10         <= (raw_y_bin == 4'd10) ? 22'd1 : 22'd0;
                    hist11         <= (raw_y_bin == 4'd11) ? 22'd1 : 22'd0;
                    hist12         <= (raw_y_bin == 4'd12) ? 22'd1 : 22'd0;
                    hist13         <= (raw_y_bin == 4'd13) ? 22'd1 : 22'd0;
                    hist14         <= (raw_y_bin == 4'd14) ? 22'd1 : 22'd0;
                    hist15         <= (raw_y_bin == 4'd15) ? 22'd1 : 22'd0;

                    if (stat_valid_pixel_d) begin
                        valid_r_sum_acc <= {24'd0, raw_r};
                        valid_g_sum_acc <= {24'd0, raw_g};
                        valid_b_sum_acc <= {24'd0, raw_b};
                        valid_cnt_acc   <= 22'd1;
                    end else begin
                        valid_r_sum_acc <= 32'd0;
                        valid_g_sum_acc <= 32'd0;
                        valid_b_sum_acc <= 32'd0;
                        valid_cnt_acc   <= 22'd0;
                    end
                end else begin
                    y_sum_acc <= y_sum_acc_increment;
                    r_sum_acc <= r_sum_acc_increment;
                    g_sum_acc <= g_sum_acc_increment;
                    b_sum_acc <= b_sum_acc_increment;
                    if (raw_y < 8'd48) dark_cnt_acc <= dark_cnt_increment;
                    if (raw_y > 8'd220) bright_cnt_acc <= bright_cnt_increment;
                    case (raw_y_bin)
                        4'd0: hist0 <= hist0 + 22'd1;
                        4'd1: hist1 <= hist1 + 22'd1;
                        4'd2: hist2 <= hist2 + 22'd1;
                        4'd3: hist3 <= hist3 + 22'd1;
                        4'd4: hist4 <= hist4 + 22'd1;
                        4'd5: hist5 <= hist5 + 22'd1;
                        4'd6: hist6 <= hist6 + 22'd1;
                        4'd7: hist7 <= hist7 + 22'd1;
                        4'd8: hist8 <= hist8 + 22'd1;
                        4'd9: hist9 <= hist9 + 22'd1;
                        4'd10: hist10 <= hist10 + 22'd1;
                        4'd11: hist11 <= hist11 + 22'd1;
                        4'd12: hist12 <= hist12 + 22'd1;
                        4'd13: hist13 <= hist13 + 22'd1;
                        4'd14: hist14 <= hist14 + 22'd1;
                        default: hist15 <= hist15 + 22'd1;
                    endcase

                    if (stat_valid_pixel_d) begin
                        valid_r_sum_acc <= valid_r_sum_acc_increment;
                        valid_g_sum_acc <= valid_g_sum_acc_increment;
                        valid_b_sum_acc <= valid_b_sum_acc_increment;
                        valid_cnt_acc   <= valid_cnt_acc + 22'd1;
                    end

                    if (raw_y < y_min_acc) y_min_acc <= raw_y;
                    if (raw_y > y_max_acc) y_max_acc <= raw_y;
                end
            end
        end
    end

    //---------------------------------------------------
    // 12：AXI-Stream输出赋值
    //---------------------------------------------------
    assign m_axis_tdata  = out_tdata_reg;
    assign m_axis_tvalid = out_tvalid_reg;
    assign m_axis_tuser  = out_tuser_reg;
    assign m_axis_tlast  = out_tlast_reg;

endmodule
