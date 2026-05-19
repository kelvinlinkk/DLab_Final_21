module start_ui(
    input clk,
    input rst_n,
    input btnU,
    input btnC,
    input btnD,
    input btnR,
    input btnL,
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
    localparam CHAR_P = 6'd23;
    localparam CHAR_A = 6'd10;
    localparam CHAR_I = 6'd1;
    localparam S_PLAYER   = 4'd0;
    localparam S_AI       = 4'd1;
    localparam S_money_p1 = 4'd2;    
    reg [3:0] state = S_PLAYER;
    reg [1:0] player_count = 2'd0;
    reg [1:0] ai_level = 2'd1;
    reg [13:0] money_you_have = 14'd100;
    reg [9:0] money_you_bet = 10'd0;
    reg rst_reg = 1'b0;
    wire [5:0] money_you_have_thousands;
    wire [5:0] money_you_have_hundreds;
    wire [5:0] money_you_have_tens;
    wire [5:0] money_you_have_ones;    
    wire [5:0] money_you_bet_hundreds;
    wire [5:0] money_you_bet_tens;
    wire [5:0] money_you_bet_ones;
    assign money_you_have_thousands = money_you_have / 14'd1000;
    assign money_you_have_hundreds  = (money_you_have % 14'd1000) / 14'd100;
    assign money_you_have_tens      = (money_you_have % 14'd100) / 14'd10;
    assign money_you_have_ones      = money_you_have % 14'd10;

    assign money_you_bet_hundreds   = money_you_bet / 10'd100;
    assign money_you_bet_tens       = (money_you_bet % 10'd100) / 10'd10;
    assign money_you_bet_ones       = money_you_bet % 10'd10;
    always @(posedge clk)
    begin
        if(rst_reg | !rst_n)
        begin
            money_you_have <= 14'd100;
            money_you_bet  <= 10'd0;
            rst_reg          <= 1'b0;
        end                
        case(state)
            S_PLAYER:
            begin
                if(btnU)
                begin
                    if(player_count == 2'd3)
                        player_count <= 2'd0;
                    else
                        player_count <= player_count + 2'd1;
                end
                if(btnC)
                begin
                    if(player_count == 2'd0)
                        state <= S_AI;
                end
            end
            
            S_AI:
            begin
                if(btnU)
                begin
                    if(ai_level == 2'd3)
                        ai_level <= 2'd1;
                    else
                        ai_level <= ai_level + 2'd1;
                end
                if(btnC)
                begin
                    state <= S_money_p1;
                end
                if(btnR)
                begin
                    state <= S_PLAYER;
                end
            end
            
            S_money_p1:
            begin
                if(btnU)
                begin
                    if((money_you_have >= {4'd0,money_you_bet} + 14'd10) && ({4'd0,money_you_bet} + 14'd10 <= 14'd500))
                    begin
                        money_you_bet <= money_you_bet + 10'd10; 
                    end   
                end
                if(btnD)
                begin
                    if(money_you_bet >= 10'd10)
                    begin
                        money_you_bet <= money_you_bet - 10'd10;
                    end
                end
                if(btnL)
                begin
                    if((money_you_have >= {4'd0,money_you_bet} + 14'd100) && ({4'd0,money_you_bet} + 14'd100 <= 14'd500))
                    begin
                        money_you_bet <= money_you_bet + 10'd100; 
                    end
                end
                if(btnR)
                begin
                    state <= S_AI;
                    rst_reg <= 1'b1;
                end 
                if(btnC)
                begin //start single player

                end    
            end
            default:
            begin
                // default
            end
        endcase
    end
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
            S_PLAYER:
            begin
                d1 = CHAR_P;
                case(player_count)
                    2'd0: d0 = NUM_1;
                    2'd1: d0 = NUM_2;
                    2'd2: d0 = NUM_3;
                    2'd3: d0 = NUM_4;
                endcase
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
            
            S_money_p1:
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
            default:
            begin
                // default
            end
        endcase
    end

endmodule