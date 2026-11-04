//---------------------------------------------------

// Copyright (c) 2019 PANGO MICROSYSTEMS, INC
// ALL RIGHTS REVERVED.

// THE SOURCE CODE CONTAINED HEREIN IS PROPRIETARY TO PANGO MICROSYSTEMS, INC.
// IT SHALL NOT BE REPRODUCED OR DISCLOSED IN WHOLE OR IN PART OR USED BY
// PARTIES WITHOUT WRITTEN AUTHORIZATION FROM THE OWNER.

//---------------------------------------------------

//---------------------------------------------------
`timescale 1ns / 100fs

module ipm2l_hsstlp_wrapper_v1_6 #(
    // 全局参数
    parameter PLL0_EN = "FALSE",  // PLL0 使能
    parameter PLL1_EN = "FALSE",  // PLL1 使能
    parameter CH0_EN = "DISABLE",  // 取值：全双工、仅发送、仅接收或禁用。
    parameter CH1_EN = "DISABLE",  // 取值：全双工、仅发送、仅接收或禁用。
    parameter CH2_EN = "DISABLE",  // 取值：全双工、仅发送、仅接收或禁用。
    parameter CH3_EN = "DISABLE",  // 取值：全双工、仅发送、仅接收或禁用。
    parameter CHANNEL0_EN = "FALSE",  // 通道 0 使能。
    parameter CHANNEL1_EN = "FALSE",  // 通道 1 使能。
    parameter CHANNEL2_EN = "FALSE",  // 通道 2 使能。
    parameter CHANNEL3_EN = "FALSE",  // 通道 3 使能。
    parameter TX_CHANNEL0_PLL = 0,  // 0 选择 PLL0，1 选择 PLL1。
    parameter TX_CHANNEL1_PLL = 0,  // 0 选择 PLL0，1 选择 PLL1。
    parameter TX_CHANNEL2_PLL = 0,  // 0 选择 PLL0，1 选择 PLL1。
    parameter TX_CHANNEL3_PLL = 0,  // 0 选择 PLL0，1 选择 PLL1。
    parameter RX_CHANNEL0_PLL = 0,  // 0 选择 PLL0，1 选择 PLL1。
    parameter RX_CHANNEL1_PLL = 0,  // 0 选择 PLL0，1 选择 PLL1。
    parameter RX_CHANNEL2_PLL = 0,  // 0 选择 PLL0，1 选择 PLL1。
    parameter RX_CHANNEL3_PLL = 0,  // 0 选择 PLL0，1 选择 PLL1。
    parameter CH0_MULT_LANE_MODE = 1,  // 通道 0 配置：1 单通道，2 双通道，4 四通道。
    parameter CH1_MULT_LANE_MODE = 1,  // 通道 1 配置：1 单通道，2 双通道，4 四通道。
    parameter CH2_MULT_LANE_MODE = 1,  // 通道 2 配置：1 单通道，2 双通道，4 四通道。
    parameter CH3_MULT_LANE_MODE = 1,  // 通道 3 配置：1 单通道，2 双通道，4 四通道。
    parameter PLL0_TXPCLK_PLL_SEL = 0,  // PLL0 时钟来自通道 0。
    parameter PLL1_TXPCLK_PLL_SEL = 0,  // PLL1 时钟来自通道 0。
    // PLL0 参数
    parameter integer PMA_PLL0_TX_SYNCK_PD = 0,  // 发送同步电荷泵控制：0 上电，1 掉电。
    parameter PMA_PLL0_REG_REFCLK_TERM_IMP_CTRL = "TRUE",  // 参考时钟终端阻抗选择，不支持仿真。

    parameter integer PMA_PLL0_REG_BG_TRIM         = 2,        // 电压电流转换配置，不支持仿真。
    parameter integer PMA_PLL0_REG_IBUP_A1         = 262143,   // 电压电流转换配置，不支持仿真。
    parameter integer PMA_PLL0_REG_IBUP_A2         = 3072,     // 电压电流转换配置，不支持仿真。
    parameter integer PMA_PLL0_REG_IBUP_PD         = 0,        // 电压电流转换配置，不支持仿真。
    parameter         PMA_PLL0_REG_V2I_BIAS_SEL    = "FALSE",  // 电压电流转换配置，不支持仿真。
    parameter         PMA_PLL0_REG_V2I_EN          = "TRUE",   // 电压电流转换配置，不支持仿真。
    parameter integer PMA_PLL0_REG_V2I_TB_SEL      = 0,        // 电压电流转换配置，不支持仿真。
    parameter         PMA_PLL0_REG_V2I_RCALTEST_PD = "FALSE",  // 电压电流转换配置，不支持仿真。
    parameter integer PMA_PLL0_REG_RES_CAL_TEST    = 0,        // 电压电流转换配置，不支持仿真。
    parameter integer PMA_PLL0_RES_CAL_DIV         = 0,        // 电压电流转换配置，不支持仿真。
    parameter         PMA_PLL0_RES_CAL_CLK_SEL     = "FALSE",  // 电压电流转换配置，不支持仿真。

    parameter PMA_PLL0_REG_PLL_PFDDELAY_EN = "TRUE",  // 使能选项：开启或关闭。
    parameter integer PMA_PLL0_REG_PFDDELAYSEL = 1,
    parameter integer PMA_PLL0_REG_PLL_VCTRL_SET = 0,
    parameter PMA_PLL0_REG_READY_OR_LOCK = "FALSE",  // 使能选项：开启或关闭。
    parameter integer PMA_PLL0_REG_PLL_CP = 31,  // 电流配置范围：1～1023，默认 31。
    parameter integer PMA_PLL0_REG_PLL_REFDIV = 16,  // PLL 参考时钟分频 M，默认 16。
    parameter PMA_PLL0_REG_PLL_LOCKDET_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_PLL0_REG_PLL_READY = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_PLL0_REG_PLL_READY_OW = "FALSE",  // 使能选项：开启或关闭。
    parameter    integer    PMA_PLL0_REG_PLL_FBDIV = 36                       ,// PLL 反馈分频 N2 由 Pll_fbdiv[5] 决定：1 对应 5，0 对应 4。
                                                                               // PLL 反馈分频 N1 可取 1、2、3、4、5、6、8、10。
    parameter integer PMA_PLL0_REG_LPF_RES = 1,  // 低通滤波电阻控制，默认 1。
    parameter PMA_PLL0_REG_JTAG_OE = "FALSE",  // PLL JTAG 输出使能
    parameter integer PMA_PLL0_REG_JTAG_VHYSTSEL = 0,  // PLL JTAG 门限电压选择，默认 0。
    parameter PMA_PLL0_REG_PLL_LOCKDET_EN_OW = "FALSE",  // 使能选项：开启或关闭。
    parameter    integer    PMA_PLL0_REG_PLL_LOCKDET_FBCT = 7                 ,// 计数编码 0～7 分别对应 2^9～2^15、2^16−1，默认编码 7。
    parameter    integer    PMA_PLL0_REG_PLL_LOCKDET_ITER = 3                 ,// 编码 0～7 对应 1、2、4、8、16、32、64、127，默认编码 3。
    parameter PMA_PLL0_REG_PLL_LOCKDET_MODE = "FALSE",  // 使能选项：开启或关闭。
    parameter    integer    PMA_PLL0_REG_PLL_LOCKDET_LOCKCT = 4               ,// 编码 0～7 对应 2、4、8、16、32、64、128、256，默认编码 4。
    parameter    integer    PMA_PLL0_REG_PLL_LOCKDET_REFCT = 7                ,// 计数编码 0～7 分别对应 2^9～2^15、2^16−1，默认编码 7。
    parameter PMA_PLL0_REG_PLL_LOCKDET_RESET_N = "TRUE",  // 使能选项：开启或关闭。
    parameter PMA_PLL0_REG_PLL_LOCKDET_RESET_N_OW = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_PLL0_REG_PLL_LOCKED = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_PLL0_REG_PLL_LOCKED_OW = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_PLL0_REG_PLL_LOCKED_STICKY_CLEAR = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_PLL0_REG_PLL_UNLOCKED = "FALSE",  // 使能选项：开启或关闭。
    parameter    integer    PMA_PLL0_REG_PLL_UNLOCKDET_ITER = 2               ,// 编码 00、01、10、11 对应 63、127、255、1023，默认编码 10。
    parameter PMA_PLL0_REG_PLL_UNLOCKED_OW = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_PLL0_REG_PLL_UNLOCKED_STICKY_CLEAR = "FALSE",  // 使能选项：开启或关闭。
    parameter integer PMA_PLL0_REG_I_CTRL_MAX = 63,  // 取值范围：0～63，默认全 1。
    parameter PMA_PLL0_REG_REFCLK_TEST_EN = "FALSE",  // 参考时钟端口测试使能
    parameter PMA_PLL0_REG_RESCAL_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter integer PMA_PLL0_REG_I_CTRL_MIN = 0,  // 取值范围：0～63。
    parameter PMA_PLL0_REG_RESCAL_DONE_OW = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_PLL0_REG_RESCAL_DONE_VAL = "FALSE",  // 使能选项：开启或关闭。
    parameter integer PMA_PLL0_REG_RESCAL_I_CODE = 46,  // 取值范围：0～63。
    parameter PMA_PLL0_REG_RESCAL_I_CODE_OW = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_PLL0_REG_RESCAL_I_CODE_PMA = "FALSE",  // 使能选项：开启或关闭。
    parameter integer PMA_PLL0_REG_RESCAL_I_CODE_VAL = 46,  // 取值范围：0～63。
    parameter PMA_PLL0_REG_RESCAL_INT_R_SMALL_OW = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_PLL0_REG_RESCAL_INT_R_SMALL_VAL = "FALSE",  // 使能选项：开启或关闭。
    parameter integer PMA_PLL0_REG_RESCAL_ITER_VALID_SEL = 0,  //0,1,2,3
    parameter PMA_PLL0_REG_RESCAL_RESET_N_OW = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_PLL0_REG_RESCAL_RST_N_VAL = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_PLL0_REG_RESCAL_WAIT_SEL = "TRUE",  // 使能选项：开启或关闭。
    parameter PMA_PLL0_REFCLK2LANE_PD_L = "FALSE",  // 左侧 PLL 参考时钟掉电控制
    parameter PMA_PLL0_REFCLK2LANE_PD_R = "FALSE",  // 右侧 PLL 参考时钟掉电控制
    parameter PMA_PLL0_REG_LOCKDET_REPEAT = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_PLL0_REG_NOFBCLK_STICKY_CLEAR = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_PLL0_REG_NOREFCLK_STICKY_CLEAR = "FALSE",  // 使能选项：开启或关闭。
    parameter integer PMA_PLL0_REG_TEST_SEL = 15,  // 测试取值范围：0～20。
    parameter PMA_PLL0_REG_TEST_V_EN = "FALSE",  // 测试使能
    parameter PMA_PLL0_REG_TEST_SIG_HALF_EN = "FALSE",  // 测试使能
    parameter PMA_PLL0_REG_REFCLK_PAD_SEL = "FALSE",  // 参考时钟选择
    parameter PMA_PLL0_PARM_PLL_POWERUP = "OFF",  // 使能选项：开启或关闭。
    // PLL1 参数
    parameter integer PMA_PLL1_TX_SYNCK_PD = 0,  // 发送同步电荷泵控制：0 上电，1 掉电。
    parameter PMA_PLL1_REG_REFCLK_TERM_IMP_CTRL = "TRUE",  // 参考时钟终端阻抗选择，不支持仿真。

    parameter integer PMA_PLL1_REG_BG_TRIM         = 2,        // 电压电流转换配置，不支持仿真。
    parameter integer PMA_PLL1_REG_IBUP_A1         = 262143,   // 电压电流转换配置，不支持仿真。
    parameter integer PMA_PLL1_REG_IBUP_A2         = 3072,     // 电压电流转换配置，不支持仿真。
    parameter integer PMA_PLL1_REG_IBUP_PD         = 0,        // 电压电流转换配置，不支持仿真。
    parameter         PMA_PLL1_REG_V2I_BIAS_SEL    = "FALSE",  // 电压电流转换配置，不支持仿真。
    parameter         PMA_PLL1_REG_V2I_EN          = "TRUE",   // 电压电流转换配置，不支持仿真。
    parameter integer PMA_PLL1_REG_V2I_TB_SEL      = 0,        // 电压电流转换配置，不支持仿真。
    parameter         PMA_PLL1_REG_V2I_RCALTEST_PD = "FALSE",  // 电压电流转换配置，不支持仿真。
    parameter integer PMA_PLL1_REG_RES_CAL_TEST    = 0,        // 电压电流转换配置，不支持仿真。
    parameter integer PMA_PLL1_RES_CAL_DIV         = 0,        // 电压电流转换配置，不支持仿真。
    parameter         PMA_PLL1_RES_CAL_CLK_SEL     = "FALSE",  // 电压电流转换配置，不支持仿真。

    parameter PMA_PLL1_REG_PLL_PFDDELAY_EN = "TRUE",  // 使能选项：开启或关闭。
    parameter integer PMA_PLL1_REG_PFDDELAYSEL = 1,
    parameter integer PMA_PLL1_REG_PLL_VCTRL_SET = 0,
    parameter PMA_PLL1_REG_READY_OR_LOCK = "FALSE",  // 使能选项：开启或关闭。
    parameter integer PMA_PLL1_REG_PLL_CP = 31,  // 电流配置范围：1～1023，默认 31。
    parameter integer PMA_PLL1_REG_PLL_REFDIV = 16,  // PLL 参考时钟分频 M，默认 16。
    parameter PMA_PLL1_REG_PLL_LOCKDET_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_PLL1_REG_PLL_READY = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_PLL1_REG_PLL_READY_OW = "FALSE",  // 使能选项：开启或关闭。
    parameter    integer    PMA_PLL1_REG_PLL_FBDIV = 36                       ,// PLL 反馈分频 N2 由 Pll_fbdiv[5] 决定：1 对应 5，0 对应 4。
                                                                               // PLL 反馈分频 N1 可取 1、2、3、4、5、6、8、10。
    parameter integer PMA_PLL1_REG_LPF_RES = 1,  // 低通滤波电阻控制，默认 1。
    parameter PMA_PLL1_REG_JTAG_OE = "FALSE",  // PLL JTAG 输出使能
    parameter integer PMA_PLL1_REG_JTAG_VHYSTSEL = 0,  // PLL JTAG 门限电压选择，默认 0。
    parameter PMA_PLL1_REG_PLL_LOCKDET_EN_OW = "FALSE",  // 使能选项：开启或关闭。
    parameter    integer    PMA_PLL1_REG_PLL_LOCKDET_FBCT = 7                 ,// 计数编码 0～7 分别对应 2^9～2^15、2^16−1，默认编码 7。
    parameter    integer    PMA_PLL1_REG_PLL_LOCKDET_ITER = 3                 ,// 编码 0～7 对应 1、2、4、8、16、32、64、127，默认编码 3。
    parameter PMA_PLL1_REG_PLL_LOCKDET_MODE = "FALSE",  // 使能选项：开启或关闭。
    parameter    integer    PMA_PLL1_REG_PLL_LOCKDET_LOCKCT = 4               ,// 编码 0～7 对应 2、4、8、16、32、64、128、256，默认编码 4。
    parameter    integer    PMA_PLL1_REG_PLL_LOCKDET_REFCT = 7                ,// 计数编码 0～7 分别对应 2^9～2^15、2^16−1，默认编码 7。
    parameter PMA_PLL1_REG_PLL_LOCKDET_RESET_N = "TRUE",  // 使能选项：开启或关闭。
    parameter PMA_PLL1_REG_PLL_LOCKDET_RESET_N_OW = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_PLL1_REG_PLL_LOCKED = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_PLL1_REG_PLL_LOCKED_OW = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_PLL1_REG_PLL_LOCKED_STICKY_CLEAR = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_PLL1_REG_PLL_UNLOCKED = "FALSE",  // 使能选项：开启或关闭。
    parameter    integer    PMA_PLL1_REG_PLL_UNLOCKDET_ITER = 2               ,// 编码 00、01、10、11 对应 63、127、255、1023，默认编码 10。
    parameter PMA_PLL1_REG_PLL_UNLOCKED_OW = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_PLL1_REG_PLL_UNLOCKED_STICKY_CLEAR = "FALSE",  // 使能选项：开启或关闭。
    parameter integer PMA_PLL1_REG_I_CTRL_MAX = 63,  // 取值范围：0～63，默认全 1。
    parameter PMA_PLL1_REG_REFCLK_TEST_EN = "FALSE",  // 参考时钟端口测试使能
    parameter PMA_PLL1_REG_RESCAL_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter integer PMA_PLL1_REG_I_CTRL_MIN = 0,  // 取值范围：0～63。
    parameter PMA_PLL1_REG_RESCAL_DONE_OW = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_PLL1_REG_RESCAL_DONE_VAL = "FALSE",  // 使能选项：开启或关闭。
    parameter integer PMA_PLL1_REG_RESCAL_I_CODE = 46,  // 取值范围：0～63。
    parameter PMA_PLL1_REG_RESCAL_I_CODE_OW = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_PLL1_REG_RESCAL_I_CODE_PMA = "FALSE",  // 使能选项：开启或关闭。
    parameter integer PMA_PLL1_REG_RESCAL_I_CODE_VAL = 46,  // 取值范围：0～63。
    parameter PMA_PLL1_REG_RESCAL_INT_R_SMALL_OW = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_PLL1_REG_RESCAL_INT_R_SMALL_VAL = "FALSE",  // 使能选项：开启或关闭。
    parameter integer PMA_PLL1_REG_RESCAL_ITER_VALID_SEL = 0,  //0,1,2,3
    parameter PMA_PLL1_REG_RESCAL_RESET_N_OW = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_PLL1_REG_RESCAL_RST_N_VAL = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_PLL1_REG_RESCAL_WAIT_SEL = "TRUE",  // 使能选项：开启或关闭。
    parameter PMA_PLL1_REFCLK2LANE_PD_L = "FALSE",  // 左侧 PLL 参考时钟掉电控制
    parameter PMA_PLL1_REFCLK2LANE_PD_R = "FALSE",  // 右侧 PLL 参考时钟掉电控制
    parameter PMA_PLL1_REG_LOCKDET_REPEAT = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_PLL1_REG_NOFBCLK_STICKY_CLEAR = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_PLL1_REG_NOREFCLK_STICKY_CLEAR = "FALSE",  // 使能选项：开启或关闭。
    parameter integer PMA_PLL1_REG_TEST_SEL = 15,  // 测试取值范围：0～20。
    parameter PMA_PLL1_REG_TEST_V_EN = "FALSE",  // 测试使能
    parameter PMA_PLL1_REG_TEST_SIG_HALF_EN = "FALSE",  // 测试使能
    parameter PMA_PLL1_REG_REFCLK_PAD_SEL = "FALSE",  // 参考时钟选择
    parameter PMA_PLL1_PARM_PLL_POWERUP = "OFF",  // 使能选项：开启或关闭。
    // 通道 0 参数
    parameter integer CH0_MUX_BIAS = 2,  // 取值范围：0～7，不支持仿真。
    parameter integer CH0_PD_CLK = 0,  // 取值范围：0～1。
    parameter integer CH0_REG_SYNC = 0,  // 取值范围：0～1。
    parameter integer CH0_REG_SYNC_OW = 0,  // 取值范围：0～1。
    parameter integer CH0_PLL_LOCK_OW = 0,  // 取值范围：0～1。
    parameter integer CH0_PLL_LOCK_OW_EN = 0,  // 取值范围：0～1。

    parameter integer PCS_CH0_SLAVE = 0,  // 时钟配置由用户指定，软件仅检查对应的时钟连线。
    parameter PCS_CH0_BYPASS_WORD_ALIGN = "FALSE",  // 字对齐旁路使能
    parameter PCS_CH0_BYPASS_DENC = "FALSE",  // 8b/10b 解码旁路使能
    parameter PCS_CH0_BYPASS_BONDING = "FALSE",  // 通道绑定旁路使能
    parameter PCS_CH0_BYPASS_CTC = "FALSE",  // 时钟补偿旁路使能
    parameter PCS_CH0_BYPASS_GEAR = "FALSE",  // 接收齿轮箱旁路使能
    parameter PCS_CH0_BYPASS_BRIDGE = "FALSE",  // 接收桥接单元旁路使能
    parameter PCS_CH0_BYPASS_BRIDGE_FIFO = "FALSE",  // 接收桥接 FIFO 旁路使能
    parameter PCS_CH0_DATA_MODE = "X8",  // 参数选项："X8","X10","X16","X20"
    parameter               PCS_CH0_RX_POLARITY_INV = "DELAY"                     ,// 数据变换：延迟、位极性反转、位序反转或两者同时反转。
    parameter PCS_CH0_ALIGN_MODE = "1GB",  // 协议模式：1GB、10GB、RAPIDIO 或外部模式。
    parameter PCS_CH0_SAMP_16B = "X20",  // 参数选项："X20",X16
    parameter PCS_CH0_FARLP_PWR_REDUCTION = "FALSE",  // 使能选项：开启或关闭。
    parameter integer PCS_CH0_COMMA_REG0 = 0,  // 取值范围：0～1023。
    parameter integer PCS_CH0_COMMA_MASK = 0,  // 取值范围：0～1023。
    parameter PCS_CH0_CEB_MODE = "10GB",  // 协议模式：10GB、RAPIDIO 或外部模式。
    parameter PCS_CH0_CTC_MODE = "1SKIP",  // 跳过字符模式：单字符、双字符、PCIe 双字节或四字符。
    parameter integer PCS_CH0_A_REG = 0,  // 取值范围：0～255。
    parameter PCS_CH0_GE_AUTO_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter integer PCS_CH0_SKIP_REG0 = 0,  // 取值范围：0～1023。
    parameter integer PCS_CH0_SKIP_REG1 = 0,  // 取值范围：0～1023。
    parameter integer PCS_CH0_SKIP_REG2 = 0,  // 取值范围：0～1023。
    parameter integer PCS_CH0_SKIP_REG3 = 0,  // 取值范围：0～1023。
    parameter PCS_CH0_DEC_DUAL = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH0_SPLIT = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH0_FIFOFLAG_CTC = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH0_COMMA_DET_MODE = "COMMA_PATTERN",  // 参数选项："RX_CLK_SLIP" "COMMA_PATTERN"
    parameter PCS_CH0_ERRDETECT_SILENCE = "TRUE",  // 使能选项：开启或关闭。
    parameter PCS_CH0_PMA_RCLK_POLINV = "PMA_RCLK",  // 参数选项："PMA_RCLK" "REVERSE_OF_PMA_RCLK"
    parameter PCS_CH0_PCS_RCLK_SEL = "PMA_RCLK",  // 参数选项："PMA_RCLK" "PMA_TCLK" "RCLK"
    parameter PCS_CH0_CB_RCLK_SEL = "PMA_RCLK",  // 参数选项："PMA_RCLK" "PMA_TCLK" "MCB_RCLK"
    parameter PCS_CH0_AFTER_CTC_RCLK_SEL = "PMA_RCLK",  // 参数选项："PMA_RCLK" "PMA_TCLK" "MCB_RCLK" "RCLK2"
    parameter PCS_CH0_RCLK_POLINV = "RCLK",  // 参数选项："RCLK" "REVERSE_OF_RCLK"
    parameter PCS_CH0_BRIDGE_RCLK_SEL = "PMA_RCLK",  // 参数选项："PMA_RCLK" "PMA_TCLK" "MCB_RCLK" "RCLK"
    parameter PCS_CH0_PCS_RCLK_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH0_CB_RCLK_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH0_AFTER_CTC_RCLK_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH0_AFTER_CTC_RCLK_EN_GB = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH0_PCS_RX_RSTN = "TRUE",  // PCS 接收端复位控制
    parameter PCS_CH0_PCIE_SLAVE = "MASTER",  // 通道角色：主通道或从通道。
    parameter PCS_CH0_RX_64B66B_67B = "NORMAL",  // 编码模式：普通、64b/66b 或 64b/67b。
    parameter               PCS_CH0_RX_BRIDGE_CLK_POLINV = "RX_BRIDGE_CLK"        ,// 参数选项："RX_BRIDGE_CLK" "REVERSE_OF_RX_BRIDGE_CLK"
    parameter PCS_CH0_PCS_CB_RSTN = "TRUE",  // PCS 通道绑定复位控制
    parameter               PCS_CH0_TX_BRIDGE_GEAR_SEL = "FALSE"                  ,// TRUE 优先使用发送齿轮箱，FALSE 优先使用发送桥接单元。
    parameter PCS_CH0_TX_BYPASS_BRIDGE_UINT = "FALSE",  // 旁路使能
    parameter PCS_CH0_TX_BYPASS_BRIDGE_FIFO = "FALSE",  // 发送桥接 FIFO 旁路使能
    parameter PCS_CH0_TX_BYPASS_GEAR = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH0_TX_BYPASS_ENC = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH0_TX_BYPASS_BIT_SLIP = "TRUE",  // 使能选项：开启或关闭。
    parameter PCS_CH0_TX_GEAR_SPLIT = "TRUE",  // 使能选项：开启或关闭。
    parameter               PCS_CH0_TX_DRIVE_REG_MODE = "NO_CHANGE"               ,// 变换选项：不变、极性反转、位序反转或两者同时反转。
    parameter integer PCS_CH0_TX_BIT_SLIP_CYCLES = 0,  // 取值范围：0～31。
    parameter PCS_CH0_INT_TX_MASK_0 = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH0_INT_TX_MASK_1 = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH0_INT_TX_MASK_2 = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH0_INT_TX_CLR_0 = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH0_INT_TX_CLR_1 = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH0_INT_TX_CLR_2 = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH0_TX_PMA_TCLK_POLINV = "PMA_TCLK",  // 参数选项："PMA_TCLK" "REVERSE_OF_PMA_TCLK"
    parameter PCS_CH0_TX_PCS_CLK_EN_SEL = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH0_TX_BRIDGE_TCLK_SEL = "TCLK",  // 参数选项："PCS_TCLK" "TCLK"
    parameter PCS_CH0_TX_TCLK_POLINV = "TCLK",  // 参数选项："TCLK" "REVERSE_OF_TCLK"
    parameter PCS_CH0_PCS_TCLK_SEL = "PMA_TCLK",  // 参数选项："PMA_TCLK" "TCLK"
    parameter PCS_CH0_TX_PCS_TX_RSTN = "TRUE",  // PCS 发送端复位控制
    parameter PCS_CH0_TX_SLAVE = "MASTER",  // 通道角色：主通道或从通道。
    parameter PCS_CH0_TX_GEAR_CLK_EN_SEL = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH0_DATA_WIDTH_MODE = "X20",  // 参数选项："X8" "X10" "X16" "X20"
    parameter PCS_CH0_TX_64B66B_67B = "NORMAL",  // 编码模式：普通、64b/66b 或 64b/67b。
    parameter PCS_CH0_GEAR_TCLK_SEL = "PMA_TCLK",  // 参数选项："PMA_TCLK" "TCLK2"
    parameter PCS_CH0_TX_TCLK2FABRIC_SEL = "TRUE",  // 使能选项：开启或关闭。
    parameter PCS_CH0_TX_OUTZZ = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH0_ENC_DUAL = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH0_TX_BITSLIP_DATA_MODE = "X10",  // 参数选项："X10" "X20"
    parameter               PCS_CH0_TX_BRIDGE_CLK_POLINV = "TX_BRIDGE_CLK"        ,// 参数选项："TX_BRIDGE_CLK" "REVERSE_OF_TX_BRIDGE_CLK"
    parameter integer PCS_CH0_COMMA_REG1 = 0,  // 取值范围：0～1023。
    parameter integer PCS_CH0_RAPID_IMAX = 0,  // 取值范围：0～7。
    parameter integer PCS_CH0_RAPID_VMIN_1 = 0,  // 取值范围：0～255。
    parameter integer PCS_CH0_RAPID_VMIN_2 = 0,  // 取值范围：0～255。
    parameter PCS_CH0_RX_PRBS_MODE = "DISABLE",  // PRBS 配置：关闭或选择 7、15、23、31 阶多项式。
    parameter PCS_CH0_RX_ERRCNT_CLR = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH0_PRBS_ERR_LPBK = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH0_TX_PRBS_MODE = "DISABLE",  // 测试码型：PRBS、长 1、长 0、20 UI、D10.2 或 PCIe。
    parameter PCS_CH0_TX_INSERT_ER = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH0_ENABLE_PRBS_GEN = "FALSE",  // 使能选项：开启或关闭。
    parameter integer PCS_CH0_DEFAULT_RADDR = 6,  // 取值范围：0～15。
    parameter integer PCS_CH0_MASTER_CHECK_OFFSET = 0,  // 取值范围：0～15。
    parameter integer PCS_CH0_DELAY_SET = 0,  // 取值范围：0～15。
    parameter PCS_CH0_SEACH_OFFSET = "20BIT",  // 绑定位宽：20～80 位，间隔 10 位。
    parameter integer PCS_CH0_CEB_RAPIDLS_MMAX = 0,  // 取值范围：0～7。
    parameter integer PCS_CH0_CTC_AFULL = 20,  // 取值范围：0～31。
    parameter integer PCS_CH0_CTC_AEMPTY = 12,  // 取值范围：0～31。
    parameter integer PCS_CH0_CTC_CONTI_SKP_SET = 0,  // 取值范围：0～1。
    parameter PCS_CH0_FAR_LOOP = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH0_NEAR_LOOP = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH0_PMA_TX2RX_PLOOP_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH0_PMA_TX2RX_SLOOP_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH0_PMA_RX2TX_PLOOP_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH0_INT_RX_MASK_0 = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH0_INT_RX_MASK_1 = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH0_INT_RX_MASK_2 = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH0_INT_RX_MASK_3 = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH0_INT_RX_MASK_4 = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH0_INT_RX_MASK_5 = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH0_INT_RX_MASK_6 = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH0_INT_RX_MASK_7 = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH0_INT_RX_CLR_0 = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH0_INT_RX_CLR_1 = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH0_INT_RX_CLR_2 = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH0_INT_RX_CLR_3 = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH0_INT_RX_CLR_4 = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH0_INT_RX_CLR_5 = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH0_INT_RX_CLR_6 = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH0_INT_RX_CLR_7 = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH0_CA_RSTN_RX = "FALSE",  // 接收时钟对齐器复位控制
    parameter PCS_CH0_CA_DYN_DLY_EN_RX = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH0_CA_DYN_DLY_SEL_RX = "FALSE",  // 使能选项：开启或关闭。
    parameter integer PCS_CH0_CA_RX = 0,  // 取值范围：0～255。
    parameter PCS_CH0_CA_RSTN_TX = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH0_CA_DYN_DLY_EN_TX = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH0_CA_DYN_DLY_SEL_TX = "FALSE",  // 使能选项：开启或关闭。
    parameter integer PCS_CH0_CA_TX = 0,  // 取值范围：0～255。
    parameter PCS_CH0_RXPRBS_PWR_REDUCTION = "NORMAL",  // 工作模式：普通或低功耗。
    parameter PCS_CH0_WDALIGN_PWR_REDUCTION = "NORMAL",  // 工作模式：普通或低功耗。
    parameter PCS_CH0_RXDEC_PWR_REDUCTION = "NORMAL",  // 工作模式：普通或低功耗。
    parameter PCS_CH0_RXCB_PWR_REDUCTION = "NORMAL",  // 工作模式：普通或低功耗。
    parameter PCS_CH0_RXCTC_PWR_REDUCTION = "NORMAL",  // 工作模式：普通或低功耗。
    parameter PCS_CH0_RXGEAR_PWR_REDUCTION = "NORMAL",  // 工作模式：普通或低功耗。
    parameter PCS_CH0_RXBRG_PWR_REDUCTION = "NORMAL",  // 工作模式：普通或低功耗。
    parameter PCS_CH0_RXTEST_PWR_REDUCTION = "NORMAL",  // 工作模式：普通或低功耗。
    parameter PCS_CH0_TXBRG_PWR_REDUCTION = "NORMAL",  // 工作模式：普通或低功耗。
    parameter PCS_CH0_TXGEAR_PWR_REDUCTION = "NORMAL",  // 工作模式：普通或低功耗。
    parameter PCS_CH0_TXENC_PWR_REDUCTION = "NORMAL",  // 工作模式：普通或低功耗。
    parameter PCS_CH0_TXBSLP_PWR_REDUCTION = "NORMAL",  // 工作模式：普通或低功耗。
    parameter PCS_CH0_TXPRBS_PWR_REDUCTION = "NORMAL",  // 工作模式：普通或低功耗。

    parameter PMA_CH0_REG_RX_PD = "ON",  // 使能选项：开启或关闭。
    parameter PMA_CH0_REG_RX_PD_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH0_REG_RX_RESERVED_2 = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH0_REG_RX_RESERVED_3 = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH0_REG_RX_DATAPATH_PD = "ON",  // 使能选项：开启或关闭。
    parameter PMA_CH0_REG_RX_DATAPATH_PD_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH0_REG_RX_SIGDET_PD = "ON",  // 使能选项：开启或关闭。
    parameter PMA_CH0_REG_RX_SIGDET_PD_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH0_REG_RX_DCC_RST_N = "TRUE",  // 使能选项：开启或关闭。
    parameter PMA_CH0_REG_RX_DCC_RST_N_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH0_REG_RX_CDR_RST_N = "TRUE",  // 使能选项：开启或关闭。
    parameter PMA_CH0_REG_RX_CDR_RST_N_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH0_REG_RX_SIGDET_RST_N = "TRUE",  // 使能选项：开启或关闭。
    parameter PMA_CH0_REG_RX_SIGDET_RST_N_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH0_REG_RXPCLK_SLIP = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH0_REG_RXPCLK_SLIP_OW = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH0_REG_RX_PCLKSWITCH_RST_N = "TRUE",  // 发送 PMA 复位控制
    parameter PMA_CH0_REG_RX_PCLKSWITCH_RST_N_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH0_REG_RX_PCLKSWITCH = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH0_REG_RX_PCLKSWITCH_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH0_REG_RX_HIGHZ = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH0_REG_RX_HIGHZ_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH0_REG_RX_SIGDET_CLK_WINDOW = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH0_REG_RX_SIGDET_CLK_WINDOW_OW = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH0_REG_RX_PD_BIAS_RX = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH0_REG_RX_PD_BIAS_RX_OW = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH0_REG_RX_RESET_N = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH0_REG_RX_RESET_N_OW = "FALSE",  // 使能选项：开启或关闭。
    parameter integer PMA_CH0_REG_RX_RESERVED_29_28 = 0,  // 取值范围：0～3。
    parameter PMA_CH0_REG_RX_BUSWIDTH = "20BIT",  // 位宽选项：8、10、16 或 20 位。
    parameter PMA_CH0_REG_RX_BUSWIDTH_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH0_REG_RX_RATE = "DIV1",  // 时钟倍率：四分频、二分频、原频或二倍频。
    parameter PMA_CH0_REG_RX_RESERVED_36 = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH0_REG_RX_RATE_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter integer PMA_CH0_REG_RX_RES_TRIM = 46,  // 取值范围：0～63。
    parameter PMA_CH0_REG_RX_RESERVED_44 = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH0_REG_RX_RESERVED_45 = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH0_REG_RX_SIGDET_STATUS_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter integer PMA_CH0_REG_RX_RESERVED_48_47 = 0,  // 取值范围：0～3。
    parameter integer PMA_CH0_REG_RX_ICTRL_SIGDET = 5,  // 取值范围：0～15。
    parameter integer PMA_CH0_REG_CDR_READY_THD = 2734,  // 取值范围：0～4095。
    parameter PMA_CH0_REG_RX_RESERVED_65 = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH0_REG_RX_PCLK_EDGE_SEL = "POS_EDGE",  // 时钟边沿：上升沿或下降沿。
    parameter integer PMA_CH0_REG_RX_PIBUF_IC = 1,  // 取值范围：0～3。
    parameter PMA_CH0_REG_RX_RESERVED_69 = "FALSE",  // 使能选项：开启或关闭。
    parameter integer PMA_CH0_REG_RX_DCC_IC_RX = 1,  // 取值范围：0～3。
    parameter integer PMA_CH0_REG_CDR_READY_CHECK_CTRL = 0,  // 取值范围：0～3。
    parameter PMA_CH0_REG_RX_ICTRL_TRX = "100PCT",  // 比例选项：87.5%、100%、112.5%、125%。
    parameter integer PMA_CH0_REG_RX_RESERVED_77_76 = 0,  // 取值范围：0～3。
    parameter integer PMA_CH0_REG_RX_RESERVED_79_78 = 1,  // 取值范围：0～3。
    parameter integer PMA_CH0_REG_RX_RESERVED_81_80 = 1,  // 取值范围：0～3。
    parameter PMA_CH0_REG_RX_ICTRL_PIBUF = "100PCT",  // 比例选项：87.5%、100%、112.5%、125%。
    parameter PMA_CH0_REG_RX_ICTRL_PI = "100PCT",  // 比例选项：87.5%、100%、112.5%、125%。
    parameter PMA_CH0_REG_RX_ICTRL_DCC = "100PCT",  // 比例选项：87.5%、100%、112.5%、125%。
    parameter integer PMA_CH0_REG_RX_RESERVED_89_88 = 1,  // 取值范围：0～3。
    parameter PMA_CH0_REG_TX_RATE = "DIV1",  // 时钟倍率：四分频、二分频、原频或二倍频。
    parameter PMA_CH0_REG_RX_RESERVED_92 = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH0_REG_TX_RATE_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH0_REG_RX_TX2RX_PLPBK_RST_N = "TRUE",  // PMA 发送到接收并行环回复位控制
    parameter PMA_CH0_REG_RX_TX2RX_PLPBK_RST_N_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH0_REG_RX_TX2RX_PLPBK_EN = "FALSE",  // PMA 发送到接收并行环回使能
    parameter PMA_CH0_REG_TXCLK_SEL = "PLL",  // 时钟来源：PLL 或接收时钟。
    parameter PMA_CH0_REG_RX_DATA_POLARITY = "NORMAL",  // 极性选项：正常或反转。
    parameter PMA_CH0_REG_RX_ERR_INSERT = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH0_REG_UDP_CHK_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH0_REG_PRBS_SEL = "PRBS7",  // PRBS 多项式阶数：7、15、23、31。
    parameter PMA_CH0_REG_PRBS_CHK_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH0_REG_PRBS_CHK_WIDTH_SEL = "20BIT",  // 位宽选项：8、10、16 或 20 位。
    parameter PMA_CH0_REG_BIST_CHK_PAT_SEL = "PRBS",  // 码型来源：PRBS 或常量。
    parameter PMA_CH0_REG_LOAD_ERR_CNT = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH0_REG_CHK_COUNTER_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter integer PMA_CH0_REG_CDR_PROP_GAIN = 7,  // 取值范围：0～7。
    parameter integer PMA_CH0_REG_CDR_PROP_TURBO_GAIN = 5,  // 取值范围：0～7。
    parameter integer PMA_CH0_REG_CDR_INT_GAIN = 4,  // 取值范围：0～7。
    parameter integer PMA_CH0_REG_CDR_INT_TURBO_GAIN = 5,  // 取值范围：0～7。
    parameter integer PMA_CH0_REG_CDR_INT_SAT_MAX = 768,  // 取值范围：0～1023。
    parameter integer PMA_CH0_REG_CDR_INT_SAT_MIN = 255,  // 取值范围：0～1023。
    parameter PMA_CH0_REG_CDR_INT_RST = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH0_REG_CDR_INT_RST_OW = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH0_REG_CDR_PROP_RST = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH0_REG_CDR_PROP_RST_OW = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH0_REG_CDR_LOCK_RST = "FALSE",  // CDR 锁定计数器复位控制
    parameter PMA_CH0_REG_CDR_LOCK_RST_OW = "FALSE",  // 使能选项：开启或关闭。
    parameter integer PMA_CH0_REG_CDR_RX_PI_FORCE_SEL = 0,  //0,1
    parameter integer PMA_CH0_REG_CDR_RX_PI_FORCE_D = 0,  // 取值范围：0～255。
    parameter               PMA_CH0_REG_CDR_LOCK_TIMER = "1_2U"                   ,// 参数选项："0_8U" "1_2U" "1_6U" "2_4U" 3_2U" "4_8U" "12_8U" "25_6U"
    parameter integer PMA_CH0_REG_CDR_TURBO_MODE_TIMER = 1,  // 取值范围：0～3。
    parameter PMA_CH0_REG_CDR_LOCK_VAL = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH0_REG_CDR_LOCK_OW = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH0_REG_CDR_INT_SAT_DET_EN = "TRUE",  // 使能选项：开启或关闭。
    parameter PMA_CH0_REG_CDR_SAT_AUTO_DIS = "TRUE",  // 使能选项：开启或关闭。
    parameter PMA_CH0_REG_CDR_GAIN_AUTO = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH0_REG_CDR_TURBO_GAIN_AUTO = "FALSE",  // 使能选项：开启或关闭。
    parameter integer PMA_CH0_REG_RX_RESERVED_171_167 = 0,  // 取值范围：0～31。
    parameter integer PMA_CH0_REG_RX_RESERVED_175_172 = 0,  // 取值范围：0～31。
    parameter PMA_CH0_REG_CDR_SAT_DET_STATUS_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH0_REG_CDR_SAT_DET_STATUS_RESET_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH0_REG_CDR_PI_CTRL_RST = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH0_REG_CDR_PI_CTRL_RST_OW = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH0_REG_CDR_SAT_DET_RST = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH0_REG_CDR_SAT_DET_RST_OW = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH0_REG_CDR_SAT_DET_STICKY_RST = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH0_REG_CDR_SAT_DET_STICKY_RST_OW = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH0_REG_CDR_SIGDET_STATUS_DIS = "FALSE",  // 无信号检测状态时复位 CDR。
    parameter integer PMA_CH0_REG_CDR_SAT_DET_TIMER = 2,  // 取值范围：0～3。
    parameter PMA_CH0_REG_CDR_SAT_DET_STATUS_VAL = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH0_REG_CDR_SAT_DET_STATUS_OW = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH0_REG_CDR_TURBO_MODE_EN = "TRUE",  // 使能选项：开启或关闭。
    parameter PMA_CH0_REG_RX_RESERVED_190 = "FALSE",  // 使能选项：开启或关闭。
    parameter integer PMA_CH0_REG_RX_RESERVED_193_191 = 0,  // 取值范围：0～7。
    parameter PMA_CH0_REG_CDR_STATUS_FIFO_EN = "TRUE",  // 使能选项：开启或关闭。
    parameter integer PMA_CH0_REG_PMA_TEST_SEL = 0,  //0,1
    parameter integer PMA_CH0_REG_OOB_COMWAKE_GAP_MIN = 3,  // 取值范围：0～63。
    parameter integer PMA_CH0_REG_OOB_COMWAKE_GAP_MAX = 11,  // 取值范围：0～63。
    parameter integer PMA_CH0_REG_OOB_COMINIT_GAP_MIN = 15,  // 取值范围：0～255。
    parameter integer PMA_CH0_REG_OOB_COMINIT_GAP_MAX = 35,  // 取值范围：0～255。
    parameter integer PMA_CH0_REG_RX_RESERVED_227_226 = 1,  // 取值范围：0～3。
    parameter integer PMA_CH0_REG_COMWAKE_STATUS_CLEAR = 0,  //0,1
    parameter integer PMA_CH0_REG_COMINIT_STATUS_CLEAR = 0,  //0,1
    parameter PMA_CH0_REG_RX_SYNC_RST_N_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH0_REG_RX_SYNC_RST_N = "TRUE",  // 使能选项：开启或关闭。
    parameter integer PMA_CH0_REG_RX_RESERVED_233_232 = 0,  // 取值范围：0～3。
    parameter integer PMA_CH0_REG_RX_RESERVED_235_234 = 0,  // 取值范围：0～3。
    parameter PMA_CH0_REG_RX_SATA_COMINIT_OW = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH0_REG_RX_SATA_COMINIT = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH0_REG_RX_SATA_COMWAKE_OW = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH0_REG_RX_SATA_COMWAKE = "FALSE",  // 使能选项：开启或关闭。
    parameter integer PMA_CH0_REG_RX_RESERVED_241_240 = 0,  // 取值范围：0～3。
    parameter PMA_CH0_REG_RX_DCC_DISABLE = "FALSE",  // 接收占空比校正禁用控制
    parameter PMA_CH0_REG_RX_RESERVED_243 = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH0_REG_RX_SLIP_SEL_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter integer PMA_CH0_REG_RX_SLIP_SEL = 0,  // 取值范围：0～15。
    parameter PMA_CH0_REG_RX_SLIP_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter integer PMA_CH0_REG_RX_SIGDET_STATUS_SEL = 5,  // 取值范围：0～7。
    parameter PMA_CH0_REG_RX_SIGDET_FSM_RST_N = "TRUE",  // 使能选项：开启或关闭。
    parameter PMA_CH0_REG_RX_RESERVED_254 = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH0_REG_RX_SIGDET_STATUS = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH0_REG_RX_SIGDET_VTH = "72MV",  // 检测电压：45、54、63、72 mV。
    parameter integer PMA_CH0_REG_RX_SIGDET_GRM = 0,  //0,1,2,3
    parameter PMA_CH0_REG_RX_SIGDET_PULSE_EXT = "FALSE",  // 使能选项：开启或关闭。
    parameter integer PMA_CH0_REG_RX_SIGDET_CH2_SEL = 0,  //0,1
    parameter integer PMA_CH0_REG_RX_SIGDET_CH2_CHK_WINDOW = 3,  // 取值范围：0～31。
    parameter PMA_CH0_REG_RX_SIGDET_CHK_WINDOW_EN = "TRUE",  // 使能选项：开启或关闭。
    parameter integer PMA_CH0_REG_RX_SIGDET_NOSIG_COUNT_SETTING = 4,  // 取值范围：0～7。
    parameter PMA_CH0_REG_SLIP_FIFO_INV_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH0_REG_SLIP_FIFO_INV = "POS_EDGE",  // 时钟边沿：上升沿或下降沿。
    parameter integer PMA_CH0_REG_RX_SIGDET_OOB_DET_COUNT_VAL = 0,  // 取值范围：0～31。
    parameter integer PMA_CH0_REG_RX_SIGDET_4OOB_DET_SEL = 7,  // 取值范围：0～7。
    parameter integer PMA_CH0_REG_RX_RESERVED_285_283 = 0,  // 取值范围：0～7。
    parameter PMA_CH0_REG_RX_RESERVED_286 = "FALSE",  // 使能选项：开启或关闭。
    parameter integer PMA_CH0_REG_RX_SIGDET_IC_I = 10,  // 取值范围：0～15。
    parameter PMA_CH0_REG_RX_OOB_DETECTOR_RESET_N_OW = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH0_REG_RX_OOB_DETECTOR_RESET_N = "FALSE",  // 接收带外检测器复位控制
    parameter PMA_CH0_REG_RX_OOB_DETECTOR_PD_OW = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH0_REG_RX_OOB_DETECTOR_PD = "ON",  // 接收带外检测器掉电控制
    parameter PMA_CH0_REG_RX_LS_MODE_EN = "FALSE",  // 低速模式使能
    parameter PMA_CH0_REG_ANA_RX_EQ1_R_SET_FB_O_SEL = "TRUE",  // 使能选项：开启或关闭。
    parameter PMA_CH0_REG_ANA_RX_EQ2_R_SET_FB_O_SEL = "TRUE",  // 使能选项：开启或关闭。
    parameter integer PMA_CH0_REG_RX_EQ1_R_SET_TOP = 0,  // 取值范围：0～3。
    parameter integer PMA_CH0_REG_RX_EQ1_R_SET_FB = 15,  // 取值范围：0～15。
    parameter integer PMA_CH0_REG_RX_EQ1_C_SET_FB = 0,  // 取值范围：0～15。
    parameter PMA_CH0_REG_RX_EQ1_OFF = "FALSE",  // 使能选项：开启或关闭。
    parameter integer PMA_CH0_REG_RX_EQ2_R_SET_TOP = 0,  // 取值范围：0～3。
    parameter integer PMA_CH0_REG_RX_EQ2_R_SET_FB = 0,  // 取值范围：0～15。
    parameter integer PMA_CH0_REG_RX_EQ2_C_SET_FB = 0,  // 取值范围：0～15。
    parameter PMA_CH0_REG_RX_EQ2_OFF = "FALSE",  // 使能选项：开启或关闭。
    parameter integer PMA_CH0_REG_EQ_DAC = 0,  // 取值范围：0～63。
    parameter integer PMA_CH0_REG_RX_ICTRL_EQ = 2,  // 使能选项：开启或关闭。
    parameter PMA_CH0_REG_EQ_DC_CALIB_EN = "TRUE",  // 使能选项：开启或关闭。
    parameter PMA_CH0_REG_EQ_DC_CALIB_SEL = "FALSE",  // 使能选项：开启或关闭。
    parameter integer PMA_CH0_REG_RX_RESERVED_337_330 = 0,  // 取值范围：0～255。
    parameter integer PMA_CH0_REG_RX_RESERVED_345_338 = 0,  // 取值范围：0～255。
    parameter integer PMA_CH0_REG_RX_RESERVED_353_346 = 0,  // 取值范围：0～255。
    parameter integer PMA_CH0_REG_RX_RESERVED_361_354 = 0,  // 取值范围：0～255。
    parameter integer PMA_CH0_CTLE_CTRL_REG_I = 0,  // 取值范围：0～15。
    parameter PMA_CH0_CTLE_REG_FORCE_SEL_I = "FALSE",  // 自适应调整控制
    parameter PMA_CH0_CTLE_REG_HOLD_I = "FALSE",  // 使能选项：开启或关闭。
    parameter integer PMA_CH0_CTLE_REG_INIT_DAC_I = 0,  // 取值范围：0～15。
    parameter PMA_CH0_CTLE_REG_POLARITY_I = "FALSE",  // 使能选项：开启或关闭。
    parameter integer PMA_CH0_CTLE_REG_SHIFTER_GAIN_I = 1,  // 取值范围：0～7。
    parameter integer PMA_CH0_CTLE_REG_THRESHOLD_I = 3072,  // 取值范围：0～4095。
    parameter PMA_CH0_REG_RX_RES_TRIM_EN = "TRUE",  // 使能选项：开启或关闭。
    parameter integer PMA_CH0_REG_RX_RESERVED_393_389 = 0,  // 取值范围：0～31。
    parameter PMA_CH0_CFG_RX_LANE_POWERUP = "ON",  // 接收通道上电控制
    parameter PMA_CH0_CFG_RX_PMA_RSTN = "TRUE",  // 接收 PMA 复位控制
    parameter PMA_CH0_INT_PMA_RX_MASK_0 = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH0_INT_PMA_RX_CLR_0 = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH0_CFG_CTLE_ADP_RSTN = "TRUE",  // 控制逻辑复位

    parameter         PMA_CH0_REG_TX_PD                       = "ON",      // 发送端掉电控制
    parameter         PMA_CH0_REG_TX_PD_OW                    = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH0_REG_TX_MAIN_PRE_Z               = "FALSE",   // PCIe 模式电气空闲使能
    parameter         PMA_CH0_REG_TX_MAIN_PRE_Z_OW            = "FALSE",   // 使能选项：开启或关闭。
    parameter integer PMA_CH0_REG_TX_BEACON_TIMER_SEL         = 0,         // 取值范围：0～3。
    parameter         PMA_CH0_REG_TX_RXDET_REQ_OW             = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH0_REG_TX_RXDET_REQ                = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH0_REG_TX_BEACON_EN_OW             = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH0_REG_TX_BEACON_EN                = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH0_REG_TX_EI_EN_OW                 = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH0_REG_TX_EI_EN                    = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH0_REG_TX_BIT_CONV                 = "FALSE",   // 使能选项：开启或关闭。
    parameter integer PMA_CH0_REG_TX_RES_CAL                  = 48,        // 取值范围：0～63。
    parameter         PMA_CH0_REG_TX_RESERVED_19              = "FALSE",   // 使能选项：开启或关闭。
    parameter integer PMA_CH0_REG_TX_RESERVED_25_20           = 32,        // 取值范围：0～63。
    parameter integer PMA_CH0_REG_TX_RESERVED_33_26           = 0,         // 取值范围：0～255。
    parameter integer PMA_CH0_REG_TX_RESERVED_41_34           = 0,         // 取值范围：0～255。
    parameter integer PMA_CH0_REG_TX_RESERVED_49_42           = 0,         // 取值范围：0～255。
    parameter integer PMA_CH0_REG_TX_RESERVED_57_50           = 0,         // 取值范围：0～255。
    parameter         PMA_CH0_REG_TX_SYNC_OW                  = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH0_REG_TX_SYNC                     = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH0_REG_TX_PD_POST                  = "OFF",     // 使能选项：开启或关闭。
    parameter         PMA_CH0_REG_TX_PD_POST_OW               = "TRUE",    // 使能选项：开启或关闭。
    parameter         PMA_CH0_REG_TX_RESET_N_OW               = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH0_REG_TX_RESET_N                  = "TRUE",    // 使能选项：开启或关闭。
    parameter         PMA_CH0_REG_TX_RESERVED_64              = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH0_REG_TX_RESERVED_65              = "TRUE",    // 使能选项：开启或关闭。
    parameter         PMA_CH0_REG_TX_BUSWIDTH_OW              = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH0_REG_TX_BUSWIDTH                 = "20BIT",   // 位宽选项：8、10、16 或 20 位。
    parameter         PMA_CH0_REG_PLL_READY_OW                = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH0_REG_PLL_READY                   = "TRUE",    // 使能选项：开启或关闭。
    parameter         PMA_CH0_REG_TX_RESERVED_72              = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH0_REG_TX_RESERVED_73              = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH0_REG_TX_RESERVED_74              = "FALSE",   // 使能选项：开启或关闭。
    parameter integer PMA_CH0_REG_EI_PCLK_DELAY_SEL           = 0,         // 取值范围：0～3。
    parameter         PMA_CH0_REG_TX_RESERVED_77              = "FALSE",   // 使能选项：开启或关闭。
    parameter integer PMA_CH0_REG_TX_RESERVED_83_78           = 0,         // 取值范围：0～63。
    parameter integer PMA_CH0_REG_TX_RESERVED_89_84           = 0,         // 取值范围：0～63。
    parameter integer PMA_CH0_REG_TX_RESERVED_95_90           = 0,         // 取值范围：0～63。
    parameter integer PMA_CH0_REG_TX_RESERVED_101_96          = 0,         // 取值范围：0～63。
    parameter integer PMA_CH0_REG_TX_RESERVED_107_102         = 0,         // 取值范围：0～63。
    parameter integer PMA_CH0_REG_TX_RESERVED_113_108         = 0,         // 取值范围：0～63。
    parameter integer PMA_CH0_REG_TX_AMP_DAC0                 = 25,        // 取值范围：0～63。
    parameter integer PMA_CH0_REG_TX_AMP_DAC1                 = 19,        // 取值范围：0～63。
    parameter integer PMA_CH0_REG_TX_AMP_DAC2                 = 14,        // 取值范围：0～63。
    parameter integer PMA_CH0_REG_TX_AMP_DAC3                 = 9,         // 取值范围：0～63。
    parameter integer PMA_CH0_REG_TX_RESERVED_143_138         = 5,         // 取值范围：0～63。
    parameter integer PMA_CH0_REG_TX_MARGIN                   = 0,         // 取值范围：0～7。
    parameter         PMA_CH0_REG_TX_MARGIN_OW                = "FALSE",   // 使能选项：开启或关闭。
    parameter integer PMA_CH0_REG_TX_RESERVED_149_148         = 0,         // 取值范围：0～3。
    parameter         PMA_CH0_REG_TX_RESERVED_150             = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH0_REG_TX_SWING                    = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH0_REG_TX_SWING_OW                 = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH0_REG_TX_RESERVED_153             = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH0_REG_TX_RXDET_THRESHOLD          = "84MV",    // 电压选项：28、56、84、112 mV。
    parameter integer PMA_CH0_REG_TX_RESERVED_157_156         = 0,         // 取值范围：0～3。
    parameter         PMA_CH0_REG_TX_BEACON_OSC_CTRL          = "FALSE",   // 使能选项：开启或关闭。
    parameter integer PMA_CH0_REG_TX_RESERVED_160_159         = 0,         // 取值范围：0～3。
    parameter integer PMA_CH0_REG_TX_RESERVED_162_161         = 0,         // 取值范围：0～3。
    parameter         PMA_CH0_REG_TX_TX2RX_SLPBACK_EN         = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH0_REG_TX_PCLK_EDGE_SEL            = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH0_REG_TX_RXDET_STATUS_OW          = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH0_REG_TX_RXDET_STATUS             = "TRUE",    // 使能选项：开启或关闭。
    parameter         PMA_CH0_REG_TX_PRBS_GEN_EN              = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH0_REG_TX_PRBS_GEN_WIDTH_SEL       = "20BIT",   // 位宽选项：8、10、16 或 20 位。
    parameter         PMA_CH0_REG_TX_PRBS_SEL                 = "PRBS7",   // PRBS 多项式阶数：7、15、23、31。
    parameter integer PMA_CH0_REG_TX_UDP_DATA_7_TO_0          = 5,         // 取值范围：0～255。
    parameter integer PMA_CH0_REG_TX_UDP_DATA_15_TO_8         = 235,       // 取值范围：0～255。
    parameter integer PMA_CH0_REG_TX_UDP_DATA_19_TO_16        = 3,         // 取值范围：0～15。
    parameter         PMA_CH0_REG_TX_RESERVED_192             = "FALSE",   // 使能选项：开启或关闭。
    parameter integer PMA_CH0_REG_TX_FIFO_WP_CTRL             = 4,         // 取值范围：0～7。
    parameter         PMA_CH0_REG_TX_FIFO_EN                  = "FALSE",   // 使能选项：开启或关闭。
    parameter integer PMA_CH0_REG_TX_DATA_MUX_SEL             = 0,         // 取值范围：0～3。
    parameter         PMA_CH0_REG_TX_ERR_INSERT               = "FALSE",   // 使能选项：开启或关闭。
    parameter integer PMA_CH0_REG_TX_RESERVED_203_200         = 0,         // 取值范围：0～15。
    parameter         PMA_CH0_REG_TX_RESERVED_204             = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH0_REG_TX_SATA_EN                  = "FALSE",   // 使能选项：开启或关闭。
    parameter integer PMA_CH0_REG_TX_RESERVED_207_206         = 0,         // 取值范围：0～3。
    parameter         PMA_CH0_REG_RATE_CHANGE_TXPCLK_ON_OW    = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH0_REG_RATE_CHANGE_TXPCLK_ON       = "TRUE",    // 使能选项：开启或关闭。
    parameter integer PMA_CH0_REG_TX_CFG_POST1                = 0,         // 取值范围：0～31。
    parameter integer PMA_CH0_REG_TX_CFG_POST2                = 0,         // 取值范围：0～31。
    parameter integer PMA_CH0_REG_TX_DEEMP                    = 0,         // 取值范围：0～3。
    parameter         PMA_CH0_REG_TX_DEEMP_OW                 = "FALSE",   // 发送去加重控制
    parameter integer PMA_CH0_REG_TX_RESERVED_224_223         = 0,         // 取值范围：0～3。
    parameter         PMA_CH0_REG_TX_RESERVED_225             = "FALSE",   // 使能选项：开启或关闭。
    parameter integer PMA_CH0_REG_TX_RESERVED_229_226         = 0,         // 取值范围：0～15。
    parameter integer PMA_CH0_REG_TX_OOB_DELAY_SEL            = 0,         // 取值范围：0～15。
    parameter         PMA_CH0_REG_TX_POLARITY                 = "NORMAL",  // 极性选项：正常或反转。
    parameter         PMA_CH0_REG_ANA_TX_JTAG_DATA_O_SEL      = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH0_REG_TX_RESERVED_236             = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH0_REG_TX_LS_MODE_EN               = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH0_REG_TX_JTAG_MODE_EN_OW          = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH0_REG_TX_JTAG_MODE_EN             = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH0_REG_RX_JTAG_MODE_EN_OW          = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH0_REG_RX_JTAG_MODE_EN             = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH0_REG_RX_JTAG_OE                  = "TRUE",    // 使能选项：开启或关闭。
    parameter integer PMA_CH0_REG_RX_ACJTAG_VHYSTSEL          = 0,         // 取值范围：0～7。
    parameter         PMA_CH0_REG_TX_RES_CAL_EN               = "FALSE",   // 使能选项：开启或关闭。
    parameter integer PMA_CH0_REG_RX_TERM_MODE_CTRL           = 5,         // 接收终端控制范围：0～7。
    parameter integer PMA_CH0_REG_TX_RESERVED_251_250         = 0,         // 取值范围：0～7。
    parameter         PMA_CH0_REG_PLPBK_TXPCLK_EN             = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH0_REG_TX_RESERVED_253             = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH0_REG_TX_RESERVED_254             = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH0_REG_TX_RESERVED_255             = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH0_REG_TX_RESERVED_256             = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH0_REG_TX_RESERVED_257             = "FALSE",   // 使能选项：开启或关闭。
    parameter integer PMA_CH0_REG_TX_PH_SEL                   = 1,         // 取值范围：0～63。
    parameter integer PMA_CH0_REG_TX_CFG_PRE                  = 0,         // 取值范围：0～31。
    parameter integer PMA_CH0_REG_TX_CFG_MAIN                 = 0,         // 取值范围：0～63。
    parameter integer PMA_CH0_REG_CFG_POST                    = 0,         // 取值范围：0～31。
    parameter         PMA_CH0_REG_PD_MAIN                     = "TRUE",    // 使能选项：开启或关闭。
    parameter         PMA_CH0_REG_PD_PRE                      = "TRUE",    // 使能选项：开启或关闭。
    parameter         PMA_CH0_REG_TX_LS_DATA                  = "FALSE",   // 使能选项：开启或关闭。
    parameter integer PMA_CH0_REG_TX_DCC_BUF_SZ_SEL           = 0,         // 取值范围：0～3。
    parameter integer PMA_CH0_REG_TX_DCC_CAL_CUR_TUNE         = 0,         // 取值范围：0～63。
    parameter         PMA_CH0_REG_TX_DCC_CAL_EN               = "FALSE",   // 使能选项：开启或关闭。
    parameter integer PMA_CH0_REG_TX_DCC_CUR_SS               = 0,         // 取值范围：0～3。
    parameter         PMA_CH0_REG_TX_DCC_FA_CTRL              = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH0_REG_TX_DCC_RI_CTRL              = "FALSE",   // 使能选项：开启或关闭。
    parameter integer PMA_CH0_REG_ATB_SEL_2_TO_0              = 0,         // 取值范围：0～7。
    parameter integer PMA_CH0_REG_ATB_SEL_9_TO_3              = 0,         // 取值范围：0～127。
    parameter integer PMA_CH0_REG_TX_CFG_7_TO_0               = 0,         // 取值范围：0～255。
    parameter integer PMA_CH0_REG_TX_CFG_15_TO_8              = 0,         // 取值范围：0～255。
    parameter integer PMA_CH0_REG_TX_CFG_23_TO_16             = 0,         // 取值范围：0～255。
    parameter integer PMA_CH0_REG_TX_CFG_31_TO_24             = 128,       // 取值范围：0～255。
    parameter         PMA_CH0_REG_TX_OOB_EI_EN                = "FALSE",   // SATA 模式带外电气空闲使能
    parameter         PMA_CH0_REG_TX_OOB_EI_EN_OW             = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH0_REG_TX_BEACON_EN_DELAYED        = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH0_REG_TX_BEACON_EN_DELAYED_OW     = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH0_REG_TX_JTAG_DATA                = "FALSE",   // 使能选项：开启或关闭。
    parameter integer PMA_CH0_REG_TX_RXDET_TIMER_SEL          = 87,        // 取值范围：0～255。
    parameter integer PMA_CH0_REG_TX_CFG1_7_0                 = 0,         // 取值范围：0～255。
    parameter integer PMA_CH0_REG_TX_CFG1_15_8                = 0,         // 取值范围：0～255。
    parameter integer PMA_CH0_REG_TX_CFG1_23_16               = 0,         // 取值范围：0～255。
    parameter integer PMA_CH0_REG_TX_CFG1_31_24               = 0,         // 取值范围：0～255。
    parameter         PMA_CH0_REG_CFG_LANE_POWERUP            = "ON",      // PMA 通道上电控制
    parameter         PMA_CH0_REG_CFG_TX_LANE_POWERUP_CLKPATH = "TRUE",    // PMA 发送通道时钟路径上电控制
    parameter         PMA_CH0_REG_CFG_TX_LANE_POWERUP_PISO    = "TRUE",    // PMA 发送并串转换单元上电控制
    parameter         PMA_CH0_REG_CFG_TX_LANE_POWERUP_DRIVER  = "TRUE",    // PMA 发送驱动器上电控制
    // 通道 1 参数
    parameter integer CH1_MUX_BIAS                            = 2,         // 取值范围：0～7，不支持仿真。
    parameter integer CH1_PD_CLK                              = 0,         // 取值范围：0～1。
    parameter integer CH1_REG_SYNC                            = 0,         // 取值范围：0～1。
    parameter integer CH1_REG_SYNC_OW                         = 0,         // 取值范围：0～1。
    parameter integer CH1_PLL_LOCK_OW                         = 0,         // 取值范围：0～1。
    parameter integer CH1_PLL_LOCK_OW_EN                      = 0,         // 取值范围：0～1。

    parameter integer PCS_CH1_SLAVE = 0,  // 时钟配置由用户指定，软件仅检查对应的时钟连线。
    parameter PCS_CH1_BYPASS_WORD_ALIGN = "FALSE",  // 字对齐旁路使能
    parameter PCS_CH1_BYPASS_DENC = "FALSE",  // 8b/10b 解码旁路使能
    parameter PCS_CH1_BYPASS_BONDING = "FALSE",  // 通道绑定旁路使能
    parameter PCS_CH1_BYPASS_CTC = "FALSE",  // 时钟补偿旁路使能
    parameter PCS_CH1_BYPASS_GEAR = "FALSE",  // 接收齿轮箱旁路使能
    parameter PCS_CH1_BYPASS_BRIDGE = "FALSE",  // 接收桥接单元旁路使能
    parameter PCS_CH1_BYPASS_BRIDGE_FIFO = "FALSE",  // 接收桥接 FIFO 旁路使能
    parameter PCS_CH1_DATA_MODE = "X8",  // 参数选项："X8","X10","X16","X20"
    parameter               PCS_CH1_RX_POLARITY_INV = "DELAY"                     ,// 数据变换：延迟、位极性反转、位序反转或两者同时反转。
    parameter PCS_CH1_ALIGN_MODE = "1GB",  // 协议模式：1GB、10GB、RAPIDIO 或外部模式。
    parameter PCS_CH1_SAMP_16B = "X20",  // 参数选项："X20",X16
    parameter PCS_CH1_FARLP_PWR_REDUCTION = "FALSE",  // 使能选项：开启或关闭。
    parameter integer PCS_CH1_COMMA_REG0 = 0,  // 取值范围：0～1023。
    parameter integer PCS_CH1_COMMA_MASK = 0,  // 取值范围：0～1023。
    parameter PCS_CH1_CEB_MODE = "10GB",  // 协议模式：10GB、RAPIDIO 或外部模式。
    parameter PCS_CH1_CTC_MODE = "1SKIP",  // 跳过字符模式：单字符、双字符、PCIe 双字节或四字符。
    parameter integer PCS_CH1_A_REG = 0,  // 取值范围：0～255。
    parameter PCS_CH1_GE_AUTO_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter integer PCS_CH1_SKIP_REG0 = 0,  // 取值范围：0～1023。
    parameter integer PCS_CH1_SKIP_REG1 = 0,  // 取值范围：0～1023。
    parameter integer PCS_CH1_SKIP_REG2 = 0,  // 取值范围：0～1023。
    parameter integer PCS_CH1_SKIP_REG3 = 0,  // 取值范围：0～1023。
    parameter PCS_CH1_DEC_DUAL = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH1_SPLIT = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH1_FIFOFLAG_CTC = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH1_COMMA_DET_MODE = "COMMA_PATTERN",  // 参数选项："RX_CLK_SLIP" "COMMA_PATTERN"
    parameter PCS_CH1_ERRDETECT_SILENCE = "TRUE",  // 使能选项：开启或关闭。
    parameter PCS_CH1_PMA_RCLK_POLINV = "PMA_RCLK",  // 参数选项："PMA_RCLK" "REVERSE_OF_PMA_RCLK"
    parameter PCS_CH1_PCS_RCLK_SEL = "PMA_RCLK",  // 参数选项："PMA_RCLK" "PMA_TCLK" "RCLK"
    parameter PCS_CH1_CB_RCLK_SEL = "PMA_RCLK",  // 参数选项："PMA_RCLK" "PMA_TCLK" "MCB_RCLK"
    parameter PCS_CH1_AFTER_CTC_RCLK_SEL = "PMA_RCLK",  // 参数选项："PMA_RCLK" "PMA_TCLK" "MCB_RCLK" "RCLK2"
    parameter PCS_CH1_RCLK_POLINV = "RCLK",  // 参数选项："RCLK" "REVERSE_OF_RCLK"
    parameter PCS_CH1_BRIDGE_RCLK_SEL = "PMA_RCLK",  // 参数选项："PMA_RCLK" "PMA_TCLK" "MCB_RCLK" "RCLK"
    parameter PCS_CH1_PCS_RCLK_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH1_CB_RCLK_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH1_AFTER_CTC_RCLK_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH1_AFTER_CTC_RCLK_EN_GB = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH1_PCS_RX_RSTN = "TRUE",  // PCS 接收端复位控制
    parameter PCS_CH1_PCIE_SLAVE = "MASTER",  // 通道角色：主通道或从通道。
    parameter PCS_CH1_RX_64B66B_67B = "NORMAL",  // 编码模式：普通、64b/66b 或 64b/67b。
    parameter               PCS_CH1_RX_BRIDGE_CLK_POLINV = "RX_BRIDGE_CLK"        ,// 参数选项："RX_BRIDGE_CLK" "REVERSE_OF_RX_BRIDGE_CLK"
    parameter PCS_CH1_PCS_CB_RSTN = "TRUE",  // PCS 通道绑定复位控制
    parameter               PCS_CH1_TX_BRIDGE_GEAR_SEL = "FALSE"                  ,// TRUE 优先使用发送齿轮箱，FALSE 优先使用发送桥接单元。
    parameter PCS_CH1_TX_BYPASS_BRIDGE_UINT = "FALSE",  // 旁路使能
    parameter PCS_CH1_TX_BYPASS_BRIDGE_FIFO = "FALSE",  // 发送桥接 FIFO 旁路使能
    parameter PCS_CH1_TX_BYPASS_GEAR = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH1_TX_BYPASS_ENC = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH1_TX_BYPASS_BIT_SLIP = "TRUE",  // 使能选项：开启或关闭。
    parameter PCS_CH1_TX_GEAR_SPLIT = "TRUE",  // 使能选项：开启或关闭。
    parameter               PCS_CH1_TX_DRIVE_REG_MODE = "NO_CHANGE"               ,// 变换选项：不变、极性反转、位序反转或两者同时反转。
    parameter integer PCS_CH1_TX_BIT_SLIP_CYCLES = 0,  // 取值范围：0～31。
    parameter PCS_CH1_INT_TX_MASK_0 = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH1_INT_TX_MASK_1 = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH1_INT_TX_MASK_2 = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH1_INT_TX_CLR_0 = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH1_INT_TX_CLR_1 = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH1_INT_TX_CLR_2 = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH1_TX_PMA_TCLK_POLINV = "PMA_TCLK",  // 参数选项："PMA_TCLK" "REVERSE_OF_PMA_TCLK"
    parameter PCS_CH1_TX_PCS_CLK_EN_SEL = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH1_TX_BRIDGE_TCLK_SEL = "TCLK",  // 参数选项："PCS_TCLK" "TCLK"
    parameter PCS_CH1_TX_TCLK_POLINV = "TCLK",  // 参数选项："TCLK" "REVERSE_OF_TCLK"
    parameter PCS_CH1_PCS_TCLK_SEL = "PMA_TCLK",  // 参数选项："PMA_TCLK" "TCLK"
    parameter PCS_CH1_TX_PCS_TX_RSTN = "TRUE",  // PCS 发送端复位控制
    parameter PCS_CH1_TX_SLAVE = "MASTER",  // 通道角色：主通道或从通道。
    parameter PCS_CH1_TX_GEAR_CLK_EN_SEL = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH1_DATA_WIDTH_MODE = "X20",  // 参数选项："X8" "X10" "X16" "X20"
    parameter PCS_CH1_TX_64B66B_67B = "NORMAL",  // 编码模式：普通、64b/66b 或 64b/67b。
    parameter PCS_CH1_GEAR_TCLK_SEL = "PMA_TCLK",  // 参数选项："PMA_TCLK" "TCLK2"
    parameter PCS_CH1_TX_TCLK2FABRIC_SEL = "TRUE",  // 使能选项：开启或关闭。
    parameter PCS_CH1_TX_OUTZZ = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH1_ENC_DUAL = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH1_TX_BITSLIP_DATA_MODE = "X10",  // 参数选项："X10" "X20"
    parameter               PCS_CH1_TX_BRIDGE_CLK_POLINV = "TX_BRIDGE_CLK"        ,// 参数选项："TX_BRIDGE_CLK" "REVERSE_OF_TX_BRIDGE_CLK"
    parameter integer PCS_CH1_COMMA_REG1 = 0,  // 取值范围：0～1023。
    parameter integer PCS_CH1_RAPID_IMAX = 0,  // 取值范围：0～7。
    parameter integer PCS_CH1_RAPID_VMIN_1 = 0,  // 取值范围：0～255。
    parameter integer PCS_CH1_RAPID_VMIN_2 = 0,  // 取值范围：0～255。
    parameter PCS_CH1_RX_PRBS_MODE = "DISABLE",  // PRBS 配置：关闭或选择 7、15、23、31 阶多项式。
    parameter PCS_CH1_RX_ERRCNT_CLR = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH1_PRBS_ERR_LPBK = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH1_TX_PRBS_MODE = "DISABLE",  // 测试码型：PRBS、长 1、长 0、20 UI、D10.2 或 PCIe。
    parameter PCS_CH1_TX_INSERT_ER = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH1_ENABLE_PRBS_GEN = "FALSE",  // 使能选项：开启或关闭。
    parameter integer PCS_CH1_DEFAULT_RADDR = 6,  // 取值范围：0～15。
    parameter integer PCS_CH1_MASTER_CHECK_OFFSET = 0,  // 取值范围：0～15。
    parameter integer PCS_CH1_DELAY_SET = 0,  // 取值范围：0～15。
    parameter PCS_CH1_SEACH_OFFSET = "20BIT",  // 绑定位宽：20～80 位，间隔 10 位。
    parameter integer PCS_CH1_CEB_RAPIDLS_MMAX = 0,  // 取值范围：0～7。
    parameter integer PCS_CH1_CTC_AFULL = 20,  // 取值范围：0～31。
    parameter integer PCS_CH1_CTC_AEMPTY = 12,  // 取值范围：0～31。
    parameter integer PCS_CH1_CTC_CONTI_SKP_SET = 0,  // 取值范围：0～1。
    parameter PCS_CH1_FAR_LOOP = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH1_NEAR_LOOP = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH1_PMA_TX2RX_PLOOP_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH1_PMA_TX2RX_SLOOP_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH1_PMA_RX2TX_PLOOP_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH1_INT_RX_MASK_0 = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH1_INT_RX_MASK_1 = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH1_INT_RX_MASK_2 = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH1_INT_RX_MASK_3 = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH1_INT_RX_MASK_4 = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH1_INT_RX_MASK_5 = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH1_INT_RX_MASK_6 = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH1_INT_RX_MASK_7 = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH1_INT_RX_CLR_0 = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH1_INT_RX_CLR_1 = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH1_INT_RX_CLR_2 = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH1_INT_RX_CLR_3 = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH1_INT_RX_CLR_4 = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH1_INT_RX_CLR_5 = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH1_INT_RX_CLR_6 = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH1_INT_RX_CLR_7 = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH1_CA_RSTN_RX = "FALSE",  // 接收时钟对齐器复位控制
    parameter PCS_CH1_CA_DYN_DLY_EN_RX = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH1_CA_DYN_DLY_SEL_RX = "FALSE",  // 使能选项：开启或关闭。
    parameter integer PCS_CH1_CA_RX = 0,  // 取值范围：0～255。
    parameter PCS_CH1_CA_RSTN_TX = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH1_CA_DYN_DLY_EN_TX = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH1_CA_DYN_DLY_SEL_TX = "FALSE",  // 使能选项：开启或关闭。
    parameter integer PCS_CH1_CA_TX = 0,  // 取值范围：0～255。
    parameter PCS_CH1_RXPRBS_PWR_REDUCTION = "NORMAL",  // 工作模式：普通或低功耗。
    parameter PCS_CH1_WDALIGN_PWR_REDUCTION = "NORMAL",  // 工作模式：普通或低功耗。
    parameter PCS_CH1_RXDEC_PWR_REDUCTION = "NORMAL",  // 工作模式：普通或低功耗。
    parameter PCS_CH1_RXCB_PWR_REDUCTION = "NORMAL",  // 工作模式：普通或低功耗。
    parameter PCS_CH1_RXCTC_PWR_REDUCTION = "NORMAL",  // 工作模式：普通或低功耗。
    parameter PCS_CH1_RXGEAR_PWR_REDUCTION = "NORMAL",  // 工作模式：普通或低功耗。
    parameter PCS_CH1_RXBRG_PWR_REDUCTION = "NORMAL",  // 工作模式：普通或低功耗。
    parameter PCS_CH1_RXTEST_PWR_REDUCTION = "NORMAL",  // 工作模式：普通或低功耗。
    parameter PCS_CH1_TXBRG_PWR_REDUCTION = "NORMAL",  // 工作模式：普通或低功耗。
    parameter PCS_CH1_TXGEAR_PWR_REDUCTION = "NORMAL",  // 工作模式：普通或低功耗。
    parameter PCS_CH1_TXENC_PWR_REDUCTION = "NORMAL",  // 工作模式：普通或低功耗。
    parameter PCS_CH1_TXBSLP_PWR_REDUCTION = "NORMAL",  // 工作模式：普通或低功耗。
    parameter PCS_CH1_TXPRBS_PWR_REDUCTION = "NORMAL",  // 工作模式：普通或低功耗。

    parameter PMA_CH1_REG_RX_PD = "ON",  // 使能选项：开启或关闭。
    parameter PMA_CH1_REG_RX_PD_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH1_REG_RX_RESERVED_2 = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH1_REG_RX_RESERVED_3 = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH1_REG_RX_DATAPATH_PD = "ON",  // 使能选项：开启或关闭。
    parameter PMA_CH1_REG_RX_DATAPATH_PD_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH1_REG_RX_SIGDET_PD = "ON",  // 使能选项：开启或关闭。
    parameter PMA_CH1_REG_RX_SIGDET_PD_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH1_REG_RX_DCC_RST_N = "TRUE",  // 使能选项：开启或关闭。
    parameter PMA_CH1_REG_RX_DCC_RST_N_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH1_REG_RX_CDR_RST_N = "TRUE",  // 使能选项：开启或关闭。
    parameter PMA_CH1_REG_RX_CDR_RST_N_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH1_REG_RX_SIGDET_RST_N = "TRUE",  // 使能选项：开启或关闭。
    parameter PMA_CH1_REG_RX_SIGDET_RST_N_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH1_REG_RXPCLK_SLIP = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH1_REG_RXPCLK_SLIP_OW = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH1_REG_RX_PCLKSWITCH_RST_N = "TRUE",  // 发送 PMA 复位控制
    parameter PMA_CH1_REG_RX_PCLKSWITCH_RST_N_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH1_REG_RX_PCLKSWITCH = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH1_REG_RX_PCLKSWITCH_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH1_REG_RX_HIGHZ = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH1_REG_RX_HIGHZ_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH1_REG_RX_SIGDET_CLK_WINDOW = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH1_REG_RX_SIGDET_CLK_WINDOW_OW = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH1_REG_RX_PD_BIAS_RX = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH1_REG_RX_PD_BIAS_RX_OW = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH1_REG_RX_RESET_N = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH1_REG_RX_RESET_N_OW = "FALSE",  // 使能选项：开启或关闭。
    parameter integer PMA_CH1_REG_RX_RESERVED_29_28 = 0,  // 取值范围：0～3。
    parameter PMA_CH1_REG_RX_BUSWIDTH = "20BIT",  // 位宽选项：8、10、16 或 20 位。
    parameter PMA_CH1_REG_RX_BUSWIDTH_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH1_REG_RX_RATE = "DIV1",  // 时钟倍率：四分频、二分频、原频或二倍频。
    parameter PMA_CH1_REG_RX_RESERVED_36 = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH1_REG_RX_RATE_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter integer PMA_CH1_REG_RX_RES_TRIM = 46,  // 取值范围：0～63。
    parameter PMA_CH1_REG_RX_RESERVED_44 = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH1_REG_RX_RESERVED_45 = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH1_REG_RX_SIGDET_STATUS_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter integer PMA_CH1_REG_RX_RESERVED_48_47 = 0,  // 取值范围：0～3。
    parameter integer PMA_CH1_REG_RX_ICTRL_SIGDET = 5,  // 取值范围：0～15。
    parameter integer PMA_CH1_REG_CDR_READY_THD = 2734,  // 取值范围：0～4095。
    parameter PMA_CH1_REG_RX_RESERVED_65 = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH1_REG_RX_PCLK_EDGE_SEL = "POS_EDGE",  // 时钟边沿：上升沿或下降沿。
    parameter integer PMA_CH1_REG_RX_PIBUF_IC = 1,  // 取值范围：0～3。
    parameter PMA_CH1_REG_RX_RESERVED_69 = "FALSE",  // 使能选项：开启或关闭。
    parameter integer PMA_CH1_REG_RX_DCC_IC_RX = 1,  // 取值范围：0～3。
    parameter integer PMA_CH1_REG_CDR_READY_CHECK_CTRL = 0,  // 取值范围：0～3。
    parameter PMA_CH1_REG_RX_ICTRL_TRX = "100PCT",  // 比例选项：87.5%、100%、112.5%、125%。
    parameter integer PMA_CH1_REG_RX_RESERVED_77_76 = 0,  // 取值范围：0～3。
    parameter integer PMA_CH1_REG_RX_RESERVED_79_78 = 1,  // 取值范围：0～3。
    parameter integer PMA_CH1_REG_RX_RESERVED_81_80 = 1,  // 取值范围：0～3。
    parameter PMA_CH1_REG_RX_ICTRL_PIBUF = "100PCT",  // 比例选项：87.5%、100%、112.5%、125%。
    parameter PMA_CH1_REG_RX_ICTRL_PI = "100PCT",  // 比例选项：87.5%、100%、112.5%、125%。
    parameter PMA_CH1_REG_RX_ICTRL_DCC = "100PCT",  // 比例选项：87.5%、100%、112.5%、125%。
    parameter integer PMA_CH1_REG_RX_RESERVED_89_88 = 1,  // 取值范围：0～3。
    parameter PMA_CH1_REG_TX_RATE = "DIV1",  // 时钟倍率：四分频、二分频、原频或二倍频。
    parameter PMA_CH1_REG_RX_RESERVED_92 = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH1_REG_TX_RATE_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH1_REG_RX_TX2RX_PLPBK_RST_N = "TRUE",  // PMA 发送到接收并行环回复位控制
    parameter PMA_CH1_REG_RX_TX2RX_PLPBK_RST_N_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH1_REG_RX_TX2RX_PLPBK_EN = "FALSE",  // PMA 发送到接收并行环回使能
    parameter PMA_CH1_REG_TXCLK_SEL = "PLL",  // 时钟来源：PLL 或接收时钟。
    parameter PMA_CH1_REG_RX_DATA_POLARITY = "NORMAL",  // 极性选项：正常或反转。
    parameter PMA_CH1_REG_RX_ERR_INSERT = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH1_REG_UDP_CHK_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH1_REG_PRBS_SEL = "PRBS7",  // PRBS 多项式阶数：7、15、23、31。
    parameter PMA_CH1_REG_PRBS_CHK_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH1_REG_PRBS_CHK_WIDTH_SEL = "20BIT",  // 位宽选项：8、10、16 或 20 位。
    parameter PMA_CH1_REG_BIST_CHK_PAT_SEL = "PRBS",  // 码型来源：PRBS 或常量。
    parameter PMA_CH1_REG_LOAD_ERR_CNT = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH1_REG_CHK_COUNTER_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter integer PMA_CH1_REG_CDR_PROP_GAIN = 7,  // 取值范围：0～7。
    parameter integer PMA_CH1_REG_CDR_PROP_TURBO_GAIN = 5,  // 取值范围：0～7。
    parameter integer PMA_CH1_REG_CDR_INT_GAIN = 4,  // 取值范围：0～7。
    parameter integer PMA_CH1_REG_CDR_INT_TURBO_GAIN = 5,  // 取值范围：0～7。
    parameter integer PMA_CH1_REG_CDR_INT_SAT_MAX = 768,  // 取值范围：0～1023。
    parameter integer PMA_CH1_REG_CDR_INT_SAT_MIN = 255,  // 取值范围：0～1023。
    parameter PMA_CH1_REG_CDR_INT_RST = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH1_REG_CDR_INT_RST_OW = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH1_REG_CDR_PROP_RST = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH1_REG_CDR_PROP_RST_OW = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH1_REG_CDR_LOCK_RST = "FALSE",  // CDR 锁定计数器复位控制
    parameter PMA_CH1_REG_CDR_LOCK_RST_OW = "FALSE",  // 使能选项：开启或关闭。
    parameter integer PMA_CH1_REG_CDR_RX_PI_FORCE_SEL = 0,  //0,1
    parameter integer PMA_CH1_REG_CDR_RX_PI_FORCE_D = 0,  // 取值范围：0～255。
    parameter               PMA_CH1_REG_CDR_LOCK_TIMER = "1_2U"                   ,// 参数选项："0_8U" "1_2U" "1_6U" "2_4U" 3_2U" "4_8U" "12_8U" "25_6U"
    parameter integer PMA_CH1_REG_CDR_TURBO_MODE_TIMER = 1,  // 取值范围：0～3。
    parameter PMA_CH1_REG_CDR_LOCK_VAL = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH1_REG_CDR_LOCK_OW = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH1_REG_CDR_INT_SAT_DET_EN = "TRUE",  // 使能选项：开启或关闭。
    parameter PMA_CH1_REG_CDR_SAT_AUTO_DIS = "TRUE",  // 使能选项：开启或关闭。
    parameter PMA_CH1_REG_CDR_GAIN_AUTO = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH1_REG_CDR_TURBO_GAIN_AUTO = "FALSE",  // 使能选项：开启或关闭。
    parameter integer PMA_CH1_REG_RX_RESERVED_171_167 = 0,  // 取值范围：0～31。
    parameter integer PMA_CH1_REG_RX_RESERVED_175_172 = 0,  // 取值范围：0～31。
    parameter PMA_CH1_REG_CDR_SAT_DET_STATUS_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH1_REG_CDR_SAT_DET_STATUS_RESET_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH1_REG_CDR_PI_CTRL_RST = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH1_REG_CDR_PI_CTRL_RST_OW = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH1_REG_CDR_SAT_DET_RST = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH1_REG_CDR_SAT_DET_RST_OW = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH1_REG_CDR_SAT_DET_STICKY_RST = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH1_REG_CDR_SAT_DET_STICKY_RST_OW = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH1_REG_CDR_SIGDET_STATUS_DIS = "FALSE",  // 无信号检测状态时复位 CDR。
    parameter integer PMA_CH1_REG_CDR_SAT_DET_TIMER = 2,  // 取值范围：0～3。
    parameter PMA_CH1_REG_CDR_SAT_DET_STATUS_VAL = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH1_REG_CDR_SAT_DET_STATUS_OW = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH1_REG_CDR_TURBO_MODE_EN = "TRUE",  // 使能选项：开启或关闭。
    parameter PMA_CH1_REG_RX_RESERVED_190 = "FALSE",  // 使能选项：开启或关闭。
    parameter integer PMA_CH1_REG_RX_RESERVED_193_191 = 0,  // 取值范围：0～7。
    parameter PMA_CH1_REG_CDR_STATUS_FIFO_EN = "TRUE",  // 使能选项：开启或关闭。
    parameter integer PMA_CH1_REG_PMA_TEST_SEL = 0,  //0,1
    parameter integer PMA_CH1_REG_OOB_COMWAKE_GAP_MIN = 3,  // 取值范围：0～63。
    parameter integer PMA_CH1_REG_OOB_COMWAKE_GAP_MAX = 11,  // 取值范围：0～63。
    parameter integer PMA_CH1_REG_OOB_COMINIT_GAP_MIN = 15,  // 取值范围：0～255。
    parameter integer PMA_CH1_REG_OOB_COMINIT_GAP_MAX = 35,  // 取值范围：0～255。
    parameter integer PMA_CH1_REG_RX_RESERVED_227_226 = 1,  // 取值范围：0～3。
    parameter integer PMA_CH1_REG_COMWAKE_STATUS_CLEAR = 0,  //0,1
    parameter integer PMA_CH1_REG_COMINIT_STATUS_CLEAR = 0,  //0,1
    parameter PMA_CH1_REG_RX_SYNC_RST_N_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH1_REG_RX_SYNC_RST_N = "TRUE",  // 使能选项：开启或关闭。
    parameter integer PMA_CH1_REG_RX_RESERVED_233_232 = 0,  // 取值范围：0～3。
    parameter integer PMA_CH1_REG_RX_RESERVED_235_234 = 0,  // 取值范围：0～3。
    parameter PMA_CH1_REG_RX_SATA_COMINIT_OW = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH1_REG_RX_SATA_COMINIT = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH1_REG_RX_SATA_COMWAKE_OW = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH1_REG_RX_SATA_COMWAKE = "FALSE",  // 使能选项：开启或关闭。
    parameter integer PMA_CH1_REG_RX_RESERVED_241_240 = 0,  // 取值范围：0～3。
    parameter PMA_CH1_REG_RX_DCC_DISABLE = "FALSE",  // 接收占空比校正禁用控制
    parameter PMA_CH1_REG_RX_RESERVED_243 = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH1_REG_RX_SLIP_SEL_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter integer PMA_CH1_REG_RX_SLIP_SEL = 0,  // 取值范围：0～15。
    parameter PMA_CH1_REG_RX_SLIP_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter integer PMA_CH1_REG_RX_SIGDET_STATUS_SEL = 5,  // 取值范围：0～7。
    parameter PMA_CH1_REG_RX_SIGDET_FSM_RST_N = "TRUE",  // 使能选项：开启或关闭。
    parameter PMA_CH1_REG_RX_RESERVED_254 = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH1_REG_RX_SIGDET_STATUS = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH1_REG_RX_SIGDET_VTH = "72MV",  // 检测电压：45、54、63、72 mV。
    parameter integer PMA_CH1_REG_RX_SIGDET_GRM = 0,  //0,1,2,3
    parameter PMA_CH1_REG_RX_SIGDET_PULSE_EXT = "FALSE",  // 使能选项：开启或关闭。
    parameter integer PMA_CH1_REG_RX_SIGDET_CH2_SEL = 0,  //0,1
    parameter integer PMA_CH1_REG_RX_SIGDET_CH2_CHK_WINDOW = 3,  // 取值范围：0～31。
    parameter PMA_CH1_REG_RX_SIGDET_CHK_WINDOW_EN = "TRUE",  // 使能选项：开启或关闭。
    parameter integer PMA_CH1_REG_RX_SIGDET_NOSIG_COUNT_SETTING = 4,  // 取值范围：0～7。
    parameter PMA_CH1_REG_SLIP_FIFO_INV_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH1_REG_SLIP_FIFO_INV = "POS_EDGE",  // 时钟边沿：上升沿或下降沿。
    parameter integer PMA_CH1_REG_RX_SIGDET_OOB_DET_COUNT_VAL = 0,  // 取值范围：0～31。
    parameter integer PMA_CH1_REG_RX_SIGDET_4OOB_DET_SEL = 7,  // 取值范围：0～7。
    parameter integer PMA_CH1_REG_RX_RESERVED_285_283 = 0,  // 取值范围：0～7。
    parameter PMA_CH1_REG_RX_RESERVED_286 = "FALSE",  // 使能选项：开启或关闭。
    parameter integer PMA_CH1_REG_RX_SIGDET_IC_I = 10,  // 取值范围：0～15。
    parameter PMA_CH1_REG_RX_OOB_DETECTOR_RESET_N_OW = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH1_REG_RX_OOB_DETECTOR_RESET_N = "FALSE",  // 接收带外检测器复位控制
    parameter PMA_CH1_REG_RX_OOB_DETECTOR_PD_OW = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH1_REG_RX_OOB_DETECTOR_PD = "ON",  // 接收带外检测器掉电控制
    parameter PMA_CH1_REG_RX_LS_MODE_EN = "FALSE",  // 低速模式使能
    parameter PMA_CH1_REG_ANA_RX_EQ1_R_SET_FB_O_SEL = "TRUE",  // 使能选项：开启或关闭。
    parameter PMA_CH1_REG_ANA_RX_EQ2_R_SET_FB_O_SEL = "TRUE",  // 使能选项：开启或关闭。
    parameter integer PMA_CH1_REG_RX_EQ1_R_SET_TOP = 0,  // 取值范围：0～3。
    parameter integer PMA_CH1_REG_RX_EQ1_R_SET_FB = 15,  // 取值范围：0～15。
    parameter integer PMA_CH1_REG_RX_EQ1_C_SET_FB = 0,  // 取值范围：0～15。
    parameter PMA_CH1_REG_RX_EQ1_OFF = "FALSE",  // 使能选项：开启或关闭。
    parameter integer PMA_CH1_REG_RX_EQ2_R_SET_TOP = 0,  // 取值范围：0～3。
    parameter integer PMA_CH1_REG_RX_EQ2_R_SET_FB = 0,  // 取值范围：0～15。
    parameter integer PMA_CH1_REG_RX_EQ2_C_SET_FB = 0,  // 取值范围：0～15。
    parameter PMA_CH1_REG_RX_EQ2_OFF = "FALSE",  // 使能选项：开启或关闭。
    parameter integer PMA_CH1_REG_EQ_DAC = 0,  // 取值范围：0～63。
    parameter integer PMA_CH1_REG_RX_ICTRL_EQ = 2,  // 使能选项：开启或关闭。
    parameter PMA_CH1_REG_EQ_DC_CALIB_EN = "TRUE",  // 使能选项：开启或关闭。
    parameter PMA_CH1_REG_EQ_DC_CALIB_SEL = "FALSE",  // 使能选项：开启或关闭。
    parameter integer PMA_CH1_REG_RX_RESERVED_337_330 = 0,  // 取值范围：0～255。
    parameter integer PMA_CH1_REG_RX_RESERVED_345_338 = 0,  // 取值范围：0～255。
    parameter integer PMA_CH1_REG_RX_RESERVED_353_346 = 0,  // 取值范围：0～255。
    parameter integer PMA_CH1_REG_RX_RESERVED_361_354 = 0,  // 取值范围：0～255。
    parameter integer PMA_CH1_CTLE_CTRL_REG_I = 0,  // 取值范围：0～15。
    parameter PMA_CH1_CTLE_REG_FORCE_SEL_I = "FALSE",  // 自适应调整控制
    parameter PMA_CH1_CTLE_REG_HOLD_I = "FALSE",  // 使能选项：开启或关闭。
    parameter integer PMA_CH1_CTLE_REG_INIT_DAC_I = 0,  // 取值范围：0～15。
    parameter PMA_CH1_CTLE_REG_POLARITY_I = "FALSE",  // 使能选项：开启或关闭。
    parameter integer PMA_CH1_CTLE_REG_SHIFTER_GAIN_I = 1,  // 取值范围：0～7。
    parameter integer PMA_CH1_CTLE_REG_THRESHOLD_I = 3072,  // 取值范围：0～4095。
    parameter PMA_CH1_REG_RX_RES_TRIM_EN = "TRUE",  // 使能选项：开启或关闭。
    parameter integer PMA_CH1_REG_RX_RESERVED_393_389 = 0,  // 取值范围：0～31。
    parameter PMA_CH1_CFG_RX_LANE_POWERUP = "ON",  // 接收通道上电控制
    parameter PMA_CH1_CFG_RX_PMA_RSTN = "TRUE",  // 接收 PMA 复位控制
    parameter PMA_CH1_INT_PMA_RX_MASK_0 = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH1_INT_PMA_RX_CLR_0 = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH1_CFG_CTLE_ADP_RSTN = "TRUE",  // 控制逻辑复位

    parameter         PMA_CH1_REG_TX_PD                       = "ON",      // 发送端掉电控制
    parameter         PMA_CH1_REG_TX_PD_OW                    = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH1_REG_TX_MAIN_PRE_Z               = "FALSE",   // PCIe 模式电气空闲使能
    parameter         PMA_CH1_REG_TX_MAIN_PRE_Z_OW            = "FALSE",   // 使能选项：开启或关闭。
    parameter integer PMA_CH1_REG_TX_BEACON_TIMER_SEL         = 0,         // 取值范围：0～3。
    parameter         PMA_CH1_REG_TX_RXDET_REQ_OW             = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH1_REG_TX_RXDET_REQ                = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH1_REG_TX_BEACON_EN_OW             = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH1_REG_TX_BEACON_EN                = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH1_REG_TX_EI_EN_OW                 = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH1_REG_TX_EI_EN                    = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH1_REG_TX_BIT_CONV                 = "FALSE",   // 使能选项：开启或关闭。
    parameter integer PMA_CH1_REG_TX_RES_CAL                  = 48,        // 取值范围：0～63。
    parameter         PMA_CH1_REG_TX_RESERVED_19              = "FALSE",   // 使能选项：开启或关闭。
    parameter integer PMA_CH1_REG_TX_RESERVED_25_20           = 32,        // 取值范围：0～63。
    parameter integer PMA_CH1_REG_TX_RESERVED_33_26           = 0,         // 取值范围：0～255。
    parameter integer PMA_CH1_REG_TX_RESERVED_41_34           = 0,         // 取值范围：0～255。
    parameter integer PMA_CH1_REG_TX_RESERVED_49_42           = 0,         // 取值范围：0～255。
    parameter integer PMA_CH1_REG_TX_RESERVED_57_50           = 0,         // 取值范围：0～255。
    parameter         PMA_CH1_REG_TX_SYNC_OW                  = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH1_REG_TX_SYNC                     = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH1_REG_TX_PD_POST                  = "OFF",     // 使能选项：开启或关闭。
    parameter         PMA_CH1_REG_TX_PD_POST_OW               = "TRUE",    // 使能选项：开启或关闭。
    parameter         PMA_CH1_REG_TX_RESET_N_OW               = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH1_REG_TX_RESET_N                  = "TRUE",    // 使能选项：开启或关闭。
    parameter         PMA_CH1_REG_TX_RESERVED_64              = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH1_REG_TX_RESERVED_65              = "TRUE",    // 使能选项：开启或关闭。
    parameter         PMA_CH1_REG_TX_BUSWIDTH_OW              = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH1_REG_TX_BUSWIDTH                 = "20BIT",   // 位宽选项：8、10、16 或 20 位。
    parameter         PMA_CH1_REG_PLL_READY_OW                = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH1_REG_PLL_READY                   = "TRUE",    // 使能选项：开启或关闭。
    parameter         PMA_CH1_REG_TX_RESERVED_72              = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH1_REG_TX_RESERVED_73              = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH1_REG_TX_RESERVED_74              = "FALSE",   // 使能选项：开启或关闭。
    parameter integer PMA_CH1_REG_EI_PCLK_DELAY_SEL           = 0,         // 取值范围：0～3。
    parameter         PMA_CH1_REG_TX_RESERVED_77              = "FALSE",   // 使能选项：开启或关闭。
    parameter integer PMA_CH1_REG_TX_RESERVED_83_78           = 0,         // 取值范围：0～63。
    parameter integer PMA_CH1_REG_TX_RESERVED_89_84           = 0,         // 取值范围：0～63。
    parameter integer PMA_CH1_REG_TX_RESERVED_95_90           = 0,         // 取值范围：0～63。
    parameter integer PMA_CH1_REG_TX_RESERVED_101_96          = 0,         // 取值范围：0～63。
    parameter integer PMA_CH1_REG_TX_RESERVED_107_102         = 0,         // 取值范围：0～63。
    parameter integer PMA_CH1_REG_TX_RESERVED_113_108         = 0,         // 取值范围：0～63。
    parameter integer PMA_CH1_REG_TX_AMP_DAC0                 = 25,        // 取值范围：0～63。
    parameter integer PMA_CH1_REG_TX_AMP_DAC1                 = 19,        // 取值范围：0～63。
    parameter integer PMA_CH1_REG_TX_AMP_DAC2                 = 14,        // 取值范围：0～63。
    parameter integer PMA_CH1_REG_TX_AMP_DAC3                 = 9,         // 取值范围：0～63。
    parameter integer PMA_CH1_REG_TX_RESERVED_143_138         = 5,         // 取值范围：0～63。
    parameter integer PMA_CH1_REG_TX_MARGIN                   = 0,         // 取值范围：0～7。
    parameter         PMA_CH1_REG_TX_MARGIN_OW                = "FALSE",   // 使能选项：开启或关闭。
    parameter integer PMA_CH1_REG_TX_RESERVED_149_148         = 0,         // 取值范围：0～3。
    parameter         PMA_CH1_REG_TX_RESERVED_150             = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH1_REG_TX_SWING                    = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH1_REG_TX_SWING_OW                 = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH1_REG_TX_RESERVED_153             = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH1_REG_TX_RXDET_THRESHOLD          = "84MV",    // 电压选项：28、56、84、112 mV。
    parameter integer PMA_CH1_REG_TX_RESERVED_157_156         = 0,         // 取值范围：0～3。
    parameter         PMA_CH1_REG_TX_BEACON_OSC_CTRL          = "FALSE",   // 使能选项：开启或关闭。
    parameter integer PMA_CH1_REG_TX_RESERVED_160_159         = 0,         // 取值范围：0～3。
    parameter integer PMA_CH1_REG_TX_RESERVED_162_161         = 0,         // 取值范围：0～3。
    parameter         PMA_CH1_REG_TX_TX2RX_SLPBACK_EN         = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH1_REG_TX_PCLK_EDGE_SEL            = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH1_REG_TX_RXDET_STATUS_OW          = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH1_REG_TX_RXDET_STATUS             = "TRUE",    // 使能选项：开启或关闭。
    parameter         PMA_CH1_REG_TX_PRBS_GEN_EN              = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH1_REG_TX_PRBS_GEN_WIDTH_SEL       = "20BIT",   // 位宽选项：8、10、16 或 20 位。
    parameter         PMA_CH1_REG_TX_PRBS_SEL                 = "PRBS7",   // PRBS 多项式阶数：7、15、23、31。
    parameter integer PMA_CH1_REG_TX_UDP_DATA_7_TO_0          = 5,         // 取值范围：0～255。
    parameter integer PMA_CH1_REG_TX_UDP_DATA_15_TO_8         = 235,       // 取值范围：0～255。
    parameter integer PMA_CH1_REG_TX_UDP_DATA_19_TO_16        = 3,         // 取值范围：0～15。
    parameter         PMA_CH1_REG_TX_RESERVED_192             = "FALSE",   // 使能选项：开启或关闭。
    parameter integer PMA_CH1_REG_TX_FIFO_WP_CTRL             = 4,         // 取值范围：0～7。
    parameter         PMA_CH1_REG_TX_FIFO_EN                  = "FALSE",   // 使能选项：开启或关闭。
    parameter integer PMA_CH1_REG_TX_DATA_MUX_SEL             = 0,         // 取值范围：0～3。
    parameter         PMA_CH1_REG_TX_ERR_INSERT               = "FALSE",   // 使能选项：开启或关闭。
    parameter integer PMA_CH1_REG_TX_RESERVED_203_200         = 0,         // 取值范围：0～15。
    parameter         PMA_CH1_REG_TX_RESERVED_204             = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH1_REG_TX_SATA_EN                  = "FALSE",   // 使能选项：开启或关闭。
    parameter integer PMA_CH1_REG_TX_RESERVED_207_206         = 0,         // 取值范围：0～3。
    parameter         PMA_CH1_REG_RATE_CHANGE_TXPCLK_ON_OW    = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH1_REG_RATE_CHANGE_TXPCLK_ON       = "TRUE",    // 使能选项：开启或关闭。
    parameter integer PMA_CH1_REG_TX_CFG_POST1                = 0,         // 取值范围：0～31。
    parameter integer PMA_CH1_REG_TX_CFG_POST2                = 0,         // 取值范围：0～31。
    parameter integer PMA_CH1_REG_TX_DEEMP                    = 0,         // 取值范围：0～3。
    parameter         PMA_CH1_REG_TX_DEEMP_OW                 = "FALSE",   // 发送去加重控制
    parameter integer PMA_CH1_REG_TX_RESERVED_224_223         = 0,         // 取值范围：0～3。
    parameter         PMA_CH1_REG_TX_RESERVED_225             = "FALSE",   // 使能选项：开启或关闭。
    parameter integer PMA_CH1_REG_TX_RESERVED_229_226         = 0,         // 取值范围：0～15。
    parameter integer PMA_CH1_REG_TX_OOB_DELAY_SEL            = 0,         // 取值范围：0～15。
    parameter         PMA_CH1_REG_TX_POLARITY                 = "NORMAL",  // 极性选项：正常或反转。
    parameter         PMA_CH1_REG_ANA_TX_JTAG_DATA_O_SEL      = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH1_REG_TX_RESERVED_236             = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH1_REG_TX_LS_MODE_EN               = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH1_REG_TX_JTAG_MODE_EN_OW          = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH1_REG_TX_JTAG_MODE_EN             = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH1_REG_RX_JTAG_MODE_EN_OW          = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH1_REG_RX_JTAG_MODE_EN             = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH1_REG_RX_JTAG_OE                  = "TRUE",    // 使能选项：开启或关闭。
    parameter integer PMA_CH1_REG_RX_ACJTAG_VHYSTSEL          = 0,         // 取值范围：0～7。
    parameter         PMA_CH1_REG_TX_RES_CAL_EN               = "FALSE",   // 使能选项：开启或关闭。
    parameter integer PMA_CH1_REG_RX_TERM_MODE_CTRL           = 5,         // 接收终端控制范围：0～7。
    parameter integer PMA_CH1_REG_TX_RESERVED_251_250         = 0,         // 取值范围：0～7。
    parameter         PMA_CH1_REG_PLPBK_TXPCLK_EN             = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH1_REG_TX_RESERVED_253             = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH1_REG_TX_RESERVED_254             = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH1_REG_TX_RESERVED_255             = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH1_REG_TX_RESERVED_256             = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH1_REG_TX_RESERVED_257             = "FALSE",   // 使能选项：开启或关闭。
    parameter integer PMA_CH1_REG_TX_PH_SEL                   = 1,         // 取值范围：0～63。
    parameter integer PMA_CH1_REG_TX_CFG_PRE                  = 0,         // 取值范围：0～31。
    parameter integer PMA_CH1_REG_TX_CFG_MAIN                 = 0,         // 取值范围：0～63。
    parameter integer PMA_CH1_REG_CFG_POST                    = 0,         // 取值范围：0～31。
    parameter         PMA_CH1_REG_PD_MAIN                     = "TRUE",    // 使能选项：开启或关闭。
    parameter         PMA_CH1_REG_PD_PRE                      = "TRUE",    // 使能选项：开启或关闭。
    parameter         PMA_CH1_REG_TX_LS_DATA                  = "FALSE",   // 使能选项：开启或关闭。
    parameter integer PMA_CH1_REG_TX_DCC_BUF_SZ_SEL           = 0,         // 取值范围：0～3。
    parameter integer PMA_CH1_REG_TX_DCC_CAL_CUR_TUNE         = 0,         // 取值范围：0～63。
    parameter         PMA_CH1_REG_TX_DCC_CAL_EN               = "FALSE",   // 使能选项：开启或关闭。
    parameter integer PMA_CH1_REG_TX_DCC_CUR_SS               = 0,         // 取值范围：0～3。
    parameter         PMA_CH1_REG_TX_DCC_FA_CTRL              = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH1_REG_TX_DCC_RI_CTRL              = "FALSE",   // 使能选项：开启或关闭。
    parameter integer PMA_CH1_REG_ATB_SEL_2_TO_0              = 0,         // 取值范围：0～7。
    parameter integer PMA_CH1_REG_ATB_SEL_9_TO_3              = 0,         // 取值范围：0～127。
    parameter integer PMA_CH1_REG_TX_CFG_7_TO_0               = 0,         // 取值范围：0～255。
    parameter integer PMA_CH1_REG_TX_CFG_15_TO_8              = 0,         // 取值范围：0～255。
    parameter integer PMA_CH1_REG_TX_CFG_23_TO_16             = 0,         // 取值范围：0～255。
    parameter integer PMA_CH1_REG_TX_CFG_31_TO_24             = 128,       // 取值范围：0～255。
    parameter         PMA_CH1_REG_TX_OOB_EI_EN                = "FALSE",   // SATA 模式带外电气空闲使能
    parameter         PMA_CH1_REG_TX_OOB_EI_EN_OW             = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH1_REG_TX_BEACON_EN_DELAYED        = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH1_REG_TX_BEACON_EN_DELAYED_OW     = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH1_REG_TX_JTAG_DATA                = "FALSE",   // 使能选项：开启或关闭。
    parameter integer PMA_CH1_REG_TX_RXDET_TIMER_SEL          = 87,        // 取值范围：0～255。
    parameter integer PMA_CH1_REG_TX_CFG1_7_0                 = 0,         // 取值范围：0～255。
    parameter integer PMA_CH1_REG_TX_CFG1_15_8                = 0,         // 取值范围：0～255。
    parameter integer PMA_CH1_REG_TX_CFG1_23_16               = 0,         // 取值范围：0～255。
    parameter integer PMA_CH1_REG_TX_CFG1_31_24               = 0,         // 取值范围：0～255。
    parameter         PMA_CH1_REG_CFG_LANE_POWERUP            = "ON",      // PMA 通道上电控制
    parameter         PMA_CH1_REG_CFG_TX_LANE_POWERUP_CLKPATH = "TRUE",    // PMA 发送通道时钟路径上电控制
    parameter         PMA_CH1_REG_CFG_TX_LANE_POWERUP_PISO    = "TRUE",    // PMA 发送并串转换单元上电控制
    parameter         PMA_CH1_REG_CFG_TX_LANE_POWERUP_DRIVER  = "TRUE",    // PMA 发送驱动器上电控制
    // 通道 2 参数
    parameter integer CH2_MUX_BIAS                            = 2,         // 取值范围：0～7，不支持仿真。
    parameter integer CH2_PD_CLK                              = 0,         // 取值范围：0～1。
    parameter integer CH2_REG_SYNC                            = 0,         // 取值范围：0～1。
    parameter integer CH2_REG_SYNC_OW                         = 0,         // 取值范围：0～1。
    parameter integer CH2_PLL_LOCK_OW                         = 0,         // 取值范围：0～1。
    parameter integer CH2_PLL_LOCK_OW_EN                      = 0,         // 取值范围：0～1。

    parameter integer PCS_CH2_SLAVE = 0,  // 时钟配置由用户指定，软件仅检查对应的时钟连线。
    parameter PCS_CH2_BYPASS_WORD_ALIGN = "FALSE",  // 字对齐旁路使能
    parameter PCS_CH2_BYPASS_DENC = "FALSE",  // 8b/10b 解码旁路使能
    parameter PCS_CH2_BYPASS_BONDING = "FALSE",  // 通道绑定旁路使能
    parameter PCS_CH2_BYPASS_CTC = "FALSE",  // 时钟补偿旁路使能
    parameter PCS_CH2_BYPASS_GEAR = "FALSE",  // 接收齿轮箱旁路使能
    parameter PCS_CH2_BYPASS_BRIDGE = "FALSE",  // 接收桥接单元旁路使能
    parameter PCS_CH2_BYPASS_BRIDGE_FIFO = "FALSE",  // 接收桥接 FIFO 旁路使能
    parameter PCS_CH2_DATA_MODE = "X8",  // 参数选项："X8","X10","X16","X20"
    parameter               PCS_CH2_RX_POLARITY_INV = "DELAY"                     ,// 数据变换：延迟、位极性反转、位序反转或两者同时反转。
    parameter PCS_CH2_ALIGN_MODE = "1GB",  // 协议模式：1GB、10GB、RAPIDIO 或外部模式。
    parameter PCS_CH2_SAMP_16B = "X20",  // 参数选项："X20",X16
    parameter PCS_CH2_FARLP_PWR_REDUCTION = "FALSE",  // 使能选项：开启或关闭。
    parameter integer PCS_CH2_COMMA_REG0 = 0,  // 取值范围：0～1023。
    parameter integer PCS_CH2_COMMA_MASK = 0,  // 取值范围：0～1023。
    parameter PCS_CH2_CEB_MODE = "10GB",  // 协议模式：10GB、RAPIDIO 或外部模式。
    parameter PCS_CH2_CTC_MODE = "1SKIP",  // 跳过字符模式：单字符、双字符、PCIe 双字节或四字符。
    parameter integer PCS_CH2_A_REG = 0,  // 取值范围：0～255。
    parameter PCS_CH2_GE_AUTO_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter integer PCS_CH2_SKIP_REG0 = 0,  // 取值范围：0～1023。
    parameter integer PCS_CH2_SKIP_REG1 = 0,  // 取值范围：0～1023。
    parameter integer PCS_CH2_SKIP_REG2 = 0,  // 取值范围：0～1023。
    parameter integer PCS_CH2_SKIP_REG3 = 0,  // 取值范围：0～1023。
    parameter PCS_CH2_DEC_DUAL = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH2_SPLIT = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH2_FIFOFLAG_CTC = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH2_COMMA_DET_MODE = "COMMA_PATTERN",  // 参数选项："RX_CLK_SLIP" "COMMA_PATTERN"
    parameter PCS_CH2_ERRDETECT_SILENCE = "TRUE",  // 使能选项：开启或关闭。
    parameter PCS_CH2_PMA_RCLK_POLINV = "PMA_RCLK",  // 参数选项："PMA_RCLK" "REVERSE_OF_PMA_RCLK"
    parameter PCS_CH2_PCS_RCLK_SEL = "PMA_RCLK",  // 参数选项："PMA_RCLK" "PMA_TCLK" "RCLK"
    parameter PCS_CH2_CB_RCLK_SEL = "PMA_RCLK",  // 参数选项："PMA_RCLK" "PMA_TCLK" "MCB_RCLK"
    parameter PCS_CH2_AFTER_CTC_RCLK_SEL = "PMA_RCLK",  // 参数选项："PMA_RCLK" "PMA_TCLK" "MCB_RCLK" "RCLK2"
    parameter PCS_CH2_RCLK_POLINV = "RCLK",  // 参数选项："RCLK" "REVERSE_OF_RCLK"
    parameter PCS_CH2_BRIDGE_RCLK_SEL = "PMA_RCLK",  // 参数选项："PMA_RCLK" "PMA_TCLK" "MCB_RCLK" "RCLK"
    parameter PCS_CH2_PCS_RCLK_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH2_CB_RCLK_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH2_AFTER_CTC_RCLK_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH2_AFTER_CTC_RCLK_EN_GB = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH2_PCS_RX_RSTN = "TRUE",  // PCS 接收端复位控制
    parameter PCS_CH2_PCIE_SLAVE = "MASTER",  // 通道角色：主通道或从通道。
    parameter PCS_CH2_RX_64B66B_67B = "NORMAL",  // 编码模式：普通、64b/66b 或 64b/67b。
    parameter               PCS_CH2_RX_BRIDGE_CLK_POLINV = "RX_BRIDGE_CLK"        ,// 参数选项："RX_BRIDGE_CLK" "REVERSE_OF_RX_BRIDGE_CLK"
    parameter PCS_CH2_PCS_CB_RSTN = "TRUE",  // PCS 通道绑定复位控制
    parameter               PCS_CH2_TX_BRIDGE_GEAR_SEL = "FALSE"                  ,// TRUE 优先使用发送齿轮箱，FALSE 优先使用发送桥接单元。
    parameter PCS_CH2_TX_BYPASS_BRIDGE_UINT = "FALSE",  // 旁路使能
    parameter PCS_CH2_TX_BYPASS_BRIDGE_FIFO = "FALSE",  // 发送桥接 FIFO 旁路使能
    parameter PCS_CH2_TX_BYPASS_GEAR = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH2_TX_BYPASS_ENC = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH2_TX_BYPASS_BIT_SLIP = "TRUE",  // 使能选项：开启或关闭。
    parameter PCS_CH2_TX_GEAR_SPLIT = "TRUE",  // 使能选项：开启或关闭。
    parameter               PCS_CH2_TX_DRIVE_REG_MODE = "NO_CHANGE"               ,// 变换选项：不变、极性反转、位序反转或两者同时反转。
    parameter integer PCS_CH2_TX_BIT_SLIP_CYCLES = 0,  // 取值范围：0～31。
    parameter PCS_CH2_INT_TX_MASK_0 = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH2_INT_TX_MASK_1 = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH2_INT_TX_MASK_2 = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH2_INT_TX_CLR_0 = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH2_INT_TX_CLR_1 = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH2_INT_TX_CLR_2 = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH2_TX_PMA_TCLK_POLINV = "PMA_TCLK",  // 参数选项："PMA_TCLK" "REVERSE_OF_PMA_TCLK"
    parameter PCS_CH2_TX_PCS_CLK_EN_SEL = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH2_TX_BRIDGE_TCLK_SEL = "TCLK",  // 参数选项："PCS_TCLK" "TCLK"
    parameter PCS_CH2_TX_TCLK_POLINV = "TCLK",  // 参数选项："TCLK" "REVERSE_OF_TCLK"
    parameter PCS_CH2_PCS_TCLK_SEL = "PMA_TCLK",  // 参数选项："PMA_TCLK" "TCLK"
    parameter PCS_CH2_TX_PCS_TX_RSTN = "TRUE",  // PCS 发送端复位控制
    parameter PCS_CH2_TX_SLAVE = "MASTER",  // 通道角色：主通道或从通道。
    parameter PCS_CH2_TX_GEAR_CLK_EN_SEL = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH2_DATA_WIDTH_MODE = "X20",  // 参数选项："X8" "X10" "X16" "X20"
    parameter PCS_CH2_TX_64B66B_67B = "NORMAL",  // 编码模式：普通、64b/66b 或 64b/67b。
    parameter PCS_CH2_GEAR_TCLK_SEL = "PMA_TCLK",  // 参数选项："PMA_TCLK" "TCLK2"
    parameter PCS_CH2_TX_TCLK2FABRIC_SEL = "TRUE",  // 使能选项：开启或关闭。
    parameter PCS_CH2_TX_OUTZZ = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH2_ENC_DUAL = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH2_TX_BITSLIP_DATA_MODE = "X10",  // 参数选项："X10" "X20"
    parameter               PCS_CH2_TX_BRIDGE_CLK_POLINV = "TX_BRIDGE_CLK"        ,// 参数选项："TX_BRIDGE_CLK" "REVERSE_OF_TX_BRIDGE_CLK"
    parameter integer PCS_CH2_COMMA_REG1 = 0,  // 取值范围：0～1023。
    parameter integer PCS_CH2_RAPID_IMAX = 0,  // 取值范围：0～7。
    parameter integer PCS_CH2_RAPID_VMIN_1 = 0,  // 取值范围：0～255。
    parameter integer PCS_CH2_RAPID_VMIN_2 = 0,  // 取值范围：0～255。
    parameter PCS_CH2_RX_PRBS_MODE = "DISABLE",  // PRBS 配置：关闭或选择 7、15、23、31 阶多项式。
    parameter PCS_CH2_RX_ERRCNT_CLR = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH2_PRBS_ERR_LPBK = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH2_TX_PRBS_MODE = "DISABLE",  // 测试码型：PRBS、长 1、长 0、20 UI、D10.2 或 PCIe。
    parameter PCS_CH2_TX_INSERT_ER = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH2_ENABLE_PRBS_GEN = "FALSE",  // 使能选项：开启或关闭。
    parameter integer PCS_CH2_DEFAULT_RADDR = 6,  // 取值范围：0～15。
    parameter integer PCS_CH2_MASTER_CHECK_OFFSET = 0,  // 取值范围：0～15。
    parameter integer PCS_CH2_DELAY_SET = 0,  // 取值范围：0～15。
    parameter PCS_CH2_SEACH_OFFSET = "20BIT",  // 绑定位宽：20～80 位，间隔 10 位。
    parameter integer PCS_CH2_CEB_RAPIDLS_MMAX = 0,  // 取值范围：0～7。
    parameter integer PCS_CH2_CTC_AFULL = 20,  // 取值范围：0～31。
    parameter integer PCS_CH2_CTC_AEMPTY = 12,  // 取值范围：0～31。
    parameter integer PCS_CH2_CTC_CONTI_SKP_SET = 0,  // 取值范围：0～1。
    parameter PCS_CH2_FAR_LOOP = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH2_NEAR_LOOP = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH2_PMA_TX2RX_PLOOP_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH2_PMA_TX2RX_SLOOP_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH2_PMA_RX2TX_PLOOP_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH2_INT_RX_MASK_0 = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH2_INT_RX_MASK_1 = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH2_INT_RX_MASK_2 = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH2_INT_RX_MASK_3 = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH2_INT_RX_MASK_4 = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH2_INT_RX_MASK_5 = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH2_INT_RX_MASK_6 = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH2_INT_RX_MASK_7 = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH2_INT_RX_CLR_0 = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH2_INT_RX_CLR_1 = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH2_INT_RX_CLR_2 = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH2_INT_RX_CLR_3 = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH2_INT_RX_CLR_4 = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH2_INT_RX_CLR_5 = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH2_INT_RX_CLR_6 = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH2_INT_RX_CLR_7 = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH2_CA_RSTN_RX = "FALSE",  // 接收时钟对齐器复位控制
    parameter PCS_CH2_CA_DYN_DLY_EN_RX = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH2_CA_DYN_DLY_SEL_RX = "FALSE",  // 使能选项：开启或关闭。
    parameter integer PCS_CH2_CA_RX = 0,  // 取值范围：0～255。
    parameter PCS_CH2_CA_RSTN_TX = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH2_CA_DYN_DLY_EN_TX = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH2_CA_DYN_DLY_SEL_TX = "FALSE",  // 使能选项：开启或关闭。
    parameter integer PCS_CH2_CA_TX = 0,  // 取值范围：0～255。
    parameter PCS_CH2_RXPRBS_PWR_REDUCTION = "NORMAL",  // 工作模式：普通或低功耗。
    parameter PCS_CH2_WDALIGN_PWR_REDUCTION = "NORMAL",  // 工作模式：普通或低功耗。
    parameter PCS_CH2_RXDEC_PWR_REDUCTION = "NORMAL",  // 工作模式：普通或低功耗。
    parameter PCS_CH2_RXCB_PWR_REDUCTION = "NORMAL",  // 工作模式：普通或低功耗。
    parameter PCS_CH2_RXCTC_PWR_REDUCTION = "NORMAL",  // 工作模式：普通或低功耗。
    parameter PCS_CH2_RXGEAR_PWR_REDUCTION = "NORMAL",  // 工作模式：普通或低功耗。
    parameter PCS_CH2_RXBRG_PWR_REDUCTION = "NORMAL",  // 工作模式：普通或低功耗。
    parameter PCS_CH2_RXTEST_PWR_REDUCTION = "NORMAL",  // 工作模式：普通或低功耗。
    parameter PCS_CH2_TXBRG_PWR_REDUCTION = "NORMAL",  // 工作模式：普通或低功耗。
    parameter PCS_CH2_TXGEAR_PWR_REDUCTION = "NORMAL",  // 工作模式：普通或低功耗。
    parameter PCS_CH2_TXENC_PWR_REDUCTION = "NORMAL",  // 工作模式：普通或低功耗。
    parameter PCS_CH2_TXBSLP_PWR_REDUCTION = "NORMAL",  // 工作模式：普通或低功耗。
    parameter PCS_CH2_TXPRBS_PWR_REDUCTION = "NORMAL",  // 工作模式：普通或低功耗。

    parameter PMA_CH2_REG_RX_PD = "ON",  // 使能选项：开启或关闭。
    parameter PMA_CH2_REG_RX_PD_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH2_REG_RX_RESERVED_2 = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH2_REG_RX_RESERVED_3 = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH2_REG_RX_DATAPATH_PD = "ON",  // 使能选项：开启或关闭。
    parameter PMA_CH2_REG_RX_DATAPATH_PD_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH2_REG_RX_SIGDET_PD = "ON",  // 使能选项：开启或关闭。
    parameter PMA_CH2_REG_RX_SIGDET_PD_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH2_REG_RX_DCC_RST_N = "TRUE",  // 使能选项：开启或关闭。
    parameter PMA_CH2_REG_RX_DCC_RST_N_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH2_REG_RX_CDR_RST_N = "TRUE",  // 使能选项：开启或关闭。
    parameter PMA_CH2_REG_RX_CDR_RST_N_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH2_REG_RX_SIGDET_RST_N = "TRUE",  // 使能选项：开启或关闭。
    parameter PMA_CH2_REG_RX_SIGDET_RST_N_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH2_REG_RXPCLK_SLIP = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH2_REG_RXPCLK_SLIP_OW = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH2_REG_RX_PCLKSWITCH_RST_N = "TRUE",  // 发送 PMA 复位控制
    parameter PMA_CH2_REG_RX_PCLKSWITCH_RST_N_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH2_REG_RX_PCLKSWITCH = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH2_REG_RX_PCLKSWITCH_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH2_REG_RX_HIGHZ = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH2_REG_RX_HIGHZ_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH2_REG_RX_SIGDET_CLK_WINDOW = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH2_REG_RX_SIGDET_CLK_WINDOW_OW = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH2_REG_RX_PD_BIAS_RX = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH2_REG_RX_PD_BIAS_RX_OW = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH2_REG_RX_RESET_N = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH2_REG_RX_RESET_N_OW = "FALSE",  // 使能选项：开启或关闭。
    parameter integer PMA_CH2_REG_RX_RESERVED_29_28 = 0,  // 取值范围：0～3。
    parameter PMA_CH2_REG_RX_BUSWIDTH = "20BIT",  // 位宽选项：8、10、16 或 20 位。
    parameter PMA_CH2_REG_RX_BUSWIDTH_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH2_REG_RX_RATE = "DIV1",  // 时钟倍率：四分频、二分频、原频或二倍频。
    parameter PMA_CH2_REG_RX_RESERVED_36 = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH2_REG_RX_RATE_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter integer PMA_CH2_REG_RX_RES_TRIM = 46,  // 取值范围：0～63。
    parameter PMA_CH2_REG_RX_RESERVED_44 = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH2_REG_RX_RESERVED_45 = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH2_REG_RX_SIGDET_STATUS_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter integer PMA_CH2_REG_RX_RESERVED_48_47 = 0,  // 取值范围：0～3。
    parameter integer PMA_CH2_REG_RX_ICTRL_SIGDET = 5,  // 取值范围：0～15。
    parameter integer PMA_CH2_REG_CDR_READY_THD = 2734,  // 取值范围：0～4095。
    parameter PMA_CH2_REG_RX_RESERVED_65 = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH2_REG_RX_PCLK_EDGE_SEL = "POS_EDGE",  // 时钟边沿：上升沿或下降沿。
    parameter integer PMA_CH2_REG_RX_PIBUF_IC = 1,  // 取值范围：0～3。
    parameter PMA_CH2_REG_RX_RESERVED_69 = "FALSE",  // 使能选项：开启或关闭。
    parameter integer PMA_CH2_REG_RX_DCC_IC_RX = 1,  // 取值范围：0～3。
    parameter integer PMA_CH2_REG_CDR_READY_CHECK_CTRL = 0,  // 取值范围：0～3。
    parameter PMA_CH2_REG_RX_ICTRL_TRX = "100PCT",  // 比例选项：87.5%、100%、112.5%、125%。
    parameter integer PMA_CH2_REG_RX_RESERVED_77_76 = 0,  // 取值范围：0～3。
    parameter integer PMA_CH2_REG_RX_RESERVED_79_78 = 1,  // 取值范围：0～3。
    parameter integer PMA_CH2_REG_RX_RESERVED_81_80 = 1,  // 取值范围：0～3。
    parameter PMA_CH2_REG_RX_ICTRL_PIBUF = "100PCT",  // 比例选项：87.5%、100%、112.5%、125%。
    parameter PMA_CH2_REG_RX_ICTRL_PI = "100PCT",  // 比例选项：87.5%、100%、112.5%、125%。
    parameter PMA_CH2_REG_RX_ICTRL_DCC = "100PCT",  // 比例选项：87.5%、100%、112.5%、125%。
    parameter integer PMA_CH2_REG_RX_RESERVED_89_88 = 1,  // 取值范围：0～3。
    parameter PMA_CH2_REG_TX_RATE = "DIV1",  // 时钟倍率：四分频、二分频、原频或二倍频。
    parameter PMA_CH2_REG_RX_RESERVED_92 = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH2_REG_TX_RATE_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH2_REG_RX_TX2RX_PLPBK_RST_N = "TRUE",  // PMA 发送到接收并行环回复位控制
    parameter PMA_CH2_REG_RX_TX2RX_PLPBK_RST_N_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH2_REG_RX_TX2RX_PLPBK_EN = "FALSE",  // PMA 发送到接收并行环回使能
    parameter PMA_CH2_REG_TXCLK_SEL = "PLL",  // 时钟来源：PLL 或接收时钟。
    parameter PMA_CH2_REG_RX_DATA_POLARITY = "NORMAL",  // 极性选项：正常或反转。
    parameter PMA_CH2_REG_RX_ERR_INSERT = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH2_REG_UDP_CHK_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH2_REG_PRBS_SEL = "PRBS7",  // PRBS 多项式阶数：7、15、23、31。
    parameter PMA_CH2_REG_PRBS_CHK_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH2_REG_PRBS_CHK_WIDTH_SEL = "20BIT",  // 位宽选项：8、10、16 或 20 位。
    parameter PMA_CH2_REG_BIST_CHK_PAT_SEL = "PRBS",  // 码型来源：PRBS 或常量。
    parameter PMA_CH2_REG_LOAD_ERR_CNT = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH2_REG_CHK_COUNTER_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter integer PMA_CH2_REG_CDR_PROP_GAIN = 7,  // 取值范围：0～7。
    parameter integer PMA_CH2_REG_CDR_PROP_TURBO_GAIN = 5,  // 取值范围：0～7。
    parameter integer PMA_CH2_REG_CDR_INT_GAIN = 4,  // 取值范围：0～7。
    parameter integer PMA_CH2_REG_CDR_INT_TURBO_GAIN = 5,  // 取值范围：0～7。
    parameter integer PMA_CH2_REG_CDR_INT_SAT_MAX = 768,  // 取值范围：0～1023。
    parameter integer PMA_CH2_REG_CDR_INT_SAT_MIN = 255,  // 取值范围：0～1023。
    parameter PMA_CH2_REG_CDR_INT_RST = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH2_REG_CDR_INT_RST_OW = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH2_REG_CDR_PROP_RST = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH2_REG_CDR_PROP_RST_OW = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH2_REG_CDR_LOCK_RST = "FALSE",  // CDR 锁定计数器复位控制
    parameter PMA_CH2_REG_CDR_LOCK_RST_OW = "FALSE",  // 使能选项：开启或关闭。
    parameter integer PMA_CH2_REG_CDR_RX_PI_FORCE_SEL = 0,  //0,1
    parameter integer PMA_CH2_REG_CDR_RX_PI_FORCE_D = 0,  // 取值范围：0～255。
    parameter               PMA_CH2_REG_CDR_LOCK_TIMER = "1_2U"                   ,// 参数选项："0_8U" "1_2U" "1_6U" "2_4U" 3_2U" "4_8U" "12_8U" "25_6U"
    parameter integer PMA_CH2_REG_CDR_TURBO_MODE_TIMER = 1,  // 取值范围：0～3。
    parameter PMA_CH2_REG_CDR_LOCK_VAL = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH2_REG_CDR_LOCK_OW = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH2_REG_CDR_INT_SAT_DET_EN = "TRUE",  // 使能选项：开启或关闭。
    parameter PMA_CH2_REG_CDR_SAT_AUTO_DIS = "TRUE",  // 使能选项：开启或关闭。
    parameter PMA_CH2_REG_CDR_GAIN_AUTO = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH2_REG_CDR_TURBO_GAIN_AUTO = "FALSE",  // 使能选项：开启或关闭。
    parameter integer PMA_CH2_REG_RX_RESERVED_171_167 = 0,  // 取值范围：0～31。
    parameter integer PMA_CH2_REG_RX_RESERVED_175_172 = 0,  // 取值范围：0～31。
    parameter PMA_CH2_REG_CDR_SAT_DET_STATUS_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH2_REG_CDR_SAT_DET_STATUS_RESET_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH2_REG_CDR_PI_CTRL_RST = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH2_REG_CDR_PI_CTRL_RST_OW = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH2_REG_CDR_SAT_DET_RST = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH2_REG_CDR_SAT_DET_RST_OW = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH2_REG_CDR_SAT_DET_STICKY_RST = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH2_REG_CDR_SAT_DET_STICKY_RST_OW = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH2_REG_CDR_SIGDET_STATUS_DIS = "FALSE",  // 无信号检测状态时复位 CDR。
    parameter integer PMA_CH2_REG_CDR_SAT_DET_TIMER = 2,  // 取值范围：0～3。
    parameter PMA_CH2_REG_CDR_SAT_DET_STATUS_VAL = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH2_REG_CDR_SAT_DET_STATUS_OW = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH2_REG_CDR_TURBO_MODE_EN = "TRUE",  // 使能选项：开启或关闭。
    parameter PMA_CH2_REG_RX_RESERVED_190 = "FALSE",  // 使能选项：开启或关闭。
    parameter integer PMA_CH2_REG_RX_RESERVED_193_191 = 0,  // 取值范围：0～7。
    parameter PMA_CH2_REG_CDR_STATUS_FIFO_EN = "TRUE",  // 使能选项：开启或关闭。
    parameter integer PMA_CH2_REG_PMA_TEST_SEL = 0,  //0,1
    parameter integer PMA_CH2_REG_OOB_COMWAKE_GAP_MIN = 3,  // 取值范围：0～63。
    parameter integer PMA_CH2_REG_OOB_COMWAKE_GAP_MAX = 11,  // 取值范围：0～63。
    parameter integer PMA_CH2_REG_OOB_COMINIT_GAP_MIN = 15,  // 取值范围：0～255。
    parameter integer PMA_CH2_REG_OOB_COMINIT_GAP_MAX = 35,  // 取值范围：0～255。
    parameter integer PMA_CH2_REG_RX_RESERVED_227_226 = 1,  // 取值范围：0～3。
    parameter integer PMA_CH2_REG_COMWAKE_STATUS_CLEAR = 0,  //0,1
    parameter integer PMA_CH2_REG_COMINIT_STATUS_CLEAR = 0,  //0,1
    parameter PMA_CH2_REG_RX_SYNC_RST_N_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH2_REG_RX_SYNC_RST_N = "TRUE",  // 使能选项：开启或关闭。
    parameter integer PMA_CH2_REG_RX_RESERVED_233_232 = 0,  // 取值范围：0～3。
    parameter integer PMA_CH2_REG_RX_RESERVED_235_234 = 0,  // 取值范围：0～3。
    parameter PMA_CH2_REG_RX_SATA_COMINIT_OW = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH2_REG_RX_SATA_COMINIT = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH2_REG_RX_SATA_COMWAKE_OW = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH2_REG_RX_SATA_COMWAKE = "FALSE",  // 使能选项：开启或关闭。
    parameter integer PMA_CH2_REG_RX_RESERVED_241_240 = 0,  // 取值范围：0～3。
    parameter PMA_CH2_REG_RX_DCC_DISABLE = "FALSE",  // 接收占空比校正禁用控制
    parameter PMA_CH2_REG_RX_RESERVED_243 = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH2_REG_RX_SLIP_SEL_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter integer PMA_CH2_REG_RX_SLIP_SEL = 0,  // 取值范围：0～15。
    parameter PMA_CH2_REG_RX_SLIP_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter integer PMA_CH2_REG_RX_SIGDET_STATUS_SEL = 5,  // 取值范围：0～7。
    parameter PMA_CH2_REG_RX_SIGDET_FSM_RST_N = "TRUE",  // 使能选项：开启或关闭。
    parameter PMA_CH2_REG_RX_RESERVED_254 = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH2_REG_RX_SIGDET_STATUS = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH2_REG_RX_SIGDET_VTH = "72MV",  // 检测电压：45、54、63、72 mV。
    parameter integer PMA_CH2_REG_RX_SIGDET_GRM = 0,  //0,1,2,3
    parameter PMA_CH2_REG_RX_SIGDET_PULSE_EXT = "FALSE",  // 使能选项：开启或关闭。
    parameter integer PMA_CH2_REG_RX_SIGDET_CH2_SEL = 0,  //0,1
    parameter integer PMA_CH2_REG_RX_SIGDET_CH2_CHK_WINDOW = 3,  // 取值范围：0～31。
    parameter PMA_CH2_REG_RX_SIGDET_CHK_WINDOW_EN = "TRUE",  // 使能选项：开启或关闭。
    parameter integer PMA_CH2_REG_RX_SIGDET_NOSIG_COUNT_SETTING = 4,  // 取值范围：0～7。
    parameter PMA_CH2_REG_SLIP_FIFO_INV_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH2_REG_SLIP_FIFO_INV = "POS_EDGE",  // 时钟边沿：上升沿或下降沿。
    parameter integer PMA_CH2_REG_RX_SIGDET_OOB_DET_COUNT_VAL = 0,  // 取值范围：0～31。
    parameter integer PMA_CH2_REG_RX_SIGDET_4OOB_DET_SEL = 7,  // 取值范围：0～7。
    parameter integer PMA_CH2_REG_RX_RESERVED_285_283 = 0,  // 取值范围：0～7。
    parameter PMA_CH2_REG_RX_RESERVED_286 = "FALSE",  // 使能选项：开启或关闭。
    parameter integer PMA_CH2_REG_RX_SIGDET_IC_I = 10,  // 取值范围：0～15。
    parameter PMA_CH2_REG_RX_OOB_DETECTOR_RESET_N_OW = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH2_REG_RX_OOB_DETECTOR_RESET_N = "FALSE",  // 接收带外检测器复位控制
    parameter PMA_CH2_REG_RX_OOB_DETECTOR_PD_OW = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH2_REG_RX_OOB_DETECTOR_PD = "ON",  // 接收带外检测器掉电控制
    parameter PMA_CH2_REG_RX_LS_MODE_EN = "FALSE",  // 低速模式使能
    parameter PMA_CH2_REG_ANA_RX_EQ1_R_SET_FB_O_SEL = "TRUE",  // 使能选项：开启或关闭。
    parameter PMA_CH2_REG_ANA_RX_EQ2_R_SET_FB_O_SEL = "TRUE",  // 使能选项：开启或关闭。
    parameter integer PMA_CH2_REG_RX_EQ1_R_SET_TOP = 0,  // 取值范围：0～3。
    parameter integer PMA_CH2_REG_RX_EQ1_R_SET_FB = 15,  // 取值范围：0～15。
    parameter integer PMA_CH2_REG_RX_EQ1_C_SET_FB = 0,  // 取值范围：0～15。
    parameter PMA_CH2_REG_RX_EQ1_OFF = "FALSE",  // 使能选项：开启或关闭。
    parameter integer PMA_CH2_REG_RX_EQ2_R_SET_TOP = 0,  // 取值范围：0～3。
    parameter integer PMA_CH2_REG_RX_EQ2_R_SET_FB = 0,  // 取值范围：0～15。
    parameter integer PMA_CH2_REG_RX_EQ2_C_SET_FB = 0,  // 取值范围：0～15。
    parameter PMA_CH2_REG_RX_EQ2_OFF = "FALSE",  // 使能选项：开启或关闭。
    parameter integer PMA_CH2_REG_EQ_DAC = 0,  // 取值范围：0～63。
    parameter integer PMA_CH2_REG_RX_ICTRL_EQ = 2,  // 使能选项：开启或关闭。
    parameter PMA_CH2_REG_EQ_DC_CALIB_EN = "TRUE",  // 使能选项：开启或关闭。
    parameter PMA_CH2_REG_EQ_DC_CALIB_SEL = "FALSE",  // 使能选项：开启或关闭。
    parameter integer PMA_CH2_REG_RX_RESERVED_337_330 = 0,  // 取值范围：0～255。
    parameter integer PMA_CH2_REG_RX_RESERVED_345_338 = 0,  // 取值范围：0～255。
    parameter integer PMA_CH2_REG_RX_RESERVED_353_346 = 0,  // 取值范围：0～255。
    parameter integer PMA_CH2_REG_RX_RESERVED_361_354 = 0,  // 取值范围：0～255。
    parameter integer PMA_CH2_CTLE_CTRL_REG_I = 0,  // 取值范围：0～15。
    parameter PMA_CH2_CTLE_REG_FORCE_SEL_I = "FALSE",  // 自适应调整控制
    parameter PMA_CH2_CTLE_REG_HOLD_I = "FALSE",  // 使能选项：开启或关闭。
    parameter integer PMA_CH2_CTLE_REG_INIT_DAC_I = 0,  // 取值范围：0～15。
    parameter PMA_CH2_CTLE_REG_POLARITY_I = "FALSE",  // 使能选项：开启或关闭。
    parameter integer PMA_CH2_CTLE_REG_SHIFTER_GAIN_I = 1,  // 取值范围：0～7。
    parameter integer PMA_CH2_CTLE_REG_THRESHOLD_I = 3072,  // 取值范围：0～4095。
    parameter PMA_CH2_REG_RX_RES_TRIM_EN = "TRUE",  // 使能选项：开启或关闭。
    parameter integer PMA_CH2_REG_RX_RESERVED_393_389 = 0,  // 取值范围：0～31。
    parameter PMA_CH2_CFG_RX_LANE_POWERUP = "ON",  // 接收通道上电控制
    parameter PMA_CH2_CFG_RX_PMA_RSTN = "TRUE",  // 接收 PMA 复位控制
    parameter PMA_CH2_INT_PMA_RX_MASK_0 = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH2_INT_PMA_RX_CLR_0 = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH2_CFG_CTLE_ADP_RSTN = "TRUE",  // 控制逻辑复位

    parameter         PMA_CH2_REG_TX_PD                       = "ON",      // 发送端掉电控制
    parameter         PMA_CH2_REG_TX_PD_OW                    = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH2_REG_TX_MAIN_PRE_Z               = "FALSE",   // PCIe 模式电气空闲使能
    parameter         PMA_CH2_REG_TX_MAIN_PRE_Z_OW            = "FALSE",   // 使能选项：开启或关闭。
    parameter integer PMA_CH2_REG_TX_BEACON_TIMER_SEL         = 0,         // 取值范围：0～3。
    parameter         PMA_CH2_REG_TX_RXDET_REQ_OW             = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH2_REG_TX_RXDET_REQ                = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH2_REG_TX_BEACON_EN_OW             = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH2_REG_TX_BEACON_EN                = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH2_REG_TX_EI_EN_OW                 = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH2_REG_TX_EI_EN                    = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH2_REG_TX_BIT_CONV                 = "FALSE",   // 使能选项：开启或关闭。
    parameter integer PMA_CH2_REG_TX_RES_CAL                  = 48,        // 取值范围：0～63。
    parameter         PMA_CH2_REG_TX_RESERVED_19              = "FALSE",   // 使能选项：开启或关闭。
    parameter integer PMA_CH2_REG_TX_RESERVED_25_20           = 32,        // 取值范围：0～63。
    parameter integer PMA_CH2_REG_TX_RESERVED_33_26           = 0,         // 取值范围：0～255。
    parameter integer PMA_CH2_REG_TX_RESERVED_41_34           = 0,         // 取值范围：0～255。
    parameter integer PMA_CH2_REG_TX_RESERVED_49_42           = 0,         // 取值范围：0～255。
    parameter integer PMA_CH2_REG_TX_RESERVED_57_50           = 0,         // 取值范围：0～255。
    parameter         PMA_CH2_REG_TX_SYNC_OW                  = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH2_REG_TX_SYNC                     = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH2_REG_TX_PD_POST                  = "OFF",     // 使能选项：开启或关闭。
    parameter         PMA_CH2_REG_TX_PD_POST_OW               = "TRUE",    // 使能选项：开启或关闭。
    parameter         PMA_CH2_REG_TX_RESET_N_OW               = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH2_REG_TX_RESET_N                  = "TRUE",    // 使能选项：开启或关闭。
    parameter         PMA_CH2_REG_TX_RESERVED_64              = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH2_REG_TX_RESERVED_65              = "TRUE",    // 使能选项：开启或关闭。
    parameter         PMA_CH2_REG_TX_BUSWIDTH_OW              = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH2_REG_TX_BUSWIDTH                 = "20BIT",   // 位宽选项：8、10、16 或 20 位。
    parameter         PMA_CH2_REG_PLL_READY_OW                = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH2_REG_PLL_READY                   = "TRUE",    // 使能选项：开启或关闭。
    parameter         PMA_CH2_REG_TX_RESERVED_72              = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH2_REG_TX_RESERVED_73              = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH2_REG_TX_RESERVED_74              = "FALSE",   // 使能选项：开启或关闭。
    parameter integer PMA_CH2_REG_EI_PCLK_DELAY_SEL           = 0,         // 取值范围：0～3。
    parameter         PMA_CH2_REG_TX_RESERVED_77              = "FALSE",   // 使能选项：开启或关闭。
    parameter integer PMA_CH2_REG_TX_RESERVED_83_78           = 0,         // 取值范围：0～63。
    parameter integer PMA_CH2_REG_TX_RESERVED_89_84           = 0,         // 取值范围：0～63。
    parameter integer PMA_CH2_REG_TX_RESERVED_95_90           = 0,         // 取值范围：0～63。
    parameter integer PMA_CH2_REG_TX_RESERVED_101_96          = 0,         // 取值范围：0～63。
    parameter integer PMA_CH2_REG_TX_RESERVED_107_102         = 0,         // 取值范围：0～63。
    parameter integer PMA_CH2_REG_TX_RESERVED_113_108         = 0,         // 取值范围：0～63。
    parameter integer PMA_CH2_REG_TX_AMP_DAC0                 = 25,        // 取值范围：0～63。
    parameter integer PMA_CH2_REG_TX_AMP_DAC1                 = 19,        // 取值范围：0～63。
    parameter integer PMA_CH2_REG_TX_AMP_DAC2                 = 14,        // 取值范围：0～63。
    parameter integer PMA_CH2_REG_TX_AMP_DAC3                 = 9,         // 取值范围：0～63。
    parameter integer PMA_CH2_REG_TX_RESERVED_143_138         = 5,         // 取值范围：0～63。
    parameter integer PMA_CH2_REG_TX_MARGIN                   = 0,         // 取值范围：0～7。
    parameter         PMA_CH2_REG_TX_MARGIN_OW                = "FALSE",   // 使能选项：开启或关闭。
    parameter integer PMA_CH2_REG_TX_RESERVED_149_148         = 0,         // 取值范围：0～3。
    parameter         PMA_CH2_REG_TX_RESERVED_150             = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH2_REG_TX_SWING                    = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH2_REG_TX_SWING_OW                 = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH2_REG_TX_RESERVED_153             = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH2_REG_TX_RXDET_THRESHOLD          = "84MV",    // 电压选项：28、56、84、112 mV。
    parameter integer PMA_CH2_REG_TX_RESERVED_157_156         = 0,         // 取值范围：0～3。
    parameter         PMA_CH2_REG_TX_BEACON_OSC_CTRL          = "FALSE",   // 使能选项：开启或关闭。
    parameter integer PMA_CH2_REG_TX_RESERVED_160_159         = 0,         // 取值范围：0～3。
    parameter integer PMA_CH2_REG_TX_RESERVED_162_161         = 0,         // 取值范围：0～3。
    parameter         PMA_CH2_REG_TX_TX2RX_SLPBACK_EN         = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH2_REG_TX_PCLK_EDGE_SEL            = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH2_REG_TX_RXDET_STATUS_OW          = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH2_REG_TX_RXDET_STATUS             = "TRUE",    // 使能选项：开启或关闭。
    parameter         PMA_CH2_REG_TX_PRBS_GEN_EN              = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH2_REG_TX_PRBS_GEN_WIDTH_SEL       = "20BIT",   // 位宽选项：8、10、16 或 20 位。
    parameter         PMA_CH2_REG_TX_PRBS_SEL                 = "PRBS7",   // PRBS 多项式阶数：7、15、23、31。
    parameter integer PMA_CH2_REG_TX_UDP_DATA_7_TO_0          = 5,         // 取值范围：0～255。
    parameter integer PMA_CH2_REG_TX_UDP_DATA_15_TO_8         = 235,       // 取值范围：0～255。
    parameter integer PMA_CH2_REG_TX_UDP_DATA_19_TO_16        = 3,         // 取值范围：0～15。
    parameter         PMA_CH2_REG_TX_RESERVED_192             = "FALSE",   // 使能选项：开启或关闭。
    parameter integer PMA_CH2_REG_TX_FIFO_WP_CTRL             = 4,         // 取值范围：0～7。
    parameter         PMA_CH2_REG_TX_FIFO_EN                  = "FALSE",   // 使能选项：开启或关闭。
    parameter integer PMA_CH2_REG_TX_DATA_MUX_SEL             = 0,         // 取值范围：0～3。
    parameter         PMA_CH2_REG_TX_ERR_INSERT               = "FALSE",   // 使能选项：开启或关闭。
    parameter integer PMA_CH2_REG_TX_RESERVED_203_200         = 0,         // 取值范围：0～15。
    parameter         PMA_CH2_REG_TX_RESERVED_204             = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH2_REG_TX_SATA_EN                  = "FALSE",   // 使能选项：开启或关闭。
    parameter integer PMA_CH2_REG_TX_RESERVED_207_206         = 0,         // 取值范围：0～3。
    parameter         PMA_CH2_REG_RATE_CHANGE_TXPCLK_ON_OW    = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH2_REG_RATE_CHANGE_TXPCLK_ON       = "TRUE",    // 使能选项：开启或关闭。
    parameter integer PMA_CH2_REG_TX_CFG_POST1                = 0,         // 取值范围：0～31。
    parameter integer PMA_CH2_REG_TX_CFG_POST2                = 0,         // 取值范围：0～31。
    parameter integer PMA_CH2_REG_TX_DEEMP                    = 0,         // 取值范围：0～3。
    parameter         PMA_CH2_REG_TX_DEEMP_OW                 = "FALSE",   // 发送去加重控制
    parameter integer PMA_CH2_REG_TX_RESERVED_224_223         = 0,         // 取值范围：0～3。
    parameter         PMA_CH2_REG_TX_RESERVED_225             = "FALSE",   // 使能选项：开启或关闭。
    parameter integer PMA_CH2_REG_TX_RESERVED_229_226         = 0,         // 取值范围：0～15。
    parameter integer PMA_CH2_REG_TX_OOB_DELAY_SEL            = 0,         // 取值范围：0～15。
    parameter         PMA_CH2_REG_TX_POLARITY                 = "NORMAL",  // 极性选项：正常或反转。
    parameter         PMA_CH2_REG_ANA_TX_JTAG_DATA_O_SEL      = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH2_REG_TX_RESERVED_236             = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH2_REG_TX_LS_MODE_EN               = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH2_REG_TX_JTAG_MODE_EN_OW          = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH2_REG_TX_JTAG_MODE_EN             = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH2_REG_RX_JTAG_MODE_EN_OW          = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH2_REG_RX_JTAG_MODE_EN             = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH2_REG_RX_JTAG_OE                  = "TRUE",    // 使能选项：开启或关闭。
    parameter integer PMA_CH2_REG_RX_ACJTAG_VHYSTSEL          = 0,         // 取值范围：0～7。
    parameter         PMA_CH2_REG_TX_RES_CAL_EN               = "FALSE",   // 使能选项：开启或关闭。
    parameter integer PMA_CH2_REG_RX_TERM_MODE_CTRL           = 5,         // 接收终端控制范围：0～7。
    parameter integer PMA_CH2_REG_TX_RESERVED_251_250         = 0,         // 取值范围：0～7。
    parameter         PMA_CH2_REG_PLPBK_TXPCLK_EN             = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH2_REG_TX_RESERVED_253             = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH2_REG_TX_RESERVED_254             = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH2_REG_TX_RESERVED_255             = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH2_REG_TX_RESERVED_256             = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH2_REG_TX_RESERVED_257             = "FALSE",   // 使能选项：开启或关闭。
    parameter integer PMA_CH2_REG_TX_PH_SEL                   = 1,         // 取值范围：0～63。
    parameter integer PMA_CH2_REG_TX_CFG_PRE                  = 0,         // 取值范围：0～31。
    parameter integer PMA_CH2_REG_TX_CFG_MAIN                 = 0,         // 取值范围：0～63。
    parameter integer PMA_CH2_REG_CFG_POST                    = 0,         // 取值范围：0～31。
    parameter         PMA_CH2_REG_PD_MAIN                     = "TRUE",    // 使能选项：开启或关闭。
    parameter         PMA_CH2_REG_PD_PRE                      = "TRUE",    // 使能选项：开启或关闭。
    parameter         PMA_CH2_REG_TX_LS_DATA                  = "FALSE",   // 使能选项：开启或关闭。
    parameter integer PMA_CH2_REG_TX_DCC_BUF_SZ_SEL           = 0,         // 取值范围：0～3。
    parameter integer PMA_CH2_REG_TX_DCC_CAL_CUR_TUNE         = 0,         // 取值范围：0～63。
    parameter         PMA_CH2_REG_TX_DCC_CAL_EN               = "FALSE",   // 使能选项：开启或关闭。
    parameter integer PMA_CH2_REG_TX_DCC_CUR_SS               = 0,         // 取值范围：0～3。
    parameter         PMA_CH2_REG_TX_DCC_FA_CTRL              = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH2_REG_TX_DCC_RI_CTRL              = "FALSE",   // 使能选项：开启或关闭。
    parameter integer PMA_CH2_REG_ATB_SEL_2_TO_0              = 0,         // 取值范围：0～7。
    parameter integer PMA_CH2_REG_ATB_SEL_9_TO_3              = 0,         // 取值范围：0～127。
    parameter integer PMA_CH2_REG_TX_CFG_7_TO_0               = 0,         // 取值范围：0～255。
    parameter integer PMA_CH2_REG_TX_CFG_15_TO_8              = 0,         // 取值范围：0～255。
    parameter integer PMA_CH2_REG_TX_CFG_23_TO_16             = 0,         // 取值范围：0～255。
    parameter integer PMA_CH2_REG_TX_CFG_31_TO_24             = 128,       // 取值范围：0～255。
    parameter         PMA_CH2_REG_TX_OOB_EI_EN                = "FALSE",   // SATA 模式带外电气空闲使能
    parameter         PMA_CH2_REG_TX_OOB_EI_EN_OW             = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH2_REG_TX_BEACON_EN_DELAYED        = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH2_REG_TX_BEACON_EN_DELAYED_OW     = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH2_REG_TX_JTAG_DATA                = "FALSE",   // 使能选项：开启或关闭。
    parameter integer PMA_CH2_REG_TX_RXDET_TIMER_SEL          = 87,        // 取值范围：0～255。
    parameter integer PMA_CH2_REG_TX_CFG1_7_0                 = 0,         // 取值范围：0～255。
    parameter integer PMA_CH2_REG_TX_CFG1_15_8                = 0,         // 取值范围：0～255。
    parameter integer PMA_CH2_REG_TX_CFG1_23_16               = 0,         // 取值范围：0～255。
    parameter integer PMA_CH2_REG_TX_CFG1_31_24               = 0,         // 取值范围：0～255。
    parameter         PMA_CH2_REG_CFG_LANE_POWERUP            = "ON",      // PMA 通道上电控制
    parameter         PMA_CH2_REG_CFG_TX_LANE_POWERUP_CLKPATH = "TRUE",    // PMA 发送通道时钟路径上电控制
    parameter         PMA_CH2_REG_CFG_TX_LANE_POWERUP_PISO    = "TRUE",    // PMA 发送并串转换单元上电控制
    parameter         PMA_CH2_REG_CFG_TX_LANE_POWERUP_DRIVER  = "TRUE",    // PMA 发送驱动器上电控制
    // 通道 3 参数
    parameter integer CH3_MUX_BIAS                            = 2,         // 取值范围：0～7，不支持仿真。
    parameter integer CH3_PD_CLK                              = 0,         // 取值范围：0～1。
    parameter integer CH3_REG_SYNC                            = 0,         // 取值范围：0～1。
    parameter integer CH3_REG_SYNC_OW                         = 0,         // 取值范围：0～1。
    parameter integer CH3_PLL_LOCK_OW                         = 0,         // 取值范围：0～1。
    parameter integer CH3_PLL_LOCK_OW_EN                      = 0,         // 取值范围：0～1。

    parameter integer PCS_CH3_SLAVE = 0,  // 时钟配置由用户指定，软件仅检查对应的时钟连线。
    parameter PCS_CH3_BYPASS_WORD_ALIGN = "FALSE",  // 字对齐旁路使能
    parameter PCS_CH3_BYPASS_DENC = "FALSE",  // 8b/10b 解码旁路使能
    parameter PCS_CH3_BYPASS_BONDING = "FALSE",  // 通道绑定旁路使能
    parameter PCS_CH3_BYPASS_CTC = "FALSE",  // 时钟补偿旁路使能
    parameter PCS_CH3_BYPASS_GEAR = "FALSE",  // 接收齿轮箱旁路使能
    parameter PCS_CH3_BYPASS_BRIDGE = "FALSE",  // 接收桥接单元旁路使能
    parameter PCS_CH3_BYPASS_BRIDGE_FIFO = "FALSE",  // 接收桥接 FIFO 旁路使能
    parameter PCS_CH3_DATA_MODE = "X8",  // 参数选项："X8","X10","X16","X20"
    parameter               PCS_CH3_RX_POLARITY_INV = "DELAY"                     ,// 数据变换：延迟、位极性反转、位序反转或两者同时反转。
    parameter PCS_CH3_ALIGN_MODE = "1GB",  // 协议模式：1GB、10GB、RAPIDIO 或外部模式。
    parameter PCS_CH3_SAMP_16B = "X20",  // 参数选项："X20",X16
    parameter PCS_CH3_FARLP_PWR_REDUCTION = "FALSE",  // 使能选项：开启或关闭。
    parameter integer PCS_CH3_COMMA_REG0 = 0,  // 取值范围：0～1023。
    parameter integer PCS_CH3_COMMA_MASK = 0,  // 取值范围：0～1023。
    parameter PCS_CH3_CEB_MODE = "10GB",  // 协议模式：10GB、RAPIDIO 或外部模式。
    parameter PCS_CH3_CTC_MODE = "1SKIP",  // 跳过字符模式：单字符、双字符、PCIe 双字节或四字符。
    parameter integer PCS_CH3_A_REG = 0,  // 取值范围：0～255。
    parameter PCS_CH3_GE_AUTO_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter integer PCS_CH3_SKIP_REG0 = 0,  // 取值范围：0～1023。
    parameter integer PCS_CH3_SKIP_REG1 = 0,  // 取值范围：0～1023。
    parameter integer PCS_CH3_SKIP_REG2 = 0,  // 取值范围：0～1023。
    parameter integer PCS_CH3_SKIP_REG3 = 0,  // 取值范围：0～1023。
    parameter PCS_CH3_DEC_DUAL = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH3_SPLIT = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH3_FIFOFLAG_CTC = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH3_COMMA_DET_MODE = "COMMA_PATTERN",  // 参数选项："RX_CLK_SLIP" "COMMA_PATTERN"
    parameter PCS_CH3_ERRDETECT_SILENCE = "TRUE",  // 使能选项：开启或关闭。
    parameter PCS_CH3_PMA_RCLK_POLINV = "PMA_RCLK",  // 参数选项："PMA_RCLK" "REVERSE_OF_PMA_RCLK"
    parameter PCS_CH3_PCS_RCLK_SEL = "PMA_RCLK",  // 参数选项："PMA_RCLK" "PMA_TCLK" "RCLK"
    parameter PCS_CH3_CB_RCLK_SEL = "PMA_RCLK",  // 参数选项："PMA_RCLK" "PMA_TCLK" "MCB_RCLK"
    parameter PCS_CH3_AFTER_CTC_RCLK_SEL = "PMA_RCLK",  // 参数选项："PMA_RCLK" "PMA_TCLK" "MCB_RCLK" "RCLK2"
    parameter PCS_CH3_RCLK_POLINV = "RCLK",  // 参数选项："RCLK" "REVERSE_OF_RCLK"
    parameter PCS_CH3_BRIDGE_RCLK_SEL = "PMA_RCLK",  // 参数选项："PMA_RCLK" "PMA_TCLK" "MCB_RCLK" "RCLK"
    parameter PCS_CH3_PCS_RCLK_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH3_CB_RCLK_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH3_AFTER_CTC_RCLK_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH3_AFTER_CTC_RCLK_EN_GB = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH3_PCS_RX_RSTN = "TRUE",  // PCS 接收端复位控制
    parameter PCS_CH3_PCIE_SLAVE = "MASTER",  // 通道角色：主通道或从通道。
    parameter PCS_CH3_RX_64B66B_67B = "NORMAL",  // 编码模式：普通、64b/66b 或 64b/67b。
    parameter               PCS_CH3_RX_BRIDGE_CLK_POLINV = "RX_BRIDGE_CLK"        ,// 参数选项："RX_BRIDGE_CLK" "REVERSE_OF_RX_BRIDGE_CLK"
    parameter PCS_CH3_PCS_CB_RSTN = "TRUE",  // PCS 通道绑定复位控制
    parameter               PCS_CH3_TX_BRIDGE_GEAR_SEL = "FALSE"                  ,// TRUE 优先使用发送齿轮箱，FALSE 优先使用发送桥接单元。
    parameter PCS_CH3_TX_BYPASS_BRIDGE_UINT = "FALSE",  // 旁路使能
    parameter PCS_CH3_TX_BYPASS_BRIDGE_FIFO = "FALSE",  // 发送桥接 FIFO 旁路使能
    parameter PCS_CH3_TX_BYPASS_GEAR = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH3_TX_BYPASS_ENC = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH3_TX_BYPASS_BIT_SLIP = "TRUE",  // 使能选项：开启或关闭。
    parameter PCS_CH3_TX_GEAR_SPLIT = "TRUE",  // 使能选项：开启或关闭。
    parameter               PCS_CH3_TX_DRIVE_REG_MODE = "NO_CHANGE"               ,// 变换选项：不变、极性反转、位序反转或两者同时反转。
    parameter integer PCS_CH3_TX_BIT_SLIP_CYCLES = 0,  // 取值范围：0～31。
    parameter PCS_CH3_INT_TX_MASK_0 = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH3_INT_TX_MASK_1 = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH3_INT_TX_MASK_2 = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH3_INT_TX_CLR_0 = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH3_INT_TX_CLR_1 = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH3_INT_TX_CLR_2 = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH3_TX_PMA_TCLK_POLINV = "PMA_TCLK",  // 参数选项："PMA_TCLK" "REVERSE_OF_PMA_TCLK"
    parameter PCS_CH3_TX_PCS_CLK_EN_SEL = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH3_TX_BRIDGE_TCLK_SEL = "TCLK",  // 参数选项："PCS_TCLK" "TCLK"
    parameter PCS_CH3_TX_TCLK_POLINV = "TCLK",  // 参数选项："TCLK" "REVERSE_OF_TCLK"
    parameter PCS_CH3_PCS_TCLK_SEL = "PMA_TCLK",  // 参数选项："PMA_TCLK" "TCLK"
    parameter PCS_CH3_TX_PCS_TX_RSTN = "TRUE",  // PCS 发送端复位控制
    parameter PCS_CH3_TX_SLAVE = "MASTER",  // 通道角色：主通道或从通道。
    parameter PCS_CH3_TX_GEAR_CLK_EN_SEL = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH3_DATA_WIDTH_MODE = "X20",  // 参数选项："X8" "X10" "X16" "X20"
    parameter PCS_CH3_TX_64B66B_67B = "NORMAL",  // 编码模式：普通、64b/66b 或 64b/67b。
    parameter PCS_CH3_GEAR_TCLK_SEL = "PMA_TCLK",  // 参数选项："PMA_TCLK" "TCLK2"
    parameter PCS_CH3_TX_TCLK2FABRIC_SEL = "TRUE",  // 使能选项：开启或关闭。
    parameter PCS_CH3_TX_OUTZZ = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH3_ENC_DUAL = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH3_TX_BITSLIP_DATA_MODE = "X10",  // 参数选项："X10" "X20"
    parameter               PCS_CH3_TX_BRIDGE_CLK_POLINV = "TX_BRIDGE_CLK"        ,// 参数选项："TX_BRIDGE_CLK" "REVERSE_OF_TX_BRIDGE_CLK"
    parameter integer PCS_CH3_COMMA_REG1 = 0,  // 取值范围：0～1023。
    parameter integer PCS_CH3_RAPID_IMAX = 0,  // 取值范围：0～7。
    parameter integer PCS_CH3_RAPID_VMIN_1 = 0,  // 取值范围：0～255。
    parameter integer PCS_CH3_RAPID_VMIN_2 = 0,  // 取值范围：0～255。
    parameter PCS_CH3_RX_PRBS_MODE = "DISABLE",  // PRBS 配置：关闭或选择 7、15、23、31 阶多项式。
    parameter PCS_CH3_RX_ERRCNT_CLR = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH3_PRBS_ERR_LPBK = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH3_TX_PRBS_MODE = "DISABLE",  // 测试码型：PRBS、长 1、长 0、20 UI、D10.2 或 PCIe。
    parameter PCS_CH3_TX_INSERT_ER = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH3_ENABLE_PRBS_GEN = "FALSE",  // 使能选项：开启或关闭。
    parameter integer PCS_CH3_DEFAULT_RADDR = 6,  // 取值范围：0～15。
    parameter integer PCS_CH3_MASTER_CHECK_OFFSET = 0,  // 取值范围：0～15。
    parameter integer PCS_CH3_DELAY_SET = 0,  // 取值范围：0～15。
    parameter PCS_CH3_SEACH_OFFSET = "20BIT",  // 绑定位宽：20～80 位，间隔 10 位。
    parameter integer PCS_CH3_CEB_RAPIDLS_MMAX = 0,  // 取值范围：0～7。
    parameter integer PCS_CH3_CTC_AFULL = 20,  // 取值范围：0～31。
    parameter integer PCS_CH3_CTC_AEMPTY = 12,  // 取值范围：0～31。
    parameter integer PCS_CH3_CTC_CONTI_SKP_SET = 0,  // 取值范围：0～1。
    parameter PCS_CH3_FAR_LOOP = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH3_NEAR_LOOP = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH3_PMA_TX2RX_PLOOP_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH3_PMA_TX2RX_SLOOP_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH3_PMA_RX2TX_PLOOP_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH3_INT_RX_MASK_0 = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH3_INT_RX_MASK_1 = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH3_INT_RX_MASK_2 = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH3_INT_RX_MASK_3 = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH3_INT_RX_MASK_4 = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH3_INT_RX_MASK_5 = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH3_INT_RX_MASK_6 = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH3_INT_RX_MASK_7 = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH3_INT_RX_CLR_0 = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH3_INT_RX_CLR_1 = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH3_INT_RX_CLR_2 = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH3_INT_RX_CLR_3 = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH3_INT_RX_CLR_4 = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH3_INT_RX_CLR_5 = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH3_INT_RX_CLR_6 = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH3_INT_RX_CLR_7 = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH3_CA_RSTN_RX = "FALSE",  // 接收时钟对齐器复位控制
    parameter PCS_CH3_CA_DYN_DLY_EN_RX = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH3_CA_DYN_DLY_SEL_RX = "FALSE",  // 使能选项：开启或关闭。
    parameter integer PCS_CH3_CA_RX = 0,  // 取值范围：0～255。
    parameter PCS_CH3_CA_RSTN_TX = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH3_CA_DYN_DLY_EN_TX = "FALSE",  // 使能选项：开启或关闭。
    parameter PCS_CH3_CA_DYN_DLY_SEL_TX = "FALSE",  // 使能选项：开启或关闭。
    parameter integer PCS_CH3_CA_TX = 0,  // 取值范围：0～255。
    parameter PCS_CH3_RXPRBS_PWR_REDUCTION = "NORMAL",  // 工作模式：普通或低功耗。
    parameter PCS_CH3_WDALIGN_PWR_REDUCTION = "NORMAL",  // 工作模式：普通或低功耗。
    parameter PCS_CH3_RXDEC_PWR_REDUCTION = "NORMAL",  // 工作模式：普通或低功耗。
    parameter PCS_CH3_RXCB_PWR_REDUCTION = "NORMAL",  // 工作模式：普通或低功耗。
    parameter PCS_CH3_RXCTC_PWR_REDUCTION = "NORMAL",  // 工作模式：普通或低功耗。
    parameter PCS_CH3_RXGEAR_PWR_REDUCTION = "NORMAL",  // 工作模式：普通或低功耗。
    parameter PCS_CH3_RXBRG_PWR_REDUCTION = "NORMAL",  // 工作模式：普通或低功耗。
    parameter PCS_CH3_RXTEST_PWR_REDUCTION = "NORMAL",  // 工作模式：普通或低功耗。
    parameter PCS_CH3_TXBRG_PWR_REDUCTION = "NORMAL",  // 工作模式：普通或低功耗。
    parameter PCS_CH3_TXGEAR_PWR_REDUCTION = "NORMAL",  // 工作模式：普通或低功耗。
    parameter PCS_CH3_TXENC_PWR_REDUCTION = "NORMAL",  // 工作模式：普通或低功耗。
    parameter PCS_CH3_TXBSLP_PWR_REDUCTION = "NORMAL",  // 工作模式：普通或低功耗。
    parameter PCS_CH3_TXPRBS_PWR_REDUCTION = "NORMAL",  // 工作模式：普通或低功耗。

    parameter PMA_CH3_REG_RX_PD = "ON",  // 使能选项：开启或关闭。
    parameter PMA_CH3_REG_RX_PD_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH3_REG_RX_RESERVED_2 = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH3_REG_RX_RESERVED_3 = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH3_REG_RX_DATAPATH_PD = "ON",  // 使能选项：开启或关闭。
    parameter PMA_CH3_REG_RX_DATAPATH_PD_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH3_REG_RX_SIGDET_PD = "ON",  // 使能选项：开启或关闭。
    parameter PMA_CH3_REG_RX_SIGDET_PD_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH3_REG_RX_DCC_RST_N = "TRUE",  // 使能选项：开启或关闭。
    parameter PMA_CH3_REG_RX_DCC_RST_N_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH3_REG_RX_CDR_RST_N = "TRUE",  // 使能选项：开启或关闭。
    parameter PMA_CH3_REG_RX_CDR_RST_N_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH3_REG_RX_SIGDET_RST_N = "TRUE",  // 使能选项：开启或关闭。
    parameter PMA_CH3_REG_RX_SIGDET_RST_N_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH3_REG_RXPCLK_SLIP = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH3_REG_RXPCLK_SLIP_OW = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH3_REG_RX_PCLKSWITCH_RST_N = "TRUE",  // 发送 PMA 复位控制
    parameter PMA_CH3_REG_RX_PCLKSWITCH_RST_N_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH3_REG_RX_PCLKSWITCH = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH3_REG_RX_PCLKSWITCH_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH3_REG_RX_HIGHZ = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH3_REG_RX_HIGHZ_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH3_REG_RX_SIGDET_CLK_WINDOW = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH3_REG_RX_SIGDET_CLK_WINDOW_OW = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH3_REG_RX_PD_BIAS_RX = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH3_REG_RX_PD_BIAS_RX_OW = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH3_REG_RX_RESET_N = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH3_REG_RX_RESET_N_OW = "FALSE",  // 使能选项：开启或关闭。
    parameter integer PMA_CH3_REG_RX_RESERVED_29_28 = 0,  // 取值范围：0～3。
    parameter PMA_CH3_REG_RX_BUSWIDTH = "20BIT",  // 位宽选项：8、10、16 或 20 位。
    parameter PMA_CH3_REG_RX_BUSWIDTH_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH3_REG_RX_RATE = "DIV1",  // 时钟倍率：四分频、二分频、原频或二倍频。
    parameter PMA_CH3_REG_RX_RESERVED_36 = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH3_REG_RX_RATE_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter integer PMA_CH3_REG_RX_RES_TRIM = 46,  // 取值范围：0～63。
    parameter PMA_CH3_REG_RX_RESERVED_44 = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH3_REG_RX_RESERVED_45 = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH3_REG_RX_SIGDET_STATUS_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter integer PMA_CH3_REG_RX_RESERVED_48_47 = 0,  // 取值范围：0～3。
    parameter integer PMA_CH3_REG_RX_ICTRL_SIGDET = 5,  // 取值范围：0～15。
    parameter integer PMA_CH3_REG_CDR_READY_THD = 2734,  // 取值范围：0～4095。
    parameter PMA_CH3_REG_RX_RESERVED_65 = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH3_REG_RX_PCLK_EDGE_SEL = "POS_EDGE",  // 时钟边沿：上升沿或下降沿。
    parameter integer PMA_CH3_REG_RX_PIBUF_IC = 1,  // 取值范围：0～3。
    parameter PMA_CH3_REG_RX_RESERVED_69 = "FALSE",  // 使能选项：开启或关闭。
    parameter integer PMA_CH3_REG_RX_DCC_IC_RX = 1,  // 取值范围：0～3。
    parameter integer PMA_CH3_REG_CDR_READY_CHECK_CTRL = 0,  // 取值范围：0～3。
    parameter PMA_CH3_REG_RX_ICTRL_TRX = "100PCT",  // 比例选项：87.5%、100%、112.5%、125%。
    parameter integer PMA_CH3_REG_RX_RESERVED_77_76 = 0,  // 取值范围：0～3。
    parameter integer PMA_CH3_REG_RX_RESERVED_79_78 = 1,  // 取值范围：0～3。
    parameter integer PMA_CH3_REG_RX_RESERVED_81_80 = 1,  // 取值范围：0～3。
    parameter PMA_CH3_REG_RX_ICTRL_PIBUF = "100PCT",  // 比例选项：87.5%、100%、112.5%、125%。
    parameter PMA_CH3_REG_RX_ICTRL_PI = "100PCT",  // 比例选项：87.5%、100%、112.5%、125%。
    parameter PMA_CH3_REG_RX_ICTRL_DCC = "100PCT",  // 比例选项：87.5%、100%、112.5%、125%。
    parameter integer PMA_CH3_REG_RX_RESERVED_89_88 = 1,  // 取值范围：0～3。
    parameter PMA_CH3_REG_TX_RATE = "DIV1",  // 时钟倍率：四分频、二分频、原频或二倍频。
    parameter PMA_CH3_REG_RX_RESERVED_92 = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH3_REG_TX_RATE_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH3_REG_RX_TX2RX_PLPBK_RST_N = "TRUE",  // PMA 发送到接收并行环回复位控制
    parameter PMA_CH3_REG_RX_TX2RX_PLPBK_RST_N_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH3_REG_RX_TX2RX_PLPBK_EN = "FALSE",  // PMA 发送到接收并行环回使能
    parameter PMA_CH3_REG_TXCLK_SEL = "PLL",  // 时钟来源：PLL 或接收时钟。
    parameter PMA_CH3_REG_RX_DATA_POLARITY = "NORMAL",  // 极性选项：正常或反转。
    parameter PMA_CH3_REG_RX_ERR_INSERT = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH3_REG_UDP_CHK_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH3_REG_PRBS_SEL = "PRBS7",  // PRBS 多项式阶数：7、15、23、31。
    parameter PMA_CH3_REG_PRBS_CHK_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH3_REG_PRBS_CHK_WIDTH_SEL = "20BIT",  // 位宽选项：8、10、16 或 20 位。
    parameter PMA_CH3_REG_BIST_CHK_PAT_SEL = "PRBS",  // 码型来源：PRBS 或常量。
    parameter PMA_CH3_REG_LOAD_ERR_CNT = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH3_REG_CHK_COUNTER_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter integer PMA_CH3_REG_CDR_PROP_GAIN = 7,  // 取值范围：0～7。
    parameter integer PMA_CH3_REG_CDR_PROP_TURBO_GAIN = 5,  // 取值范围：0～7。
    parameter integer PMA_CH3_REG_CDR_INT_GAIN = 4,  // 取值范围：0～7。
    parameter integer PMA_CH3_REG_CDR_INT_TURBO_GAIN = 5,  // 取值范围：0～7。
    parameter integer PMA_CH3_REG_CDR_INT_SAT_MAX = 768,  // 取值范围：0～1023。
    parameter integer PMA_CH3_REG_CDR_INT_SAT_MIN = 255,  // 取值范围：0～1023。
    parameter PMA_CH3_REG_CDR_INT_RST = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH3_REG_CDR_INT_RST_OW = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH3_REG_CDR_PROP_RST = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH3_REG_CDR_PROP_RST_OW = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH3_REG_CDR_LOCK_RST = "FALSE",  // CDR 锁定计数器复位控制
    parameter PMA_CH3_REG_CDR_LOCK_RST_OW = "FALSE",  // 使能选项：开启或关闭。
    parameter integer PMA_CH3_REG_CDR_RX_PI_FORCE_SEL = 0,  //0,1
    parameter integer PMA_CH3_REG_CDR_RX_PI_FORCE_D = 0,  // 取值范围：0～255。
    parameter               PMA_CH3_REG_CDR_LOCK_TIMER = "1_2U"                   ,// 参数选项："0_8U" "1_2U" "1_6U" "2_4U" 3_2U" "4_8U" "12_8U" "25_6U"
    parameter integer PMA_CH3_REG_CDR_TURBO_MODE_TIMER = 1,  // 取值范围：0～3。
    parameter PMA_CH3_REG_CDR_LOCK_VAL = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH3_REG_CDR_LOCK_OW = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH3_REG_CDR_INT_SAT_DET_EN = "TRUE",  // 使能选项：开启或关闭。
    parameter PMA_CH3_REG_CDR_SAT_AUTO_DIS = "TRUE",  // 使能选项：开启或关闭。
    parameter PMA_CH3_REG_CDR_GAIN_AUTO = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH3_REG_CDR_TURBO_GAIN_AUTO = "FALSE",  // 使能选项：开启或关闭。
    parameter integer PMA_CH3_REG_RX_RESERVED_171_167 = 0,  // 取值范围：0～31。
    parameter integer PMA_CH3_REG_RX_RESERVED_175_172 = 0,  // 取值范围：0～31。
    parameter PMA_CH3_REG_CDR_SAT_DET_STATUS_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH3_REG_CDR_SAT_DET_STATUS_RESET_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH3_REG_CDR_PI_CTRL_RST = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH3_REG_CDR_PI_CTRL_RST_OW = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH3_REG_CDR_SAT_DET_RST = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH3_REG_CDR_SAT_DET_RST_OW = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH3_REG_CDR_SAT_DET_STICKY_RST = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH3_REG_CDR_SAT_DET_STICKY_RST_OW = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH3_REG_CDR_SIGDET_STATUS_DIS = "FALSE",  // 无信号检测状态时复位 CDR。
    parameter integer PMA_CH3_REG_CDR_SAT_DET_TIMER = 2,  // 取值范围：0～3。
    parameter PMA_CH3_REG_CDR_SAT_DET_STATUS_VAL = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH3_REG_CDR_SAT_DET_STATUS_OW = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH3_REG_CDR_TURBO_MODE_EN = "TRUE",  // 使能选项：开启或关闭。
    parameter PMA_CH3_REG_RX_RESERVED_190 = "FALSE",  // 使能选项：开启或关闭。
    parameter integer PMA_CH3_REG_RX_RESERVED_193_191 = 0,  // 取值范围：0～7。
    parameter PMA_CH3_REG_CDR_STATUS_FIFO_EN = "TRUE",  // 使能选项：开启或关闭。
    parameter integer PMA_CH3_REG_PMA_TEST_SEL = 0,  //0,1
    parameter integer PMA_CH3_REG_OOB_COMWAKE_GAP_MIN = 3,  // 取值范围：0～63。
    parameter integer PMA_CH3_REG_OOB_COMWAKE_GAP_MAX = 11,  // 取值范围：0～63。
    parameter integer PMA_CH3_REG_OOB_COMINIT_GAP_MIN = 15,  // 取值范围：0～255。
    parameter integer PMA_CH3_REG_OOB_COMINIT_GAP_MAX = 35,  // 取值范围：0～255。
    parameter integer PMA_CH3_REG_RX_RESERVED_227_226 = 1,  // 取值范围：0～3。
    parameter integer PMA_CH3_REG_COMWAKE_STATUS_CLEAR = 0,  //0,1
    parameter integer PMA_CH3_REG_COMINIT_STATUS_CLEAR = 0,  //0,1
    parameter PMA_CH3_REG_RX_SYNC_RST_N_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH3_REG_RX_SYNC_RST_N = "TRUE",  // 使能选项：开启或关闭。
    parameter integer PMA_CH3_REG_RX_RESERVED_233_232 = 0,  // 取值范围：0～3。
    parameter integer PMA_CH3_REG_RX_RESERVED_235_234 = 0,  // 取值范围：0～3。
    parameter PMA_CH3_REG_RX_SATA_COMINIT_OW = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH3_REG_RX_SATA_COMINIT = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH3_REG_RX_SATA_COMWAKE_OW = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH3_REG_RX_SATA_COMWAKE = "FALSE",  // 使能选项：开启或关闭。
    parameter integer PMA_CH3_REG_RX_RESERVED_241_240 = 0,  // 取值范围：0～3。
    parameter PMA_CH3_REG_RX_DCC_DISABLE = "FALSE",  // 接收占空比校正禁用控制
    parameter PMA_CH3_REG_RX_RESERVED_243 = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH3_REG_RX_SLIP_SEL_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter integer PMA_CH3_REG_RX_SLIP_SEL = 0,  // 取值范围：0～15。
    parameter PMA_CH3_REG_RX_SLIP_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter integer PMA_CH3_REG_RX_SIGDET_STATUS_SEL = 5,  // 取值范围：0～7。
    parameter PMA_CH3_REG_RX_SIGDET_FSM_RST_N = "TRUE",  // 使能选项：开启或关闭。
    parameter PMA_CH3_REG_RX_RESERVED_254 = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH3_REG_RX_SIGDET_STATUS = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH3_REG_RX_SIGDET_VTH = "72MV",  // 检测电压：45、54、63、72 mV。
    parameter integer PMA_CH3_REG_RX_SIGDET_GRM = 0,  //0,1,2,3
    parameter PMA_CH3_REG_RX_SIGDET_PULSE_EXT = "FALSE",  // 使能选项：开启或关闭。
    parameter integer PMA_CH3_REG_RX_SIGDET_CH2_SEL = 0,  //0,1
    parameter integer PMA_CH3_REG_RX_SIGDET_CH2_CHK_WINDOW = 3,  // 取值范围：0～31。
    parameter PMA_CH3_REG_RX_SIGDET_CHK_WINDOW_EN = "TRUE",  // 使能选项：开启或关闭。
    parameter integer PMA_CH3_REG_RX_SIGDET_NOSIG_COUNT_SETTING = 4,  // 取值范围：0～7。
    parameter PMA_CH3_REG_SLIP_FIFO_INV_EN = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH3_REG_SLIP_FIFO_INV = "POS_EDGE",  // 时钟边沿：上升沿或下降沿。
    parameter integer PMA_CH3_REG_RX_SIGDET_OOB_DET_COUNT_VAL = 0,  // 取值范围：0～31。
    parameter integer PMA_CH3_REG_RX_SIGDET_4OOB_DET_SEL = 7,  // 取值范围：0～7。
    parameter integer PMA_CH3_REG_RX_RESERVED_285_283 = 0,  // 取值范围：0～7。
    parameter PMA_CH3_REG_RX_RESERVED_286 = "FALSE",  // 使能选项：开启或关闭。
    parameter integer PMA_CH3_REG_RX_SIGDET_IC_I = 10,  // 取值范围：0～15。
    parameter PMA_CH3_REG_RX_OOB_DETECTOR_RESET_N_OW = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH3_REG_RX_OOB_DETECTOR_RESET_N = "FALSE",  // 接收带外检测器复位控制
    parameter PMA_CH3_REG_RX_OOB_DETECTOR_PD_OW = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH3_REG_RX_OOB_DETECTOR_PD = "ON",  // 接收带外检测器掉电控制
    parameter PMA_CH3_REG_RX_LS_MODE_EN = "FALSE",  // 低速模式使能
    parameter PMA_CH3_REG_ANA_RX_EQ1_R_SET_FB_O_SEL = "TRUE",  // 使能选项：开启或关闭。
    parameter PMA_CH3_REG_ANA_RX_EQ2_R_SET_FB_O_SEL = "TRUE",  // 使能选项：开启或关闭。
    parameter integer PMA_CH3_REG_RX_EQ1_R_SET_TOP = 0,  // 取值范围：0～3。
    parameter integer PMA_CH3_REG_RX_EQ1_R_SET_FB = 15,  // 取值范围：0～15。
    parameter integer PMA_CH3_REG_RX_EQ1_C_SET_FB = 0,  // 取值范围：0～15。
    parameter PMA_CH3_REG_RX_EQ1_OFF = "FALSE",  // 使能选项：开启或关闭。
    parameter integer PMA_CH3_REG_RX_EQ2_R_SET_TOP = 0,  // 取值范围：0～3。
    parameter integer PMA_CH3_REG_RX_EQ2_R_SET_FB = 0,  // 取值范围：0～15。
    parameter integer PMA_CH3_REG_RX_EQ2_C_SET_FB = 0,  // 取值范围：0～15。
    parameter PMA_CH3_REG_RX_EQ2_OFF = "FALSE",  // 使能选项：开启或关闭。
    parameter integer PMA_CH3_REG_EQ_DAC = 0,  // 取值范围：0～63。
    parameter integer PMA_CH3_REG_RX_ICTRL_EQ = 2,  // 使能选项：开启或关闭。
    parameter PMA_CH3_REG_EQ_DC_CALIB_EN = "TRUE",  // 使能选项：开启或关闭。
    parameter PMA_CH3_REG_EQ_DC_CALIB_SEL = "FALSE",  // 使能选项：开启或关闭。
    parameter integer PMA_CH3_REG_RX_RESERVED_337_330 = 0,  // 取值范围：0～255。
    parameter integer PMA_CH3_REG_RX_RESERVED_345_338 = 0,  // 取值范围：0～255。
    parameter integer PMA_CH3_REG_RX_RESERVED_353_346 = 0,  // 取值范围：0～255。
    parameter integer PMA_CH3_REG_RX_RESERVED_361_354 = 0,  // 取值范围：0～255。
    parameter integer PMA_CH3_CTLE_CTRL_REG_I = 0,  // 取值范围：0～15。
    parameter PMA_CH3_CTLE_REG_FORCE_SEL_I = "FALSE",  // 自适应调整控制
    parameter PMA_CH3_CTLE_REG_HOLD_I = "FALSE",  // 使能选项：开启或关闭。
    parameter integer PMA_CH3_CTLE_REG_INIT_DAC_I = 0,  // 取值范围：0～15。
    parameter PMA_CH3_CTLE_REG_POLARITY_I = "FALSE",  // 使能选项：开启或关闭。
    parameter integer PMA_CH3_CTLE_REG_SHIFTER_GAIN_I = 1,  // 取值范围：0～7。
    parameter integer PMA_CH3_CTLE_REG_THRESHOLD_I = 3072,  // 取值范围：0～4095。
    parameter PMA_CH3_REG_RX_RES_TRIM_EN = "TRUE",  // 使能选项：开启或关闭。
    parameter integer PMA_CH3_REG_RX_RESERVED_393_389 = 0,  // 取值范围：0～31。
    parameter PMA_CH3_CFG_RX_LANE_POWERUP = "ON",  // 接收通道上电控制
    parameter PMA_CH3_CFG_RX_PMA_RSTN = "TRUE",  // 接收 PMA 复位控制
    parameter PMA_CH3_INT_PMA_RX_MASK_0 = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH3_INT_PMA_RX_CLR_0 = "FALSE",  // 使能选项：开启或关闭。
    parameter PMA_CH3_CFG_CTLE_ADP_RSTN = "TRUE",  // 控制逻辑复位

    parameter         PMA_CH3_REG_TX_PD                       = "ON",      // 发送端掉电控制
    parameter         PMA_CH3_REG_TX_PD_OW                    = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH3_REG_TX_MAIN_PRE_Z               = "FALSE",   // PCIe 模式电气空闲使能
    parameter         PMA_CH3_REG_TX_MAIN_PRE_Z_OW            = "FALSE",   // 使能选项：开启或关闭。
    parameter integer PMA_CH3_REG_TX_BEACON_TIMER_SEL         = 0,         // 取值范围：0～3。
    parameter         PMA_CH3_REG_TX_RXDET_REQ_OW             = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH3_REG_TX_RXDET_REQ                = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH3_REG_TX_BEACON_EN_OW             = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH3_REG_TX_BEACON_EN                = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH3_REG_TX_EI_EN_OW                 = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH3_REG_TX_EI_EN                    = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH3_REG_TX_BIT_CONV                 = "FALSE",   // 使能选项：开启或关闭。
    parameter integer PMA_CH3_REG_TX_RES_CAL                  = 48,        // 取值范围：0～63。
    parameter         PMA_CH3_REG_TX_RESERVED_19              = "FALSE",   // 使能选项：开启或关闭。
    parameter integer PMA_CH3_REG_TX_RESERVED_25_20           = 32,        // 取值范围：0～63。
    parameter integer PMA_CH3_REG_TX_RESERVED_33_26           = 0,         // 取值范围：0～255。
    parameter integer PMA_CH3_REG_TX_RESERVED_41_34           = 0,         // 取值范围：0～255。
    parameter integer PMA_CH3_REG_TX_RESERVED_49_42           = 0,         // 取值范围：0～255。
    parameter integer PMA_CH3_REG_TX_RESERVED_57_50           = 0,         // 取值范围：0～255。
    parameter         PMA_CH3_REG_TX_SYNC_OW                  = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH3_REG_TX_SYNC                     = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH3_REG_TX_PD_POST                  = "OFF",     // 使能选项：开启或关闭。
    parameter         PMA_CH3_REG_TX_PD_POST_OW               = "TRUE",    // 使能选项：开启或关闭。
    parameter         PMA_CH3_REG_TX_RESET_N_OW               = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH3_REG_TX_RESET_N                  = "TRUE",    // 使能选项：开启或关闭。
    parameter         PMA_CH3_REG_TX_RESERVED_64              = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH3_REG_TX_RESERVED_65              = "TRUE",    // 使能选项：开启或关闭。
    parameter         PMA_CH3_REG_TX_BUSWIDTH_OW              = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH3_REG_TX_BUSWIDTH                 = "20BIT",   // 位宽选项：8、10、16 或 20 位。
    parameter         PMA_CH3_REG_PLL_READY_OW                = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH3_REG_PLL_READY                   = "TRUE",    // 使能选项：开启或关闭。
    parameter         PMA_CH3_REG_TX_RESERVED_72              = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH3_REG_TX_RESERVED_73              = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH3_REG_TX_RESERVED_74              = "FALSE",   // 使能选项：开启或关闭。
    parameter integer PMA_CH3_REG_EI_PCLK_DELAY_SEL           = 0,         // 取值范围：0～3。
    parameter         PMA_CH3_REG_TX_RESERVED_77              = "FALSE",   // 使能选项：开启或关闭。
    parameter integer PMA_CH3_REG_TX_RESERVED_83_78           = 0,         // 取值范围：0～63。
    parameter integer PMA_CH3_REG_TX_RESERVED_89_84           = 0,         // 取值范围：0～63。
    parameter integer PMA_CH3_REG_TX_RESERVED_95_90           = 0,         // 取值范围：0～63。
    parameter integer PMA_CH3_REG_TX_RESERVED_101_96          = 0,         // 取值范围：0～63。
    parameter integer PMA_CH3_REG_TX_RESERVED_107_102         = 0,         // 取值范围：0～63。
    parameter integer PMA_CH3_REG_TX_RESERVED_113_108         = 0,         // 取值范围：0～63。
    parameter integer PMA_CH3_REG_TX_AMP_DAC0                 = 25,        // 取值范围：0～63。
    parameter integer PMA_CH3_REG_TX_AMP_DAC1                 = 19,        // 取值范围：0～63。
    parameter integer PMA_CH3_REG_TX_AMP_DAC2                 = 14,        // 取值范围：0～63。
    parameter integer PMA_CH3_REG_TX_AMP_DAC3                 = 9,         // 取值范围：0～63。
    parameter integer PMA_CH3_REG_TX_RESERVED_143_138         = 5,         // 取值范围：0～63。
    parameter integer PMA_CH3_REG_TX_MARGIN                   = 0,         // 取值范围：0～7。
    parameter         PMA_CH3_REG_TX_MARGIN_OW                = "FALSE",   // 使能选项：开启或关闭。
    parameter integer PMA_CH3_REG_TX_RESERVED_149_148         = 0,         // 取值范围：0～3。
    parameter         PMA_CH3_REG_TX_RESERVED_150             = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH3_REG_TX_SWING                    = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH3_REG_TX_SWING_OW                 = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH3_REG_TX_RESERVED_153             = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH3_REG_TX_RXDET_THRESHOLD          = "84MV",    // 电压选项：28、56、84、112 mV。
    parameter integer PMA_CH3_REG_TX_RESERVED_157_156         = 0,         // 取值范围：0～3。
    parameter         PMA_CH3_REG_TX_BEACON_OSC_CTRL          = "FALSE",   // 使能选项：开启或关闭。
    parameter integer PMA_CH3_REG_TX_RESERVED_160_159         = 0,         // 取值范围：0～3。
    parameter integer PMA_CH3_REG_TX_RESERVED_162_161         = 0,         // 取值范围：0～3。
    parameter         PMA_CH3_REG_TX_TX2RX_SLPBACK_EN         = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH3_REG_TX_PCLK_EDGE_SEL            = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH3_REG_TX_RXDET_STATUS_OW          = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH3_REG_TX_RXDET_STATUS             = "TRUE",    // 使能选项：开启或关闭。
    parameter         PMA_CH3_REG_TX_PRBS_GEN_EN              = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH3_REG_TX_PRBS_GEN_WIDTH_SEL       = "20BIT",   // 位宽选项：8、10、16 或 20 位。
    parameter         PMA_CH3_REG_TX_PRBS_SEL                 = "PRBS7",   // PRBS 多项式阶数：7、15、23、31。
    parameter integer PMA_CH3_REG_TX_UDP_DATA_7_TO_0          = 5,         // 取值范围：0～255。
    parameter integer PMA_CH3_REG_TX_UDP_DATA_15_TO_8         = 235,       // 取值范围：0～255。
    parameter integer PMA_CH3_REG_TX_UDP_DATA_19_TO_16        = 3,         // 取值范围：0～15。
    parameter         PMA_CH3_REG_TX_RESERVED_192             = "FALSE",   // 使能选项：开启或关闭。
    parameter integer PMA_CH3_REG_TX_FIFO_WP_CTRL             = 4,         // 取值范围：0～7。
    parameter         PMA_CH3_REG_TX_FIFO_EN                  = "FALSE",   // 使能选项：开启或关闭。
    parameter integer PMA_CH3_REG_TX_DATA_MUX_SEL             = 0,         // 取值范围：0～3。
    parameter         PMA_CH3_REG_TX_ERR_INSERT               = "FALSE",   // 使能选项：开启或关闭。
    parameter integer PMA_CH3_REG_TX_RESERVED_203_200         = 0,         // 取值范围：0～15。
    parameter         PMA_CH3_REG_TX_RESERVED_204             = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH3_REG_TX_SATA_EN                  = "FALSE",   // 使能选项：开启或关闭。
    parameter integer PMA_CH3_REG_TX_RESERVED_207_206         = 0,         // 取值范围：0～3。
    parameter         PMA_CH3_REG_RATE_CHANGE_TXPCLK_ON_OW    = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH3_REG_RATE_CHANGE_TXPCLK_ON       = "TRUE",    // 使能选项：开启或关闭。
    parameter integer PMA_CH3_REG_TX_CFG_POST1                = 0,         // 取值范围：0～31。
    parameter integer PMA_CH3_REG_TX_CFG_POST2                = 0,         // 取值范围：0～31。
    parameter integer PMA_CH3_REG_TX_DEEMP                    = 0,         // 取值范围：0～3。
    parameter         PMA_CH3_REG_TX_DEEMP_OW                 = "FALSE",   // 发送去加重控制
    parameter integer PMA_CH3_REG_TX_RESERVED_224_223         = 0,         // 取值范围：0～3。
    parameter         PMA_CH3_REG_TX_RESERVED_225             = "FALSE",   // 使能选项：开启或关闭。
    parameter integer PMA_CH3_REG_TX_RESERVED_229_226         = 0,         // 取值范围：0～15。
    parameter integer PMA_CH3_REG_TX_OOB_DELAY_SEL            = 0,         // 取值范围：0～15。
    parameter         PMA_CH3_REG_TX_POLARITY                 = "NORMAL",  // 极性选项：正常或反转。
    parameter         PMA_CH3_REG_ANA_TX_JTAG_DATA_O_SEL      = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH3_REG_TX_RESERVED_236             = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH3_REG_TX_LS_MODE_EN               = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH3_REG_TX_JTAG_MODE_EN_OW          = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH3_REG_TX_JTAG_MODE_EN             = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH3_REG_RX_JTAG_MODE_EN_OW          = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH3_REG_RX_JTAG_MODE_EN             = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH3_REG_RX_JTAG_OE                  = "TRUE",    // 使能选项：开启或关闭。
    parameter integer PMA_CH3_REG_RX_ACJTAG_VHYSTSEL          = 0,         // 取值范围：0～7。
    parameter         PMA_CH3_REG_TX_RES_CAL_EN               = "FALSE",   // 使能选项：开启或关闭。
    parameter integer PMA_CH3_REG_RX_TERM_MODE_CTRL           = 5,         // 接收终端控制范围：0～7。
    parameter integer PMA_CH3_REG_TX_RESERVED_251_250         = 0,         // 取值范围：0～7。
    parameter         PMA_CH3_REG_PLPBK_TXPCLK_EN             = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH3_REG_TX_RESERVED_253             = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH3_REG_TX_RESERVED_254             = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH3_REG_TX_RESERVED_255             = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH3_REG_TX_RESERVED_256             = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH3_REG_TX_RESERVED_257             = "FALSE",   // 使能选项：开启或关闭。
    parameter integer PMA_CH3_REG_TX_PH_SEL                   = 1,         // 取值范围：0～63。
    parameter integer PMA_CH3_REG_TX_CFG_PRE                  = 0,         // 取值范围：0～31。
    parameter integer PMA_CH3_REG_TX_CFG_MAIN                 = 0,         // 取值范围：0～63。
    parameter integer PMA_CH3_REG_CFG_POST                    = 0,         // 取值范围：0～31。
    parameter         PMA_CH3_REG_PD_MAIN                     = "TRUE",    // 使能选项：开启或关闭。
    parameter         PMA_CH3_REG_PD_PRE                      = "TRUE",    // 使能选项：开启或关闭。
    parameter         PMA_CH3_REG_TX_LS_DATA                  = "FALSE",   // 使能选项：开启或关闭。
    parameter integer PMA_CH3_REG_TX_DCC_BUF_SZ_SEL           = 0,         // 取值范围：0～3。
    parameter integer PMA_CH3_REG_TX_DCC_CAL_CUR_TUNE         = 0,         // 取值范围：0～63。
    parameter         PMA_CH3_REG_TX_DCC_CAL_EN               = "FALSE",   // 使能选项：开启或关闭。
    parameter integer PMA_CH3_REG_TX_DCC_CUR_SS               = 0,         // 取值范围：0～3。
    parameter         PMA_CH3_REG_TX_DCC_FA_CTRL              = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH3_REG_TX_DCC_RI_CTRL              = "FALSE",   // 使能选项：开启或关闭。
    parameter integer PMA_CH3_REG_ATB_SEL_2_TO_0              = 0,         // 取值范围：0～7。
    parameter integer PMA_CH3_REG_ATB_SEL_9_TO_3              = 0,         // 取值范围：0～127。
    parameter integer PMA_CH3_REG_TX_CFG_7_TO_0               = 0,         // 取值范围：0～255。
    parameter integer PMA_CH3_REG_TX_CFG_15_TO_8              = 0,         // 取值范围：0～255。
    parameter integer PMA_CH3_REG_TX_CFG_23_TO_16             = 0,         // 取值范围：0～255。
    parameter integer PMA_CH3_REG_TX_CFG_31_TO_24             = 128,       // 取值范围：0～255。
    parameter         PMA_CH3_REG_TX_OOB_EI_EN                = "FALSE",   // SATA 模式带外电气空闲使能
    parameter         PMA_CH3_REG_TX_OOB_EI_EN_OW             = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH3_REG_TX_BEACON_EN_DELAYED        = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH3_REG_TX_BEACON_EN_DELAYED_OW     = "FALSE",   // 使能选项：开启或关闭。
    parameter         PMA_CH3_REG_TX_JTAG_DATA                = "FALSE",   // 使能选项：开启或关闭。
    parameter integer PMA_CH3_REG_TX_RXDET_TIMER_SEL          = 87,        // 取值范围：0～255。
    parameter integer PMA_CH3_REG_TX_CFG1_7_0                 = 0,         // 取值范围：0～255。
    parameter integer PMA_CH3_REG_TX_CFG1_15_8                = 0,         // 取值范围：0～255。
    parameter integer PMA_CH3_REG_TX_CFG1_23_16               = 0,         // 取值范围：0～255。
    parameter integer PMA_CH3_REG_TX_CFG1_31_24               = 0,         // 取值范围：0～255。
    parameter         PMA_CH3_REG_CFG_LANE_POWERUP            = "ON",      // PMA 通道上电控制
    parameter         PMA_CH3_REG_CFG_TX_LANE_POWERUP_CLKPATH = "TRUE",    // PMA 发送通道时钟路径上电控制
    parameter         PMA_CH3_REG_CFG_TX_LANE_POWERUP_PISO    = "TRUE",    // PMA 发送并串转换单元上电控制
    parameter         PMA_CH3_REG_CFG_TX_LANE_POWERUP_DRIVER  = "TRUE"     // PMA 发送驱动器上电控制
) (
    // 逻辑侧端口
    input  wire        p_cfg_clk,
    input  wire        p_cfg_rst,
    input  wire        p_cfg_psel,
    input  wire        p_cfg_enable,
    input  wire        p_cfg_write,
    input  wire [15:0] p_cfg_addr,
    input  wire [ 7:0] p_cfg_wdata,
    output wire        p_cfg_ready,
    output wire [ 7:0] p_cfg_rdata,
    output wire        p_cfg_int,
    // PLL0 端口
    output             P_REFCK2CORE_0,
    output             P_PLL_READY_0,
    input              P_RESCAL_RST_I_0,
    input              P_PLL_REF_CLK_0,
    input              P_PLL_RST_0,
    input              P_PLLPOWERDOWN_0,
    input              P_LANE_SYNC_0,
    input              P_RATE_CHANGE_TCLK_ON_0,
    input              REFCLK_CML_N_0,
    input              REFCLK_CML_P_0,
    // PLL1 端口
    output             P_REFCK2CORE_1,
    output             P_PLL_READY_1,

    input P_RESCAL_RST_I_1,
    input P_PLL_REF_CLK_1,
    input P_PLL_RST_1,
    input P_PLLPOWERDOWN_1,
    input P_LANE_SYNC_1,
    input P_RATE_CHANGE_TCLK_ON_1,

    input REFCLK_CML_N_1,
    input REFCLK_CML_P_1,
    // 通道 0 端口

    output        P_TX_SDN_0,
    output        P_TX_SDP_0,
    // SRB 相关信号
    output        P_PCS_RX_MCB_STATUS_0,
    output        P_PCS_LSM_SYNCED_0,
    output [46:0] P_RDATA_0,
    output        P_RCLK2FABRIC_0,
    output        P_TCLK2FABRIC_0,
    output        P_RX_SIGDET_STATUS_0,
    output        P_RX_SATA_COMINIT_0,
    output        P_RX_SATA_COMWAKE_0,
    output        P_RX_READY_0,
    output        P_TX_RXDET_STATUS_0,

    input        P_RX_SDN_0,
    input        P_RX_SDP_0,
    // SRB 相关信号
    input        P_RX_CLK_FR_CORE_0,
    input        P_RCLK2_FR_CORE_0,
    input        P_TX_CLK_FR_CORE_0,
    input        P_TCLK2_FR_CORE_0,
    input        P_PCS_TX_RST_0,
    input        P_PCS_RX_RST_0,
    input        P_PCS_CB_RST_0,
    input        P_RXGEAR_SLIP_0,
    input [45:0] P_TDATA_0,
    input        P_PCS_WORD_ALIGN_EN_0,
    input        P_RX_POLARITY_INVERT_0,
    input        P_PCS_MCB_EXT_EN_0,
    input        P_PCS_NEAREND_LOOP_0,
    input        P_PCS_FAREND_LOOP_0,
    input        P_PMA_NEAREND_PLOOP_0,
    input        P_PMA_NEAREND_SLOOP_0,
    input        P_PMA_FAREND_PLOOP_0,
    input        P_TX_BEACON_EN_0,
    input        P_LANE_PD_0,
    input        P_LANE_RST_0,
    input        P_RX_LANE_PD_0,
    input        P_RX_PMA_RST_0,
    input [ 1:0] P_TX_DEEMP_0,
    input        P_TX_SWING_0,
    input        P_TX_RXDET_REQ_0,
    input [ 2:0] P_TX_RATE_0,
    input [ 2:0] P_TX_MARGIN_0,
    input        P_TX_PMA_RST_0,
    input        P_TX_LANE_PD_CLKPATH_0,
    input        P_TX_LANE_PD_PISO_0,
    input        P_TX_LANE_PD_DRIVER_0,
    input [ 2:0] P_RX_RATE_0,
    input        P_RX_HIGHZ_0,
    // 通道 1 端口

    output        P_TX_SDN_1,
    output        P_TX_SDP_1,
    // SRB 相关信号
    output        P_PCS_RX_MCB_STATUS_1,
    output        P_PCS_LSM_SYNCED_1,
    output [46:0] P_RDATA_1,
    output        P_RCLK2FABRIC_1,
    output        P_TCLK2FABRIC_1,
    output        P_RX_SIGDET_STATUS_1,
    output        P_RX_SATA_COMINIT_1,
    output        P_RX_SATA_COMWAKE_1,
    output        P_RX_READY_1,
    output        P_TX_RXDET_STATUS_1,

    input        P_RX_SDN_1,
    input        P_RX_SDP_1,
    // SRB 相关信号
    input        P_RX_CLK_FR_CORE_1,
    input        P_RCLK2_FR_CORE_1,
    input        P_TX_CLK_FR_CORE_1,
    input        P_TCLK2_FR_CORE_1,
    input        P_PCS_TX_RST_1,
    input        P_PCS_RX_RST_1,
    input        P_PCS_CB_RST_1,
    input        P_RXGEAR_SLIP_1,
    input [45:0] P_TDATA_1,
    input        P_PCS_WORD_ALIGN_EN_1,
    input        P_RX_POLARITY_INVERT_1,
    input        P_PCS_MCB_EXT_EN_1,
    input        P_PCS_NEAREND_LOOP_1,
    input        P_PCS_FAREND_LOOP_1,
    input        P_PMA_NEAREND_PLOOP_1,
    input        P_PMA_NEAREND_SLOOP_1,
    input        P_PMA_FAREND_PLOOP_1,
    input        P_TX_BEACON_EN_1,
    input        P_LANE_PD_1,
    input        P_LANE_RST_1,
    input        P_RX_LANE_PD_1,
    input        P_RX_PMA_RST_1,
    input [ 1:0] P_TX_DEEMP_1,
    input        P_TX_SWING_1,
    input        P_TX_RXDET_REQ_1,
    input [ 2:0] P_TX_RATE_1,
    input [ 2:0] P_TX_MARGIN_1,
    input        P_TX_PMA_RST_1,
    input        P_TX_LANE_PD_CLKPATH_1,
    input        P_TX_LANE_PD_PISO_1,
    input        P_TX_LANE_PD_DRIVER_1,
    input [ 2:0] P_RX_RATE_1,
    input        P_RX_HIGHZ_1,
    // 通道 2 端口

    output        P_TX_SDN_2,
    output        P_TX_SDP_2,
    // SRB 相关信号
    output        P_PCS_RX_MCB_STATUS_2,
    output        P_PCS_LSM_SYNCED_2,
    output [46:0] P_RDATA_2,
    output        P_RCLK2FABRIC_2,
    output        P_TCLK2FABRIC_2,
    output        P_RX_SIGDET_STATUS_2,
    output        P_RX_SATA_COMINIT_2,
    output        P_RX_SATA_COMWAKE_2,
    output        P_RX_READY_2,
    output        P_TX_RXDET_STATUS_2,

    input        P_RX_SDN_2,
    input        P_RX_SDP_2,
    // SRB 相关信号
    input        P_RX_CLK_FR_CORE_2,
    input        P_RCLK2_FR_CORE_2,
    input        P_TX_CLK_FR_CORE_2,
    input        P_TCLK2_FR_CORE_2,
    input        P_PCS_TX_RST_2,
    input        P_PCS_RX_RST_2,
    input        P_PCS_CB_RST_2,
    input        P_RXGEAR_SLIP_2,
    input [45:0] P_TDATA_2,
    input        P_PCS_WORD_ALIGN_EN_2,
    input        P_RX_POLARITY_INVERT_2,
    input        P_PCS_MCB_EXT_EN_2,
    input        P_PCS_NEAREND_LOOP_2,
    input        P_PCS_FAREND_LOOP_2,
    input        P_PMA_NEAREND_PLOOP_2,
    input        P_PMA_NEAREND_SLOOP_2,
    input        P_PMA_FAREND_PLOOP_2,
    input        P_TX_BEACON_EN_2,
    input        P_LANE_PD_2,
    input        P_LANE_RST_2,
    input        P_RX_LANE_PD_2,
    input        P_RX_PMA_RST_2,
    input [ 1:0] P_TX_DEEMP_2,
    input        P_TX_SWING_2,
    input        P_TX_RXDET_REQ_2,
    input [ 2:0] P_TX_RATE_2,
    input [ 2:0] P_TX_MARGIN_2,
    input        P_TX_PMA_RST_2,
    input        P_TX_LANE_PD_CLKPATH_2,
    input        P_TX_LANE_PD_PISO_2,
    input        P_TX_LANE_PD_DRIVER_2,
    input [ 2:0] P_RX_RATE_2,
    input        P_RX_HIGHZ_2,
    // 通道 3 端口

    output        P_TX_SDN_3,
    output        P_TX_SDP_3,
    // SRB 相关信号
    output        P_PCS_RX_MCB_STATUS_3,
    output        P_PCS_LSM_SYNCED_3,
    output [46:0] P_RDATA_3,
    output        P_RCLK2FABRIC_3,
    output        P_TCLK2FABRIC_3,
    output        P_RX_SIGDET_STATUS_3,
    output        P_RX_SATA_COMINIT_3,
    output        P_RX_SATA_COMWAKE_3,
    output        P_RX_READY_3,
    output        P_TX_RXDET_STATUS_3,

    input        P_RX_SDN_3,
    input        P_RX_SDP_3,
    // SRB 相关信号
    input        P_RX_CLK_FR_CORE_3,
    input        P_RCLK2_FR_CORE_3,
    input        P_TX_CLK_FR_CORE_3,
    input        P_TCLK2_FR_CORE_3,
    input        P_PCS_TX_RST_3,
    input        P_PCS_RX_RST_3,
    input        P_PCS_CB_RST_3,
    input        P_RXGEAR_SLIP_3,
    input [45:0] P_TDATA_3,
    input        P_PCS_WORD_ALIGN_EN_3,
    input        P_RX_POLARITY_INVERT_3,
    input        P_PCS_MCB_EXT_EN_3,
    input        P_PCS_NEAREND_LOOP_3,
    input        P_PCS_FAREND_LOOP_3,
    input        P_PMA_NEAREND_PLOOP_3,
    input        P_PMA_NEAREND_SLOOP_3,
    input        P_PMA_FAREND_PLOOP_3,
    input        P_TX_BEACON_EN_3,
    input        P_LANE_PD_3,
    input        P_LANE_RST_3,
    input        P_RX_LANE_PD_3,
    input        P_RX_PMA_RST_3,
    input [ 1:0] P_TX_DEEMP_3,
    input        P_TX_SWING_3,
    input        P_TX_RXDET_REQ_3,
    input [ 2:0] P_TX_RATE_3,
    input [ 2:0] P_TX_MARGIN_3,
    input        P_TX_PMA_RST_3,
    input        P_TX_LANE_PD_CLKPATH_3,
    input        P_TX_LANE_PD_PISO_3,
    input        P_TX_LANE_PD_DRIVER_3,
    input [ 2:0] P_RX_RATE_3,
    input        P_RX_HIGHZ_3
);

    wire [ 5:0] P_RESCAL_I_CODE_I_0 = 6'b101110;
    wire        P_PLL_LOCKDET_RST_I_0 = 1'b0;
    wire [ 5:0] P_RESCAL_I_CODE_O_0;
    wire        PLL_CLK0_0;
    wire        PLL_CLK90_0;
    wire        PLL_CLK180_0;
    wire        PLL_CLK270_0;
    wire        SYNC_PLL_0;
    wire        RATE_CHANGE_PLL_0;
    wire        PLL_PD_O_0;
    wire        PLL_RST_O_0;
    wire        PMA_PLL_READY_O_0;
    wire        PLL_REFCLK_LANE_L_0;
    wire        TXPCLK_PLL_SELECTED_0;
    wire        P_CFG_READY_PLL_0;
    wire [ 7:0] P_CFG_RDATA_PLL_0;
    wire        P_CFG_INT_PLL_0;
    wire        P_CFG_RST_PLL_0;
    wire        P_CFG_CLK_PLL_0;
    wire        P_CFG_PSEL_PLL_0;
    wire        P_CFG_ENABLE_PLL_0;
    wire        P_CFG_WRITE_PLL_0;
    wire [11:0] P_CFG_ADDR_PLL_0;
    wire [ 7:0] P_CFG_WDATA_PLL_0;

    wire [ 5:0] P_RESCAL_I_CODE_I_1 = 6'b101110;
    wire        P_PLL_LOCKDET_RST_I_1 = 1'b0;
    wire [ 5:0] P_RESCAL_I_CODE_O_1;
    wire        PLL_CLK0_1;
    wire        PLL_CLK90_1;
    wire        PLL_CLK180_1;
    wire        PLL_CLK270_1;
    wire        SYNC_PLL_1;
    wire        RATE_CHANGE_PLL_1;
    wire        PLL_PD_O_1;
    wire        PLL_RST_O_1;
    wire        PMA_PLL_READY_O_1;
    wire        PLL_REFCLK_LANE_L_1;
    wire        TXPCLK_PLL_SELECTED_1;
    wire        P_CFG_READY_PLL_1;
    wire [ 7:0] P_CFG_RDATA_PLL_1;
    wire        P_CFG_INT_PLL_1;
    wire        P_CFG_RST_PLL_1;
    wire        P_CFG_CLK_PLL_1;
    wire        P_CFG_PSEL_PLL_1;
    wire        P_CFG_ENABLE_PLL_1;
    wire        P_CFG_WRITE_PLL_1;
    wire [11:0] P_CFG_ADDR_PLL_1;
    wire [ 7:0] P_CFG_WDATA_PLL_1;

    wire        TXPCLK_PLL_0;
    wire        SYNC_0;
    wire        RATE_CHANGE_0;
    wire        PLL_LOCK_SEL_0;
    wire        CLK_TXP_0;
    wire        CLK_TXN_0;
    wire        CLK_RX0_0;
    wire        CLK_RX90_0;
    wire        CLK_RX180_0;
    wire        CLK_RX270_0;
    wire        PLL_PD_I_0;
    wire        PLL_RESET_I_0;
    wire        PLL_REFCLK_I_0;
    wire [ 5:0] PLL_RES_TRIM_I_0;
    wire        PMA_RCLK_0;
    wire        MCB_RCLK_0;
    wire [18:0] LANE_CIN_BUS_FORWARD_0;
    wire        APATTERN_STATUS_CIN_0;
    wire [18:0] LANE_COUT_BUS_FORWARD_0;
    wire        APATTERN_STATUS_COUT_0;
    wire        P_CFG_READY_0;
    wire [ 7:0] P_CFG_RDATA_0;
    wire        P_CFG_INT_0;
    wire        P_CFG_CLK_0;
    wire        P_CFG_RST_0;
    wire        P_CFG_PSEL_0;
    wire        P_CFG_ENABLE_0;
    wire        P_CFG_WRITE_0;
    wire [11:0] P_CFG_ADDR_0;
    wire [ 7:0] P_CFG_WDATA_0;
    wire [19:0] P_TEST_STATUS_0;
    wire        P_CA_ALIGN_RX_0;
    wire        P_CA_ALIGN_TX_0;
    wire        P_CEB_ADETECT_EN_0 = 1'b1;
    wire        P_CTLE_ADP_RST_0 = 1'b0;
    wire        P_TX_LS_DATA_0 = 1'b0;
    wire [ 7:0] P_CIM_CLK_ALIGNER_RX_0 = 8'b0;
    wire [ 7:0] P_CIM_CLK_ALIGNER_TX_0 = 8'b0;
    wire        P_CIM_DYN_DLY_SEL_RX_0 = 1'b0;
    wire        P_CIM_DYN_DLY_SEL_TX_0 = 1'b0;
    wire        P_CIM_START_ALIGN_RX_0 = 1'b0;
    wire        P_CIM_START_ALIGN_TX_0 = 1'b0;
    wire        P_RX_LS_DATA_0;
    wire [ 2:0] P_TX_BUSWIDTH_0 = 2'b0;
    wire [ 2:0] P_RX_BUSWIDTH_0 = 2'b0;

    wire        TXPCLK_PLL_1;
    wire        SYNC_1;
    wire        RATE_CHANGE_1;
    wire        PLL_LOCK_SEL_1;
    wire        CLK_TXP_1;
    wire        CLK_TXN_1;
    wire        CLK_RX0_1;
    wire        CLK_RX90_1;
    wire        CLK_RX180_1;
    wire        CLK_RX270_1;
    wire        PLL_PD_I_1;
    wire        PLL_RESET_I_1;
    wire        PLL_REFCLK_I_1;
    wire [ 5:0] PLL_RES_TRIM_I_1;
    wire        PMA_RCLK_1;
    wire        MCB_RCLK_1;
    wire [18:0] LANE_CIN_BUS_FORWARD_1;
    wire        APATTERN_STATUS_CIN_1;
    wire [18:0] LANE_COUT_BUS_FORWARD_1;
    wire        APATTERN_STATUS_COUT_1;
    wire        P_CFG_READY_1;
    wire [ 7:0] P_CFG_RDATA_1;
    wire        P_CFG_INT_1;
    wire        P_CFG_CLK_1;
    wire        P_CFG_RST_1;
    wire        P_CFG_PSEL_1;
    wire        P_CFG_ENABLE_1;
    wire        P_CFG_WRITE_1;
    wire [11:0] P_CFG_ADDR_1;
    wire [ 7:0] P_CFG_WDATA_1;
    wire [19:0] P_TEST_STATUS_1;
    wire        P_CA_ALIGN_RX_1;
    wire        P_CA_ALIGN_TX_1;
    wire        P_CEB_ADETECT_EN_1 = 1'b1;
    wire        P_CTLE_ADP_RST_1 = 1'b0;
    wire        P_TX_LS_DATA_1 = 1'b0;
    wire [ 7:0] P_CIM_CLK_ALIGNER_RX_1 = 8'b0;
    wire [ 7:0] P_CIM_CLK_ALIGNER_TX_1 = 8'b0;
    wire        P_CIM_DYN_DLY_SEL_RX_1 = 1'b0;
    wire        P_CIM_DYN_DLY_SEL_TX_1 = 1'b0;
    wire        P_CIM_START_ALIGN_RX_1 = 1'b0;
    wire        P_CIM_START_ALIGN_TX_1 = 1'b0;
    wire        P_RX_LS_DATA_1;
    wire [ 2:0] P_TX_BUSWIDTH_1 = 3'b0;
    wire [ 2:0] P_RX_BUSWIDTH_1 = 3'b0;

    wire        TXPCLK_PLL_2;
    wire        SYNC_2;
    wire        RATE_CHANGE_2;
    wire        PLL_LOCK_SEL_2;
    wire        CLK_TXP_2;
    wire        CLK_TXN_2;
    wire        CLK_RX0_2;
    wire        CLK_RX90_2;
    wire        CLK_RX180_2;
    wire        CLK_RX270_2;
    wire        PLL_PD_I_2;
    wire        PLL_RESET_I_2;
    wire        PLL_REFCLK_I_2;
    wire [ 5:0] PLL_RES_TRIM_I_2;
    wire        PMA_RCLK_2;
    wire        MCB_RCLK_2;
    wire [18:0] LANE_CIN_BUS_FORWARD_2;
    wire        APATTERN_STATUS_CIN_2;
    wire [18:0] LANE_COUT_BUS_FORWARD_2;
    wire        APATTERN_STATUS_COUT_2;
    wire        P_CFG_READY_2;
    wire [ 7:0] P_CFG_RDATA_2;
    wire        P_CFG_INT_2;
    wire        P_CFG_CLK_2;
    wire        P_CFG_RST_2;
    wire        P_CFG_PSEL_2;
    wire        P_CFG_ENABLE_2;
    wire        P_CFG_WRITE_2;
    wire [11:0] P_CFG_ADDR_2;
    wire [ 7:0] P_CFG_WDATA_2;
    wire [19:0] P_TEST_STATUS_2;
    wire        P_CA_ALIGN_RX_2;
    wire        P_CA_ALIGN_TX_2;
    wire        P_CEB_ADETECT_EN_2 = 1'b1;
    wire        P_CTLE_ADP_RST_2 = 1'b0;
    wire        P_TX_LS_DATA_2 = 1'b0;
    wire [ 7:0] P_CIM_CLK_ALIGNER_RX_2 = 8'b0;
    wire [ 7:0] P_CIM_CLK_ALIGNER_TX_2 = 8'b0;
    wire        P_CIM_DYN_DLY_SEL_RX_2 = 1'b0;
    wire        P_CIM_DYN_DLY_SEL_TX_2 = 1'b0;
    wire        P_CIM_START_ALIGN_RX_2 = 1'b0;
    wire        P_CIM_START_ALIGN_TX_2 = 1'b0;
    wire        P_RX_LS_DATA_2;
    wire [ 2:0] P_TX_BUSWIDTH_2 = 3'b0;
    wire [ 2:0] P_RX_BUSWIDTH_2 = 3'b0;

    wire        TXPCLK_PLL_3;
    wire        SYNC_3;
    wire        RATE_CHANGE_3;
    wire        PLL_LOCK_SEL_3;
    wire        CLK_TXP_3;
    wire        CLK_TXN_3;
    wire        CLK_RX0_3;
    wire        CLK_RX90_3;
    wire        CLK_RX180_3;
    wire        CLK_RX270_3;
    wire        PLL_PD_I_3;
    wire        PLL_RESET_I_3;
    wire        PLL_REFCLK_I_3;
    wire [ 5:0] PLL_RES_TRIM_I_3;
    wire        PMA_RCLK_3;
    wire        MCB_RCLK_3;
    wire [18:0] LANE_CIN_BUS_FORWARD_3;
    wire        APATTERN_STATUS_CIN_3 = 1'b1;
    wire [18:0] LANE_COUT_BUS_FORWARD_3;
    wire        APATTERN_STATUS_COUT_3;
    wire        P_CFG_READY_3;
    wire [ 7:0] P_CFG_RDATA_3;
    wire        P_CFG_INT_3;
    wire        P_CFG_CLK_3;
    wire        P_CFG_RST_3;
    wire        P_CFG_PSEL_3;
    wire        P_CFG_ENABLE_3;
    wire        P_CFG_WRITE_3;
    wire [11:0] P_CFG_ADDR_3;
    wire [ 7:0] P_CFG_WDATA_3;
    wire [19:0] P_TEST_STATUS_3;
    wire        P_CA_ALIGN_RX_3;
    wire        P_CA_ALIGN_TX_3;
    wire        P_CEB_ADETECT_EN_3 = 1'b1;
    wire        P_CTLE_ADP_RST_3 = 1'b0;
    wire        P_TX_LS_DATA_3 = 1'b0;
    wire [ 7:0] P_CIM_CLK_ALIGNER_RX_3 = 8'b0;
    wire [ 7:0] P_CIM_CLK_ALIGNER_TX_3 = 8'b0;
    wire        P_CIM_DYN_DLY_SEL_RX_3 = 1'b0;
    wire        P_CIM_DYN_DLY_SEL_TX_3 = 1'b0;
    wire        P_CIM_START_ALIGN_RX_3 = 1'b0;
    wire        P_CIM_START_ALIGN_TX_3 = 1'b0;
    wire        P_RX_LS_DATA_3;
    wire [ 2:0] P_TX_BUSWIDTH_3 = 3'b0;
    wire [ 2:0] P_RX_BUSWIDTH_3 = 3'b0;

    // 通道绑定适配逻辑
    // MCB_RCLK 时钟处理
    assign MCB_RCLK_0 = PMA_RCLK_0;
    assign MCB_RCLK_1 = (CH0_MULT_LANE_MODE == 2 || CH0_MULT_LANE_MODE == 4) ? PMA_RCLK_0 : PMA_RCLK_1;
    assign MCB_RCLK_2 = (CH0_MULT_LANE_MODE == 4) ? PMA_RCLK_0 : PMA_RCLK_2;
    assign MCB_RCLK_3 = (CH0_MULT_LANE_MODE == 4) ? PMA_RCLK_0 : (CH2_MULT_LANE_MODE == 2) ? PMA_RCLK_2 : PMA_RCLK_3;

    // 通道绑定的 CIN 与 COUT 处理
    generate
        if (CH0_MULT_LANE_MODE == 4) begin : LANE_0123_BONDING
            assign LANE_CIN_BUS_FORWARD_1 = LANE_COUT_BUS_FORWARD_0;  // 通道 0 级联到通道 1。
            assign LANE_CIN_BUS_FORWARD_2 = LANE_COUT_BUS_FORWARD_1;  // 通道 1 级联到通道 2。
            assign LANE_CIN_BUS_FORWARD_3 = LANE_COUT_BUS_FORWARD_2;  // 通道 2 级联到通道 3。
            assign APATTERN_STATUS_CIN_0  = APATTERN_STATUS_COUT_1;  // 通道 1 级联到通道 0。
            assign APATTERN_STATUS_CIN_1  = APATTERN_STATUS_COUT_2;  // 通道 2 级联到通道 1。
            assign APATTERN_STATUS_CIN_2  = APATTERN_STATUS_COUT_3;  // 通道 3 级联到通道 2。
        end else if (CH0_MULT_LANE_MODE == 2 && CH2_MULT_LANE_MODE == 2) begin : LANE_01_23_BONDING
            assign LANE_CIN_BUS_FORWARD_1 = LANE_COUT_BUS_FORWARD_0;  // 通道 0 级联到通道 1。
            assign LANE_CIN_BUS_FORWARD_3 = LANE_COUT_BUS_FORWARD_2;  // 通道 2 级联到通道 3。
            assign APATTERN_STATUS_CIN_0  = APATTERN_STATUS_COUT_1;  // 通道 1 级联到通道 0。
            assign APATTERN_STATUS_CIN_2  = APATTERN_STATUS_COUT_3;  // 通道 3 级联到通道 2。
        end else if (CH0_MULT_LANE_MODE == 2 && CH2_MULT_LANE_MODE == 1) begin : LANE_01_BONDING
            assign LANE_CIN_BUS_FORWARD_1 = LANE_COUT_BUS_FORWARD_0;  // 通道 0 级联到通道 1。
            assign APATTERN_STATUS_CIN_0  = APATTERN_STATUS_COUT_1;  // 通道 1 级联到通道 0。
        end else if (CH0_MULT_LANE_MODE == 1 && CH2_MULT_LANE_MODE == 2) begin : LANE_23_BONDING
            assign LANE_CIN_BUS_FORWARD_3 = LANE_COUT_BUS_FORWARD_2;  // 通道 2 级联到通道 3。
            assign APATTERN_STATUS_CIN_2  = APATTERN_STATUS_COUT_3;  // 通道 3 级联到通道 2。
        end
    endgenerate

    // 仿真适配逻辑

    // 发送 PLL 选择
    assign TXPCLK_PLL_SELECTED_0     = PLL0_TXPCLK_PLL_SEL == 0 ? TXPCLK_PLL_0 :
                                   PLL0_TXPCLK_PLL_SEL == 1 ? TXPCLK_PLL_1 :
                                   PLL0_TXPCLK_PLL_SEL == 2 ? TXPCLK_PLL_2 : TXPCLK_PLL_3;

    assign TXPCLK_PLL_SELECTED_1     = PLL1_TXPCLK_PLL_SEL == 0 ? TXPCLK_PLL_0 :
                                   PLL1_TXPCLK_PLL_SEL == 1 ? TXPCLK_PLL_1 :
                                   PLL1_TXPCLK_PLL_SEL == 2 ? TXPCLK_PLL_2 : TXPCLK_PLL_3;

    // 通道 0 选择
    assign PLL_RES_TRIM_I_0 = P_RESCAL_I_CODE_O_0;
    assign SYNC_0 = (TX_CHANNEL0_PLL == 0) ? SYNC_PLL_0 : SYNC_PLL_1;
    assign RATE_CHANGE_0 = (TX_CHANNEL0_PLL == 0) ? RATE_CHANGE_PLL_0 : RATE_CHANGE_PLL_1;
    assign CLK_TXP_0 = (TX_CHANNEL0_PLL == 0) ? PLL_CLK0_0 : PLL_CLK0_1;
    assign CLK_TXN_0 = (TX_CHANNEL0_PLL == 0) ? PLL_CLK180_0 : PLL_CLK180_1;
    assign CLK_RX0_0 = (RX_CHANNEL0_PLL == 0) ? PLL_CLK0_0 : PLL_CLK0_1;
    assign CLK_RX90_0 = (RX_CHANNEL0_PLL == 0) ? PLL_CLK90_0 : PLL_CLK90_1;
    assign CLK_RX180_0 = (RX_CHANNEL0_PLL == 0) ? PLL_CLK180_0 : PLL_CLK180_1;
    assign CLK_RX270_0 = (RX_CHANNEL0_PLL == 0) ? PLL_CLK270_0 : PLL_CLK270_1;
    assign PLL_PD_I_0 = (RX_CHANNEL0_PLL == 0) ? PLL_PD_O_0 : PLL_PD_O_1;
    assign    PLL_RESET_I_0           = (CH0_EN == "TX_only")? ((TX_CHANNEL0_PLL==0) ? PLL_RST_O_0   : PLL_RST_O_1  ) :
                                                           ((RX_CHANNEL0_PLL==0) ? PLL_RST_O_0   : PLL_RST_O_1  ) ;
    assign    PLL_REFCLK_I_0          = (CH0_EN == "TX_only")? ((TX_CHANNEL0_PLL==0) ? PLL_REFCLK_LANE_L_0   : PLL_REFCLK_LANE_L_1  ) :
                                                           ((RX_CHANNEL0_PLL==0) ? PLL_REFCLK_LANE_L_0   : PLL_REFCLK_LANE_L_1  ) ;
    assign    PLL_LOCK_SEL_0          = (CH0_EN == "TX_only")? ((TX_CHANNEL0_PLL==0) ? PMA_PLL_READY_O_0   : PMA_PLL_READY_O_1  ) :
                                                           ((RX_CHANNEL0_PLL==0) ? PMA_PLL_READY_O_0   : PMA_PLL_READY_O_1  ) ;
    // 通道 1 选择
    assign PLL_RES_TRIM_I_1 = P_RESCAL_I_CODE_O_0;
    assign SYNC_1 = (TX_CHANNEL1_PLL == 0) ? SYNC_PLL_0 : SYNC_PLL_1;
    assign RATE_CHANGE_1 = (TX_CHANNEL1_PLL == 0) ? RATE_CHANGE_PLL_0 : RATE_CHANGE_PLL_1;
    assign CLK_TXP_1 = (TX_CHANNEL1_PLL == 0) ? PLL_CLK0_0 : PLL_CLK0_1;
    assign CLK_TXN_1 = (TX_CHANNEL1_PLL == 0) ? PLL_CLK180_0 : PLL_CLK180_1;
    assign CLK_RX0_1 = (RX_CHANNEL1_PLL == 0) ? PLL_CLK0_0 : PLL_CLK0_1;
    assign CLK_RX90_1 = (RX_CHANNEL1_PLL == 0) ? PLL_CLK90_0 : PLL_CLK90_1;
    assign CLK_RX180_1 = (RX_CHANNEL1_PLL == 0) ? PLL_CLK180_0 : PLL_CLK180_1;
    assign CLK_RX270_1 = (RX_CHANNEL1_PLL == 0) ? PLL_CLK270_0 : PLL_CLK270_1;
    assign PLL_PD_I_1 = (RX_CHANNEL1_PLL == 0) ? PLL_PD_O_0 : PLL_PD_O_1;
    assign    PLL_RESET_I_1           = (CH1_EN == "TX_only")? ((TX_CHANNEL1_PLL==0) ? PLL_RST_O_0   : PLL_RST_O_1  ) :
                                                           ((RX_CHANNEL1_PLL==0) ? PLL_RST_O_0   : PLL_RST_O_1  ) ;
    assign    PLL_REFCLK_I_1          = (CH1_EN == "TX_only")? ((TX_CHANNEL1_PLL==0) ? PLL_REFCLK_LANE_L_0   : PLL_REFCLK_LANE_L_1  ) :
                                                           ((RX_CHANNEL1_PLL==0) ? PLL_REFCLK_LANE_L_0   : PLL_REFCLK_LANE_L_1  ) ;
    assign    PLL_LOCK_SEL_1          = (CH1_EN == "TX_only")? ((TX_CHANNEL1_PLL==0) ? PMA_PLL_READY_O_0   : PMA_PLL_READY_O_1  ) :
                                                           ((RX_CHANNEL1_PLL==0) ? PMA_PLL_READY_O_0   : PMA_PLL_READY_O_1  ) ;
    // 通道 2 选择
    assign PLL_RES_TRIM_I_2 = P_RESCAL_I_CODE_O_0;
    assign SYNC_2 = (TX_CHANNEL2_PLL == 0) ? SYNC_PLL_0 : SYNC_PLL_1;
    assign RATE_CHANGE_2 = (TX_CHANNEL2_PLL == 0) ? RATE_CHANGE_PLL_0 : RATE_CHANGE_PLL_1;
    assign CLK_TXP_2 = (TX_CHANNEL2_PLL == 0) ? PLL_CLK0_0 : PLL_CLK0_1;
    assign CLK_TXN_2 = (TX_CHANNEL2_PLL == 0) ? PLL_CLK180_0 : PLL_CLK180_1;
    assign CLK_RX0_2 = (RX_CHANNEL2_PLL == 0) ? PLL_CLK0_0 : PLL_CLK0_1;
    assign CLK_RX90_2 = (RX_CHANNEL2_PLL == 0) ? PLL_CLK90_0 : PLL_CLK90_1;
    assign CLK_RX180_2 = (RX_CHANNEL2_PLL == 0) ? PLL_CLK180_0 : PLL_CLK180_1;
    assign CLK_RX270_2 = (RX_CHANNEL2_PLL == 0) ? PLL_CLK270_0 : PLL_CLK270_1;
    assign PLL_PD_I_2 = (RX_CHANNEL2_PLL == 0) ? PLL_PD_O_0 : PLL_PD_O_1;
    assign    PLL_RESET_I_2           = (CH2_EN == "TX_only")? ((TX_CHANNEL2_PLL==0) ? PLL_RST_O_0   : PLL_RST_O_1  ) :
                                                           ((RX_CHANNEL2_PLL==0) ? PLL_RST_O_0   : PLL_RST_O_1  ) ;
    assign    PLL_REFCLK_I_2          = (CH2_EN == "TX_only")? ((TX_CHANNEL2_PLL==0) ? PLL_REFCLK_LANE_L_0   : PLL_REFCLK_LANE_L_1  ) :
                                                           ((RX_CHANNEL2_PLL==0) ? PLL_REFCLK_LANE_L_0   : PLL_REFCLK_LANE_L_1  ) ;
    assign    PLL_LOCK_SEL_2          = (CH2_EN == "TX_only")? ((TX_CHANNEL2_PLL==0) ? PMA_PLL_READY_O_0   : PMA_PLL_READY_O_1  ) :
                                                           ((RX_CHANNEL2_PLL==0) ? PMA_PLL_READY_O_0   : PMA_PLL_READY_O_1  ) ;
    // 通道 3 选择
    assign PLL_RES_TRIM_I_3 = P_RESCAL_I_CODE_O_0;
    assign SYNC_3 = (TX_CHANNEL3_PLL == 0) ? SYNC_PLL_0 : SYNC_PLL_1;
    assign RATE_CHANGE_3 = (TX_CHANNEL3_PLL == 0) ? RATE_CHANGE_PLL_0 : RATE_CHANGE_PLL_1;
    assign CLK_TXP_3 = (TX_CHANNEL3_PLL == 0) ? PLL_CLK0_0 : PLL_CLK0_1;
    assign CLK_TXN_3 = (TX_CHANNEL3_PLL == 0) ? PLL_CLK180_0 : PLL_CLK180_1;
    assign CLK_RX0_3 = (RX_CHANNEL3_PLL == 0) ? PLL_CLK0_0 : PLL_CLK0_1;
    assign CLK_RX90_3 = (RX_CHANNEL3_PLL == 0) ? PLL_CLK90_0 : PLL_CLK90_1;
    assign CLK_RX180_3 = (RX_CHANNEL3_PLL == 0) ? PLL_CLK180_0 : PLL_CLK180_1;
    assign CLK_RX270_3 = (RX_CHANNEL3_PLL == 0) ? PLL_CLK270_0 : PLL_CLK270_1;
    assign PLL_PD_I_3 = (RX_CHANNEL3_PLL == 0) ? PLL_PD_O_0 : PLL_PD_O_1;
    assign    PLL_RESET_I_3           = (CH3_EN == "TX_only")? ((TX_CHANNEL3_PLL==0) ? PLL_RST_O_0   : PLL_RST_O_1  ) :
                                                           ((RX_CHANNEL3_PLL==0) ? PLL_RST_O_0   : PLL_RST_O_1  ) ;
    assign    PLL_REFCLK_I_3          = (CH3_EN == "TX_only")? ((TX_CHANNEL3_PLL==0) ? PLL_REFCLK_LANE_L_0   : PLL_REFCLK_LANE_L_1  ) :
                                                           ((RX_CHANNEL3_PLL==0) ? PLL_REFCLK_LANE_L_0   : PLL_REFCLK_LANE_L_1  ) ;
    assign    PLL_LOCK_SEL_3          = (CH3_EN == "TX_only")? ((TX_CHANNEL3_PLL==0) ? PMA_PLL_READY_O_0   : PMA_PLL_READY_O_1  ) :
                                                           ((RX_CHANNEL3_PLL==0) ? PMA_PLL_READY_O_0   : PMA_PLL_READY_O_1  ) ;

    // APB 桥例化
    ipm2l_hsstlp_apb_bridge_v1_2 #(
        .PLL0_EN    (PLL0_EN),      // PLL0 使能
        .PLL1_EN    (PLL1_EN),      // PLL1 使能
        .CHANNEL0_EN(CHANNEL0_EN),  // 通道 0 使能。
        .CHANNEL1_EN(CHANNEL1_EN),  // 通道 1 使能。
        .CHANNEL2_EN(CHANNEL2_EN),  // 通道 2 使能。
        .CHANNEL3_EN(CHANNEL3_EN)   // 通道 3 使能。
    ) U_APB_BRIDGE (
        // 逻辑侧端口
        .p_cfg_clk         (p_cfg_clk),
        .p_cfg_rst         (p_cfg_rst),
        .p_cfg_psel        (p_cfg_psel),
        .p_cfg_enable      (p_cfg_enable),
        .p_cfg_write       (p_cfg_write),
        .p_cfg_addr        (p_cfg_addr),
        .p_cfg_wdata       (p_cfg_wdata),
        .p_cfg_ready       (p_cfg_ready),
        .p_cfg_rdata       (p_cfg_rdata),
        .p_cfg_int         (p_cfg_int),
        // PLL0 端口
        .P_CFG_READY_PLL_0 (P_CFG_READY_PLL_0),
        .P_CFG_RDATA_PLL_0 (P_CFG_RDATA_PLL_0),
        .P_CFG_INT_PLL_0   (P_CFG_INT_PLL_0),
        .P_CFG_RST_PLL_0   (P_CFG_RST_PLL_0),
        .P_CFG_CLK_PLL_0   (P_CFG_CLK_PLL_0),
        .P_CFG_PSEL_PLL_0  (P_CFG_PSEL_PLL_0),
        .P_CFG_ENABLE_PLL_0(P_CFG_ENABLE_PLL_0),
        .P_CFG_WRITE_PLL_0 (P_CFG_WRITE_PLL_0),
        .P_CFG_ADDR_PLL_0  (P_CFG_ADDR_PLL_0),
        .P_CFG_WDATA_PLL_0 (P_CFG_WDATA_PLL_0),
        // PLL1 端口
        .P_CFG_READY_PLL_1 (P_CFG_READY_PLL_1),
        .P_CFG_RDATA_PLL_1 (P_CFG_RDATA_PLL_1),
        .P_CFG_INT_PLL_1   (P_CFG_INT_PLL_1),
        .P_CFG_RST_PLL_1   (P_CFG_RST_PLL_1),
        .P_CFG_CLK_PLL_1   (P_CFG_CLK_PLL_1),
        .P_CFG_PSEL_PLL_1  (P_CFG_PSEL_PLL_1),
        .P_CFG_ENABLE_PLL_1(P_CFG_ENABLE_PLL_1),
        .P_CFG_WRITE_PLL_1 (P_CFG_WRITE_PLL_1),
        .P_CFG_ADDR_PLL_1  (P_CFG_ADDR_PLL_1),
        .P_CFG_WDATA_PLL_1 (P_CFG_WDATA_PLL_1),
        // 通道 0 端口
        .P_CFG_READY_0     (P_CFG_READY_0),
        .P_CFG_RDATA_0     (P_CFG_RDATA_0),
        .P_CFG_INT_0       (P_CFG_INT_0),
        .P_CFG_CLK_0       (P_CFG_CLK_0),
        .P_CFG_RST_0       (P_CFG_RST_0),
        .P_CFG_PSEL_0      (P_CFG_PSEL_0),
        .P_CFG_ENABLE_0    (P_CFG_ENABLE_0),
        .P_CFG_WRITE_0     (P_CFG_WRITE_0),
        .P_CFG_ADDR_0      (P_CFG_ADDR_0),
        .P_CFG_WDATA_0     (P_CFG_WDATA_0),
        // 通道 1 端口
        .P_CFG_READY_1     (P_CFG_READY_1),
        .P_CFG_RDATA_1     (P_CFG_RDATA_1),
        .P_CFG_INT_1       (P_CFG_INT_1),
        .P_CFG_CLK_1       (P_CFG_CLK_1),
        .P_CFG_RST_1       (P_CFG_RST_1),
        .P_CFG_PSEL_1      (P_CFG_PSEL_1),
        .P_CFG_ENABLE_1    (P_CFG_ENABLE_1),
        .P_CFG_WRITE_1     (P_CFG_WRITE_1),
        .P_CFG_ADDR_1      (P_CFG_ADDR_1),
        .P_CFG_WDATA_1     (P_CFG_WDATA_1),
        // 通道 2 端口
        .P_CFG_READY_2     (P_CFG_READY_2),
        .P_CFG_RDATA_2     (P_CFG_RDATA_2),
        .P_CFG_INT_2       (P_CFG_INT_2),
        .P_CFG_CLK_2       (P_CFG_CLK_2),
        .P_CFG_RST_2       (P_CFG_RST_2),
        .P_CFG_PSEL_2      (P_CFG_PSEL_2),
        .P_CFG_ENABLE_2    (P_CFG_ENABLE_2),
        .P_CFG_WRITE_2     (P_CFG_WRITE_2),
        .P_CFG_ADDR_2      (P_CFG_ADDR_2),
        .P_CFG_WDATA_2     (P_CFG_WDATA_2),
        // 通道 3 端口
        .P_CFG_READY_3     (P_CFG_READY_3),
        .P_CFG_RDATA_3     (P_CFG_RDATA_3),
        .P_CFG_INT_3       (P_CFG_INT_3),
        .P_CFG_CLK_3       (P_CFG_CLK_3),
        .P_CFG_RST_3       (P_CFG_RST_3),
        .P_CFG_PSEL_3      (P_CFG_PSEL_3),
        .P_CFG_ENABLE_3    (P_CFG_ENABLE_3),
        .P_CFG_WRITE_3     (P_CFG_WRITE_3),
        .P_CFG_ADDR_3      (P_CFG_ADDR_3),
        .P_CFG_WDATA_3     (P_CFG_WDATA_3)
    );

    // PLL0 例化
    generate
        if (PLL0_EN == "TRUE") begin : PLL0_ENABLE
            GTP_HSSTLP_PLL #(
                .TX_SYNCK_PD(PMA_PLL0_TX_SYNCK_PD),  // 发送同步电荷泵控制：0 上电，1 掉电。
                .PMA_PLL_REG_REFCLK_TERM_IMP_CTRL       (PMA_PLL0_REG_REFCLK_TERM_IMP_CTRL     ),// 参考时钟终端阻抗选择，不支持仿真。

                .PMA_PLL_REG_BG_TRIM(PMA_PLL0_REG_BG_TRIM),  // 电压电流转换配置，不支持仿真。
                .PMA_PLL_REG_IBUP_A1(PMA_PLL0_REG_IBUP_A1),  // 电压电流转换配置，不支持仿真。
                .PMA_PLL_REG_IBUP_A2(PMA_PLL0_REG_IBUP_A2),  // 电压电流转换配置，不支持仿真。
                .PMA_PLL_REG_IBUP_PD(PMA_PLL0_REG_IBUP_PD),  // 电压电流转换配置，不支持仿真。
                .PMA_PLL_REG_V2I_BIAS_SEL(PMA_PLL0_REG_V2I_BIAS_SEL),  // 电压电流转换配置，不支持仿真。
                .PMA_PLL_REG_V2I_EN(PMA_PLL0_REG_V2I_EN),  // 电压电流转换配置，不支持仿真。
                .PMA_PLL_REG_V2I_TB_SEL(PMA_PLL0_REG_V2I_TB_SEL),  // 电压电流转换配置，不支持仿真。
                .PMA_PLL_REG_V2I_RCALTEST_PD            (PMA_PLL0_REG_V2I_RCALTEST_PD          ),// 电压电流转换配置，不支持仿真。
                .PMA_PLL_REG_RES_CAL_TEST(PMA_PLL0_REG_RES_CAL_TEST),  // 电压电流转换配置，不支持仿真。
                .PMA_RES_CAL_DIV(PMA_PLL0_RES_CAL_DIV),  // 电压电流转换配置，不支持仿真。
                .PMA_RES_CAL_CLK_SEL(PMA_PLL0_RES_CAL_CLK_SEL),  // 电压电流转换配置，不支持仿真。

                .PMA_PLL_REG_PLL_PFDDELAY_EN(PMA_PLL0_REG_PLL_PFDDELAY_EN),  // 使能选项：开启或关闭。
                .PMA_PLL_REG_PFDDELAYSEL(PMA_PLL0_REG_PFDDELAYSEL),
                .PMA_PLL_REG_PLL_VCTRL_SET(PMA_PLL0_REG_PLL_VCTRL_SET),
                .PMA_PLL_REG_READY_OR_LOCK(PMA_PLL0_REG_READY_OR_LOCK),  // 使能选项：开启或关闭。
                .PMA_PLL_REG_PLL_CP(PMA_PLL0_REG_PLL_CP),  // 电流配置范围：1～1023，默认 31。
                .PMA_PLL_REG_PLL_REFDIV(PMA_PLL0_REG_PLL_REFDIV),  // PLL 参考时钟分频 M，默认 16。
                .PMA_PLL_REG_PLL_LOCKDET_EN(PMA_PLL0_REG_PLL_LOCKDET_EN),  // 使能选项：开启或关闭。
                .PMA_PLL_REG_PLL_READY(PMA_PLL0_REG_PLL_READY),  // 使能选项：开启或关闭。
                .PMA_PLL_REG_PLL_READY_OW(PMA_PLL0_REG_PLL_READY_OW),  // 使能选项：开启或关闭。
                .PMA_PLL_REG_PLL_FBDIV                  (PMA_PLL0_REG_PLL_FBDIV                ),// PLL 反馈分频 N2 由 Pll_fbdiv[5] 决定：1 对应 5，0 对应 4。
                                                                                                 // PLL 反馈分频 N1 可取 1、2、3、4、5、6、8、10。
                .PMA_PLL_REG_LPF_RES(PMA_PLL0_REG_LPF_RES),  // 低通滤波电阻控制，默认 1。
                .PMA_PLL_REG_JTAG_OE(PMA_PLL0_REG_JTAG_OE),  // PLL JTAG 输出使能
                .PMA_PLL_REG_JTAG_VHYSTSEL(PMA_PLL0_REG_JTAG_VHYSTSEL),  // PLL JTAG 门限电压选择，默认 0。
                .PMA_PLL_REG_PLL_LOCKDET_EN_OW(PMA_PLL0_REG_PLL_LOCKDET_EN_OW),  // 使能选项：开启或关闭。
                .PMA_PLL_REG_PLL_LOCKDET_FBCT           (PMA_PLL0_REG_PLL_LOCKDET_FBCT         ),// 计数编码 0～7 分别对应 2^9～2^15、2^16−1，默认编码 7。
                .PMA_PLL_REG_PLL_LOCKDET_ITER           (PMA_PLL0_REG_PLL_LOCKDET_ITER         ),// 编码 0～7 对应 1、2、4、8、16、32、64、127，默认编码 3。
                .PMA_PLL_REG_PLL_LOCKDET_MODE(PMA_PLL0_REG_PLL_LOCKDET_MODE),  // 使能选项：开启或关闭。
                .PMA_PLL_REG_PLL_LOCKDET_LOCKCT         (PMA_PLL0_REG_PLL_LOCKDET_LOCKCT       ),// 编码 0～7 对应 2、4、8、16、32、64、128、256，默认编码 4。
                .PMA_PLL_REG_PLL_LOCKDET_REFCT          (PMA_PLL0_REG_PLL_LOCKDET_REFCT        ),// 计数编码 0～7 分别对应 2^9～2^15、2^16−1，默认编码 7。
                .PMA_PLL_REG_PLL_LOCKDET_RESET_N        (PMA_PLL0_REG_PLL_LOCKDET_RESET_N      ),// 使能选项：开启或关闭。
                .PMA_PLL_REG_PLL_LOCKDET_RESET_N_OW     (PMA_PLL0_REG_PLL_LOCKDET_RESET_N_OW   ),// 使能选项：开启或关闭。
                .PMA_PLL_REG_PLL_LOCKED(PMA_PLL0_REG_PLL_LOCKED),  // 使能选项：开启或关闭。
                .PMA_PLL_REG_PLL_LOCKED_OW(PMA_PLL0_REG_PLL_LOCKED_OW),  // 使能选项：开启或关闭。
                .PMA_PLL_REG_PLL_LOCKED_STICKY_CLEAR    (PMA_PLL0_REG_PLL_LOCKED_STICKY_CLEAR  ),// 使能选项：开启或关闭。
                .PMA_PLL_REG_PLL_UNLOCKED(PMA_PLL0_REG_PLL_UNLOCKED),  // 使能选项：开启或关闭。
                .PMA_PLL_REG_PLL_UNLOCKDET_ITER         (PMA_PLL0_REG_PLL_UNLOCKDET_ITER       ),// 编码 00、01、10、11 对应 63、127、255、1023，默认编码 10。
                .PMA_PLL_REG_PLL_UNLOCKED_OW(PMA_PLL0_REG_PLL_UNLOCKED_OW),  // 使能选项：开启或关闭。
                .PMA_PLL_REG_PLL_UNLOCKED_STICKY_CLEAR  (PMA_PLL0_REG_PLL_UNLOCKED_STICKY_CLEAR),// 使能选项：开启或关闭。
                .PMA_PLL_REG_I_CTRL_MAX(PMA_PLL0_REG_I_CTRL_MAX),  // 取值范围：0～63，默认全 1。
                .PMA_PLL_REG_REFCLK_TEST_EN(PMA_PLL0_REG_REFCLK_TEST_EN),  // 参考时钟端口测试使能
                .PMA_PLL_REG_RESCAL_EN(PMA_PLL0_REG_RESCAL_EN),  // 使能选项：开启或关闭。
                .PMA_PLL_REG_I_CTRL_MIN(PMA_PLL0_REG_I_CTRL_MIN),  // 取值范围：0～63。
                .PMA_PLL_REG_RESCAL_DONE_OW(PMA_PLL0_REG_RESCAL_DONE_OW),  // 使能选项：开启或关闭。
                .PMA_PLL_REG_RESCAL_DONE_VAL(PMA_PLL0_REG_RESCAL_DONE_VAL),  // 使能选项：开启或关闭。
                .PMA_PLL_REG_RESCAL_I_CODE(PMA_PLL0_REG_RESCAL_I_CODE),  // 取值范围：0～63。
                .PMA_PLL_REG_RESCAL_I_CODE_OW(PMA_PLL0_REG_RESCAL_I_CODE_OW),  // 使能选项：开启或关闭。
                .PMA_PLL_REG_RESCAL_I_CODE_PMA(PMA_PLL0_REG_RESCAL_I_CODE_PMA),  // 使能选项：开启或关闭。
                .PMA_PLL_REG_RESCAL_I_CODE_VAL(PMA_PLL0_REG_RESCAL_I_CODE_VAL),  // 取值范围：0～63。
                .PMA_PLL_REG_RESCAL_INT_R_SMALL_OW      (PMA_PLL0_REG_RESCAL_INT_R_SMALL_OW    ),// 使能选项：开启或关闭。
                .PMA_PLL_REG_RESCAL_INT_R_SMALL_VAL     (PMA_PLL0_REG_RESCAL_INT_R_SMALL_VAL   ),// 使能选项：开启或关闭。
                .PMA_PLL_REG_RESCAL_ITER_VALID_SEL(PMA_PLL0_REG_RESCAL_ITER_VALID_SEL),  //0,1,2,3
                .PMA_PLL_REG_RESCAL_RESET_N_OW(PMA_PLL0_REG_RESCAL_RESET_N_OW),  // 使能选项：开启或关闭。
                .PMA_PLL_REG_RESCAL_RST_N_VAL(PMA_PLL0_REG_RESCAL_RST_N_VAL),  // 使能选项：开启或关闭。
                .PMA_PLL_REG_RESCAL_WAIT_SEL(PMA_PLL0_REG_RESCAL_WAIT_SEL),  // 使能选项：开启或关闭。
                .PMA_PLL_REFCLK2LANE_PD_L(PMA_PLL0_REFCLK2LANE_PD_L),  // 左侧 PLL 参考时钟掉电控制
                .PMA_PLL_REFCLK2LANE_PD_R(PMA_PLL0_REFCLK2LANE_PD_R),  // 右侧 PLL 参考时钟掉电控制
                .PMA_PLL_REG_LOCKDET_REPEAT(PMA_PLL0_REG_LOCKDET_REPEAT),  // 使能选项：开启或关闭。
                .PMA_PLL_REG_NOFBCLK_STICKY_CLEAR       (PMA_PLL0_REG_NOFBCLK_STICKY_CLEAR     ),// 使能选项：开启或关闭。
                .PMA_PLL_REG_NOREFCLK_STICKY_CLEAR      (PMA_PLL0_REG_NOREFCLK_STICKY_CLEAR    ),// 使能选项：开启或关闭。
                .PMA_PLL_REG_TEST_SEL(PMA_PLL0_REG_TEST_SEL),  // 测试取值范围：0～20。
                .PMA_PLL_REG_TEST_V_EN(PMA_PLL0_REG_TEST_V_EN),  // 测试使能
                .PMA_PLL_REG_TEST_SIG_HALF_EN(PMA_PLL0_REG_TEST_SIG_HALF_EN),  // 测试使能
                .PMA_PLL_REG_REFCLK_PAD_SEL(PMA_PLL0_REG_REFCLK_PAD_SEL),  // 参考时钟选择
                .PARM_PLL_POWERUP(PMA_PLL0_PARM_PLL_POWERUP)  // 使能选项：开启或关闭。
            ) U_GTP_HSSTLP_PLL0 (
                // SRB 相关信号
                .P_CFG_READY_PLL  (P_CFG_READY_PLL_0),
                .P_CFG_RDATA_PLL  (P_CFG_RDATA_PLL_0),
                .P_CFG_INT_PLL    (P_CFG_INT_PLL_0),
                .P_RESCAL_I_CODE_O(P_RESCAL_I_CODE_O_0),
                .P_REFCK2CORE     (P_REFCK2CORE_0),
                .P_PLL_READY      (P_PLL_READY_0),

                .PLL_CLK0             (PLL_CLK0_0),
                .PLL_CLK90            (PLL_CLK90_0),
                .PLL_CLK180           (PLL_CLK180_0),
                .PLL_CLK270           (PLL_CLK270_0),
                .SYNC_PLL             (SYNC_PLL_0),
                .RATE_CHANGE_PLL      (RATE_CHANGE_PLL_0),
                .PLL_PD_O             (PLL_PD_O_0),
                .PLL_RST_O            (PLL_RST_O_0),
                .PMA_PLL_READY_O      (PMA_PLL_READY_O_0),
                .PLL_REFCLK_LANE_L    (PLL_REFCLK_LANE_L_0),
                // SRB 相关信号
                .P_CFG_RST_PLL        (P_CFG_RST_PLL_0),
                .P_CFG_CLK_PLL        (P_CFG_CLK_PLL_0),
                .P_CFG_PSEL_PLL       (P_CFG_PSEL_PLL_0),
                .P_CFG_ENABLE_PLL     (P_CFG_ENABLE_PLL_0),
                .P_CFG_WRITE_PLL      (P_CFG_WRITE_PLL_0),
                .P_CFG_ADDR_PLL       (P_CFG_ADDR_PLL_0),
                .P_CFG_WDATA_PLL      (P_CFG_WDATA_PLL_0),
                .P_RESCAL_RST_I       (P_RESCAL_RST_I_0),
                .P_RESCAL_I_CODE_I    (P_RESCAL_I_CODE_I_0),
                .P_PLL_LOCKDET_RST_I  (P_PLL_LOCKDET_RST_I_0),
                .P_PLL_REF_CLK        (P_PLL_REF_CLK_0),
                .P_PLL_RST            (P_PLL_RST_0),
                .P_PLLPOWERDOWN       (P_PLLPOWERDOWN_0),
                .P_LANE_SYNC          (P_LANE_SYNC_0),
                .P_RATE_CHANGE_TCLK_ON(P_RATE_CHANGE_TCLK_ON_0),
                // 引脚相关信号
                .REFCLK_CML_N         (REFCLK_CML_N_0),
                .REFCLK_CML_P         (REFCLK_CML_P_0),
                .TXPCLK_PLL_SELECTED  (TXPCLK_PLL_SELECTED_0)
            );
        end else begin : PLL0_NULL
            assign P_CFG_READY_PLL_0   = 1'b0;
            assign P_CFG_RDATA_PLL_0   = 8'b0;
            assign P_CFG_INT_PLL_0     = 1'b0;
            assign P_RESCAL_I_CODE_O_0 = 6'b0;
            assign P_REFCK2CORE_0      = 1'b0;
            assign P_PLL_READY_0       = 1'b0;
            assign PLL_CLK0_0          = 1'b0;
            assign PLL_CLK90_0         = 1'b0;
            assign PLL_CLK180_0        = 1'b0;
            assign PLL_CLK270_0        = 1'b0;
            assign SYNC_PLL_0          = 1'b0;
            assign RATE_CHANGE_PLL_0   = 1'b0;
            assign PLL_PD_O_0          = 1'b0;
            assign PLL_RST_O_0         = 1'b0;
            assign PMA_PLL_READY_O_0   = 1'b0;
            assign PLL_REFCLK_LANE_L_0 = 1'b0;
        end
    endgenerate

    // PLL1 例化
    generate
        if (PLL1_EN == "TRUE") begin : PLL1_ENABLE
            GTP_HSSTLP_PLL #(
                .TX_SYNCK_PD(PMA_PLL1_TX_SYNCK_PD),  // 发送同步电荷泵控制：0 上电，1 掉电。
                .PMA_PLL_REG_REFCLK_TERM_IMP_CTRL       (PMA_PLL1_REG_REFCLK_TERM_IMP_CTRL     ),// 参考时钟终端阻抗选择，不支持仿真。

                .PMA_PLL_REG_BG_TRIM(PMA_PLL1_REG_BG_TRIM),  // 电压电流转换配置，不支持仿真。
                .PMA_PLL_REG_IBUP_A1(PMA_PLL1_REG_IBUP_A1),  // 电压电流转换配置，不支持仿真。
                .PMA_PLL_REG_IBUP_A2(PMA_PLL1_REG_IBUP_A2),  // 电压电流转换配置，不支持仿真。
                .PMA_PLL_REG_IBUP_PD(PMA_PLL1_REG_IBUP_PD),  // 电压电流转换配置，不支持仿真。
                .PMA_PLL_REG_V2I_BIAS_SEL(PMA_PLL1_REG_V2I_BIAS_SEL),  // 电压电流转换配置，不支持仿真。
                .PMA_PLL_REG_V2I_EN(PMA_PLL1_REG_V2I_EN),  // 电压电流转换配置，不支持仿真。
                .PMA_PLL_REG_V2I_TB_SEL(PMA_PLL1_REG_V2I_TB_SEL),  // 电压电流转换配置，不支持仿真。
                .PMA_PLL_REG_V2I_RCALTEST_PD            (PMA_PLL1_REG_V2I_RCALTEST_PD          ),// 电压电流转换配置，不支持仿真。
                .PMA_PLL_REG_RES_CAL_TEST(PMA_PLL1_REG_RES_CAL_TEST),  // 电压电流转换配置，不支持仿真。
                .PMA_RES_CAL_DIV(PMA_PLL1_RES_CAL_DIV),  // 电压电流转换配置，不支持仿真。
                .PMA_RES_CAL_CLK_SEL(PMA_PLL1_RES_CAL_CLK_SEL),  // 电压电流转换配置，不支持仿真。

                .PMA_PLL_REG_PLL_PFDDELAY_EN(PMA_PLL1_REG_PLL_PFDDELAY_EN),  // 使能选项：开启或关闭。
                .PMA_PLL_REG_PFDDELAYSEL(PMA_PLL1_REG_PFDDELAYSEL),
                .PMA_PLL_REG_PLL_VCTRL_SET(PMA_PLL1_REG_PLL_VCTRL_SET),
                .PMA_PLL_REG_READY_OR_LOCK(PMA_PLL1_REG_READY_OR_LOCK),  // 使能选项：开启或关闭。
                .PMA_PLL_REG_PLL_CP(PMA_PLL1_REG_PLL_CP),  // 电流配置范围：1～1023，默认 31。
                .PMA_PLL_REG_PLL_REFDIV(PMA_PLL1_REG_PLL_REFDIV),  // PLL 参考时钟分频 M，默认 16。
                .PMA_PLL_REG_PLL_LOCKDET_EN(PMA_PLL1_REG_PLL_LOCKDET_EN),  // 使能选项：开启或关闭。
                .PMA_PLL_REG_PLL_READY(PMA_PLL1_REG_PLL_READY),  // 使能选项：开启或关闭。
                .PMA_PLL_REG_PLL_READY_OW(PMA_PLL1_REG_PLL_READY_OW),  // 使能选项：开启或关闭。
                .PMA_PLL_REG_PLL_FBDIV                  (PMA_PLL1_REG_PLL_FBDIV                ),// PLL 反馈分频 N2 由 Pll_fbdiv[5] 决定：1 对应 5，0 对应 4。
                                                                                                 // PLL 反馈分频 N1 可取 1、2、3、4、5、6、8、10。
                .PMA_PLL_REG_LPF_RES(PMA_PLL1_REG_LPF_RES),  // 低通滤波电阻控制，默认 1。
                .PMA_PLL_REG_JTAG_OE(PMA_PLL1_REG_JTAG_OE),  // PLL JTAG 输出使能
                .PMA_PLL_REG_JTAG_VHYSTSEL(PMA_PLL1_REG_JTAG_VHYSTSEL),  // PLL JTAG 门限电压选择，默认 0。
                .PMA_PLL_REG_PLL_LOCKDET_EN_OW(PMA_PLL1_REG_PLL_LOCKDET_EN_OW),  // 使能选项：开启或关闭。
                .PMA_PLL_REG_PLL_LOCKDET_FBCT           (PMA_PLL1_REG_PLL_LOCKDET_FBCT         ),// 计数编码 0～7 分别对应 2^9～2^15、2^16−1，默认编码 7。
                .PMA_PLL_REG_PLL_LOCKDET_ITER           (PMA_PLL1_REG_PLL_LOCKDET_ITER         ),// 编码 0～7 对应 1、2、4、8、16、32、64、127，默认编码 3。
                .PMA_PLL_REG_PLL_LOCKDET_MODE(PMA_PLL1_REG_PLL_LOCKDET_MODE),  // 使能选项：开启或关闭。
                .PMA_PLL_REG_PLL_LOCKDET_LOCKCT         (PMA_PLL1_REG_PLL_LOCKDET_LOCKCT       ),// 编码 0～7 对应 2、4、8、16、32、64、128、256，默认编码 4。
                .PMA_PLL_REG_PLL_LOCKDET_REFCT          (PMA_PLL1_REG_PLL_LOCKDET_REFCT        ),// 计数编码 0～7 分别对应 2^9～2^15、2^16−1，默认编码 7。
                .PMA_PLL_REG_PLL_LOCKDET_RESET_N        (PMA_PLL1_REG_PLL_LOCKDET_RESET_N      ),// 使能选项：开启或关闭。
                .PMA_PLL_REG_PLL_LOCKDET_RESET_N_OW     (PMA_PLL1_REG_PLL_LOCKDET_RESET_N_OW   ),// 使能选项：开启或关闭。
                .PMA_PLL_REG_PLL_LOCKED(PMA_PLL1_REG_PLL_LOCKED),  // 使能选项：开启或关闭。
                .PMA_PLL_REG_PLL_LOCKED_OW(PMA_PLL1_REG_PLL_LOCKED_OW),  // 使能选项：开启或关闭。
                .PMA_PLL_REG_PLL_LOCKED_STICKY_CLEAR    (PMA_PLL1_REG_PLL_LOCKED_STICKY_CLEAR  ),// 使能选项：开启或关闭。
                .PMA_PLL_REG_PLL_UNLOCKED(PMA_PLL1_REG_PLL_UNLOCKED),  // 使能选项：开启或关闭。
                .PMA_PLL_REG_PLL_UNLOCKDET_ITER         (PMA_PLL1_REG_PLL_UNLOCKDET_ITER       ),// 编码 00、01、10、11 对应 63、127、255、1023，默认编码 10。
                .PMA_PLL_REG_PLL_UNLOCKED_OW(PMA_PLL1_REG_PLL_UNLOCKED_OW),  // 使能选项：开启或关闭。
                .PMA_PLL_REG_PLL_UNLOCKED_STICKY_CLEAR  (PMA_PLL1_REG_PLL_UNLOCKED_STICKY_CLEAR),// 使能选项：开启或关闭。
                .PMA_PLL_REG_I_CTRL_MAX(PMA_PLL1_REG_I_CTRL_MAX),  // 取值范围：0～63，默认全 1。
                .PMA_PLL_REG_REFCLK_TEST_EN(PMA_PLL1_REG_REFCLK_TEST_EN),  // 参考时钟端口测试使能
                .PMA_PLL_REG_RESCAL_EN(PMA_PLL1_REG_RESCAL_EN),  // 使能选项：开启或关闭。
                .PMA_PLL_REG_I_CTRL_MIN(PMA_PLL1_REG_I_CTRL_MIN),  // 取值范围：0～63。
                .PMA_PLL_REG_RESCAL_DONE_OW(PMA_PLL1_REG_RESCAL_DONE_OW),  // 使能选项：开启或关闭。
                .PMA_PLL_REG_RESCAL_DONE_VAL(PMA_PLL1_REG_RESCAL_DONE_VAL),  // 使能选项：开启或关闭。
                .PMA_PLL_REG_RESCAL_I_CODE(PMA_PLL1_REG_RESCAL_I_CODE),  // 取值范围：0～63。
                .PMA_PLL_REG_RESCAL_I_CODE_OW(PMA_PLL1_REG_RESCAL_I_CODE_OW),  // 使能选项：开启或关闭。
                .PMA_PLL_REG_RESCAL_I_CODE_PMA(PMA_PLL1_REG_RESCAL_I_CODE_PMA),  // 使能选项：开启或关闭。
                .PMA_PLL_REG_RESCAL_I_CODE_VAL(PMA_PLL1_REG_RESCAL_I_CODE_VAL),  // 取值范围：0～63。
                .PMA_PLL_REG_RESCAL_INT_R_SMALL_OW      (PMA_PLL1_REG_RESCAL_INT_R_SMALL_OW    ),// 使能选项：开启或关闭。
                .PMA_PLL_REG_RESCAL_INT_R_SMALL_VAL     (PMA_PLL1_REG_RESCAL_INT_R_SMALL_VAL   ),// 使能选项：开启或关闭。
                .PMA_PLL_REG_RESCAL_ITER_VALID_SEL(PMA_PLL1_REG_RESCAL_ITER_VALID_SEL),  //0,1,2,3
                .PMA_PLL_REG_RESCAL_RESET_N_OW(PMA_PLL1_REG_RESCAL_RESET_N_OW),  // 使能选项：开启或关闭。
                .PMA_PLL_REG_RESCAL_RST_N_VAL(PMA_PLL1_REG_RESCAL_RST_N_VAL),  // 使能选项：开启或关闭。
                .PMA_PLL_REG_RESCAL_WAIT_SEL(PMA_PLL1_REG_RESCAL_WAIT_SEL),  // 使能选项：开启或关闭。
                .PMA_PLL_REFCLK2LANE_PD_L(PMA_PLL1_REFCLK2LANE_PD_L),  // 左侧 PLL 参考时钟掉电控制
                .PMA_PLL_REFCLK2LANE_PD_R(PMA_PLL1_REFCLK2LANE_PD_R),  // 右侧 PLL 参考时钟掉电控制
                .PMA_PLL_REG_LOCKDET_REPEAT(PMA_PLL1_REG_LOCKDET_REPEAT),  // 使能选项：开启或关闭。
                .PMA_PLL_REG_NOFBCLK_STICKY_CLEAR       (PMA_PLL1_REG_NOFBCLK_STICKY_CLEAR     ),// 使能选项：开启或关闭。
                .PMA_PLL_REG_NOREFCLK_STICKY_CLEAR      (PMA_PLL1_REG_NOREFCLK_STICKY_CLEAR    ),// 使能选项：开启或关闭。
                .PMA_PLL_REG_TEST_SEL(PMA_PLL1_REG_TEST_SEL),  // 测试取值范围：0～20。
                .PMA_PLL_REG_TEST_V_EN(PMA_PLL1_REG_TEST_V_EN),  // 测试使能
                .PMA_PLL_REG_TEST_SIG_HALF_EN(PMA_PLL1_REG_TEST_SIG_HALF_EN),  // 测试使能
                .PMA_PLL_REG_REFCLK_PAD_SEL(PMA_PLL1_REG_REFCLK_PAD_SEL),  // 参考时钟选择
                .PARM_PLL_POWERUP(PMA_PLL1_PARM_PLL_POWERUP)  // 使能选项：开启或关闭。
            ) U_GTP_HSSTLP_PLL1 (
                // SRB 相关信号
                .P_CFG_READY_PLL  (P_CFG_READY_PLL_1),
                .P_CFG_RDATA_PLL  (P_CFG_RDATA_PLL_1),
                .P_CFG_INT_PLL    (P_CFG_INT_PLL_1),
                .P_RESCAL_I_CODE_O(P_RESCAL_I_CODE_O_1),
                .P_REFCK2CORE     (P_REFCK2CORE_1),
                .P_PLL_READY      (P_PLL_READY_1),

                .PLL_CLK0             (PLL_CLK0_1),
                .PLL_CLK90            (PLL_CLK90_1),
                .PLL_CLK180           (PLL_CLK180_1),
                .PLL_CLK270           (PLL_CLK270_1),
                .SYNC_PLL             (SYNC_PLL_1),
                .RATE_CHANGE_PLL      (RATE_CHANGE_PLL_1),
                .PLL_PD_O             (PLL_PD_O_1),
                .PLL_RST_O            (PLL_RST_O_1),
                .PMA_PLL_READY_O      (PMA_PLL_READY_O_1),
                .PLL_REFCLK_LANE_L    (PLL_REFCLK_LANE_L_1),
                // SRB 相关信号
                .P_CFG_RST_PLL        (P_CFG_RST_PLL_1),
                .P_CFG_CLK_PLL        (P_CFG_CLK_PLL_1),
                .P_CFG_PSEL_PLL       (P_CFG_PSEL_PLL_1),
                .P_CFG_ENABLE_PLL     (P_CFG_ENABLE_PLL_1),
                .P_CFG_WRITE_PLL      (P_CFG_WRITE_PLL_1),
                .P_CFG_ADDR_PLL       (P_CFG_ADDR_PLL_1),
                .P_CFG_WDATA_PLL      (P_CFG_WDATA_PLL_1),
                .P_RESCAL_RST_I       (P_RESCAL_RST_I_1),
                .P_RESCAL_I_CODE_I    (P_RESCAL_I_CODE_I_1),
                .P_PLL_LOCKDET_RST_I  (P_PLL_LOCKDET_RST_I_1),
                .P_PLL_REF_CLK        (P_PLL_REF_CLK_1),
                .P_PLL_RST            (P_PLL_RST_1),
                .P_PLLPOWERDOWN       (P_PLLPOWERDOWN_1),
                .P_LANE_SYNC          (P_LANE_SYNC_1),
                .P_RATE_CHANGE_TCLK_ON(P_RATE_CHANGE_TCLK_ON_1),
                // 引脚相关信号
                .REFCLK_CML_N         (REFCLK_CML_N_1),
                .REFCLK_CML_P         (REFCLK_CML_P_1),
                .TXPCLK_PLL_SELECTED  (TXPCLK_PLL_SELECTED_1)
            );
        end else begin : PLL1_NULL
            assign P_CFG_READY_PLL_1   = 1'b0;
            assign P_CFG_RDATA_PLL_1   = 8'b0;
            assign P_CFG_INT_PLL_1     = 1'b0;
            assign P_RESCAL_I_CODE_O_1 = 6'b0;
            assign P_REFCK2CORE_1      = 1'b0;
            assign P_PLL_READY_1       = 1'b0;
            assign PLL_CLK0_1          = 1'b0;
            assign PLL_CLK90_1         = 1'b0;
            assign PLL_CLK180_1        = 1'b0;
            assign PLL_CLK270_1        = 1'b0;
            assign SYNC_PLL_1          = 1'b0;
            assign RATE_CHANGE_PLL_1   = 1'b0;
            assign PLL_PD_O_1          = 1'b0;
            assign PLL_RST_O_1         = 1'b0;
            assign PMA_PLL_READY_O_1   = 1'b0;
            assign PLL_REFCLK_LANE_L_1 = 1'b0;
        end
    endgenerate

    // 通道 0 例化
    generate
        if (CHANNEL0_EN == "TRUE") begin : CHANNEL0_ENABLE
            GTP_HSSTLP_LANE #(
                .MUX_BIAS      (CH0_MUX_BIAS),       // 取值范围：0～7，不支持仿真。
                .PD_CLK        (CH0_PD_CLK),         // 取值范围：0～1。
                .REG_SYNC      (CH0_REG_SYNC),       // 取值范围：0～1。
                .REG_SYNC_OW   (CH0_REG_SYNC_OW),    // 取值范围：0～1。
                .PLL_LOCK_OW   (CH0_PLL_LOCK_OW),    // 取值范围：0～1。
                .PLL_LOCK_OW_EN(CH0_PLL_LOCK_OW_EN), // 取值范围：0～1。

                .PCS_SLAVE(PCS_CH0_SLAVE),
                .PCS_BYPASS_WORD_ALIGN(PCS_CH0_BYPASS_WORD_ALIGN),  // 字对齐旁路使能
                .PCS_BYPASS_DENC(PCS_CH0_BYPASS_DENC),  // 8b/10b 解码旁路使能
                .PCS_BYPASS_BONDING(PCS_CH0_BYPASS_BONDING),  // 通道绑定旁路使能
                .PCS_BYPASS_CTC(PCS_CH0_BYPASS_CTC),  // 时钟补偿旁路使能
                .PCS_BYPASS_GEAR(PCS_CH0_BYPASS_GEAR),  // 接收齿轮箱旁路使能
                .PCS_BYPASS_BRIDGE(PCS_CH0_BYPASS_BRIDGE),  // 接收桥接单元旁路使能
                .PCS_BYPASS_BRIDGE_FIFO(PCS_CH0_BYPASS_BRIDGE_FIFO),  // 接收桥接 FIFO 旁路使能
                .PCS_DATA_MODE(PCS_CH0_DATA_MODE),  // 参数选项："X8","X10","X16","X20"
                .PCS_RX_POLARITY_INV                         (PCS_CH0_RX_POLARITY_INV                           ),// 数据变换：延迟、位极性反转、位序反转或两者同时反转。
                .PCS_ALIGN_MODE(PCS_CH0_ALIGN_MODE),  // 协议模式：1GB、10GB、RAPIDIO 或外部模式。
                .PCS_SAMP_16B(PCS_CH0_SAMP_16B),  // 参数选项："X20",X16
                .PCS_FARLP_PWR_REDUCTION(PCS_CH0_FARLP_PWR_REDUCTION),  // 使能选项：开启或关闭。
                .PCS_COMMA_REG0(PCS_CH0_COMMA_REG0),  // 取值范围：0～1023。
                .PCS_COMMA_MASK(PCS_CH0_COMMA_MASK),  // 取值范围：0～1023。
                .PCS_CEB_MODE(PCS_CH0_CEB_MODE),  // 协议模式：10GB、RAPIDIO 或外部模式。
                .PCS_CTC_MODE                                (PCS_CH0_CTC_MODE                                  ),// 跳过字符模式：单字符、双字符、PCIe 双字节或四字符。
                .PCS_A_REG(PCS_CH0_A_REG),  // 取值范围：0～255。
                .PCS_GE_AUTO_EN(PCS_CH0_GE_AUTO_EN),  // 使能选项：开启或关闭。
                .PCS_SKIP_REG0(PCS_CH0_SKIP_REG0),  // 取值范围：0～1023。
                .PCS_SKIP_REG1(PCS_CH0_SKIP_REG1),  // 取值范围：0～1023。
                .PCS_SKIP_REG2(PCS_CH0_SKIP_REG2),  // 取值范围：0～1023。
                .PCS_SKIP_REG3(PCS_CH0_SKIP_REG3),  // 取值范围：0～1023。
                .PCS_DEC_DUAL(PCS_CH0_DEC_DUAL),  // 使能选项：开启或关闭。
                .PCS_SPLIT(PCS_CH0_SPLIT),  // 使能选项：开启或关闭。
                .PCS_FIFOFLAG_CTC(PCS_CH0_FIFOFLAG_CTC),  // 使能选项：开启或关闭。
                .PCS_COMMA_DET_MODE(PCS_CH0_COMMA_DET_MODE),  // 参数选项："RX_CLK_SLIP" "COMMA_PATTERN"
                .PCS_ERRDETECT_SILENCE(PCS_CH0_ERRDETECT_SILENCE),  // 使能选项：开启或关闭。
                .PCS_PMA_RCLK_POLINV(PCS_CH0_PMA_RCLK_POLINV),  // 参数选项："PMA_RCLK" "REVERSE_OF_PMA_RCLK"
                .PCS_PCS_RCLK_SEL(PCS_CH0_PCS_RCLK_SEL),  // 参数选项："PMA_RCLK" "PMA_TCLK" "RCLK"
                .PCS_CB_RCLK_SEL(PCS_CH0_CB_RCLK_SEL),  // 参数选项："PMA_RCLK" "PMA_TCLK" "MCB_RCLK"
                .PCS_AFTER_CTC_RCLK_SEL                      (PCS_CH0_AFTER_CTC_RCLK_SEL                        ),// 参数选项："PMA_RCLK" "PMA_TCLK" "MCB_RCLK" "RCLK2"
                .PCS_RCLK_POLINV(PCS_CH0_RCLK_POLINV),  // 参数选项："RCLK" "REVERSE_OF_RCLK"
                .PCS_BRIDGE_RCLK_SEL                         (PCS_CH0_BRIDGE_RCLK_SEL                           ),// 参数选项："PMA_RCLK" "PMA_TCLK" "MCB_RCLK" "RCLK"
                .PCS_PCS_RCLK_EN(PCS_CH0_PCS_RCLK_EN),  // 使能选项：开启或关闭。
                .PCS_CB_RCLK_EN(PCS_CH0_CB_RCLK_EN),  // 使能选项：开启或关闭。
                .PCS_AFTER_CTC_RCLK_EN(PCS_CH0_AFTER_CTC_RCLK_EN),  // 使能选项：开启或关闭。
                .PCS_AFTER_CTC_RCLK_EN_GB(PCS_CH0_AFTER_CTC_RCLK_EN_GB),  // 使能选项：开启或关闭。
                .PCS_PCS_RX_RSTN(PCS_CH0_PCS_RX_RSTN),  // PCS 接收端复位控制
                .PCS_PCIE_SLAVE(PCS_CH0_PCIE_SLAVE),  // 通道角色：主通道或从通道。
                .PCS_RX_64B66B_67B(PCS_CH0_RX_64B66B_67B),  // 编码模式：普通、64b/66b 或 64b/67b。
                .PCS_RX_BRIDGE_CLK_POLINV                    (PCS_CH0_RX_BRIDGE_CLK_POLINV                      ),// 参数选项："RX_BRIDGE_CLK" "REVERSE_OF_RX_BRIDGE_CLK"
                .PCS_PCS_CB_RSTN(PCS_CH0_PCS_CB_RSTN),  // PCS 通道绑定复位控制
                .PCS_TX_BRIDGE_GEAR_SEL                      (PCS_CH0_TX_BRIDGE_GEAR_SEL                        ),// TRUE 优先使用发送齿轮箱，FALSE 优先使用发送桥接单元。
                .PCS_TX_BYPASS_BRIDGE_UINT(PCS_CH0_TX_BYPASS_BRIDGE_UINT),  // 旁路使能
                .PCS_TX_BYPASS_BRIDGE_FIFO(PCS_CH0_TX_BYPASS_BRIDGE_FIFO),  // 发送桥接 FIFO 旁路使能
                .PCS_TX_BYPASS_GEAR(PCS_CH0_TX_BYPASS_GEAR),  // 使能选项：开启或关闭。
                .PCS_TX_BYPASS_ENC(PCS_CH0_TX_BYPASS_ENC),  // 使能选项：开启或关闭。
                .PCS_TX_BYPASS_BIT_SLIP(PCS_CH0_TX_BYPASS_BIT_SLIP),  // 使能选项：开启或关闭。
                .PCS_TX_GEAR_SPLIT(PCS_CH0_TX_GEAR_SPLIT),  // 使能选项：开启或关闭。
                .PCS_TX_DRIVE_REG_MODE                       (PCS_CH0_TX_DRIVE_REG_MODE                         ),// 变换选项：不变、极性反转、位序反转或两者同时反转。
                .PCS_TX_BIT_SLIP_CYCLES(PCS_CH0_TX_BIT_SLIP_CYCLES),  // 取值范围：0～31。
                .PCS_INT_TX_MASK_0(PCS_CH0_INT_TX_MASK_0),  // 使能选项：开启或关闭。
                .PCS_INT_TX_MASK_1(PCS_CH0_INT_TX_MASK_1),  // 使能选项：开启或关闭。
                .PCS_INT_TX_MASK_2(PCS_CH0_INT_TX_MASK_2),  // 使能选项：开启或关闭。
                .PCS_INT_TX_CLR_0(PCS_CH0_INT_TX_CLR_0),  // 使能选项：开启或关闭。
                .PCS_INT_TX_CLR_1(PCS_CH0_INT_TX_CLR_1),  // 使能选项：开启或关闭。
                .PCS_INT_TX_CLR_2(PCS_CH0_INT_TX_CLR_2),  // 使能选项：开启或关闭。
                .PCS_TX_PMA_TCLK_POLINV(PCS_CH0_TX_PMA_TCLK_POLINV),  // 参数选项："PMA_TCLK" "REVERSE_OF_PMA_TCLK"
                .PCS_TX_PCS_CLK_EN_SEL(PCS_CH0_TX_PCS_CLK_EN_SEL),  // 使能选项：开启或关闭。
                .PCS_TX_BRIDGE_TCLK_SEL(PCS_CH0_TX_BRIDGE_TCLK_SEL),  // 参数选项："PCS_TCLK" "TCLK"
                .PCS_TX_TCLK_POLINV(PCS_CH0_TX_TCLK_POLINV),  // 参数选项："TCLK" "REVERSE_OF_TCLK"
                .PCS_PCS_TCLK_SEL(PCS_CH0_PCS_TCLK_SEL),  // 参数选项："PMA_TCLK" "TCLK"
                .PCS_TX_PCS_TX_RSTN(PCS_CH0_TX_PCS_TX_RSTN),  // PCS 发送端复位控制
                .PCS_TX_SLAVE(PCS_CH0_TX_SLAVE),  // 通道角色：主通道或从通道。
                .PCS_TX_GEAR_CLK_EN_SEL(PCS_CH0_TX_GEAR_CLK_EN_SEL),  // 使能选项：开启或关闭。
                .PCS_DATA_WIDTH_MODE(PCS_CH0_DATA_WIDTH_MODE),  // 参数选项："X8" "X10" "X16" "X20"
                .PCS_TX_64B66B_67B(PCS_CH0_TX_64B66B_67B),  // 编码模式：普通、64b/66b 或 64b/67b。
                .PCS_GEAR_TCLK_SEL(PCS_CH0_GEAR_TCLK_SEL),  // 参数选项："PMA_TCLK" "TCLK2"
                .PCS_TX_TCLK2FABRIC_SEL(PCS_CH0_TX_TCLK2FABRIC_SEL),  // 使能选项：开启或关闭。
                .PCS_TX_OUTZZ(PCS_CH0_TX_OUTZZ),  // 使能选项：开启或关闭。
                .PCS_ENC_DUAL(PCS_CH0_ENC_DUAL),  // 使能选项：开启或关闭。
                .PCS_TX_BITSLIP_DATA_MODE(PCS_CH0_TX_BITSLIP_DATA_MODE),  // 参数选项："X10" "X20"
                .PCS_TX_BRIDGE_CLK_POLINV                    (PCS_CH0_TX_BRIDGE_CLK_POLINV                      ),// 参数选项："TX_BRIDGE_CLK" "REVERSE_OF_TX_BRIDGE_CLK"
                .PCS_COMMA_REG1(PCS_CH0_COMMA_REG1),  // 取值范围：0～1023。
                .PCS_RAPID_IMAX(PCS_CH0_RAPID_IMAX),  // 取值范围：0～7。
                .PCS_RAPID_VMIN_1(PCS_CH0_RAPID_VMIN_1),  // 取值范围：0～255。
                .PCS_RAPID_VMIN_2(PCS_CH0_RAPID_VMIN_2),  // 取值范围：0～255。
                .PCS_RX_PRBS_MODE                            (PCS_CH0_RX_PRBS_MODE                              ),// PRBS 配置：关闭或选择 7、15、23、31 阶多项式。
                .PCS_RX_ERRCNT_CLR(PCS_CH0_RX_ERRCNT_CLR),  // 使能选项：开启或关闭。
                .PCS_PRBS_ERR_LPBK(PCS_CH0_PRBS_ERR_LPBK),  // 使能选项：开启或关闭。
                .PCS_TX_PRBS_MODE                            (PCS_CH0_TX_PRBS_MODE                              ),// 测试码型：PRBS、长 1、长 0、20 UI、D10.2 或 PCIe。
                .PCS_TX_INSERT_ER(PCS_CH0_TX_INSERT_ER),  // 使能选项：开启或关闭。
                .PCS_ENABLE_PRBS_GEN(PCS_CH0_ENABLE_PRBS_GEN),  // 使能选项：开启或关闭。
                .PCS_DEFAULT_RADDR(PCS_CH0_DEFAULT_RADDR),  // 取值范围：0～15。
                .PCS_MASTER_CHECK_OFFSET(PCS_CH0_MASTER_CHECK_OFFSET),  // 取值范围：0～15。
                .PCS_DELAY_SET(PCS_CH0_DELAY_SET),  // 取值范围：0～15。
                .PCS_SEACH_OFFSET(PCS_CH0_SEACH_OFFSET),  // 绑定位宽：20～80 位，间隔 10 位。
                .PCS_CEB_RAPIDLS_MMAX(PCS_CH0_CEB_RAPIDLS_MMAX),  // 取值范围：0～7。
                .PCS_CTC_AFULL(PCS_CH0_CTC_AFULL),  // 取值范围：0～31。
                .PCS_CTC_AEMPTY(PCS_CH0_CTC_AEMPTY),  // 取值范围：0～31。
                .PCS_CTC_CONTI_SKP_SET(PCS_CH0_CTC_CONTI_SKP_SET),  // 取值范围：0～1。
                .PCS_FAR_LOOP(PCS_CH0_FAR_LOOP),  // 使能选项：开启或关闭。
                .PCS_NEAR_LOOP(PCS_CH0_NEAR_LOOP),  // 使能选项：开启或关闭。
                .PCS_PMA_TX2RX_PLOOP_EN(PCS_CH0_PMA_TX2RX_PLOOP_EN),  // 使能选项：开启或关闭。
                .PCS_PMA_TX2RX_SLOOP_EN(PCS_CH0_PMA_TX2RX_SLOOP_EN),  // 使能选项：开启或关闭。
                .PCS_PMA_RX2TX_PLOOP_EN(PCS_CH0_PMA_RX2TX_PLOOP_EN),  // 使能选项：开启或关闭。
                .PCS_INT_RX_MASK_0(PCS_CH0_INT_RX_MASK_0),  // 使能选项：开启或关闭。
                .PCS_INT_RX_MASK_1(PCS_CH0_INT_RX_MASK_1),  // 使能选项：开启或关闭。
                .PCS_INT_RX_MASK_2(PCS_CH0_INT_RX_MASK_2),  // 使能选项：开启或关闭。
                .PCS_INT_RX_MASK_3(PCS_CH0_INT_RX_MASK_3),  // 使能选项：开启或关闭。
                .PCS_INT_RX_MASK_4(PCS_CH0_INT_RX_MASK_4),  // 使能选项：开启或关闭。
                .PCS_INT_RX_MASK_5(PCS_CH0_INT_RX_MASK_5),  // 使能选项：开启或关闭。
                .PCS_INT_RX_MASK_6(PCS_CH0_INT_RX_MASK_6),  // 使能选项：开启或关闭。
                .PCS_INT_RX_MASK_7(PCS_CH0_INT_RX_MASK_7),  // 使能选项：开启或关闭。
                .PCS_INT_RX_CLR_0(PCS_CH0_INT_RX_CLR_0),  // 使能选项：开启或关闭。
                .PCS_INT_RX_CLR_1(PCS_CH0_INT_RX_CLR_1),  // 使能选项：开启或关闭。
                .PCS_INT_RX_CLR_2(PCS_CH0_INT_RX_CLR_2),  // 使能选项：开启或关闭。
                .PCS_INT_RX_CLR_3(PCS_CH0_INT_RX_CLR_3),  // 使能选项：开启或关闭。
                .PCS_INT_RX_CLR_4(PCS_CH0_INT_RX_CLR_4),  // 使能选项：开启或关闭。
                .PCS_INT_RX_CLR_5(PCS_CH0_INT_RX_CLR_5),  // 使能选项：开启或关闭。
                .PCS_INT_RX_CLR_6(PCS_CH0_INT_RX_CLR_6),  // 使能选项：开启或关闭。
                .PCS_INT_RX_CLR_7(PCS_CH0_INT_RX_CLR_7),  // 使能选项：开启或关闭。
                .PCS_CA_RSTN_RX(PCS_CH0_CA_RSTN_RX),  // 接收时钟对齐器复位控制
                .PCS_CA_DYN_DLY_EN_RX(PCS_CH0_CA_DYN_DLY_EN_RX),  // 使能选项：开启或关闭。
                .PCS_CA_DYN_DLY_SEL_RX(PCS_CH0_CA_DYN_DLY_SEL_RX),  // 使能选项：开启或关闭。
                .PCS_CA_RX(PCS_CH0_CA_RX),  // 取值范围：0～255。
                .PCS_CA_RSTN_TX(PCS_CH0_CA_RSTN_TX),  // 使能选项：开启或关闭。
                .PCS_CA_DYN_DLY_EN_TX(PCS_CH0_CA_DYN_DLY_EN_TX),  // 使能选项：开启或关闭。
                .PCS_CA_DYN_DLY_SEL_TX(PCS_CH0_CA_DYN_DLY_SEL_TX),  // 使能选项：开启或关闭。
                .PCS_CA_TX(PCS_CH0_CA_TX),  // 取值范围：0～255。
                .PCS_RXPRBS_PWR_REDUCTION(PCS_CH0_RXPRBS_PWR_REDUCTION),  // 工作模式：普通或低功耗。
                .PCS_WDALIGN_PWR_REDUCTION(PCS_CH0_WDALIGN_PWR_REDUCTION),  // 工作模式：普通或低功耗。
                .PCS_RXDEC_PWR_REDUCTION(PCS_CH0_RXDEC_PWR_REDUCTION),  // 工作模式：普通或低功耗。
                .PCS_RXCB_PWR_REDUCTION(PCS_CH0_RXCB_PWR_REDUCTION),  // 工作模式：普通或低功耗。
                .PCS_RXCTC_PWR_REDUCTION(PCS_CH0_RXCTC_PWR_REDUCTION),  // 工作模式：普通或低功耗。
                .PCS_RXGEAR_PWR_REDUCTION(PCS_CH0_RXGEAR_PWR_REDUCTION),  // 工作模式：普通或低功耗。
                .PCS_RXBRG_PWR_REDUCTION(PCS_CH0_RXBRG_PWR_REDUCTION),  // 工作模式：普通或低功耗。
                .PCS_RXTEST_PWR_REDUCTION(PCS_CH0_RXTEST_PWR_REDUCTION),  // 工作模式：普通或低功耗。
                .PCS_TXBRG_PWR_REDUCTION(PCS_CH0_TXBRG_PWR_REDUCTION),  // 工作模式：普通或低功耗。
                .PCS_TXGEAR_PWR_REDUCTION(PCS_CH0_TXGEAR_PWR_REDUCTION),  // 工作模式：普通或低功耗。
                .PCS_TXENC_PWR_REDUCTION(PCS_CH0_TXENC_PWR_REDUCTION),  // 工作模式：普通或低功耗。
                .PCS_TXBSLP_PWR_REDUCTION(PCS_CH0_TXBSLP_PWR_REDUCTION),  // 工作模式：普通或低功耗。
                .PCS_TXPRBS_PWR_REDUCTION(PCS_CH0_TXPRBS_PWR_REDUCTION),  // 工作模式：普通或低功耗。

                .PMA_REG_RX_PD(PMA_CH0_REG_RX_PD),  // 使能选项：开启或关闭。
                .PMA_REG_RX_PD_EN(PMA_CH0_REG_RX_PD_EN),  // 使能选项：开启或关闭。
                .PMA_REG_RX_RESERVED_2(PMA_CH0_REG_RX_RESERVED_2),  // 使能选项：开启或关闭。
                .PMA_REG_RX_RESERVED_3(PMA_CH0_REG_RX_RESERVED_3),  // 使能选项：开启或关闭。
                .PMA_REG_RX_DATAPATH_PD(PMA_CH0_REG_RX_DATAPATH_PD),  // 使能选项：开启或关闭。
                .PMA_REG_RX_DATAPATH_PD_EN(PMA_CH0_REG_RX_DATAPATH_PD_EN),  // 使能选项：开启或关闭。
                .PMA_REG_RX_SIGDET_PD(PMA_CH0_REG_RX_SIGDET_PD),  // 使能选项：开启或关闭。
                .PMA_REG_RX_SIGDET_PD_EN(PMA_CH0_REG_RX_SIGDET_PD_EN),  // 使能选项：开启或关闭。
                .PMA_REG_RX_DCC_RST_N(PMA_CH0_REG_RX_DCC_RST_N),  // 使能选项：开启或关闭。
                .PMA_REG_RX_DCC_RST_N_EN(PMA_CH0_REG_RX_DCC_RST_N_EN),  // 使能选项：开启或关闭。
                .PMA_REG_RX_CDR_RST_N(PMA_CH0_REG_RX_CDR_RST_N),  // 使能选项：开启或关闭。
                .PMA_REG_RX_CDR_RST_N_EN(PMA_CH0_REG_RX_CDR_RST_N_EN),  // 使能选项：开启或关闭。
                .PMA_REG_RX_SIGDET_RST_N(PMA_CH0_REG_RX_SIGDET_RST_N),  // 使能选项：开启或关闭。
                .PMA_REG_RX_SIGDET_RST_N_EN(PMA_CH0_REG_RX_SIGDET_RST_N_EN),  // 使能选项：开启或关闭。
                .PMA_REG_RXPCLK_SLIP(PMA_CH0_REG_RXPCLK_SLIP),  // 使能选项：开启或关闭。
                .PMA_REG_RXPCLK_SLIP_OW(PMA_CH0_REG_RXPCLK_SLIP_OW),  // 使能选项：开启或关闭。
                .PMA_REG_RX_PCLKSWITCH_RST_N(PMA_CH0_REG_RX_PCLKSWITCH_RST_N),  // 发送 PMA 复位控制
                .PMA_REG_RX_PCLKSWITCH_RST_N_EN              (PMA_CH0_REG_RX_PCLKSWITCH_RST_N_EN                ),// 使能选项：开启或关闭。
                .PMA_REG_RX_PCLKSWITCH(PMA_CH0_REG_RX_PCLKSWITCH),  // 使能选项：开启或关闭。
                .PMA_REG_RX_PCLKSWITCH_EN(PMA_CH0_REG_RX_PCLKSWITCH_EN),  // 使能选项：开启或关闭。
                .PMA_REG_RX_HIGHZ(PMA_CH0_REG_RX_HIGHZ),  // 使能选项：开启或关闭。
                .PMA_REG_RX_HIGHZ_EN(PMA_CH0_REG_RX_HIGHZ_EN),  // 使能选项：开启或关闭。
                .PMA_REG_RX_SIGDET_CLK_WINDOW(PMA_CH0_REG_RX_SIGDET_CLK_WINDOW),  // 使能选项：开启或关闭。
                .PMA_REG_RX_SIGDET_CLK_WINDOW_OW             (PMA_CH0_REG_RX_SIGDET_CLK_WINDOW_OW               ),// 使能选项：开启或关闭。
                .PMA_REG_RX_PD_BIAS_RX(PMA_CH0_REG_RX_PD_BIAS_RX),  // 使能选项：开启或关闭。
                .PMA_REG_RX_PD_BIAS_RX_OW(PMA_CH0_REG_RX_PD_BIAS_RX_OW),  // 使能选项：开启或关闭。
                .PMA_REG_RX_RESET_N(PMA_CH0_REG_RX_RESET_N),  // 使能选项：开启或关闭。
                .PMA_REG_RX_RESET_N_OW(PMA_CH0_REG_RX_RESET_N_OW),  // 使能选项：开启或关闭。
                .PMA_REG_RX_RESERVED_29_28(PMA_CH0_REG_RX_RESERVED_29_28),  // 取值范围：0～3。
                .PMA_REG_RX_BUSWIDTH(PMA_CH0_REG_RX_BUSWIDTH),  // 位宽选项：8、10、16 或 20 位。
                .PMA_REG_RX_BUSWIDTH_EN(PMA_CH0_REG_RX_BUSWIDTH_EN),  // 使能选项：开启或关闭。
                .PMA_REG_RX_RATE(PMA_CH0_REG_RX_RATE),  // 时钟倍率：四分频、二分频、原频或二倍频。
                .PMA_REG_RX_RESERVED_36(PMA_CH0_REG_RX_RESERVED_36),  // 使能选项：开启或关闭。
                .PMA_REG_RX_RATE_EN(PMA_CH0_REG_RX_RATE_EN),  // 使能选项：开启或关闭。
                .PMA_REG_RX_RES_TRIM(PMA_CH0_REG_RX_RES_TRIM),  // 取值范围：0～63。
                .PMA_REG_RX_RESERVED_44(PMA_CH0_REG_RX_RESERVED_44),  // 使能选项：开启或关闭。
                .PMA_REG_RX_RESERVED_45(PMA_CH0_REG_RX_RESERVED_45),  // 使能选项：开启或关闭。
                .PMA_REG_RX_SIGDET_STATUS_EN(PMA_CH0_REG_RX_SIGDET_STATUS_EN),  // 使能选项：开启或关闭。
                .PMA_REG_RX_RESERVED_48_47(PMA_CH0_REG_RX_RESERVED_48_47),  // 取值范围：0～3。
                .PMA_REG_RX_ICTRL_SIGDET(PMA_CH0_REG_RX_ICTRL_SIGDET),  // 取值范围：0～15。
                .PMA_REG_CDR_READY_THD(PMA_CH0_REG_CDR_READY_THD),  // 取值范围：0～4095。
                .PMA_REG_RX_RESERVED_65(PMA_CH0_REG_RX_RESERVED_65),  // 使能选项：开启或关闭。
                .PMA_REG_RX_PCLK_EDGE_SEL(PMA_CH0_REG_RX_PCLK_EDGE_SEL),  // 时钟边沿：上升沿或下降沿。
                .PMA_REG_RX_PIBUF_IC(PMA_CH0_REG_RX_PIBUF_IC),  // 取值范围：0～3。
                .PMA_REG_RX_RESERVED_69(PMA_CH0_REG_RX_RESERVED_69),  // 使能选项：开启或关闭。
                .PMA_REG_RX_DCC_IC_RX(PMA_CH0_REG_RX_DCC_IC_RX),  // 取值范围：0～3。
                .PMA_REG_CDR_READY_CHECK_CTRL(PMA_CH0_REG_CDR_READY_CHECK_CTRL),  // 取值范围：0～3。
                .PMA_REG_RX_ICTRL_TRX(PMA_CH0_REG_RX_ICTRL_TRX),  // 比例选项：87.5%、100%、112.5%、125%。
                .PMA_REG_RX_RESERVED_77_76(PMA_CH0_REG_RX_RESERVED_77_76),  // 取值范围：0～3。
                .PMA_REG_RX_RESERVED_79_78(PMA_CH0_REG_RX_RESERVED_79_78),  // 取值范围：0～3。
                .PMA_REG_RX_RESERVED_81_80(PMA_CH0_REG_RX_RESERVED_81_80),  // 取值范围：0～3。
                .PMA_REG_RX_ICTRL_PIBUF(PMA_CH0_REG_RX_ICTRL_PIBUF),  // 比例选项：87.5%、100%、112.5%、125%。
                .PMA_REG_RX_ICTRL_PI(PMA_CH0_REG_RX_ICTRL_PI),  // 比例选项：87.5%、100%、112.5%、125%。
                .PMA_REG_RX_ICTRL_DCC(PMA_CH0_REG_RX_ICTRL_DCC),  // 比例选项：87.5%、100%、112.5%、125%。
                .PMA_REG_RX_RESERVED_89_88(PMA_CH0_REG_RX_RESERVED_89_88),  // 取值范围：0～3。
                .PMA_REG_TX_RATE(PMA_CH0_REG_TX_RATE),  // 时钟倍率：四分频、二分频、原频或二倍频。
                .PMA_REG_RX_RESERVED_92(PMA_CH0_REG_RX_RESERVED_92),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RATE_EN(PMA_CH0_REG_TX_RATE_EN),  // 使能选项：开启或关闭。
                .PMA_REG_RX_TX2RX_PLPBK_RST_N                (PMA_CH0_REG_RX_TX2RX_PLPBK_RST_N                  ),// PMA 发送到接收并行环回复位控制
                .PMA_REG_RX_TX2RX_PLPBK_RST_N_EN             (PMA_CH0_REG_RX_TX2RX_PLPBK_RST_N_EN               ),// 使能选项：开启或关闭。
                .PMA_REG_RX_TX2RX_PLPBK_EN(PMA_CH0_REG_RX_TX2RX_PLPBK_EN),  // PMA 发送到接收并行环回使能
                .PMA_REG_TXCLK_SEL(PMA_CH0_REG_TXCLK_SEL),  // 时钟来源：PLL 或接收时钟。
                .PMA_REG_RX_DATA_POLARITY(PMA_CH0_REG_RX_DATA_POLARITY),  // 极性选项：正常或反转。
                .PMA_REG_RX_ERR_INSERT(PMA_CH0_REG_RX_ERR_INSERT),  // 使能选项：开启或关闭。
                .PMA_REG_UDP_CHK_EN(PMA_CH0_REG_UDP_CHK_EN),  // 使能选项：开启或关闭。
                .PMA_REG_PRBS_SEL(PMA_CH0_REG_PRBS_SEL),  // PRBS 多项式阶数：7、15、23、31。
                .PMA_REG_PRBS_CHK_EN(PMA_CH0_REG_PRBS_CHK_EN),  // 使能选项：开启或关闭。
                .PMA_REG_PRBS_CHK_WIDTH_SEL                  (PMA_CH0_REG_PRBS_CHK_WIDTH_SEL                    ),// 位宽选项：8、10、16 或 20 位。
                .PMA_REG_BIST_CHK_PAT_SEL(PMA_CH0_REG_BIST_CHK_PAT_SEL),  // 码型来源：PRBS 或常量。
                .PMA_REG_LOAD_ERR_CNT(PMA_CH0_REG_LOAD_ERR_CNT),  // 使能选项：开启或关闭。
                .PMA_REG_CHK_COUNTER_EN(PMA_CH0_REG_CHK_COUNTER_EN),  // 使能选项：开启或关闭。
                .PMA_REG_CDR_PROP_GAIN(PMA_CH0_REG_CDR_PROP_GAIN),  // 取值范围：0～7。
                .PMA_REG_CDR_PROP_TURBO_GAIN(PMA_CH0_REG_CDR_PROP_TURBO_GAIN),  // 取值范围：0～7。
                .PMA_REG_CDR_INT_GAIN(PMA_CH0_REG_CDR_INT_GAIN),  // 取值范围：0～7。
                .PMA_REG_CDR_INT_TURBO_GAIN(PMA_CH0_REG_CDR_INT_TURBO_GAIN),  // 取值范围：0～7。
                .PMA_REG_CDR_INT_SAT_MAX(PMA_CH0_REG_CDR_INT_SAT_MAX),  // 取值范围：0～1023。
                .PMA_REG_CDR_INT_SAT_MIN(PMA_CH0_REG_CDR_INT_SAT_MIN),  // 取值范围：0～1023。
                .PMA_REG_CDR_INT_RST(PMA_CH0_REG_CDR_INT_RST),  // 使能选项：开启或关闭。
                .PMA_REG_CDR_INT_RST_OW(PMA_CH0_REG_CDR_INT_RST_OW),  // 使能选项：开启或关闭。
                .PMA_REG_CDR_PROP_RST(PMA_CH0_REG_CDR_PROP_RST),  // 使能选项：开启或关闭。
                .PMA_REG_CDR_PROP_RST_OW(PMA_CH0_REG_CDR_PROP_RST_OW),  // 使能选项：开启或关闭。
                .PMA_REG_CDR_LOCK_RST(PMA_CH0_REG_CDR_LOCK_RST),  // CDR 锁定计数器复位控制
                .PMA_REG_CDR_LOCK_RST_OW(PMA_CH0_REG_CDR_LOCK_RST_OW),  // 使能选项：开启或关闭。
                .PMA_REG_CDR_RX_PI_FORCE_SEL(PMA_CH0_REG_CDR_RX_PI_FORCE_SEL),  //0,1
                .PMA_REG_CDR_RX_PI_FORCE_D(PMA_CH0_REG_CDR_RX_PI_FORCE_D),  // 取值范围：0～255。
                .PMA_REG_CDR_LOCK_TIMER                      (PMA_CH0_REG_CDR_LOCK_TIMER                        ),// 参数选项："0_8U" "1_2U" "1_6U" "2_4U" 3_2U" "4_8U" "12_8U" "25_6U"
                .PMA_REG_CDR_TURBO_MODE_TIMER(PMA_CH0_REG_CDR_TURBO_MODE_TIMER),  // 取值范围：0～3。
                .PMA_REG_CDR_LOCK_VAL(PMA_CH0_REG_CDR_LOCK_VAL),  // 使能选项：开启或关闭。
                .PMA_REG_CDR_LOCK_OW(PMA_CH0_REG_CDR_LOCK_OW),  // 使能选项：开启或关闭。
                .PMA_REG_CDR_INT_SAT_DET_EN(PMA_CH0_REG_CDR_INT_SAT_DET_EN),  // 使能选项：开启或关闭。
                .PMA_REG_CDR_SAT_AUTO_DIS(PMA_CH0_REG_CDR_SAT_AUTO_DIS),  // 使能选项：开启或关闭。
                .PMA_REG_CDR_GAIN_AUTO(PMA_CH0_REG_CDR_GAIN_AUTO),  // 使能选项：开启或关闭。
                .PMA_REG_CDR_TURBO_GAIN_AUTO(PMA_CH0_REG_CDR_TURBO_GAIN_AUTO),  // 使能选项：开启或关闭。
                .PMA_REG_RX_RESERVED_171_167(PMA_CH0_REG_RX_RESERVED_171_167),  // 取值范围：0～31。
                .PMA_REG_RX_RESERVED_175_172(PMA_CH0_REG_RX_RESERVED_175_172),  // 取值范围：0～31。
                .PMA_REG_CDR_SAT_DET_STATUS_EN(PMA_CH0_REG_CDR_SAT_DET_STATUS_EN),  // 使能选项：开启或关闭。
                .PMA_REG_CDR_SAT_DET_STATUS_RESET_EN         (PMA_CH0_REG_CDR_SAT_DET_STATUS_RESET_EN           ),// 使能选项：开启或关闭。
                .PMA_REG_CDR_PI_CTRL_RST(PMA_CH0_REG_CDR_PI_CTRL_RST),  // 使能选项：开启或关闭。
                .PMA_REG_CDR_PI_CTRL_RST_OW(PMA_CH0_REG_CDR_PI_CTRL_RST_OW),  // 使能选项：开启或关闭。
                .PMA_REG_CDR_SAT_DET_RST(PMA_CH0_REG_CDR_SAT_DET_RST),  // 使能选项：开启或关闭。
                .PMA_REG_CDR_SAT_DET_RST_OW(PMA_CH0_REG_CDR_SAT_DET_RST_OW),  // 使能选项：开启或关闭。
                .PMA_REG_CDR_SAT_DET_STICKY_RST              (PMA_CH0_REG_CDR_SAT_DET_STICKY_RST                ),// 使能选项：开启或关闭。
                .PMA_REG_CDR_SAT_DET_STICKY_RST_OW           (PMA_CH0_REG_CDR_SAT_DET_STICKY_RST_OW             ),// 使能选项：开启或关闭。
                .PMA_REG_CDR_SIGDET_STATUS_DIS               (PMA_CH0_REG_CDR_SIGDET_STATUS_DIS                 ),// 无信号检测状态时复位 CDR。
                .PMA_REG_CDR_SAT_DET_TIMER(PMA_CH0_REG_CDR_SAT_DET_TIMER),  // 取值范围：0～3。
                .PMA_REG_CDR_SAT_DET_STATUS_VAL              (PMA_CH0_REG_CDR_SAT_DET_STATUS_VAL                ),// 使能选项：开启或关闭。
                .PMA_REG_CDR_SAT_DET_STATUS_OW(PMA_CH0_REG_CDR_SAT_DET_STATUS_OW),  // 使能选项：开启或关闭。
                .PMA_REG_CDR_TURBO_MODE_EN(PMA_CH0_REG_CDR_TURBO_MODE_EN),  // 使能选项：开启或关闭。
                .PMA_REG_RX_RESERVED_190(PMA_CH0_REG_RX_RESERVED_190),  // 使能选项：开启或关闭。
                .PMA_REG_RX_RESERVED_193_191(PMA_CH0_REG_RX_RESERVED_193_191),  // 取值范围：0～7。
                .PMA_REG_CDR_STATUS_FIFO_EN(PMA_CH0_REG_CDR_STATUS_FIFO_EN),  // 使能选项：开启或关闭。
                .PMA_REG_PMA_TEST_SEL(PMA_CH0_REG_PMA_TEST_SEL),  //0,1
                .PMA_REG_OOB_COMWAKE_GAP_MIN(PMA_CH0_REG_OOB_COMWAKE_GAP_MIN),  // 取值范围：0～63。
                .PMA_REG_OOB_COMWAKE_GAP_MAX(PMA_CH0_REG_OOB_COMWAKE_GAP_MAX),  // 取值范围：0～63。
                .PMA_REG_OOB_COMINIT_GAP_MIN(PMA_CH0_REG_OOB_COMINIT_GAP_MIN),  // 取值范围：0～255。
                .PMA_REG_OOB_COMINIT_GAP_MAX(PMA_CH0_REG_OOB_COMINIT_GAP_MAX),  // 取值范围：0～255。
                .PMA_REG_RX_RESERVED_227_226(PMA_CH0_REG_RX_RESERVED_227_226),  // 取值范围：0～3。
                .PMA_REG_COMWAKE_STATUS_CLEAR(PMA_CH0_REG_COMWAKE_STATUS_CLEAR),  //0,1
                .PMA_REG_COMINIT_STATUS_CLEAR(PMA_CH0_REG_COMINIT_STATUS_CLEAR),  //0,1
                .PMA_REG_RX_SYNC_RST_N_EN(PMA_CH0_REG_RX_SYNC_RST_N_EN),  // 使能选项：开启或关闭。
                .PMA_REG_RX_SYNC_RST_N(PMA_CH0_REG_RX_SYNC_RST_N),  // 使能选项：开启或关闭。
                .PMA_REG_RX_RESERVED_233_232(PMA_CH0_REG_RX_RESERVED_233_232),  // 取值范围：0～3。
                .PMA_REG_RX_RESERVED_235_234(PMA_CH0_REG_RX_RESERVED_235_234),  // 取值范围：0～3。
                .PMA_REG_RX_SATA_COMINIT_OW(PMA_CH0_REG_RX_SATA_COMINIT_OW),  // 使能选项：开启或关闭。
                .PMA_REG_RX_SATA_COMINIT(PMA_CH0_REG_RX_SATA_COMINIT),  // 使能选项：开启或关闭。
                .PMA_REG_RX_SATA_COMWAKE_OW(PMA_CH0_REG_RX_SATA_COMWAKE_OW),  // 使能选项：开启或关闭。
                .PMA_REG_RX_SATA_COMWAKE(PMA_CH0_REG_RX_SATA_COMWAKE),  // 使能选项：开启或关闭。
                .PMA_REG_RX_RESERVED_241_240(PMA_CH0_REG_RX_RESERVED_241_240),  // 取值范围：0～3。
                .PMA_REG_RX_DCC_DISABLE(PMA_CH0_REG_RX_DCC_DISABLE),  // 接收占空比校正禁用控制
                .PMA_REG_RX_RESERVED_243(PMA_CH0_REG_RX_RESERVED_243),  // 使能选项：开启或关闭。
                .PMA_REG_RX_SLIP_SEL_EN(PMA_CH0_REG_RX_SLIP_SEL_EN),  // 使能选项：开启或关闭。
                .PMA_REG_RX_SLIP_SEL(PMA_CH0_REG_RX_SLIP_SEL),  // 取值范围：0～15。
                .PMA_REG_RX_SLIP_EN(PMA_CH0_REG_RX_SLIP_EN),  // 使能选项：开启或关闭。
                .PMA_REG_RX_SIGDET_STATUS_SEL(PMA_CH0_REG_RX_SIGDET_STATUS_SEL),  // 取值范围：0～7。
                .PMA_REG_RX_SIGDET_FSM_RST_N(PMA_CH0_REG_RX_SIGDET_FSM_RST_N),  // 使能选项：开启或关闭。
                .PMA_REG_RX_RESERVED_254(PMA_CH0_REG_RX_RESERVED_254),  // 使能选项：开启或关闭。
                .PMA_REG_RX_SIGDET_STATUS(PMA_CH0_REG_RX_SIGDET_STATUS),  // 使能选项：开启或关闭。
                .PMA_REG_RX_SIGDET_VTH(PMA_CH0_REG_RX_SIGDET_VTH),  // 检测电压：45、54、63、72 mV。
                .PMA_REG_RX_SIGDET_GRM(PMA_CH0_REG_RX_SIGDET_GRM),  //0,1,2,3
                .PMA_REG_RX_SIGDET_PULSE_EXT(PMA_CH0_REG_RX_SIGDET_PULSE_EXT),  // 使能选项：开启或关闭。
                .PMA_REG_RX_SIGDET_CH2_SEL(PMA_CH0_REG_RX_SIGDET_CH2_SEL),  //0,1
                .PMA_REG_RX_SIGDET_CH2_CHK_WINDOW(PMA_CH0_REG_RX_SIGDET_CH2_CHK_WINDOW),  // 取值范围：0～31。
                .PMA_REG_RX_SIGDET_CHK_WINDOW_EN             (PMA_CH0_REG_RX_SIGDET_CHK_WINDOW_EN               ),// 使能选项：开启或关闭。
                .PMA_REG_RX_SIGDET_NOSIG_COUNT_SETTING       (PMA_CH0_REG_RX_SIGDET_NOSIG_COUNT_SETTING         ),// 取值范围：0～7。
                .PMA_REG_SLIP_FIFO_INV_EN(PMA_CH0_REG_SLIP_FIFO_INV_EN),  // 使能选项：开启或关闭。
                .PMA_REG_SLIP_FIFO_INV(PMA_CH0_REG_SLIP_FIFO_INV),  // 时钟边沿：上升沿或下降沿。
                .PMA_REG_RX_SIGDET_OOB_DET_COUNT_VAL         (PMA_CH0_REG_RX_SIGDET_OOB_DET_COUNT_VAL           ),// 取值范围：0～31。
                .PMA_REG_RX_SIGDET_4OOB_DET_SEL(PMA_CH0_REG_RX_SIGDET_4OOB_DET_SEL),  // 取值范围：0～7。
                .PMA_REG_RX_RESERVED_285_283(PMA_CH0_REG_RX_RESERVED_285_283),  // 取值范围：0～7。
                .PMA_REG_RX_RESERVED_286(PMA_CH0_REG_RX_RESERVED_286),  // 使能选项：开启或关闭。
                .PMA_REG_RX_SIGDET_IC_I(PMA_CH0_REG_RX_SIGDET_IC_I),  // 取值范围：0～15。
                .PMA_REG_RX_OOB_DETECTOR_RESET_N_OW          (PMA_CH0_REG_RX_OOB_DETECTOR_RESET_N_OW            ),// 使能选项：开启或关闭。
                .PMA_REG_RX_OOB_DETECTOR_RESET_N             (PMA_CH0_REG_RX_OOB_DETECTOR_RESET_N               ),// 接收带外检测器复位控制
                .PMA_REG_RX_OOB_DETECTOR_PD_OW(PMA_CH0_REG_RX_OOB_DETECTOR_PD_OW),  // 使能选项：开启或关闭。
                .PMA_REG_RX_OOB_DETECTOR_PD(PMA_CH0_REG_RX_OOB_DETECTOR_PD),  // 接收带外检测器掉电控制
                .PMA_REG_RX_LS_MODE_EN(PMA_CH0_REG_RX_LS_MODE_EN),  // 低速模式使能
                .PMA_REG_ANA_RX_EQ1_R_SET_FB_O_SEL           (PMA_CH0_REG_ANA_RX_EQ1_R_SET_FB_O_SEL             ),// 使能选项：开启或关闭。
                .PMA_REG_ANA_RX_EQ2_R_SET_FB_O_SEL           (PMA_CH0_REG_ANA_RX_EQ2_R_SET_FB_O_SEL             ),// 使能选项：开启或关闭。
                .PMA_REG_RX_EQ1_R_SET_TOP(PMA_CH0_REG_RX_EQ1_R_SET_TOP),  // 取值范围：0～3。
                .PMA_REG_RX_EQ1_R_SET_FB(PMA_CH0_REG_RX_EQ1_R_SET_FB),  // 取值范围：0～15。
                .PMA_REG_RX_EQ1_C_SET_FB(PMA_CH0_REG_RX_EQ1_C_SET_FB),  // 取值范围：0～15。
                .PMA_REG_RX_EQ1_OFF(PMA_CH0_REG_RX_EQ1_OFF),  // 使能选项：开启或关闭。
                .PMA_REG_RX_EQ2_R_SET_TOP(PMA_CH0_REG_RX_EQ2_R_SET_TOP),  // 取值范围：0～3。
                .PMA_REG_RX_EQ2_R_SET_FB(PMA_CH0_REG_RX_EQ2_R_SET_FB),  // 取值范围：0～15。
                .PMA_REG_RX_EQ2_C_SET_FB(PMA_CH0_REG_RX_EQ2_C_SET_FB),  // 取值范围：0～15。
                .PMA_REG_RX_EQ2_OFF(PMA_CH0_REG_RX_EQ2_OFF),  // 使能选项：开启或关闭。
                .PMA_REG_EQ_DAC(PMA_CH0_REG_EQ_DAC),  // 取值范围：0～63。
                .PMA_REG_RX_ICTRL_EQ(PMA_CH0_REG_RX_ICTRL_EQ),  // 使能选项：开启或关闭。
                .PMA_REG_EQ_DC_CALIB_EN(PMA_CH0_REG_EQ_DC_CALIB_EN),  // 使能选项：开启或关闭。
                .PMA_REG_EQ_DC_CALIB_SEL(PMA_CH0_REG_EQ_DC_CALIB_SEL),  // 使能选项：开启或关闭。
                .PMA_REG_RX_RESERVED_337_330(PMA_CH0_REG_RX_RESERVED_337_330),  // 取值范围：0～255。
                .PMA_REG_RX_RESERVED_345_338(PMA_CH0_REG_RX_RESERVED_345_338),  // 取值范围：0～255。
                .PMA_REG_RX_RESERVED_353_346(PMA_CH0_REG_RX_RESERVED_353_346),  // 取值范围：0～255。
                .PMA_REG_RX_RESERVED_361_354(PMA_CH0_REG_RX_RESERVED_361_354),  // 取值范围：0～255。
                .PMA_CTLE_CTRL_REG_I(PMA_CH0_CTLE_CTRL_REG_I),  // 取值范围：0～15。
                .PMA_CTLE_REG_FORCE_SEL_I(PMA_CH0_CTLE_REG_FORCE_SEL_I),  // 自适应调整控制
                .PMA_CTLE_REG_HOLD_I(PMA_CH0_CTLE_REG_HOLD_I),  // 使能选项：开启或关闭。
                .PMA_CTLE_REG_INIT_DAC_I(PMA_CH0_CTLE_REG_INIT_DAC_I),  // 取值范围：0～15。
                .PMA_CTLE_REG_POLARITY_I(PMA_CH0_CTLE_REG_POLARITY_I),  // 使能选项：开启或关闭。
                .PMA_CTLE_REG_SHIFTER_GAIN_I(PMA_CH0_CTLE_REG_SHIFTER_GAIN_I),  // 取值范围：0～7。
                .PMA_CTLE_REG_THRESHOLD_I(PMA_CH0_CTLE_REG_THRESHOLD_I),  // 取值范围：0～4095。
                .PMA_REG_RX_RES_TRIM_EN(PMA_CH0_REG_RX_RES_TRIM_EN),  // 使能选项：开启或关闭。
                .PMA_REG_RX_RESERVED_393_389(PMA_CH0_REG_RX_RESERVED_393_389),  // 取值范围：0～31。
                .PMA_CFG_RX_LANE_POWERUP(PMA_CH0_CFG_RX_LANE_POWERUP),  // 接收通道上电控制
                .PMA_CFG_RX_PMA_RSTN(PMA_CH0_CFG_RX_PMA_RSTN),  // 接收 PMA 复位控制
                .PMA_INT_PMA_RX_MASK_0(PMA_CH0_INT_PMA_RX_MASK_0),  // 使能选项：开启或关闭。
                .PMA_INT_PMA_RX_CLR_0(PMA_CH0_INT_PMA_RX_CLR_0),  // 使能选项：开启或关闭。
                .PMA_CFG_CTLE_ADP_RSTN(PMA_CH0_CFG_CTLE_ADP_RSTN),  // 控制逻辑复位

                .PMA_REG_TX_PD(PMA_CH0_REG_TX_PD),  // 发送端掉电控制
                .PMA_REG_TX_PD_OW(PMA_CH0_REG_TX_PD_OW),  // 使能选项：开启或关闭。
                .PMA_REG_TX_MAIN_PRE_Z(PMA_CH0_REG_TX_MAIN_PRE_Z),  // PCIe 模式电气空闲使能
                .PMA_REG_TX_MAIN_PRE_Z_OW(PMA_CH0_REG_TX_MAIN_PRE_Z_OW),  // 使能选项：开启或关闭。
                .PMA_REG_TX_BEACON_TIMER_SEL(PMA_CH0_REG_TX_BEACON_TIMER_SEL),  // 取值范围：0～3。
                .PMA_REG_TX_RXDET_REQ_OW(PMA_CH0_REG_TX_RXDET_REQ_OW),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RXDET_REQ(PMA_CH0_REG_TX_RXDET_REQ),  // 使能选项：开启或关闭。
                .PMA_REG_TX_BEACON_EN_OW(PMA_CH0_REG_TX_BEACON_EN_OW),  // 使能选项：开启或关闭。
                .PMA_REG_TX_BEACON_EN(PMA_CH0_REG_TX_BEACON_EN),  // 使能选项：开启或关闭。
                .PMA_REG_TX_EI_EN_OW(PMA_CH0_REG_TX_EI_EN_OW),  // 使能选项：开启或关闭。
                .PMA_REG_TX_EI_EN(PMA_CH0_REG_TX_EI_EN),  // 使能选项：开启或关闭。
                .PMA_REG_TX_BIT_CONV(PMA_CH0_REG_TX_BIT_CONV),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RES_CAL(PMA_CH0_REG_TX_RES_CAL),  // 取值范围：0～63。
                .PMA_REG_TX_RESERVED_19(PMA_CH0_REG_TX_RESERVED_19),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RESERVED_25_20(PMA_CH0_REG_TX_RESERVED_25_20),  // 取值范围：0～63。
                .PMA_REG_TX_RESERVED_33_26(PMA_CH0_REG_TX_RESERVED_33_26),  // 取值范围：0～255。
                .PMA_REG_TX_RESERVED_41_34(PMA_CH0_REG_TX_RESERVED_41_34),  // 取值范围：0～255。
                .PMA_REG_TX_RESERVED_49_42(PMA_CH0_REG_TX_RESERVED_49_42),  // 取值范围：0～255。
                .PMA_REG_TX_RESERVED_57_50(PMA_CH0_REG_TX_RESERVED_57_50),  // 取值范围：0～255。
                .PMA_REG_TX_SYNC_OW(PMA_CH0_REG_TX_SYNC_OW),  // 使能选项：开启或关闭。
                .PMA_REG_TX_SYNC(PMA_CH0_REG_TX_SYNC),  // 使能选项：开启或关闭。
                .PMA_REG_TX_PD_POST(PMA_CH0_REG_TX_PD_POST),  // 使能选项：开启或关闭。
                .PMA_REG_TX_PD_POST_OW(PMA_CH0_REG_TX_PD_POST_OW),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RESET_N_OW(PMA_CH0_REG_TX_RESET_N_OW),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RESET_N(PMA_CH0_REG_TX_RESET_N),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RESERVED_64(PMA_CH0_REG_TX_RESERVED_64),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RESERVED_65(PMA_CH0_REG_TX_RESERVED_65),  // 使能选项：开启或关闭。
                .PMA_REG_TX_BUSWIDTH_OW(PMA_CH0_REG_TX_BUSWIDTH_OW),  // 使能选项：开启或关闭。
                .PMA_REG_TX_BUSWIDTH(PMA_CH0_REG_TX_BUSWIDTH),  // 位宽选项：8、10、16 或 20 位。
                .PMA_REG_PLL_READY_OW(PMA_CH0_REG_PLL_READY_OW),  // 使能选项：开启或关闭。
                .PMA_REG_PLL_READY(PMA_CH0_REG_PLL_READY),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RESERVED_72(PMA_CH0_REG_TX_RESERVED_72),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RESERVED_73(PMA_CH0_REG_TX_RESERVED_73),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RESERVED_74(PMA_CH0_REG_TX_RESERVED_74),  // 使能选项：开启或关闭。
                .PMA_REG_EI_PCLK_DELAY_SEL(PMA_CH0_REG_EI_PCLK_DELAY_SEL),  // 取值范围：0～3。
                .PMA_REG_TX_RESERVED_77(PMA_CH0_REG_TX_RESERVED_77),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RESERVED_83_78(PMA_CH0_REG_TX_RESERVED_83_78),  // 取值范围：0～63。
                .PMA_REG_TX_RESERVED_89_84(PMA_CH0_REG_TX_RESERVED_89_84),  // 取值范围：0～63。
                .PMA_REG_TX_RESERVED_95_90(PMA_CH0_REG_TX_RESERVED_95_90),  // 取值范围：0～63。
                .PMA_REG_TX_RESERVED_101_96(PMA_CH0_REG_TX_RESERVED_101_96),  // 取值范围：0～63。
                .PMA_REG_TX_RESERVED_107_102(PMA_CH0_REG_TX_RESERVED_107_102),  // 取值范围：0～63。
                .PMA_REG_TX_RESERVED_113_108(PMA_CH0_REG_TX_RESERVED_113_108),  // 取值范围：0～63。
                .PMA_REG_TX_AMP_DAC0(PMA_CH0_REG_TX_AMP_DAC0),  // 取值范围：0～63。
                .PMA_REG_TX_AMP_DAC1(PMA_CH0_REG_TX_AMP_DAC1),  // 取值范围：0～63。
                .PMA_REG_TX_AMP_DAC2(PMA_CH0_REG_TX_AMP_DAC2),  // 取值范围：0～63。
                .PMA_REG_TX_AMP_DAC3(PMA_CH0_REG_TX_AMP_DAC3),  // 取值范围：0～63。
                .PMA_REG_TX_RESERVED_143_138(PMA_CH0_REG_TX_RESERVED_143_138),  // 取值范围：0～63。
                .PMA_REG_TX_MARGIN(PMA_CH0_REG_TX_MARGIN),  // 取值范围：0～7。
                .PMA_REG_TX_MARGIN_OW(PMA_CH0_REG_TX_MARGIN_OW),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RESERVED_149_148(PMA_CH0_REG_TX_RESERVED_149_148),  // 取值范围：0～3。
                .PMA_REG_TX_RESERVED_150(PMA_CH0_REG_TX_RESERVED_150),  // 使能选项：开启或关闭。
                .PMA_REG_TX_SWING(PMA_CH0_REG_TX_SWING),  // 使能选项：开启或关闭。
                .PMA_REG_TX_SWING_OW(PMA_CH0_REG_TX_SWING_OW),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RESERVED_153(PMA_CH0_REG_TX_RESERVED_153),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RXDET_THRESHOLD(PMA_CH0_REG_TX_RXDET_THRESHOLD),  // 电压选项：28、56、84、112 mV。
                .PMA_REG_TX_RESERVED_157_156(PMA_CH0_REG_TX_RESERVED_157_156),  // 取值范围：0～3。
                .PMA_REG_TX_BEACON_OSC_CTRL(PMA_CH0_REG_TX_BEACON_OSC_CTRL),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RESERVED_160_159(PMA_CH0_REG_TX_RESERVED_160_159),  // 取值范围：0～3。
                .PMA_REG_TX_RESERVED_162_161(PMA_CH0_REG_TX_RESERVED_162_161),  // 取值范围：0～3。
                .PMA_REG_TX_TX2RX_SLPBACK_EN(PMA_CH0_REG_TX_TX2RX_SLPBACK_EN),  // 使能选项：开启或关闭。
                .PMA_REG_TX_PCLK_EDGE_SEL(PMA_CH0_REG_TX_PCLK_EDGE_SEL),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RXDET_STATUS_OW(PMA_CH0_REG_TX_RXDET_STATUS_OW),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RXDET_STATUS(PMA_CH0_REG_TX_RXDET_STATUS),  // 使能选项：开启或关闭。
                .PMA_REG_TX_PRBS_GEN_EN(PMA_CH0_REG_TX_PRBS_GEN_EN),  // 使能选项：开启或关闭。
                .PMA_REG_TX_PRBS_GEN_WIDTH_SEL               (PMA_CH0_REG_TX_PRBS_GEN_WIDTH_SEL                 ),// 位宽选项：8、10、16 或 20 位。
                .PMA_REG_TX_PRBS_SEL(PMA_CH0_REG_TX_PRBS_SEL),  // PRBS 多项式阶数：7、15、23、31。
                .PMA_REG_TX_UDP_DATA_7_TO_0(PMA_CH0_REG_TX_UDP_DATA_7_TO_0),  // 取值范围：0～255。
                .PMA_REG_TX_UDP_DATA_15_TO_8(PMA_CH0_REG_TX_UDP_DATA_15_TO_8),  // 取值范围：0～255。
                .PMA_REG_TX_UDP_DATA_19_TO_16(PMA_CH0_REG_TX_UDP_DATA_19_TO_16),  // 取值范围：0～15。
                .PMA_REG_TX_RESERVED_192(PMA_CH0_REG_TX_RESERVED_192),  // 使能选项：开启或关闭。
                .PMA_REG_TX_FIFO_WP_CTRL(PMA_CH0_REG_TX_FIFO_WP_CTRL),  // 取值范围：0～7。
                .PMA_REG_TX_FIFO_EN(PMA_CH0_REG_TX_FIFO_EN),  // 使能选项：开启或关闭。
                .PMA_REG_TX_DATA_MUX_SEL(PMA_CH0_REG_TX_DATA_MUX_SEL),  // 取值范围：0～3。
                .PMA_REG_TX_ERR_INSERT(PMA_CH0_REG_TX_ERR_INSERT),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RESERVED_203_200(PMA_CH0_REG_TX_RESERVED_203_200),  // 取值范围：0～15。
                .PMA_REG_TX_RESERVED_204(PMA_CH0_REG_TX_RESERVED_204),  // 使能选项：开启或关闭。
                .PMA_REG_TX_SATA_EN(PMA_CH0_REG_TX_SATA_EN),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RESERVED_207_206(PMA_CH0_REG_TX_RESERVED_207_206),  // 取值范围：0～3。
                .PMA_REG_RATE_CHANGE_TXPCLK_ON_OW            (PMA_CH0_REG_RATE_CHANGE_TXPCLK_ON_OW              ),// 使能选项：开启或关闭。
                .PMA_REG_RATE_CHANGE_TXPCLK_ON(PMA_CH0_REG_RATE_CHANGE_TXPCLK_ON),  // 使能选项：开启或关闭。
                .PMA_REG_TX_CFG_POST1(PMA_CH0_REG_TX_CFG_POST1),  // 取值范围：0～31。
                .PMA_REG_TX_CFG_POST2(PMA_CH0_REG_TX_CFG_POST2),  // 取值范围：0～31。
                .PMA_REG_TX_DEEMP(PMA_CH0_REG_TX_DEEMP),  // 取值范围：0～3。
                .PMA_REG_TX_DEEMP_OW(PMA_CH0_REG_TX_DEEMP_OW),  // 发送去加重控制
                .PMA_REG_TX_RESERVED_224_223(PMA_CH0_REG_TX_RESERVED_224_223),  // 取值范围：0～3。
                .PMA_REG_TX_RESERVED_225(PMA_CH0_REG_TX_RESERVED_225),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RESERVED_229_226(PMA_CH0_REG_TX_RESERVED_229_226),  // 取值范围：0～15。
                .PMA_REG_TX_OOB_DELAY_SEL(PMA_CH0_REG_TX_OOB_DELAY_SEL),  // 取值范围：0～15。
                .PMA_REG_TX_POLARITY(PMA_CH0_REG_TX_POLARITY),  // 极性选项：正常或反转。
                .PMA_REG_ANA_TX_JTAG_DATA_O_SEL              (PMA_CH0_REG_ANA_TX_JTAG_DATA_O_SEL                ),// 使能选项：开启或关闭。
                .PMA_REG_TX_RESERVED_236(PMA_CH0_REG_TX_RESERVED_236),  // 使能选项：开启或关闭。
                .PMA_REG_TX_LS_MODE_EN(PMA_CH0_REG_TX_LS_MODE_EN),  // 使能选项：开启或关闭。
                .PMA_REG_TX_JTAG_MODE_EN_OW(PMA_CH0_REG_TX_JTAG_MODE_EN_OW),  // 使能选项：开启或关闭。
                .PMA_REG_TX_JTAG_MODE_EN(PMA_CH0_REG_TX_JTAG_MODE_EN),  // 使能选项：开启或关闭。
                .PMA_REG_RX_JTAG_MODE_EN_OW(PMA_CH0_REG_RX_JTAG_MODE_EN_OW),  // 使能选项：开启或关闭。
                .PMA_REG_RX_JTAG_MODE_EN(PMA_CH0_REG_RX_JTAG_MODE_EN),  // 使能选项：开启或关闭。
                .PMA_REG_RX_JTAG_OE(PMA_CH0_REG_RX_JTAG_OE),  // 使能选项：开启或关闭。
                .PMA_REG_RX_ACJTAG_VHYSTSEL(PMA_CH0_REG_RX_ACJTAG_VHYSTSEL),  // 取值范围：0～7。
                .PMA_REG_TX_RES_CAL_EN(PMA_CH0_REG_TX_RES_CAL_EN),  // 使能选项：开启或关闭。
                .PMA_REG_RX_TERM_MODE_CTRL(PMA_CH0_REG_RX_TERM_MODE_CTRL),  // 接收终端控制范围：0～7。
                .PMA_REG_TX_RESERVED_251_250(PMA_CH0_REG_TX_RESERVED_251_250),  // 取值范围：0～7。
                .PMA_REG_PLPBK_TXPCLK_EN(PMA_CH0_REG_PLPBK_TXPCLK_EN),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RESERVED_253(PMA_CH0_REG_TX_RESERVED_253),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RESERVED_254(PMA_CH0_REG_TX_RESERVED_254),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RESERVED_255(PMA_CH0_REG_TX_RESERVED_255),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RESERVED_256(PMA_CH0_REG_TX_RESERVED_256),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RESERVED_257(PMA_CH0_REG_TX_RESERVED_257),  // 使能选项：开启或关闭。
                .PMA_REG_TX_PH_SEL(PMA_CH0_REG_TX_PH_SEL),  // 取值范围：0～63。
                .PMA_REG_TX_CFG_PRE(PMA_CH0_REG_TX_CFG_PRE),  // 取值范围：0～31。
                .PMA_REG_TX_CFG_MAIN(PMA_CH0_REG_TX_CFG_MAIN),  // 取值范围：0～63。
                .PMA_REG_CFG_POST(PMA_CH0_REG_CFG_POST),  // 取值范围：0～31。
                .PMA_REG_PD_MAIN(PMA_CH0_REG_PD_MAIN),  // 使能选项：开启或关闭。
                .PMA_REG_PD_PRE(PMA_CH0_REG_PD_PRE),  // 使能选项：开启或关闭。
                .PMA_REG_TX_LS_DATA(PMA_CH0_REG_TX_LS_DATA),  // 使能选项：开启或关闭。
                .PMA_REG_TX_DCC_BUF_SZ_SEL(PMA_CH0_REG_TX_DCC_BUF_SZ_SEL),  // 取值范围：0～3。
                .PMA_REG_TX_DCC_CAL_CUR_TUNE(PMA_CH0_REG_TX_DCC_CAL_CUR_TUNE),  // 取值范围：0～63。
                .PMA_REG_TX_DCC_CAL_EN(PMA_CH0_REG_TX_DCC_CAL_EN),  // 使能选项：开启或关闭。
                .PMA_REG_TX_DCC_CUR_SS(PMA_CH0_REG_TX_DCC_CUR_SS),  // 取值范围：0～3。
                .PMA_REG_TX_DCC_FA_CTRL(PMA_CH0_REG_TX_DCC_FA_CTRL),  // 使能选项：开启或关闭。
                .PMA_REG_TX_DCC_RI_CTRL(PMA_CH0_REG_TX_DCC_RI_CTRL),  // 使能选项：开启或关闭。
                .PMA_REG_ATB_SEL_2_TO_0(PMA_CH0_REG_ATB_SEL_2_TO_0),  // 取值范围：0～7。
                .PMA_REG_ATB_SEL_9_TO_3(PMA_CH0_REG_ATB_SEL_9_TO_3),  // 取值范围：0～127。
                .PMA_REG_TX_CFG_7_TO_0(PMA_CH0_REG_TX_CFG_7_TO_0),  // 取值范围：0～255。
                .PMA_REG_TX_CFG_15_TO_8(PMA_CH0_REG_TX_CFG_15_TO_8),  // 取值范围：0～255。
                .PMA_REG_TX_CFG_23_TO_16(PMA_CH0_REG_TX_CFG_23_TO_16),  // 取值范围：0～255。
                .PMA_REG_TX_CFG_31_TO_24(PMA_CH0_REG_TX_CFG_31_TO_24),  // 取值范围：0～255。
                .PMA_REG_TX_OOB_EI_EN(PMA_CH0_REG_TX_OOB_EI_EN),  // SATA 模式带外电气空闲使能
                .PMA_REG_TX_OOB_EI_EN_OW(PMA_CH0_REG_TX_OOB_EI_EN_OW),  // 使能选项：开启或关闭。
                .PMA_REG_TX_BEACON_EN_DELAYED(PMA_CH0_REG_TX_BEACON_EN_DELAYED),  // 使能选项：开启或关闭。
                .PMA_REG_TX_BEACON_EN_DELAYED_OW             (PMA_CH0_REG_TX_BEACON_EN_DELAYED_OW               ),// 使能选项：开启或关闭。
                .PMA_REG_TX_JTAG_DATA(PMA_CH0_REG_TX_JTAG_DATA),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RXDET_TIMER_SEL(PMA_CH0_REG_TX_RXDET_TIMER_SEL),  // 取值范围：0～255。
                .PMA_REG_TX_CFG1_7_0(PMA_CH0_REG_TX_CFG1_7_0),  // 取值范围：0～255。
                .PMA_REG_TX_CFG1_15_8(PMA_CH0_REG_TX_CFG1_15_8),  // 取值范围：0～255。
                .PMA_REG_TX_CFG1_23_16(PMA_CH0_REG_TX_CFG1_23_16),  // 取值范围：0～255。
                .PMA_REG_TX_CFG1_31_24(PMA_CH0_REG_TX_CFG1_31_24),  // 取值范围：0～255。
                .PMA_REG_CFG_LANE_POWERUP(PMA_CH0_REG_CFG_LANE_POWERUP),  // PMA 通道上电控制
                .PMA_REG_CFG_TX_LANE_POWERUP_CLKPATH         (PMA_CH0_REG_CFG_TX_LANE_POWERUP_CLKPATH           ),// PMA 发送通道时钟路径上电控制
                .PMA_REG_CFG_TX_LANE_POWERUP_PISO            (PMA_CH0_REG_CFG_TX_LANE_POWERUP_PISO              ),// PMA 发送并串转换单元上电控制
                .PMA_REG_CFG_TX_LANE_POWERUP_DRIVER          (PMA_CH0_REG_CFG_TX_LANE_POWERUP_DRIVER            ) // PMA 发送驱动器上电控制
            ) U_GTP_HSSTLP_LANE0 (

                .P_TX_SDN           (P_TX_SDN_0),
                .P_TX_SDP           (P_TX_SDP_0),
                // SRB 相关信号
                .P_PCS_RX_MCB_STATUS(P_PCS_RX_MCB_STATUS_0),
                .P_PCS_LSM_SYNCED   (P_PCS_LSM_SYNCED_0),
                .P_CFG_READY        (P_CFG_READY_0),
                .P_CFG_RDATA        (P_CFG_RDATA_0),
                .P_CFG_INT          (P_CFG_INT_0),
                .P_RDATA            (P_RDATA_0),
                .P_RCLK2FABRIC      (P_RCLK2FABRIC_0),
                .P_TCLK2FABRIC      (P_TCLK2FABRIC_0),
                .P_RX_SIGDET_STATUS (P_RX_SIGDET_STATUS_0),
                .P_RX_SATA_COMINIT  (P_RX_SATA_COMINIT_0),
                .P_RX_SATA_COMWAKE  (P_RX_SATA_COMWAKE_0),
                .P_RX_LS_DATA       (P_RX_LS_DATA_0),
                .P_RX_READY         (P_RX_READY_0),
                .P_TEST_STATUS      (P_TEST_STATUS_0),
                .P_TX_RXDET_STATUS  (P_TX_RXDET_STATUS_0),
                .P_CA_ALIGN_RX      (P_CA_ALIGN_RX_0),
                .P_CA_ALIGN_TX      (P_CA_ALIGN_TX_0),

                .PMA_RCLK             (PMA_RCLK_0),
                .TXPCLK_PLL           (TXPCLK_PLL_0),
                // CIN 与 COUT 级联接口
                .LANE_COUT_BUS_FORWARD(LANE_COUT_BUS_FORWARD_0),
                .APATTERN_STATUS_COUT (APATTERN_STATUS_COUT_0),

                .P_RX_SDN            (P_RX_SDN_0),
                .P_RX_SDP            (P_RX_SDP_0),
                // SRB 相关信号
                .P_RX_CLK_FR_CORE    (P_RX_CLK_FR_CORE_0),
                .P_RCLK2_FR_CORE     (P_RCLK2_FR_CORE_0),
                .P_TX_CLK_FR_CORE    (P_TX_CLK_FR_CORE_0),
                .P_TCLK2_FR_CORE     (P_TCLK2_FR_CORE_0),
                .P_PCS_TX_RST        (P_PCS_TX_RST_0),
                .P_PCS_RX_RST        (P_PCS_RX_RST_0),
                .P_PCS_CB_RST        (P_PCS_CB_RST_0),
                .P_RXGEAR_SLIP       (P_RXGEAR_SLIP_0),
                .P_CFG_CLK           (P_CFG_CLK_0),
                .P_CFG_RST           (P_CFG_RST_0),
                .P_CFG_PSEL          (P_CFG_PSEL_0),
                .P_CFG_ENABLE        (P_CFG_ENABLE_0),
                .P_CFG_WRITE         (P_CFG_WRITE_0),
                .P_CFG_ADDR          (P_CFG_ADDR_0),
                .P_CFG_WDATA         (P_CFG_WDATA_0),
                .P_TDATA             (P_TDATA_0),
                .P_PCS_WORD_ALIGN_EN (P_PCS_WORD_ALIGN_EN_0),
                .P_RX_POLARITY_INVERT(P_RX_POLARITY_INVERT_0),
                .P_CEB_ADETECT_EN    (P_CEB_ADETECT_EN_0),
                .P_PCS_MCB_EXT_EN    (P_PCS_MCB_EXT_EN_0),
                .P_PCS_NEAREND_LOOP  (P_PCS_NEAREND_LOOP_0),
                .P_PCS_FAREND_LOOP   (P_PCS_FAREND_LOOP_0),
                .P_PMA_NEAREND_PLOOP (P_PMA_NEAREND_PLOOP_0),
                .P_PMA_NEAREND_SLOOP (P_PMA_NEAREND_SLOOP_0),
                .P_PMA_FAREND_PLOOP  (P_PMA_FAREND_PLOOP_0),

                .P_LANE_PD           (P_LANE_PD_0),
                .P_LANE_RST          (P_LANE_RST_0),
                .P_RX_LANE_PD        (P_RX_LANE_PD_0),
                .P_RX_PMA_RST        (P_RX_PMA_RST_0),
                .P_CTLE_ADP_RST      (P_CTLE_ADP_RST_0),
                .P_TX_DEEMP          (P_TX_DEEMP_0),
                .P_TX_LS_DATA        (P_TX_LS_DATA_0),
                .P_TX_BEACON_EN      (P_TX_BEACON_EN_0),
                .P_TX_SWING          (P_TX_SWING_0),
                .P_TX_RXDET_REQ      (P_TX_RXDET_REQ_0),
                .P_TX_RATE           (P_TX_RATE_0),
                .P_TX_BUSWIDTH       (P_TX_BUSWIDTH_0),
                .P_TX_MARGIN         (P_TX_MARGIN_0),
                .P_TX_PMA_RST        (P_TX_PMA_RST_0),
                .P_TX_LANE_PD_CLKPATH(P_TX_LANE_PD_CLKPATH_0),
                .P_TX_LANE_PD_PISO   (P_TX_LANE_PD_PISO_0),
                .P_TX_LANE_PD_DRIVER (P_TX_LANE_PD_DRIVER_0),
                .P_RX_RATE           (P_RX_RATE_0),
                .P_RX_BUSWIDTH       (P_RX_BUSWIDTH_0),
                .P_RX_HIGHZ          (P_RX_HIGHZ_0),
                .P_CIM_CLK_ALIGNER_RX(P_CIM_CLK_ALIGNER_RX_0),
                .P_CIM_CLK_ALIGNER_TX(P_CIM_CLK_ALIGNER_TX_0),
                .P_CIM_DYN_DLY_SEL_RX(P_CIM_DYN_DLY_SEL_RX_0),
                .P_CIM_DYN_DLY_SEL_TX(P_CIM_DYN_DLY_SEL_TX_0),
                .P_CIM_START_ALIGN_RX(P_CIM_START_ALIGN_RX_0),
                .P_CIM_START_ALIGN_TX(P_CIM_START_ALIGN_TX_0),
                // 扩展端口
                .MCB_RCLK            (MCB_RCLK_0),
                .SYNC                (SYNC_0),
                .RATE_CHANGE         (RATE_CHANGE_0),
                .PLL_LOCK_SEL        (PLL_LOCK_SEL_0),
                // CIN 与 COUT 级联接口
                .LANE_CIN_BUS_FORWARD(LANE_CIN_BUS_FORWARD_0),
                .APATTERN_STATUS_CIN (APATTERN_STATUS_CIN_0),
                // 来自 PLL
                .CLK_TXP             (CLK_TXP_0),
                .CLK_TXN             (CLK_TXN_0),
                .CLK_RX0             (CLK_RX0_0),
                .CLK_RX90            (CLK_RX90_0),
                .CLK_RX180           (CLK_RX180_0),
                .CLK_RX270           (CLK_RX270_0),
                .PLL_PD_I            (PLL_PD_I_0),
                .PLL_RESET_I         (PLL_RESET_I_0),
                .PLL_REFCLK_I        (PLL_REFCLK_I_0),
                .PLL_RES_TRIM_I      (PLL_RES_TRIM_I_0)
            );
        end else begin : CHANNEL0_NULL
            assign P_TX_SDN_0              = 1'b0;
            assign P_TX_SDP_0              = 1'b0;
            assign P_PCS_RX_MCB_STATUS_0   = 1'b0;
            assign P_PCS_LSM_SYNCED_0      = 1'b0;
            assign P_CFG_READY_0           = 1'b0;
            assign P_CFG_RDATA_0           = 8'b0;
            assign P_CFG_INT_0             = 1'b0;
            assign P_RDATA_0               = 47'b0;
            assign P_RCLK2FABRIC_0         = 1'b0;
            assign P_TCLK2FABRIC_0         = 1'b0;
            assign P_RX_SIGDET_STATUS_0    = 1'b0;
            assign P_RX_SATA_COMINIT_0     = 1'b0;
            assign P_RX_SATA_COMWAKE_0     = 1'b0;
            assign P_RX_LS_DATA_0          = 1'b0;
            assign P_RX_READY_0            = 1'b0;
            assign P_TEST_STATUS_0         = 20'b0;
            assign P_TX_RXDET_STATUS_0     = 1'b0;
            assign P_CA_ALIGN_RX_0         = 1'b0;
            assign P_CA_ALIGN_TX_0         = 1'b0;
            assign PMA_RCLK_0              = 1'b0;
            assign TXPCLK_PLL_0            = 1'b0;
            assign LANE_COUT_BUS_FORWARD_0 = 19'b0;
            assign APATTERN_STATUS_COUT_0  = 1'b0;
        end
    endgenerate

    // 通道 1 例化
    generate
        if (CHANNEL1_EN == "TRUE") begin : CHANNEL1_ENABLE
            GTP_HSSTLP_LANE #(
                .MUX_BIAS      (CH1_MUX_BIAS),       // 取值范围：0～7，不支持仿真。
                .PD_CLK        (CH1_PD_CLK),         // 取值范围：0～1。
                .REG_SYNC      (CH1_REG_SYNC),       // 取值范围：0～1。
                .REG_SYNC_OW   (CH1_REG_SYNC_OW),    // 取值范围：0～1。
                .PLL_LOCK_OW   (CH1_PLL_LOCK_OW),    // 取值范围：0～1。
                .PLL_LOCK_OW_EN(CH1_PLL_LOCK_OW_EN), // 取值范围：0～1。

                .PCS_SLAVE(PCS_CH1_SLAVE),
                .PCS_BYPASS_WORD_ALIGN(PCS_CH1_BYPASS_WORD_ALIGN),  // 字对齐旁路使能
                .PCS_BYPASS_DENC(PCS_CH1_BYPASS_DENC),  // 8b/10b 解码旁路使能
                .PCS_BYPASS_BONDING(PCS_CH1_BYPASS_BONDING),  // 通道绑定旁路使能
                .PCS_BYPASS_CTC(PCS_CH1_BYPASS_CTC),  // 时钟补偿旁路使能
                .PCS_BYPASS_GEAR(PCS_CH1_BYPASS_GEAR),  // 接收齿轮箱旁路使能
                .PCS_BYPASS_BRIDGE(PCS_CH1_BYPASS_BRIDGE),  // 接收桥接单元旁路使能
                .PCS_BYPASS_BRIDGE_FIFO(PCS_CH1_BYPASS_BRIDGE_FIFO),  // 接收桥接 FIFO 旁路使能
                .PCS_DATA_MODE(PCS_CH1_DATA_MODE),  // 参数选项："X8","X10","X16","X20"
                .PCS_RX_POLARITY_INV                         (PCS_CH1_RX_POLARITY_INV                           ),// 数据变换：延迟、位极性反转、位序反转或两者同时反转。
                .PCS_ALIGN_MODE(PCS_CH1_ALIGN_MODE),  // 协议模式：1GB、10GB、RAPIDIO 或外部模式。
                .PCS_SAMP_16B(PCS_CH1_SAMP_16B),  // 参数选项："X20",X16
                .PCS_FARLP_PWR_REDUCTION(PCS_CH1_FARLP_PWR_REDUCTION),  // 使能选项：开启或关闭。
                .PCS_COMMA_REG0(PCS_CH1_COMMA_REG0),  // 取值范围：0～1023。
                .PCS_COMMA_MASK(PCS_CH1_COMMA_MASK),  // 取值范围：0～1023。
                .PCS_CEB_MODE(PCS_CH1_CEB_MODE),  // 协议模式：10GB、RAPIDIO 或外部模式。
                .PCS_CTC_MODE                                (PCS_CH1_CTC_MODE                                  ),// 跳过字符模式：单字符、双字符、PCIe 双字节或四字符。
                .PCS_A_REG(PCS_CH1_A_REG),  // 取值范围：0～255。
                .PCS_GE_AUTO_EN(PCS_CH1_GE_AUTO_EN),  // 使能选项：开启或关闭。
                .PCS_SKIP_REG0(PCS_CH1_SKIP_REG0),  // 取值范围：0～1023。
                .PCS_SKIP_REG1(PCS_CH1_SKIP_REG1),  // 取值范围：0～1023。
                .PCS_SKIP_REG2(PCS_CH1_SKIP_REG2),  // 取值范围：0～1023。
                .PCS_SKIP_REG3(PCS_CH1_SKIP_REG3),  // 取值范围：0～1023。
                .PCS_DEC_DUAL(PCS_CH1_DEC_DUAL),  // 使能选项：开启或关闭。
                .PCS_SPLIT(PCS_CH1_SPLIT),  // 使能选项：开启或关闭。
                .PCS_FIFOFLAG_CTC(PCS_CH1_FIFOFLAG_CTC),  // 使能选项：开启或关闭。
                .PCS_COMMA_DET_MODE(PCS_CH1_COMMA_DET_MODE),  // 参数选项："RX_CLK_SLIP" "COMMA_PATTERN"
                .PCS_ERRDETECT_SILENCE(PCS_CH1_ERRDETECT_SILENCE),  // 使能选项：开启或关闭。
                .PCS_PMA_RCLK_POLINV(PCS_CH1_PMA_RCLK_POLINV),  // 参数选项："PMA_RCLK" "REVERSE_OF_PMA_RCLK"
                .PCS_PCS_RCLK_SEL(PCS_CH1_PCS_RCLK_SEL),  // 参数选项："PMA_RCLK" "PMA_TCLK" "RCLK"
                .PCS_CB_RCLK_SEL(PCS_CH1_CB_RCLK_SEL),  // 参数选项："PMA_RCLK" "PMA_TCLK" "MCB_RCLK"
                .PCS_AFTER_CTC_RCLK_SEL                      (PCS_CH1_AFTER_CTC_RCLK_SEL                        ),// 参数选项："PMA_RCLK" "PMA_TCLK" "MCB_RCLK" "RCLK2"
                .PCS_RCLK_POLINV(PCS_CH1_RCLK_POLINV),  // 参数选项："RCLK" "REVERSE_OF_RCLK"
                .PCS_BRIDGE_RCLK_SEL                         (PCS_CH1_BRIDGE_RCLK_SEL                           ),// 参数选项："PMA_RCLK" "PMA_TCLK" "MCB_RCLK" "RCLK"
                .PCS_PCS_RCLK_EN(PCS_CH1_PCS_RCLK_EN),  // 使能选项：开启或关闭。
                .PCS_CB_RCLK_EN(PCS_CH1_CB_RCLK_EN),  // 使能选项：开启或关闭。
                .PCS_AFTER_CTC_RCLK_EN(PCS_CH1_AFTER_CTC_RCLK_EN),  // 使能选项：开启或关闭。
                .PCS_AFTER_CTC_RCLK_EN_GB(PCS_CH1_AFTER_CTC_RCLK_EN_GB),  // 使能选项：开启或关闭。
                .PCS_PCS_RX_RSTN(PCS_CH1_PCS_RX_RSTN),  // PCS 接收端复位控制
                .PCS_PCIE_SLAVE(PCS_CH1_PCIE_SLAVE),  // 通道角色：主通道或从通道。
                .PCS_RX_64B66B_67B(PCS_CH1_RX_64B66B_67B),  // 编码模式：普通、64b/66b 或 64b/67b。
                .PCS_RX_BRIDGE_CLK_POLINV                    (PCS_CH1_RX_BRIDGE_CLK_POLINV                      ),// 参数选项："RX_BRIDGE_CLK" "REVERSE_OF_RX_BRIDGE_CLK"
                .PCS_PCS_CB_RSTN(PCS_CH1_PCS_CB_RSTN),  // PCS 通道绑定复位控制
                .PCS_TX_BRIDGE_GEAR_SEL                      (PCS_CH1_TX_BRIDGE_GEAR_SEL                        ),// TRUE 优先使用发送齿轮箱，FALSE 优先使用发送桥接单元。
                .PCS_TX_BYPASS_BRIDGE_UINT(PCS_CH1_TX_BYPASS_BRIDGE_UINT),  // 旁路使能
                .PCS_TX_BYPASS_BRIDGE_FIFO(PCS_CH1_TX_BYPASS_BRIDGE_FIFO),  // 发送桥接 FIFO 旁路使能
                .PCS_TX_BYPASS_GEAR(PCS_CH1_TX_BYPASS_GEAR),  // 使能选项：开启或关闭。
                .PCS_TX_BYPASS_ENC(PCS_CH1_TX_BYPASS_ENC),  // 使能选项：开启或关闭。
                .PCS_TX_BYPASS_BIT_SLIP(PCS_CH1_TX_BYPASS_BIT_SLIP),  // 使能选项：开启或关闭。
                .PCS_TX_GEAR_SPLIT(PCS_CH1_TX_GEAR_SPLIT),  // 使能选项：开启或关闭。
                .PCS_TX_DRIVE_REG_MODE                       (PCS_CH1_TX_DRIVE_REG_MODE                         ),// 变换选项：不变、极性反转、位序反转或两者同时反转。
                .PCS_TX_BIT_SLIP_CYCLES(PCS_CH1_TX_BIT_SLIP_CYCLES),  // 取值范围：0～31。
                .PCS_INT_TX_MASK_0(PCS_CH1_INT_TX_MASK_0),  // 使能选项：开启或关闭。
                .PCS_INT_TX_MASK_1(PCS_CH1_INT_TX_MASK_1),  // 使能选项：开启或关闭。
                .PCS_INT_TX_MASK_2(PCS_CH1_INT_TX_MASK_2),  // 使能选项：开启或关闭。
                .PCS_INT_TX_CLR_0(PCS_CH1_INT_TX_CLR_0),  // 使能选项：开启或关闭。
                .PCS_INT_TX_CLR_1(PCS_CH1_INT_TX_CLR_1),  // 使能选项：开启或关闭。
                .PCS_INT_TX_CLR_2(PCS_CH1_INT_TX_CLR_2),  // 使能选项：开启或关闭。
                .PCS_TX_PMA_TCLK_POLINV(PCS_CH1_TX_PMA_TCLK_POLINV),  // 参数选项："PMA_TCLK" "REVERSE_OF_PMA_TCLK"
                .PCS_TX_PCS_CLK_EN_SEL(PCS_CH1_TX_PCS_CLK_EN_SEL),  // 使能选项：开启或关闭。
                .PCS_TX_BRIDGE_TCLK_SEL(PCS_CH1_TX_BRIDGE_TCLK_SEL),  // 参数选项："PCS_TCLK" "TCLK"
                .PCS_TX_TCLK_POLINV(PCS_CH1_TX_TCLK_POLINV),  // 参数选项："TCLK" "REVERSE_OF_TCLK"
                .PCS_PCS_TCLK_SEL(PCS_CH1_PCS_TCLK_SEL),  // 参数选项："PMA_TCLK" "TCLK"
                .PCS_TX_PCS_TX_RSTN(PCS_CH1_TX_PCS_TX_RSTN),  // PCS 发送端复位控制
                .PCS_TX_SLAVE(PCS_CH1_TX_SLAVE),  // 通道角色：主通道或从通道。
                .PCS_TX_GEAR_CLK_EN_SEL(PCS_CH1_TX_GEAR_CLK_EN_SEL),  // 使能选项：开启或关闭。
                .PCS_DATA_WIDTH_MODE(PCS_CH1_DATA_WIDTH_MODE),  // 参数选项："X8" "X10" "X16" "X20"
                .PCS_TX_64B66B_67B(PCS_CH1_TX_64B66B_67B),  // 编码模式：普通、64b/66b 或 64b/67b。
                .PCS_GEAR_TCLK_SEL(PCS_CH1_GEAR_TCLK_SEL),  // 参数选项："PMA_TCLK" "TCLK2"
                .PCS_TX_TCLK2FABRIC_SEL(PCS_CH1_TX_TCLK2FABRIC_SEL),  // 使能选项：开启或关闭。
                .PCS_TX_OUTZZ(PCS_CH1_TX_OUTZZ),  // 使能选项：开启或关闭。
                .PCS_ENC_DUAL(PCS_CH1_ENC_DUAL),  // 使能选项：开启或关闭。
                .PCS_TX_BITSLIP_DATA_MODE(PCS_CH1_TX_BITSLIP_DATA_MODE),  // 参数选项："X10" "X20"
                .PCS_TX_BRIDGE_CLK_POLINV                    (PCS_CH1_TX_BRIDGE_CLK_POLINV                      ),// 参数选项："TX_BRIDGE_CLK" "REVERSE_OF_TX_BRIDGE_CLK"
                .PCS_COMMA_REG1(PCS_CH1_COMMA_REG1),  // 取值范围：0～1023。
                .PCS_RAPID_IMAX(PCS_CH1_RAPID_IMAX),  // 取值范围：0～7。
                .PCS_RAPID_VMIN_1(PCS_CH1_RAPID_VMIN_1),  // 取值范围：0～255。
                .PCS_RAPID_VMIN_2(PCS_CH1_RAPID_VMIN_2),  // 取值范围：0～255。
                .PCS_RX_PRBS_MODE                            (PCS_CH1_RX_PRBS_MODE                              ),// PRBS 配置：关闭或选择 7、15、23、31 阶多项式。
                .PCS_RX_ERRCNT_CLR(PCS_CH1_RX_ERRCNT_CLR),  // 使能选项：开启或关闭。
                .PCS_PRBS_ERR_LPBK(PCS_CH1_PRBS_ERR_LPBK),  // 使能选项：开启或关闭。
                .PCS_TX_PRBS_MODE                            (PCS_CH1_TX_PRBS_MODE                              ),// 测试码型：PRBS、长 1、长 0、20 UI、D10.2 或 PCIe。
                .PCS_TX_INSERT_ER(PCS_CH1_TX_INSERT_ER),  // 使能选项：开启或关闭。
                .PCS_ENABLE_PRBS_GEN(PCS_CH1_ENABLE_PRBS_GEN),  // 使能选项：开启或关闭。
                .PCS_DEFAULT_RADDR(PCS_CH1_DEFAULT_RADDR),  // 取值范围：0～15。
                .PCS_MASTER_CHECK_OFFSET(PCS_CH1_MASTER_CHECK_OFFSET),  // 取值范围：0～15。
                .PCS_DELAY_SET(PCS_CH1_DELAY_SET),  // 取值范围：0～15。
                .PCS_SEACH_OFFSET(PCS_CH1_SEACH_OFFSET),  // 绑定位宽：20～80 位，间隔 10 位。
                .PCS_CEB_RAPIDLS_MMAX(PCS_CH1_CEB_RAPIDLS_MMAX),  // 取值范围：0～7。
                .PCS_CTC_AFULL(PCS_CH1_CTC_AFULL),  // 取值范围：0～31。
                .PCS_CTC_AEMPTY(PCS_CH1_CTC_AEMPTY),  // 取值范围：0～31。
                .PCS_CTC_CONTI_SKP_SET(PCS_CH1_CTC_CONTI_SKP_SET),  // 取值范围：0～1。
                .PCS_FAR_LOOP(PCS_CH1_FAR_LOOP),  // 使能选项：开启或关闭。
                .PCS_NEAR_LOOP(PCS_CH1_NEAR_LOOP),  // 使能选项：开启或关闭。
                .PCS_PMA_TX2RX_PLOOP_EN(PCS_CH1_PMA_TX2RX_PLOOP_EN),  // 使能选项：开启或关闭。
                .PCS_PMA_TX2RX_SLOOP_EN(PCS_CH1_PMA_TX2RX_SLOOP_EN),  // 使能选项：开启或关闭。
                .PCS_PMA_RX2TX_PLOOP_EN(PCS_CH1_PMA_RX2TX_PLOOP_EN),  // 使能选项：开启或关闭。
                .PCS_INT_RX_MASK_0(PCS_CH1_INT_RX_MASK_0),  // 使能选项：开启或关闭。
                .PCS_INT_RX_MASK_1(PCS_CH1_INT_RX_MASK_1),  // 使能选项：开启或关闭。
                .PCS_INT_RX_MASK_2(PCS_CH1_INT_RX_MASK_2),  // 使能选项：开启或关闭。
                .PCS_INT_RX_MASK_3(PCS_CH1_INT_RX_MASK_3),  // 使能选项：开启或关闭。
                .PCS_INT_RX_MASK_4(PCS_CH1_INT_RX_MASK_4),  // 使能选项：开启或关闭。
                .PCS_INT_RX_MASK_5(PCS_CH1_INT_RX_MASK_5),  // 使能选项：开启或关闭。
                .PCS_INT_RX_MASK_6(PCS_CH1_INT_RX_MASK_6),  // 使能选项：开启或关闭。
                .PCS_INT_RX_MASK_7(PCS_CH1_INT_RX_MASK_7),  // 使能选项：开启或关闭。
                .PCS_INT_RX_CLR_0(PCS_CH1_INT_RX_CLR_0),  // 使能选项：开启或关闭。
                .PCS_INT_RX_CLR_1(PCS_CH1_INT_RX_CLR_1),  // 使能选项：开启或关闭。
                .PCS_INT_RX_CLR_2(PCS_CH1_INT_RX_CLR_2),  // 使能选项：开启或关闭。
                .PCS_INT_RX_CLR_3(PCS_CH1_INT_RX_CLR_3),  // 使能选项：开启或关闭。
                .PCS_INT_RX_CLR_4(PCS_CH1_INT_RX_CLR_4),  // 使能选项：开启或关闭。
                .PCS_INT_RX_CLR_5(PCS_CH1_INT_RX_CLR_5),  // 使能选项：开启或关闭。
                .PCS_INT_RX_CLR_6(PCS_CH1_INT_RX_CLR_6),  // 使能选项：开启或关闭。
                .PCS_INT_RX_CLR_7(PCS_CH1_INT_RX_CLR_7),  // 使能选项：开启或关闭。
                .PCS_CA_RSTN_RX(PCS_CH1_CA_RSTN_RX),  // 接收时钟对齐器复位控制
                .PCS_CA_DYN_DLY_EN_RX(PCS_CH1_CA_DYN_DLY_EN_RX),  // 使能选项：开启或关闭。
                .PCS_CA_DYN_DLY_SEL_RX(PCS_CH1_CA_DYN_DLY_SEL_RX),  // 使能选项：开启或关闭。
                .PCS_CA_RX(PCS_CH1_CA_RX),  // 取值范围：0～255。
                .PCS_CA_RSTN_TX(PCS_CH1_CA_RSTN_TX),  // 使能选项：开启或关闭。
                .PCS_CA_DYN_DLY_EN_TX(PCS_CH1_CA_DYN_DLY_EN_TX),  // 使能选项：开启或关闭。
                .PCS_CA_DYN_DLY_SEL_TX(PCS_CH1_CA_DYN_DLY_SEL_TX),  // 使能选项：开启或关闭。
                .PCS_CA_TX(PCS_CH1_CA_TX),  // 取值范围：0～255。
                .PCS_RXPRBS_PWR_REDUCTION(PCS_CH1_RXPRBS_PWR_REDUCTION),  // 工作模式：普通或低功耗。
                .PCS_WDALIGN_PWR_REDUCTION(PCS_CH1_WDALIGN_PWR_REDUCTION),  // 工作模式：普通或低功耗。
                .PCS_RXDEC_PWR_REDUCTION(PCS_CH1_RXDEC_PWR_REDUCTION),  // 工作模式：普通或低功耗。
                .PCS_RXCB_PWR_REDUCTION(PCS_CH1_RXCB_PWR_REDUCTION),  // 工作模式：普通或低功耗。
                .PCS_RXCTC_PWR_REDUCTION(PCS_CH1_RXCTC_PWR_REDUCTION),  // 工作模式：普通或低功耗。
                .PCS_RXGEAR_PWR_REDUCTION(PCS_CH1_RXGEAR_PWR_REDUCTION),  // 工作模式：普通或低功耗。
                .PCS_RXBRG_PWR_REDUCTION(PCS_CH1_RXBRG_PWR_REDUCTION),  // 工作模式：普通或低功耗。
                .PCS_RXTEST_PWR_REDUCTION(PCS_CH1_RXTEST_PWR_REDUCTION),  // 工作模式：普通或低功耗。
                .PCS_TXBRG_PWR_REDUCTION(PCS_CH1_TXBRG_PWR_REDUCTION),  // 工作模式：普通或低功耗。
                .PCS_TXGEAR_PWR_REDUCTION(PCS_CH1_TXGEAR_PWR_REDUCTION),  // 工作模式：普通或低功耗。
                .PCS_TXENC_PWR_REDUCTION(PCS_CH1_TXENC_PWR_REDUCTION),  // 工作模式：普通或低功耗。
                .PCS_TXBSLP_PWR_REDUCTION(PCS_CH1_TXBSLP_PWR_REDUCTION),  // 工作模式：普通或低功耗。
                .PCS_TXPRBS_PWR_REDUCTION(PCS_CH1_TXPRBS_PWR_REDUCTION),  // 工作模式：普通或低功耗。

                .PMA_REG_RX_PD(PMA_CH1_REG_RX_PD),  // 使能选项：开启或关闭。
                .PMA_REG_RX_PD_EN(PMA_CH1_REG_RX_PD_EN),  // 使能选项：开启或关闭。
                .PMA_REG_RX_RESERVED_2(PMA_CH1_REG_RX_RESERVED_2),  // 使能选项：开启或关闭。
                .PMA_REG_RX_RESERVED_3(PMA_CH1_REG_RX_RESERVED_3),  // 使能选项：开启或关闭。
                .PMA_REG_RX_DATAPATH_PD(PMA_CH1_REG_RX_DATAPATH_PD),  // 使能选项：开启或关闭。
                .PMA_REG_RX_DATAPATH_PD_EN(PMA_CH1_REG_RX_DATAPATH_PD_EN),  // 使能选项：开启或关闭。
                .PMA_REG_RX_SIGDET_PD(PMA_CH1_REG_RX_SIGDET_PD),  // 使能选项：开启或关闭。
                .PMA_REG_RX_SIGDET_PD_EN(PMA_CH1_REG_RX_SIGDET_PD_EN),  // 使能选项：开启或关闭。
                .PMA_REG_RX_DCC_RST_N(PMA_CH1_REG_RX_DCC_RST_N),  // 使能选项：开启或关闭。
                .PMA_REG_RX_DCC_RST_N_EN(PMA_CH1_REG_RX_DCC_RST_N_EN),  // 使能选项：开启或关闭。
                .PMA_REG_RX_CDR_RST_N(PMA_CH1_REG_RX_CDR_RST_N),  // 使能选项：开启或关闭。
                .PMA_REG_RX_CDR_RST_N_EN(PMA_CH1_REG_RX_CDR_RST_N_EN),  // 使能选项：开启或关闭。
                .PMA_REG_RX_SIGDET_RST_N(PMA_CH1_REG_RX_SIGDET_RST_N),  // 使能选项：开启或关闭。
                .PMA_REG_RX_SIGDET_RST_N_EN(PMA_CH1_REG_RX_SIGDET_RST_N_EN),  // 使能选项：开启或关闭。
                .PMA_REG_RXPCLK_SLIP(PMA_CH1_REG_RXPCLK_SLIP),  // 使能选项：开启或关闭。
                .PMA_REG_RXPCLK_SLIP_OW(PMA_CH1_REG_RXPCLK_SLIP_OW),  // 使能选项：开启或关闭。
                .PMA_REG_RX_PCLKSWITCH_RST_N(PMA_CH1_REG_RX_PCLKSWITCH_RST_N),  // 发送 PMA 复位控制
                .PMA_REG_RX_PCLKSWITCH_RST_N_EN              (PMA_CH1_REG_RX_PCLKSWITCH_RST_N_EN                ),// 使能选项：开启或关闭。
                .PMA_REG_RX_PCLKSWITCH(PMA_CH1_REG_RX_PCLKSWITCH),  // 使能选项：开启或关闭。
                .PMA_REG_RX_PCLKSWITCH_EN(PMA_CH1_REG_RX_PCLKSWITCH_EN),  // 使能选项：开启或关闭。
                .PMA_REG_RX_HIGHZ(PMA_CH1_REG_RX_HIGHZ),  // 使能选项：开启或关闭。
                .PMA_REG_RX_HIGHZ_EN(PMA_CH1_REG_RX_HIGHZ_EN),  // 使能选项：开启或关闭。
                .PMA_REG_RX_SIGDET_CLK_WINDOW(PMA_CH1_REG_RX_SIGDET_CLK_WINDOW),  // 使能选项：开启或关闭。
                .PMA_REG_RX_SIGDET_CLK_WINDOW_OW             (PMA_CH1_REG_RX_SIGDET_CLK_WINDOW_OW               ),// 使能选项：开启或关闭。
                .PMA_REG_RX_PD_BIAS_RX(PMA_CH1_REG_RX_PD_BIAS_RX),  // 使能选项：开启或关闭。
                .PMA_REG_RX_PD_BIAS_RX_OW(PMA_CH1_REG_RX_PD_BIAS_RX_OW),  // 使能选项：开启或关闭。
                .PMA_REG_RX_RESET_N(PMA_CH1_REG_RX_RESET_N),  // 使能选项：开启或关闭。
                .PMA_REG_RX_RESET_N_OW(PMA_CH1_REG_RX_RESET_N_OW),  // 使能选项：开启或关闭。
                .PMA_REG_RX_RESERVED_29_28(PMA_CH1_REG_RX_RESERVED_29_28),  // 取值范围：0～3。
                .PMA_REG_RX_BUSWIDTH(PMA_CH1_REG_RX_BUSWIDTH),  // 位宽选项：8、10、16 或 20 位。
                .PMA_REG_RX_BUSWIDTH_EN(PMA_CH1_REG_RX_BUSWIDTH_EN),  // 使能选项：开启或关闭。
                .PMA_REG_RX_RATE(PMA_CH1_REG_RX_RATE),  // 时钟倍率：四分频、二分频、原频或二倍频。
                .PMA_REG_RX_RESERVED_36(PMA_CH1_REG_RX_RESERVED_36),  // 使能选项：开启或关闭。
                .PMA_REG_RX_RATE_EN(PMA_CH1_REG_RX_RATE_EN),  // 使能选项：开启或关闭。
                .PMA_REG_RX_RES_TRIM(PMA_CH1_REG_RX_RES_TRIM),  // 取值范围：0～63。
                .PMA_REG_RX_RESERVED_44(PMA_CH1_REG_RX_RESERVED_44),  // 使能选项：开启或关闭。
                .PMA_REG_RX_RESERVED_45(PMA_CH1_REG_RX_RESERVED_45),  // 使能选项：开启或关闭。
                .PMA_REG_RX_SIGDET_STATUS_EN(PMA_CH1_REG_RX_SIGDET_STATUS_EN),  // 使能选项：开启或关闭。
                .PMA_REG_RX_RESERVED_48_47(PMA_CH1_REG_RX_RESERVED_48_47),  // 取值范围：0～3。
                .PMA_REG_RX_ICTRL_SIGDET(PMA_CH1_REG_RX_ICTRL_SIGDET),  // 取值范围：0～15。
                .PMA_REG_CDR_READY_THD(PMA_CH1_REG_CDR_READY_THD),  // 取值范围：0～4095。
                .PMA_REG_RX_RESERVED_65(PMA_CH1_REG_RX_RESERVED_65),  // 使能选项：开启或关闭。
                .PMA_REG_RX_PCLK_EDGE_SEL(PMA_CH1_REG_RX_PCLK_EDGE_SEL),  // 时钟边沿：上升沿或下降沿。
                .PMA_REG_RX_PIBUF_IC(PMA_CH1_REG_RX_PIBUF_IC),  // 取值范围：0～3。
                .PMA_REG_RX_RESERVED_69(PMA_CH1_REG_RX_RESERVED_69),  // 使能选项：开启或关闭。
                .PMA_REG_RX_DCC_IC_RX(PMA_CH1_REG_RX_DCC_IC_RX),  // 取值范围：0～3。
                .PMA_REG_CDR_READY_CHECK_CTRL(PMA_CH1_REG_CDR_READY_CHECK_CTRL),  // 取值范围：0～3。
                .PMA_REG_RX_ICTRL_TRX(PMA_CH1_REG_RX_ICTRL_TRX),  // 比例选项：87.5%、100%、112.5%、125%。
                .PMA_REG_RX_RESERVED_77_76(PMA_CH1_REG_RX_RESERVED_77_76),  // 取值范围：0～3。
                .PMA_REG_RX_RESERVED_79_78(PMA_CH1_REG_RX_RESERVED_79_78),  // 取值范围：0～3。
                .PMA_REG_RX_RESERVED_81_80(PMA_CH1_REG_RX_RESERVED_81_80),  // 取值范围：0～3。
                .PMA_REG_RX_ICTRL_PIBUF(PMA_CH1_REG_RX_ICTRL_PIBUF),  // 比例选项：87.5%、100%、112.5%、125%。
                .PMA_REG_RX_ICTRL_PI(PMA_CH1_REG_RX_ICTRL_PI),  // 比例选项：87.5%、100%、112.5%、125%。
                .PMA_REG_RX_ICTRL_DCC(PMA_CH1_REG_RX_ICTRL_DCC),  // 比例选项：87.5%、100%、112.5%、125%。
                .PMA_REG_RX_RESERVED_89_88(PMA_CH1_REG_RX_RESERVED_89_88),  // 取值范围：0～3。
                .PMA_REG_TX_RATE(PMA_CH1_REG_TX_RATE),  // 时钟倍率：四分频、二分频、原频或二倍频。
                .PMA_REG_RX_RESERVED_92(PMA_CH1_REG_RX_RESERVED_92),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RATE_EN(PMA_CH1_REG_TX_RATE_EN),  // 使能选项：开启或关闭。
                .PMA_REG_RX_TX2RX_PLPBK_RST_N                (PMA_CH1_REG_RX_TX2RX_PLPBK_RST_N                  ),// PMA 发送到接收并行环回复位控制
                .PMA_REG_RX_TX2RX_PLPBK_RST_N_EN             (PMA_CH1_REG_RX_TX2RX_PLPBK_RST_N_EN               ),// 使能选项：开启或关闭。
                .PMA_REG_RX_TX2RX_PLPBK_EN(PMA_CH1_REG_RX_TX2RX_PLPBK_EN),  // PMA 发送到接收并行环回使能
                .PMA_REG_TXCLK_SEL(PMA_CH1_REG_TXCLK_SEL),  // 时钟来源：PLL 或接收时钟。
                .PMA_REG_RX_DATA_POLARITY(PMA_CH1_REG_RX_DATA_POLARITY),  // 极性选项：正常或反转。
                .PMA_REG_RX_ERR_INSERT(PMA_CH1_REG_RX_ERR_INSERT),  // 使能选项：开启或关闭。
                .PMA_REG_UDP_CHK_EN(PMA_CH1_REG_UDP_CHK_EN),  // 使能选项：开启或关闭。
                .PMA_REG_PRBS_SEL(PMA_CH1_REG_PRBS_SEL),  // PRBS 多项式阶数：7、15、23、31。
                .PMA_REG_PRBS_CHK_EN(PMA_CH1_REG_PRBS_CHK_EN),  // 使能选项：开启或关闭。
                .PMA_REG_PRBS_CHK_WIDTH_SEL                  (PMA_CH1_REG_PRBS_CHK_WIDTH_SEL                    ),// 位宽选项：8、10、16 或 20 位。
                .PMA_REG_BIST_CHK_PAT_SEL(PMA_CH1_REG_BIST_CHK_PAT_SEL),  // 码型来源：PRBS 或常量。
                .PMA_REG_LOAD_ERR_CNT(PMA_CH1_REG_LOAD_ERR_CNT),  // 使能选项：开启或关闭。
                .PMA_REG_CHK_COUNTER_EN(PMA_CH1_REG_CHK_COUNTER_EN),  // 使能选项：开启或关闭。
                .PMA_REG_CDR_PROP_GAIN(PMA_CH1_REG_CDR_PROP_GAIN),  // 取值范围：0～7。
                .PMA_REG_CDR_PROP_TURBO_GAIN(PMA_CH1_REG_CDR_PROP_TURBO_GAIN),  // 取值范围：0～7。
                .PMA_REG_CDR_INT_GAIN(PMA_CH1_REG_CDR_INT_GAIN),  // 取值范围：0～7。
                .PMA_REG_CDR_INT_TURBO_GAIN(PMA_CH1_REG_CDR_INT_TURBO_GAIN),  // 取值范围：0～7。
                .PMA_REG_CDR_INT_SAT_MAX(PMA_CH1_REG_CDR_INT_SAT_MAX),  // 取值范围：0～1023。
                .PMA_REG_CDR_INT_SAT_MIN(PMA_CH1_REG_CDR_INT_SAT_MIN),  // 取值范围：0～1023。
                .PMA_REG_CDR_INT_RST(PMA_CH1_REG_CDR_INT_RST),  // 使能选项：开启或关闭。
                .PMA_REG_CDR_INT_RST_OW(PMA_CH1_REG_CDR_INT_RST_OW),  // 使能选项：开启或关闭。
                .PMA_REG_CDR_PROP_RST(PMA_CH1_REG_CDR_PROP_RST),  // 使能选项：开启或关闭。
                .PMA_REG_CDR_PROP_RST_OW(PMA_CH1_REG_CDR_PROP_RST_OW),  // 使能选项：开启或关闭。
                .PMA_REG_CDR_LOCK_RST(PMA_CH1_REG_CDR_LOCK_RST),  // CDR 锁定计数器复位控制
                .PMA_REG_CDR_LOCK_RST_OW(PMA_CH1_REG_CDR_LOCK_RST_OW),  // 使能选项：开启或关闭。
                .PMA_REG_CDR_RX_PI_FORCE_SEL(PMA_CH1_REG_CDR_RX_PI_FORCE_SEL),  //0,1
                .PMA_REG_CDR_RX_PI_FORCE_D(PMA_CH1_REG_CDR_RX_PI_FORCE_D),  // 取值范围：0～255。
                .PMA_REG_CDR_LOCK_TIMER                      (PMA_CH1_REG_CDR_LOCK_TIMER                        ),// 参数选项："0_8U" "1_2U" "1_6U" "2_4U" 3_2U" "4_8U" "12_8U" "25_6U"
                .PMA_REG_CDR_TURBO_MODE_TIMER(PMA_CH1_REG_CDR_TURBO_MODE_TIMER),  // 取值范围：0～3。
                .PMA_REG_CDR_LOCK_VAL(PMA_CH1_REG_CDR_LOCK_VAL),  // 使能选项：开启或关闭。
                .PMA_REG_CDR_LOCK_OW(PMA_CH1_REG_CDR_LOCK_OW),  // 使能选项：开启或关闭。
                .PMA_REG_CDR_INT_SAT_DET_EN(PMA_CH1_REG_CDR_INT_SAT_DET_EN),  // 使能选项：开启或关闭。
                .PMA_REG_CDR_SAT_AUTO_DIS(PMA_CH1_REG_CDR_SAT_AUTO_DIS),  // 使能选项：开启或关闭。
                .PMA_REG_CDR_GAIN_AUTO(PMA_CH1_REG_CDR_GAIN_AUTO),  // 使能选项：开启或关闭。
                .PMA_REG_CDR_TURBO_GAIN_AUTO(PMA_CH1_REG_CDR_TURBO_GAIN_AUTO),  // 使能选项：开启或关闭。
                .PMA_REG_RX_RESERVED_171_167(PMA_CH1_REG_RX_RESERVED_171_167),  // 取值范围：0～31。
                .PMA_REG_RX_RESERVED_175_172(PMA_CH1_REG_RX_RESERVED_175_172),  // 取值范围：0～31。
                .PMA_REG_CDR_SAT_DET_STATUS_EN(PMA_CH1_REG_CDR_SAT_DET_STATUS_EN),  // 使能选项：开启或关闭。
                .PMA_REG_CDR_SAT_DET_STATUS_RESET_EN         (PMA_CH1_REG_CDR_SAT_DET_STATUS_RESET_EN           ),// 使能选项：开启或关闭。
                .PMA_REG_CDR_PI_CTRL_RST(PMA_CH1_REG_CDR_PI_CTRL_RST),  // 使能选项：开启或关闭。
                .PMA_REG_CDR_PI_CTRL_RST_OW(PMA_CH1_REG_CDR_PI_CTRL_RST_OW),  // 使能选项：开启或关闭。
                .PMA_REG_CDR_SAT_DET_RST(PMA_CH1_REG_CDR_SAT_DET_RST),  // 使能选项：开启或关闭。
                .PMA_REG_CDR_SAT_DET_RST_OW(PMA_CH1_REG_CDR_SAT_DET_RST_OW),  // 使能选项：开启或关闭。
                .PMA_REG_CDR_SAT_DET_STICKY_RST              (PMA_CH1_REG_CDR_SAT_DET_STICKY_RST                ),// 使能选项：开启或关闭。
                .PMA_REG_CDR_SAT_DET_STICKY_RST_OW           (PMA_CH1_REG_CDR_SAT_DET_STICKY_RST_OW             ),// 使能选项：开启或关闭。
                .PMA_REG_CDR_SIGDET_STATUS_DIS               (PMA_CH1_REG_CDR_SIGDET_STATUS_DIS                 ),// 无信号检测状态时复位 CDR。
                .PMA_REG_CDR_SAT_DET_TIMER(PMA_CH1_REG_CDR_SAT_DET_TIMER),  // 取值范围：0～3。
                .PMA_REG_CDR_SAT_DET_STATUS_VAL              (PMA_CH1_REG_CDR_SAT_DET_STATUS_VAL                ),// 使能选项：开启或关闭。
                .PMA_REG_CDR_SAT_DET_STATUS_OW(PMA_CH1_REG_CDR_SAT_DET_STATUS_OW),  // 使能选项：开启或关闭。
                .PMA_REG_CDR_TURBO_MODE_EN(PMA_CH1_REG_CDR_TURBO_MODE_EN),  // 使能选项：开启或关闭。
                .PMA_REG_RX_RESERVED_190(PMA_CH1_REG_RX_RESERVED_190),  // 使能选项：开启或关闭。
                .PMA_REG_RX_RESERVED_193_191(PMA_CH1_REG_RX_RESERVED_193_191),  // 取值范围：0～7。
                .PMA_REG_CDR_STATUS_FIFO_EN(PMA_CH1_REG_CDR_STATUS_FIFO_EN),  // 使能选项：开启或关闭。
                .PMA_REG_PMA_TEST_SEL(PMA_CH1_REG_PMA_TEST_SEL),  //0,1
                .PMA_REG_OOB_COMWAKE_GAP_MIN(PMA_CH1_REG_OOB_COMWAKE_GAP_MIN),  // 取值范围：0～63。
                .PMA_REG_OOB_COMWAKE_GAP_MAX(PMA_CH1_REG_OOB_COMWAKE_GAP_MAX),  // 取值范围：0～63。
                .PMA_REG_OOB_COMINIT_GAP_MIN(PMA_CH1_REG_OOB_COMINIT_GAP_MIN),  // 取值范围：0～255。
                .PMA_REG_OOB_COMINIT_GAP_MAX(PMA_CH1_REG_OOB_COMINIT_GAP_MAX),  // 取值范围：0～255。
                .PMA_REG_RX_RESERVED_227_226(PMA_CH1_REG_RX_RESERVED_227_226),  // 取值范围：0～3。
                .PMA_REG_COMWAKE_STATUS_CLEAR(PMA_CH1_REG_COMWAKE_STATUS_CLEAR),  //0,1
                .PMA_REG_COMINIT_STATUS_CLEAR(PMA_CH1_REG_COMINIT_STATUS_CLEAR),  //0,1
                .PMA_REG_RX_SYNC_RST_N_EN(PMA_CH1_REG_RX_SYNC_RST_N_EN),  // 使能选项：开启或关闭。
                .PMA_REG_RX_SYNC_RST_N(PMA_CH1_REG_RX_SYNC_RST_N),  // 使能选项：开启或关闭。
                .PMA_REG_RX_RESERVED_233_232(PMA_CH1_REG_RX_RESERVED_233_232),  // 取值范围：0～3。
                .PMA_REG_RX_RESERVED_235_234(PMA_CH1_REG_RX_RESERVED_235_234),  // 取值范围：0～3。
                .PMA_REG_RX_SATA_COMINIT_OW(PMA_CH1_REG_RX_SATA_COMINIT_OW),  // 使能选项：开启或关闭。
                .PMA_REG_RX_SATA_COMINIT(PMA_CH1_REG_RX_SATA_COMINIT),  // 使能选项：开启或关闭。
                .PMA_REG_RX_SATA_COMWAKE_OW(PMA_CH1_REG_RX_SATA_COMWAKE_OW),  // 使能选项：开启或关闭。
                .PMA_REG_RX_SATA_COMWAKE(PMA_CH1_REG_RX_SATA_COMWAKE),  // 使能选项：开启或关闭。
                .PMA_REG_RX_RESERVED_241_240(PMA_CH1_REG_RX_RESERVED_241_240),  // 取值范围：0～3。
                .PMA_REG_RX_DCC_DISABLE(PMA_CH1_REG_RX_DCC_DISABLE),  // 接收占空比校正禁用控制
                .PMA_REG_RX_RESERVED_243(PMA_CH1_REG_RX_RESERVED_243),  // 使能选项：开启或关闭。
                .PMA_REG_RX_SLIP_SEL_EN(PMA_CH1_REG_RX_SLIP_SEL_EN),  // 使能选项：开启或关闭。
                .PMA_REG_RX_SLIP_SEL(PMA_CH1_REG_RX_SLIP_SEL),  // 取值范围：0～15。
                .PMA_REG_RX_SLIP_EN(PMA_CH1_REG_RX_SLIP_EN),  // 使能选项：开启或关闭。
                .PMA_REG_RX_SIGDET_STATUS_SEL(PMA_CH1_REG_RX_SIGDET_STATUS_SEL),  // 取值范围：0～7。
                .PMA_REG_RX_SIGDET_FSM_RST_N(PMA_CH1_REG_RX_SIGDET_FSM_RST_N),  // 使能选项：开启或关闭。
                .PMA_REG_RX_RESERVED_254(PMA_CH1_REG_RX_RESERVED_254),  // 使能选项：开启或关闭。
                .PMA_REG_RX_SIGDET_STATUS(PMA_CH1_REG_RX_SIGDET_STATUS),  // 使能选项：开启或关闭。
                .PMA_REG_RX_SIGDET_VTH(PMA_CH1_REG_RX_SIGDET_VTH),  // 检测电压：45、54、63、72 mV。
                .PMA_REG_RX_SIGDET_GRM(PMA_CH1_REG_RX_SIGDET_GRM),  //0,1,2,3
                .PMA_REG_RX_SIGDET_PULSE_EXT(PMA_CH1_REG_RX_SIGDET_PULSE_EXT),  // 使能选项：开启或关闭。
                .PMA_REG_RX_SIGDET_CH2_SEL(PMA_CH1_REG_RX_SIGDET_CH2_SEL),  //0,1
                .PMA_REG_RX_SIGDET_CH2_CHK_WINDOW(PMA_CH1_REG_RX_SIGDET_CH2_CHK_WINDOW),  // 取值范围：0～31。
                .PMA_REG_RX_SIGDET_CHK_WINDOW_EN             (PMA_CH1_REG_RX_SIGDET_CHK_WINDOW_EN               ),// 使能选项：开启或关闭。
                .PMA_REG_RX_SIGDET_NOSIG_COUNT_SETTING       (PMA_CH1_REG_RX_SIGDET_NOSIG_COUNT_SETTING         ),// 取值范围：0～7。
                .PMA_REG_SLIP_FIFO_INV_EN(PMA_CH1_REG_SLIP_FIFO_INV_EN),  // 使能选项：开启或关闭。
                .PMA_REG_SLIP_FIFO_INV(PMA_CH1_REG_SLIP_FIFO_INV),  // 时钟边沿：上升沿或下降沿。
                .PMA_REG_RX_SIGDET_OOB_DET_COUNT_VAL         (PMA_CH1_REG_RX_SIGDET_OOB_DET_COUNT_VAL           ),// 取值范围：0～31。
                .PMA_REG_RX_SIGDET_4OOB_DET_SEL(PMA_CH1_REG_RX_SIGDET_4OOB_DET_SEL),  // 取值范围：0～7。
                .PMA_REG_RX_RESERVED_285_283(PMA_CH1_REG_RX_RESERVED_285_283),  // 取值范围：0～7。
                .PMA_REG_RX_RESERVED_286(PMA_CH1_REG_RX_RESERVED_286),  // 使能选项：开启或关闭。
                .PMA_REG_RX_SIGDET_IC_I(PMA_CH1_REG_RX_SIGDET_IC_I),  // 取值范围：0～15。
                .PMA_REG_RX_OOB_DETECTOR_RESET_N_OW          (PMA_CH1_REG_RX_OOB_DETECTOR_RESET_N_OW            ),// 使能选项：开启或关闭。
                .PMA_REG_RX_OOB_DETECTOR_RESET_N             (PMA_CH1_REG_RX_OOB_DETECTOR_RESET_N               ),// 接收带外检测器复位控制
                .PMA_REG_RX_OOB_DETECTOR_PD_OW(PMA_CH1_REG_RX_OOB_DETECTOR_PD_OW),  // 使能选项：开启或关闭。
                .PMA_REG_RX_OOB_DETECTOR_PD(PMA_CH1_REG_RX_OOB_DETECTOR_PD),  // 接收带外检测器掉电控制
                .PMA_REG_RX_LS_MODE_EN(PMA_CH1_REG_RX_LS_MODE_EN),  // 低速模式使能
                .PMA_REG_ANA_RX_EQ1_R_SET_FB_O_SEL           (PMA_CH1_REG_ANA_RX_EQ1_R_SET_FB_O_SEL             ),// 使能选项：开启或关闭。
                .PMA_REG_ANA_RX_EQ2_R_SET_FB_O_SEL           (PMA_CH1_REG_ANA_RX_EQ2_R_SET_FB_O_SEL             ),// 使能选项：开启或关闭。
                .PMA_REG_RX_EQ1_R_SET_TOP(PMA_CH1_REG_RX_EQ1_R_SET_TOP),  // 取值范围：0～3。
                .PMA_REG_RX_EQ1_R_SET_FB(PMA_CH1_REG_RX_EQ1_R_SET_FB),  // 取值范围：0～15。
                .PMA_REG_RX_EQ1_C_SET_FB(PMA_CH1_REG_RX_EQ1_C_SET_FB),  // 取值范围：0～15。
                .PMA_REG_RX_EQ1_OFF(PMA_CH1_REG_RX_EQ1_OFF),  // 使能选项：开启或关闭。
                .PMA_REG_RX_EQ2_R_SET_TOP(PMA_CH1_REG_RX_EQ2_R_SET_TOP),  // 取值范围：0～3。
                .PMA_REG_RX_EQ2_R_SET_FB(PMA_CH1_REG_RX_EQ2_R_SET_FB),  // 取值范围：0～15。
                .PMA_REG_RX_EQ2_C_SET_FB(PMA_CH1_REG_RX_EQ2_C_SET_FB),  // 取值范围：0～15。
                .PMA_REG_RX_EQ2_OFF(PMA_CH1_REG_RX_EQ2_OFF),  // 使能选项：开启或关闭。
                .PMA_REG_EQ_DAC(PMA_CH1_REG_EQ_DAC),  // 取值范围：0～63。
                .PMA_REG_RX_ICTRL_EQ(PMA_CH1_REG_RX_ICTRL_EQ),  // 使能选项：开启或关闭。
                .PMA_REG_EQ_DC_CALIB_EN(PMA_CH1_REG_EQ_DC_CALIB_EN),  // 使能选项：开启或关闭。
                .PMA_REG_EQ_DC_CALIB_SEL(PMA_CH1_REG_EQ_DC_CALIB_SEL),  // 使能选项：开启或关闭。
                .PMA_REG_RX_RESERVED_337_330(PMA_CH1_REG_RX_RESERVED_337_330),  // 取值范围：0～255。
                .PMA_REG_RX_RESERVED_345_338(PMA_CH1_REG_RX_RESERVED_345_338),  // 取值范围：0～255。
                .PMA_REG_RX_RESERVED_353_346(PMA_CH1_REG_RX_RESERVED_353_346),  // 取值范围：0～255。
                .PMA_REG_RX_RESERVED_361_354(PMA_CH1_REG_RX_RESERVED_361_354),  // 取值范围：0～255。
                .PMA_CTLE_CTRL_REG_I(PMA_CH1_CTLE_CTRL_REG_I),  // 取值范围：0～15。
                .PMA_CTLE_REG_FORCE_SEL_I(PMA_CH1_CTLE_REG_FORCE_SEL_I),  // 自适应调整控制
                .PMA_CTLE_REG_HOLD_I(PMA_CH1_CTLE_REG_HOLD_I),  // 使能选项：开启或关闭。
                .PMA_CTLE_REG_INIT_DAC_I(PMA_CH1_CTLE_REG_INIT_DAC_I),  // 取值范围：0～15。
                .PMA_CTLE_REG_POLARITY_I(PMA_CH1_CTLE_REG_POLARITY_I),  // 使能选项：开启或关闭。
                .PMA_CTLE_REG_SHIFTER_GAIN_I(PMA_CH1_CTLE_REG_SHIFTER_GAIN_I),  // 取值范围：0～7。
                .PMA_CTLE_REG_THRESHOLD_I(PMA_CH1_CTLE_REG_THRESHOLD_I),  // 取值范围：0～4095。
                .PMA_REG_RX_RES_TRIM_EN(PMA_CH1_REG_RX_RES_TRIM_EN),  // 使能选项：开启或关闭。
                .PMA_REG_RX_RESERVED_393_389(PMA_CH1_REG_RX_RESERVED_393_389),  // 取值范围：0～31。
                .PMA_CFG_RX_LANE_POWERUP(PMA_CH1_CFG_RX_LANE_POWERUP),  // 接收通道上电控制
                .PMA_CFG_RX_PMA_RSTN(PMA_CH1_CFG_RX_PMA_RSTN),  // 接收 PMA 复位控制
                .PMA_INT_PMA_RX_MASK_0(PMA_CH1_INT_PMA_RX_MASK_0),  // 使能选项：开启或关闭。
                .PMA_INT_PMA_RX_CLR_0(PMA_CH1_INT_PMA_RX_CLR_0),  // 使能选项：开启或关闭。
                .PMA_CFG_CTLE_ADP_RSTN(PMA_CH1_CFG_CTLE_ADP_RSTN),  // 控制逻辑复位

                .PMA_REG_TX_PD(PMA_CH1_REG_TX_PD),  // 发送端掉电控制
                .PMA_REG_TX_PD_OW(PMA_CH1_REG_TX_PD_OW),  // 使能选项：开启或关闭。
                .PMA_REG_TX_MAIN_PRE_Z(PMA_CH1_REG_TX_MAIN_PRE_Z),  // PCIe 模式电气空闲使能
                .PMA_REG_TX_MAIN_PRE_Z_OW(PMA_CH1_REG_TX_MAIN_PRE_Z_OW),  // 使能选项：开启或关闭。
                .PMA_REG_TX_BEACON_TIMER_SEL(PMA_CH1_REG_TX_BEACON_TIMER_SEL),  // 取值范围：0～3。
                .PMA_REG_TX_RXDET_REQ_OW(PMA_CH1_REG_TX_RXDET_REQ_OW),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RXDET_REQ(PMA_CH1_REG_TX_RXDET_REQ),  // 使能选项：开启或关闭。
                .PMA_REG_TX_BEACON_EN_OW(PMA_CH1_REG_TX_BEACON_EN_OW),  // 使能选项：开启或关闭。
                .PMA_REG_TX_BEACON_EN(PMA_CH1_REG_TX_BEACON_EN),  // 使能选项：开启或关闭。
                .PMA_REG_TX_EI_EN_OW(PMA_CH1_REG_TX_EI_EN_OW),  // 使能选项：开启或关闭。
                .PMA_REG_TX_EI_EN(PMA_CH1_REG_TX_EI_EN),  // 使能选项：开启或关闭。
                .PMA_REG_TX_BIT_CONV(PMA_CH1_REG_TX_BIT_CONV),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RES_CAL(PMA_CH1_REG_TX_RES_CAL),  // 取值范围：0～63。
                .PMA_REG_TX_RESERVED_19(PMA_CH1_REG_TX_RESERVED_19),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RESERVED_25_20(PMA_CH1_REG_TX_RESERVED_25_20),  // 取值范围：0～63。
                .PMA_REG_TX_RESERVED_33_26(PMA_CH1_REG_TX_RESERVED_33_26),  // 取值范围：0～255。
                .PMA_REG_TX_RESERVED_41_34(PMA_CH1_REG_TX_RESERVED_41_34),  // 取值范围：0～255。
                .PMA_REG_TX_RESERVED_49_42(PMA_CH1_REG_TX_RESERVED_49_42),  // 取值范围：0～255。
                .PMA_REG_TX_RESERVED_57_50(PMA_CH1_REG_TX_RESERVED_57_50),  // 取值范围：0～255。
                .PMA_REG_TX_SYNC_OW(PMA_CH1_REG_TX_SYNC_OW),  // 使能选项：开启或关闭。
                .PMA_REG_TX_SYNC(PMA_CH1_REG_TX_SYNC),  // 使能选项：开启或关闭。
                .PMA_REG_TX_PD_POST(PMA_CH1_REG_TX_PD_POST),  // 使能选项：开启或关闭。
                .PMA_REG_TX_PD_POST_OW(PMA_CH1_REG_TX_PD_POST_OW),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RESET_N_OW(PMA_CH1_REG_TX_RESET_N_OW),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RESET_N(PMA_CH1_REG_TX_RESET_N),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RESERVED_64(PMA_CH1_REG_TX_RESERVED_64),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RESERVED_65(PMA_CH1_REG_TX_RESERVED_65),  // 使能选项：开启或关闭。
                .PMA_REG_TX_BUSWIDTH_OW(PMA_CH1_REG_TX_BUSWIDTH_OW),  // 使能选项：开启或关闭。
                .PMA_REG_TX_BUSWIDTH(PMA_CH1_REG_TX_BUSWIDTH),  // 位宽选项：8、10、16 或 20 位。
                .PMA_REG_PLL_READY_OW(PMA_CH1_REG_PLL_READY_OW),  // 使能选项：开启或关闭。
                .PMA_REG_PLL_READY(PMA_CH1_REG_PLL_READY),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RESERVED_72(PMA_CH1_REG_TX_RESERVED_72),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RESERVED_73(PMA_CH1_REG_TX_RESERVED_73),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RESERVED_74(PMA_CH1_REG_TX_RESERVED_74),  // 使能选项：开启或关闭。
                .PMA_REG_EI_PCLK_DELAY_SEL(PMA_CH1_REG_EI_PCLK_DELAY_SEL),  // 取值范围：0～3。
                .PMA_REG_TX_RESERVED_77(PMA_CH1_REG_TX_RESERVED_77),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RESERVED_83_78(PMA_CH1_REG_TX_RESERVED_83_78),  // 取值范围：0～63。
                .PMA_REG_TX_RESERVED_89_84(PMA_CH1_REG_TX_RESERVED_89_84),  // 取值范围：0～63。
                .PMA_REG_TX_RESERVED_95_90(PMA_CH1_REG_TX_RESERVED_95_90),  // 取值范围：0～63。
                .PMA_REG_TX_RESERVED_101_96(PMA_CH1_REG_TX_RESERVED_101_96),  // 取值范围：0～63。
                .PMA_REG_TX_RESERVED_107_102(PMA_CH1_REG_TX_RESERVED_107_102),  // 取值范围：0～63。
                .PMA_REG_TX_RESERVED_113_108(PMA_CH1_REG_TX_RESERVED_113_108),  // 取值范围：0～63。
                .PMA_REG_TX_AMP_DAC0(PMA_CH1_REG_TX_AMP_DAC0),  // 取值范围：0～63。
                .PMA_REG_TX_AMP_DAC1(PMA_CH1_REG_TX_AMP_DAC1),  // 取值范围：0～63。
                .PMA_REG_TX_AMP_DAC2(PMA_CH1_REG_TX_AMP_DAC2),  // 取值范围：0～63。
                .PMA_REG_TX_AMP_DAC3(PMA_CH1_REG_TX_AMP_DAC3),  // 取值范围：0～63。
                .PMA_REG_TX_RESERVED_143_138(PMA_CH1_REG_TX_RESERVED_143_138),  // 取值范围：0～63。
                .PMA_REG_TX_MARGIN(PMA_CH1_REG_TX_MARGIN),  // 取值范围：0～7。
                .PMA_REG_TX_MARGIN_OW(PMA_CH1_REG_TX_MARGIN_OW),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RESERVED_149_148(PMA_CH1_REG_TX_RESERVED_149_148),  // 取值范围：0～3。
                .PMA_REG_TX_RESERVED_150(PMA_CH1_REG_TX_RESERVED_150),  // 使能选项：开启或关闭。
                .PMA_REG_TX_SWING(PMA_CH1_REG_TX_SWING),  // 使能选项：开启或关闭。
                .PMA_REG_TX_SWING_OW(PMA_CH1_REG_TX_SWING_OW),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RESERVED_153(PMA_CH1_REG_TX_RESERVED_153),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RXDET_THRESHOLD(PMA_CH1_REG_TX_RXDET_THRESHOLD),  // 电压选项：28、56、84、112 mV。
                .PMA_REG_TX_RESERVED_157_156(PMA_CH1_REG_TX_RESERVED_157_156),  // 取值范围：0～3。
                .PMA_REG_TX_BEACON_OSC_CTRL(PMA_CH1_REG_TX_BEACON_OSC_CTRL),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RESERVED_160_159(PMA_CH1_REG_TX_RESERVED_160_159),  // 取值范围：0～3。
                .PMA_REG_TX_RESERVED_162_161(PMA_CH1_REG_TX_RESERVED_162_161),  // 取值范围：0～3。
                .PMA_REG_TX_TX2RX_SLPBACK_EN(PMA_CH1_REG_TX_TX2RX_SLPBACK_EN),  // 使能选项：开启或关闭。
                .PMA_REG_TX_PCLK_EDGE_SEL(PMA_CH1_REG_TX_PCLK_EDGE_SEL),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RXDET_STATUS_OW(PMA_CH1_REG_TX_RXDET_STATUS_OW),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RXDET_STATUS(PMA_CH1_REG_TX_RXDET_STATUS),  // 使能选项：开启或关闭。
                .PMA_REG_TX_PRBS_GEN_EN(PMA_CH1_REG_TX_PRBS_GEN_EN),  // 使能选项：开启或关闭。
                .PMA_REG_TX_PRBS_GEN_WIDTH_SEL               (PMA_CH1_REG_TX_PRBS_GEN_WIDTH_SEL                 ),// 位宽选项：8、10、16 或 20 位。
                .PMA_REG_TX_PRBS_SEL(PMA_CH1_REG_TX_PRBS_SEL),  // PRBS 多项式阶数：7、15、23、31。
                .PMA_REG_TX_UDP_DATA_7_TO_0(PMA_CH1_REG_TX_UDP_DATA_7_TO_0),  // 取值范围：0～255。
                .PMA_REG_TX_UDP_DATA_15_TO_8(PMA_CH1_REG_TX_UDP_DATA_15_TO_8),  // 取值范围：0～255。
                .PMA_REG_TX_UDP_DATA_19_TO_16(PMA_CH1_REG_TX_UDP_DATA_19_TO_16),  // 取值范围：0～15。
                .PMA_REG_TX_RESERVED_192(PMA_CH1_REG_TX_RESERVED_192),  // 使能选项：开启或关闭。
                .PMA_REG_TX_FIFO_WP_CTRL(PMA_CH1_REG_TX_FIFO_WP_CTRL),  // 取值范围：0～7。
                .PMA_REG_TX_FIFO_EN(PMA_CH1_REG_TX_FIFO_EN),  // 使能选项：开启或关闭。
                .PMA_REG_TX_DATA_MUX_SEL(PMA_CH1_REG_TX_DATA_MUX_SEL),  // 取值范围：0～3。
                .PMA_REG_TX_ERR_INSERT(PMA_CH1_REG_TX_ERR_INSERT),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RESERVED_203_200(PMA_CH1_REG_TX_RESERVED_203_200),  // 取值范围：0～15。
                .PMA_REG_TX_RESERVED_204(PMA_CH1_REG_TX_RESERVED_204),  // 使能选项：开启或关闭。
                .PMA_REG_TX_SATA_EN(PMA_CH1_REG_TX_SATA_EN),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RESERVED_207_206(PMA_CH1_REG_TX_RESERVED_207_206),  // 取值范围：0～3。
                .PMA_REG_RATE_CHANGE_TXPCLK_ON_OW            (PMA_CH1_REG_RATE_CHANGE_TXPCLK_ON_OW              ),// 使能选项：开启或关闭。
                .PMA_REG_RATE_CHANGE_TXPCLK_ON(PMA_CH1_REG_RATE_CHANGE_TXPCLK_ON),  // 使能选项：开启或关闭。
                .PMA_REG_TX_CFG_POST1(PMA_CH1_REG_TX_CFG_POST1),  // 取值范围：0～31。
                .PMA_REG_TX_CFG_POST2(PMA_CH1_REG_TX_CFG_POST2),  // 取值范围：0～31。
                .PMA_REG_TX_DEEMP(PMA_CH1_REG_TX_DEEMP),  // 取值范围：0～3。
                .PMA_REG_TX_DEEMP_OW(PMA_CH1_REG_TX_DEEMP_OW),  // 发送去加重控制
                .PMA_REG_TX_RESERVED_224_223(PMA_CH1_REG_TX_RESERVED_224_223),  // 取值范围：0～3。
                .PMA_REG_TX_RESERVED_225(PMA_CH1_REG_TX_RESERVED_225),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RESERVED_229_226(PMA_CH1_REG_TX_RESERVED_229_226),  // 取值范围：0～15。
                .PMA_REG_TX_OOB_DELAY_SEL(PMA_CH1_REG_TX_OOB_DELAY_SEL),  // 取值范围：0～15。
                .PMA_REG_TX_POLARITY(PMA_CH1_REG_TX_POLARITY),  // 极性选项：正常或反转。
                .PMA_REG_ANA_TX_JTAG_DATA_O_SEL              (PMA_CH1_REG_ANA_TX_JTAG_DATA_O_SEL                ),// 使能选项：开启或关闭。
                .PMA_REG_TX_RESERVED_236(PMA_CH1_REG_TX_RESERVED_236),  // 使能选项：开启或关闭。
                .PMA_REG_TX_LS_MODE_EN(PMA_CH1_REG_TX_LS_MODE_EN),  // 使能选项：开启或关闭。
                .PMA_REG_TX_JTAG_MODE_EN_OW(PMA_CH1_REG_TX_JTAG_MODE_EN_OW),  // 使能选项：开启或关闭。
                .PMA_REG_TX_JTAG_MODE_EN(PMA_CH1_REG_TX_JTAG_MODE_EN),  // 使能选项：开启或关闭。
                .PMA_REG_RX_JTAG_MODE_EN_OW(PMA_CH1_REG_RX_JTAG_MODE_EN_OW),  // 使能选项：开启或关闭。
                .PMA_REG_RX_JTAG_MODE_EN(PMA_CH1_REG_RX_JTAG_MODE_EN),  // 使能选项：开启或关闭。
                .PMA_REG_RX_JTAG_OE(PMA_CH1_REG_RX_JTAG_OE),  // 使能选项：开启或关闭。
                .PMA_REG_RX_ACJTAG_VHYSTSEL(PMA_CH1_REG_RX_ACJTAG_VHYSTSEL),  // 取值范围：0～7。
                .PMA_REG_TX_RES_CAL_EN(PMA_CH1_REG_TX_RES_CAL_EN),  // 使能选项：开启或关闭。
                .PMA_REG_RX_TERM_MODE_CTRL(PMA_CH1_REG_RX_TERM_MODE_CTRL),  // 接收终端控制范围：0～7。
                .PMA_REG_TX_RESERVED_251_250(PMA_CH1_REG_TX_RESERVED_251_250),  // 取值范围：0～7。
                .PMA_REG_PLPBK_TXPCLK_EN(PMA_CH1_REG_PLPBK_TXPCLK_EN),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RESERVED_253(PMA_CH1_REG_TX_RESERVED_253),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RESERVED_254(PMA_CH1_REG_TX_RESERVED_254),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RESERVED_255(PMA_CH1_REG_TX_RESERVED_255),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RESERVED_256(PMA_CH1_REG_TX_RESERVED_256),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RESERVED_257(PMA_CH1_REG_TX_RESERVED_257),  // 使能选项：开启或关闭。
                .PMA_REG_TX_PH_SEL(PMA_CH1_REG_TX_PH_SEL),  // 取值范围：0～63。
                .PMA_REG_TX_CFG_PRE(PMA_CH1_REG_TX_CFG_PRE),  // 取值范围：0～31。
                .PMA_REG_TX_CFG_MAIN(PMA_CH1_REG_TX_CFG_MAIN),  // 取值范围：0～63。
                .PMA_REG_CFG_POST(PMA_CH1_REG_CFG_POST),  // 取值范围：0～31。
                .PMA_REG_PD_MAIN(PMA_CH1_REG_PD_MAIN),  // 使能选项：开启或关闭。
                .PMA_REG_PD_PRE(PMA_CH1_REG_PD_PRE),  // 使能选项：开启或关闭。
                .PMA_REG_TX_LS_DATA(PMA_CH1_REG_TX_LS_DATA),  // 使能选项：开启或关闭。
                .PMA_REG_TX_DCC_BUF_SZ_SEL(PMA_CH1_REG_TX_DCC_BUF_SZ_SEL),  // 取值范围：0～3。
                .PMA_REG_TX_DCC_CAL_CUR_TUNE(PMA_CH1_REG_TX_DCC_CAL_CUR_TUNE),  // 取值范围：0～63。
                .PMA_REG_TX_DCC_CAL_EN(PMA_CH1_REG_TX_DCC_CAL_EN),  // 使能选项：开启或关闭。
                .PMA_REG_TX_DCC_CUR_SS(PMA_CH1_REG_TX_DCC_CUR_SS),  // 取值范围：0～3。
                .PMA_REG_TX_DCC_FA_CTRL(PMA_CH1_REG_TX_DCC_FA_CTRL),  // 使能选项：开启或关闭。
                .PMA_REG_TX_DCC_RI_CTRL(PMA_CH1_REG_TX_DCC_RI_CTRL),  // 使能选项：开启或关闭。
                .PMA_REG_ATB_SEL_2_TO_0(PMA_CH1_REG_ATB_SEL_2_TO_0),  // 取值范围：0～7。
                .PMA_REG_ATB_SEL_9_TO_3(PMA_CH1_REG_ATB_SEL_9_TO_3),  // 取值范围：0～127。
                .PMA_REG_TX_CFG_7_TO_0(PMA_CH1_REG_TX_CFG_7_TO_0),  // 取值范围：0～255。
                .PMA_REG_TX_CFG_15_TO_8(PMA_CH1_REG_TX_CFG_15_TO_8),  // 取值范围：0～255。
                .PMA_REG_TX_CFG_23_TO_16(PMA_CH1_REG_TX_CFG_23_TO_16),  // 取值范围：0～255。
                .PMA_REG_TX_CFG_31_TO_24(PMA_CH1_REG_TX_CFG_31_TO_24),  // 取值范围：0～255。
                .PMA_REG_TX_OOB_EI_EN(PMA_CH1_REG_TX_OOB_EI_EN),  // SATA 模式带外电气空闲使能
                .PMA_REG_TX_OOB_EI_EN_OW(PMA_CH1_REG_TX_OOB_EI_EN_OW),  // 使能选项：开启或关闭。
                .PMA_REG_TX_BEACON_EN_DELAYED(PMA_CH1_REG_TX_BEACON_EN_DELAYED),  // 使能选项：开启或关闭。
                .PMA_REG_TX_BEACON_EN_DELAYED_OW             (PMA_CH1_REG_TX_BEACON_EN_DELAYED_OW               ),// 使能选项：开启或关闭。
                .PMA_REG_TX_JTAG_DATA(PMA_CH1_REG_TX_JTAG_DATA),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RXDET_TIMER_SEL(PMA_CH1_REG_TX_RXDET_TIMER_SEL),  // 取值范围：0～255。
                .PMA_REG_TX_CFG1_7_0(PMA_CH1_REG_TX_CFG1_7_0),  // 取值范围：0～255。
                .PMA_REG_TX_CFG1_15_8(PMA_CH1_REG_TX_CFG1_15_8),  // 取值范围：0～255。
                .PMA_REG_TX_CFG1_23_16(PMA_CH1_REG_TX_CFG1_23_16),  // 取值范围：0～255。
                .PMA_REG_TX_CFG1_31_24(PMA_CH1_REG_TX_CFG1_31_24),  // 取值范围：0～255。
                .PMA_REG_CFG_LANE_POWERUP(PMA_CH1_REG_CFG_LANE_POWERUP),  // PMA 通道上电控制
                .PMA_REG_CFG_TX_LANE_POWERUP_CLKPATH         (PMA_CH1_REG_CFG_TX_LANE_POWERUP_CLKPATH           ),// PMA 发送通道时钟路径上电控制
                .PMA_REG_CFG_TX_LANE_POWERUP_PISO            (PMA_CH1_REG_CFG_TX_LANE_POWERUP_PISO              ),// PMA 发送并串转换单元上电控制
                .PMA_REG_CFG_TX_LANE_POWERUP_DRIVER          (PMA_CH1_REG_CFG_TX_LANE_POWERUP_DRIVER            ) // PMA 发送驱动器上电控制
            ) U_GTP_HSSTLP_LANE1 (

                .P_TX_SDN           (P_TX_SDN_1),
                .P_TX_SDP           (P_TX_SDP_1),
                // SRB 相关信号
                .P_PCS_RX_MCB_STATUS(P_PCS_RX_MCB_STATUS_1),
                .P_PCS_LSM_SYNCED   (P_PCS_LSM_SYNCED_1),
                .P_CFG_READY        (P_CFG_READY_1),
                .P_CFG_RDATA        (P_CFG_RDATA_1),
                .P_CFG_INT          (P_CFG_INT_1),
                .P_RDATA            (P_RDATA_1),
                .P_RCLK2FABRIC      (P_RCLK2FABRIC_1),
                .P_TCLK2FABRIC      (P_TCLK2FABRIC_1),
                .P_RX_SIGDET_STATUS (P_RX_SIGDET_STATUS_1),
                .P_RX_SATA_COMINIT  (P_RX_SATA_COMINIT_1),
                .P_RX_SATA_COMWAKE  (P_RX_SATA_COMWAKE_1),
                .P_RX_LS_DATA       (P_RX_LS_DATA_1),
                .P_RX_READY         (P_RX_READY_1),
                .P_TEST_STATUS      (P_TEST_STATUS_1),
                .P_TX_RXDET_STATUS  (P_TX_RXDET_STATUS_1),
                .P_CA_ALIGN_RX      (P_CA_ALIGN_RX_1),
                .P_CA_ALIGN_TX      (P_CA_ALIGN_TX_1),

                .PMA_RCLK             (PMA_RCLK_1),
                .TXPCLK_PLL           (TXPCLK_PLL_1),
                // CIN 与 COUT 级联接口
                .LANE_COUT_BUS_FORWARD(LANE_COUT_BUS_FORWARD_1),
                .APATTERN_STATUS_COUT (APATTERN_STATUS_COUT_1),

                .P_RX_SDN            (P_RX_SDN_1),
                .P_RX_SDP            (P_RX_SDP_1),
                // SRB 相关信号
                .P_RX_CLK_FR_CORE    (P_RX_CLK_FR_CORE_1),
                .P_RCLK2_FR_CORE     (P_RCLK2_FR_CORE_1),
                .P_TX_CLK_FR_CORE    (P_TX_CLK_FR_CORE_1),
                .P_TCLK2_FR_CORE     (P_TCLK2_FR_CORE_1),
                .P_PCS_TX_RST        (P_PCS_TX_RST_1),
                .P_PCS_RX_RST        (P_PCS_RX_RST_1),
                .P_PCS_CB_RST        (P_PCS_CB_RST_1),
                .P_RXGEAR_SLIP       (P_RXGEAR_SLIP_1),
                .P_CFG_CLK           (P_CFG_CLK_1),
                .P_CFG_RST           (P_CFG_RST_1),
                .P_CFG_PSEL          (P_CFG_PSEL_1),
                .P_CFG_ENABLE        (P_CFG_ENABLE_1),
                .P_CFG_WRITE         (P_CFG_WRITE_1),
                .P_CFG_ADDR          (P_CFG_ADDR_1),
                .P_CFG_WDATA         (P_CFG_WDATA_1),
                .P_TDATA             (P_TDATA_1),
                .P_PCS_WORD_ALIGN_EN (P_PCS_WORD_ALIGN_EN_1),
                .P_RX_POLARITY_INVERT(P_RX_POLARITY_INVERT_1),
                .P_CEB_ADETECT_EN    (P_CEB_ADETECT_EN_1),
                .P_PCS_MCB_EXT_EN    (P_PCS_MCB_EXT_EN_1),
                .P_PCS_NEAREND_LOOP  (P_PCS_NEAREND_LOOP_1),
                .P_PCS_FAREND_LOOP   (P_PCS_FAREND_LOOP_1),
                .P_PMA_NEAREND_PLOOP (P_PMA_NEAREND_PLOOP_1),
                .P_PMA_NEAREND_SLOOP (P_PMA_NEAREND_SLOOP_1),
                .P_PMA_FAREND_PLOOP  (P_PMA_FAREND_PLOOP_1),

                .P_LANE_PD           (P_LANE_PD_1),
                .P_LANE_RST          (P_LANE_RST_1),
                .P_RX_LANE_PD        (P_RX_LANE_PD_1),
                .P_RX_PMA_RST        (P_RX_PMA_RST_1),
                .P_CTLE_ADP_RST      (P_CTLE_ADP_RST_1),
                .P_TX_DEEMP          (P_TX_DEEMP_1),
                .P_TX_LS_DATA        (P_TX_LS_DATA_1),
                .P_TX_BEACON_EN      (P_TX_BEACON_EN_1),
                .P_TX_SWING          (P_TX_SWING_1),
                .P_TX_RXDET_REQ      (P_TX_RXDET_REQ_1),
                .P_TX_RATE           (P_TX_RATE_1),
                .P_TX_BUSWIDTH       (P_TX_BUSWIDTH_1),
                .P_TX_MARGIN         (P_TX_MARGIN_1),
                .P_TX_PMA_RST        (P_TX_PMA_RST_1),
                .P_TX_LANE_PD_CLKPATH(P_TX_LANE_PD_CLKPATH_1),
                .P_TX_LANE_PD_PISO   (P_TX_LANE_PD_PISO_1),
                .P_TX_LANE_PD_DRIVER (P_TX_LANE_PD_DRIVER_1),
                .P_RX_RATE           (P_RX_RATE_1),
                .P_RX_BUSWIDTH       (P_RX_BUSWIDTH_1),
                .P_RX_HIGHZ          (P_RX_HIGHZ_1),
                .P_CIM_CLK_ALIGNER_RX(P_CIM_CLK_ALIGNER_RX_1),
                .P_CIM_CLK_ALIGNER_TX(P_CIM_CLK_ALIGNER_TX_1),
                .P_CIM_DYN_DLY_SEL_RX(P_CIM_DYN_DLY_SEL_RX_1),
                .P_CIM_DYN_DLY_SEL_TX(P_CIM_DYN_DLY_SEL_TX_1),
                .P_CIM_START_ALIGN_RX(P_CIM_START_ALIGN_RX_1),
                .P_CIM_START_ALIGN_TX(P_CIM_START_ALIGN_TX_1),
                // 扩展端口
                .MCB_RCLK            (MCB_RCLK_1),
                .SYNC                (SYNC_1),
                .RATE_CHANGE         (RATE_CHANGE_1),
                .PLL_LOCK_SEL        (PLL_LOCK_SEL_1),
                // CIN 与 COUT 级联接口
                .LANE_CIN_BUS_FORWARD(LANE_CIN_BUS_FORWARD_1),
                .APATTERN_STATUS_CIN (APATTERN_STATUS_CIN_1),
                // 来自 PLL
                .CLK_TXP             (CLK_TXP_1),
                .CLK_TXN             (CLK_TXN_1),
                .CLK_RX0             (CLK_RX0_1),
                .CLK_RX90            (CLK_RX90_1),
                .CLK_RX180           (CLK_RX180_1),
                .CLK_RX270           (CLK_RX270_1),
                .PLL_PD_I            (PLL_PD_I_1),
                .PLL_RESET_I         (PLL_RESET_I_1),
                .PLL_REFCLK_I        (PLL_REFCLK_I_1),
                .PLL_RES_TRIM_I      (PLL_RES_TRIM_I_1)
            );
        end else begin : CHANNEL1_NULL
            assign P_TX_SDN_1              = 1'b0;
            assign P_TX_SDP_1              = 1'b0;
            assign P_PCS_RX_MCB_STATUS_1   = 1'b0;
            assign P_PCS_LSM_SYNCED_1      = 1'b0;
            assign P_CFG_READY_1           = 1'b0;
            assign P_CFG_RDATA_1           = 8'b0;
            assign P_CFG_INT_1             = 1'b0;
            assign P_RDATA_1               = 47'b0;
            assign P_RCLK2FABRIC_1         = 1'b0;
            assign P_TCLK2FABRIC_1         = 1'b0;
            assign P_RX_SIGDET_STATUS_1    = 1'b0;
            assign P_RX_SATA_COMINIT_1     = 1'b0;
            assign P_RX_SATA_COMWAKE_1     = 1'b0;
            assign P_RX_LS_DATA_1          = 1'b0;
            assign P_RX_READY_1            = 1'b0;
            assign P_TEST_STATUS_1         = 20'b0;
            assign P_TX_RXDET_STATUS_1     = 1'b0;
            assign P_CA_ALIGN_RX_1         = 1'b0;
            assign P_CA_ALIGN_TX_1         = 1'b0;
            assign PMA_RCLK_1              = 1'b0;
            assign TXPCLK_PLL_1            = 1'b0;
            assign LANE_COUT_BUS_FORWARD_1 = 19'b0;
            assign APATTERN_STATUS_COUT_1  = 1'b0;
        end
    endgenerate

    // 通道 2 例化
    generate
        if (CHANNEL2_EN == "TRUE") begin : CHANNEL2_ENABLE
            GTP_HSSTLP_LANE #(
                .MUX_BIAS      (CH2_MUX_BIAS),       // 取值范围：0～7，不支持仿真。
                .PD_CLK        (CH2_PD_CLK),         // 取值范围：0～1。
                .REG_SYNC      (CH2_REG_SYNC),       // 取值范围：0～1。
                .REG_SYNC_OW   (CH2_REG_SYNC_OW),    // 取值范围：0～1。
                .PLL_LOCK_OW   (CH2_PLL_LOCK_OW),    // 取值范围：0～1。
                .PLL_LOCK_OW_EN(CH2_PLL_LOCK_OW_EN), // 取值范围：0～1。

                .PCS_SLAVE(PCS_CH2_SLAVE),
                .PCS_BYPASS_WORD_ALIGN(PCS_CH2_BYPASS_WORD_ALIGN),  // 字对齐旁路使能
                .PCS_BYPASS_DENC(PCS_CH2_BYPASS_DENC),  // 8b/10b 解码旁路使能
                .PCS_BYPASS_BONDING(PCS_CH2_BYPASS_BONDING),  // 通道绑定旁路使能
                .PCS_BYPASS_CTC(PCS_CH2_BYPASS_CTC),  // 时钟补偿旁路使能
                .PCS_BYPASS_GEAR(PCS_CH2_BYPASS_GEAR),  // 接收齿轮箱旁路使能
                .PCS_BYPASS_BRIDGE(PCS_CH2_BYPASS_BRIDGE),  // 接收桥接单元旁路使能
                .PCS_BYPASS_BRIDGE_FIFO(PCS_CH2_BYPASS_BRIDGE_FIFO),  // 接收桥接 FIFO 旁路使能
                .PCS_DATA_MODE(PCS_CH2_DATA_MODE),  // 参数选项："X8","X10","X16","X20"
                .PCS_RX_POLARITY_INV                         (PCS_CH2_RX_POLARITY_INV                           ),// 数据变换：延迟、位极性反转、位序反转或两者同时反转。
                .PCS_ALIGN_MODE(PCS_CH2_ALIGN_MODE),  // 协议模式：1GB、10GB、RAPIDIO 或外部模式。
                .PCS_SAMP_16B(PCS_CH2_SAMP_16B),  // 参数选项："X20",X16
                .PCS_FARLP_PWR_REDUCTION(PCS_CH2_FARLP_PWR_REDUCTION),  // 使能选项：开启或关闭。
                .PCS_COMMA_REG0(PCS_CH2_COMMA_REG0),  // 取值范围：0～1023。
                .PCS_COMMA_MASK(PCS_CH2_COMMA_MASK),  // 取值范围：0～1023。
                .PCS_CEB_MODE(PCS_CH2_CEB_MODE),  // 协议模式：10GB、RAPIDIO 或外部模式。
                .PCS_CTC_MODE                                (PCS_CH2_CTC_MODE                                  ),// 跳过字符模式：单字符、双字符、PCIe 双字节或四字符。
                .PCS_A_REG(PCS_CH2_A_REG),  // 取值范围：0～255。
                .PCS_GE_AUTO_EN(PCS_CH2_GE_AUTO_EN),  // 使能选项：开启或关闭。
                .PCS_SKIP_REG0(PCS_CH2_SKIP_REG0),  // 取值范围：0～1023。
                .PCS_SKIP_REG1(PCS_CH2_SKIP_REG1),  // 取值范围：0～1023。
                .PCS_SKIP_REG2(PCS_CH2_SKIP_REG2),  // 取值范围：0～1023。
                .PCS_SKIP_REG3(PCS_CH2_SKIP_REG3),  // 取值范围：0～1023。
                .PCS_DEC_DUAL(PCS_CH2_DEC_DUAL),  // 使能选项：开启或关闭。
                .PCS_SPLIT(PCS_CH2_SPLIT),  // 使能选项：开启或关闭。
                .PCS_FIFOFLAG_CTC(PCS_CH2_FIFOFLAG_CTC),  // 使能选项：开启或关闭。
                .PCS_COMMA_DET_MODE(PCS_CH2_COMMA_DET_MODE),  // 参数选项："RX_CLK_SLIP" "COMMA_PATTERN"
                .PCS_ERRDETECT_SILENCE(PCS_CH2_ERRDETECT_SILENCE),  // 使能选项：开启或关闭。
                .PCS_PMA_RCLK_POLINV(PCS_CH2_PMA_RCLK_POLINV),  // 参数选项："PMA_RCLK" "REVERSE_OF_PMA_RCLK"
                .PCS_PCS_RCLK_SEL(PCS_CH2_PCS_RCLK_SEL),  // 参数选项："PMA_RCLK" "PMA_TCLK" "RCLK"
                .PCS_CB_RCLK_SEL(PCS_CH2_CB_RCLK_SEL),  // 参数选项："PMA_RCLK" "PMA_TCLK" "MCB_RCLK"
                .PCS_AFTER_CTC_RCLK_SEL                      (PCS_CH2_AFTER_CTC_RCLK_SEL                        ),// 参数选项："PMA_RCLK" "PMA_TCLK" "MCB_RCLK" "RCLK2"
                .PCS_RCLK_POLINV(PCS_CH2_RCLK_POLINV),  // 参数选项："RCLK" "REVERSE_OF_RCLK"
                .PCS_BRIDGE_RCLK_SEL                         (PCS_CH2_BRIDGE_RCLK_SEL                           ),// 参数选项："PMA_RCLK" "PMA_TCLK" "MCB_RCLK" "RCLK"
                .PCS_PCS_RCLK_EN(PCS_CH2_PCS_RCLK_EN),  // 使能选项：开启或关闭。
                .PCS_CB_RCLK_EN(PCS_CH2_CB_RCLK_EN),  // 使能选项：开启或关闭。
                .PCS_AFTER_CTC_RCLK_EN(PCS_CH2_AFTER_CTC_RCLK_EN),  // 使能选项：开启或关闭。
                .PCS_AFTER_CTC_RCLK_EN_GB(PCS_CH2_AFTER_CTC_RCLK_EN_GB),  // 使能选项：开启或关闭。
                .PCS_PCS_RX_RSTN(PCS_CH2_PCS_RX_RSTN),  // PCS 接收端复位控制
                .PCS_PCIE_SLAVE(PCS_CH2_PCIE_SLAVE),  // 通道角色：主通道或从通道。
                .PCS_RX_64B66B_67B(PCS_CH2_RX_64B66B_67B),  // 编码模式：普通、64b/66b 或 64b/67b。
                .PCS_RX_BRIDGE_CLK_POLINV                    (PCS_CH2_RX_BRIDGE_CLK_POLINV                      ),// 参数选项："RX_BRIDGE_CLK" "REVERSE_OF_RX_BRIDGE_CLK"
                .PCS_PCS_CB_RSTN(PCS_CH2_PCS_CB_RSTN),  // PCS 通道绑定复位控制
                .PCS_TX_BRIDGE_GEAR_SEL                      (PCS_CH2_TX_BRIDGE_GEAR_SEL                        ),// TRUE 优先使用发送齿轮箱，FALSE 优先使用发送桥接单元。
                .PCS_TX_BYPASS_BRIDGE_UINT(PCS_CH2_TX_BYPASS_BRIDGE_UINT),  // 旁路使能
                .PCS_TX_BYPASS_BRIDGE_FIFO(PCS_CH2_TX_BYPASS_BRIDGE_FIFO),  // 发送桥接 FIFO 旁路使能
                .PCS_TX_BYPASS_GEAR(PCS_CH2_TX_BYPASS_GEAR),  // 使能选项：开启或关闭。
                .PCS_TX_BYPASS_ENC(PCS_CH2_TX_BYPASS_ENC),  // 使能选项：开启或关闭。
                .PCS_TX_BYPASS_BIT_SLIP(PCS_CH2_TX_BYPASS_BIT_SLIP),  // 使能选项：开启或关闭。
                .PCS_TX_GEAR_SPLIT(PCS_CH2_TX_GEAR_SPLIT),  // 使能选项：开启或关闭。
                .PCS_TX_DRIVE_REG_MODE                       (PCS_CH2_TX_DRIVE_REG_MODE                         ),// 变换选项：不变、极性反转、位序反转或两者同时反转。
                .PCS_TX_BIT_SLIP_CYCLES(PCS_CH2_TX_BIT_SLIP_CYCLES),  // 取值范围：0～31。
                .PCS_INT_TX_MASK_0(PCS_CH2_INT_TX_MASK_0),  // 使能选项：开启或关闭。
                .PCS_INT_TX_MASK_1(PCS_CH2_INT_TX_MASK_1),  // 使能选项：开启或关闭。
                .PCS_INT_TX_MASK_2(PCS_CH2_INT_TX_MASK_2),  // 使能选项：开启或关闭。
                .PCS_INT_TX_CLR_0(PCS_CH2_INT_TX_CLR_0),  // 使能选项：开启或关闭。
                .PCS_INT_TX_CLR_1(PCS_CH2_INT_TX_CLR_1),  // 使能选项：开启或关闭。
                .PCS_INT_TX_CLR_2(PCS_CH2_INT_TX_CLR_2),  // 使能选项：开启或关闭。
                .PCS_TX_PMA_TCLK_POLINV(PCS_CH2_TX_PMA_TCLK_POLINV),  // 参数选项："PMA_TCLK" "REVERSE_OF_PMA_TCLK"
                .PCS_TX_PCS_CLK_EN_SEL(PCS_CH2_TX_PCS_CLK_EN_SEL),  // 使能选项：开启或关闭。
                .PCS_TX_BRIDGE_TCLK_SEL(PCS_CH2_TX_BRIDGE_TCLK_SEL),  // 参数选项："PCS_TCLK" "TCLK"
                .PCS_TX_TCLK_POLINV(PCS_CH2_TX_TCLK_POLINV),  // 参数选项："TCLK" "REVERSE_OF_TCLK"
                .PCS_PCS_TCLK_SEL(PCS_CH2_PCS_TCLK_SEL),  // 参数选项："PMA_TCLK" "TCLK"
                .PCS_TX_PCS_TX_RSTN(PCS_CH2_TX_PCS_TX_RSTN),  // PCS 发送端复位控制
                .PCS_TX_SLAVE(PCS_CH2_TX_SLAVE),  // 通道角色：主通道或从通道。
                .PCS_TX_GEAR_CLK_EN_SEL(PCS_CH2_TX_GEAR_CLK_EN_SEL),  // 使能选项：开启或关闭。
                .PCS_DATA_WIDTH_MODE(PCS_CH2_DATA_WIDTH_MODE),  // 参数选项："X8" "X10" "X16" "X20"
                .PCS_TX_64B66B_67B(PCS_CH2_TX_64B66B_67B),  // 编码模式：普通、64b/66b 或 64b/67b。
                .PCS_GEAR_TCLK_SEL(PCS_CH2_GEAR_TCLK_SEL),  // 参数选项："PMA_TCLK" "TCLK2"
                .PCS_TX_TCLK2FABRIC_SEL(PCS_CH2_TX_TCLK2FABRIC_SEL),  // 使能选项：开启或关闭。
                .PCS_TX_OUTZZ(PCS_CH2_TX_OUTZZ),  // 使能选项：开启或关闭。
                .PCS_ENC_DUAL(PCS_CH2_ENC_DUAL),  // 使能选项：开启或关闭。
                .PCS_TX_BITSLIP_DATA_MODE(PCS_CH2_TX_BITSLIP_DATA_MODE),  // 参数选项："X10" "X20"
                .PCS_TX_BRIDGE_CLK_POLINV                    (PCS_CH2_TX_BRIDGE_CLK_POLINV                      ),// 参数选项："TX_BRIDGE_CLK" "REVERSE_OF_TX_BRIDGE_CLK"
                .PCS_COMMA_REG1(PCS_CH2_COMMA_REG1),  // 取值范围：0～1023。
                .PCS_RAPID_IMAX(PCS_CH2_RAPID_IMAX),  // 取值范围：0～7。
                .PCS_RAPID_VMIN_1(PCS_CH2_RAPID_VMIN_1),  // 取值范围：0～255。
                .PCS_RAPID_VMIN_2(PCS_CH2_RAPID_VMIN_2),  // 取值范围：0～255。
                .PCS_RX_PRBS_MODE                            (PCS_CH2_RX_PRBS_MODE                              ),// PRBS 配置：关闭或选择 7、15、23、31 阶多项式。
                .PCS_RX_ERRCNT_CLR(PCS_CH2_RX_ERRCNT_CLR),  // 使能选项：开启或关闭。
                .PCS_PRBS_ERR_LPBK(PCS_CH2_PRBS_ERR_LPBK),  // 使能选项：开启或关闭。
                .PCS_TX_PRBS_MODE                            (PCS_CH2_TX_PRBS_MODE                              ),// 测试码型：PRBS、长 1、长 0、20 UI、D10.2 或 PCIe。
                .PCS_TX_INSERT_ER(PCS_CH2_TX_INSERT_ER),  // 使能选项：开启或关闭。
                .PCS_ENABLE_PRBS_GEN(PCS_CH2_ENABLE_PRBS_GEN),  // 使能选项：开启或关闭。
                .PCS_DEFAULT_RADDR(PCS_CH2_DEFAULT_RADDR),  // 取值范围：0～15。
                .PCS_MASTER_CHECK_OFFSET(PCS_CH2_MASTER_CHECK_OFFSET),  // 取值范围：0～15。
                .PCS_DELAY_SET(PCS_CH2_DELAY_SET),  // 取值范围：0～15。
                .PCS_SEACH_OFFSET(PCS_CH2_SEACH_OFFSET),  // 绑定位宽：20～80 位，间隔 10 位。
                .PCS_CEB_RAPIDLS_MMAX(PCS_CH2_CEB_RAPIDLS_MMAX),  // 取值范围：0～7。
                .PCS_CTC_AFULL(PCS_CH2_CTC_AFULL),  // 取值范围：0～31。
                .PCS_CTC_AEMPTY(PCS_CH2_CTC_AEMPTY),  // 取值范围：0～31。
                .PCS_CTC_CONTI_SKP_SET(PCS_CH2_CTC_CONTI_SKP_SET),  // 取值范围：0～1。
                .PCS_FAR_LOOP(PCS_CH2_FAR_LOOP),  // 使能选项：开启或关闭。
                .PCS_NEAR_LOOP(PCS_CH2_NEAR_LOOP),  // 使能选项：开启或关闭。
                .PCS_PMA_TX2RX_PLOOP_EN(PCS_CH2_PMA_TX2RX_PLOOP_EN),  // 使能选项：开启或关闭。
                .PCS_PMA_TX2RX_SLOOP_EN(PCS_CH2_PMA_TX2RX_SLOOP_EN),  // 使能选项：开启或关闭。
                .PCS_PMA_RX2TX_PLOOP_EN(PCS_CH2_PMA_RX2TX_PLOOP_EN),  // 使能选项：开启或关闭。
                .PCS_INT_RX_MASK_0(PCS_CH2_INT_RX_MASK_0),  // 使能选项：开启或关闭。
                .PCS_INT_RX_MASK_1(PCS_CH2_INT_RX_MASK_1),  // 使能选项：开启或关闭。
                .PCS_INT_RX_MASK_2(PCS_CH2_INT_RX_MASK_2),  // 使能选项：开启或关闭。
                .PCS_INT_RX_MASK_3(PCS_CH2_INT_RX_MASK_3),  // 使能选项：开启或关闭。
                .PCS_INT_RX_MASK_4(PCS_CH2_INT_RX_MASK_4),  // 使能选项：开启或关闭。
                .PCS_INT_RX_MASK_5(PCS_CH2_INT_RX_MASK_5),  // 使能选项：开启或关闭。
                .PCS_INT_RX_MASK_6(PCS_CH2_INT_RX_MASK_6),  // 使能选项：开启或关闭。
                .PCS_INT_RX_MASK_7(PCS_CH2_INT_RX_MASK_7),  // 使能选项：开启或关闭。
                .PCS_INT_RX_CLR_0(PCS_CH2_INT_RX_CLR_0),  // 使能选项：开启或关闭。
                .PCS_INT_RX_CLR_1(PCS_CH2_INT_RX_CLR_1),  // 使能选项：开启或关闭。
                .PCS_INT_RX_CLR_2(PCS_CH2_INT_RX_CLR_2),  // 使能选项：开启或关闭。
                .PCS_INT_RX_CLR_3(PCS_CH2_INT_RX_CLR_3),  // 使能选项：开启或关闭。
                .PCS_INT_RX_CLR_4(PCS_CH2_INT_RX_CLR_4),  // 使能选项：开启或关闭。
                .PCS_INT_RX_CLR_5(PCS_CH2_INT_RX_CLR_5),  // 使能选项：开启或关闭。
                .PCS_INT_RX_CLR_6(PCS_CH2_INT_RX_CLR_6),  // 使能选项：开启或关闭。
                .PCS_INT_RX_CLR_7(PCS_CH2_INT_RX_CLR_7),  // 使能选项：开启或关闭。
                .PCS_CA_RSTN_RX(PCS_CH2_CA_RSTN_RX),  // 接收时钟对齐器复位控制
                .PCS_CA_DYN_DLY_EN_RX(PCS_CH2_CA_DYN_DLY_EN_RX),  // 使能选项：开启或关闭。
                .PCS_CA_DYN_DLY_SEL_RX(PCS_CH2_CA_DYN_DLY_SEL_RX),  // 使能选项：开启或关闭。
                .PCS_CA_RX(PCS_CH2_CA_RX),  // 取值范围：0～255。
                .PCS_CA_RSTN_TX(PCS_CH2_CA_RSTN_TX),  // 使能选项：开启或关闭。
                .PCS_CA_DYN_DLY_EN_TX(PCS_CH2_CA_DYN_DLY_EN_TX),  // 使能选项：开启或关闭。
                .PCS_CA_DYN_DLY_SEL_TX(PCS_CH2_CA_DYN_DLY_SEL_TX),  // 使能选项：开启或关闭。
                .PCS_CA_TX(PCS_CH2_CA_TX),  // 取值范围：0～255。
                .PCS_RXPRBS_PWR_REDUCTION(PCS_CH2_RXPRBS_PWR_REDUCTION),  // 工作模式：普通或低功耗。
                .PCS_WDALIGN_PWR_REDUCTION(PCS_CH2_WDALIGN_PWR_REDUCTION),  // 工作模式：普通或低功耗。
                .PCS_RXDEC_PWR_REDUCTION(PCS_CH2_RXDEC_PWR_REDUCTION),  // 工作模式：普通或低功耗。
                .PCS_RXCB_PWR_REDUCTION(PCS_CH2_RXCB_PWR_REDUCTION),  // 工作模式：普通或低功耗。
                .PCS_RXCTC_PWR_REDUCTION(PCS_CH2_RXCTC_PWR_REDUCTION),  // 工作模式：普通或低功耗。
                .PCS_RXGEAR_PWR_REDUCTION(PCS_CH2_RXGEAR_PWR_REDUCTION),  // 工作模式：普通或低功耗。
                .PCS_RXBRG_PWR_REDUCTION(PCS_CH2_RXBRG_PWR_REDUCTION),  // 工作模式：普通或低功耗。
                .PCS_RXTEST_PWR_REDUCTION(PCS_CH2_RXTEST_PWR_REDUCTION),  // 工作模式：普通或低功耗。
                .PCS_TXBRG_PWR_REDUCTION(PCS_CH2_TXBRG_PWR_REDUCTION),  // 工作模式：普通或低功耗。
                .PCS_TXGEAR_PWR_REDUCTION(PCS_CH2_TXGEAR_PWR_REDUCTION),  // 工作模式：普通或低功耗。
                .PCS_TXENC_PWR_REDUCTION(PCS_CH2_TXENC_PWR_REDUCTION),  // 工作模式：普通或低功耗。
                .PCS_TXBSLP_PWR_REDUCTION(PCS_CH2_TXBSLP_PWR_REDUCTION),  // 工作模式：普通或低功耗。
                .PCS_TXPRBS_PWR_REDUCTION(PCS_CH2_TXPRBS_PWR_REDUCTION),  // 工作模式：普通或低功耗。

                .PMA_REG_RX_PD(PMA_CH2_REG_RX_PD),  // 使能选项：开启或关闭。
                .PMA_REG_RX_PD_EN(PMA_CH2_REG_RX_PD_EN),  // 使能选项：开启或关闭。
                .PMA_REG_RX_RESERVED_2(PMA_CH2_REG_RX_RESERVED_2),  // 使能选项：开启或关闭。
                .PMA_REG_RX_RESERVED_3(PMA_CH2_REG_RX_RESERVED_3),  // 使能选项：开启或关闭。
                .PMA_REG_RX_DATAPATH_PD(PMA_CH2_REG_RX_DATAPATH_PD),  // 使能选项：开启或关闭。
                .PMA_REG_RX_DATAPATH_PD_EN(PMA_CH2_REG_RX_DATAPATH_PD_EN),  // 使能选项：开启或关闭。
                .PMA_REG_RX_SIGDET_PD(PMA_CH2_REG_RX_SIGDET_PD),  // 使能选项：开启或关闭。
                .PMA_REG_RX_SIGDET_PD_EN(PMA_CH2_REG_RX_SIGDET_PD_EN),  // 使能选项：开启或关闭。
                .PMA_REG_RX_DCC_RST_N(PMA_CH2_REG_RX_DCC_RST_N),  // 使能选项：开启或关闭。
                .PMA_REG_RX_DCC_RST_N_EN(PMA_CH2_REG_RX_DCC_RST_N_EN),  // 使能选项：开启或关闭。
                .PMA_REG_RX_CDR_RST_N(PMA_CH2_REG_RX_CDR_RST_N),  // 使能选项：开启或关闭。
                .PMA_REG_RX_CDR_RST_N_EN(PMA_CH2_REG_RX_CDR_RST_N_EN),  // 使能选项：开启或关闭。
                .PMA_REG_RX_SIGDET_RST_N(PMA_CH2_REG_RX_SIGDET_RST_N),  // 使能选项：开启或关闭。
                .PMA_REG_RX_SIGDET_RST_N_EN(PMA_CH2_REG_RX_SIGDET_RST_N_EN),  // 使能选项：开启或关闭。
                .PMA_REG_RXPCLK_SLIP(PMA_CH2_REG_RXPCLK_SLIP),  // 使能选项：开启或关闭。
                .PMA_REG_RXPCLK_SLIP_OW(PMA_CH2_REG_RXPCLK_SLIP_OW),  // 使能选项：开启或关闭。
                .PMA_REG_RX_PCLKSWITCH_RST_N(PMA_CH2_REG_RX_PCLKSWITCH_RST_N),  // 发送 PMA 复位控制
                .PMA_REG_RX_PCLKSWITCH_RST_N_EN              (PMA_CH2_REG_RX_PCLKSWITCH_RST_N_EN                ),// 使能选项：开启或关闭。
                .PMA_REG_RX_PCLKSWITCH(PMA_CH2_REG_RX_PCLKSWITCH),  // 使能选项：开启或关闭。
                .PMA_REG_RX_PCLKSWITCH_EN(PMA_CH2_REG_RX_PCLKSWITCH_EN),  // 使能选项：开启或关闭。
                .PMA_REG_RX_HIGHZ(PMA_CH2_REG_RX_HIGHZ),  // 使能选项：开启或关闭。
                .PMA_REG_RX_HIGHZ_EN(PMA_CH2_REG_RX_HIGHZ_EN),  // 使能选项：开启或关闭。
                .PMA_REG_RX_SIGDET_CLK_WINDOW(PMA_CH2_REG_RX_SIGDET_CLK_WINDOW),  // 使能选项：开启或关闭。
                .PMA_REG_RX_SIGDET_CLK_WINDOW_OW             (PMA_CH2_REG_RX_SIGDET_CLK_WINDOW_OW               ),// 使能选项：开启或关闭。
                .PMA_REG_RX_PD_BIAS_RX(PMA_CH2_REG_RX_PD_BIAS_RX),  // 使能选项：开启或关闭。
                .PMA_REG_RX_PD_BIAS_RX_OW(PMA_CH2_REG_RX_PD_BIAS_RX_OW),  // 使能选项：开启或关闭。
                .PMA_REG_RX_RESET_N(PMA_CH2_REG_RX_RESET_N),  // 使能选项：开启或关闭。
                .PMA_REG_RX_RESET_N_OW(PMA_CH2_REG_RX_RESET_N_OW),  // 使能选项：开启或关闭。
                .PMA_REG_RX_RESERVED_29_28(PMA_CH2_REG_RX_RESERVED_29_28),  // 取值范围：0～3。
                .PMA_REG_RX_BUSWIDTH(PMA_CH2_REG_RX_BUSWIDTH),  // 位宽选项：8、10、16 或 20 位。
                .PMA_REG_RX_BUSWIDTH_EN(PMA_CH2_REG_RX_BUSWIDTH_EN),  // 使能选项：开启或关闭。
                .PMA_REG_RX_RATE(PMA_CH2_REG_RX_RATE),  // 时钟倍率：四分频、二分频、原频或二倍频。
                .PMA_REG_RX_RESERVED_36(PMA_CH2_REG_RX_RESERVED_36),  // 使能选项：开启或关闭。
                .PMA_REG_RX_RATE_EN(PMA_CH2_REG_RX_RATE_EN),  // 使能选项：开启或关闭。
                .PMA_REG_RX_RES_TRIM(PMA_CH2_REG_RX_RES_TRIM),  // 取值范围：0～63。
                .PMA_REG_RX_RESERVED_44(PMA_CH2_REG_RX_RESERVED_44),  // 使能选项：开启或关闭。
                .PMA_REG_RX_RESERVED_45(PMA_CH2_REG_RX_RESERVED_45),  // 使能选项：开启或关闭。
                .PMA_REG_RX_SIGDET_STATUS_EN(PMA_CH2_REG_RX_SIGDET_STATUS_EN),  // 使能选项：开启或关闭。
                .PMA_REG_RX_RESERVED_48_47(PMA_CH2_REG_RX_RESERVED_48_47),  // 取值范围：0～3。
                .PMA_REG_RX_ICTRL_SIGDET(PMA_CH2_REG_RX_ICTRL_SIGDET),  // 取值范围：0～15。
                .PMA_REG_CDR_READY_THD(PMA_CH2_REG_CDR_READY_THD),  // 取值范围：0～4095。
                .PMA_REG_RX_RESERVED_65(PMA_CH2_REG_RX_RESERVED_65),  // 使能选项：开启或关闭。
                .PMA_REG_RX_PCLK_EDGE_SEL(PMA_CH2_REG_RX_PCLK_EDGE_SEL),  // 时钟边沿：上升沿或下降沿。
                .PMA_REG_RX_PIBUF_IC(PMA_CH2_REG_RX_PIBUF_IC),  // 取值范围：0～3。
                .PMA_REG_RX_RESERVED_69(PMA_CH2_REG_RX_RESERVED_69),  // 使能选项：开启或关闭。
                .PMA_REG_RX_DCC_IC_RX(PMA_CH2_REG_RX_DCC_IC_RX),  // 取值范围：0～3。
                .PMA_REG_CDR_READY_CHECK_CTRL(PMA_CH2_REG_CDR_READY_CHECK_CTRL),  // 取值范围：0～3。
                .PMA_REG_RX_ICTRL_TRX(PMA_CH2_REG_RX_ICTRL_TRX),  // 比例选项：87.5%、100%、112.5%、125%。
                .PMA_REG_RX_RESERVED_77_76(PMA_CH2_REG_RX_RESERVED_77_76),  // 取值范围：0～3。
                .PMA_REG_RX_RESERVED_79_78(PMA_CH2_REG_RX_RESERVED_79_78),  // 取值范围：0～3。
                .PMA_REG_RX_RESERVED_81_80(PMA_CH2_REG_RX_RESERVED_81_80),  // 取值范围：0～3。
                .PMA_REG_RX_ICTRL_PIBUF(PMA_CH2_REG_RX_ICTRL_PIBUF),  // 比例选项：87.5%、100%、112.5%、125%。
                .PMA_REG_RX_ICTRL_PI(PMA_CH2_REG_RX_ICTRL_PI),  // 比例选项：87.5%、100%、112.5%、125%。
                .PMA_REG_RX_ICTRL_DCC(PMA_CH2_REG_RX_ICTRL_DCC),  // 比例选项：87.5%、100%、112.5%、125%。
                .PMA_REG_RX_RESERVED_89_88(PMA_CH2_REG_RX_RESERVED_89_88),  // 取值范围：0～3。
                .PMA_REG_TX_RATE(PMA_CH2_REG_TX_RATE),  // 时钟倍率：四分频、二分频、原频或二倍频。
                .PMA_REG_RX_RESERVED_92(PMA_CH2_REG_RX_RESERVED_92),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RATE_EN(PMA_CH2_REG_TX_RATE_EN),  // 使能选项：开启或关闭。
                .PMA_REG_RX_TX2RX_PLPBK_RST_N                (PMA_CH2_REG_RX_TX2RX_PLPBK_RST_N                  ),// PMA 发送到接收并行环回复位控制
                .PMA_REG_RX_TX2RX_PLPBK_RST_N_EN             (PMA_CH2_REG_RX_TX2RX_PLPBK_RST_N_EN               ),// 使能选项：开启或关闭。
                .PMA_REG_RX_TX2RX_PLPBK_EN(PMA_CH2_REG_RX_TX2RX_PLPBK_EN),  // PMA 发送到接收并行环回使能
                .PMA_REG_TXCLK_SEL(PMA_CH2_REG_TXCLK_SEL),  // 时钟来源：PLL 或接收时钟。
                .PMA_REG_RX_DATA_POLARITY(PMA_CH2_REG_RX_DATA_POLARITY),  // 极性选项：正常或反转。
                .PMA_REG_RX_ERR_INSERT(PMA_CH2_REG_RX_ERR_INSERT),  // 使能选项：开启或关闭。
                .PMA_REG_UDP_CHK_EN(PMA_CH2_REG_UDP_CHK_EN),  // 使能选项：开启或关闭。
                .PMA_REG_PRBS_SEL(PMA_CH2_REG_PRBS_SEL),  // PRBS 多项式阶数：7、15、23、31。
                .PMA_REG_PRBS_CHK_EN(PMA_CH2_REG_PRBS_CHK_EN),  // 使能选项：开启或关闭。
                .PMA_REG_PRBS_CHK_WIDTH_SEL                  (PMA_CH2_REG_PRBS_CHK_WIDTH_SEL                    ),// 位宽选项：8、10、16 或 20 位。
                .PMA_REG_BIST_CHK_PAT_SEL(PMA_CH2_REG_BIST_CHK_PAT_SEL),  // 码型来源：PRBS 或常量。
                .PMA_REG_LOAD_ERR_CNT(PMA_CH2_REG_LOAD_ERR_CNT),  // 使能选项：开启或关闭。
                .PMA_REG_CHK_COUNTER_EN(PMA_CH2_REG_CHK_COUNTER_EN),  // 使能选项：开启或关闭。
                .PMA_REG_CDR_PROP_GAIN(PMA_CH2_REG_CDR_PROP_GAIN),  // 取值范围：0～7。
                .PMA_REG_CDR_PROP_TURBO_GAIN(PMA_CH2_REG_CDR_PROP_TURBO_GAIN),  // 取值范围：0～7。
                .PMA_REG_CDR_INT_GAIN(PMA_CH2_REG_CDR_INT_GAIN),  // 取值范围：0～7。
                .PMA_REG_CDR_INT_TURBO_GAIN(PMA_CH2_REG_CDR_INT_TURBO_GAIN),  // 取值范围：0～7。
                .PMA_REG_CDR_INT_SAT_MAX(PMA_CH2_REG_CDR_INT_SAT_MAX),  // 取值范围：0～1023。
                .PMA_REG_CDR_INT_SAT_MIN(PMA_CH2_REG_CDR_INT_SAT_MIN),  // 取值范围：0～1023。
                .PMA_REG_CDR_INT_RST(PMA_CH2_REG_CDR_INT_RST),  // 使能选项：开启或关闭。
                .PMA_REG_CDR_INT_RST_OW(PMA_CH2_REG_CDR_INT_RST_OW),  // 使能选项：开启或关闭。
                .PMA_REG_CDR_PROP_RST(PMA_CH2_REG_CDR_PROP_RST),  // 使能选项：开启或关闭。
                .PMA_REG_CDR_PROP_RST_OW(PMA_CH2_REG_CDR_PROP_RST_OW),  // 使能选项：开启或关闭。
                .PMA_REG_CDR_LOCK_RST(PMA_CH2_REG_CDR_LOCK_RST),  // CDR 锁定计数器复位控制
                .PMA_REG_CDR_LOCK_RST_OW(PMA_CH2_REG_CDR_LOCK_RST_OW),  // 使能选项：开启或关闭。
                .PMA_REG_CDR_RX_PI_FORCE_SEL(PMA_CH2_REG_CDR_RX_PI_FORCE_SEL),  //0,1
                .PMA_REG_CDR_RX_PI_FORCE_D(PMA_CH2_REG_CDR_RX_PI_FORCE_D),  // 取值范围：0～255。
                .PMA_REG_CDR_LOCK_TIMER                      (PMA_CH2_REG_CDR_LOCK_TIMER                        ),// 参数选项："0_8U" "1_2U" "1_6U" "2_4U" 3_2U" "4_8U" "12_8U" "25_6U"
                .PMA_REG_CDR_TURBO_MODE_TIMER(PMA_CH2_REG_CDR_TURBO_MODE_TIMER),  // 取值范围：0～3。
                .PMA_REG_CDR_LOCK_VAL(PMA_CH2_REG_CDR_LOCK_VAL),  // 使能选项：开启或关闭。
                .PMA_REG_CDR_LOCK_OW(PMA_CH2_REG_CDR_LOCK_OW),  // 使能选项：开启或关闭。
                .PMA_REG_CDR_INT_SAT_DET_EN(PMA_CH2_REG_CDR_INT_SAT_DET_EN),  // 使能选项：开启或关闭。
                .PMA_REG_CDR_SAT_AUTO_DIS(PMA_CH2_REG_CDR_SAT_AUTO_DIS),  // 使能选项：开启或关闭。
                .PMA_REG_CDR_GAIN_AUTO(PMA_CH2_REG_CDR_GAIN_AUTO),  // 使能选项：开启或关闭。
                .PMA_REG_CDR_TURBO_GAIN_AUTO(PMA_CH2_REG_CDR_TURBO_GAIN_AUTO),  // 使能选项：开启或关闭。
                .PMA_REG_RX_RESERVED_171_167(PMA_CH2_REG_RX_RESERVED_171_167),  // 取值范围：0～31。
                .PMA_REG_RX_RESERVED_175_172(PMA_CH2_REG_RX_RESERVED_175_172),  // 取值范围：0～31。
                .PMA_REG_CDR_SAT_DET_STATUS_EN(PMA_CH2_REG_CDR_SAT_DET_STATUS_EN),  // 使能选项：开启或关闭。
                .PMA_REG_CDR_SAT_DET_STATUS_RESET_EN         (PMA_CH2_REG_CDR_SAT_DET_STATUS_RESET_EN           ),// 使能选项：开启或关闭。
                .PMA_REG_CDR_PI_CTRL_RST(PMA_CH2_REG_CDR_PI_CTRL_RST),  // 使能选项：开启或关闭。
                .PMA_REG_CDR_PI_CTRL_RST_OW(PMA_CH2_REG_CDR_PI_CTRL_RST_OW),  // 使能选项：开启或关闭。
                .PMA_REG_CDR_SAT_DET_RST(PMA_CH2_REG_CDR_SAT_DET_RST),  // 使能选项：开启或关闭。
                .PMA_REG_CDR_SAT_DET_RST_OW(PMA_CH2_REG_CDR_SAT_DET_RST_OW),  // 使能选项：开启或关闭。
                .PMA_REG_CDR_SAT_DET_STICKY_RST              (PMA_CH2_REG_CDR_SAT_DET_STICKY_RST                ),// 使能选项：开启或关闭。
                .PMA_REG_CDR_SAT_DET_STICKY_RST_OW           (PMA_CH2_REG_CDR_SAT_DET_STICKY_RST_OW             ),// 使能选项：开启或关闭。
                .PMA_REG_CDR_SIGDET_STATUS_DIS               (PMA_CH2_REG_CDR_SIGDET_STATUS_DIS                 ),// 无信号检测状态时复位 CDR。
                .PMA_REG_CDR_SAT_DET_TIMER(PMA_CH2_REG_CDR_SAT_DET_TIMER),  // 取值范围：0～3。
                .PMA_REG_CDR_SAT_DET_STATUS_VAL              (PMA_CH2_REG_CDR_SAT_DET_STATUS_VAL                ),// 使能选项：开启或关闭。
                .PMA_REG_CDR_SAT_DET_STATUS_OW(PMA_CH2_REG_CDR_SAT_DET_STATUS_OW),  // 使能选项：开启或关闭。
                .PMA_REG_CDR_TURBO_MODE_EN(PMA_CH2_REG_CDR_TURBO_MODE_EN),  // 使能选项：开启或关闭。
                .PMA_REG_RX_RESERVED_190(PMA_CH2_REG_RX_RESERVED_190),  // 使能选项：开启或关闭。
                .PMA_REG_RX_RESERVED_193_191(PMA_CH2_REG_RX_RESERVED_193_191),  // 取值范围：0～7。
                .PMA_REG_CDR_STATUS_FIFO_EN(PMA_CH2_REG_CDR_STATUS_FIFO_EN),  // 使能选项：开启或关闭。
                .PMA_REG_PMA_TEST_SEL(PMA_CH2_REG_PMA_TEST_SEL),  //0,1
                .PMA_REG_OOB_COMWAKE_GAP_MIN(PMA_CH2_REG_OOB_COMWAKE_GAP_MIN),  // 取值范围：0～63。
                .PMA_REG_OOB_COMWAKE_GAP_MAX(PMA_CH2_REG_OOB_COMWAKE_GAP_MAX),  // 取值范围：0～63。
                .PMA_REG_OOB_COMINIT_GAP_MIN(PMA_CH2_REG_OOB_COMINIT_GAP_MIN),  // 取值范围：0～255。
                .PMA_REG_OOB_COMINIT_GAP_MAX(PMA_CH2_REG_OOB_COMINIT_GAP_MAX),  // 取值范围：0～255。
                .PMA_REG_RX_RESERVED_227_226(PMA_CH2_REG_RX_RESERVED_227_226),  // 取值范围：0～3。
                .PMA_REG_COMWAKE_STATUS_CLEAR(PMA_CH2_REG_COMWAKE_STATUS_CLEAR),  //0,1
                .PMA_REG_COMINIT_STATUS_CLEAR(PMA_CH2_REG_COMINIT_STATUS_CLEAR),  //0,1
                .PMA_REG_RX_SYNC_RST_N_EN(PMA_CH2_REG_RX_SYNC_RST_N_EN),  // 使能选项：开启或关闭。
                .PMA_REG_RX_SYNC_RST_N(PMA_CH2_REG_RX_SYNC_RST_N),  // 使能选项：开启或关闭。
                .PMA_REG_RX_RESERVED_233_232(PMA_CH2_REG_RX_RESERVED_233_232),  // 取值范围：0～3。
                .PMA_REG_RX_RESERVED_235_234(PMA_CH2_REG_RX_RESERVED_235_234),  // 取值范围：0～3。
                .PMA_REG_RX_SATA_COMINIT_OW(PMA_CH2_REG_RX_SATA_COMINIT_OW),  // 使能选项：开启或关闭。
                .PMA_REG_RX_SATA_COMINIT(PMA_CH2_REG_RX_SATA_COMINIT),  // 使能选项：开启或关闭。
                .PMA_REG_RX_SATA_COMWAKE_OW(PMA_CH2_REG_RX_SATA_COMWAKE_OW),  // 使能选项：开启或关闭。
                .PMA_REG_RX_SATA_COMWAKE(PMA_CH2_REG_RX_SATA_COMWAKE),  // 使能选项：开启或关闭。
                .PMA_REG_RX_RESERVED_241_240(PMA_CH2_REG_RX_RESERVED_241_240),  // 取值范围：0～3。
                .PMA_REG_RX_DCC_DISABLE(PMA_CH2_REG_RX_DCC_DISABLE),  // 接收占空比校正禁用控制
                .PMA_REG_RX_RESERVED_243(PMA_CH2_REG_RX_RESERVED_243),  // 使能选项：开启或关闭。
                .PMA_REG_RX_SLIP_SEL_EN(PMA_CH2_REG_RX_SLIP_SEL_EN),  // 使能选项：开启或关闭。
                .PMA_REG_RX_SLIP_SEL(PMA_CH2_REG_RX_SLIP_SEL),  // 取值范围：0～15。
                .PMA_REG_RX_SLIP_EN(PMA_CH2_REG_RX_SLIP_EN),  // 使能选项：开启或关闭。
                .PMA_REG_RX_SIGDET_STATUS_SEL(PMA_CH2_REG_RX_SIGDET_STATUS_SEL),  // 取值范围：0～7。
                .PMA_REG_RX_SIGDET_FSM_RST_N(PMA_CH2_REG_RX_SIGDET_FSM_RST_N),  // 使能选项：开启或关闭。
                .PMA_REG_RX_RESERVED_254(PMA_CH2_REG_RX_RESERVED_254),  // 使能选项：开启或关闭。
                .PMA_REG_RX_SIGDET_STATUS(PMA_CH2_REG_RX_SIGDET_STATUS),  // 使能选项：开启或关闭。
                .PMA_REG_RX_SIGDET_VTH(PMA_CH2_REG_RX_SIGDET_VTH),  // 检测电压：45、54、63、72 mV。
                .PMA_REG_RX_SIGDET_GRM(PMA_CH2_REG_RX_SIGDET_GRM),  //0,1,2,3
                .PMA_REG_RX_SIGDET_PULSE_EXT(PMA_CH2_REG_RX_SIGDET_PULSE_EXT),  // 使能选项：开启或关闭。
                .PMA_REG_RX_SIGDET_CH2_SEL(PMA_CH2_REG_RX_SIGDET_CH2_SEL),  //0,1
                .PMA_REG_RX_SIGDET_CH2_CHK_WINDOW(PMA_CH2_REG_RX_SIGDET_CH2_CHK_WINDOW),  // 取值范围：0～31。
                .PMA_REG_RX_SIGDET_CHK_WINDOW_EN             (PMA_CH2_REG_RX_SIGDET_CHK_WINDOW_EN               ),// 使能选项：开启或关闭。
                .PMA_REG_RX_SIGDET_NOSIG_COUNT_SETTING       (PMA_CH2_REG_RX_SIGDET_NOSIG_COUNT_SETTING         ),// 取值范围：0～7。
                .PMA_REG_SLIP_FIFO_INV_EN(PMA_CH2_REG_SLIP_FIFO_INV_EN),  // 使能选项：开启或关闭。
                .PMA_REG_SLIP_FIFO_INV(PMA_CH2_REG_SLIP_FIFO_INV),  // 时钟边沿：上升沿或下降沿。
                .PMA_REG_RX_SIGDET_OOB_DET_COUNT_VAL         (PMA_CH2_REG_RX_SIGDET_OOB_DET_COUNT_VAL           ),// 取值范围：0～31。
                .PMA_REG_RX_SIGDET_4OOB_DET_SEL(PMA_CH2_REG_RX_SIGDET_4OOB_DET_SEL),  // 取值范围：0～7。
                .PMA_REG_RX_RESERVED_285_283(PMA_CH2_REG_RX_RESERVED_285_283),  // 取值范围：0～7。
                .PMA_REG_RX_RESERVED_286(PMA_CH2_REG_RX_RESERVED_286),  // 使能选项：开启或关闭。
                .PMA_REG_RX_SIGDET_IC_I(PMA_CH2_REG_RX_SIGDET_IC_I),  // 取值范围：0～15。
                .PMA_REG_RX_OOB_DETECTOR_RESET_N_OW          (PMA_CH2_REG_RX_OOB_DETECTOR_RESET_N_OW            ),// 使能选项：开启或关闭。
                .PMA_REG_RX_OOB_DETECTOR_RESET_N             (PMA_CH2_REG_RX_OOB_DETECTOR_RESET_N               ),// 接收带外检测器复位控制
                .PMA_REG_RX_OOB_DETECTOR_PD_OW(PMA_CH2_REG_RX_OOB_DETECTOR_PD_OW),  // 使能选项：开启或关闭。
                .PMA_REG_RX_OOB_DETECTOR_PD(PMA_CH2_REG_RX_OOB_DETECTOR_PD),  // 接收带外检测器掉电控制
                .PMA_REG_RX_LS_MODE_EN(PMA_CH2_REG_RX_LS_MODE_EN),  // 低速模式使能
                .PMA_REG_ANA_RX_EQ1_R_SET_FB_O_SEL           (PMA_CH2_REG_ANA_RX_EQ1_R_SET_FB_O_SEL             ),// 使能选项：开启或关闭。
                .PMA_REG_ANA_RX_EQ2_R_SET_FB_O_SEL           (PMA_CH2_REG_ANA_RX_EQ2_R_SET_FB_O_SEL             ),// 使能选项：开启或关闭。
                .PMA_REG_RX_EQ1_R_SET_TOP(PMA_CH2_REG_RX_EQ1_R_SET_TOP),  // 取值范围：0～3。
                .PMA_REG_RX_EQ1_R_SET_FB(PMA_CH2_REG_RX_EQ1_R_SET_FB),  // 取值范围：0～15。
                .PMA_REG_RX_EQ1_C_SET_FB(PMA_CH2_REG_RX_EQ1_C_SET_FB),  // 取值范围：0～15。
                .PMA_REG_RX_EQ1_OFF(PMA_CH2_REG_RX_EQ1_OFF),  // 使能选项：开启或关闭。
                .PMA_REG_RX_EQ2_R_SET_TOP(PMA_CH2_REG_RX_EQ2_R_SET_TOP),  // 取值范围：0～3。
                .PMA_REG_RX_EQ2_R_SET_FB(PMA_CH2_REG_RX_EQ2_R_SET_FB),  // 取值范围：0～15。
                .PMA_REG_RX_EQ2_C_SET_FB(PMA_CH2_REG_RX_EQ2_C_SET_FB),  // 取值范围：0～15。
                .PMA_REG_RX_EQ2_OFF(PMA_CH2_REG_RX_EQ2_OFF),  // 使能选项：开启或关闭。
                .PMA_REG_EQ_DAC(PMA_CH2_REG_EQ_DAC),  // 取值范围：0～63。
                .PMA_REG_RX_ICTRL_EQ(PMA_CH2_REG_RX_ICTRL_EQ),  // 使能选项：开启或关闭。
                .PMA_REG_EQ_DC_CALIB_EN(PMA_CH2_REG_EQ_DC_CALIB_EN),  // 使能选项：开启或关闭。
                .PMA_REG_EQ_DC_CALIB_SEL(PMA_CH2_REG_EQ_DC_CALIB_SEL),  // 使能选项：开启或关闭。
                .PMA_REG_RX_RESERVED_337_330(PMA_CH2_REG_RX_RESERVED_337_330),  // 取值范围：0～255。
                .PMA_REG_RX_RESERVED_345_338(PMA_CH2_REG_RX_RESERVED_345_338),  // 取值范围：0～255。
                .PMA_REG_RX_RESERVED_353_346(PMA_CH2_REG_RX_RESERVED_353_346),  // 取值范围：0～255。
                .PMA_REG_RX_RESERVED_361_354(PMA_CH2_REG_RX_RESERVED_361_354),  // 取值范围：0～255。
                .PMA_CTLE_CTRL_REG_I(PMA_CH2_CTLE_CTRL_REG_I),  // 取值范围：0～15。
                .PMA_CTLE_REG_FORCE_SEL_I(PMA_CH2_CTLE_REG_FORCE_SEL_I),  // 自适应调整控制
                .PMA_CTLE_REG_HOLD_I(PMA_CH2_CTLE_REG_HOLD_I),  // 使能选项：开启或关闭。
                .PMA_CTLE_REG_INIT_DAC_I(PMA_CH2_CTLE_REG_INIT_DAC_I),  // 取值范围：0～15。
                .PMA_CTLE_REG_POLARITY_I(PMA_CH2_CTLE_REG_POLARITY_I),  // 使能选项：开启或关闭。
                .PMA_CTLE_REG_SHIFTER_GAIN_I(PMA_CH2_CTLE_REG_SHIFTER_GAIN_I),  // 取值范围：0～7。
                .PMA_CTLE_REG_THRESHOLD_I(PMA_CH2_CTLE_REG_THRESHOLD_I),  // 取值范围：0～4095。
                .PMA_REG_RX_RES_TRIM_EN(PMA_CH2_REG_RX_RES_TRIM_EN),  // 使能选项：开启或关闭。
                .PMA_REG_RX_RESERVED_393_389(PMA_CH2_REG_RX_RESERVED_393_389),  // 取值范围：0～31。
                .PMA_CFG_RX_LANE_POWERUP(PMA_CH2_CFG_RX_LANE_POWERUP),  // 接收通道上电控制
                .PMA_CFG_RX_PMA_RSTN(PMA_CH2_CFG_RX_PMA_RSTN),  // 接收 PMA 复位控制
                .PMA_INT_PMA_RX_MASK_0(PMA_CH2_INT_PMA_RX_MASK_0),  // 使能选项：开启或关闭。
                .PMA_INT_PMA_RX_CLR_0(PMA_CH2_INT_PMA_RX_CLR_0),  // 使能选项：开启或关闭。
                .PMA_CFG_CTLE_ADP_RSTN(PMA_CH2_CFG_CTLE_ADP_RSTN),  // 控制逻辑复位

                .PMA_REG_TX_PD(PMA_CH2_REG_TX_PD),  // 发送端掉电控制
                .PMA_REG_TX_PD_OW(PMA_CH2_REG_TX_PD_OW),  // 使能选项：开启或关闭。
                .PMA_REG_TX_MAIN_PRE_Z(PMA_CH2_REG_TX_MAIN_PRE_Z),  // PCIe 模式电气空闲使能
                .PMA_REG_TX_MAIN_PRE_Z_OW(PMA_CH2_REG_TX_MAIN_PRE_Z_OW),  // 使能选项：开启或关闭。
                .PMA_REG_TX_BEACON_TIMER_SEL(PMA_CH2_REG_TX_BEACON_TIMER_SEL),  // 取值范围：0～3。
                .PMA_REG_TX_RXDET_REQ_OW(PMA_CH2_REG_TX_RXDET_REQ_OW),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RXDET_REQ(PMA_CH2_REG_TX_RXDET_REQ),  // 使能选项：开启或关闭。
                .PMA_REG_TX_BEACON_EN_OW(PMA_CH2_REG_TX_BEACON_EN_OW),  // 使能选项：开启或关闭。
                .PMA_REG_TX_BEACON_EN(PMA_CH2_REG_TX_BEACON_EN),  // 使能选项：开启或关闭。
                .PMA_REG_TX_EI_EN_OW(PMA_CH2_REG_TX_EI_EN_OW),  // 使能选项：开启或关闭。
                .PMA_REG_TX_EI_EN(PMA_CH2_REG_TX_EI_EN),  // 使能选项：开启或关闭。
                .PMA_REG_TX_BIT_CONV(PMA_CH2_REG_TX_BIT_CONV),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RES_CAL(PMA_CH2_REG_TX_RES_CAL),  // 取值范围：0～63。
                .PMA_REG_TX_RESERVED_19(PMA_CH2_REG_TX_RESERVED_19),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RESERVED_25_20(PMA_CH2_REG_TX_RESERVED_25_20),  // 取值范围：0～63。
                .PMA_REG_TX_RESERVED_33_26(PMA_CH2_REG_TX_RESERVED_33_26),  // 取值范围：0～255。
                .PMA_REG_TX_RESERVED_41_34(PMA_CH2_REG_TX_RESERVED_41_34),  // 取值范围：0～255。
                .PMA_REG_TX_RESERVED_49_42(PMA_CH2_REG_TX_RESERVED_49_42),  // 取值范围：0～255。
                .PMA_REG_TX_RESERVED_57_50(PMA_CH2_REG_TX_RESERVED_57_50),  // 取值范围：0～255。
                .PMA_REG_TX_SYNC_OW(PMA_CH2_REG_TX_SYNC_OW),  // 使能选项：开启或关闭。
                .PMA_REG_TX_SYNC(PMA_CH2_REG_TX_SYNC),  // 使能选项：开启或关闭。
                .PMA_REG_TX_PD_POST(PMA_CH2_REG_TX_PD_POST),  // 使能选项：开启或关闭。
                .PMA_REG_TX_PD_POST_OW(PMA_CH2_REG_TX_PD_POST_OW),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RESET_N_OW(PMA_CH2_REG_TX_RESET_N_OW),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RESET_N(PMA_CH2_REG_TX_RESET_N),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RESERVED_64(PMA_CH2_REG_TX_RESERVED_64),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RESERVED_65(PMA_CH2_REG_TX_RESERVED_65),  // 使能选项：开启或关闭。
                .PMA_REG_TX_BUSWIDTH_OW(PMA_CH2_REG_TX_BUSWIDTH_OW),  // 使能选项：开启或关闭。
                .PMA_REG_TX_BUSWIDTH(PMA_CH2_REG_TX_BUSWIDTH),  // 位宽选项：8、10、16 或 20 位。
                .PMA_REG_PLL_READY_OW(PMA_CH2_REG_PLL_READY_OW),  // 使能选项：开启或关闭。
                .PMA_REG_PLL_READY(PMA_CH2_REG_PLL_READY),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RESERVED_72(PMA_CH2_REG_TX_RESERVED_72),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RESERVED_73(PMA_CH2_REG_TX_RESERVED_73),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RESERVED_74(PMA_CH2_REG_TX_RESERVED_74),  // 使能选项：开启或关闭。
                .PMA_REG_EI_PCLK_DELAY_SEL(PMA_CH2_REG_EI_PCLK_DELAY_SEL),  // 取值范围：0～3。
                .PMA_REG_TX_RESERVED_77(PMA_CH2_REG_TX_RESERVED_77),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RESERVED_83_78(PMA_CH2_REG_TX_RESERVED_83_78),  // 取值范围：0～63。
                .PMA_REG_TX_RESERVED_89_84(PMA_CH2_REG_TX_RESERVED_89_84),  // 取值范围：0～63。
                .PMA_REG_TX_RESERVED_95_90(PMA_CH2_REG_TX_RESERVED_95_90),  // 取值范围：0～63。
                .PMA_REG_TX_RESERVED_101_96(PMA_CH2_REG_TX_RESERVED_101_96),  // 取值范围：0～63。
                .PMA_REG_TX_RESERVED_107_102(PMA_CH2_REG_TX_RESERVED_107_102),  // 取值范围：0～63。
                .PMA_REG_TX_RESERVED_113_108(PMA_CH2_REG_TX_RESERVED_113_108),  // 取值范围：0～63。
                .PMA_REG_TX_AMP_DAC0(PMA_CH2_REG_TX_AMP_DAC0),  // 取值范围：0～63。
                .PMA_REG_TX_AMP_DAC1(PMA_CH2_REG_TX_AMP_DAC1),  // 取值范围：0～63。
                .PMA_REG_TX_AMP_DAC2(PMA_CH2_REG_TX_AMP_DAC2),  // 取值范围：0～63。
                .PMA_REG_TX_AMP_DAC3(PMA_CH2_REG_TX_AMP_DAC3),  // 取值范围：0～63。
                .PMA_REG_TX_RESERVED_143_138(PMA_CH2_REG_TX_RESERVED_143_138),  // 取值范围：0～63。
                .PMA_REG_TX_MARGIN(PMA_CH2_REG_TX_MARGIN),  // 取值范围：0～7。
                .PMA_REG_TX_MARGIN_OW(PMA_CH2_REG_TX_MARGIN_OW),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RESERVED_149_148(PMA_CH2_REG_TX_RESERVED_149_148),  // 取值范围：0～3。
                .PMA_REG_TX_RESERVED_150(PMA_CH2_REG_TX_RESERVED_150),  // 使能选项：开启或关闭。
                .PMA_REG_TX_SWING(PMA_CH2_REG_TX_SWING),  // 使能选项：开启或关闭。
                .PMA_REG_TX_SWING_OW(PMA_CH2_REG_TX_SWING_OW),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RESERVED_153(PMA_CH2_REG_TX_RESERVED_153),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RXDET_THRESHOLD(PMA_CH2_REG_TX_RXDET_THRESHOLD),  // 电压选项：28、56、84、112 mV。
                .PMA_REG_TX_RESERVED_157_156(PMA_CH2_REG_TX_RESERVED_157_156),  // 取值范围：0～3。
                .PMA_REG_TX_BEACON_OSC_CTRL(PMA_CH2_REG_TX_BEACON_OSC_CTRL),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RESERVED_160_159(PMA_CH2_REG_TX_RESERVED_160_159),  // 取值范围：0～3。
                .PMA_REG_TX_RESERVED_162_161(PMA_CH2_REG_TX_RESERVED_162_161),  // 取值范围：0～3。
                .PMA_REG_TX_TX2RX_SLPBACK_EN(PMA_CH2_REG_TX_TX2RX_SLPBACK_EN),  // 使能选项：开启或关闭。
                .PMA_REG_TX_PCLK_EDGE_SEL(PMA_CH2_REG_TX_PCLK_EDGE_SEL),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RXDET_STATUS_OW(PMA_CH2_REG_TX_RXDET_STATUS_OW),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RXDET_STATUS(PMA_CH2_REG_TX_RXDET_STATUS),  // 使能选项：开启或关闭。
                .PMA_REG_TX_PRBS_GEN_EN(PMA_CH2_REG_TX_PRBS_GEN_EN),  // 使能选项：开启或关闭。
                .PMA_REG_TX_PRBS_GEN_WIDTH_SEL               (PMA_CH2_REG_TX_PRBS_GEN_WIDTH_SEL                 ),// 位宽选项：8、10、16 或 20 位。
                .PMA_REG_TX_PRBS_SEL(PMA_CH2_REG_TX_PRBS_SEL),  // PRBS 多项式阶数：7、15、23、31。
                .PMA_REG_TX_UDP_DATA_7_TO_0(PMA_CH2_REG_TX_UDP_DATA_7_TO_0),  // 取值范围：0～255。
                .PMA_REG_TX_UDP_DATA_15_TO_8(PMA_CH2_REG_TX_UDP_DATA_15_TO_8),  // 取值范围：0～255。
                .PMA_REG_TX_UDP_DATA_19_TO_16(PMA_CH2_REG_TX_UDP_DATA_19_TO_16),  // 取值范围：0～15。
                .PMA_REG_TX_RESERVED_192(PMA_CH2_REG_TX_RESERVED_192),  // 使能选项：开启或关闭。
                .PMA_REG_TX_FIFO_WP_CTRL(PMA_CH2_REG_TX_FIFO_WP_CTRL),  // 取值范围：0～7。
                .PMA_REG_TX_FIFO_EN(PMA_CH2_REG_TX_FIFO_EN),  // 使能选项：开启或关闭。
                .PMA_REG_TX_DATA_MUX_SEL(PMA_CH2_REG_TX_DATA_MUX_SEL),  // 取值范围：0～3。
                .PMA_REG_TX_ERR_INSERT(PMA_CH2_REG_TX_ERR_INSERT),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RESERVED_203_200(PMA_CH2_REG_TX_RESERVED_203_200),  // 取值范围：0～15。
                .PMA_REG_TX_RESERVED_204(PMA_CH2_REG_TX_RESERVED_204),  // 使能选项：开启或关闭。
                .PMA_REG_TX_SATA_EN(PMA_CH2_REG_TX_SATA_EN),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RESERVED_207_206(PMA_CH2_REG_TX_RESERVED_207_206),  // 取值范围：0～3。
                .PMA_REG_RATE_CHANGE_TXPCLK_ON_OW            (PMA_CH2_REG_RATE_CHANGE_TXPCLK_ON_OW              ),// 使能选项：开启或关闭。
                .PMA_REG_RATE_CHANGE_TXPCLK_ON(PMA_CH2_REG_RATE_CHANGE_TXPCLK_ON),  // 使能选项：开启或关闭。
                .PMA_REG_TX_CFG_POST1(PMA_CH2_REG_TX_CFG_POST1),  // 取值范围：0～31。
                .PMA_REG_TX_CFG_POST2(PMA_CH2_REG_TX_CFG_POST2),  // 取值范围：0～31。
                .PMA_REG_TX_DEEMP(PMA_CH2_REG_TX_DEEMP),  // 取值范围：0～3。
                .PMA_REG_TX_DEEMP_OW(PMA_CH2_REG_TX_DEEMP_OW),  // 发送去加重控制
                .PMA_REG_TX_RESERVED_224_223(PMA_CH2_REG_TX_RESERVED_224_223),  // 取值范围：0～3。
                .PMA_REG_TX_RESERVED_225(PMA_CH2_REG_TX_RESERVED_225),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RESERVED_229_226(PMA_CH2_REG_TX_RESERVED_229_226),  // 取值范围：0～15。
                .PMA_REG_TX_OOB_DELAY_SEL(PMA_CH2_REG_TX_OOB_DELAY_SEL),  // 取值范围：0～15。
                .PMA_REG_TX_POLARITY(PMA_CH2_REG_TX_POLARITY),  // 极性选项：正常或反转。
                .PMA_REG_ANA_TX_JTAG_DATA_O_SEL              (PMA_CH2_REG_ANA_TX_JTAG_DATA_O_SEL                ),// 使能选项：开启或关闭。
                .PMA_REG_TX_RESERVED_236(PMA_CH2_REG_TX_RESERVED_236),  // 使能选项：开启或关闭。
                .PMA_REG_TX_LS_MODE_EN(PMA_CH2_REG_TX_LS_MODE_EN),  // 使能选项：开启或关闭。
                .PMA_REG_TX_JTAG_MODE_EN_OW(PMA_CH2_REG_TX_JTAG_MODE_EN_OW),  // 使能选项：开启或关闭。
                .PMA_REG_TX_JTAG_MODE_EN(PMA_CH2_REG_TX_JTAG_MODE_EN),  // 使能选项：开启或关闭。
                .PMA_REG_RX_JTAG_MODE_EN_OW(PMA_CH2_REG_RX_JTAG_MODE_EN_OW),  // 使能选项：开启或关闭。
                .PMA_REG_RX_JTAG_MODE_EN(PMA_CH2_REG_RX_JTAG_MODE_EN),  // 使能选项：开启或关闭。
                .PMA_REG_RX_JTAG_OE(PMA_CH2_REG_RX_JTAG_OE),  // 使能选项：开启或关闭。
                .PMA_REG_RX_ACJTAG_VHYSTSEL(PMA_CH2_REG_RX_ACJTAG_VHYSTSEL),  // 取值范围：0～7。
                .PMA_REG_TX_RES_CAL_EN(PMA_CH2_REG_TX_RES_CAL_EN),  // 使能选项：开启或关闭。
                .PMA_REG_RX_TERM_MODE_CTRL(PMA_CH2_REG_RX_TERM_MODE_CTRL),  // 接收终端控制范围：0～7。
                .PMA_REG_TX_RESERVED_251_250(PMA_CH2_REG_TX_RESERVED_251_250),  // 取值范围：0～7。
                .PMA_REG_PLPBK_TXPCLK_EN(PMA_CH2_REG_PLPBK_TXPCLK_EN),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RESERVED_253(PMA_CH2_REG_TX_RESERVED_253),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RESERVED_254(PMA_CH2_REG_TX_RESERVED_254),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RESERVED_255(PMA_CH2_REG_TX_RESERVED_255),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RESERVED_256(PMA_CH2_REG_TX_RESERVED_256),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RESERVED_257(PMA_CH2_REG_TX_RESERVED_257),  // 使能选项：开启或关闭。
                .PMA_REG_TX_PH_SEL(PMA_CH2_REG_TX_PH_SEL),  // 取值范围：0～63。
                .PMA_REG_TX_CFG_PRE(PMA_CH2_REG_TX_CFG_PRE),  // 取值范围：0～31。
                .PMA_REG_TX_CFG_MAIN(PMA_CH2_REG_TX_CFG_MAIN),  // 取值范围：0～63。
                .PMA_REG_CFG_POST(PMA_CH2_REG_CFG_POST),  // 取值范围：0～31。
                .PMA_REG_PD_MAIN(PMA_CH2_REG_PD_MAIN),  // 使能选项：开启或关闭。
                .PMA_REG_PD_PRE(PMA_CH2_REG_PD_PRE),  // 使能选项：开启或关闭。
                .PMA_REG_TX_LS_DATA(PMA_CH2_REG_TX_LS_DATA),  // 使能选项：开启或关闭。
                .PMA_REG_TX_DCC_BUF_SZ_SEL(PMA_CH2_REG_TX_DCC_BUF_SZ_SEL),  // 取值范围：0～3。
                .PMA_REG_TX_DCC_CAL_CUR_TUNE(PMA_CH2_REG_TX_DCC_CAL_CUR_TUNE),  // 取值范围：0～63。
                .PMA_REG_TX_DCC_CAL_EN(PMA_CH2_REG_TX_DCC_CAL_EN),  // 使能选项：开启或关闭。
                .PMA_REG_TX_DCC_CUR_SS(PMA_CH2_REG_TX_DCC_CUR_SS),  // 取值范围：0～3。
                .PMA_REG_TX_DCC_FA_CTRL(PMA_CH2_REG_TX_DCC_FA_CTRL),  // 使能选项：开启或关闭。
                .PMA_REG_TX_DCC_RI_CTRL(PMA_CH2_REG_TX_DCC_RI_CTRL),  // 使能选项：开启或关闭。
                .PMA_REG_ATB_SEL_2_TO_0(PMA_CH2_REG_ATB_SEL_2_TO_0),  // 取值范围：0～7。
                .PMA_REG_ATB_SEL_9_TO_3(PMA_CH2_REG_ATB_SEL_9_TO_3),  // 取值范围：0～127。
                .PMA_REG_TX_CFG_7_TO_0(PMA_CH2_REG_TX_CFG_7_TO_0),  // 取值范围：0～255。
                .PMA_REG_TX_CFG_15_TO_8(PMA_CH2_REG_TX_CFG_15_TO_8),  // 取值范围：0～255。
                .PMA_REG_TX_CFG_23_TO_16(PMA_CH2_REG_TX_CFG_23_TO_16),  // 取值范围：0～255。
                .PMA_REG_TX_CFG_31_TO_24(PMA_CH2_REG_TX_CFG_31_TO_24),  // 取值范围：0～255。
                .PMA_REG_TX_OOB_EI_EN(PMA_CH2_REG_TX_OOB_EI_EN),  // SATA 模式带外电气空闲使能
                .PMA_REG_TX_OOB_EI_EN_OW(PMA_CH2_REG_TX_OOB_EI_EN_OW),  // 使能选项：开启或关闭。
                .PMA_REG_TX_BEACON_EN_DELAYED(PMA_CH2_REG_TX_BEACON_EN_DELAYED),  // 使能选项：开启或关闭。
                .PMA_REG_TX_BEACON_EN_DELAYED_OW             (PMA_CH2_REG_TX_BEACON_EN_DELAYED_OW               ),// 使能选项：开启或关闭。
                .PMA_REG_TX_JTAG_DATA(PMA_CH2_REG_TX_JTAG_DATA),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RXDET_TIMER_SEL(PMA_CH2_REG_TX_RXDET_TIMER_SEL),  // 取值范围：0～255。
                .PMA_REG_TX_CFG1_7_0(PMA_CH2_REG_TX_CFG1_7_0),  // 取值范围：0～255。
                .PMA_REG_TX_CFG1_15_8(PMA_CH2_REG_TX_CFG1_15_8),  // 取值范围：0～255。
                .PMA_REG_TX_CFG1_23_16(PMA_CH2_REG_TX_CFG1_23_16),  // 取值范围：0～255。
                .PMA_REG_TX_CFG1_31_24(PMA_CH2_REG_TX_CFG1_31_24),  // 取值范围：0～255。
                .PMA_REG_CFG_LANE_POWERUP(PMA_CH2_REG_CFG_LANE_POWERUP),  // PMA 通道上电控制
                .PMA_REG_CFG_TX_LANE_POWERUP_CLKPATH         (PMA_CH2_REG_CFG_TX_LANE_POWERUP_CLKPATH           ),// PMA 发送通道时钟路径上电控制
                .PMA_REG_CFG_TX_LANE_POWERUP_PISO            (PMA_CH2_REG_CFG_TX_LANE_POWERUP_PISO              ),// PMA 发送并串转换单元上电控制
                .PMA_REG_CFG_TX_LANE_POWERUP_DRIVER          (PMA_CH2_REG_CFG_TX_LANE_POWERUP_DRIVER            ) // PMA 发送驱动器上电控制
            ) U_GTP_HSSTLP_LANE2 (

                .P_TX_SDN           (P_TX_SDN_2),
                .P_TX_SDP           (P_TX_SDP_2),
                // SRB 相关信号
                .P_PCS_RX_MCB_STATUS(P_PCS_RX_MCB_STATUS_2),
                .P_PCS_LSM_SYNCED   (P_PCS_LSM_SYNCED_2),
                .P_CFG_READY        (P_CFG_READY_2),
                .P_CFG_RDATA        (P_CFG_RDATA_2),
                .P_CFG_INT          (P_CFG_INT_2),
                .P_RDATA            (P_RDATA_2),
                .P_RCLK2FABRIC      (P_RCLK2FABRIC_2),
                .P_TCLK2FABRIC      (P_TCLK2FABRIC_2),
                .P_RX_SIGDET_STATUS (P_RX_SIGDET_STATUS_2),
                .P_RX_SATA_COMINIT  (P_RX_SATA_COMINIT_2),
                .P_RX_SATA_COMWAKE  (P_RX_SATA_COMWAKE_2),
                .P_RX_LS_DATA       (P_RX_LS_DATA_2),
                .P_RX_READY         (P_RX_READY_2),
                .P_TEST_STATUS      (P_TEST_STATUS_2),
                .P_TX_RXDET_STATUS  (P_TX_RXDET_STATUS_2),
                .P_CA_ALIGN_RX      (P_CA_ALIGN_RX_2),
                .P_CA_ALIGN_TX      (P_CA_ALIGN_TX_2),

                .PMA_RCLK             (PMA_RCLK_2),
                .TXPCLK_PLL           (TXPCLK_PLL_2),
                // CIN 与 COUT 级联接口
                .LANE_COUT_BUS_FORWARD(LANE_COUT_BUS_FORWARD_2),
                .APATTERN_STATUS_COUT (APATTERN_STATUS_COUT_2),

                .P_RX_SDN            (P_RX_SDN_2),
                .P_RX_SDP            (P_RX_SDP_2),
                // SRB 相关信号
                .P_RX_CLK_FR_CORE    (P_RX_CLK_FR_CORE_2),
                .P_RCLK2_FR_CORE     (P_RCLK2_FR_CORE_2),
                .P_TX_CLK_FR_CORE    (P_TX_CLK_FR_CORE_2),
                .P_TCLK2_FR_CORE     (P_TCLK2_FR_CORE_2),
                .P_PCS_TX_RST        (P_PCS_TX_RST_2),
                .P_PCS_RX_RST        (P_PCS_RX_RST_2),
                .P_PCS_CB_RST        (P_PCS_CB_RST_2),
                .P_RXGEAR_SLIP       (P_RXGEAR_SLIP_2),
                .P_CFG_CLK           (P_CFG_CLK_2),
                .P_CFG_RST           (P_CFG_RST_2),
                .P_CFG_PSEL          (P_CFG_PSEL_2),
                .P_CFG_ENABLE        (P_CFG_ENABLE_2),
                .P_CFG_WRITE         (P_CFG_WRITE_2),
                .P_CFG_ADDR          (P_CFG_ADDR_2),
                .P_CFG_WDATA         (P_CFG_WDATA_2),
                .P_TDATA             (P_TDATA_2),
                .P_PCS_WORD_ALIGN_EN (P_PCS_WORD_ALIGN_EN_2),
                .P_RX_POLARITY_INVERT(P_RX_POLARITY_INVERT_2),
                .P_CEB_ADETECT_EN    (P_CEB_ADETECT_EN_2),
                .P_PCS_MCB_EXT_EN    (P_PCS_MCB_EXT_EN_2),
                .P_PCS_NEAREND_LOOP  (P_PCS_NEAREND_LOOP_2),
                .P_PCS_FAREND_LOOP   (P_PCS_FAREND_LOOP_2),
                .P_PMA_NEAREND_PLOOP (P_PMA_NEAREND_PLOOP_2),
                .P_PMA_NEAREND_SLOOP (P_PMA_NEAREND_SLOOP_2),
                .P_PMA_FAREND_PLOOP  (P_PMA_FAREND_PLOOP_2),

                .P_LANE_PD           (P_LANE_PD_2),
                .P_LANE_RST          (P_LANE_RST_2),
                .P_RX_LANE_PD        (P_RX_LANE_PD_2),
                .P_RX_PMA_RST        (P_RX_PMA_RST_2),
                .P_CTLE_ADP_RST      (P_CTLE_ADP_RST_2),
                .P_TX_DEEMP          (P_TX_DEEMP_2),
                .P_TX_LS_DATA        (P_TX_LS_DATA_2),
                .P_TX_BEACON_EN      (P_TX_BEACON_EN_2),
                .P_TX_SWING          (P_TX_SWING_2),
                .P_TX_RXDET_REQ      (P_TX_RXDET_REQ_2),
                .P_TX_RATE           (P_TX_RATE_2),
                .P_TX_BUSWIDTH       (P_TX_BUSWIDTH_2),
                .P_TX_MARGIN         (P_TX_MARGIN_2),
                .P_TX_PMA_RST        (P_TX_PMA_RST_2),
                .P_TX_LANE_PD_CLKPATH(P_TX_LANE_PD_CLKPATH_2),
                .P_TX_LANE_PD_PISO   (P_TX_LANE_PD_PISO_2),
                .P_TX_LANE_PD_DRIVER (P_TX_LANE_PD_DRIVER_2),
                .P_RX_RATE           (P_RX_RATE_2),
                .P_RX_BUSWIDTH       (P_RX_BUSWIDTH_2),
                .P_RX_HIGHZ          (P_RX_HIGHZ_2),
                .P_CIM_CLK_ALIGNER_RX(P_CIM_CLK_ALIGNER_RX_2),
                .P_CIM_CLK_ALIGNER_TX(P_CIM_CLK_ALIGNER_TX_2),
                .P_CIM_DYN_DLY_SEL_RX(P_CIM_DYN_DLY_SEL_RX_2),
                .P_CIM_DYN_DLY_SEL_TX(P_CIM_DYN_DLY_SEL_TX_2),
                .P_CIM_START_ALIGN_RX(P_CIM_START_ALIGN_RX_2),
                .P_CIM_START_ALIGN_TX(P_CIM_START_ALIGN_TX_2),
                // 扩展端口
                .MCB_RCLK            (MCB_RCLK_2),
                .SYNC                (SYNC_2),
                .RATE_CHANGE         (RATE_CHANGE_2),
                .PLL_LOCK_SEL        (PLL_LOCK_SEL_2),
                // CIN 与 COUT 级联接口
                .LANE_CIN_BUS_FORWARD(LANE_CIN_BUS_FORWARD_2),
                .APATTERN_STATUS_CIN (APATTERN_STATUS_CIN_2),
                // 来自 PLL
                .CLK_TXP             (CLK_TXP_2),
                .CLK_TXN             (CLK_TXN_2),
                .CLK_RX0             (CLK_RX0_2),
                .CLK_RX90            (CLK_RX90_2),
                .CLK_RX180           (CLK_RX180_2),
                .CLK_RX270           (CLK_RX270_2),
                .PLL_PD_I            (PLL_PD_I_2),
                .PLL_RESET_I         (PLL_RESET_I_2),
                .PLL_REFCLK_I        (PLL_REFCLK_I_2),
                .PLL_RES_TRIM_I      (PLL_RES_TRIM_I_2)
            );
        end else begin : CHANNEL2_NULL
            assign P_TX_SDN_2              = 1'b0;
            assign P_TX_SDP_2              = 1'b0;
            assign P_PCS_RX_MCB_STATUS_2   = 1'b0;
            assign P_PCS_LSM_SYNCED_2      = 1'b0;
            assign P_CFG_READY_2           = 1'b0;
            assign P_CFG_RDATA_2           = 8'b0;
            assign P_CFG_INT_2             = 1'b0;
            assign P_RDATA_2               = 47'b0;
            assign P_RCLK2FABRIC_2         = 1'b0;
            assign P_TCLK2FABRIC_2         = 1'b0;
            assign P_RX_SIGDET_STATUS_2    = 1'b0;
            assign P_RX_SATA_COMINIT_2     = 1'b0;
            assign P_RX_SATA_COMWAKE_2     = 1'b0;
            assign P_RX_LS_DATA_2          = 1'b0;
            assign P_RX_READY_2            = 1'b0;
            assign P_TEST_STATUS_2         = 20'b0;
            assign P_TX_RXDET_STATUS_2     = 1'b0;
            assign P_CA_ALIGN_RX_2         = 1'b0;
            assign P_CA_ALIGN_TX_2         = 1'b0;
            assign PMA_RCLK_2              = 1'b0;
            assign TXPCLK_PLL_2            = 1'b0;
            assign LANE_COUT_BUS_FORWARD_2 = 19'b0;
            assign APATTERN_STATUS_COUT_2  = 1'b0;
        end
    endgenerate

    // 通道 3 例化
    generate
        if (CHANNEL3_EN == "TRUE") begin : CHANNEL3_ENABLE
            GTP_HSSTLP_LANE #(
                .MUX_BIAS      (CH3_MUX_BIAS),       // 取值范围：0～7，不支持仿真。
                .PD_CLK        (CH3_PD_CLK),         // 取值范围：0～1。
                .REG_SYNC      (CH3_REG_SYNC),       // 取值范围：0～1。
                .REG_SYNC_OW   (CH3_REG_SYNC_OW),    // 取值范围：0～1。
                .PLL_LOCK_OW   (CH3_PLL_LOCK_OW),    // 取值范围：0～1。
                .PLL_LOCK_OW_EN(CH3_PLL_LOCK_OW_EN), // 取值范围：0～1。

                .PCS_SLAVE(PCS_CH3_SLAVE),
                .PCS_BYPASS_WORD_ALIGN(PCS_CH3_BYPASS_WORD_ALIGN),  // 字对齐旁路使能
                .PCS_BYPASS_DENC(PCS_CH3_BYPASS_DENC),  // 8b/10b 解码旁路使能
                .PCS_BYPASS_BONDING(PCS_CH3_BYPASS_BONDING),  // 通道绑定旁路使能
                .PCS_BYPASS_CTC(PCS_CH3_BYPASS_CTC),  // 时钟补偿旁路使能
                .PCS_BYPASS_GEAR(PCS_CH3_BYPASS_GEAR),  // 接收齿轮箱旁路使能
                .PCS_BYPASS_BRIDGE(PCS_CH3_BYPASS_BRIDGE),  // 接收桥接单元旁路使能
                .PCS_BYPASS_BRIDGE_FIFO(PCS_CH3_BYPASS_BRIDGE_FIFO),  // 接收桥接 FIFO 旁路使能
                .PCS_DATA_MODE(PCS_CH3_DATA_MODE),  // 参数选项："X8","X10","X16","X20"
                .PCS_RX_POLARITY_INV                         (PCS_CH3_RX_POLARITY_INV                           ),// 数据变换：延迟、位极性反转、位序反转或两者同时反转。
                .PCS_ALIGN_MODE(PCS_CH3_ALIGN_MODE),  // 协议模式：1GB、10GB、RAPIDIO 或外部模式。
                .PCS_SAMP_16B(PCS_CH3_SAMP_16B),  // 参数选项："X20",X16
                .PCS_FARLP_PWR_REDUCTION(PCS_CH3_FARLP_PWR_REDUCTION),  // 使能选项：开启或关闭。
                .PCS_COMMA_REG0(PCS_CH3_COMMA_REG0),  // 取值范围：0～1023。
                .PCS_COMMA_MASK(PCS_CH3_COMMA_MASK),  // 取值范围：0～1023。
                .PCS_CEB_MODE(PCS_CH3_CEB_MODE),  // 协议模式：10GB、RAPIDIO 或外部模式。
                .PCS_CTC_MODE                                (PCS_CH3_CTC_MODE                                  ),// 跳过字符模式：单字符、双字符、PCIe 双字节或四字符。
                .PCS_A_REG(PCS_CH3_A_REG),  // 取值范围：0～255。
                .PCS_GE_AUTO_EN(PCS_CH3_GE_AUTO_EN),  // 使能选项：开启或关闭。
                .PCS_SKIP_REG0(PCS_CH3_SKIP_REG0),  // 取值范围：0～1023。
                .PCS_SKIP_REG1(PCS_CH3_SKIP_REG1),  // 取值范围：0～1023。
                .PCS_SKIP_REG2(PCS_CH3_SKIP_REG2),  // 取值范围：0～1023。
                .PCS_SKIP_REG3(PCS_CH3_SKIP_REG3),  // 取值范围：0～1023。
                .PCS_DEC_DUAL(PCS_CH3_DEC_DUAL),  // 使能选项：开启或关闭。
                .PCS_SPLIT(PCS_CH3_SPLIT),  // 使能选项：开启或关闭。
                .PCS_FIFOFLAG_CTC(PCS_CH3_FIFOFLAG_CTC),  // 使能选项：开启或关闭。
                .PCS_COMMA_DET_MODE(PCS_CH3_COMMA_DET_MODE),  // 参数选项："RX_CLK_SLIP" "COMMA_PATTERN"
                .PCS_ERRDETECT_SILENCE(PCS_CH3_ERRDETECT_SILENCE),  // 使能选项：开启或关闭。
                .PCS_PMA_RCLK_POLINV(PCS_CH3_PMA_RCLK_POLINV),  // 参数选项："PMA_RCLK" "REVERSE_OF_PMA_RCLK"
                .PCS_PCS_RCLK_SEL(PCS_CH3_PCS_RCLK_SEL),  // 参数选项："PMA_RCLK" "PMA_TCLK" "RCLK"
                .PCS_CB_RCLK_SEL(PCS_CH3_CB_RCLK_SEL),  // 参数选项："PMA_RCLK" "PMA_TCLK" "MCB_RCLK"
                .PCS_AFTER_CTC_RCLK_SEL                      (PCS_CH3_AFTER_CTC_RCLK_SEL                        ),// 参数选项："PMA_RCLK" "PMA_TCLK" "MCB_RCLK" "RCLK2"
                .PCS_RCLK_POLINV(PCS_CH3_RCLK_POLINV),  // 参数选项："RCLK" "REVERSE_OF_RCLK"
                .PCS_BRIDGE_RCLK_SEL                         (PCS_CH3_BRIDGE_RCLK_SEL                           ),// 参数选项："PMA_RCLK" "PMA_TCLK" "MCB_RCLK" "RCLK"
                .PCS_PCS_RCLK_EN(PCS_CH3_PCS_RCLK_EN),  // 使能选项：开启或关闭。
                .PCS_CB_RCLK_EN(PCS_CH3_CB_RCLK_EN),  // 使能选项：开启或关闭。
                .PCS_AFTER_CTC_RCLK_EN(PCS_CH3_AFTER_CTC_RCLK_EN),  // 使能选项：开启或关闭。
                .PCS_AFTER_CTC_RCLK_EN_GB(PCS_CH3_AFTER_CTC_RCLK_EN_GB),  // 使能选项：开启或关闭。
                .PCS_PCS_RX_RSTN(PCS_CH3_PCS_RX_RSTN),  // PCS 接收端复位控制
                .PCS_PCIE_SLAVE(PCS_CH3_PCIE_SLAVE),  // 通道角色：主通道或从通道。
                .PCS_RX_64B66B_67B(PCS_CH3_RX_64B66B_67B),  // 编码模式：普通、64b/66b 或 64b/67b。
                .PCS_RX_BRIDGE_CLK_POLINV                    (PCS_CH3_RX_BRIDGE_CLK_POLINV                      ),// 参数选项："RX_BRIDGE_CLK" "REVERSE_OF_RX_BRIDGE_CLK"
                .PCS_PCS_CB_RSTN(PCS_CH3_PCS_CB_RSTN),  // PCS 通道绑定复位控制
                .PCS_TX_BRIDGE_GEAR_SEL                      (PCS_CH3_TX_BRIDGE_GEAR_SEL                        ),// TRUE 优先使用发送齿轮箱，FALSE 优先使用发送桥接单元。
                .PCS_TX_BYPASS_BRIDGE_UINT(PCS_CH3_TX_BYPASS_BRIDGE_UINT),  // 旁路使能
                .PCS_TX_BYPASS_BRIDGE_FIFO(PCS_CH3_TX_BYPASS_BRIDGE_FIFO),  // 发送桥接 FIFO 旁路使能
                .PCS_TX_BYPASS_GEAR(PCS_CH3_TX_BYPASS_GEAR),  // 使能选项：开启或关闭。
                .PCS_TX_BYPASS_ENC(PCS_CH3_TX_BYPASS_ENC),  // 使能选项：开启或关闭。
                .PCS_TX_BYPASS_BIT_SLIP(PCS_CH3_TX_BYPASS_BIT_SLIP),  // 使能选项：开启或关闭。
                .PCS_TX_GEAR_SPLIT(PCS_CH3_TX_GEAR_SPLIT),  // 使能选项：开启或关闭。
                .PCS_TX_DRIVE_REG_MODE                       (PCS_CH3_TX_DRIVE_REG_MODE                         ),// 变换选项：不变、极性反转、位序反转或两者同时反转。
                .PCS_TX_BIT_SLIP_CYCLES(PCS_CH3_TX_BIT_SLIP_CYCLES),  // 取值范围：0～31。
                .PCS_INT_TX_MASK_0(PCS_CH3_INT_TX_MASK_0),  // 使能选项：开启或关闭。
                .PCS_INT_TX_MASK_1(PCS_CH3_INT_TX_MASK_1),  // 使能选项：开启或关闭。
                .PCS_INT_TX_MASK_2(PCS_CH3_INT_TX_MASK_2),  // 使能选项：开启或关闭。
                .PCS_INT_TX_CLR_0(PCS_CH3_INT_TX_CLR_0),  // 使能选项：开启或关闭。
                .PCS_INT_TX_CLR_1(PCS_CH3_INT_TX_CLR_1),  // 使能选项：开启或关闭。
                .PCS_INT_TX_CLR_2(PCS_CH3_INT_TX_CLR_2),  // 使能选项：开启或关闭。
                .PCS_TX_PMA_TCLK_POLINV(PCS_CH3_TX_PMA_TCLK_POLINV),  // 参数选项："PMA_TCLK" "REVERSE_OF_PMA_TCLK"
                .PCS_TX_PCS_CLK_EN_SEL(PCS_CH3_TX_PCS_CLK_EN_SEL),  // 使能选项：开启或关闭。
                .PCS_TX_BRIDGE_TCLK_SEL(PCS_CH3_TX_BRIDGE_TCLK_SEL),  // 参数选项："PCS_TCLK" "TCLK"
                .PCS_TX_TCLK_POLINV(PCS_CH3_TX_TCLK_POLINV),  // 参数选项："TCLK" "REVERSE_OF_TCLK"
                .PCS_PCS_TCLK_SEL(PCS_CH3_PCS_TCLK_SEL),  // 参数选项："PMA_TCLK" "TCLK"
                .PCS_TX_PCS_TX_RSTN(PCS_CH3_TX_PCS_TX_RSTN),  // PCS 发送端复位控制
                .PCS_TX_SLAVE(PCS_CH3_TX_SLAVE),  // 通道角色：主通道或从通道。
                .PCS_TX_GEAR_CLK_EN_SEL(PCS_CH3_TX_GEAR_CLK_EN_SEL),  // 使能选项：开启或关闭。
                .PCS_DATA_WIDTH_MODE(PCS_CH3_DATA_WIDTH_MODE),  // 参数选项："X8" "X10" "X16" "X20"
                .PCS_TX_64B66B_67B(PCS_CH3_TX_64B66B_67B),  // 编码模式：普通、64b/66b 或 64b/67b。
                .PCS_GEAR_TCLK_SEL(PCS_CH3_GEAR_TCLK_SEL),  // 参数选项："PMA_TCLK" "TCLK2"
                .PCS_TX_TCLK2FABRIC_SEL(PCS_CH3_TX_TCLK2FABRIC_SEL),  // 使能选项：开启或关闭。
                .PCS_TX_OUTZZ(PCS_CH3_TX_OUTZZ),  // 使能选项：开启或关闭。
                .PCS_ENC_DUAL(PCS_CH3_ENC_DUAL),  // 使能选项：开启或关闭。
                .PCS_TX_BITSLIP_DATA_MODE(PCS_CH3_TX_BITSLIP_DATA_MODE),  // 参数选项："X10" "X20"
                .PCS_TX_BRIDGE_CLK_POLINV                    (PCS_CH3_TX_BRIDGE_CLK_POLINV                      ),// 参数选项："TX_BRIDGE_CLK" "REVERSE_OF_TX_BRIDGE_CLK"
                .PCS_COMMA_REG1(PCS_CH3_COMMA_REG1),  // 取值范围：0～1023。
                .PCS_RAPID_IMAX(PCS_CH3_RAPID_IMAX),  // 取值范围：0～7。
                .PCS_RAPID_VMIN_1(PCS_CH3_RAPID_VMIN_1),  // 取值范围：0～255。
                .PCS_RAPID_VMIN_2(PCS_CH3_RAPID_VMIN_2),  // 取值范围：0～255。
                .PCS_RX_PRBS_MODE                            (PCS_CH3_RX_PRBS_MODE                              ),// PRBS 配置：关闭或选择 7、15、23、31 阶多项式。
                .PCS_RX_ERRCNT_CLR(PCS_CH3_RX_ERRCNT_CLR),  // 使能选项：开启或关闭。
                .PCS_PRBS_ERR_LPBK(PCS_CH3_PRBS_ERR_LPBK),  // 使能选项：开启或关闭。
                .PCS_TX_PRBS_MODE                            (PCS_CH3_TX_PRBS_MODE                              ),// 测试码型：PRBS、长 1、长 0、20 UI、D10.2 或 PCIe。
                .PCS_TX_INSERT_ER(PCS_CH3_TX_INSERT_ER),  // 使能选项：开启或关闭。
                .PCS_ENABLE_PRBS_GEN(PCS_CH3_ENABLE_PRBS_GEN),  // 使能选项：开启或关闭。
                .PCS_DEFAULT_RADDR(PCS_CH3_DEFAULT_RADDR),  // 取值范围：0～15。
                .PCS_MASTER_CHECK_OFFSET(PCS_CH3_MASTER_CHECK_OFFSET),  // 取值范围：0～15。
                .PCS_DELAY_SET(PCS_CH3_DELAY_SET),  // 取值范围：0～15。
                .PCS_SEACH_OFFSET(PCS_CH3_SEACH_OFFSET),  // 绑定位宽：20～80 位，间隔 10 位。
                .PCS_CEB_RAPIDLS_MMAX(PCS_CH3_CEB_RAPIDLS_MMAX),  // 取值范围：0～7。
                .PCS_CTC_AFULL(PCS_CH3_CTC_AFULL),  // 取值范围：0～31。
                .PCS_CTC_AEMPTY(PCS_CH3_CTC_AEMPTY),  // 取值范围：0～31。
                .PCS_CTC_CONTI_SKP_SET(PCS_CH3_CTC_CONTI_SKP_SET),  // 取值范围：0～1。
                .PCS_FAR_LOOP(PCS_CH3_FAR_LOOP),  // 使能选项：开启或关闭。
                .PCS_NEAR_LOOP(PCS_CH3_NEAR_LOOP),  // 使能选项：开启或关闭。
                .PCS_PMA_TX2RX_PLOOP_EN(PCS_CH3_PMA_TX2RX_PLOOP_EN),  // 使能选项：开启或关闭。
                .PCS_PMA_TX2RX_SLOOP_EN(PCS_CH3_PMA_TX2RX_SLOOP_EN),  // 使能选项：开启或关闭。
                .PCS_PMA_RX2TX_PLOOP_EN(PCS_CH3_PMA_RX2TX_PLOOP_EN),  // 使能选项：开启或关闭。
                .PCS_INT_RX_MASK_0(PCS_CH3_INT_RX_MASK_0),  // 使能选项：开启或关闭。
                .PCS_INT_RX_MASK_1(PCS_CH3_INT_RX_MASK_1),  // 使能选项：开启或关闭。
                .PCS_INT_RX_MASK_2(PCS_CH3_INT_RX_MASK_2),  // 使能选项：开启或关闭。
                .PCS_INT_RX_MASK_3(PCS_CH3_INT_RX_MASK_3),  // 使能选项：开启或关闭。
                .PCS_INT_RX_MASK_4(PCS_CH3_INT_RX_MASK_4),  // 使能选项：开启或关闭。
                .PCS_INT_RX_MASK_5(PCS_CH3_INT_RX_MASK_5),  // 使能选项：开启或关闭。
                .PCS_INT_RX_MASK_6(PCS_CH3_INT_RX_MASK_6),  // 使能选项：开启或关闭。
                .PCS_INT_RX_MASK_7(PCS_CH3_INT_RX_MASK_7),  // 使能选项：开启或关闭。
                .PCS_INT_RX_CLR_0(PCS_CH3_INT_RX_CLR_0),  // 使能选项：开启或关闭。
                .PCS_INT_RX_CLR_1(PCS_CH3_INT_RX_CLR_1),  // 使能选项：开启或关闭。
                .PCS_INT_RX_CLR_2(PCS_CH3_INT_RX_CLR_2),  // 使能选项：开启或关闭。
                .PCS_INT_RX_CLR_3(PCS_CH3_INT_RX_CLR_3),  // 使能选项：开启或关闭。
                .PCS_INT_RX_CLR_4(PCS_CH3_INT_RX_CLR_4),  // 使能选项：开启或关闭。
                .PCS_INT_RX_CLR_5(PCS_CH3_INT_RX_CLR_5),  // 使能选项：开启或关闭。
                .PCS_INT_RX_CLR_6(PCS_CH3_INT_RX_CLR_6),  // 使能选项：开启或关闭。
                .PCS_INT_RX_CLR_7(PCS_CH3_INT_RX_CLR_7),  // 使能选项：开启或关闭。
                .PCS_CA_RSTN_RX(PCS_CH3_CA_RSTN_RX),  // 接收时钟对齐器复位控制
                .PCS_CA_DYN_DLY_EN_RX(PCS_CH3_CA_DYN_DLY_EN_RX),  // 使能选项：开启或关闭。
                .PCS_CA_DYN_DLY_SEL_RX(PCS_CH3_CA_DYN_DLY_SEL_RX),  // 使能选项：开启或关闭。
                .PCS_CA_RX(PCS_CH3_CA_RX),  // 取值范围：0～255。
                .PCS_CA_RSTN_TX(PCS_CH3_CA_RSTN_TX),  // 使能选项：开启或关闭。
                .PCS_CA_DYN_DLY_EN_TX(PCS_CH3_CA_DYN_DLY_EN_TX),  // 使能选项：开启或关闭。
                .PCS_CA_DYN_DLY_SEL_TX(PCS_CH3_CA_DYN_DLY_SEL_TX),  // 使能选项：开启或关闭。
                .PCS_CA_TX(PCS_CH3_CA_TX),  // 取值范围：0～255。
                .PCS_RXPRBS_PWR_REDUCTION(PCS_CH3_RXPRBS_PWR_REDUCTION),  // 工作模式：普通或低功耗。
                .PCS_WDALIGN_PWR_REDUCTION(PCS_CH3_WDALIGN_PWR_REDUCTION),  // 工作模式：普通或低功耗。
                .PCS_RXDEC_PWR_REDUCTION(PCS_CH3_RXDEC_PWR_REDUCTION),  // 工作模式：普通或低功耗。
                .PCS_RXCB_PWR_REDUCTION(PCS_CH3_RXCB_PWR_REDUCTION),  // 工作模式：普通或低功耗。
                .PCS_RXCTC_PWR_REDUCTION(PCS_CH3_RXCTC_PWR_REDUCTION),  // 工作模式：普通或低功耗。
                .PCS_RXGEAR_PWR_REDUCTION(PCS_CH3_RXGEAR_PWR_REDUCTION),  // 工作模式：普通或低功耗。
                .PCS_RXBRG_PWR_REDUCTION(PCS_CH3_RXBRG_PWR_REDUCTION),  // 工作模式：普通或低功耗。
                .PCS_RXTEST_PWR_REDUCTION(PCS_CH3_RXTEST_PWR_REDUCTION),  // 工作模式：普通或低功耗。
                .PCS_TXBRG_PWR_REDUCTION(PCS_CH3_TXBRG_PWR_REDUCTION),  // 工作模式：普通或低功耗。
                .PCS_TXGEAR_PWR_REDUCTION(PCS_CH3_TXGEAR_PWR_REDUCTION),  // 工作模式：普通或低功耗。
                .PCS_TXENC_PWR_REDUCTION(PCS_CH3_TXENC_PWR_REDUCTION),  // 工作模式：普通或低功耗。
                .PCS_TXBSLP_PWR_REDUCTION(PCS_CH3_TXBSLP_PWR_REDUCTION),  // 工作模式：普通或低功耗。
                .PCS_TXPRBS_PWR_REDUCTION(PCS_CH3_TXPRBS_PWR_REDUCTION),  // 工作模式：普通或低功耗。

                .PMA_REG_RX_PD(PMA_CH3_REG_RX_PD),  // 使能选项：开启或关闭。
                .PMA_REG_RX_PD_EN(PMA_CH3_REG_RX_PD_EN),  // 使能选项：开启或关闭。
                .PMA_REG_RX_RESERVED_2(PMA_CH3_REG_RX_RESERVED_2),  // 使能选项：开启或关闭。
                .PMA_REG_RX_RESERVED_3(PMA_CH3_REG_RX_RESERVED_3),  // 使能选项：开启或关闭。
                .PMA_REG_RX_DATAPATH_PD(PMA_CH3_REG_RX_DATAPATH_PD),  // 使能选项：开启或关闭。
                .PMA_REG_RX_DATAPATH_PD_EN(PMA_CH3_REG_RX_DATAPATH_PD_EN),  // 使能选项：开启或关闭。
                .PMA_REG_RX_SIGDET_PD(PMA_CH3_REG_RX_SIGDET_PD),  // 使能选项：开启或关闭。
                .PMA_REG_RX_SIGDET_PD_EN(PMA_CH3_REG_RX_SIGDET_PD_EN),  // 使能选项：开启或关闭。
                .PMA_REG_RX_DCC_RST_N(PMA_CH3_REG_RX_DCC_RST_N),  // 使能选项：开启或关闭。
                .PMA_REG_RX_DCC_RST_N_EN(PMA_CH3_REG_RX_DCC_RST_N_EN),  // 使能选项：开启或关闭。
                .PMA_REG_RX_CDR_RST_N(PMA_CH3_REG_RX_CDR_RST_N),  // 使能选项：开启或关闭。
                .PMA_REG_RX_CDR_RST_N_EN(PMA_CH3_REG_RX_CDR_RST_N_EN),  // 使能选项：开启或关闭。
                .PMA_REG_RX_SIGDET_RST_N(PMA_CH3_REG_RX_SIGDET_RST_N),  // 使能选项：开启或关闭。
                .PMA_REG_RX_SIGDET_RST_N_EN(PMA_CH3_REG_RX_SIGDET_RST_N_EN),  // 使能选项：开启或关闭。
                .PMA_REG_RXPCLK_SLIP(PMA_CH3_REG_RXPCLK_SLIP),  // 使能选项：开启或关闭。
                .PMA_REG_RXPCLK_SLIP_OW(PMA_CH3_REG_RXPCLK_SLIP_OW),  // 使能选项：开启或关闭。
                .PMA_REG_RX_PCLKSWITCH_RST_N(PMA_CH3_REG_RX_PCLKSWITCH_RST_N),  // 发送 PMA 复位控制
                .PMA_REG_RX_PCLKSWITCH_RST_N_EN              (PMA_CH3_REG_RX_PCLKSWITCH_RST_N_EN                ),// 使能选项：开启或关闭。
                .PMA_REG_RX_PCLKSWITCH(PMA_CH3_REG_RX_PCLKSWITCH),  // 使能选项：开启或关闭。
                .PMA_REG_RX_PCLKSWITCH_EN(PMA_CH3_REG_RX_PCLKSWITCH_EN),  // 使能选项：开启或关闭。
                .PMA_REG_RX_HIGHZ(PMA_CH3_REG_RX_HIGHZ),  // 使能选项：开启或关闭。
                .PMA_REG_RX_HIGHZ_EN(PMA_CH3_REG_RX_HIGHZ_EN),  // 使能选项：开启或关闭。
                .PMA_REG_RX_SIGDET_CLK_WINDOW(PMA_CH3_REG_RX_SIGDET_CLK_WINDOW),  // 使能选项：开启或关闭。
                .PMA_REG_RX_SIGDET_CLK_WINDOW_OW             (PMA_CH3_REG_RX_SIGDET_CLK_WINDOW_OW               ),// 使能选项：开启或关闭。
                .PMA_REG_RX_PD_BIAS_RX(PMA_CH3_REG_RX_PD_BIAS_RX),  // 使能选项：开启或关闭。
                .PMA_REG_RX_PD_BIAS_RX_OW(PMA_CH3_REG_RX_PD_BIAS_RX_OW),  // 使能选项：开启或关闭。
                .PMA_REG_RX_RESET_N(PMA_CH3_REG_RX_RESET_N),  // 使能选项：开启或关闭。
                .PMA_REG_RX_RESET_N_OW(PMA_CH3_REG_RX_RESET_N_OW),  // 使能选项：开启或关闭。
                .PMA_REG_RX_RESERVED_29_28(PMA_CH3_REG_RX_RESERVED_29_28),  // 取值范围：0～3。
                .PMA_REG_RX_BUSWIDTH(PMA_CH3_REG_RX_BUSWIDTH),  // 位宽选项：8、10、16 或 20 位。
                .PMA_REG_RX_BUSWIDTH_EN(PMA_CH3_REG_RX_BUSWIDTH_EN),  // 使能选项：开启或关闭。
                .PMA_REG_RX_RATE(PMA_CH3_REG_RX_RATE),  // 时钟倍率：四分频、二分频、原频或二倍频。
                .PMA_REG_RX_RESERVED_36(PMA_CH3_REG_RX_RESERVED_36),  // 使能选项：开启或关闭。
                .PMA_REG_RX_RATE_EN(PMA_CH3_REG_RX_RATE_EN),  // 使能选项：开启或关闭。
                .PMA_REG_RX_RES_TRIM(PMA_CH3_REG_RX_RES_TRIM),  // 取值范围：0～63。
                .PMA_REG_RX_RESERVED_44(PMA_CH3_REG_RX_RESERVED_44),  // 使能选项：开启或关闭。
                .PMA_REG_RX_RESERVED_45(PMA_CH3_REG_RX_RESERVED_45),  // 使能选项：开启或关闭。
                .PMA_REG_RX_SIGDET_STATUS_EN(PMA_CH3_REG_RX_SIGDET_STATUS_EN),  // 使能选项：开启或关闭。
                .PMA_REG_RX_RESERVED_48_47(PMA_CH3_REG_RX_RESERVED_48_47),  // 取值范围：0～3。
                .PMA_REG_RX_ICTRL_SIGDET(PMA_CH3_REG_RX_ICTRL_SIGDET),  // 取值范围：0～15。
                .PMA_REG_CDR_READY_THD(PMA_CH3_REG_CDR_READY_THD),  // 取值范围：0～4095。
                .PMA_REG_RX_RESERVED_65(PMA_CH3_REG_RX_RESERVED_65),  // 使能选项：开启或关闭。
                .PMA_REG_RX_PCLK_EDGE_SEL(PMA_CH3_REG_RX_PCLK_EDGE_SEL),  // 时钟边沿：上升沿或下降沿。
                .PMA_REG_RX_PIBUF_IC(PMA_CH3_REG_RX_PIBUF_IC),  // 取值范围：0～3。
                .PMA_REG_RX_RESERVED_69(PMA_CH3_REG_RX_RESERVED_69),  // 使能选项：开启或关闭。
                .PMA_REG_RX_DCC_IC_RX(PMA_CH3_REG_RX_DCC_IC_RX),  // 取值范围：0～3。
                .PMA_REG_CDR_READY_CHECK_CTRL(PMA_CH3_REG_CDR_READY_CHECK_CTRL),  // 取值范围：0～3。
                .PMA_REG_RX_ICTRL_TRX(PMA_CH3_REG_RX_ICTRL_TRX),  // 比例选项：87.5%、100%、112.5%、125%。
                .PMA_REG_RX_RESERVED_77_76(PMA_CH3_REG_RX_RESERVED_77_76),  // 取值范围：0～3。
                .PMA_REG_RX_RESERVED_79_78(PMA_CH3_REG_RX_RESERVED_79_78),  // 取值范围：0～3。
                .PMA_REG_RX_RESERVED_81_80(PMA_CH3_REG_RX_RESERVED_81_80),  // 取值范围：0～3。
                .PMA_REG_RX_ICTRL_PIBUF(PMA_CH3_REG_RX_ICTRL_PIBUF),  // 比例选项：87.5%、100%、112.5%、125%。
                .PMA_REG_RX_ICTRL_PI(PMA_CH3_REG_RX_ICTRL_PI),  // 比例选项：87.5%、100%、112.5%、125%。
                .PMA_REG_RX_ICTRL_DCC(PMA_CH3_REG_RX_ICTRL_DCC),  // 比例选项：87.5%、100%、112.5%、125%。
                .PMA_REG_RX_RESERVED_89_88(PMA_CH3_REG_RX_RESERVED_89_88),  // 取值范围：0～3。
                .PMA_REG_TX_RATE(PMA_CH3_REG_TX_RATE),  // 时钟倍率：四分频、二分频、原频或二倍频。
                .PMA_REG_RX_RESERVED_92(PMA_CH3_REG_RX_RESERVED_92),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RATE_EN(PMA_CH3_REG_TX_RATE_EN),  // 使能选项：开启或关闭。
                .PMA_REG_RX_TX2RX_PLPBK_RST_N                (PMA_CH3_REG_RX_TX2RX_PLPBK_RST_N                  ),// PMA 发送到接收并行环回复位控制
                .PMA_REG_RX_TX2RX_PLPBK_RST_N_EN             (PMA_CH3_REG_RX_TX2RX_PLPBK_RST_N_EN               ),// 使能选项：开启或关闭。
                .PMA_REG_RX_TX2RX_PLPBK_EN(PMA_CH3_REG_RX_TX2RX_PLPBK_EN),  // PMA 发送到接收并行环回使能
                .PMA_REG_TXCLK_SEL(PMA_CH3_REG_TXCLK_SEL),  // 时钟来源：PLL 或接收时钟。
                .PMA_REG_RX_DATA_POLARITY(PMA_CH3_REG_RX_DATA_POLARITY),  // 极性选项：正常或反转。
                .PMA_REG_RX_ERR_INSERT(PMA_CH3_REG_RX_ERR_INSERT),  // 使能选项：开启或关闭。
                .PMA_REG_UDP_CHK_EN(PMA_CH3_REG_UDP_CHK_EN),  // 使能选项：开启或关闭。
                .PMA_REG_PRBS_SEL(PMA_CH3_REG_PRBS_SEL),  // PRBS 多项式阶数：7、15、23、31。
                .PMA_REG_PRBS_CHK_EN(PMA_CH3_REG_PRBS_CHK_EN),  // 使能选项：开启或关闭。
                .PMA_REG_PRBS_CHK_WIDTH_SEL                  (PMA_CH3_REG_PRBS_CHK_WIDTH_SEL                    ),// 位宽选项：8、10、16 或 20 位。
                .PMA_REG_BIST_CHK_PAT_SEL(PMA_CH3_REG_BIST_CHK_PAT_SEL),  // 码型来源：PRBS 或常量。
                .PMA_REG_LOAD_ERR_CNT(PMA_CH3_REG_LOAD_ERR_CNT),  // 使能选项：开启或关闭。
                .PMA_REG_CHK_COUNTER_EN(PMA_CH3_REG_CHK_COUNTER_EN),  // 使能选项：开启或关闭。
                .PMA_REG_CDR_PROP_GAIN(PMA_CH3_REG_CDR_PROP_GAIN),  // 取值范围：0～7。
                .PMA_REG_CDR_PROP_TURBO_GAIN(PMA_CH3_REG_CDR_PROP_TURBO_GAIN),  // 取值范围：0～7。
                .PMA_REG_CDR_INT_GAIN(PMA_CH3_REG_CDR_INT_GAIN),  // 取值范围：0～7。
                .PMA_REG_CDR_INT_TURBO_GAIN(PMA_CH3_REG_CDR_INT_TURBO_GAIN),  // 取值范围：0～7。
                .PMA_REG_CDR_INT_SAT_MAX(PMA_CH3_REG_CDR_INT_SAT_MAX),  // 取值范围：0～1023。
                .PMA_REG_CDR_INT_SAT_MIN(PMA_CH3_REG_CDR_INT_SAT_MIN),  // 取值范围：0～1023。
                .PMA_REG_CDR_INT_RST(PMA_CH3_REG_CDR_INT_RST),  // 使能选项：开启或关闭。
                .PMA_REG_CDR_INT_RST_OW(PMA_CH3_REG_CDR_INT_RST_OW),  // 使能选项：开启或关闭。
                .PMA_REG_CDR_PROP_RST(PMA_CH3_REG_CDR_PROP_RST),  // 使能选项：开启或关闭。
                .PMA_REG_CDR_PROP_RST_OW(PMA_CH3_REG_CDR_PROP_RST_OW),  // 使能选项：开启或关闭。
                .PMA_REG_CDR_LOCK_RST(PMA_CH3_REG_CDR_LOCK_RST),  // CDR 锁定计数器复位控制
                .PMA_REG_CDR_LOCK_RST_OW(PMA_CH3_REG_CDR_LOCK_RST_OW),  // 使能选项：开启或关闭。
                .PMA_REG_CDR_RX_PI_FORCE_SEL(PMA_CH3_REG_CDR_RX_PI_FORCE_SEL),  //0,1
                .PMA_REG_CDR_RX_PI_FORCE_D(PMA_CH3_REG_CDR_RX_PI_FORCE_D),  // 取值范围：0～255。
                .PMA_REG_CDR_LOCK_TIMER                      (PMA_CH3_REG_CDR_LOCK_TIMER                        ),// 参数选项："0_8U" "1_2U" "1_6U" "2_4U" 3_2U" "4_8U" "12_8U" "25_6U"
                .PMA_REG_CDR_TURBO_MODE_TIMER(PMA_CH3_REG_CDR_TURBO_MODE_TIMER),  // 取值范围：0～3。
                .PMA_REG_CDR_LOCK_VAL(PMA_CH3_REG_CDR_LOCK_VAL),  // 使能选项：开启或关闭。
                .PMA_REG_CDR_LOCK_OW(PMA_CH3_REG_CDR_LOCK_OW),  // 使能选项：开启或关闭。
                .PMA_REG_CDR_INT_SAT_DET_EN(PMA_CH3_REG_CDR_INT_SAT_DET_EN),  // 使能选项：开启或关闭。
                .PMA_REG_CDR_SAT_AUTO_DIS(PMA_CH3_REG_CDR_SAT_AUTO_DIS),  // 使能选项：开启或关闭。
                .PMA_REG_CDR_GAIN_AUTO(PMA_CH3_REG_CDR_GAIN_AUTO),  // 使能选项：开启或关闭。
                .PMA_REG_CDR_TURBO_GAIN_AUTO(PMA_CH3_REG_CDR_TURBO_GAIN_AUTO),  // 使能选项：开启或关闭。
                .PMA_REG_RX_RESERVED_171_167(PMA_CH3_REG_RX_RESERVED_171_167),  // 取值范围：0～31。
                .PMA_REG_RX_RESERVED_175_172(PMA_CH3_REG_RX_RESERVED_175_172),  // 取值范围：0～31。
                .PMA_REG_CDR_SAT_DET_STATUS_EN(PMA_CH3_REG_CDR_SAT_DET_STATUS_EN),  // 使能选项：开启或关闭。
                .PMA_REG_CDR_SAT_DET_STATUS_RESET_EN         (PMA_CH3_REG_CDR_SAT_DET_STATUS_RESET_EN           ),// 使能选项：开启或关闭。
                .PMA_REG_CDR_PI_CTRL_RST(PMA_CH3_REG_CDR_PI_CTRL_RST),  // 使能选项：开启或关闭。
                .PMA_REG_CDR_PI_CTRL_RST_OW(PMA_CH3_REG_CDR_PI_CTRL_RST_OW),  // 使能选项：开启或关闭。
                .PMA_REG_CDR_SAT_DET_RST(PMA_CH3_REG_CDR_SAT_DET_RST),  // 使能选项：开启或关闭。
                .PMA_REG_CDR_SAT_DET_RST_OW(PMA_CH3_REG_CDR_SAT_DET_RST_OW),  // 使能选项：开启或关闭。
                .PMA_REG_CDR_SAT_DET_STICKY_RST              (PMA_CH3_REG_CDR_SAT_DET_STICKY_RST                ),// 使能选项：开启或关闭。
                .PMA_REG_CDR_SAT_DET_STICKY_RST_OW           (PMA_CH3_REG_CDR_SAT_DET_STICKY_RST_OW             ),// 使能选项：开启或关闭。
                .PMA_REG_CDR_SIGDET_STATUS_DIS               (PMA_CH3_REG_CDR_SIGDET_STATUS_DIS                 ),// 无信号检测状态时复位 CDR。
                .PMA_REG_CDR_SAT_DET_TIMER(PMA_CH3_REG_CDR_SAT_DET_TIMER),  // 取值范围：0～3。
                .PMA_REG_CDR_SAT_DET_STATUS_VAL              (PMA_CH3_REG_CDR_SAT_DET_STATUS_VAL                ),// 使能选项：开启或关闭。
                .PMA_REG_CDR_SAT_DET_STATUS_OW(PMA_CH3_REG_CDR_SAT_DET_STATUS_OW),  // 使能选项：开启或关闭。
                .PMA_REG_CDR_TURBO_MODE_EN(PMA_CH3_REG_CDR_TURBO_MODE_EN),  // 使能选项：开启或关闭。
                .PMA_REG_RX_RESERVED_190(PMA_CH3_REG_RX_RESERVED_190),  // 使能选项：开启或关闭。
                .PMA_REG_RX_RESERVED_193_191(PMA_CH3_REG_RX_RESERVED_193_191),  // 取值范围：0～7。
                .PMA_REG_CDR_STATUS_FIFO_EN(PMA_CH3_REG_CDR_STATUS_FIFO_EN),  // 使能选项：开启或关闭。
                .PMA_REG_PMA_TEST_SEL(PMA_CH3_REG_PMA_TEST_SEL),  //0,1
                .PMA_REG_OOB_COMWAKE_GAP_MIN(PMA_CH3_REG_OOB_COMWAKE_GAP_MIN),  // 取值范围：0～63。
                .PMA_REG_OOB_COMWAKE_GAP_MAX(PMA_CH3_REG_OOB_COMWAKE_GAP_MAX),  // 取值范围：0～63。
                .PMA_REG_OOB_COMINIT_GAP_MIN(PMA_CH3_REG_OOB_COMINIT_GAP_MIN),  // 取值范围：0～255。
                .PMA_REG_OOB_COMINIT_GAP_MAX(PMA_CH3_REG_OOB_COMINIT_GAP_MAX),  // 取值范围：0～255。
                .PMA_REG_RX_RESERVED_227_226(PMA_CH3_REG_RX_RESERVED_227_226),  // 取值范围：0～3。
                .PMA_REG_COMWAKE_STATUS_CLEAR(PMA_CH3_REG_COMWAKE_STATUS_CLEAR),  //0,1
                .PMA_REG_COMINIT_STATUS_CLEAR(PMA_CH3_REG_COMINIT_STATUS_CLEAR),  //0,1
                .PMA_REG_RX_SYNC_RST_N_EN(PMA_CH3_REG_RX_SYNC_RST_N_EN),  // 使能选项：开启或关闭。
                .PMA_REG_RX_SYNC_RST_N(PMA_CH3_REG_RX_SYNC_RST_N),  // 使能选项：开启或关闭。
                .PMA_REG_RX_RESERVED_233_232(PMA_CH3_REG_RX_RESERVED_233_232),  // 取值范围：0～3。
                .PMA_REG_RX_RESERVED_235_234(PMA_CH3_REG_RX_RESERVED_235_234),  // 取值范围：0～3。
                .PMA_REG_RX_SATA_COMINIT_OW(PMA_CH3_REG_RX_SATA_COMINIT_OW),  // 使能选项：开启或关闭。
                .PMA_REG_RX_SATA_COMINIT(PMA_CH3_REG_RX_SATA_COMINIT),  // 使能选项：开启或关闭。
                .PMA_REG_RX_SATA_COMWAKE_OW(PMA_CH3_REG_RX_SATA_COMWAKE_OW),  // 使能选项：开启或关闭。
                .PMA_REG_RX_SATA_COMWAKE(PMA_CH3_REG_RX_SATA_COMWAKE),  // 使能选项：开启或关闭。
                .PMA_REG_RX_RESERVED_241_240(PMA_CH3_REG_RX_RESERVED_241_240),  // 取值范围：0～3。
                .PMA_REG_RX_DCC_DISABLE(PMA_CH3_REG_RX_DCC_DISABLE),  // 接收占空比校正禁用控制
                .PMA_REG_RX_RESERVED_243(PMA_CH3_REG_RX_RESERVED_243),  // 使能选项：开启或关闭。
                .PMA_REG_RX_SLIP_SEL_EN(PMA_CH3_REG_RX_SLIP_SEL_EN),  // 使能选项：开启或关闭。
                .PMA_REG_RX_SLIP_SEL(PMA_CH3_REG_RX_SLIP_SEL),  // 取值范围：0～15。
                .PMA_REG_RX_SLIP_EN(PMA_CH3_REG_RX_SLIP_EN),  // 使能选项：开启或关闭。
                .PMA_REG_RX_SIGDET_STATUS_SEL(PMA_CH3_REG_RX_SIGDET_STATUS_SEL),  // 取值范围：0～7。
                .PMA_REG_RX_SIGDET_FSM_RST_N(PMA_CH3_REG_RX_SIGDET_FSM_RST_N),  // 使能选项：开启或关闭。
                .PMA_REG_RX_RESERVED_254(PMA_CH3_REG_RX_RESERVED_254),  // 使能选项：开启或关闭。
                .PMA_REG_RX_SIGDET_STATUS(PMA_CH3_REG_RX_SIGDET_STATUS),  // 使能选项：开启或关闭。
                .PMA_REG_RX_SIGDET_VTH(PMA_CH3_REG_RX_SIGDET_VTH),  // 检测电压：45、54、63、72 mV。
                .PMA_REG_RX_SIGDET_GRM(PMA_CH3_REG_RX_SIGDET_GRM),  //0,1,2,3
                .PMA_REG_RX_SIGDET_PULSE_EXT(PMA_CH3_REG_RX_SIGDET_PULSE_EXT),  // 使能选项：开启或关闭。
                .PMA_REG_RX_SIGDET_CH2_SEL(PMA_CH3_REG_RX_SIGDET_CH2_SEL),  //0,1
                .PMA_REG_RX_SIGDET_CH2_CHK_WINDOW(PMA_CH3_REG_RX_SIGDET_CH2_CHK_WINDOW),  // 取值范围：0～31。
                .PMA_REG_RX_SIGDET_CHK_WINDOW_EN             (PMA_CH3_REG_RX_SIGDET_CHK_WINDOW_EN               ),// 使能选项：开启或关闭。
                .PMA_REG_RX_SIGDET_NOSIG_COUNT_SETTING       (PMA_CH3_REG_RX_SIGDET_NOSIG_COUNT_SETTING         ),// 取值范围：0～7。
                .PMA_REG_SLIP_FIFO_INV_EN(PMA_CH3_REG_SLIP_FIFO_INV_EN),  // 使能选项：开启或关闭。
                .PMA_REG_SLIP_FIFO_INV(PMA_CH3_REG_SLIP_FIFO_INV),  // 时钟边沿：上升沿或下降沿。
                .PMA_REG_RX_SIGDET_OOB_DET_COUNT_VAL         (PMA_CH3_REG_RX_SIGDET_OOB_DET_COUNT_VAL           ),// 取值范围：0～31。
                .PMA_REG_RX_SIGDET_4OOB_DET_SEL(PMA_CH3_REG_RX_SIGDET_4OOB_DET_SEL),  // 取值范围：0～7。
                .PMA_REG_RX_RESERVED_285_283(PMA_CH3_REG_RX_RESERVED_285_283),  // 取值范围：0～7。
                .PMA_REG_RX_RESERVED_286(PMA_CH3_REG_RX_RESERVED_286),  // 使能选项：开启或关闭。
                .PMA_REG_RX_SIGDET_IC_I(PMA_CH3_REG_RX_SIGDET_IC_I),  // 取值范围：0～15。
                .PMA_REG_RX_OOB_DETECTOR_RESET_N_OW          (PMA_CH3_REG_RX_OOB_DETECTOR_RESET_N_OW            ),// 使能选项：开启或关闭。
                .PMA_REG_RX_OOB_DETECTOR_RESET_N             (PMA_CH3_REG_RX_OOB_DETECTOR_RESET_N               ),// 接收带外检测器复位控制
                .PMA_REG_RX_OOB_DETECTOR_PD_OW(PMA_CH3_REG_RX_OOB_DETECTOR_PD_OW),  // 使能选项：开启或关闭。
                .PMA_REG_RX_OOB_DETECTOR_PD(PMA_CH3_REG_RX_OOB_DETECTOR_PD),  // 接收带外检测器掉电控制
                .PMA_REG_RX_LS_MODE_EN(PMA_CH3_REG_RX_LS_MODE_EN),  // 低速模式使能
                .PMA_REG_ANA_RX_EQ1_R_SET_FB_O_SEL           (PMA_CH3_REG_ANA_RX_EQ1_R_SET_FB_O_SEL             ),// 使能选项：开启或关闭。
                .PMA_REG_ANA_RX_EQ2_R_SET_FB_O_SEL           (PMA_CH3_REG_ANA_RX_EQ2_R_SET_FB_O_SEL             ),// 使能选项：开启或关闭。
                .PMA_REG_RX_EQ1_R_SET_TOP(PMA_CH3_REG_RX_EQ1_R_SET_TOP),  // 取值范围：0～3。
                .PMA_REG_RX_EQ1_R_SET_FB(PMA_CH3_REG_RX_EQ1_R_SET_FB),  // 取值范围：0～15。
                .PMA_REG_RX_EQ1_C_SET_FB(PMA_CH3_REG_RX_EQ1_C_SET_FB),  // 取值范围：0～15。
                .PMA_REG_RX_EQ1_OFF(PMA_CH3_REG_RX_EQ1_OFF),  // 使能选项：开启或关闭。
                .PMA_REG_RX_EQ2_R_SET_TOP(PMA_CH3_REG_RX_EQ2_R_SET_TOP),  // 取值范围：0～3。
                .PMA_REG_RX_EQ2_R_SET_FB(PMA_CH3_REG_RX_EQ2_R_SET_FB),  // 取值范围：0～15。
                .PMA_REG_RX_EQ2_C_SET_FB(PMA_CH3_REG_RX_EQ2_C_SET_FB),  // 取值范围：0～15。
                .PMA_REG_RX_EQ2_OFF(PMA_CH3_REG_RX_EQ2_OFF),  // 使能选项：开启或关闭。
                .PMA_REG_EQ_DAC(PMA_CH3_REG_EQ_DAC),  // 取值范围：0～63。
                .PMA_REG_RX_ICTRL_EQ(PMA_CH3_REG_RX_ICTRL_EQ),  // 使能选项：开启或关闭。
                .PMA_REG_EQ_DC_CALIB_EN(PMA_CH3_REG_EQ_DC_CALIB_EN),  // 使能选项：开启或关闭。
                .PMA_REG_EQ_DC_CALIB_SEL(PMA_CH3_REG_EQ_DC_CALIB_SEL),  // 使能选项：开启或关闭。
                .PMA_REG_RX_RESERVED_337_330(PMA_CH3_REG_RX_RESERVED_337_330),  // 取值范围：0～255。
                .PMA_REG_RX_RESERVED_345_338(PMA_CH3_REG_RX_RESERVED_345_338),  // 取值范围：0～255。
                .PMA_REG_RX_RESERVED_353_346(PMA_CH3_REG_RX_RESERVED_353_346),  // 取值范围：0～255。
                .PMA_REG_RX_RESERVED_361_354(PMA_CH3_REG_RX_RESERVED_361_354),  // 取值范围：0～255。
                .PMA_CTLE_CTRL_REG_I(PMA_CH3_CTLE_CTRL_REG_I),  // 取值范围：0～15。
                .PMA_CTLE_REG_FORCE_SEL_I(PMA_CH3_CTLE_REG_FORCE_SEL_I),  // 自适应调整控制
                .PMA_CTLE_REG_HOLD_I(PMA_CH3_CTLE_REG_HOLD_I),  // 使能选项：开启或关闭。
                .PMA_CTLE_REG_INIT_DAC_I(PMA_CH3_CTLE_REG_INIT_DAC_I),  // 取值范围：0～15。
                .PMA_CTLE_REG_POLARITY_I(PMA_CH3_CTLE_REG_POLARITY_I),  // 使能选项：开启或关闭。
                .PMA_CTLE_REG_SHIFTER_GAIN_I(PMA_CH3_CTLE_REG_SHIFTER_GAIN_I),  // 取值范围：0～7。
                .PMA_CTLE_REG_THRESHOLD_I(PMA_CH3_CTLE_REG_THRESHOLD_I),  // 取值范围：0～4095。
                .PMA_REG_RX_RES_TRIM_EN(PMA_CH3_REG_RX_RES_TRIM_EN),  // 使能选项：开启或关闭。
                .PMA_REG_RX_RESERVED_393_389(PMA_CH3_REG_RX_RESERVED_393_389),  // 取值范围：0～31。
                .PMA_CFG_RX_LANE_POWERUP(PMA_CH3_CFG_RX_LANE_POWERUP),  // 接收通道上电控制
                .PMA_CFG_RX_PMA_RSTN(PMA_CH3_CFG_RX_PMA_RSTN),  // 接收 PMA 复位控制
                .PMA_INT_PMA_RX_MASK_0(PMA_CH3_INT_PMA_RX_MASK_0),  // 使能选项：开启或关闭。
                .PMA_INT_PMA_RX_CLR_0(PMA_CH3_INT_PMA_RX_CLR_0),  // 使能选项：开启或关闭。
                .PMA_CFG_CTLE_ADP_RSTN(PMA_CH3_CFG_CTLE_ADP_RSTN),  // 控制逻辑复位

                .PMA_REG_TX_PD(PMA_CH3_REG_TX_PD),  // 发送端掉电控制
                .PMA_REG_TX_PD_OW(PMA_CH3_REG_TX_PD_OW),  // 使能选项：开启或关闭。
                .PMA_REG_TX_MAIN_PRE_Z(PMA_CH3_REG_TX_MAIN_PRE_Z),  // PCIe 模式电气空闲使能
                .PMA_REG_TX_MAIN_PRE_Z_OW(PMA_CH3_REG_TX_MAIN_PRE_Z_OW),  // 使能选项：开启或关闭。
                .PMA_REG_TX_BEACON_TIMER_SEL(PMA_CH3_REG_TX_BEACON_TIMER_SEL),  // 取值范围：0～3。
                .PMA_REG_TX_RXDET_REQ_OW(PMA_CH3_REG_TX_RXDET_REQ_OW),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RXDET_REQ(PMA_CH3_REG_TX_RXDET_REQ),  // 使能选项：开启或关闭。
                .PMA_REG_TX_BEACON_EN_OW(PMA_CH3_REG_TX_BEACON_EN_OW),  // 使能选项：开启或关闭。
                .PMA_REG_TX_BEACON_EN(PMA_CH3_REG_TX_BEACON_EN),  // 使能选项：开启或关闭。
                .PMA_REG_TX_EI_EN_OW(PMA_CH3_REG_TX_EI_EN_OW),  // 使能选项：开启或关闭。
                .PMA_REG_TX_EI_EN(PMA_CH3_REG_TX_EI_EN),  // 使能选项：开启或关闭。
                .PMA_REG_TX_BIT_CONV(PMA_CH3_REG_TX_BIT_CONV),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RES_CAL(PMA_CH3_REG_TX_RES_CAL),  // 取值范围：0～63。
                .PMA_REG_TX_RESERVED_19(PMA_CH3_REG_TX_RESERVED_19),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RESERVED_25_20(PMA_CH3_REG_TX_RESERVED_25_20),  // 取值范围：0～63。
                .PMA_REG_TX_RESERVED_33_26(PMA_CH3_REG_TX_RESERVED_33_26),  // 取值范围：0～255。
                .PMA_REG_TX_RESERVED_41_34(PMA_CH3_REG_TX_RESERVED_41_34),  // 取值范围：0～255。
                .PMA_REG_TX_RESERVED_49_42(PMA_CH3_REG_TX_RESERVED_49_42),  // 取值范围：0～255。
                .PMA_REG_TX_RESERVED_57_50(PMA_CH3_REG_TX_RESERVED_57_50),  // 取值范围：0～255。
                .PMA_REG_TX_SYNC_OW(PMA_CH3_REG_TX_SYNC_OW),  // 使能选项：开启或关闭。
                .PMA_REG_TX_SYNC(PMA_CH3_REG_TX_SYNC),  // 使能选项：开启或关闭。
                .PMA_REG_TX_PD_POST(PMA_CH3_REG_TX_PD_POST),  // 使能选项：开启或关闭。
                .PMA_REG_TX_PD_POST_OW(PMA_CH3_REG_TX_PD_POST_OW),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RESET_N_OW(PMA_CH3_REG_TX_RESET_N_OW),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RESET_N(PMA_CH3_REG_TX_RESET_N),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RESERVED_64(PMA_CH3_REG_TX_RESERVED_64),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RESERVED_65(PMA_CH3_REG_TX_RESERVED_65),  // 使能选项：开启或关闭。
                .PMA_REG_TX_BUSWIDTH_OW(PMA_CH3_REG_TX_BUSWIDTH_OW),  // 使能选项：开启或关闭。
                .PMA_REG_TX_BUSWIDTH(PMA_CH3_REG_TX_BUSWIDTH),  // 位宽选项：8、10、16 或 20 位。
                .PMA_REG_PLL_READY_OW(PMA_CH3_REG_PLL_READY_OW),  // 使能选项：开启或关闭。
                .PMA_REG_PLL_READY(PMA_CH3_REG_PLL_READY),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RESERVED_72(PMA_CH3_REG_TX_RESERVED_72),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RESERVED_73(PMA_CH3_REG_TX_RESERVED_73),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RESERVED_74(PMA_CH3_REG_TX_RESERVED_74),  // 使能选项：开启或关闭。
                .PMA_REG_EI_PCLK_DELAY_SEL(PMA_CH3_REG_EI_PCLK_DELAY_SEL),  // 取值范围：0～3。
                .PMA_REG_TX_RESERVED_77(PMA_CH3_REG_TX_RESERVED_77),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RESERVED_83_78(PMA_CH3_REG_TX_RESERVED_83_78),  // 取值范围：0～63。
                .PMA_REG_TX_RESERVED_89_84(PMA_CH3_REG_TX_RESERVED_89_84),  // 取值范围：0～63。
                .PMA_REG_TX_RESERVED_95_90(PMA_CH3_REG_TX_RESERVED_95_90),  // 取值范围：0～63。
                .PMA_REG_TX_RESERVED_101_96(PMA_CH3_REG_TX_RESERVED_101_96),  // 取值范围：0～63。
                .PMA_REG_TX_RESERVED_107_102(PMA_CH3_REG_TX_RESERVED_107_102),  // 取值范围：0～63。
                .PMA_REG_TX_RESERVED_113_108(PMA_CH3_REG_TX_RESERVED_113_108),  // 取值范围：0～63。
                .PMA_REG_TX_AMP_DAC0(PMA_CH3_REG_TX_AMP_DAC0),  // 取值范围：0～63。
                .PMA_REG_TX_AMP_DAC1(PMA_CH3_REG_TX_AMP_DAC1),  // 取值范围：0～63。
                .PMA_REG_TX_AMP_DAC2(PMA_CH3_REG_TX_AMP_DAC2),  // 取值范围：0～63。
                .PMA_REG_TX_AMP_DAC3(PMA_CH3_REG_TX_AMP_DAC3),  // 取值范围：0～63。
                .PMA_REG_TX_RESERVED_143_138(PMA_CH3_REG_TX_RESERVED_143_138),  // 取值范围：0～63。
                .PMA_REG_TX_MARGIN(PMA_CH3_REG_TX_MARGIN),  // 取值范围：0～7。
                .PMA_REG_TX_MARGIN_OW(PMA_CH3_REG_TX_MARGIN_OW),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RESERVED_149_148(PMA_CH3_REG_TX_RESERVED_149_148),  // 取值范围：0～3。
                .PMA_REG_TX_RESERVED_150(PMA_CH3_REG_TX_RESERVED_150),  // 使能选项：开启或关闭。
                .PMA_REG_TX_SWING(PMA_CH3_REG_TX_SWING),  // 使能选项：开启或关闭。
                .PMA_REG_TX_SWING_OW(PMA_CH3_REG_TX_SWING_OW),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RESERVED_153(PMA_CH3_REG_TX_RESERVED_153),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RXDET_THRESHOLD(PMA_CH3_REG_TX_RXDET_THRESHOLD),  // 电压选项：28、56、84、112 mV。
                .PMA_REG_TX_RESERVED_157_156(PMA_CH3_REG_TX_RESERVED_157_156),  // 取值范围：0～3。
                .PMA_REG_TX_BEACON_OSC_CTRL(PMA_CH3_REG_TX_BEACON_OSC_CTRL),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RESERVED_160_159(PMA_CH3_REG_TX_RESERVED_160_159),  // 取值范围：0～3。
                .PMA_REG_TX_RESERVED_162_161(PMA_CH3_REG_TX_RESERVED_162_161),  // 取值范围：0～3。
                .PMA_REG_TX_TX2RX_SLPBACK_EN(PMA_CH3_REG_TX_TX2RX_SLPBACK_EN),  // 使能选项：开启或关闭。
                .PMA_REG_TX_PCLK_EDGE_SEL(PMA_CH3_REG_TX_PCLK_EDGE_SEL),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RXDET_STATUS_OW(PMA_CH3_REG_TX_RXDET_STATUS_OW),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RXDET_STATUS(PMA_CH3_REG_TX_RXDET_STATUS),  // 使能选项：开启或关闭。
                .PMA_REG_TX_PRBS_GEN_EN(PMA_CH3_REG_TX_PRBS_GEN_EN),  // 使能选项：开启或关闭。
                .PMA_REG_TX_PRBS_GEN_WIDTH_SEL               (PMA_CH3_REG_TX_PRBS_GEN_WIDTH_SEL                 ),// 位宽选项：8、10、16 或 20 位。
                .PMA_REG_TX_PRBS_SEL(PMA_CH3_REG_TX_PRBS_SEL),  // PRBS 多项式阶数：7、15、23、31。
                .PMA_REG_TX_UDP_DATA_7_TO_0(PMA_CH3_REG_TX_UDP_DATA_7_TO_0),  // 取值范围：0～255。
                .PMA_REG_TX_UDP_DATA_15_TO_8(PMA_CH3_REG_TX_UDP_DATA_15_TO_8),  // 取值范围：0～255。
                .PMA_REG_TX_UDP_DATA_19_TO_16(PMA_CH3_REG_TX_UDP_DATA_19_TO_16),  // 取值范围：0～15。
                .PMA_REG_TX_RESERVED_192(PMA_CH3_REG_TX_RESERVED_192),  // 使能选项：开启或关闭。
                .PMA_REG_TX_FIFO_WP_CTRL(PMA_CH3_REG_TX_FIFO_WP_CTRL),  // 取值范围：0～7。
                .PMA_REG_TX_FIFO_EN(PMA_CH3_REG_TX_FIFO_EN),  // 使能选项：开启或关闭。
                .PMA_REG_TX_DATA_MUX_SEL(PMA_CH3_REG_TX_DATA_MUX_SEL),  // 取值范围：0～3。
                .PMA_REG_TX_ERR_INSERT(PMA_CH3_REG_TX_ERR_INSERT),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RESERVED_203_200(PMA_CH3_REG_TX_RESERVED_203_200),  // 取值范围：0～15。
                .PMA_REG_TX_RESERVED_204(PMA_CH3_REG_TX_RESERVED_204),  // 使能选项：开启或关闭。
                .PMA_REG_TX_SATA_EN(PMA_CH3_REG_TX_SATA_EN),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RESERVED_207_206(PMA_CH3_REG_TX_RESERVED_207_206),  // 取值范围：0～3。
                .PMA_REG_RATE_CHANGE_TXPCLK_ON_OW            (PMA_CH3_REG_RATE_CHANGE_TXPCLK_ON_OW              ),// 使能选项：开启或关闭。
                .PMA_REG_RATE_CHANGE_TXPCLK_ON(PMA_CH3_REG_RATE_CHANGE_TXPCLK_ON),  // 使能选项：开启或关闭。
                .PMA_REG_TX_CFG_POST1(PMA_CH3_REG_TX_CFG_POST1),  // 取值范围：0～31。
                .PMA_REG_TX_CFG_POST2(PMA_CH3_REG_TX_CFG_POST2),  // 取值范围：0～31。
                .PMA_REG_TX_DEEMP(PMA_CH3_REG_TX_DEEMP),  // 取值范围：0～3。
                .PMA_REG_TX_DEEMP_OW(PMA_CH3_REG_TX_DEEMP_OW),  // 发送去加重控制
                .PMA_REG_TX_RESERVED_224_223(PMA_CH3_REG_TX_RESERVED_224_223),  // 取值范围：0～3。
                .PMA_REG_TX_RESERVED_225(PMA_CH3_REG_TX_RESERVED_225),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RESERVED_229_226(PMA_CH3_REG_TX_RESERVED_229_226),  // 取值范围：0～15。
                .PMA_REG_TX_OOB_DELAY_SEL(PMA_CH3_REG_TX_OOB_DELAY_SEL),  // 取值范围：0～15。
                .PMA_REG_TX_POLARITY(PMA_CH3_REG_TX_POLARITY),  // 极性选项：正常或反转。
                .PMA_REG_ANA_TX_JTAG_DATA_O_SEL              (PMA_CH3_REG_ANA_TX_JTAG_DATA_O_SEL                ),// 使能选项：开启或关闭。
                .PMA_REG_TX_RESERVED_236(PMA_CH3_REG_TX_RESERVED_236),  // 使能选项：开启或关闭。
                .PMA_REG_TX_LS_MODE_EN(PMA_CH3_REG_TX_LS_MODE_EN),  // 使能选项：开启或关闭。
                .PMA_REG_TX_JTAG_MODE_EN_OW(PMA_CH3_REG_TX_JTAG_MODE_EN_OW),  // 使能选项：开启或关闭。
                .PMA_REG_TX_JTAG_MODE_EN(PMA_CH3_REG_TX_JTAG_MODE_EN),  // 使能选项：开启或关闭。
                .PMA_REG_RX_JTAG_MODE_EN_OW(PMA_CH3_REG_RX_JTAG_MODE_EN_OW),  // 使能选项：开启或关闭。
                .PMA_REG_RX_JTAG_MODE_EN(PMA_CH3_REG_RX_JTAG_MODE_EN),  // 使能选项：开启或关闭。
                .PMA_REG_RX_JTAG_OE(PMA_CH3_REG_RX_JTAG_OE),  // 使能选项：开启或关闭。
                .PMA_REG_RX_ACJTAG_VHYSTSEL(PMA_CH3_REG_RX_ACJTAG_VHYSTSEL),  // 取值范围：0～7。
                .PMA_REG_TX_RES_CAL_EN(PMA_CH3_REG_TX_RES_CAL_EN),  // 使能选项：开启或关闭。
                .PMA_REG_RX_TERM_MODE_CTRL(PMA_CH3_REG_RX_TERM_MODE_CTRL),  // 接收终端控制范围：0～7。
                .PMA_REG_TX_RESERVED_251_250(PMA_CH3_REG_TX_RESERVED_251_250),  // 取值范围：0～7。
                .PMA_REG_PLPBK_TXPCLK_EN(PMA_CH3_REG_PLPBK_TXPCLK_EN),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RESERVED_253(PMA_CH3_REG_TX_RESERVED_253),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RESERVED_254(PMA_CH3_REG_TX_RESERVED_254),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RESERVED_255(PMA_CH3_REG_TX_RESERVED_255),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RESERVED_256(PMA_CH3_REG_TX_RESERVED_256),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RESERVED_257(PMA_CH3_REG_TX_RESERVED_257),  // 使能选项：开启或关闭。
                .PMA_REG_TX_PH_SEL(PMA_CH3_REG_TX_PH_SEL),  // 取值范围：0～63。
                .PMA_REG_TX_CFG_PRE(PMA_CH3_REG_TX_CFG_PRE),  // 取值范围：0～31。
                .PMA_REG_TX_CFG_MAIN(PMA_CH3_REG_TX_CFG_MAIN),  // 取值范围：0～63。
                .PMA_REG_CFG_POST(PMA_CH3_REG_CFG_POST),  // 取值范围：0～31。
                .PMA_REG_PD_MAIN(PMA_CH3_REG_PD_MAIN),  // 使能选项：开启或关闭。
                .PMA_REG_PD_PRE(PMA_CH3_REG_PD_PRE),  // 使能选项：开启或关闭。
                .PMA_REG_TX_LS_DATA(PMA_CH3_REG_TX_LS_DATA),  // 使能选项：开启或关闭。
                .PMA_REG_TX_DCC_BUF_SZ_SEL(PMA_CH3_REG_TX_DCC_BUF_SZ_SEL),  // 取值范围：0～3。
                .PMA_REG_TX_DCC_CAL_CUR_TUNE(PMA_CH3_REG_TX_DCC_CAL_CUR_TUNE),  // 取值范围：0～63。
                .PMA_REG_TX_DCC_CAL_EN(PMA_CH3_REG_TX_DCC_CAL_EN),  // 使能选项：开启或关闭。
                .PMA_REG_TX_DCC_CUR_SS(PMA_CH3_REG_TX_DCC_CUR_SS),  // 取值范围：0～3。
                .PMA_REG_TX_DCC_FA_CTRL(PMA_CH3_REG_TX_DCC_FA_CTRL),  // 使能选项：开启或关闭。
                .PMA_REG_TX_DCC_RI_CTRL(PMA_CH3_REG_TX_DCC_RI_CTRL),  // 使能选项：开启或关闭。
                .PMA_REG_ATB_SEL_2_TO_0(PMA_CH3_REG_ATB_SEL_2_TO_0),  // 取值范围：0～7。
                .PMA_REG_ATB_SEL_9_TO_3(PMA_CH3_REG_ATB_SEL_9_TO_3),  // 取值范围：0～127。
                .PMA_REG_TX_CFG_7_TO_0(PMA_CH3_REG_TX_CFG_7_TO_0),  // 取值范围：0～255。
                .PMA_REG_TX_CFG_15_TO_8(PMA_CH3_REG_TX_CFG_15_TO_8),  // 取值范围：0～255。
                .PMA_REG_TX_CFG_23_TO_16(PMA_CH3_REG_TX_CFG_23_TO_16),  // 取值范围：0～255。
                .PMA_REG_TX_CFG_31_TO_24(PMA_CH3_REG_TX_CFG_31_TO_24),  // 取值范围：0～255。
                .PMA_REG_TX_OOB_EI_EN(PMA_CH3_REG_TX_OOB_EI_EN),  // SATA 模式带外电气空闲使能
                .PMA_REG_TX_OOB_EI_EN_OW(PMA_CH3_REG_TX_OOB_EI_EN_OW),  // 使能选项：开启或关闭。
                .PMA_REG_TX_BEACON_EN_DELAYED(PMA_CH3_REG_TX_BEACON_EN_DELAYED),  // 使能选项：开启或关闭。
                .PMA_REG_TX_BEACON_EN_DELAYED_OW             (PMA_CH3_REG_TX_BEACON_EN_DELAYED_OW               ),// 使能选项：开启或关闭。
                .PMA_REG_TX_JTAG_DATA(PMA_CH3_REG_TX_JTAG_DATA),  // 使能选项：开启或关闭。
                .PMA_REG_TX_RXDET_TIMER_SEL(PMA_CH3_REG_TX_RXDET_TIMER_SEL),  // 取值范围：0～255。
                .PMA_REG_TX_CFG1_7_0(PMA_CH3_REG_TX_CFG1_7_0),  // 取值范围：0～255。
                .PMA_REG_TX_CFG1_15_8(PMA_CH3_REG_TX_CFG1_15_8),  // 取值范围：0～255。
                .PMA_REG_TX_CFG1_23_16(PMA_CH3_REG_TX_CFG1_23_16),  // 取值范围：0～255。
                .PMA_REG_TX_CFG1_31_24(PMA_CH3_REG_TX_CFG1_31_24),  // 取值范围：0～255。
                .PMA_REG_CFG_LANE_POWERUP(PMA_CH3_REG_CFG_LANE_POWERUP),  // PMA 通道上电控制
                .PMA_REG_CFG_TX_LANE_POWERUP_CLKPATH         (PMA_CH3_REG_CFG_TX_LANE_POWERUP_CLKPATH           ),// PMA 发送通道时钟路径上电控制
                .PMA_REG_CFG_TX_LANE_POWERUP_PISO            (PMA_CH3_REG_CFG_TX_LANE_POWERUP_PISO              ),// PMA 发送并串转换单元上电控制
                .PMA_REG_CFG_TX_LANE_POWERUP_DRIVER          (PMA_CH3_REG_CFG_TX_LANE_POWERUP_DRIVER            ) // PMA 发送驱动器上电控制
            ) U_GTP_HSSTLP_LANE3 (

                .P_TX_SDN           (P_TX_SDN_3),
                .P_TX_SDP           (P_TX_SDP_3),
                // SRB 相关信号
                .P_PCS_RX_MCB_STATUS(P_PCS_RX_MCB_STATUS_3),
                .P_PCS_LSM_SYNCED   (P_PCS_LSM_SYNCED_3),
                .P_CFG_READY        (P_CFG_READY_3),
                .P_CFG_RDATA        (P_CFG_RDATA_3),
                .P_CFG_INT          (P_CFG_INT_3),
                .P_RDATA            (P_RDATA_3),
                .P_RCLK2FABRIC      (P_RCLK2FABRIC_3),
                .P_TCLK2FABRIC      (P_TCLK2FABRIC_3),
                .P_RX_SIGDET_STATUS (P_RX_SIGDET_STATUS_3),
                .P_RX_SATA_COMINIT  (P_RX_SATA_COMINIT_3),
                .P_RX_SATA_COMWAKE  (P_RX_SATA_COMWAKE_3),
                .P_RX_LS_DATA       (P_RX_LS_DATA_3),
                .P_RX_READY         (P_RX_READY_3),
                .P_TEST_STATUS      (P_TEST_STATUS_3),
                .P_TX_RXDET_STATUS  (P_TX_RXDET_STATUS_3),
                .P_CA_ALIGN_RX      (P_CA_ALIGN_RX_3),
                .P_CA_ALIGN_TX      (P_CA_ALIGN_TX_3),

                .PMA_RCLK             (PMA_RCLK_3),
                .TXPCLK_PLL           (TXPCLK_PLL_3),
                // CIN 与 COUT 级联接口
                .LANE_COUT_BUS_FORWARD(LANE_COUT_BUS_FORWARD_3),
                .APATTERN_STATUS_COUT (APATTERN_STATUS_COUT_3),

                .P_RX_SDN            (P_RX_SDN_3),
                .P_RX_SDP            (P_RX_SDP_3),
                // SRB 相关信号
                .P_RX_CLK_FR_CORE    (P_RX_CLK_FR_CORE_3),
                .P_RCLK2_FR_CORE     (P_RCLK2_FR_CORE_3),
                .P_TX_CLK_FR_CORE    (P_TX_CLK_FR_CORE_3),
                .P_TCLK2_FR_CORE     (P_TCLK2_FR_CORE_3),
                .P_PCS_TX_RST        (P_PCS_TX_RST_3),
                .P_PCS_RX_RST        (P_PCS_RX_RST_3),
                .P_PCS_CB_RST        (P_PCS_CB_RST_3),
                .P_RXGEAR_SLIP       (P_RXGEAR_SLIP_3),
                .P_CFG_CLK           (P_CFG_CLK_3),
                .P_CFG_RST           (P_CFG_RST_3),
                .P_CFG_PSEL          (P_CFG_PSEL_3),
                .P_CFG_ENABLE        (P_CFG_ENABLE_3),
                .P_CFG_WRITE         (P_CFG_WRITE_3),
                .P_CFG_ADDR          (P_CFG_ADDR_3),
                .P_CFG_WDATA         (P_CFG_WDATA_3),
                .P_TDATA             (P_TDATA_3),
                .P_PCS_WORD_ALIGN_EN (P_PCS_WORD_ALIGN_EN_3),
                .P_RX_POLARITY_INVERT(P_RX_POLARITY_INVERT_3),
                .P_CEB_ADETECT_EN    (P_CEB_ADETECT_EN_3),
                .P_PCS_MCB_EXT_EN    (P_PCS_MCB_EXT_EN_3),
                .P_PCS_NEAREND_LOOP  (P_PCS_NEAREND_LOOP_3),
                .P_PCS_FAREND_LOOP   (P_PCS_FAREND_LOOP_3),
                .P_PMA_NEAREND_PLOOP (P_PMA_NEAREND_PLOOP_3),
                .P_PMA_NEAREND_SLOOP (P_PMA_NEAREND_SLOOP_3),
                .P_PMA_FAREND_PLOOP  (P_PMA_FAREND_PLOOP_3),

                .P_LANE_PD           (P_LANE_PD_3),
                .P_LANE_RST          (P_LANE_RST_3),
                .P_RX_LANE_PD        (P_RX_LANE_PD_3),
                .P_RX_PMA_RST        (P_RX_PMA_RST_3),
                .P_CTLE_ADP_RST      (P_CTLE_ADP_RST_3),
                .P_TX_DEEMP          (P_TX_DEEMP_3),
                .P_TX_LS_DATA        (P_TX_LS_DATA_3),
                .P_TX_BEACON_EN      (P_TX_BEACON_EN_3),
                .P_TX_SWING          (P_TX_SWING_3),
                .P_TX_RXDET_REQ      (P_TX_RXDET_REQ_3),
                .P_TX_RATE           (P_TX_RATE_3),
                .P_TX_BUSWIDTH       (P_TX_BUSWIDTH_3),
                .P_TX_MARGIN         (P_TX_MARGIN_3),
                .P_TX_PMA_RST        (P_TX_PMA_RST_3),
                .P_TX_LANE_PD_CLKPATH(P_TX_LANE_PD_CLKPATH_3),
                .P_TX_LANE_PD_PISO   (P_TX_LANE_PD_PISO_3),
                .P_TX_LANE_PD_DRIVER (P_TX_LANE_PD_DRIVER_3),
                .P_RX_RATE           (P_RX_RATE_3),
                .P_RX_BUSWIDTH       (P_RX_BUSWIDTH_3),
                .P_RX_HIGHZ          (P_RX_HIGHZ_3),
                .P_CIM_CLK_ALIGNER_RX(P_CIM_CLK_ALIGNER_RX_3),
                .P_CIM_CLK_ALIGNER_TX(P_CIM_CLK_ALIGNER_TX_3),
                .P_CIM_DYN_DLY_SEL_RX(P_CIM_DYN_DLY_SEL_RX_3),
                .P_CIM_DYN_DLY_SEL_TX(P_CIM_DYN_DLY_SEL_TX_3),
                .P_CIM_START_ALIGN_RX(P_CIM_START_ALIGN_RX_3),
                .P_CIM_START_ALIGN_TX(P_CIM_START_ALIGN_TX_3),
                // 扩展端口
                .MCB_RCLK            (MCB_RCLK_3),
                .SYNC                (SYNC_3),
                .RATE_CHANGE         (RATE_CHANGE_3),
                .PLL_LOCK_SEL        (PLL_LOCK_SEL_3),
                // CIN 与 COUT 级联接口
                .LANE_CIN_BUS_FORWARD(LANE_CIN_BUS_FORWARD_3),
                .APATTERN_STATUS_CIN (APATTERN_STATUS_CIN_3),
                // 来自 PLL
                .CLK_TXP             (CLK_TXP_3),
                .CLK_TXN             (CLK_TXN_3),
                .CLK_RX0             (CLK_RX0_3),
                .CLK_RX90            (CLK_RX90_3),
                .CLK_RX180           (CLK_RX180_3),
                .CLK_RX270           (CLK_RX270_3),
                .PLL_PD_I            (PLL_PD_I_3),
                .PLL_RESET_I         (PLL_RESET_I_3),
                .PLL_REFCLK_I        (PLL_REFCLK_I_3),
                .PLL_RES_TRIM_I      (PLL_RES_TRIM_I_3)
            );
        end else begin : CHANNEL3_NULL
            assign P_TX_SDN_3              = 1'b0;
            assign P_TX_SDP_3              = 1'b0;
            assign P_PCS_RX_MCB_STATUS_3   = 1'b0;
            assign P_PCS_LSM_SYNCED_3      = 1'b0;
            assign P_CFG_READY_3           = 1'b0;
            assign P_CFG_RDATA_3           = 8'b0;
            assign P_CFG_INT_3             = 1'b0;
            assign P_RDATA_3               = 47'b0;
            assign P_RCLK2FABRIC_3         = 1'b0;
            assign P_TCLK2FABRIC_3         = 1'b0;
            assign P_RX_SIGDET_STATUS_3    = 1'b0;
            assign P_RX_SATA_COMINIT_3     = 1'b0;
            assign P_RX_SATA_COMWAKE_3     = 1'b0;
            assign P_RX_LS_DATA_3          = 1'b0;
            assign P_RX_READY_3            = 1'b0;
            assign P_TEST_STATUS_3         = 20'b0;
            assign P_TX_RXDET_STATUS_3     = 1'b0;
            assign P_CA_ALIGN_RX_3         = 1'b0;
            assign P_CA_ALIGN_TX_3         = 1'b0;
            assign PMA_RCLK_3              = 1'b0;
            assign TXPCLK_PLL_3            = 1'b0;
            assign LANE_COUT_BUS_FORWARD_3 = 19'b0;
            assign APATTERN_STATUS_COUT_3  = 1'b0;
        end
    endgenerate

endmodule
