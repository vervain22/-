
//---------------------------------------------------

// Copyright (c) 2019 PANGO MICROSYSTEMS, INC
// ALL RIGHTS REVERVED.

// THE SOURCE CODE CONTAINED HEREIN IS PROPRIETARY TO PANGO MICROSYSTEMS, INC.
// IT SHALL NOT BE REPRODUCED OR DISCLOSED IN WHOLE OR IN PART OR USED BY
// PARTIES WITHOUT WRITTEN AUTHORIZATION FROM THE OWNER.

//---------------------------------------------------

//---------------------------------------------------

module afifo_16i_128o_512 (

    wr_clk,
    wr_rst,

    wr_en,
    wr_data,
    wr_full,

    wr_water_level,

    rd_clk,
    rd_rst,

    rd_en,
    rd_data,

    almost_full,
    rd_empty,

    rd_water_level,

    almost_empty
);

    localparam CAS_MODE          = "36K";                                       // @IPC enum 18K,36K,64K

    localparam POWER_OPT         = 0;                                           // @IPC bool

    localparam RESET_TYPE        = "ASYNC";                                     // @IPC enum SYNC,ASYNC

    localparam FIFO_TYPE         = "ASYN_FIFO";                                 // @IPC enum SYN_FIFO,ASYN_FIFO

    localparam SAMEWIDTH_EN      = 0;                                           // @IPC bool

    localparam WR_BYTE_EN        = 0;                                           // @IPC bool

    localparam BYTE_SIZE         = 8;                                           // @IPC enum 8,9

    localparam WR_DEPTH_WIDTH    = 12;                                          // @IPC int 9,20

    localparam WR_DATA_WIDTH     = 16;                                          // @IPC int 1,1152

    localparam BE_WIDTH          = 1;                                           // @IPC int 1,128

    localparam RD_DEPTH_WIDTH    = 9;                                           // @IPC int 9,20

    localparam RD_DATA_WIDTH     = 128;                                         // @IPC int 1,1152

    localparam RD_BE_WIDTH       = 1;                                           // @IPC int 1,128

    localparam OUTPUT_REG        = 0;                                           // @IPC bool

    localparam RD_OCE_EN         = 0;                                           // @IPC bool

    localparam RD_CLK_OR_POL_INV = 0;                                           // @IPC bool

    localparam FAB_REG           = 0;                                           // @IPC bool

    localparam FULL_WL_EN        = 1;                                           // @IPC bool

    localparam EMPTY_WL_EN       = 1;                                           // @IPC bool

    localparam ASYN_FIFO_EN      = "1";                                         // @IPC bool

    localparam ALMOST_FULL_NUM   = 4092;                                        // @IPC int

    localparam ALMOST_EMPTY_NUM  = 4;                                           // @IPC int

    localparam RST_VAL_EN        = 0;                                           // @IPC bool

    localparam FIFO_TYPE_SEL     = (FIFO_TYPE == "SYN_FIFO") ? "SYN" : "ASYN";

    input [WR_DATA_WIDTH-1 : 0] wr_data;
    input wr_en;

    input wr_clk;
    input wr_rst;

    output wr_full;

    output almost_full;

    output [WR_DEPTH_WIDTH : 0] wr_water_level;

    output [RD_DATA_WIDTH-1 : 0] rd_data;
    input rd_en;

    input rd_clk;
    input rd_rst;

    output rd_empty;

    output almost_empty;

    output [RD_DEPTH_WIDTH : 0] rd_water_level;

    wire [WR_DATA_WIDTH-1 : 0] wr_data;
    wire                       wr_en;
    wire                       wr_clk;
    wire                       wr_full;
    wire                       wr_rst;
    wire [     BE_WIDTH-1 : 0] wr_byte_en;
    wire                       almost_full;
    wire [ WR_DEPTH_WIDTH : 0] wr_water_level;
    wire [RD_DATA_WIDTH-1 : 0] rd_data;
    wire                       rd_en;
    wire                       rd_clk;
    wire                       rd_empty;
    wire                       rd_rst;
    wire                       rd_oce;
    wire                       rd_oce_mux2d;
    wire                       rd_oce_mux2f;
    wire                       almost_empty;
    wire [ RD_DEPTH_WIDTH : 0] rd_water_level;

    wire [       BE_WIDTH-1:0] wr_byte_en_mux;
    wire                       rd_oce_mux;

    wire [RD_DATA_WIDTH-1 : 0] rd_data_d;
    reg  [RD_DATA_WIDTH-1 : 0] fab_reg_invt;
    reg  [RD_DATA_WIDTH-1 : 0] fab_reg;

    assign wr_byte_en_mux = (WR_BYTE_EN == 1) ? wr_byte_en : {BE_WIDTH{1'b1}};
    assign rd_oce_mux2d   = ((FAB_REG       == 1) && (OUTPUT_REG == 1)) ? 1 :
                         (OUTPUT_REG    == 1) ? ((RD_OCE_EN  == 1)  ? rd_oce : 1'b1) : 1'b0 ;
    assign rd_oce_mux2f = (FAB_REG == 1) ? ((RD_OCE_EN == 1) ? rd_oce : 1'b1) : 1'b0;

    // 简单双口 RAM 实例
    ipm2l_fifo_v1_10_afifo_16i_128o_512 #(
        .c_CAS_MODE(CAS_MODE),
        .c_WR_DEPTH_WIDTH(WR_DEPTH_WIDTH),  // FIFO 地址位宽范围：9～20。
        .c_WR_DATA_WIDTH     (WR_DATA_WIDTH         ),    // 写位宽为 1～1152；启用字节使能时取 2 的整数次幂或其 9 倍。
        .c_RD_DEPTH_WIDTH(RD_DEPTH_WIDTH),  // 读地址位宽参数范围：1～20。
        .c_RD_DATA_WIDTH     (RD_DATA_WIDTH         ),    // 读位宽为 1～1152；启用字节使能时取 2 的整数次幂或其 9 倍。
        .c_OUTPUT_REG(OUTPUT_REG),
        .c_RD_OCE_EN(RD_OCE_EN),
        .c_FAB_REG(FAB_REG),
        .c_RESET_TYPE(RESET_TYPE),  // 复位类型：异步置位同步释放、同步复位或异步复位。
        .c_POWER_OPT(POWER_OPT),  // 工作模式：0 普通模式，1 低功耗模式。
        .c_RD_CLK_OR_POL_INV(RD_CLK_OR_POL_INV),  // 输出寄存器时钟极性反转，取值 0 或 1。
        .c_WR_BYTE_EN(WR_BYTE_EN),  // 字节写使能，取值 0 或 1。
        .c_BE_WIDTH(BE_WIDTH),  // 字节位宽范围：1～128。
        .c_FIFO_TYPE(FIFO_TYPE_SEL),  // FIFO 类型：SYN 同步，ASYN 异步。
        .c_ALMOST_FULL_NUM(ALMOST_FULL_NUM),  // 将满阈值
        .c_ALMOST_EMPTY_NUM(ALMOST_EMPTY_NUM)  // 将满阈值
    ) U_ipm2l_fifo_afifo_16i_128o_512 (

        .wr_clk(wr_clk),
        .wr_rst(wr_rst),

        .wr_en         (wr_en),
        .wr_data       (wr_data),
        .wr_full       (wr_full),
        .wr_byte_en    (wr_byte_en_mux),
        .almost_full   (almost_full),
        .wr_water_level(wr_water_level),

        .rd_clk(rd_clk),
        .rd_rst(rd_rst),

        .rd_en(rd_en),

        .rd_data(rd_data),

        .rd_oce        (rd_oce_mux2d),
        .rd_empty      (rd_empty),
        .almost_empty  (almost_empty),
        .rd_water_level(rd_water_level)
    );

    generate
        if (FAB_REG == 1) begin

            assign rd_data = (FAB_REG == 1) ? ((RD_CLK_OR_POL_INV == 1) ? fab_reg_invt : fab_reg) : rd_data_d;
            if (RD_CLK_OR_POL_INV == 1) begin

                always @(negedge rd_clk or posedge rd_rst) begin
                    if (rd_rst) fab_reg_invt <= {RD_DATA_WIDTH{1'b0}};
                    else if (rd_oce_mux2f) fab_reg_invt <= rd_data_d;
                end
            end else begin

                always @(posedge rd_clk or posedge rd_rst) begin
                    if (rd_rst) fab_reg <= {RD_DATA_WIDTH{1'b0}};
                    else if (rd_oce_mux2f) fab_reg <= rd_data_d;
                end
            end
        end
    endgenerate

endmodule
