module start_ui_top(
    input sys_clk,
    input sys_rst_n,
    input SW15,
    input btnU,
    input btnC,
    input btnD,
    input btnR,
    input btnL,
    output [7:0] seg,
    output [7:0] an
);
    reg [3:0] state=init;
    localparam init = 4'b0000;
    localparam start_host = 4'b0001;
    localparam start_guest = 4'b0010;
    localparam game_host = 4'b0011;
    localparam game_guest = 4'b0100;


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
    reg ishost=0;
    reg startstartui=0;
    always @(posedge clk_slow or negedge sys_rst_n) begin
        if (!sys_rst_n) begin
            startstartui <= 1'b0;
            ishost       <= 1'b0;
            state<=init;
        end else begin
            case(state)
            init:
            begin
                if(pulseC & SW15)begin
                startstartui<=1'b1;
                state<=start_host;
                end
                if(pulseC & !SW15)begin
                startstartui<=1'b1;
                state<=start_guest;
                end
            end
            start_host:
            begin
                startstartui <= 1'b0;
                if(backtogh_h)
                begin
                    state<=game_host;
                end
            end
            start_guest:
            begin
                startstartui <= 1'b0;
                if(backtogh_p)
                begin
                    state<=start_guest;
                end
            end
            default:
            begin
                state<=init;
            end
            endcase
        end
    end
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
    wire backtogh_h;
    wire backtogh_p;
    wire [3:0] state_h;
    wire [3:0] state_p;
    wire [2:0] player_count;
    wire [1:0] ai_level;
    wire [5:0] money_you_have_thousands;
    wire [5:0] money_you_have_hundreds;
    wire [5:0] money_you_have_tens;
    wire [5:0] money_you_have_ones;    
    wire [5:0] money_you_bet_hundreds;
    wire [5:0] money_you_bet_tens;
    wire [5:0] money_you_bet_ones;
    start_ui_host startui_h(
        .clk(clk_slow),
        .rst_n(sys_rst_n),
        .btnU(pulseU),
        .btnC(pulseC),
        .btnD(pulseD),
        .btnR(pulseR),
        .btnL(pulseL),
        .ishost(ishost),
        .startstartui(startstartui),
        .backtogh_h(backtogh_h),
        .state_h(state_h),
        .player_count(player_count),
        .ai_level(ai_level)
    );
    start_ui_player startui_p(
        .clk(clk_slow),
        .rst_n(sys_rst_n),
        .btnU(pulseU),
        .btnC(pulseC),
        .btnD(pulseD),
        .btnR(pulseR),
        .btnL(pulseL),
        .ishost(ishost),
        .startstartui(startstartui),
        .backtogh_p(backtogh_p),
        .state_p(state_p),
        .money_you_have_thousands(money_you_have_thousands),
        .money_you_have_hundreds(money_you_have_hundreds),
        .money_you_have_tens(money_you_have_tens),
        .money_you_have_ones(money_you_have_ones),    
        .money_you_bet_hundreds(money_you_bet_hundreds),
        .money_you_bet_tens(money_you_bet_tens),
        .money_you_bet_ones(money_you_bet_ones)
    );
    before_sevenseg segchoser(
        .state_p(state_p),
        .state_h(state_h),
        .ishost(ishost),
        .player_count(player_count),
        .ai_level(ai_level),
        .money_you_have_thousands(money_you_have_thousands),
        .money_you_have_hundreds(money_you_have_hundreds),
        .money_you_have_tens(money_you_have_tens),
        .money_you_have_ones(money_you_have_ones),    
        .money_you_bet_hundreds(money_you_bet_hundreds),
        .money_you_bet_tens(money_you_bet_tens),
        .money_you_bet_ones(money_you_bet_ones),
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
