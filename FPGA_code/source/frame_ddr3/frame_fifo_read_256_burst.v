`timescale 1ns / 1ps
module frame_fifo_read_256_burst #(
    parameter MEM_DATA_BITS = 32,
    parameter ADDR_BITS     = 23,
    parameter BUSRT_BITS    = 10,
    parameter FIFO_DEPTH    = 256,
    parameter BURST_SIZE    = 16
) (
    input                         rst,
    input                         mem_clk,              // 外部存储控制器用户接口时钟
    output reg                    rd_burst_req,         // 向外部存储控制器发出突发读请求
    output reg [BUSRT_BITS - 1:0] rd_burst_len,         // 突发读长度，单位为数据拍而非字节
    output reg [ ADDR_BITS - 1:0] rd_burst_addr,        // 突发读基地址
    input                         rd_burst_data_valid,  // 外部存储控制器读数据有效
    input                         rd_burst_finish,      // 外部存储控制器突发读完成
    input                         read_req,             // 读请求保持有效，直到 read_req_ack 应答。
    output reg                    read_req_ack,         // 数据读取模块请求应答
    output                        read_finish,          // 数据读取模块请求完成
    input      [ ADDR_BITS - 1:0] read_addr_0,          // 读缓存 0 基地址，read_addr_index=0 时选用。
    input      [ ADDR_BITS - 1:0] read_addr_1,          // 读缓存 1 基地址，read_addr_index=1 时选用。
    input      [ ADDR_BITS - 1:0] read_addr_2,          // 读缓存 2 基地址，read_addr_index=2 时选用。
    input      [ ADDR_BITS - 1:0] read_addr_3,          // 读缓存 3 基地址，read_addr_index=3 时选用。
    input      [             1:0] read_addr_index,      // 根据读缓存编号选择四个基地址之一。
    input      [ ADDR_BITS - 1:0] read_len,             // 数据读取长度
    output reg                    fifo_aclr,            // FIFO 异步清零
    input      [            15:0] wrusedw               // FIFO 写端数据字数
);
    localparam ONE              = 256'd1;  // 256 位全 1 常量，可用 ONE[n-1:0] 取得低 n 位。
    localparam ZERO             = 256'd0;  // 256 位全 0 常量
    // 读状态编码
    localparam S_IDLE           = 0;       // 空闲状态，等待帧读取请求
    localparam S_ACK            = 1;       // 读请求应答
    localparam S_WAIT           = 2;
    localparam S_CHECK_FIFO     = 3;       // 检查 FIFO 剩余空间是否足够接收一次突发数据
    localparam S_READ_BURST     = 4;       // 开始一次突发读取
    localparam S_READ_BURST_END = 5;       // 一次突发读取完成
    localparam S_END            = 6;       // 一帧数据读取完成

    reg                   read_req_d0;  // 异步读请求同步到 mem_clk，第一级寄存。
    reg                   read_req_d1;  // 第二级同步
    reg                   read_req_d2;  // 第三级同步
    reg [ADDR_BITS - 1:0] read_len_d0;  // 读长度同步到 mem_clk，第一级寄存。
    reg [ADDR_BITS - 1:0] read_len_d1;  // 第二级同步
    reg [ADDR_BITS - 1:0] read_len_latch;  // 锁存读数据长度
    reg [ADDR_BITS - 1:0] read_cnt;  // 读数据计数
    reg [            3:0] state;  // 状态机
    reg [            1:0] read_addr_index_d0;  // 同步到 mem_clk 的第一级寄存器
    reg [            1:0] read_addr_index_d1;  // 同步到 mem_clk 的第二级寄存器
    reg [           15:0] wait_cnt;
    assign read_finish = (state == S_END) ? 1'b1 : 1'b0;  // S_END 状态产生读完成信号
    always @(posedge mem_clk or posedge rst) begin
        if (rst == 1'b1) begin
            read_req_d0    <=  1'b0;
            read_req_d1    <=  1'b0;
            read_req_d2    <=  1'b0;
            read_len_d0    <=  ZERO[ADDR_BITS - 1:0];
            read_len_d1    <=  ZERO[ADDR_BITS - 1:0];
            read_addr_index_d0 <= 2'b00;
            read_addr_index_d1 <= 2'b00;
        end else begin
            read_req_d0    <=  read_req;
            read_req_d1    <=  read_req_d0;
            read_req_d2    <=  read_req_d1;
            read_len_d0    <=  read_len;
            read_len_d1    <=  read_len_d0;
            read_addr_index_d0 <= read_addr_index;
            read_addr_index_d1 <= read_addr_index_d0;
        end
    end

    always @(posedge mem_clk or posedge rst) begin
        if (rst == 1'b1) begin
            state <= S_IDLE;
            read_len_latch <= ZERO[ADDR_BITS-1:0];
            rd_burst_addr <= ZERO[ADDR_BITS-1:0];
            rd_burst_req <= 1'b0;
            read_cnt <= ZERO[ADDR_BITS-1:0];
            fifo_aclr <= 1'b0;
            rd_burst_len <= ZERO[BUSRT_BITS-1:0];
            read_req_ack <= 1'b0;
            wait_cnt <= 16'd0;
        end else
            case (state)
                // 空闲等待读请求，read_req_d2 有效时进入 S_ACK。
                S_IDLE: begin
                    if (read_req_d2 == 1'b1) begin
                        state <= S_ACK;
                    end
                    read_req_ack <= 1'b0;
                end
                // S_ACK 完成请求应答、FIFO 复位、地址及数据长度锁存。
                S_ACK: begin
                    if (read_req_d2 == 1'b0) begin
                        state <= S_WAIT;
                        wait_cnt <= 16'd0;
                        fifo_aclr <= 1'b0;
                        read_req_ack <= 1'b0;
                    end else begin
                        // 读请求应答
                        read_req_ack <= 1'b1;
                        // FIFO 复位
                        fifo_aclr <= 1'b1;
                        // 根据读缓存编号选择四个基地址之一。
                        if (read_addr_index_d1 == 2'd0) rd_burst_addr <= read_addr_0;
                        else if (read_addr_index_d1 == 2'd1) rd_burst_addr <= read_addr_1;
                        else if (read_addr_index_d1 == 2'd2) rd_burst_addr <= read_addr_2;
                        else if (read_addr_index_d1 == 2'd3) rd_burst_addr <= read_addr_3;
                        // 锁存数据长度
                        read_len_latch <= read_len_d1;
                    end

                    read_cnt <= ZERO[ADDR_BITS-1:0];
                end
                S_WAIT: begin
                    if (wait_cnt >= 16'd200) begin
                        state <= S_CHECK_FIFO;
                    end else begin
                        wait_cnt <= wait_cnt + 16'd1;
                    end
                end
                S_CHECK_FIFO: begin
                    // 有新的读请求时进入 S_ACK。
                    if (read_req_d2 == 1'b1) begin
                        state <= S_ACK;
                    end  // FIFO 空间足够时进入突发读状态。
                    else if(wrusedw < 16'd160)  //当小于一次突发就请求突发  255*3
				begin
                        state <= S_READ_BURST;
                        rd_burst_len <= BURST_SIZE[BUSRT_BITS-1:0];
                        rd_burst_req <= 1'b1;
                    end
                end

                S_READ_BURST: begin
                    if (rd_burst_data_valid) rd_burst_req <= 1'b0;
                    // 突发结束
                    if (rd_burst_finish == 1'b1) begin
                        state <= S_READ_BURST_END;
                        // 读计数加上本次突发长度
                        read_cnt <= read_cnt + BURST_SIZE[ADDR_BITS-1:0];
                        // 计算下一次突发读地址
                        rd_burst_addr <= rd_burst_addr + BURST_SIZE[ADDR_BITS-1:0];
                    end
                end
                S_READ_BURST_END: begin
                    // 有新的读请求时进入 S_ACK。
                    if (read_req_d2 == 1'b1) begin
                        state <= S_ACK;
                    end  // 累计读取量小于帧长度时继续读取。
                         // 否则帧读取完成
                    else if (read_cnt < read_len_latch) begin
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
