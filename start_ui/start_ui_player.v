module start_ui_player(
    input clk,
    input rst_n,
    input btnU,
    input btnC,
    input btnD,
    input btnR,
    input btnL,
    input ishost,
    input startstartui,
    output reg backtogh_p = 0,
    output reg [3:0] state_p,
    output [5:0] money_you_have_thousands,
    output [5:0] money_you_have_hundreds,
    output [5:0] money_you_have_tens,
    output [5:0] money_you_have_ones,    
    output [5:0] money_you_bet_hundreds,
    output [5:0] money_you_bet_tens,
    output [5:0] money_you_bet_ones
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

    reg [13:0] money_you_have = 14'd100;
    reg [9:0] money_you_bet = 10'd0;
    reg rst_reg = 1'b0;

    assign money_you_have_thousands = money_you_have / 14'd1000;
    assign money_you_have_hundreds  = (money_you_have % 14'd1000) / 14'd100;
    assign money_you_have_tens      = (money_you_have % 14'd100) / 14'd10;
    assign money_you_have_ones      = money_you_have % 14'd10;

    assign money_you_bet_hundreds   = money_you_bet / 10'd100;
    assign money_you_bet_tens       = (money_you_bet % 10'd100) / 10'd10;
    assign money_you_bet_ones       = money_you_bet % 10'd10;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state_p         <= S_IDLE;
            money_you_have  <= 14'd100;
            money_you_bet   <= 10'd0;
            backtogh_p      <= 1'b0;
            rst_reg         <= 1'b0;
        end else begin
            if (rst_reg) begin
                money_you_have <= 14'd100;
                money_you_bet  <= 10'd0;
                rst_reg        <= 1'b0;
            end           
            backtogh_p <= 1'b0;

            case(state_p)
                S_IDLE: begin
                    if (startstartui) begin
                        if (!ishost) begin
                            state_p <= S_money_p1;
                        end
                    end
                end
                S_money_p1: begin
                    if (btnU) begin
                        if ((money_you_have >= {4'd0,money_you_bet} + 14'd20) && ({4'd0,money_you_bet} + 14'd20 <= 14'd500))
                            money_you_bet <= money_you_bet + 10'd20;
                    end
                    if (btnD) begin
                        if (money_you_bet >= 10'd20)
                            money_you_bet <= money_you_bet - 10'd20;
                    end
                    if (btnL) begin
                        if ((money_you_have >= {4'd0,money_you_bet} + 14'd100) && ({4'd0,money_you_bet} + 14'd100 <= 14'd500))
                            money_you_bet <= money_you_bet + 10'd100;
                    end
                    if (btnR) begin
                        backtogh_p <= 1'b1;
                        state_p    <= S_IDLE;
                        rst_reg    <= 1'b1;
                    end 
                    if (btnC) begin
                        backtogh_p <= 1'b1;
                        state_p <= S_IDLE; // 設定完成，直接結束回到 IDLE 狀態
                    end
                end
                default: state_p <= S_IDLE;
            endcase
        end
    end

endmodule