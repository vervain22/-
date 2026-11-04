
`ifndef LANE_ASSIST_INCLUDED
`define LANE_ASSIST_INCLUDED
`timescale 1ns / 1ps

// 每个 RGB565 像素与其输出位置、特征标志同步传递。
// 特征位：bit0 为白色，bit1 为黄色，bit2 为横向对比度不低于 12。
// 首尾各 13 列及上半幅特征清零，不作纵向填充。
// 帧首撤销未完成计算，末像素输入后至少保留 24 个空闲时钟。
module lane_paint_stream #(
    parameter WIDTH = 640,
    HEIGHT = 360
) (
    input clk,
    rst_n,
    frame_start,
    in_valid,
    input [15:0] in_data,
    output reg out_valid,
    output reg [15:0] out_data,
    output reg [2:0] out_features,
    output reg [19:0] out_index,
    output reg frame_done
);
    localparam TOTAL = WIDTH * HEIGHT, COVER = TOTAL / 2;
    // 颜色边界按 RGB565 量化值定义，与 RK 端特征计算一致。
    function [15:0] saturation_limits;
        input [7:0] index;
        begin
            case (index)
                8'd0: saturation_limits = 16'hff00;
                8'd1: saturation_limits = 16'h0100;
                8'd2: saturation_limits = 16'h0100;
                8'd3: saturation_limits = 16'h0101;
                8'd4: saturation_limits = 16'h0201;
                8'd5: saturation_limits = 16'h0202;
                8'd6: saturation_limits = 16'h0202;
                8'd7: saturation_limits = 16'h0203;
                8'd8: saturation_limits = 16'h0303;
                8'd9: saturation_limits = 16'h0303;
                8'd10: saturation_limits = 16'h0304;
                8'd11: saturation_limits = 16'h0304;
                8'd12: saturation_limits = 16'h0405;
                8'd13: saturation_limits = 16'h0405;
                8'd14: saturation_limits = 16'h0406;
                8'd15: saturation_limits = 16'h0506;
                8'd16: saturation_limits = 16'h0506;
                8'd17: saturation_limits = 16'h0507;
                8'd18: saturation_limits = 16'h0507;
                8'd19: saturation_limits = 16'h0608;
                8'd20: saturation_limits = 16'h0608;
                8'd21: saturation_limits = 16'h0609;
                8'd22: saturation_limits = 16'h0609;
                8'd23: saturation_limits = 16'h0709;
                8'd24: saturation_limits = 16'h070a;
                8'd25: saturation_limits = 16'h070a;
                8'd26: saturation_limits = 16'h080b;
                8'd27: saturation_limits = 16'h080b;
                8'd28: saturation_limits = 16'h080c;
                8'd29: saturation_limits = 16'h080c;
                8'd30: saturation_limits = 16'h090c;
                8'd31: saturation_limits = 16'h090d;
                8'd32: saturation_limits = 16'h090d;
                8'd33: saturation_limits = 16'h090e;
                8'd34: saturation_limits = 16'h0a0e;
                8'd35: saturation_limits = 16'h0a0f;
                8'd36: saturation_limits = 16'h0a0f;
                8'd37: saturation_limits = 16'h0b0f;
                8'd38: saturation_limits = 16'h0b10;
                8'd39: saturation_limits = 16'h0b10;
                8'd40: saturation_limits = 16'h0b11;
                8'd41: saturation_limits = 16'h0c11;
                8'd42: saturation_limits = 16'h0c12;
                8'd43: saturation_limits = 16'h0c12;
                8'd44: saturation_limits = 16'h0c12;
                8'd45: saturation_limits = 16'h0d13;
                8'd46: saturation_limits = 16'h0d13;
                8'd47: saturation_limits = 16'h0d14;
                8'd48: saturation_limits = 16'h0e14;
                8'd49: saturation_limits = 16'h0e15;
                8'd50: saturation_limits = 16'h0e15;
                8'd51: saturation_limits = 16'h0e15;
                8'd52: saturation_limits = 16'h0f16;
                8'd53: saturation_limits = 16'h0f16;
                8'd54: saturation_limits = 16'h0f17;
                8'd55: saturation_limits = 16'h0f17;
                8'd56: saturation_limits = 16'h1018;
                8'd57: saturation_limits = 16'h1018;
                8'd58: saturation_limits = 16'h1018;
                8'd59: saturation_limits = 16'h1119;
                8'd60: saturation_limits = 16'h1119;
                8'd61: saturation_limits = 16'h111a;
                8'd62: saturation_limits = 16'h111a;
                8'd63: saturation_limits = 16'h121b;
                8'd64: saturation_limits = 16'h121b;
                8'd65: saturation_limits = 16'h121b;
                8'd66: saturation_limits = 16'h121c;
                8'd67: saturation_limits = 16'h131c;
                8'd68: saturation_limits = 16'h131d;
                8'd69: saturation_limits = 16'h131d;
                8'd70: saturation_limits = 16'h141e;
                8'd71: saturation_limits = 16'h141e;
                8'd72: saturation_limits = 16'h141e;
                8'd73: saturation_limits = 16'h141f;
                8'd74: saturation_limits = 16'h151f;
                8'd75: saturation_limits = 16'h1520;
                8'd76: saturation_limits = 16'h1520;
                8'd77: saturation_limits = 16'h1521;
                8'd78: saturation_limits = 16'h1621;
                8'd79: saturation_limits = 16'h1621;
                8'd80: saturation_limits = 16'h1622;
                8'd81: saturation_limits = 16'h1722;
                8'd82: saturation_limits = 16'h1723;
                8'd83: saturation_limits = 16'h1723;
                8'd84: saturation_limits = 16'h1724;
                8'd85: saturation_limits = 16'h1824;
                8'd86: saturation_limits = 16'h1824;
                8'd87: saturation_limits = 16'h1825;
                8'd88: saturation_limits = 16'h1825;
                8'd89: saturation_limits = 16'h1926;
                8'd90: saturation_limits = 16'h1926;
                8'd91: saturation_limits = 16'h1927;
                8'd92: saturation_limits = 16'h1a27;
                8'd93: saturation_limits = 16'h1a27;
                8'd94: saturation_limits = 16'h1a28;
                8'd95: saturation_limits = 16'h1a28;
                8'd96: saturation_limits = 16'h1b29;
                8'd97: saturation_limits = 16'h1b29;
                8'd98: saturation_limits = 16'h1b2a;
                8'd99: saturation_limits = 16'h1b2a;
                8'd100: saturation_limits = 16'h1c2a;
                8'd101: saturation_limits = 16'h1c2b;
                8'd102: saturation_limits = 16'h1c2b;
                8'd103: saturation_limits = 16'h1d2c;
                8'd104: saturation_limits = 16'h1d2c;
                8'd105: saturation_limits = 16'h1d2d;
                8'd106: saturation_limits = 16'h1d2d;
                8'd107: saturation_limits = 16'h1e2d;
                8'd108: saturation_limits = 16'h1e2e;
                8'd109: saturation_limits = 16'h1e2e;
                8'd110: saturation_limits = 16'h1e2f;
                8'd111: saturation_limits = 16'h1f2f;
                8'd112: saturation_limits = 16'h1f30;
                8'd113: saturation_limits = 16'h1f30;
                8'd114: saturation_limits = 16'h2030;
                8'd115: saturation_limits = 16'h2031;
                8'd116: saturation_limits = 16'h2031;
                8'd117: saturation_limits = 16'h2032;
                8'd118: saturation_limits = 16'h2132;
                8'd119: saturation_limits = 16'h2133;
                8'd120: saturation_limits = 16'h2133;
                8'd121: saturation_limits = 16'h2133;
                8'd122: saturation_limits = 16'h2234;
                8'd123: saturation_limits = 16'h2234;
                8'd124: saturation_limits = 16'h2235;
                8'd125: saturation_limits = 16'h2335;
                8'd126: saturation_limits = 16'h2336;
                8'd127: saturation_limits = 16'h2336;
                8'd128: saturation_limits = 16'h2336;
                8'd129: saturation_limits = 16'h2437;
                8'd130: saturation_limits = 16'h2437;
                8'd131: saturation_limits = 16'h2438;
                8'd132: saturation_limits = 16'h2438;
                8'd133: saturation_limits = 16'h2539;
                8'd134: saturation_limits = 16'h2539;
                8'd135: saturation_limits = 16'h2539;
                8'd136: saturation_limits = 16'h263a;
                8'd137: saturation_limits = 16'h263a;
                8'd138: saturation_limits = 16'h263b;
                8'd139: saturation_limits = 16'h263b;
                8'd140: saturation_limits = 16'h273c;
                8'd141: saturation_limits = 16'h273c;
                8'd142: saturation_limits = 16'h273c;
                8'd143: saturation_limits = 16'h273d;
                8'd144: saturation_limits = 16'h283d;
                8'd145: saturation_limits = 16'h283e;
                8'd146: saturation_limits = 16'h283e;
                8'd147: saturation_limits = 16'h293f;
                8'd148: saturation_limits = 16'h293f;
                8'd149: saturation_limits = 16'h293f;
                8'd150: saturation_limits = 16'h2940;
                8'd151: saturation_limits = 16'h2a40;
                8'd152: saturation_limits = 16'h2a41;
                8'd153: saturation_limits = 16'h2a41;
                8'd154: saturation_limits = 16'h2a42;
                8'd155: saturation_limits = 16'h2b42;
                8'd156: saturation_limits = 16'h2b42;
                8'd157: saturation_limits = 16'h2b43;
                8'd158: saturation_limits = 16'h2c43;
                8'd159: saturation_limits = 16'h2c44;
                8'd160: saturation_limits = 16'h2c44;
                8'd161: saturation_limits = 16'h2c45;
                8'd162: saturation_limits = 16'h2d45;
                8'd163: saturation_limits = 16'h2d45;
                8'd164: saturation_limits = 16'h2d46;
                8'd165: saturation_limits = 16'h2d46;
                8'd166: saturation_limits = 16'h2e47;
                8'd167: saturation_limits = 16'h2e47;
                8'd168: saturation_limits = 16'h2e48;
                8'd169: saturation_limits = 16'h2f48;
                8'd170: saturation_limits = 16'h2f48;
                8'd171: saturation_limits = 16'h2f49;
                8'd172: saturation_limits = 16'h2f49;
                8'd173: saturation_limits = 16'h304a;
                8'd174: saturation_limits = 16'h304a;
                8'd175: saturation_limits = 16'h304b;
                8'd176: saturation_limits = 16'h304b;
                8'd177: saturation_limits = 16'h314c;
                8'd178: saturation_limits = 16'h314c;
                8'd179: saturation_limits = 16'h314c;
                8'd180: saturation_limits = 16'h324d;
                8'd181: saturation_limits = 16'h324d;
                8'd182: saturation_limits = 16'h324e;
                8'd183: saturation_limits = 16'h324e;
                8'd184: saturation_limits = 16'h334f;
                8'd185: saturation_limits = 16'h334f;
                8'd186: saturation_limits = 16'h334f;
                8'd187: saturation_limits = 16'h3350;
                8'd188: saturation_limits = 16'h3450;
                8'd189: saturation_limits = 16'h3451;
                8'd190: saturation_limits = 16'h3451;
                8'd191: saturation_limits = 16'h3552;
                8'd192: saturation_limits = 16'h3552;
                8'd193: saturation_limits = 16'h3552;
                8'd194: saturation_limits = 16'h3553;
                8'd195: saturation_limits = 16'h3653;
                8'd196: saturation_limits = 16'h3654;
                8'd197: saturation_limits = 16'h3654;
                8'd198: saturation_limits = 16'h3655;
                8'd199: saturation_limits = 16'h3755;
                8'd200: saturation_limits = 16'h3755;
                8'd201: saturation_limits = 16'h3756;
                8'd202: saturation_limits = 16'h3856;
                8'd203: saturation_limits = 16'h3857;
                8'd204: saturation_limits = 16'h3857;
                8'd205: saturation_limits = 16'h3858;
                8'd206: saturation_limits = 16'h3958;
                8'd207: saturation_limits = 16'h3958;
                8'd208: saturation_limits = 16'h3959;
                8'd209: saturation_limits = 16'h3959;
                8'd210: saturation_limits = 16'h3a5a;
                8'd211: saturation_limits = 16'h3a5a;
                8'd212: saturation_limits = 16'h3a5b;
                8'd213: saturation_limits = 16'h3b5b;
                8'd214: saturation_limits = 16'h3b5b;
                8'd215: saturation_limits = 16'h3b5c;
                8'd216: saturation_limits = 16'h3b5c;
                8'd217: saturation_limits = 16'h3c5d;
                8'd218: saturation_limits = 16'h3c5d;
                8'd219: saturation_limits = 16'h3c5e;
                8'd220: saturation_limits = 16'h3c5e;
                8'd221: saturation_limits = 16'h3d5e;
                8'd222: saturation_limits = 16'h3d5f;
                8'd223: saturation_limits = 16'h3d5f;
                8'd224: saturation_limits = 16'h3e60;
                8'd225: saturation_limits = 16'h3e60;
                8'd226: saturation_limits = 16'h3e61;
                8'd227: saturation_limits = 16'h3e61;
                8'd228: saturation_limits = 16'h3f61;
                8'd229: saturation_limits = 16'h3f62;
                8'd230: saturation_limits = 16'h3f62;
                8'd231: saturation_limits = 16'h3f63;
                8'd232: saturation_limits = 16'h4063;
                8'd233: saturation_limits = 16'h4064;
                8'd234: saturation_limits = 16'h4064;
                8'd235: saturation_limits = 16'h4164;
                8'd236: saturation_limits = 16'h4165;
                8'd237: saturation_limits = 16'h4165;
                8'd238: saturation_limits = 16'h4166;
                8'd239: saturation_limits = 16'h4266;
                8'd240: saturation_limits = 16'h4267;
                8'd241: saturation_limits = 16'h4267;
                8'd242: saturation_limits = 16'h4267;
                8'd243: saturation_limits = 16'h4368;
                8'd244: saturation_limits = 16'h4368;
                8'd245: saturation_limits = 16'h4369;
                8'd246: saturation_limits = 16'h4469;
                8'd247: saturation_limits = 16'h446a;
                8'd248: saturation_limits = 16'h446a;
                8'd249: saturation_limits = 16'h446a;
                8'd250: saturation_limits = 16'h456b;
                8'd251: saturation_limits = 16'h456b;
                8'd252: saturation_limits = 16'h456c;
                8'd253: saturation_limits = 16'h456c;
                8'd254: saturation_limits = 16'h466d;
                8'd255: saturation_limits = 16'h466d;
                default: saturation_limits = 16'hffff;
            endcase
        end
    endfunction
    function [15:0] hue_limits;
        input [7:0] index;
        begin
            case (index)
                8'd0: hue_limits = 16'hffff;
                8'd1: hue_limits = 16'h0101;
                8'd2: hue_limits = 16'h0201;
                8'd3: hue_limits = 16'h0202;
                8'd4: hue_limits = 16'h0302;
                8'd5: hue_limits = 16'h0403;
                8'd6: hue_limits = 16'h0403;
                8'd7: hue_limits = 16'h0504;
                8'd8: hue_limits = 16'h0604;
                8'd9: hue_limits = 16'h0605;
                8'd10: hue_limits = 16'h0705;
                8'd11: hue_limits = 16'h0806;
                8'd12: hue_limits = 16'h0806;
                8'd13: hue_limits = 16'h0907;
                8'd14: hue_limits = 16'h0a07;
                8'd15: hue_limits = 16'h0a08;
                8'd16: hue_limits = 16'h0b08;
                8'd17: hue_limits = 16'h0c09;
                8'd18: hue_limits = 16'h0c09;
                8'd19: hue_limits = 16'h0d0a;
                8'd20: hue_limits = 16'h0e0a;
                8'd21: hue_limits = 16'h0e0b;
                8'd22: hue_limits = 16'h0f0b;
                8'd23: hue_limits = 16'h0f0c;
                8'd24: hue_limits = 16'h100c;
                8'd25: hue_limits = 16'h110d;
                8'd26: hue_limits = 16'h110d;
                8'd27: hue_limits = 16'h120e;
                8'd28: hue_limits = 16'h130e;
                8'd29: hue_limits = 16'h130f;
                8'd30: hue_limits = 16'h140f;
                8'd31: hue_limits = 16'h150f;
                8'd32: hue_limits = 16'h1510;
                8'd33: hue_limits = 16'h1610;
                8'd34: hue_limits = 16'h1711;
                8'd35: hue_limits = 16'h1711;
                8'd36: hue_limits = 16'h1812;
                8'd37: hue_limits = 16'h1912;
                8'd38: hue_limits = 16'h1913;
                8'd39: hue_limits = 16'h1a13;
                8'd40: hue_limits = 16'h1b14;
                8'd41: hue_limits = 16'h1b14;
                8'd42: hue_limits = 16'h1c15;
                8'd43: hue_limits = 16'h1c15;
                8'd44: hue_limits = 16'h1d16;
                8'd45: hue_limits = 16'h1e16;
                8'd46: hue_limits = 16'h1e17;
                8'd47: hue_limits = 16'h1f17;
                8'd48: hue_limits = 16'h2018;
                8'd49: hue_limits = 16'h2018;
                8'd50: hue_limits = 16'h2119;
                8'd51: hue_limits = 16'h2219;
                8'd52: hue_limits = 16'h221a;
                8'd53: hue_limits = 16'h231a;
                8'd54: hue_limits = 16'h241b;
                8'd55: hue_limits = 16'h241b;
                8'd56: hue_limits = 16'h251c;
                8'd57: hue_limits = 16'h261c;
                8'd58: hue_limits = 16'h261d;
                8'd59: hue_limits = 16'h271d;
                8'd60: hue_limits = 16'h281d;
                8'd61: hue_limits = 16'h281e;
                8'd62: hue_limits = 16'h291e;
                8'd63: hue_limits = 16'h291f;
                8'd64: hue_limits = 16'h2a1f;
                8'd65: hue_limits = 16'h2b20;
                8'd66: hue_limits = 16'h2b20;
                8'd67: hue_limits = 16'h2c21;
                8'd68: hue_limits = 16'h2d21;
                8'd69: hue_limits = 16'h2d22;
                8'd70: hue_limits = 16'h2e22;
                8'd71: hue_limits = 16'h2f23;
                8'd72: hue_limits = 16'h2f23;
                8'd73: hue_limits = 16'h3024;
                8'd74: hue_limits = 16'h3124;
                8'd75: hue_limits = 16'h3125;
                8'd76: hue_limits = 16'h3225;
                8'd77: hue_limits = 16'h3326;
                8'd78: hue_limits = 16'h3326;
                8'd79: hue_limits = 16'h3427;
                8'd80: hue_limits = 16'h3527;
                8'd81: hue_limits = 16'h3528;
                8'd82: hue_limits = 16'h3628;
                8'd83: hue_limits = 16'h3629;
                8'd84: hue_limits = 16'h3729;
                8'd85: hue_limits = 16'h382a;
                8'd86: hue_limits = 16'h382a;
                8'd87: hue_limits = 16'h392b;
                8'd88: hue_limits = 16'h3a2b;
                8'd89: hue_limits = 16'h3a2c;
                8'd90: hue_limits = 16'h3b2c;
                8'd91: hue_limits = 16'h3c2c;
                8'd92: hue_limits = 16'h3c2d;
                8'd93: hue_limits = 16'h3d2d;
                8'd94: hue_limits = 16'h3e2e;
                8'd95: hue_limits = 16'h3e2e;
                8'd96: hue_limits = 16'h3f2f;
                8'd97: hue_limits = 16'h402f;
                8'd98: hue_limits = 16'h4030;
                8'd99: hue_limits = 16'h4130;
                8'd100: hue_limits = 16'h4231;
                8'd101: hue_limits = 16'h4231;
                8'd102: hue_limits = 16'h4332;
                8'd103: hue_limits = 16'h4332;
                8'd104: hue_limits = 16'h4433;
                8'd105: hue_limits = 16'h4533;
                8'd106: hue_limits = 16'h4534;
                8'd107: hue_limits = 16'h4634;
                8'd108: hue_limits = 16'h4735;
                8'd109: hue_limits = 16'h4735;
                8'd110: hue_limits = 16'h4836;
                8'd111: hue_limits = 16'h4936;
                8'd112: hue_limits = 16'h4937;
                8'd113: hue_limits = 16'h4a37;
                8'd114: hue_limits = 16'h4b38;
                8'd115: hue_limits = 16'h4b38;
                8'd116: hue_limits = 16'h4c39;
                8'd117: hue_limits = 16'h4d39;
                8'd118: hue_limits = 16'h4d3a;
                8'd119: hue_limits = 16'h4e3a;
                8'd120: hue_limits = 16'h4f3a;
                8'd121: hue_limits = 16'h4f3b;
                8'd122: hue_limits = 16'h503b;
                8'd123: hue_limits = 16'h503c;
                8'd124: hue_limits = 16'h513c;
                8'd125: hue_limits = 16'h523d;
                8'd126: hue_limits = 16'h523d;
                8'd127: hue_limits = 16'h533e;
                8'd128: hue_limits = 16'h543e;
                8'd129: hue_limits = 16'h543f;
                8'd130: hue_limits = 16'h553f;
                8'd131: hue_limits = 16'h5640;
                8'd132: hue_limits = 16'h5640;
                8'd133: hue_limits = 16'h5741;
                8'd134: hue_limits = 16'h5841;
                8'd135: hue_limits = 16'h5842;
                8'd136: hue_limits = 16'h5942;
                8'd137: hue_limits = 16'h5a43;
                8'd138: hue_limits = 16'h5a43;
                8'd139: hue_limits = 16'h5b44;
                8'd140: hue_limits = 16'h5c44;
                8'd141: hue_limits = 16'h5c45;
                8'd142: hue_limits = 16'h5d45;
                8'd143: hue_limits = 16'h5d46;
                8'd144: hue_limits = 16'h5e46;
                8'd145: hue_limits = 16'h5f47;
                8'd146: hue_limits = 16'h5f47;
                8'd147: hue_limits = 16'h6048;
                8'd148: hue_limits = 16'h6148;
                8'd149: hue_limits = 16'h6148;
                8'd150: hue_limits = 16'h6249;
                8'd151: hue_limits = 16'h6349;
                8'd152: hue_limits = 16'h634a;
                8'd153: hue_limits = 16'h644a;
                8'd154: hue_limits = 16'h654b;
                8'd155: hue_limits = 16'h654b;
                8'd156: hue_limits = 16'h664c;
                8'd157: hue_limits = 16'h674c;
                8'd158: hue_limits = 16'h674d;
                8'd159: hue_limits = 16'h684d;
                8'd160: hue_limits = 16'h694e;
                8'd161: hue_limits = 16'h694e;
                8'd162: hue_limits = 16'h6a4f;
                8'd163: hue_limits = 16'h6a4f;
                8'd164: hue_limits = 16'h6b50;
                8'd165: hue_limits = 16'h6c50;
                8'd166: hue_limits = 16'h6c51;
                8'd167: hue_limits = 16'h6d51;
                8'd168: hue_limits = 16'h6e52;
                8'd169: hue_limits = 16'h6e52;
                8'd170: hue_limits = 16'h6f53;
                8'd171: hue_limits = 16'h7053;
                8'd172: hue_limits = 16'h7054;
                8'd173: hue_limits = 16'h7154;
                8'd174: hue_limits = 16'h7255;
                8'd175: hue_limits = 16'h7255;
                8'd176: hue_limits = 16'h7356;
                8'd177: hue_limits = 16'h7356;
                8'd178: hue_limits = 16'h7457;
                8'd179: hue_limits = 16'h7557;
                8'd180: hue_limits = 16'h7657;
                8'd181: hue_limits = 16'h7658;
                8'd182: hue_limits = 16'h7758;
                8'd183: hue_limits = 16'h7759;
                8'd184: hue_limits = 16'h7859;
                8'd185: hue_limits = 16'h795a;
                8'd186: hue_limits = 16'h7a5a;
                8'd187: hue_limits = 16'h7a5b;
                8'd188: hue_limits = 16'h7b5b;
                8'd189: hue_limits = 16'h7b5c;
                8'd190: hue_limits = 16'h7c5c;
                8'd191: hue_limits = 16'h7d5d;
                8'd192: hue_limits = 16'h7d5d;
                8'd193: hue_limits = 16'h7e5e;
                8'd194: hue_limits = 16'h7e5e;
                8'd195: hue_limits = 16'h7f5f;
                8'd196: hue_limits = 16'h805f;
                8'd197: hue_limits = 16'h8160;
                8'd198: hue_limits = 16'h8160;
                8'd199: hue_limits = 16'h8261;
                8'd200: hue_limits = 16'h8261;
                8'd201: hue_limits = 16'h8362;
                8'd202: hue_limits = 16'h8462;
                8'd203: hue_limits = 16'h8463;
                8'd204: hue_limits = 16'h8563;
                8'd205: hue_limits = 16'h8664;
                8'd206: hue_limits = 16'h8764;
                8'd207: hue_limits = 16'h8764;
                8'd208: hue_limits = 16'h8865;
                8'd209: hue_limits = 16'h8866;
                8'd210: hue_limits = 16'h8966;
                8'd211: hue_limits = 16'h8967;
                8'd212: hue_limits = 16'h8a67;
                8'd213: hue_limits = 16'h8b67;
                8'd214: hue_limits = 16'h8b68;
                8'd215: hue_limits = 16'h8c68;
                8'd216: hue_limits = 16'h8d69;
                8'd217: hue_limits = 16'h8d69;
                8'd218: hue_limits = 16'h8e6a;
                8'd219: hue_limits = 16'h8f6a;
                8'd220: hue_limits = 16'h906b;
                8'd221: hue_limits = 16'h906b;
                8'd222: hue_limits = 16'h916c;
                8'd223: hue_limits = 16'h916c;
                8'd224: hue_limits = 16'h926d;
                8'd225: hue_limits = 16'h936d;
                8'd226: hue_limits = 16'h946e;
                8'd227: hue_limits = 16'h946e;
                8'd228: hue_limits = 16'h956f;
                8'd229: hue_limits = 16'h966f;
                8'd230: hue_limits = 16'h9670;
                8'd231: hue_limits = 16'h9770;
                8'd232: hue_limits = 16'h9871;
                8'd233: hue_limits = 16'h9871;
                8'd234: hue_limits = 16'h9972;
                8'd235: hue_limits = 16'h9972;
                8'd236: hue_limits = 16'h9a72;
                8'd237: hue_limits = 16'h9a73;
                8'd238: hue_limits = 16'h9b74;
                8'd239: hue_limits = 16'h9c74;
                8'd240: hue_limits = 16'h9d74;
                8'd241: hue_limits = 16'h9d75;
                8'd242: hue_limits = 16'h9e75;
                8'd243: hue_limits = 16'h9f76;
                8'd244: hue_limits = 16'h9f76;
                8'd245: hue_limits = 16'ha077;
                8'd246: hue_limits = 16'ha177;
                8'd247: hue_limits = 16'ha178;
                8'd248: hue_limits = 16'ha178;
                8'd249: hue_limits = 16'ha279;
                8'd250: hue_limits = 16'ha379;
                8'd251: hue_limits = 16'ha47a;
                8'd252: hue_limits = 16'ha57a;
                8'd253: hue_limits = 16'ha57b;
                8'd254: hue_limits = 16'ha67b;
                8'd255: hue_limits = 16'ha67c;
                default: hue_limits = 16'hffff;
            endcase
        end
    endfunction

    function [7:0] value_of;
        input [15:0] pixel;
        reg [7:0] r, g, b;
        begin
            r = {pixel[15:11], 3'b0};
            g = {pixel[10:5], 2'b0};
            b = {pixel[4:0], 3'b0};
            value_of = (r >= g && r >= b) ? r : ((g >= b) ? g : b);
        end
    endfunction
    function [1:0] colour_of;
        input [15:0] pixel;
        reg [7:0] r, g, b, v, m, d;
        reg [15:0] sat, hue;
        reg white, yellow, hy;
        begin
            r = {pixel[15:11], 3'b0};
            g = {pixel[10:5], 2'b0};
            b = {pixel[4:0], 3'b0};
            v = (r >= g && r >= b) ? r : ((g >= b) ? g : b);
            m = (r <= g && r <= b) ? r : ((g <= b) ? g : b);
            d = v - m;
            sat = saturation_limits(v);
            hue = hue_limits(d);
            white = v >= 65 && d <= sat[7:0];
            hy = (r >= g && r >= b && g >= b && g - b >= hue[7:0]) || (g > r && g >= b && r >= b && r - b >= hue[15:8]);
            yellow = v >= 100 && d >= sat[15:8] && hy;
            colour_of = {yellow, white};
        end
    endfunction
    reg [15:0] pixels[0:23];
    reg [ 7:0] values[0:23];
    reg active, flush;
    reg [19:0] seen, emitted;
    reg [11:0] column;
    wire advance = active && (in_valid || flush);
    wire [15:0] incoming = flush ? 16'd0 : in_data;
    // 每周期完成一层比较交换，像素信息随流水线同步传递。
    reg [7:0] pv, edge_pipe;
    reg [15:0] data_pipe  [0:7];
    reg [19:0] index_pipe [0:7];
    reg [ 1:0] colour_pipe[0:7];
    reg [ 7:0] value_pipe [0:7];
    reg [ 7:0] sort_pipe  [0:6] [0:5];
    reg [ 8:0] middle;
    function [7:0] lo;
        input [7:0] a, b;
        begin
            lo = (a < b) ? a : b;
        end
    endfunction
    function [7:0] hi;
        input [7:0] a, b;
        begin
            hi = (a > b) ? a : b;
        end
    endfunction
    integer st, j;
    integer k;
    always @(posedge clk) begin
        if (!rst_n || frame_start) begin
            active <= rst_n && frame_start;
            flush <= 0;
            seen <= 0;
            emitted <= 0;
            column <= 0;
            pv <= 0;
            out_valid <= 0;
            frame_done <= 0;
            out_data <= 0;
            out_features <= 0;
            out_index <= 0;
        end else begin
            pv <= {pv[6:0], 1'b0};
            out_valid <= pv[7];
            frame_done <= 0;
            for (st = 1; st < 8; st = st + 1) begin
                data_pipe[st]   <= data_pipe[st-1];
                index_pipe[st]  <= index_pipe[st-1];
                colour_pipe[st] <= colour_pipe[st-1];
                value_pipe[st]  <= value_pipe[st-1];
                edge_pipe[st]   <= edge_pipe[st-1];
            end
            for (st = 1; st < 7; st = st + 1) for (j = 0; j < 6; j = j + 1) sort_pipe[st][j] <= sort_pipe[st-1][j];

            if (advance) begin
                for (k = 23; k > 0; k = k - 1) begin
                    pixels[k] <= pixels[k-1];
                    values[k] <= values[k-1];
                end
                pixels[0] <= incoming;
                values[0] <= value_of(incoming);
                seen <= seen + 1'b1;
                if (seen >= 12 && emitted < TOTAL) begin
                    pv[0] <= 1;
                    data_pipe[0] <= pixels[11];
                    index_pipe[0] <= emitted;
                    value_pipe[0] <= values[11];
                    colour_pipe[0] <= colour_of(pixels[11]);
                    edge_pipe[0] <= column < 13 || column >= WIDTH - 13 || emitted < COVER;
                    sort_pipe[0][0] <= values[23];
                    sort_pipe[0][1] <= values[21];
                    sort_pipe[0][2] <= values[19];
                    sort_pipe[0][3] <= values[3];
                    sort_pipe[0][4] <= values[1];
                    sort_pipe[0][5] <= value_of(incoming);
                    emitted <= emitted + 1'b1;
                    column <= (column == WIDTH - 1) ? 0 : column + 1'b1;
                end
                if (seen == TOTAL - 1) flush <= 1;
                if (seen == TOTAL + 11) begin
                    active <= 0;
                    flush  <= 0;
                end
            end
            sort_pipe[1][1] <= lo(sort_pipe[0][1], sort_pipe[0][2]);
            sort_pipe[1][2] <= hi(sort_pipe[0][1], sort_pipe[0][2]);
            sort_pipe[1][4] <= lo(sort_pipe[0][4], sort_pipe[0][5]);
            sort_pipe[1][5] <= hi(sort_pipe[0][4], sort_pipe[0][5]);
            sort_pipe[2][0] <= lo(sort_pipe[1][0], sort_pipe[1][2]);
            sort_pipe[2][2] <= hi(sort_pipe[1][0], sort_pipe[1][2]);
            sort_pipe[2][3] <= lo(sort_pipe[1][3], sort_pipe[1][5]);
            sort_pipe[2][5] <= hi(sort_pipe[1][3], sort_pipe[1][5]);
            sort_pipe[3][0] <= lo(sort_pipe[2][0], sort_pipe[2][1]);
            sort_pipe[3][1] <= hi(sort_pipe[2][0], sort_pipe[2][1]);
            sort_pipe[3][3] <= lo(sort_pipe[2][3], sort_pipe[2][4]);
            sort_pipe[3][4] <= hi(sort_pipe[2][3], sort_pipe[2][4]);
            sort_pipe[3][2] <= lo(sort_pipe[2][2], sort_pipe[2][5]);
            sort_pipe[3][5] <= hi(sort_pipe[2][2], sort_pipe[2][5]);
            sort_pipe[4][0] <= lo(sort_pipe[3][0], sort_pipe[3][3]);
            sort_pipe[4][3] <= hi(sort_pipe[3][0], sort_pipe[3][3]);
            sort_pipe[4][1] <= lo(sort_pipe[3][1], sort_pipe[3][4]);
            sort_pipe[4][4] <= hi(sort_pipe[3][1], sort_pipe[3][4]);
            sort_pipe[5][2] <= lo(sort_pipe[4][2], sort_pipe[4][4]);
            sort_pipe[5][4] <= hi(sort_pipe[4][2], sort_pipe[4][4]);
            sort_pipe[5][1] <= lo(sort_pipe[4][1], sort_pipe[4][3]);
            sort_pipe[5][3] <= hi(sort_pipe[4][1], sort_pipe[4][3]);
            sort_pipe[6][2] <= lo(sort_pipe[5][2], sort_pipe[5][3]);
            sort_pipe[6][3] <= hi(sort_pipe[5][2], sort_pipe[5][3]);
            middle <= {1'b0, sort_pipe[6][2]} + {1'b0, sort_pipe[6][3]};
            if (pv[7]) begin
                out_data <= data_pipe[7];
                out_index <= index_pipe[7];
                out_features<=edge_pipe[7]?3'd0:{({1'b0,value_pipe[7],1'b0}>={1'b0,middle}+10'd24),colour_pipe[7]};
                if (index_pipe[7] == TOTAL - 1) frame_done <= 1;
            end
        end
    end
endmodule

`timescale 1ns / 1ps

