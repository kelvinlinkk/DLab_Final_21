module before_sevenseg(
    input [3:0] state,
    input ishost,
    input [2:0] player_count,
    input [1:0] ai_level,
    input [5:0] money_you_have_thousands,
    input [5:0] money_you_have_hundreds,
    input [5:0] money_you_have_tens,
    input [5:0] money_you_have_ones,    
    input [5:0] money_you_bet_hundreds,
    input [5:0] money_you_bet_tens,
    input [5:0] money_you_bet_ones,
    output reg [5:0] d0,
    output reg [5:0] d1,
    output reg [5:0] d2,
    output reg [5:0] d3,
    output reg [5:0] d4,
    output reg [5:0] d5,
    output reg [5:0] d6,
    output reg [5:0] d7
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
    localparam S_IDLE     = 4'd0;
    localparam S_money_p1 = 4'd1;
    localparam S_PLAYER   = 4'd1;
    localparam S_AI       = 4'b0101;
    
    always @(*)
    begin
        d0 = BLANK;
        d1 = BLANK;
        d2 = BLANK;
        d3 = BLANK;
        d4 = BLANK;
        d5 = BLANK;
        d6 = BLANK;
        d7 = BLANK;

        case(state)
            S_IDLE:
            begin
                if (ishost) begin
                    d3 = 6'd17;
                    d2 = 6'd0;
                    d1 = 6'd26;
                    d0 = 6'd27;
                end else begin
                    d3 = 6'd23;
                    d2 = 6'd20;
                    d1 = 6'd10;
                    d0 = 6'd32;
                end  
            end    
            
            4'b0001:
            begin
                d1 = CHAR_P;
                case(player_count)
                    3'd0: d0 = NUM_0;
                    3'd1: d0 = NUM_1;
                    3'd2: d0 = NUM_2;
                    3'd3: d0 = NUM_3;
                    3'd4: d0 = NUM_4;
                    default:begin
                        d0 = NUM_0;
                    end
                endcase
            end 
            4'b0010:
            begin
                if(money_you_have_thousands == 6'd0)
                begin
                    if(money_you_have_hundreds == 6'd0)
                    begin
                        if(money_you_have_tens == 6'd0)
                        begin
                            d7 = BLANK;
                            d6 = BLANK;
                            d5 = BLANK;
                            d4 = money_you_have_ones;
                        end
                        else begin
                            d7 = BLANK;
                            d6 = BLANK;
                            d5 = money_you_have_tens;
                            d4 = money_you_have_ones;
                        end
                    end
                    else begin
                        d7 = BLANK;
                        d6 = money_you_have_hundreds;
                        d5 = money_you_have_tens;
                        d4 = money_you_have_ones;
                    end
                end
                else begin
                    d7 = money_you_have_thousands;
                    d6 = money_you_have_hundreds;
                    d5 = money_you_have_tens;
                    d4 = money_you_have_ones;
                end

                if(money_you_bet_hundreds == 0)
                begin
                    if(money_you_bet_tens == 0)
                    begin
                        d2 = BLANK;
                        d1 = BLANK;
                        d0 = money_you_bet_ones;
                    end
                    else begin
                        d2 = BLANK;
                        d1 = money_you_bet_tens;
                        d0 = money_you_bet_ones;
                    end
                end
                else begin
                    d2 = money_you_bet_hundreds;
                    d1 = money_you_bet_tens;
                    d0 = money_you_bet_ones;
                end
            end    
            
            S_AI:
            begin
                d3 = CHAR_A;
                d2 = CHAR_I;
                case(ai_level)
                    2'd1: d0 = NUM_1;
                    2'd2: d0 = NUM_2;
                    2'd3: d0 = NUM_3;
                    default: d0=NUM_1;
                endcase
            end
            default:
            begin
                // default
            end
        endcase
    end
endmodule