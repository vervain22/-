`timescale 1ns / 1ps
module frame_fifo_write_256_burst #(
    parameter MEM_DATA_BITS = 32,
    parameter ADDR_BITS     = 23,
    parameter BUSRT_BITS    = 10,
    parameter BURST_SIZE    = 128
) (
    input                         rst,
    input                         mem_clk,            // 外部存储控制器用户接口时钟
    output reg                    wr_burst_req,       // 向外部存储控制器发出突发写请求
    output reg [BUSRT_BITS - 1:0] wr_burst_len,       // 突发写长度，单位为数据拍而非字节
    output reg [ ADDR_BITS - 1:0] wr_burst_addr,      // 突发写基地址
    input                         wr_burst_data_req,  // 外部存储控制器提前一周期请求写数据
    input                         wr_burst_finish,    // 外部存储控制器突发写完成
    input                         write_req,          // 写请求保持有效，直到写请求应答。
    output reg                    write_req_ack,      // 数据写入模块请求应答
    output                        write_finish,       // 数据写入模块请求完成
    input      [ ADDR_BITS - 1:0] write_addr_0,       // 写缓存 0 基地址，write_addr_index=0 时选用。
    input      [ ADDR_BITS - 1:0] write_addr_1,       // 写缓存 1 基地址，write_addr_index=1 时选用。
    input      [ ADDR_BITS - 1:0] write_addr_2,       // 写缓存 2 基地址，write_addr_index=2 时选用。
    input      [ ADDR_BITS - 1:0] write_addr_3,       // 写缓存 3 基地址，write_addr_index=3 时选用。
    input      [             1:0] write_addr_index,   // 根据写缓存编号选择四个基地址之一。
    input      [ ADDR_BITS - 1:0] write_len,          // 数据写入长度
    output reg                    fifo_aclr,          // FIFO 异步清零
    input      [            15:0] rdusedw             // FIFO 读端数据字数
);
    localparam ONE               = 256'd1;  // 256 位全 1 常量，可用 ONE[n-1:0] 取得低 n 位。
    localparam ZERO              = 256'd0;  // 256 位全 0 常量
    // 写状态编码
    localparam S_IDLE            = 0;       // 空闲状态，等待写请求
    localparam S_ACK             = 1;       // 写请求应答
    localparam S_CHECK_FIFO      = 2;       // 检查 FIFO 数据是否足够发起一次突发写入
    localparam S_WRITE_BURST     = 3;       // 开始一次突发写入
    localparam S_WRITE_BURST_END = 4;       // 一次突发写入完成
    localparam S_END             = 5;       // 一帧数据写入完成

    (* ASYNC_REG="TRUE" *)reg                   write_req_d0;  // 第一级跨域同步寄存器
    (* ASYNC_REG="TRUE" *)reg                   write_req_d1;
    (* ASYNC_REG="TRUE" *)reg                   write_req_d2;
    reg [ADDR_BITS - 1:0] write_len_d0;  // 写长度同步到 mem_clk，第一级寄存。
    reg [ADDR_BITS - 1:0] write_len_d1;  // 第二级同步
    reg [ADDR_BITS - 1:0] write_len_latch;  // 锁存写数据长度
    reg [ADDR_BITS - 1:0] write_cnt;  // 写数据计数
    reg [            1:0] write_addr_index_d0;
    reg [            1:0] write_addr_index_d1;
    reg [            3:0] state;  // 状态机

    assign write_finish = (state == S_END) ? 1'b1 : 1'b0;  // S_END 状态产生写完成信号
    always @(posedge mem_clk or posedge rst) begin
        if (rst == 1'b1) begin
            write_req_d0    <=  1'b0;
            write_req_d1    <=  1'b0;
            write_req_d2    <=  1'b0;
            write_len_d0    <=  ZERO[ADDR_BITS - 1:0];
            write_len_d1    <=  ZERO[ADDR_BITS - 1:0];
            write_addr_index_d0    <=  2'b00;
            write_addr_index_d1    <=  2'b00;
        end else begin
            write_req_d0    <=  write_req;
            write_req_d1    <=  write_req_d0;
            write_req_d2    <=  write_req_d1;
            write_len_d0    <=  write_len;
            write_len_d1    <=  write_len_d0;
            write_addr_index_d0 <= write_addr_index;
            write_addr_index_d1 <= write_addr_index_d0;
        end
    end

    always @(posedge mem_clk or posedge rst) begin
        if (rst == 1'b1) begin
            state <= S_IDLE;
            write_len_latch <= ZERO[ADDR_BITS-1:0];
            wr_burst_addr <= ZERO[ADDR_BITS-1:0];
            wr_burst_req <= 1'b0;
            write_cnt <= ZERO[ADDR_BITS-1:0];
            fifo_aclr <= 1'b0;
            write_req_ack <= 1'b0;
            wr_burst_len <= ZERO[BUSRT_BITS-1:0];
        end else
            case (state)
                // 空闲等待写请求，write_req_d2 有效时进入 S_ACK。
                S_IDLE: begin
                    if (write_req_d2 == 1'b1) begin
                        state <= S_ACK;
                    end
                    write_req_ack <= 1'b0;
                end
                // S_ACK 完成请求应答、FIFO 复位、地址及数据长度锁存。
                S_ACK: begin
                    // 写请求撤销后进入 S_CHECK_FIFO，并撤销 write_req_ack。
                    if (write_req_d2 == 1'b0) begin
                        state <= S_CHECK_FIFO;
                        fifo_aclr <= 1'b0;
                        write_req_ack <= 1'b0;
                    end else begin
                        // 写请求应答
                        write_req_ack <= 1'b1;
                        // FIFO 复位
                        fifo_aclr <= 1'b1;
                        // 根据写缓存编号选择四个基地址之一。
                        if (write_addr_index_d1 == 2'd0) wr_burst_addr <= write_addr_0;
                        else if (write_addr_index_d1 == 2'd1) wr_burst_addr <= write_addr_1;
                        else if (write_addr_index_d1 == 2'd2) wr_burst_addr <= write_addr_2;
                        else if (write_addr_index_d1 == 2'd3) wr_burst_addr <= write_addr_3;
                        // 锁存数据长度
                        write_len_latch <= write_len_d1;
                    end

                    write_cnt <= ZERO[ADDR_BITS-1:0];
                end
                S_CHECK_FIFO: begin
                    // 有新的写请求时进入 S_ACK。
                    if (write_req_d2 == 1'b1) begin
                        state <= S_ACK;
                    end  // FIFO 数据足够时进入突发写状态。
                    else if (rdusedw >= BURST_SIZE) begin
                        state <= S_WRITE_BURST;
                        wr_burst_len <= BURST_SIZE[BUSRT_BITS-1:0];
                        wr_burst_req <= 1'b1;
                    end
                end

                S_WRITE_BURST: begin
                    // 突发结束
                    if (wr_burst_finish == 1'b1) begin
                        wr_burst_req <= 1'b0;
                        state <= S_WRITE_BURST_END;
                        // 写计数加上本次突发长度
                        write_cnt <= write_cnt + BURST_SIZE[ADDR_BITS-1:0];
                        // 计算下一次突发写地址
                        wr_burst_addr <= wr_burst_addr + BURST_SIZE[ADDR_BITS-1:0];
                    end
                end
                S_WRITE_BURST_END: begin
                    // 有新的写请求时进入 S_ACK。
                    if (write_req_d2 == 1'b1) begin
                        state <= S_ACK;
                    end  // 累计写入量小于帧长度时继续写入。
                         // 否则帧写入完成
                    else if (write_cnt < write_len_latch) begin
                        state <= S_CHECK_FIFO;
                    end else begin
                        state <= S_END;
                    end
                end
                S_END: begin
                    state <= S_IDLE;
                end
                default: state <= S_IDLE;
            endcase
    end
endmodule
