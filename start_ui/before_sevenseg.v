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
    output reg [5:0] d0,
    output reg [5:0] d1,
    output reg [5:0] d2,
    output reg [5:0] d3,
    output reg [5:0] d4,
    output reg [5:0] d5,
    output reg [5:0] d6,
    output reg [5:0] d7,
    output reg rgb1_r = 0,
    output reg rgb1_g = 0,
    output reg rgb1_b = 0
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
    localparam H_HOST_TWO_CARDS   = 4'd4;
    localparam H_PLAYER_TWO_CARDS = 4'd5;
    localparam H_PLAYER_TURN      = 4'd6;
    localparam H_HOST_TURN        = 4'd7;
    localparam H_GAME_OVER        = 4'd8;

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
        if(ishost==1'b0) begin
        case(state)
            TOP_IDLE:
            begin
                d3 <= 6'd23;
                d2 <= 6'd20;
                d1 <= 6'd10;
                d0 <= 6'd32;
            end    
            
            TOP_START_GUEST:
            begin
                case(state_game_play)
                4'd11: begin
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
                4'd2: begin
                        rgb1_r <= 0;
                        rgb1_g <= 0;
                        rgb1_b <= 0;
                    if(insurance_yn) begin
                        rgb1_g <= 1;
                     end else begin
                        rgb1_r <= 1;
                    end
                end
                4'd5: begin
                        rgb1_r <= 0;
                        rgb1_g <= 0;
                        rgb1_b <= 0;
                    if (card_0 / 10) begin
                        d7 <= card_0 / 10;
                    end else begin
                        d7 <= BLANK;
                    end
                    d6 <= card_0 % 10;
                    d5 <= BLANK;
                    if (card_1 / 10) begin
                        d4 <= card_1 / 10;
                    end else begin
                        d4 <= BLANK;
                    end 
                    d3 <= card_1 % 10; 
                    d2 <= BLANK;
                    d1 <= BLANK;
                    d0 <= BLANK; 
                end
                4'd6: begin
                        rgb1_r <= 0;
                        rgb1_g <= 0;
                        rgb1_b <= 0;
                    if (card_0 / 10) begin
                        d7 <= card_0 / 10;
                    end else begin
                        d7 <= BLANK;
                    end
                    d6 <= card_0 % 10;
                    d5 <= BLANK;
                    if (card_1 / 10) begin
                        d4 <= card_1 / 10;
                    end else begin
                        d4 <= BLANK;
                    end 
                    d3 <= card_1 % 10; 
                    d2 <= BLANK;
                    if (card_2 / 10) begin
                        d1 <= card_2 / 10;
                    end else begin
                        d1 <= BLANK;
                    end 
                    d0 <= card_2 % 10; 
                end
                4'd7: begin
                    if (card_left_right) begin
                        if (card_1 / 10) begin
                        d7 <= card_1 / 10;
                    end else begin
                        d7 <= BLANK;
                    end
                    d6 <= card_1 % 10;
                    d5 <= BLANK;
                    if (card_2 / 10) begin
                        d4 <= card_2 / 10;
                    end else begin
                        d4 <= BLANK;
                    end 
                    d3 <= card_2 % 10; 
                    d2 <= BLANK;
                    if (card_3 / 10) begin
                        d1 <= card_3 / 10;
                    end else begin
                        d1 <= BLANK;
                    end 
                    d0 <= card_3 % 10;
                    end else begin
                         if (card_0 / 10) begin
                        d7 <= card_0 / 10;
                    end else begin
                        d7 <= BLANK;
                    end
                    d6 <= card_0 % 10;
                    d5 <= BLANK;
                    if (card_1 / 10) begin
                        d4 <= card_1 / 10;
                    end else begin
                        d4 <= BLANK;
                    end 
                    d3 <= card_1 % 10; 
                    d2 <= BLANK;
                    if (card_2 / 10) begin
                        d1 <= card_2 / 10;
                    end else begin
                        d1 <= BLANK;
                    end 
                    d0 <= card_2 % 10;           
                    end                   
                end
                
                4'd8: begin
                    if (card_left_right) begin
                        if (card_2 / 10) begin
                        d7 <= card_2 / 10;
                    end else begin
                        d7 <= BLANK;
                    end
                    d6 <= card_2 % 10;
                    d5 <= BLANK;
                    if (card_3 / 10) begin
                        d4 <= card_3 / 10;
                    end else begin
                        d4 <= BLANK;
                    end 
                    d3 <= card_3 % 10; 
                    d2 <= BLANK;
                    if (card_4 / 10) begin
                        d1 <= card_4 / 10;
                    end else begin
                        d1 <= BLANK;
                    end 
                    d0 <= card_4 % 10;
                    end else begin
                         if (card_0 / 10) begin
                        d7 <= card_0 / 10;
                    end else begin
                        d7 <= BLANK;
                    end
                    d6 <= card_0 % 10;
                    d5 <= BLANK;
                    if (card_1 / 10) begin
                        d4 <= card_1 / 10;
                    end else begin
                        d4 <= BLANK;
                    end 
                    d3 <= card_1 % 10; 
                    d2 <= BLANK;
                    if (card_2 / 10) begin
                        d1 <= card_2 / 10;
                    end else begin
                        d1 <= BLANK;
                    end 
                    d0 <= card_2 % 10;           
                    end
                end
                
                4'd11: begin
                    rgb1_r <= 0;
                    rgb1_g <= 0;
                    rgb1_b <= 0;
                    if (lose_win==2'd1) begin
                        rgb1_r <= 1;
                        rgb1_g <= 0;
                        rgb1_b <= 0;
                    end else if (lose_win==2'd2) begin
                        rgb1_r <= 1;
                        rgb1_g <= 1;
                        rgb1_b <= 0;
                    end else if(lose_win==2'd3) begin
                        rgb1_r <= 0;
                        rgb1_g <= 1;
                        rgb1_b <= 0;
                    end
                    
                end
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
                        d3 <= 6'd17;
                        d2 <= 6'd0;
                        d1 <= 6'd26;
                        d0 <= 6'd27;
                end
                
                TOP_START_HOST: begin
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
                            d3 <= 6'd26; // S
                            d2 <= 6'd17; // H
                            d1 <= 6'd28; // U
                            d0 <= 6'd15; // F
                        end
                        H_HOST_TWO_CARDS: begin
                            d3 <= 6'd17; // H
                            d2 <= 6'd34; // BLANK
                            d1 <= 6'd2;  // 2
                            d0 <= 6'd12; // C
                        end
                        H_PLAYER_TWO_CARDS: begin
                            d3 <= 6'd23; // P
                            d2 <= 6'd34; // BLANK
                            d1 <= 6'd2;  // 2
                            d0 <= 6'd12; // C
                        end
                        H_PLAYER_TURN: begin
                            d3 <= 6'd23; // P
                            d2 <= 6'd20; // L
                            d1 <= 6'd10; // A
                            d0 <= 6'd32; // Y
                        end
                        H_HOST_TURN: begin
                            d3 <= 6'd17; // H
                            d2 <= 6'd0;  // O
                            d1 <= 6'd26; // S
                            d0 <= 6'd27; // T
                        end
                        H_GAME_OVER: begin
                            d3 <= 6'd26; // S
                            d2 <= 6'd27; // T
                            d1 <= 6'd0;  // O
                            d0 <= 6'd23; // P
                        end
                        default: begin
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