module start_ui_host(
    input clk,
    input rst_n,
    input btnU,
    input btnC,
    input btnD,
    input btnR,
    input btnL,
    input ishost,
    input startstartui,
    output reg backtogh_h=0,
    output reg [3:0] state_h,
    output reg [2:0] player_count = 3'd0,
    output reg [1:0] ai_level = 2'd1
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
    localparam S_PLAYER   = 4'd1;
    localparam S_AI       = 4'd2;  
    reg rst_reg = 1'b0;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state_h          <= S_IDLE;
            backtogh_h       <= 1'b0;
            rst_reg        <= 1'b0;
            player_count   <= 3'd0;
            ai_level       <= 2'd1;
        end else begin
            if (rst_reg) begin
                rst_reg        <= 1'b0;
            end
            backtogh_h <= 1'b0; 

            case(state_h)
                S_IDLE: begin
                    backtogh_h <= 1'b0;
                    if (startstartui) begin
                        if (ishost) begin
                            state_h <= S_PLAYER;
                        end
                    end
                end
                S_PLAYER: begin
                    if (btnU) begin
                        if (player_count == 3'd4) player_count <= 3'd0;
                        else player_count <= player_count + 3'd1;
                    end
                    if (btnC) begin
                        if (player_count == 3'd0) state_h <= S_AI;
                        else begin
                            backtogh_h <= 1'b1;
                            state_h    <= S_IDLE;
                        end
                    end
                    if (btnR) begin
                        backtogh_h <= 1'b1;
                        state_h    <= S_IDLE;
                    end
                end
                
                S_AI: begin
                    if (btnU) begin
                        if (ai_level == 2'd3) ai_level <= 2'd1;
                        else ai_level <= ai_level + 2'd1;
                    end
                    if (btnC) begin
                        backtogh_h <= 1'b1;
                        state_h    <= S_IDLE;
                    end
                    if (btnR) begin
                        state_h <= S_PLAYER;
                    end
                end                              
                default: state_h <= S_IDLE;
            endcase
        end
    end

endmodule
