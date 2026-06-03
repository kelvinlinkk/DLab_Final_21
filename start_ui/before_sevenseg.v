module before_sevenseg(
    input [3:0] state,
    input [3:0] state_game_play,
    input [3:0] state_h,
    input ishost,
    input [2:0] player_count,
    input [1:0] ai_level,
    input insurance_yn,
    input [5:0] money_you_have_thousands,
    input [5:0] money_you_have_hundreds,
    input [5:0] money_you_have_tens,
    input [5:0] money_you_have_ones,
    input [5:0] money_you_bet_thousands,    
    input [5:0] money_you_bet_hundreds,
    input [5:0] money_you_bet_tens,
    input [5:0] money_you_bet_ones,
    input [1:0] lose_win,
    input [3:0] card_0,
    input [3:0] card_1,
    input [3:0] card_2,
    input [3:0] card_3,
    input [3:0] card_4,
    input card_left_right, 
    input [3:0] host_card_0,
    input [3:0] host_card_1,
    input [3:0] host_card_2,
    input [3:0] host_card_3,
    input [3:0] host_card_4,
    input [3:0] host_card_5,
    input [3:0] host_card_6,
    input [3:0] host_card_7,
    input [3:0] host_card_8,
    input [3:0] host_page,
    input player_have_21_point,
    input host_have_21_point,
    output reg [5:0] d0,
    output reg [5:0] d1,
    output reg [5:0] d2,
    output reg [5:0] d3,
    output reg [5:0] d4,
    output reg [5:0] d5,
    output reg [5:0] d6,
    output reg [5:0] d7,
    output reg [3:0] rgb1_state = 4'd6
    );
    localparam BLANK = 6'd34;
    localparam NUM_0 = 6'd0;
    localparam NUM_1 = 6'd1;
    localparam NUM_2 = 6'd2;
    localparam NUM_3 = 6'd3;
    localparam NUM_4 = 6'd4;
    localparam NUM_5 = 6'd5;
    localparam CHAR_P = 6'd23;
    localparam CHAR_A = 6'd10;
    localparam CHAR_I = 6'd1;

    // top-level states
    localparam TOP_IDLE        = 4'b0000;
    localparam TOP_START_HOST  = 4'b0001;
    localparam TOP_START_GUEST = 4'b0010;
    localparam TOP_GAME_HOST   = 4'b0011;
    localparam TOP_GAME_GUEST  = 4'b0100;
    localparam TOP_START_AI    = 4'b0101;

    // host states
    // localparam H_IDLE             = 4'd0;
    // localparam H_PLAYER_COUNT     = 4'd1;
    // localparam H_AI_LEVEL         = 4'd2;
    localparam H_SHUFFLE          = 4'd3;
    localparam H_HOST_TWO_CARDS   = 4'b0100;
    localparam H_PLAYER_TWO_CARDS = 4'b0101;
    localparam H_PLAYER_TURN      = 4'b0110;
    localparam H_HOST_TURN        = 4'b0111;
    localparam H_GAME_OVER        = 4'b1000;
    localparam H_WAIT_BETS        = 4'd9;
    localparam H_WAIT_INSURANCE   = 4'd11;

    wire [3:0] h_cards_array [0:8];
    assign h_cards_array[0] = host_card_0;
    assign h_cards_array[1] = host_card_1;
    assign h_cards_array[2] = host_card_2;
    assign h_cards_array[3] = host_card_3;
    assign h_cards_array[4] = host_card_4;
    assign h_cards_array[5] = host_card_5;
    assign h_cards_array[6] = host_card_6;
    assign h_cards_array[7] = host_card_7;
    assign h_cards_array[8] = host_card_8;

    wire [3:0] disp_h0 = h_cards_array[host_page];
    wire [3:0] disp_h1 = (host_page < 8) ? h_cards_array[host_page + 1] : 4'd0;
    wire [3:0] disp_h2 = (host_page < 7) ? h_cards_array[host_page + 2] : 4'd0;
    wire [3:0] disp_h3 = (host_page < 6) ? h_cards_array[host_page + 3] : 4'd0;

    // player states (some matching old code)
    localparam S_IDLE     = 4'd0;
    localparam S_money_p1 = 4'd11;
    localparam S_PLAYER   = 4'd1;
    localparam S_AI       = 4'b0101;
    
    always @(*)
    begin
        d0 <= BLANK;
        d1 <= BLANK;
        d2 <= BLANK;
        d3 <= BLANK;
        d4 <= BLANK;
        d5 <= BLANK;
        d6 <= BLANK;
        d7 <= BLANK;
        rgb1_state <= 4'd6; // 加入這行！防止 latch 導致燈光卡死
        if(ishost==1'b0) begin
        case(state)
            TOP_IDLE:
            begin
                rgb1_state <= 4'd0;
                d3 <= 6'd23;
                d2 <= 6'd20;
                d1 <= 6'd10;
                d0 <= 6'd32;
            end    
            
            TOP_START_GUEST:
            begin
                case(state_game_play)
                4'd2: begin
                if(money_you_bet_thousands == 6'd0)
                begin
                    if(money_you_bet_hundreds == 6'd0)
                    begin
                        if(money_you_bet_tens == 6'd0)
                        begin
                            d7 <= BLANK;
                            d6 <= BLANK;
                            d5 <= BLANK;
                            d4 <= money_you_bet_ones;
                        end
                        else begin
                            d7 <= BLANK;
                            d6 <= BLANK;
                            d5 <= money_you_bet_tens;
                            d4 <= money_you_bet_ones;
                        end
                    end
                    else begin
                        d7 <= BLANK;
                        d6 <= money_you_bet_hundreds;
                        d5 <= money_you_bet_tens;
                        d4 <= money_you_bet_ones;
                    end
                end
                else begin
                    d7 <= money_you_bet_thousands;
                    d6 <= money_you_bet_hundreds;
                    d5 <= money_you_bet_tens;
                    d4 <= money_you_bet_ones;
                end
                if(insurance_yn==1'd1)begin
                    d0<=6'd32;
                end else begin
                    d0<=6'd22;
                end
                end
                4'd11: begin
                    if (player_have_21_point == 1'd1 && lose_win == 2'd3) begin
                        rgb1_state <= 4'd0; // Rainbow for Blackjack
                    end else if (lose_win==2'd1) begin
                        rgb1_state <= 4'd7;
                    end else if (lose_win==2'd2) begin
                        rgb1_state <= 4'd8;
                    end else if(lose_win==2'd3) begin
                        rgb1_state <= 4'd9;
                    end else begin
                        rgb1_state <= 4'd6;
                    end
                if(money_you_have_thousands == 6'd0)
                begin
                    if(money_you_have_hundreds == 6'd0)
                    begin
                        if(money_you_have_tens == 6'd0)
                        begin
                            d7 <= BLANK;
                            d6 <= BLANK;
                            d5 <= BLANK;
                            d4 <= money_you_have_ones;
                        end
                        else begin
                            d7 <= BLANK;
                            d6 <= BLANK;
                            d5 <= money_you_have_tens;
                            d4 <= money_you_have_ones;
                        end
                    end
                    else begin
                        d7 <= BLANK;
                        d6 <= money_you_have_hundreds;
                        d5 <= money_you_have_tens;
                        d4 <= money_you_have_ones;
                    end
                end
                else begin
                    d7 <= money_you_have_thousands;
                    d6 <= money_you_have_hundreds;
                    d5 <= money_you_have_tens;
                    d4 <= money_you_have_ones;
                end

                if(money_you_bet_thousands == 6'd0)
                begin
                    if(money_you_bet_hundreds == 6'd0)
                    begin
                        if(money_you_bet_tens == 6'd0)
                        begin
                            d3 <= BLANK;
                            d2 <= BLANK;
                            d1 <= BLANK;
                            d0 <= money_you_bet_ones;
                        end
                        else begin
                            d3 <= BLANK;
                            d2 <= BLANK;
                            d1 <= money_you_bet_tens;
                            d0 <= money_you_bet_ones;
                        end
                    end
                    else begin
                        d3 <= BLANK;
                        d2 <= money_you_bet_hundreds;
                        d1 <= money_you_bet_tens;
                        d0 <= money_you_bet_ones;
                    end
                end
                else begin
                    d3 <= money_you_bet_thousands;
                    d2 <= money_you_bet_hundreds;
                    d1 <= money_you_bet_tens;
                    d0 <= money_you_bet_ones;
                end
                end
                4'd9, 4'd12, 4'd13: begin // Settlement states
                    if (player_have_21_point == 1'd1 && lose_win == 2'd3) begin
                        rgb1_state <= 4'd0; // Rainbow for Blackjack
                    end else if (lose_win==2'd1) begin
                        rgb1_state <= 4'd7;
                    end else if (lose_win==2'd2) begin
                        rgb1_state <= 4'd8;
                    end else if(lose_win==2'd3) begin
                        rgb1_state <= 4'd9;
                    end else begin
                        rgb1_state <= 4'd6;
                    end
                    if (lose_win == 2'd1) begin // LOSE
                        d7 <= 6'd20; // L
                        d6 <= NUM_0; // O
                        d5 <= 6'd26; // S
                        d4 <= 6'd14; // E
                    end else if (lose_win == 2'd3) begin // WIN (COOL)
                        d7 <= 6'd12; // C
                        d6 <= NUM_0; // O
                        d5 <= NUM_0; // O
                        d4 <= 6'd20; // L
                    end else if (lose_win == 2'd2) begin // TIE (PUSH)
                        d7 <= 6'd23; // P
                        d6 <= 6'd28; // U
                        d5 <= 6'd26; // S
                        d4 <= 6'd17; // H
                    end else begin
                        d7 <= BLANK;
                        d6 <= BLANK;
                        d5 <= BLANK;
                        d4 <= BLANK;
                    end

                    // Display money_you_have on d3-d0
                    if(money_you_have_thousands == 6'd0)
                    begin
                        if(money_you_have_hundreds == 6'd0)
                        begin
                            if(money_you_have_tens == 6'd0)
                            begin
                                d3 <= BLANK;
                                d2 <= BLANK;
                                d1 <= BLANK;
                                d0 <= money_you_have_ones;
                            end
                            else begin
                                d3 <= BLANK;
                                d2 <= BLANK;
                                d1 <= money_you_have_tens;
                                d0 <= money_you_have_ones;
                            end
                        end
                        else begin
                            d3 <= BLANK;
                            d2 <= money_you_have_hundreds;
                            d1 <= money_you_have_tens;
                            d0 <= money_you_have_ones;
                        end
                    end
                    else begin
                        d3 <= money_you_have_thousands;
                        d2 <= money_you_have_hundreds;
                        d1 <= money_you_have_tens;
                        d0 <= money_you_have_ones;
                    end
                end
                4'd1: begin // check_host_ace (DEBUG)
                    rgb1_state <= 4'd6;
                    d3 <= CHAR_A;
                    d2 <= 6'd12; // C
                    d1 <= 6'd14; // E
                    d0 <= BLANK;
                end
                4'd3: begin // card_get_0 (DEBUG)
                    d7<= 6'd17; // H
                    d6 <= 6'd0; // O
                    d5<= 6'd20; // L
                    d4<=6'd13; // d
                    d3 <= BLANK;
                    d2 <= 6'd0;  // O
                    d1 <= 6'd22; // n
                    d0 <= BLANK;
                end
                4'd4: begin // card_get_1 (DEBUG)
                    d3 <= 6'd12; // C
                    d2 <= BLANK;
                    d1 <= NUM_1;
                    d0 <= BLANK;
                end
                4'd5, 4'd15: begin
                        rgb1_state <= 4'd6;
                    if (card_0 == 0) begin
                        d7 <= BLANK;
                        d6 <= BLANK;
                    end else begin
                        if (card_0 / 10) begin
                            d7 <= card_0 / 10;
                        end else begin
                            d7 <= BLANK;
                        end
                        d6 <= card_0 % 10;
                    end
                    d5 <= BLANK;
                    if (card_1 == 0) begin
                        d4 <= BLANK;
                        d3 <= BLANK;
                    end else begin
                        if (card_1 / 10) begin
                            d4 <= card_1 / 10;
                        end else begin
                            d4 <= BLANK;
                        end
                        d3 <= card_1 % 10;
                    end 
                    d2 <= BLANK;
                    d1 <= BLANK;
                    d0 <= BLANK; 
                end
                4'd6: begin
                        rgb1_state <= 4'd6;
                    if (card_0 == 0) begin
                        d7 <= BLANK;
                        d6 <= BLANK;
                    end else begin
                        if (card_0 / 10) begin
                            d7 <= card_0 / 10;
                        end else begin
                            d7 <= BLANK;
                        end
                        d6 <= card_0 % 10;
                    end
                    d5 <= BLANK;
                    if (card_1 == 0) begin
                        d4 <= BLANK;
                        d3 <= BLANK;
                    end else begin
                        if (card_1 / 10) begin
                            d4 <= card_1 / 10;
                        end else begin
                            d4 <= BLANK;
                        end
                        d3 <= card_1 % 10;
                    end 
                    d2 <= BLANK;
                    if (card_2 == 0) begin
                        d1 <= BLANK;
                        d0 <= BLANK;
                    end else begin
                        if (card_2 / 10) begin
                            d1 <= card_2 / 10;
                        end else begin
                            d1 <= BLANK;
                        end
                        d0 <= card_2 % 10;
                    end 
                end
                4'd7: begin
                    if (card_left_right) begin
                        if (card_1 == 0) begin
                        d7 <= BLANK;
                        d6 <= BLANK;
                    end else begin
                        if (card_1 / 10) begin
                            d7 <= card_1 / 10;
                        end else begin
                            d7 <= BLANK;
                        end
                        d6 <= card_1 % 10;
                    end
                    d5 <= BLANK;
                    if (card_2 == 0) begin
                        d4 <= BLANK;
                        d3 <= BLANK;
                    end else begin
                        if (card_2 / 10) begin
                            d4 <= card_2 / 10;
                        end else begin
                            d4 <= BLANK;
                        end
                        d3 <= card_2 % 10;
                    end 
                    d2 <= BLANK;
                    if (card_3 == 0) begin
                        d1 <= BLANK;
                        d0 <= BLANK;
                    end else begin
                        if (card_3 / 10) begin
                            d1 <= card_3 / 10;
                        end else begin
                            d1 <= BLANK;
                        end
                        d0 <= card_3 % 10;
                    end
                    end else begin
                         if (card_0 == 0) begin
                        d7 <= BLANK;
                        d6 <= BLANK;
                    end else begin
                        if (card_0 / 10) begin
                            d7 <= card_0 / 10;
                        end else begin
                            d7 <= BLANK;
                        end
                        d6 <= card_0 % 10;
                    end
                    d5 <= BLANK;
                    if (card_1 == 0) begin
                        d4 <= BLANK;
                        d3 <= BLANK;
                    end else begin
                        if (card_1 / 10) begin
                            d4 <= card_1 / 10;
                        end else begin
                            d4 <= BLANK;
                        end
                        d3 <= card_1 % 10;
                    end 
                    d2 <= BLANK;
                    if (card_2 == 0) begin
                        d1 <= BLANK;
                        d0 <= BLANK;
                    end else begin
                        if (card_2 / 10) begin
                            d1 <= card_2 / 10;
                        end else begin
                            d1 <= BLANK;
                        end
                        d0 <= card_2 % 10;
                    end           
                    end                   
                end
                
                4'd8: begin
                    if(player_have_21_point == 1'd1) begin
                        rgb1_state <= 4'd0;
                    end
                    if (card_left_right) begin
                        if (card_2 == 0) begin
                        d7 <= BLANK;
                        d6 <= BLANK;
                    end else begin
                        if (card_2 / 10) begin
                            d7 <= card_2 / 10;
                        end else begin
                            d7 <= BLANK;
                        end
                        d6 <= card_2 % 10;
                    end
                    d5 <= BLANK;
                    if (card_3 == 0) begin
                        d4 <= BLANK;
                        d3 <= BLANK;
                    end else begin
                        if (card_3 / 10) begin
                            d4 <= card_3 / 10;
                        end else begin
                            d4 <= BLANK;
                        end
                        d3 <= card_3 % 10;
                    end 
                    d2 <= BLANK;
                    if (card_4 == 0) begin
                        d1 <= BLANK;
                        d0 <= BLANK;
                    end else begin
                        if (card_4 / 10) begin
                            d1 <= card_4 / 10;
                        end else begin
                            d1 <= BLANK;
                        end
                        d0 <= card_4 % 10;
                    end
                    end else begin
                         if (card_0 == 0) begin
                        d7 <= BLANK;
                        d6 <= BLANK;
                    end else begin
                        if (card_0 / 10) begin
                            d7 <= card_0 / 10;
                        end else begin
                            d7 <= BLANK;
                        end
                        d6 <= card_0 % 10;
                    end
                    d5 <= BLANK;
                    if (card_1 == 0) begin
                        d4 <= BLANK;
                        d3 <= BLANK;
                    end else begin
                        if (card_1 / 10) begin
                            d4 <= card_1 / 10;
                        end else begin
                            d4 <= BLANK;
                        end
                        d3 <= card_1 % 10;
                    end 
                    d2 <= BLANK;
                    if (card_2 == 0) begin
                        d1 <= BLANK;
                        d0 <= BLANK;
                    end else begin
                        if (card_2 / 10) begin
                            d1 <= card_2 / 10;
                        end else begin
                            d1 <= BLANK;
                        end
                        d0 <= card_2 % 10;
                    end           
                    end
                end
                
                // removed duplicate case block
                endcase
            end    
            
            default:
            begin
                // default
            end
        endcase
        end else begin
            case(state)
                TOP_IDLE: begin
                        rgb1_state <= 4'd0;
                        d3 <= 6'd17;
                        d2 <= 6'd0;
                        d1 <= 6'd26;
                        d0 <= 6'd27;
                end
                
                TOP_START_HOST: begin
                    rgb1_state <= 4'd6;
                    d1 <= CHAR_P;
                    case(player_count)
                        3'd0: d0 <= NUM_0;
                        3'd1: d0 <= NUM_1;
                        3'd2: d0 <= NUM_2;
                        3'd3: d0 <= NUM_3;
                        3'd4: d0 <= NUM_4;
                        default: d0 <= NUM_0;
                    endcase
                end
                
                TOP_START_AI: begin
                    d3 <= CHAR_A;
                    d2 <= CHAR_I;
                    case(ai_level)
                        2'd1: d0 <= NUM_1;
                        2'd2: d0 <= NUM_2;
                        2'd3: d0 <= NUM_3;
                        default: d0 <= NUM_1;
                    endcase
                end
                
                // temporary ui
                TOP_GAME_HOST: begin
                    case(state_h)
                        H_SHUFFLE: begin
                            rgb1_state <= 4'd6;
                            d3 <= 6'd26; // S
                            d2 <= 6'd17; // H
                            d1 <= 6'd28; // U
                            d0 <= 6'd15; // F
                        end
                        H_HOST_TWO_CARDS: begin
                            rgb1_state <= 4'd6;
                            d3 <= 6'd17; // H
                            d2 <= 6'd34; // BLANK
                            d1 <= 6'd2;  // 2
                            d0 <= 6'd12; // C
                        end
                        H_PLAYER_TWO_CARDS: begin
                            rgb1_state <= 4'd6;
                            d3 <= 6'd23; // P
                            d2 <= 6'd34; // BLANK
                            d1 <= 6'd2;  // 2
                            d0 <= 6'd12; // C
                        end
                        H_PLAYER_TURN: begin
                            rgb1_state <= 4'd6;
                            d3 <= 6'd23; // P
                            d2 <= 6'd20; // L
                            d1 <= 6'd10; // A
                            d0 <= 6'd32; // Y
                        end
                        H_HOST_TURN, H_GAME_OVER: begin
                            if(host_have_21_point == 1'd1) begin
                                rgb1_state <= 4'd0;
                            end else begin
                                rgb1_state <= 4'd6;
                            end
                            
                            if (disp_h0 == 0) begin
                                d7 <= BLANK; d6 <= BLANK;
                            end else begin
                                if (disp_h0 / 10) d7 <= disp_h0 / 10; else d7 <= BLANK;
                                d6 <= disp_h0 % 10;
                            end
                            
                            if (disp_h1 == 0) begin
                                d5 <= BLANK; d4 <= BLANK;
                            end else begin
                                if (disp_h1 / 10) d5 <= disp_h1 / 10; else d5 <= BLANK;
                                d4 <= disp_h1 % 10;
                            end
                            
                            if (disp_h2 == 0) begin
                                d3 <= BLANK; d2 <= BLANK;
                            end else begin
                                if (disp_h2 / 10) d3 <= disp_h2 / 10; else d3 <= BLANK;
                                d2 <= disp_h2 % 10;
                            end
                            
                            if (disp_h3 == 0) begin
                                d1 <= BLANK; d0 <= BLANK;
                            end else begin
                                if (disp_h3 / 10) d1 <= disp_h3 / 10; else d1 <= BLANK;
                                d0 <= disp_h3 % 10;
                            end
                        end
                        H_WAIT_BETS: begin
                            rgb1_state <= 4'd6;
                            d3 <= 6'd30; // W
                            d2 <= 6'd10; // A
                            d1 <= 6'd18; // I
                            d0 <= 6'd27; // T
                        end
                        H_WAIT_INSURANCE: begin
                            rgb1_state <= 4'd6;
                            d3 <= 6'd26; // S
                            d2 <= 6'd10; // A
                            d1 <= 6'd15; // F
                            d0 <= 6'd14; // E
                        end
                        default: begin
                            rgb1_state <= 4'd6;
                            d3 <= 6'd34;
                            d2 <= 6'd34;
                            d1 <= 6'd34;
                            d0 <= 6'd34;
                        end
                    endcase
                end
                
                default: begin
                end
            endcase
        end
    end
endmodule