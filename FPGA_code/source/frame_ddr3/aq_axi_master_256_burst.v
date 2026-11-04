module aq_axi_master_256_burst #(
    parameter DATA_WIDTH = 128
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

    // 本地总线
    input MASTER_RST,

    input                   WR_START,
    input  [          31:0] WR_ADRS,
    input  [          31:0] WR_LEN,
    output                  WR_READY,
    output                  WR_FIFO_RE,
    input                   WR_FIFO_EMPTY,
    input                   WR_FIFO_AEMPTY,
    input  [DATA_WIDTH-1:0] WR_FIFO_DATA,
    output                  WR_DONE,

    input                   RD_START,
    input  [          31:0] RD_ADRS,
    input  [          31:0] RD_LEN,
    output                  RD_READY,
    output                  RD_FIFO_WE,
    input                   RD_FIFO_FULL,
    input                   RD_FIFO_AFULL,
    output [DATA_WIDTH-1:0] RD_FIFO_DATA,
    output                  RD_DONE,

    output [31:0] DEBUG
);

    // 地址单位为字节，每次突发 16 拍，FIFO 同步读延迟为一周期。
    // 读写通道独立运行；预取数据保持在 WR_FIFO_DATA，直到当前写拍被接收。
    localparam BYTE_SHIFT = $clog2(DATA_WIDTH / 8);
    localparam BURST_BYTES = 16 * (DATA_WIDTH / 8);
    localparam IDLE = 0, PREFETCH = 1, ADDRESS = 2, DATA = 3, RESPONSE = 4, DONE = 5;
    reg [2:0] ws, rs;
    reg [31:0] wa, ra, wleft, rleft;
    reg [3:0] wb, rb;
    assign M_AXI_AWID = 0;
    assign M_AXI_AWADDR = wa;
    assign M_AXI_AWLEN = 15;
    assign M_AXI_AWSIZE = BYTE_SHIFT;
    assign M_AXI_AWBURST = 1;
    assign M_AXI_AWLOCK = 0;
    assign M_AXI_AWCACHE = 3;
    assign M_AXI_AWPROT = 0;
    assign M_AXI_AWQOS = 0;
    assign M_AXI_AWUSER = 1;
    assign M_AXI_AWVALID = (ws == ADDRESS);
    assign M_AXI_WDATA = WR_FIFO_DATA;
    assign M_AXI_WSTRB = {DATA_WIDTH / 8{1'b1}};
    assign M_AXI_WLAST = (wb == 15);
    assign M_AXI_WUSER = 1;
    assign M_AXI_WVALID = (ws == DATA);
    assign M_AXI_BREADY = (ws == RESPONSE);
    assign WR_READY = (ws == IDLE);
    assign WR_DONE = (ws == DONE);
    assign WR_FIFO_RE = ((ws == PREFETCH) && !WR_FIFO_EMPTY) || ((ws == DATA) && M_AXI_WREADY && wleft > 1);
    always @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            ws <= IDLE;
            wa <= 0;
            wleft <= 0;
            wb <= 0;
        end else if (MASTER_RST) begin
            ws <= IDLE;
            wa <= 0;
            wleft <= 0;
            wb <= 0;
        end else
            case (ws)
                IDLE:
                if (WR_START) begin
                    wa <= WR_ADRS;
                    wleft <= WR_LEN >> BYTE_SHIFT;
                    wb <= 0;
                    ws <= PREFETCH;
                end
                PREFETCH: if (!WR_FIFO_EMPTY) ws <= ADDRESS;
                ADDRESS: if (M_AXI_AWREADY) ws <= DATA;
                DATA:
                if (M_AXI_WREADY) begin
                    wleft <= wleft - 1;
                    if (wb == 15) begin
                        wb <= 0;
                        ws <= RESPONSE;
                    end else wb <= wb + 1'b1;
                end
                RESPONSE:
                if (M_AXI_BVALID) begin
                    if (wleft == 0) ws <= DONE;
                    else begin
                        wa <= wa + BURST_BYTES;
                        ws <= ADDRESS;
                    end
                end
                DONE: ws <= IDLE;
                default: ws <= IDLE;
            endcase
    end
    assign M_AXI_ARID = 0;
    assign M_AXI_ARADDR = ra;
    assign M_AXI_ARLEN = 15;
    assign M_AXI_ARSIZE = BYTE_SHIFT;
    assign M_AXI_ARBURST = 1;
    assign M_AXI_ARLOCK = 0;
    assign M_AXI_ARCACHE = 3;
    assign M_AXI_ARPROT = 0;
    assign M_AXI_ARQOS = 0;
    assign M_AXI_ARUSER = 1;
    assign M_AXI_ARVALID = (rs == ADDRESS);
    assign M_AXI_RREADY = (rs == DATA) && !RD_FIFO_FULL;
    assign RD_READY = (rs == IDLE);
    assign RD_DONE = (rs == DONE);
    assign RD_FIFO_WE = M_AXI_RVALID && M_AXI_RREADY;
    assign RD_FIFO_DATA = M_AXI_RDATA;
    always @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            rs <= IDLE;
            ra <= 0;
            rleft <= 0;
            rb <= 0;
        end else if (MASTER_RST) begin
            rs <= IDLE;
            ra <= 0;
            rleft <= 0;
            rb <= 0;
        end else
            case (rs)
                IDLE:
                if (RD_START) begin
                    ra <= RD_ADRS;
                    rleft <= RD_LEN >> BYTE_SHIFT;
                    rb <= 0;
                    rs <= ADDRESS;
                end
                ADDRESS: if (M_AXI_ARREADY) rs <= DATA;
                DATA:
                if (M_AXI_RVALID && M_AXI_RREADY) begin
                    rleft <= rleft - 1;
                    if (rb == 15) begin
                        rb <= 0;
                        if (rleft == 1) rs <= DONE;
                        else begin
                            ra <= ra + BURST_BYTES;
                            rs <= ADDRESS;
                        end
                    end else rb <= rb + 1'b1;
                end
                DONE: rs <= IDLE;
                default: rs <= IDLE;
            endcase
    end
    assign DEBUG = {20'd0, ws, rs, wb, 2'd0};
endmodule

// 按字节寻址，每次 AXI 突发 16 拍，FIFO 读延迟为一周期。
// 地址握手前先预取，仅在当前写数据被接收时推进 FIFO。

