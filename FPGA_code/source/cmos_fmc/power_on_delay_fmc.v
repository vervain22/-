`timescale 1ns / 1ps
//---------------------------------------------------

//---------------------------------------------------
// 摄像头上电时序
module power_on_delay_fmc (
    input  clk_50M,
    input  reset_n,
    output camera1_rstn,
    output camera2_rstn,
    output camera_pwnd,
    output initial_en
);
    reg [18:0] cnt1;
    reg [15:0] cnt2;
    reg [19:0] cnt3;
    reg initial_en;
    reg camera_rstn_reg;
    reg camera_pwnd_reg;

    assign camera1_rstn = camera_rstn_reg;
    assign camera2_rstn = camera_rstn_reg;
    assign camera_pwnd  = camera_pwnd_reg;

    // 电源稳定后等待 5 ms，再拉低 PWDN。
    always @(posedge clk_50M) begin
        if (reset_n == 1'b0) begin
            cnt1 <= 0;
            camera_pwnd_reg <= 1'b1;  // 1'b1
        end else if (cnt1 < 19'h40000) begin
            cnt1 <= cnt1 + 1'b1;
            camera_pwnd_reg <= 1'b1;
        end else camera_pwnd_reg <= 1'b0;
    end

    // PWDN 拉低后等待 1.3 ms，再拉高 RESETB。
    always @(posedge clk_50M) begin
        if (camera_pwnd_reg == 1) begin
            cnt2 <= 0;
            camera_rstn_reg <= 1'b0;
        end else if (cnt2 < 16'hffff) begin
            cnt2 <= cnt2 + 1'b1;
            camera_rstn_reg <= 1'b0;
        end else camera_rstn_reg <= 1'b1;
    end

    // RESETB 拉高后等待 21 ms，再启动 SCCB 初始化。
    always @(posedge clk_50M) begin
        if (camera_rstn_reg == 0) begin
            cnt3 <= 0;
            initial_en <= 1'b0;
        end else if (cnt3 < 20'hfffff) begin
            cnt3 <= cnt3 + 1'b1;
            initial_en <= 1'b0;
        end else initial_en <= 1'b1;
    end

endmodule
