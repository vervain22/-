
//---------------------------------------------------

// Copyright (c) 2019 PANGO MICROSYSTEMS, INC
// ALL RIGHTS REVERVED.

// THE SOURCE CODE CONTAINED HEREIN IS PROPRIETARY TO PANGO MICROSYSTEMS, INC.
// IT SHALL NOT BE REPRODUCED OR DISCLOSED IN WHOLE OR IN PART OR USED BY
// PARTIES WITHOUT WRITTEN AUTHORIZATION FROM THE OWNER.

//---------------------------------------------------

//---------------------------------------------------

module ipm2l_fifo_ctrl_v1_1_afifo_128i_128o_512 #(
    parameter c_WR_DEPTH_WIDTH   = 9,
    parameter c_RD_DEPTH_WIDTH   = 9,
    parameter c_FIFO_TYPE        = "ASYN",
    parameter c_ALMOST_FULL_NUM  = 508,
    parameter c_ALMOST_EMPTY_NUM = 4
) (
    input  wire                          wclk,
    input  wire                          w_en,
    output wire [c_WR_DEPTH_WIDTH-1 : 0] waddr,
    input  wire                          wrst,
    output wire                          wfull,
    output wire                          almost_full,
    output reg  [  c_WR_DEPTH_WIDTH : 0] wr_water_level,

    input  wire                          rclk,
    input  wire                          r_en,
    output wire [c_RD_DEPTH_WIDTH-1 : 0] raddr,
    input  wire                          rrst,
    output wire                          rempty,
    output reg  [  c_RD_DEPTH_WIDTH : 0] rd_water_level,
    output wire                          almost_empty
);

    //---------------------------------------------------
    // 内部信号声明
    // 写地址操作信号
    // 写指针
    reg  [c_WR_DEPTH_WIDTH : 0] wptr  /* synthesis syn_preserve=1 */;
    // 读时钟域到写时钟域的第一级同步
    reg  [c_RD_DEPTH_WIDTH : 0] wrptr1  /* synthesis syn_preserve=1 */;
    reg  [c_RD_DEPTH_WIDTH : 0] wrptr2;  // 读时钟域到写时钟域的第二级同步
    reg  [c_WR_DEPTH_WIDTH : 0] wbin;  // 当前二进制写指针
    reg  [c_WR_DEPTH_WIDTH : 0] wbnext;  // 下一二进制写指针
    reg  [c_WR_DEPTH_WIDTH : 0] wgnext;  // 下一格雷码写指针
    reg                         waddr_msb;  // 写地址最高位

    // 读地址操作信号
    // 读指针
    reg  [c_RD_DEPTH_WIDTH : 0] rptr  /* synthesis syn_preserve=1 */;
    // 写时钟域到读时钟域的第一级同步
    reg  [c_WR_DEPTH_WIDTH : 0] rwptr1  /* synthesis syn_preserve=1 */;
    reg  [c_WR_DEPTH_WIDTH : 0] rwptr2;  // 写时钟域到读时钟域的第二级同步
    reg  [c_RD_DEPTH_WIDTH : 0] rbin;  // 当前二进制读指针
    reg  [c_RD_DEPTH_WIDTH : 0] rbnext;  // 下一二进制读指针
    reg  [c_RD_DEPTH_WIDTH : 0] rgnext;  // 下一格雷码读指针
    reg                         raddr_msb;  // 读地址最高位

    reg  [c_RD_DEPTH_WIDTH : 0] wrptr2_b;  // 同步写指针转为二进制
    reg  [c_WR_DEPTH_WIDTH : 0] rwptr2_b;  // 同步读指针转为二进制

    reg                         asyn_wfull;
    reg                         asyn_almost_full;
    reg                         asyn_rempty;
    reg                         asyn_almost_empty;
    reg                         syn_wfull;
    reg                         syn_almost_full;
    reg                         syn_rempty;
    reg                         syn_almost_empty;

    wire [  c_WR_DEPTH_WIDTH:0] wwptr;
    wire [  c_WR_DEPTH_WIDTH:0] wrptr;
    wire [  c_RD_DEPTH_WIDTH:0] rwptr;
    wire [  c_RD_DEPTH_WIDTH:0] rrptr;

    // 主逻辑
    //---------------------------------------------------
    generate
        if (c_FIFO_TYPE == "ASYN") begin : ASYN_CTRL
            // 生成格雷码写指针

            always @(*) begin
                if (!wfull) wbnext = wbin + w_en;
                else wbnext = wbin;
            end

            always @(*) begin
                wgnext = (wbnext >> 1) ^ wbnext;  // 二进制转格雷码
            end

            always @(posedge wclk or posedge wrst) begin
                if (wrst) begin
                    wptr <= 0;
                    waddr_msb <= 0;
                    wbin <= 0;
                end else begin
                    wptr <= wgnext;
                    wbin <= wbnext;
                    waddr_msb <= wgnext[c_WR_DEPTH_WIDTH] ^ wgnext[c_WR_DEPTH_WIDTH-1];
                end
            end

            // 读时钟域到写时钟域同步
            always @(posedge wclk or posedge wrst) begin
                if (wrst) {wrptr2, wrptr1} <= 0;
                else {wrptr2, wrptr1} <= {wrptr1, rptr};
            end

            integer i;
            always @(*) begin
                for (i = 0; i <= c_RD_DEPTH_WIDTH; i = i + 1)  // 格雷码转二进制
                wrptr2_b[i] = ^(wrptr2 >> i);
            end

            // 生成 FIFO 写满标志

            //---------------------------------------------------
            // 生成格雷码读指针

            always @(*) begin
                if (!rempty) rbnext = rbin + r_en;
                else rbnext = rbin;
                rgnext = (rbnext >> 1) ^ rbnext;  // 二进制转格雷码
            end

            always @(posedge rclk or posedge rrst) begin
                if (rrst) begin
                    rptr <= 0;
                    raddr_msb <= 0;
                    rbin <= 0;
                end else begin
                    rptr <= rgnext;
                    rbin <= rbnext;
                    raddr_msb <= rgnext[c_RD_DEPTH_WIDTH] ^ rgnext[c_RD_DEPTH_WIDTH-1];
                end
            end

            // 读时钟域到写时钟域同步
            always @(posedge rclk or posedge rrst) begin
                if (rrst) {rwptr2, rwptr1} <= 0;
                else {rwptr2, rwptr1} <= {rwptr1, wptr};
            end

            always @(*) begin
                for (i = 0; i <= c_WR_DEPTH_WIDTH; i = i + 1)  // 格雷码转二进制
                rwptr2_b[i] = ^(rwptr2 >> i);
            end

            if (c_WR_DEPTH_WIDTH > c_RD_DEPTH_WIDTH) begin
                assign wwptr = wbnext;
                assign wrptr = {wrptr2_b, {(c_WR_DEPTH_WIDTH - c_RD_DEPTH_WIDTH) {1'b0}}};
                assign rwptr = rwptr2_b[c_WR_DEPTH_WIDTH:c_WR_DEPTH_WIDTH-c_RD_DEPTH_WIDTH];
                assign rrptr = rbnext;
            end else begin
                assign wwptr = wbnext;
                assign wrptr = wrptr2_b[c_RD_DEPTH_WIDTH:c_RD_DEPTH_WIDTH-c_WR_DEPTH_WIDTH];
                assign rwptr = {rwptr2_b, {(c_RD_DEPTH_WIDTH - c_WR_DEPTH_WIDTH) {1'b0}}};
                assign rrptr = rbnext;
            end

            // 生成异步 FIFO 写满标志
            always @(posedge wclk or posedge wrst) begin
                if (wrst) asyn_wfull <= 1'b0;
                else
                    asyn_wfull <= ((wwptr[c_WR_DEPTH_WIDTH] != wrptr[c_WR_DEPTH_WIDTH])
                            && (wwptr[c_WR_DEPTH_WIDTH-1:0] == wrptr[c_WR_DEPTH_WIDTH-1:0]));
            end

            // 生成异步 FIFO 读空标志
            always @(posedge rclk or posedge rrst) begin
                if (rrst) asyn_rempty <= 1'b1;
                else asyn_rempty <= (rrptr == rwptr);
            end
        end else begin : SYN_CTRL
            // 写操作
            always @(*) begin
                if (!wfull) wbnext = wptr + w_en;
                else wbnext = wptr;
            end

            always @(*) begin
                wgnext = wbnext;  // 同步 FIFO
            end

            always @(posedge wclk or posedge wrst) begin
                if (wrst) begin
                    wptr <= 0;
                    waddr_msb <= 0;
                    wbin <= 0;
                end else begin
                    wptr <= wgnext;
                    wbin <= wbnext;
                    waddr_msb <= wgnext[c_WR_DEPTH_WIDTH-1];
                end
            end

            always @(*) begin
                wrptr2 = rptr;  // 同步 FIFO
            end

            always @(*) begin
                wrptr2_b = rptr;  // 同步 FIFO
            end

            // 生成 FIFO 写满标志

            //---------------------------------------------------
            // 读操作
            always @(*) begin
                if (!rempty) rbnext = rptr + r_en;
                else rbnext = rptr;
            end

            always @(*) begin
                rgnext = rbnext;
            end

            always @(posedge rclk or posedge rrst) begin
                if (rrst) begin
                    rptr <= 0;
                    raddr_msb <= 0;
                    rbin <= 0;
                end else begin
                    rptr <= rgnext;
                    rbin <= rbnext;
                    raddr_msb <= rgnext[c_RD_DEPTH_WIDTH-1];
                end
            end

            always @(*) begin
                rwptr2 = wptr;  // 同步 FIFO
            end

            always @(*) begin
                rwptr2_b = wptr;  // 同步 FIFO
            end
            // 生成同步 FIFO 写满标志
            if (c_WR_DEPTH_WIDTH > c_RD_DEPTH_WIDTH) begin
                assign wwptr = wbnext;
                assign wrptr = {rbnext, {(c_WR_DEPTH_WIDTH - c_RD_DEPTH_WIDTH) {1'b0}}};
                assign rwptr = wbnext[c_WR_DEPTH_WIDTH:c_WR_DEPTH_WIDTH-c_RD_DEPTH_WIDTH];
                assign rrptr = rbnext;
            end else begin
                assign wwptr = wbnext;
                assign wrptr = rbnext[c_RD_DEPTH_WIDTH:c_RD_DEPTH_WIDTH-c_WR_DEPTH_WIDTH];
                assign rwptr = {wbnext, {(c_RD_DEPTH_WIDTH - c_WR_DEPTH_WIDTH) {1'b0}}};
                assign rrptr = rbnext;
            end
            always @(posedge wclk or posedge wrst) begin
                if (wrst) syn_wfull <= 1'b0;
                else
                    syn_wfull <= ((wwptr[c_WR_DEPTH_WIDTH] != wrptr[c_WR_DEPTH_WIDTH])
                           && (wwptr[c_WR_DEPTH_WIDTH-1:0] == wrptr[c_WR_DEPTH_WIDTH-1:0]));
            end

            // 生成同步 FIFO 读空标志
            always @(posedge rclk or posedge rrst) begin
                if (rrst) syn_rempty <= 1'b1;
                else syn_rempty <= (rwptr == rrptr);
            end
        end
    endgenerate

    // 生成存储写地址
    assign waddr = wbin[c_WR_DEPTH_WIDTH-1:0];

    // 生成 FIFO 写满标志
    assign wfull = (c_FIFO_TYPE == "ASYN") ? asyn_wfull : syn_wfull;

    // 生成 FIFO 将满标志
    assign almost_full = (wr_water_level >= c_ALMOST_FULL_NUM) ? 1'b1 : 1'b0;
    // 生成写端水位标志
    always @(posedge wclk or posedge wrst) begin
        if (wrst) wr_water_level <= 'b0;
        else
            wr_water_level <= ( wwptr[c_WR_DEPTH_WIDTH]==0 && wrptr[c_WR_DEPTH_WIDTH]==0 ) ? (wwptr[c_WR_DEPTH_WIDTH-1:0] - wrptr[c_WR_DEPTH_WIDTH-1:0])     :
                          ( wwptr[c_WR_DEPTH_WIDTH]==0 && wrptr[c_WR_DEPTH_WIDTH]==1 ) ? ({1'b1,wwptr[c_WR_DEPTH_WIDTH-1:0]} - wrptr[c_WR_DEPTH_WIDTH-1:0] ):
                          ( wwptr[c_WR_DEPTH_WIDTH]==1 && wrptr[c_WR_DEPTH_WIDTH]==0 ) ? (wwptr[c_WR_DEPTH_WIDTH :0] - wrptr[c_WR_DEPTH_WIDTH-1:0])      :
                          ( wwptr[c_WR_DEPTH_WIDTH-1:0] - wrptr[c_WR_DEPTH_WIDTH-1:0]) ;
    end

    // 生成存储读地址
    assign raddr = rbin[c_RD_DEPTH_WIDTH-1:0];

    // 生成 FIFO 读空标志
    assign rempty = (c_FIFO_TYPE == "ASYN") ? asyn_rempty : syn_rempty;

    // 生成 FIFO 将空标志
    assign almost_empty = (rd_water_level <= c_ALMOST_EMPTY_NUM) ? 1'b1 : 1'b0;

    // 生成读端水位标志
    always @(posedge rclk or posedge rrst) begin
        if (rrst) rd_water_level <= 'b0;
        else
            rd_water_level <= ( rwptr[c_RD_DEPTH_WIDTH]==0 && rrptr[c_RD_DEPTH_WIDTH]==0 ) ? (rwptr[c_RD_DEPTH_WIDTH-1:0] - rrptr[c_RD_DEPTH_WIDTH-1:0])     :
                          ( rwptr[c_RD_DEPTH_WIDTH]==0 && rrptr[c_RD_DEPTH_WIDTH]==1 ) ? ({1'b1,rwptr[c_RD_DEPTH_WIDTH-1:0]} - rrptr[c_RD_DEPTH_WIDTH-1:0] ):
                          ( rwptr[c_RD_DEPTH_WIDTH]==1 && rrptr[c_RD_DEPTH_WIDTH]==0 ) ? (rwptr[c_RD_DEPTH_WIDTH :0] - rrptr[c_RD_DEPTH_WIDTH-1:0])      :
                          ( rwptr[c_RD_DEPTH_WIDTH-1:0] - rrptr[c_RD_DEPTH_WIDTH-1:0]);
    end

endmodule
