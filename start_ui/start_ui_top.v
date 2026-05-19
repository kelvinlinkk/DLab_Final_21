module start_ui_top(
    input sys_clk,
    input sys_rst_n,
    input btnU,
    input btnC,
    input btnD,
    input btnR,
    input btnL,
    output [7:0] seg,
    output [7:0] an
);
    wire clk_scan;
    wire clk_slow;
    clk_divider #(.CNT_MAX(32'd50000)) clk_div_scan(
        .clk(sys_clk),
        .rst_n(sys_rst_n),
        .clk_div(clk_scan)
    );
    clk_divider #(.CNT_MAX(32'd500000)) clk_div_slow(
        .clk(sys_clk),
        .rst_n(sys_rst_n),
        .clk_div(clk_slow)
    );
    wire pulseU;
    wire pulseC;
    wire pulseD;
    wire pulseR;
    wire pulseL;
    press_button bU(
        .clk(clk_slow),
        .btn(btnU),
        .pulse(pulseU)
    );
    press_button bC(
        .clk(clk_slow),
        .btn(btnC),
        .pulse(pulseC)
    );
    press_button bD(
        .clk(clk_slow),
        .btn(btnD),
        .pulse(pulseD)
    );
    press_button bR(
        .clk(clk_slow),
        .btn(btnR),
        .pulse(pulseR)
    );
    press_button bL(
        .clk(clk_slow),
        .btn(btnL),
        .pulse(pulseL)
    );
    wire [5:0] d0;
    wire [5:0] d1;
    wire [5:0] d2;
    wire [5:0] d3;
    wire [5:0] d4;
    wire [5:0] d5;
    wire [5:0] d6;
    wire [5:0] d7;
    start_ui startui(
        .clk(clk_slow),
        .rst_n(sys_rst_n),
        .btnU(pulseU),
        .btnC(pulseC),
        .btnD(pulseD),
        .btnR(pulseR),
        .btnL(pulseL),
        .d0(d0),
        .d1(d1),
        .d2(d2),
        .d3(d3),
        .d4(d4),
        .d5(d5),
        .d6(d6),
        .d7(d7)
    );
    segment_decoder segdecoder(
        .clk(clk_scan),
        .rst_n(sys_rst_n),
        .d0(d0),
        .d1(d1),
        .d2(d2),
        .d3(d3),
        .d4(d4),
        .d5(d5),
        .d6(d6),
        .d7(d7),
        .seg(seg),
        .an(an)
    );
endmodule
