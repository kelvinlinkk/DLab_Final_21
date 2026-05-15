module start_ui(
    input clk,
    input btnU,
    input btnC,
    input btnD,
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
    localparam NUM_1 = 6'd1;
    localparam NUM_2 = 6'd2;
    localparam NUM_3 = 6'd3;
    localparam NUM_4 = 6'd4;
    localparam CHAR_P = 6'd23;
    localparam CHAR_A = 6'd10;
    localparam CHAR_I = 6'd1;
    localparam S_PLAYER = 0;
    localparam S_AI     = 1;
    reg state = S_PLAYER;
    reg [1:0] player_count = 0;
    reg [1:0] ai_level = 1;
    always @(posedge clk)
    begin
        case(state)
            S_PLAYER:
            begin
                if(btnU)
                begin
                    if(player_count == 3)
                        player_count <= 0;
                    else
                        player_count <= player_count + 1;
                end
                if(btnC)
                begin
                    if(player_count == 0)
                        state <= S_AI;
                end
            end
            S_AI:
            begin
                if(btnU)
                begin
                    if(ai_level == 3)
                        ai_level <= 1;
                    else
                        ai_level <= ai_level + 1;
                end

                if(btnD)
                    state <= S_PLAYER;

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
                    0: d0 = NUM_1;
                    1: d0 = NUM_2;
                    2: d0 = NUM_3;
                    3: d0 = NUM_4;
                endcase

            end
            S_AI:
            begin
                d3 = CHAR_A;
                d2 = CHAR_I;
                case(ai_level)
                    1: d0 = NUM_1;
                    2: d0 = NUM_2;
                    3: d0 = NUM_3;
                endcase

            end

        endcase

    end

endmodule