// 保持 RGB565、上半幅颜色计数及完整 32 位帧号。
module lane_aux_stream #(
    parameter WIDTH = 640,
    HEIGHT = 360,
    FIFO_AW = 6
) (
    input clk,
    rst_n,
    in_vs,
    in_valid,
    input [31:0] in_data,
    output reg out_vs,
    out_valid,
    output reg [31:0] out_data,
    output reg [31:0] errors
);
    localparam TOTAL = WIDTH * HEIGHT, COVER = TOTAL / 2;
    wire feature_valid, done;
    wire [15:0] pixel;
    wire [ 2:0] feature;
    wire [19:0] index;
    lane_paint_stream #(
        .WIDTH (WIDTH),
        .HEIGHT(HEIGHT)
    ) core (
        .clk(clk),
        .rst_n(rst_n),
        .frame_start(in_vs),
        .in_valid(in_valid),
        .in_data(in_data[15:0]),
        .out_valid(feature_valid),
        .out_data(pixel),
        .out_features(feature),
        .out_index(index),
        .frame_done(done)
    );
    reg [15:0] metadata[0:(1<<FIFO_AW)-1];
    reg [FIFO_AW:0] wp, rp;
    wire empty = wp == rp;
    wire full = (wp[FIFO_AW] != rp[FIFO_AW]) && (wp[FIFO_AW-1:0] == rp[FIFO_AW-1:0]);
    wire [15:0] head = metadata[rp[FIFO_AW-1:0]];
    reg [15:0] word;
    reg bad;
    reg [19:0] expected_index;
    always @* begin
        word = head;
        if (index >= COVER + 6 && index < TOTAL - 4) word = {head[15:12], 9'd0, feature};
        if (index == COVER + 1) word = 16'd2;
        if (index == TOTAL - 1 && (bad || empty || index != expected_index)) word = 16'hdead;
    end
    always @(posedge clk) begin
        if (!rst_n || in_vs) begin
            out_vs <= rst_n && in_vs;
            out_valid <= 0;
            out_data <= 0;
            wp <= 0;
            rp <= 0;
            bad <= 0;
            expected_index <= 0;
            if (!rst_n) errors <= 0;
        end else begin
            out_vs <= 0;
            out_valid <= feature_valid;
            if (in_valid) begin
                if (!full) begin
                    metadata[wp[FIFO_AW-1:0]] <= in_data[31:16];
                    wp <= wp + 1'b1;
                end else begin
                    bad <= 1;
                    errors <= errors + 1'b1;
                end
            end
            if (feature_valid) begin
                out_data <= {word, pixel};
                expected_index <= expected_index + 1'b1;
                if (!empty) rp <= rp + 1'b1;
                if (empty || index != expected_index || index >= TOTAL) begin
                    bad <= 1;
                    errors <= errors + 1'b1;
                end
            end
        end
    end
endmodule

`endif
