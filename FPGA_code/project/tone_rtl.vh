
`ifndef TONE_STREAM_INCLUDED
`define TONE_STREAM_INCLUDED
`timescale 1ns / 1ps
// 轻度暗部提升：RGB565 扩展为 RGB888，三通道共用 Q10 增益，舍入后量化。
// 随像素传输的元数据只作延迟，内容保持不变。
// 五级流水：最大分量、查表、乘积、字节舍入、RGB565 输出。
module tone_stream #(
    parameter DATA_WIDTH = 32
) (
    input clk,
    rst_n,
    in_vs,
    in_valid,
    input [DATA_WIDTH-1:0] in_data,
    output out_vs,
    out_valid,
    output [DATA_WIDTH-1:0] out_data
);
    function [10:0] gain_lut;
        input [7:0] v;
        begin
            case (v)
                8'd0: gain_lut = 11'd1152;
                8'd1: gain_lut = 11'd1151;
                8'd2: gain_lut = 11'd1149;
                8'd3: gain_lut = 11'd1148;
                8'd4: gain_lut = 11'd1147;
                8'd5: gain_lut = 11'd1145;
                8'd6: gain_lut = 11'd1144;
                8'd7: gain_lut = 11'd1143;
                8'd8: gain_lut = 11'd1142;
                8'd9: gain_lut = 11'd1140;
                8'd10: gain_lut = 11'd1139;
                8'd11: gain_lut = 11'd1138;
                8'd12: gain_lut = 11'd1137;
                8'd13: gain_lut = 11'd1135;
                8'd14: gain_lut = 11'd1134;
                8'd15: gain_lut = 11'd1133;
                8'd16: gain_lut = 11'd1132;
                8'd17: gain_lut = 11'd1130;
                8'd18: gain_lut = 11'd1129;
                8'd19: gain_lut = 11'd1128;
                8'd20: gain_lut = 11'd1127;
                8'd21: gain_lut = 11'd1126;
                8'd22: gain_lut = 11'd1124;
                8'd23: gain_lut = 11'd1123;
                8'd24: gain_lut = 11'd1122;
                8'd25: gain_lut = 11'd1121;
                8'd26: gain_lut = 11'd1120;
                8'd27: gain_lut = 11'd1119;
                8'd28: gain_lut = 11'd1117;
                8'd29: gain_lut = 11'd1116;
                8'd30: gain_lut = 11'd1115;
                8'd31: gain_lut = 11'd1114;
                8'd32: gain_lut = 11'd1113;
                8'd33: gain_lut = 11'd1112;
                8'd34: gain_lut = 11'd1111;
                8'd35: gain_lut = 11'd1110;
                8'd36: gain_lut = 11'd1109;
                8'd37: gain_lut = 11'd1107;
                8'd38: gain_lut = 11'd1106;
                8'd39: gain_lut = 11'd1105;
                8'd40: gain_lut = 11'd1104;
                8'd41: gain_lut = 11'd1103;
                8'd42: gain_lut = 11'd1102;
                8'd43: gain_lut = 11'd1101;
                8'd44: gain_lut = 11'd1100;
                8'd45: gain_lut = 11'd1099;
                8'd46: gain_lut = 11'd1098;
                8'd47: gain_lut = 11'd1097;
                8'd48: gain_lut = 11'd1096;
                8'd49: gain_lut = 11'd1095;
                8'd50: gain_lut = 11'd1094;
                8'd51: gain_lut = 11'd1093;
                8'd52: gain_lut = 11'd1092;
                8'd53: gain_lut = 11'd1091;
                8'd54: gain_lut = 11'd1090;
                8'd55: gain_lut = 11'd1089;
                8'd56: gain_lut = 11'd1088;
                8'd57: gain_lut = 11'd1087;
                8'd58: gain_lut = 11'd1086;
                8'd59: gain_lut = 11'd1085;
                8'd60: gain_lut = 11'd1085;
                8'd61: gain_lut = 11'd1084;
                8'd62: gain_lut = 11'd1083;
                8'd63: gain_lut = 11'd1082;
                8'd64: gain_lut = 11'd1081;
                8'd65: gain_lut = 11'd1080;
                8'd66: gain_lut = 11'd1079;
                8'd67: gain_lut = 11'd1078;
                8'd68: gain_lut = 11'd1077;
                8'd69: gain_lut = 11'd1077;
                8'd70: gain_lut = 11'd1076;
                8'd71: gain_lut = 11'd1075;
                8'd72: gain_lut = 11'd1074;
                8'd73: gain_lut = 11'd1073;
                8'd74: gain_lut = 11'd1072;
                8'd75: gain_lut = 11'd1072;
                8'd76: gain_lut = 11'd1071;
                8'd77: gain_lut = 11'd1070;
                8'd78: gain_lut = 11'd1069;
                8'd79: gain_lut = 11'd1068;
                8'd80: gain_lut = 11'd1068;
                8'd81: gain_lut = 11'd1067;
                8'd82: gain_lut = 11'd1066;
                8'd83: gain_lut = 11'd1065;
                8'd84: gain_lut = 11'd1065;
                8'd85: gain_lut = 11'd1064;
                8'd86: gain_lut = 11'd1063;
                8'd87: gain_lut = 11'd1062;
                8'd88: gain_lut = 11'd1062;
                8'd89: gain_lut = 11'd1061;
                8'd90: gain_lut = 11'd1060;
                8'd91: gain_lut = 11'd1059;
                8'd92: gain_lut = 11'd1059;
                8'd93: gain_lut = 11'd1058;
                8'd94: gain_lut = 11'd1057;
                8'd95: gain_lut = 11'd1057;
                8'd96: gain_lut = 11'd1056;
                8'd97: gain_lut = 11'd1055;
                8'd98: gain_lut = 11'd1055;
                8'd99: gain_lut = 11'd1054;
                8'd100: gain_lut = 11'd1053;
                8'd101: gain_lut = 11'd1053;
                8'd102: gain_lut = 11'd1052;
                8'd103: gain_lut = 11'd1052;
                8'd104: gain_lut = 11'd1051;
                8'd105: gain_lut = 11'd1050;
                8'd106: gain_lut = 11'd1050;
                8'd107: gain_lut = 11'd1049;
                8'd108: gain_lut = 11'd1049;
                8'd109: gain_lut = 11'd1048;
                8'd110: gain_lut = 11'd1047;
                8'd111: gain_lut = 11'd1047;
                8'd112: gain_lut = 11'd1046;
                8'd113: gain_lut = 11'd1046;
                8'd114: gain_lut = 11'd1045;
                8'd115: gain_lut = 11'd1045;
                8'd116: gain_lut = 11'd1044;
                8'd117: gain_lut = 11'd1044;
                8'd118: gain_lut = 11'd1043;
                8'd119: gain_lut = 11'd1043;
                8'd120: gain_lut = 11'd1042;
                8'd121: gain_lut = 11'd1042;
                8'd122: gain_lut = 11'd1041;
                8'd123: gain_lut = 11'd1041;
                8'd124: gain_lut = 11'd1040;
                8'd125: gain_lut = 11'd1040;
                8'd126: gain_lut = 11'd1039;
                8'd127: gain_lut = 11'd1039;
                8'd128: gain_lut = 11'd1038;
                8'd129: gain_lut = 11'd1038;
                8'd130: gain_lut = 11'd1037;
                8'd131: gain_lut = 11'd1037;
                8'd132: gain_lut = 11'd1037;
                8'd133: gain_lut = 11'd1036;
                8'd134: gain_lut = 11'd1036;
                8'd135: gain_lut = 11'd1035;
                8'd136: gain_lut = 11'd1035;
                8'd137: gain_lut = 11'd1035;
                8'd138: gain_lut = 11'd1034;
                8'd139: gain_lut = 11'd1034;
                8'd140: gain_lut = 11'd1033;
                8'd141: gain_lut = 11'd1033;
                8'd142: gain_lut = 11'd1033;
                8'd143: gain_lut = 11'd1032;
                8'd144: gain_lut = 11'd1032;
                8'd145: gain_lut = 11'd1032;
                8'd146: gain_lut = 11'd1031;
                8'd147: gain_lut = 11'd1031;
                8'd148: gain_lut = 11'd1031;
                8'd149: gain_lut = 11'd1030;
                8'd150: gain_lut = 11'd1030;
                8'd151: gain_lut = 11'd1030;
                8'd152: gain_lut = 11'd1030;
                8'd153: gain_lut = 11'd1029;
                8'd154: gain_lut = 11'd1029;
                8'd155: gain_lut = 11'd1029;
                8'd156: gain_lut = 11'd1029;
                8'd157: gain_lut = 11'd1028;
                8'd158: gain_lut = 11'd1028;
                8'd159: gain_lut = 11'd1028;
                8'd160: gain_lut = 11'd1028;
                8'd161: gain_lut = 11'd1027;
                8'd162: gain_lut = 11'd1027;
                8'd163: gain_lut = 11'd1027;
                8'd164: gain_lut = 11'd1027;
                8'd165: gain_lut = 11'd1027;
                8'd166: gain_lut = 11'd1026;
                8'd167: gain_lut = 11'd1026;
                8'd168: gain_lut = 11'd1026;
                8'd169: gain_lut = 11'd1026;
                8'd170: gain_lut = 11'd1026;
                8'd171: gain_lut = 11'd1026;
                8'd172: gain_lut = 11'd1025;
                8'd173: gain_lut = 11'd1025;
                8'd174: gain_lut = 11'd1025;
                8'd175: gain_lut = 11'd1025;
                8'd176: gain_lut = 11'd1025;
                8'd177: gain_lut = 11'd1025;
                8'd178: gain_lut = 11'd1025;
                8'd179: gain_lut = 11'd1025;
                8'd180: gain_lut = 11'd1025;
                8'd181: gain_lut = 11'd1024;
                8'd182: gain_lut = 11'd1024;
                8'd183: gain_lut = 11'd1024;
                8'd184: gain_lut = 11'd1024;
                8'd185: gain_lut = 11'd1024;
                8'd186: gain_lut = 11'd1024;
                8'd187: gain_lut = 11'd1024;
                8'd188: gain_lut = 11'd1024;
                8'd189: gain_lut = 11'd1024;
                8'd190: gain_lut = 11'd1024;
                8'd191: gain_lut = 11'd1024;
                8'd192: gain_lut = 11'd1024;
                8'd193: gain_lut = 11'd1024;
                8'd194: gain_lut = 11'd1024;
                8'd195: gain_lut = 11'd1024;
                8'd196: gain_lut = 11'd1024;
                8'd197: gain_lut = 11'd1024;
                8'd198: gain_lut = 11'd1024;
                8'd199: gain_lut = 11'd1024;
                8'd200: gain_lut = 11'd1024;
                8'd201: gain_lut = 11'd1024;
                8'd202: gain_lut = 11'd1024;
                8'd203: gain_lut = 11'd1024;
                8'd204: gain_lut = 11'd1024;
                8'd205: gain_lut = 11'd1024;
                8'd206: gain_lut = 11'd1024;
                8'd207: gain_lut = 11'd1024;
                8'd208: gain_lut = 11'd1024;
                8'd209: gain_lut = 11'd1024;
                8'd210: gain_lut = 11'd1024;
                8'd211: gain_lut = 11'd1024;
                8'd212: gain_lut = 11'd1024;
                8'd213: gain_lut = 11'd1024;
                8'd214: gain_lut = 11'd1024;
                8'd215: gain_lut = 11'd1024;
                8'd216: gain_lut = 11'd1024;
                8'd217: gain_lut = 11'd1024;
                8'd218: gain_lut = 11'd1024;
                8'd219: gain_lut = 11'd1024;
                8'd220: gain_lut = 11'd1024;
                8'd221: gain_lut = 11'd1024;
                8'd222: gain_lut = 11'd1024;
                8'd223: gain_lut = 11'd1024;
                8'd224: gain_lut = 11'd1024;
                8'd225: gain_lut = 11'd1024;
                8'd226: gain_lut = 11'd1024;
                8'd227: gain_lut = 11'd1024;
                8'd228: gain_lut = 11'd1024;
                8'd229: gain_lut = 11'd1024;
                8'd230: gain_lut = 11'd1024;
                8'd231: gain_lut = 11'd1024;
                8'd232: gain_lut = 11'd1024;
                8'd233: gain_lut = 11'd1024;
                8'd234: gain_lut = 11'd1024;
                8'd235: gain_lut = 11'd1024;
                8'd236: gain_lut = 11'd1024;
                8'd237: gain_lut = 11'd1024;
                8'd238: gain_lut = 11'd1024;
                8'd239: gain_lut = 11'd1024;
                8'd240: gain_lut = 11'd1024;
                8'd241: gain_lut = 11'd1024;
                8'd242: gain_lut = 11'd1024;
                8'd243: gain_lut = 11'd1024;
                8'd244: gain_lut = 11'd1024;
                8'd245: gain_lut = 11'd1024;
                8'd246: gain_lut = 11'd1024;
                8'd247: gain_lut = 11'd1024;
                8'd248: gain_lut = 11'd1024;
                8'd249: gain_lut = 11'd1024;
                8'd250: gain_lut = 11'd1024;
                8'd251: gain_lut = 11'd1024;
                8'd252: gain_lut = 11'd1024;
                8'd253: gain_lut = 11'd1024;
                8'd254: gain_lut = 11'd1024;
                8'd255: gain_lut = 11'd1024;
                default: gain_lut = 11'd1024;
            endcase
        end
    endfunction
    wire [7:0] r = {in_data[15:11], in_data[15:13]};
    wire [7:0] g = {in_data[10:5], in_data[10:9]};
    wire [7:0] b = {in_data[4:0], in_data[4:2]};
    wire [7:0] rgmax = r > g ? r : g;
    reg [7:0] vmax, r0, g0, b0, r1, g1, b1;
    reg [10:0] gain;
    reg [18:0] pr, pg, pb;
    reg [7:0] rr, gg, bb;
    reg [15:0] pixel;
    reg [4:0] valid_pipe, vs_pipe;
    reg [DATA_WIDTH-1:0] side[0:4];
    integer k;
    always @(posedge clk) begin
        if (!rst_n) begin
            vmax <= 0;
            r0 <= 0;
            g0 <= 0;
            b0 <= 0;
            r1 <= 0;
            g1 <= 0;
            b1 <= 0;
            gain <= 1024;
            pr <= 0;
            pg <= 0;
            pb <= 0;
            rr <= 0;
            gg <= 0;
            bb <= 0;
            pixel <= 0;
            valid_pipe <= 0;
            vs_pipe <= 0;
            for (k = 0; k < 5; k = k + 1) side[k] <= 0;
        end else begin
            valid_pipe <= {valid_pipe[3:0], in_valid};
            vs_pipe <= {vs_pipe[3:0], in_vs};
            side[0] <= in_data;
            for (k = 1; k < 5; k = k + 1) side[k] <= side[k-1];
            vmax <= rgmax > b ? rgmax : b;
            r0 <= r;
            g0 <= g;
            b0 <= b;
            gain <= gain_lut(vmax);
            r1 <= r0;
            g1 <= g0;
            b1 <= b0;
            pr <= r1 * gain;
            pg <= g1 * gain;
            pb <= b1 * gain;
            rr <= (pr + 19'd512) >> 10;
            gg <= (pg + 19'd512) >> 10;
            bb <= (pb + 19'd512) >> 10;
            pixel <= {rr[7:3], gg[7:2], bb[7:3]};
        end
    end
    // 掩码与或运算兼容 DATA_WIDTH=16，避免零宽度位选。
    assign out_data = (side[4] & ~{{(DATA_WIDTH - 16) {1'b0}}, 16'hffff}) | {{(DATA_WIDTH - 16) {1'b0}}, pixel};
    assign out_valid = valid_pipe[4];
    assign out_vs = vs_pipe[4];
endmodule

`timescale 1ns / 1ps
// 以中心像素为基准作 3×3 有限亮度细节增强，按有效像素推进坐标，不填补空缺。
// 首尾行、首尾列保持原值，最后一行在消隐期间输出。
// 16 位附加信息与中心像素同步传递，不作修改。
module detail_stream #(
    parameter WIDTH = 640,
    HEIGHT = 360
) (
    input clk,
    rst_n,
    in_vs,
    in_valid,
    input [31:0] in_data,
    output reg out_vs,
    output out_valid,
    output [31:0] out_data
);
    localparam TOTAL = WIDTH * HEIGHT, DELAY = WIDTH + 1, DEPTH = WIDTH + 2;
    localparam XBITS = $clog2(WIDTH), PBITS = $clog2(DEPTH);
    // 三组行缓存轮转读写，避免使用同地址读写的未定义数据。
    reg [7:0] bank0[0:WIDTH-1]  /* synthesis syn_ramstyle = "block_ram" */;
    reg [7:0] bank1[0:WIDTH-1]  /* synthesis syn_ramstyle = "block_ram" */;
    reg [7:0] bank2[0:WIDTH-1]  /* synthesis syn_ramstyle = "block_ram" */;
    reg [39:0] center_fifo[0:DEPTH-1]  /* synthesis syn_ramstyle = "block_ram" */;
    reg [XBITS-1:0] x;
    reg [19:0] n;
    reg [PBITS-1:0] wp, rp;
    reg [1:0] bank;
    reg active;
    reg [7:0] a1, a2, b1, b2, c1, c2;
    wire [7:0] r = {in_data[15:11], in_data[15:13]};
    wire [7:0] g = {in_data[10:5], in_data[10:9]};
    wire [7:0] b = {in_data[4:0], in_data[4:2]};
    wire [15:0] luma_sum = 16'd77 * r + 16'd150 * g + 16'd29 * b;
    wire [7:0] yy = luma_sum[15:8];
    wire step = active && ((n < TOTAL && in_valid) || (n >= TOTAL && n < TOTAL + DELAY));
    reg [7:0] q0, q1, q2, qy;
    reg [39:0] qc;
    reg [ 1:0] qb;
    reg read_valid, read_emit, read_edge;
    wire [7:0] prev1 = qb == 0 ? q2 : (qb == 1 ? q0 : q1);
    wire [7:0] prev2 = qb == 0 ? q1 : (qb == 1 ? q2 : q0);
    // RAM 端口同步读写且不复位内容；读数据寄存一级，隔开地址选择与窗口累加。
    always @(posedge clk) begin
        if (rst_n && !in_vs && step) begin
            if (bank == 0) bank0[x] <= yy;
            if (bank == 1) bank1[x] <= yy;
            if (bank == 2) bank2[x] <= yy;
            q0 <= bank0[x];
            q1 <= bank1[x];
            q2 <= bank2[x];
            center_fifo[wp] <= {yy, in_data};
            qc <= center_fifo[rp];
        end
    end
    // 16 进制逐位除以 9，输入范围 0～143，输出余数与商。
    // 用两级小查找表替代长组合除法器。
    function [7:0] div9_digit;
        input [7:0] value;
        begin
            case (value)
                8'd0: div9_digit = 8'h00;
                8'd1: div9_digit = 8'h10;
                8'd2: div9_digit = 8'h20;
                8'd3: div9_digit = 8'h30;
                8'd4: div9_digit = 8'h40;
                8'd5: div9_digit = 8'h50;
                8'd6: div9_digit = 8'h60;
                8'd7: div9_digit = 8'h70;
                8'd8: div9_digit = 8'h80;
                8'd9: div9_digit = 8'h01;
                8'd10: div9_digit = 8'h11;
                8'd11: div9_digit = 8'h21;
                8'd12: div9_digit = 8'h31;
                8'd13: div9_digit = 8'h41;
                8'd14: div9_digit = 8'h51;
                8'd15: div9_digit = 8'h61;
                8'd16: div9_digit = 8'h71;
                8'd17: div9_digit = 8'h81;
                8'd18: div9_digit = 8'h02;
                8'd19: div9_digit = 8'h12;
                8'd20: div9_digit = 8'h22;
                8'd21: div9_digit = 8'h32;
                8'd22: div9_digit = 8'h42;
                8'd23: div9_digit = 8'h52;
                8'd24: div9_digit = 8'h62;
                8'd25: div9_digit = 8'h72;
                8'd26: div9_digit = 8'h82;
                8'd27: div9_digit = 8'h03;
                8'd28: div9_digit = 8'h13;
                8'd29: div9_digit = 8'h23;
                8'd30: div9_digit = 8'h33;
                8'd31: div9_digit = 8'h43;
                8'd32: div9_digit = 8'h53;
                8'd33: div9_digit = 8'h63;
                8'd34: div9_digit = 8'h73;
                8'd35: div9_digit = 8'h83;
                8'd36: div9_digit = 8'h04;
                8'd37: div9_digit = 8'h14;
                8'd38: div9_digit = 8'h24;
                8'd39: div9_digit = 8'h34;
                8'd40: div9_digit = 8'h44;
                8'd41: div9_digit = 8'h54;
                8'd42: div9_digit = 8'h64;
                8'd43: div9_digit = 8'h74;
                8'd44: div9_digit = 8'h84;
                8'd45: div9_digit = 8'h05;
                8'd46: div9_digit = 8'h15;
                8'd47: div9_digit = 8'h25;
                8'd48: div9_digit = 8'h35;
                8'd49: div9_digit = 8'h45;
                8'd50: div9_digit = 8'h55;
                8'd51: div9_digit = 8'h65;
                8'd52: div9_digit = 8'h75;
                8'd53: div9_digit = 8'h85;
                8'd54: div9_digit = 8'h06;
                8'd55: div9_digit = 8'h16;
                8'd56: div9_digit = 8'h26;
                8'd57: div9_digit = 8'h36;
                8'd58: div9_digit = 8'h46;
                8'd59: div9_digit = 8'h56;
                8'd60: div9_digit = 8'h66;
                8'd61: div9_digit = 8'h76;
                8'd62: div9_digit = 8'h86;
                8'd63: div9_digit = 8'h07;
                8'd64: div9_digit = 8'h17;
                8'd65: div9_digit = 8'h27;
                8'd66: div9_digit = 8'h37;
                8'd67: div9_digit = 8'h47;
                8'd68: div9_digit = 8'h57;
                8'd69: div9_digit = 8'h67;
                8'd70: div9_digit = 8'h77;
                8'd71: div9_digit = 8'h87;
                8'd72: div9_digit = 8'h08;
                8'd73: div9_digit = 8'h18;
                8'd74: div9_digit = 8'h28;
                8'd75: div9_digit = 8'h38;
                8'd76: div9_digit = 8'h48;
                8'd77: div9_digit = 8'h58;
                8'd78: div9_digit = 8'h68;
                8'd79: div9_digit = 8'h78;
                8'd80: div9_digit = 8'h88;
                8'd81: div9_digit = 8'h09;
                8'd82: div9_digit = 8'h19;
                8'd83: div9_digit = 8'h29;
                8'd84: div9_digit = 8'h39;
                8'd85: div9_digit = 8'h49;
                8'd86: div9_digit = 8'h59;
                8'd87: div9_digit = 8'h69;
                8'd88: div9_digit = 8'h79;
                8'd89: div9_digit = 8'h89;
                8'd90: div9_digit = 8'h0a;
                8'd91: div9_digit = 8'h1a;
                8'd92: div9_digit = 8'h2a;
                8'd93: div9_digit = 8'h3a;
                8'd94: div9_digit = 8'h4a;
                8'd95: div9_digit = 8'h5a;
                8'd96: div9_digit = 8'h6a;
                8'd97: div9_digit = 8'h7a;
                8'd98: div9_digit = 8'h8a;
                8'd99: div9_digit = 8'h0b;
                8'd100: div9_digit = 8'h1b;
                8'd101: div9_digit = 8'h2b;
                8'd102: div9_digit = 8'h3b;
                8'd103: div9_digit = 8'h4b;
                8'd104: div9_digit = 8'h5b;
                8'd105: div9_digit = 8'h6b;
                8'd106: div9_digit = 8'h7b;
                8'd107: div9_digit = 8'h8b;
                8'd108: div9_digit = 8'h0c;
                8'd109: div9_digit = 8'h1c;
                8'd110: div9_digit = 8'h2c;
                8'd111: div9_digit = 8'h3c;
                8'd112: div9_digit = 8'h4c;
                8'd113: div9_digit = 8'h5c;
                8'd114: div9_digit = 8'h6c;
                8'd115: div9_digit = 8'h7c;
                8'd116: div9_digit = 8'h8c;
                8'd117: div9_digit = 8'h0d;
                8'd118: div9_digit = 8'h1d;
                8'd119: div9_digit = 8'h2d;
                8'd120: div9_digit = 8'h3d;
                8'd121: div9_digit = 8'h4d;
                8'd122: div9_digit = 8'h5d;
                8'd123: div9_digit = 8'h6d;
                8'd124: div9_digit = 8'h7d;
                8'd125: div9_digit = 8'h8d;
                8'd126: div9_digit = 8'h0e;
                8'd127: div9_digit = 8'h1e;
                8'd128: div9_digit = 8'h2e;
                8'd129: div9_digit = 8'h3e;
                8'd130: div9_digit = 8'h4e;
                8'd131: div9_digit = 8'h5e;
                8'd132: div9_digit = 8'h6e;
                8'd133: div9_digit = 8'h7e;
                8'd134: div9_digit = 8'h8e;
                8'd135: div9_digit = 8'h0f;
                8'd136: div9_digit = 8'h1f;
                8'd137: div9_digit = 8'h2f;
                8'd138: div9_digit = 8'h3f;
                8'd139: div9_digit = 8'h4f;
                8'd140: div9_digit = 8'h5f;
                8'd141: div9_digit = 8'h6f;
                8'd142: div9_digit = 8'h7f;
                8'd143: div9_digit = 8'h8f;
                default: div9_digit = 8'd0;
            endcase
        end
    endfunction
    reg [9:0] sa, sb, sc;
    reg [11:0] total;
    reg [ 7:0] mean;
    reg [31:0] side0, side1, side2, side3, side4, side5, side6, side7;
    reg  [7:0] div_mid;
    reg  [3:0] div_low;
    wire [7:0] div_last = div9_digit({div_mid[7:4], div_low});
    reg [7:0] y0, y1, y2, y3;
    reg edge0, edge1, edge2, edge3;
    reg signed [4:0] delta3;
    reg [7:0] valids;
    integer d, mag;
    // 细节增量限制在 ±4，先求三通道公共余量并限幅，再分级相加。
    wire [7:0] r4 = {side4[15:11], side4[15:13]};
    wire [7:0] g4 = {side4[10:5], side4[10:9]};
    wire [7:0] b4 = {side4[4:0], side4[4:2]};
    wire [2:0] ru = r4 > 251 ? ~r4[2:0] : 3'd4;
    wire [2:0] gu = g4 > 251 ? ~g4[2:0] : 3'd4;
    wire [2:0] bu = b4 > 251 ? ~b4[2:0] : 3'd4;
    wire [2:0] rl = r4 < 4 ? r4[2:0] : 3'd4;
    wire [2:0] gl = g4 < 4 ? g4[2:0] : 3'd4;
    wire [2:0] bl = b4 < 4 ? b4[2:0] : 3'd4;
    wire [2:0] u_rg = ru < gu ? ru : gu, l_rg = rl < gl ? rl : gl;
    reg [2:0] upper5, lower5;
    reg signed [4:0] delta5, delta6;
    wire signed [4:0] upper_limit = $signed({2'b0, upper5});
    wire signed [4:0] lower_limit = -$signed({2'b0, lower5});
    wire signed [8:0] change = {{4{delta6[4]}}, delta6};
    wire signed [8:0] r_out = $signed({1'b0, side6[15:11], side6[15:13]}) + change;
    wire signed [8:0] g_out = $signed({1'b0, side6[10:5], side6[10:9]}) + change;
    wire signed [8:0] b_out = $signed({1'b0, side6[4:0], side6[4:2]}) + change;
    always @(posedge clk) begin
        if (!rst_n || in_vs) begin
            x <= 0;
            n <= 0;
            wp <= 0;
            rp <= 1;
            bank <= 0;
            active <= rst_n && in_vs;
            read_valid <= 0;
            read_emit <= 0;
            read_edge <= 1;
            qy <= 0;
            qb <= 0;
            a1 <= 0;
            a2 <= 0;
            b1 <= 0;
            b2 <= 0;
            c1 <= 0;
            c2 <= 0;
            valids <= 0;
            out_vs <= rst_n && in_vs;
            sa <= 0;
            sb <= 0;
            sc <= 0;
            total <= 0;
            mean <= 0;
            div_mid <= 0;
            div_low <= 0;
            side0 <= 0;
            side1 <= 0;
            side2 <= 0;
            side3 <= 0;
            side4 <= 0;
            side5 <= 0;
            side6 <= 0;
            side7 <= 0;
            upper5 <= 0;
            lower5 <= 0;
            delta5 <= 0;
            delta6 <= 0;
            y0 <= 0;
            y1 <= 0;
            y2 <= 0;
            y3 <= 0;
            edge0 <= 1;
            edge1 <= 1;
            edge2 <= 1;
            edge3 <= 1;
            delta3 <= 0;
        end else begin
            out_vs <= 0;
            valids <= {valids[6:0], 1'b0};
            read_valid <= step;
            if (step) begin
                qy <= yy;
                qb <= bank;
                read_emit <= n >= DELAY && n < TOTAL + DELAY;
                read_edge <= n < DELAY + WIDTH || n >= DELAY + TOTAL - WIDTH || x == 0 || x == 1;
                n <= n + 1'b1;
                wp <= wp == DEPTH - 1 ? 0 : wp + 1'b1;
                rp <= rp == DEPTH - 1 ? 0 : rp + 1'b1;
                x <= x == WIDTH - 1 ? 0 : x + 1'b1;
                if (x == WIDTH - 1) bank <= bank == 2 ? 0 : bank + 1'b1;
                if (n == TOTAL + DELAY - 1) active <= 0;
            end
            if (read_valid) begin
                a2 <= a1;
                a1 <= qy;
                b2 <= b1;
                b1 <= prev1;
                c2 <= c1;
                c1 <= prev2;
                if (read_emit) begin
                    valids[0] <= 1;
                    side0 <= qc[31:0];
                    y0 <= qc[39:32];
                    sa <= {2'd0, qy} + {2'd0, a1} + {2'd0, a2};
                    sb <= {2'd0, prev1} + {2'd0, b1} + {2'd0, b2};
                    sc <= {2'd0, prev2} + {2'd0, c1} + {2'd0, c2};
                    edge0 <= read_edge;
                end
            end
            // 舍入分子最大为 9×255+4=2299。
            total <= {2'd0, sa} + {2'd0, sb} + {2'd0, sc} + 12'd4;
            side1 <= side0;
            y1 <= y0;
            edge1 <= edge0;
            div_mid <= div9_digit(total[11:4]);
            div_low <= total[3:0];
            side2 <= side1;
            y2 <= y1;
            edge2 <= edge1;
            mean <= {div_mid[3:0], div_last[3:0]};
            side3 <= side2;
            y3 <= y2;
            edge3 <= edge2;
            d   = $signed({1'b0, y3}) - $signed({1'b0, mean});
            mag = d < 0 ? -d : d;
            mag = mag > 4 ? (mag - 4) / 4 : 0;
            if (mag > 4) mag = 4;
            delta3 <= edge3 ? 0 : (d < 0 ? -mag : mag);
            side4  <= side3;
            upper5 <= u_rg < bu ? u_rg : bu;
            lower5 <= l_rg < bl ? l_rg : bl;
            delta5 <= delta3;
            side5  <= side4;
            if (delta5 > upper_limit) delta6 <= upper_limit;
            else if (delta5 < lower_limit) delta6 <= lower_limit;
            else delta6 <= delta5;
            side6 <= side5;
            side7 <= {side6[31:16], r_out[7:3], g_out[7:2], b_out[7:3]};
        end
    end
    assign out_valid = valids[7];
    assign out_data  = side7;
endmodule

`endif
