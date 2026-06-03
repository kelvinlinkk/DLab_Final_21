module start_ui_top(
    input sys_clk,
    input sys_rst_n,
    input SW15,
    input btnU,
    input btnC,
    input btnD,
    input btnR,
    input btnL,
    input signal_in_p,
    input signal_in_p1,
    input signal_in_p2,
    input signal_in_p3,
    input signal_in_p4,
    output [7:0] seg,
    output [7:0] an,
    output signal_out_p,
    output signal_out_p1,
    output signal_out_p2,
    output signal_out_p3,
    output signal_out_p4,
    output rgb1_r,
    output rgb1_g,
    output rgb1_b,
    output audio_out
);
    localparam init = 4'b0000;
    localparam start_host = 4'b0001;
    localparam start_guest = 4'b0010;
    localparam game_host = 4'b0011;
    localparam game_guest = 4'b0100;
    localparam start_ai = 4'b0101;
    reg [3:0] state=init;
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
    reg ishost=1'b0;
    wire backtogh_h;
    wire backtogh_p;
    wire startstartui = (state == start_host || state == start_guest) && !backtogh_h && !backtogh_p;
    always @(posedge clk_slow or negedge sys_rst_n) begin
        if (!sys_rst_n) begin
            ishost       <= 1'b0;
            state<=init;
        end else begin
            case(state)
            init:
            begin
                ishost <= SW15;
                if(pulseC & SW15)begin
                state<=start_host;
                end
                if(pulseC & !SW15)begin
                state<=start_guest;
                end
            end
            start_host:
            begin
                if(backtogh_h)
                begin
                    state<=game_host;
                end
                if(pulseC & !backtogh_h)
                begin
                    state<=start_ai;
                end
            end
            start_guest:
            begin
                if(backtogh_p)
                begin
                    state<=game_guest;
                end
            end
            start_ai:
            begin
                if(backtogh_h)
                begin
                    state<=game_host;
                end
            end
            game_host:
            begin
                state<=game_host;
            end
            game_guest:
            begin
                state<=game_guest;
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

    // Convert clk_slow pulses into 1-cycle sys_clk pulses for the fast FSMs
    reg [1:0] syncU, syncC, syncD, syncR, syncL;
    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n) begin
            syncU <= 2'b0; syncC <= 2'b0; syncD <= 2'b0; syncR <= 2'b0; syncL <= 2'b0;
        end else begin
            syncU <= {syncU[0], pulseU};
            syncC <= {syncC[0], pulseC};
            syncD <= {syncD[0], pulseD};
            syncR <= {syncR[0], pulseR};
            syncL <= {syncL[0], pulseL};
        end
    end
    wire pulseU_sys = (syncU == 2'b01);
    wire pulseC_sys = (syncC == 2'b01);
    wire pulseD_sys = (syncD == 2'b01);
    wire pulseR_sys = (syncR == 2'b01);
    wire pulseL_sys = (syncL == 2'b01);
    wire [5:0] d0;
    wire [5:0] d1;
    wire [5:0] d2;
    wire [5:0] d3;
    wire [5:0] d4;
    wire [5:0] d5;
    wire [5:0] d6;
    wire [5:0] d7;
    wire [2:0] player_count;
    wire [1:0] ai_level;
    wire [3:0] state_game_play_to_before_seg;
    wire [3:0] state_h_to_before_seg;
    wire [5:0] money_you_have_thousands;
    wire [5:0] money_you_have_hundreds;
    wire [5:0] money_you_have_tens;
    wire [5:0] money_you_have_ones;
    wire [5:0] money_you_bet_thousands;    
    wire [5:0] money_you_bet_hundreds;
    wire [5:0] money_you_bet_tens;
    wire [5:0] money_you_bet_ones;
    wire insurance_yn;
    wire [3:0] card_0;
    wire [3:0] card_1;
    wire [3:0] card_2;
    wire [3:0] card_3;
    wire [3:0] card_4;
    wire card_left_right;
    wire [1:0] lose_win;
    wire [3:0] host_card_0;
    wire [3:0] host_card_1;
    wire [3:0] host_card_2;
    wire [3:0] host_card_3;
    wire [3:0] host_card_4;
    wire [3:0] host_card_5;
    wire [3:0] host_card_6;
    wire [3:0] host_card_7;
    wire [3:0] host_card_8;
    wire [3:0] host_page;
    wire [3:0] rgb1_state;
    wire player_have_21_point;
    wire host_have_21_point;
    start_ui_host startui_h(
        .clk(sys_clk),
        .rst_n(sys_rst_n),
        .btnU(pulseU_sys),
        .btnC(pulseC_sys),
        .btnD(pulseD_sys),
        .btnR(pulseR_sys),
        .btnL(pulseL_sys),
        .ishost(ishost),
        .signal_in_1(signal_in_p1),
        .signal_in_2(signal_in_p2),
        .signal_in_3(signal_in_p3),
        .signal_in_4(signal_in_p4),
        .signal_out_1(signal_out_p1),
        .signal_out_2(signal_out_p2),
        .signal_out_3(signal_out_p3),
        .signal_out_4(signal_out_p4),
        .startstartui(startstartui),
        .backtogh_h(backtogh_h),
        .state_h(state_h_to_before_seg),
        .player_count(player_count),
        .ai_level(ai_level),
        .host_card_0(host_card_0),
        .host_card_1(host_card_1),
        .host_card_2(host_card_2),
        .host_card_3(host_card_3),
        .host_card_4(host_card_4),
        .host_card_5(host_card_5),
        .host_card_6(host_card_6),
        .host_card_7(host_card_7),
        .host_card_8(host_card_8),
        .host_page(host_page),
        .host_have_21_point(host_have_21_point)
    );
    game_player game_player(
        .clk(sys_clk),
        .rst_n(sys_rst_n),
        .host_ace(),
        .btnU(pulseU_sys),
        .btnC(pulseC_sys),
        .btnD(pulseD_sys),
        .btnR(pulseR_sys),
        .btnL(pulseL_sys),
        .signal_in(signal_in_p),
        .ishost(ishost),
        .startstartui(startstartui),
        .lose_win(lose_win),
        .insurance_yn(insurance_yn),
        .backtogh_p(backtogh_p),
        .state(state_game_play_to_before_seg),
        .card_0(card_0),
        .card_1(card_1),
        .card_2(card_2),
        .card_3(card_3),
        .card_4(card_4),
        .card_left_right(card_left_right),
        .signal_out(signal_out_p),
        .money_you_have_thousands(money_you_have_thousands),
        .money_you_have_hundreds(money_you_have_hundreds),
        .money_you_have_tens(money_you_have_tens),
        .money_you_have_ones(money_you_have_ones),
        .money_you_bet_thousands(money_you_bet_thousands),    
        .money_you_bet_hundreds(money_you_bet_hundreds),
        .money_you_bet_tens(money_you_bet_tens),
        .money_you_bet_ones(money_you_bet_ones),
        .player_have_21_point(player_have_21_point)
    );
    before_sevenseg segchoser(
        .state(state),
        .state_game_play(state_game_play_to_before_seg),
        .state_h(state_h_to_before_seg),
        .ishost(ishost),
        .player_count(player_count),
        .ai_level(ai_level),
        .insurance_yn(insurance_yn),
        .money_you_have_thousands(money_you_have_thousands),
        .money_you_have_hundreds(money_you_have_hundreds),
        .money_you_have_tens(money_you_have_tens),
        .money_you_have_ones(money_you_have_ones),
        .money_you_bet_thousands(money_you_bet_thousands),    
        .money_you_bet_hundreds(money_you_bet_hundreds),
        .money_you_bet_tens(money_you_bet_tens),
        .money_you_bet_ones(money_you_bet_ones),
        .lose_win(lose_win),
        .card_0(card_0),
        .card_1(card_1),
        .card_2(card_2),
        .card_3(card_3),
        .card_4(card_4),
        .host_card_0(host_card_0),
        .host_card_1(host_card_1),
        .host_card_2(host_card_2),
        .host_card_3(host_card_3),
        .host_card_4(host_card_4),
        .host_card_5(host_card_5),
        .host_card_6(host_card_6),
        .host_card_7(host_card_7),
        .host_card_8(host_card_8),
        .host_page(host_page),
        .player_have_21_point(player_have_21_point),
        .host_have_21_point(host_have_21_point),
        .card_left_right(card_left_right),
        .d0(d0),
        .d1(d1),
        .d2(d2),
        .d3(d3),
        .d4(d4),
        .d5(d5),
        .d6(d6),
        .d7(d7),
        .rgb1_state(rgb1_state)
    );
    color_fsm rgb1(
        .sys_clk(sys_clk), // 補上遺失的系統時脈，否則 PWM 產生器會死當
        .slow_clk(clk_slow),
        .rgb1_state(rgb1_state),
        .rgb1_r(rgb1_r),
        .rgb1_g(rgb1_g),
        .rgb1_b(rgb1_b)   
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

    // 音效觸發邏輯與狀態追蹤
    reg [3:0] last_state_p;
    reg [3:0] last_state_h;
    reg [3:0] last_card_0, last_card_1, last_card_2, last_card_3, last_card_4;
    reg [3:0] last_host_card_0, last_host_card_1, last_host_card_2, last_host_card_3, last_host_card_4, last_host_card_5, last_host_card_6, last_host_card_7, last_host_card_8;

    reg play_sound = 1'b0;
    reg [3:0] sound_id = 4'd0;

    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n) begin
            last_state_p <= 4'd10; // S_IDLE
            last_state_h <= 4'd0;  // S_IDLE
            last_card_0 <= 4'd0; last_card_1 <= 4'd0; last_card_2 <= 4'd0; last_card_3 <= 4'd0; last_card_4 <= 4'd0;
            last_host_card_0 <= 4'd0; last_host_card_1 <= 4'd0; last_host_card_2 <= 4'd0; last_host_card_3 <= 4'd0; last_host_card_4 <= 4'd0;
            play_sound <= 1'b0;
            sound_id <= 4'd0;
        end else begin
            // 預設不觸發音效 (pulse)
            play_sound <= 1'b0;

            // 更新歷史狀態
            last_state_p <= state_game_play_to_before_seg;
            last_state_h <= state_h_to_before_seg;
            last_card_0 <= card_0; last_card_1 <= card_1; last_card_2 <= card_2; last_card_3 <= card_3; last_card_4 <= card_4;
            last_host_card_0 <= host_card_0; last_host_card_1 <= host_card_1; last_host_card_2 <= host_card_2; last_host_card_3 <= host_card_3; last_host_card_4 <= host_card_4;
            last_host_card_5 <= host_card_5; last_host_card_6 <= host_card_6; last_host_card_7 <= host_card_7; last_host_card_8 <= host_card_8;

            // 1. 遊戲結算音效 (優先級最高)
            if (last_state_p == 4'd12 && state_game_play_to_before_seg == 4'd13) begin
                play_sound <= 1'b1;
                if (lose_win == 2'd1) sound_id <= 4'd1; // LOSE
                else if (lose_win == 2'd2) sound_id <= 4'd3; // TIE
                else if (lose_win == 2'd3) begin
                    if (player_have_21_point || card_4 != 4'd0) sound_id <= 4'd8; // BJ or 5-Card Charlie
                    else sound_id <= 4'd0; // Normal WIN
                end
            end
            // 2. 下注音效
            else if (last_state_p == 4'd11 && state_game_play_to_before_seg == 4'd0) begin
                play_sound <= 1'b1;
                sound_id <= 4'd5; // BET
            end
            // 3. 發牌音效
            else if ((card_0 != last_card_0 && card_0 != 0) ||
                     (card_1 != last_card_1 && card_1 != 0) ||
                     (card_2 != last_card_2 && card_2 != 0) ||
                     (card_3 != last_card_3 && card_3 != 0) ||
                     (card_4 != last_card_4 && card_4 != 0) ||
                     (host_card_0 != last_host_card_0 && host_card_0 != 0) ||
                     (host_card_1 != last_host_card_1 && host_card_1 != 0) ||
                     (host_card_2 != last_host_card_2 && host_card_2 != 0) ||
                     (host_card_3 != last_host_card_3 && host_card_3 != 0) ||
                     (host_card_4 != last_host_card_4 && host_card_4 != 0) ||
                     (host_card_5 != last_host_card_5 && host_card_5 != 0) ||
                     (host_card_6 != last_host_card_6 && host_card_6 != 0) ||
                     (host_card_7 != last_host_card_7 && host_card_7 != 0) ||
                     (host_card_8 != last_host_card_8 && host_card_8 != 0)) begin
                play_sound <= 1'b1;
                sound_id <= 4'd4; // DEAL
            end
            // 4. 操作音效 (按鍵操作)
            else if (pulseU_sys || pulseD_sys || pulseL_sys || pulseR_sys || pulseC_sys) begin
                play_sound <= 1'b1;
                sound_id <= 4'd2; // CTRL
            end
        end
    end

    audio_ctl audio_inst(
        .clk(sys_clk),
        .rst_n(sys_rst_n),
        .play_sound(play_sound),
        .sound_id(sound_id),
        .audio_out(audio_out)
    );

endmodule
