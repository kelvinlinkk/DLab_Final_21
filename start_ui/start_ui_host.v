module start_ui_host (
    input clk,
    input rst_n,
    input btnU,
    input btnC,
    input btnD,
    input btnR,
    input btnL,
    input ishost,
    input startstartui,
    
    input signal_in_1,
    input signal_in_2,
    input signal_in_3,
    input signal_in_4,
    output signal_out_1,
    output signal_out_2,
    output signal_out_3,
    output signal_out_4,

    output reg backtogh_h = 0,
    output reg [3:0] state_h,
    output reg [2:0] player_count = 3'd0,
    output reg [1:0] ai_level = 2'd1
);

    localparam S_IDLE              = 4'd0;
    localparam S_PLAYER            = 4'd1;
    localparam S_AI                = 4'd2;  
    
    localparam S_SHUFFLE           = 4'd3;
    localparam S_HOST_TWO_CARDS    = 4'd4;
    localparam S_PLAYER_TWO_CARDS  = 4'd5;
    localparam S_PLAYER_TURN       = 4'd6;
    localparam S_HOST_TURN         = 4'd7;
    localparam S_GAME_OVER         = 4'd8;

    localparam BLANK  = 6'd34;
    localparam NUM_0  = 6'd0;
    localparam NUM_1  = 6'd1;
    localparam NUM_2  = 6'd2;
    localparam NUM_3  = 6'd3;
    localparam NUM_4  = 6'd4;
    localparam NUM_5  = 6'd5;
    localparam CHAR_P = 6'd23;
    localparam CHAR_A = 6'd10;
    localparam CHAR_I = 6'd1;

    reg [3:0] cards [0:8];
    reg [3:0] host_card_count;
    wire [5:0] host_total_score;
    
    reg shuffle_reg;
    reg pull_reg;
    wire [3:0] drawn_card;
    reg [2:0] current_player;
    reg [1:0] deal_step;

    reg [7:0] tx_reg_1, tx_reg_2, tx_reg_3, tx_reg_4;
    reg tx_valid_1, tx_valid_2, tx_valid_3, tx_valid_4;
    wire tx_busy_1, tx_busy_2, tx_busy_3, tx_busy_4;

    wire [7:0] rx_wire_1, rx_wire_2, rx_wire_3, rx_wire_4;
    wire rx_valid_1, rx_valid_2, rx_valid_3, rx_valid_4;
    reg [7:0] rx_reg_1, rx_reg_2, rx_reg_3, rx_reg_4;

    wire btnC_pulse;
    integer k;
    press_button pb_c (
        .clk(clk),
        .btn(btnC),
        .pulse(btnC_pulse)
    );

    // 隨機發牌/洗牌硬體核心
    serve card_server (
        .clk(clk),
        .rst_n(rst_n),
        .shuffle(shuffle_reg),
        .pull(pull_reg),
        .out_card(drawn_card)
    );

    rx rx_inst1 (.clk(clk), .rst_n(rst_n), .signal_in(signal_in_1), .out(rx_wire_1), .valid(rx_valid_1));
    rx rx_inst2 (.clk(clk), .rst_n(rst_n), .signal_in(signal_in_2), .out(rx_wire_2), .valid(rx_valid_2));
    rx rx_inst3 (.clk(clk), .rst_n(rst_n), .signal_in(signal_in_3), .out(rx_wire_3), .valid(rx_valid_3));
    rx rx_inst4 (.clk(clk), .rst_n(rst_n), .signal_in(signal_in_4), .out(rx_wire_4), .valid(rx_valid_4));

    tx tx_inst1 (.clk(clk), .rst_n(rst_n), .data_in(tx_reg_1), .valid(tx_valid_1), .signal_out(signal_out_1), .busy(tx_busy_1));
    tx tx_inst2 (.clk(clk), .rst_n(rst_n), .data_in(tx_reg_2), .valid(tx_valid_2), .signal_out(signal_out_2), .busy(tx_busy_2));
    tx tx_inst3 (.clk(clk), .rst_n(rst_n), .data_in(tx_reg_3), .valid(tx_valid_3), .signal_out(signal_out_3), .busy(tx_busy_3));
    tx tx_inst4 (.clk(clk), .rst_n(rst_n), .data_in(tx_reg_4), .valid(tx_valid_4), .signal_out(signal_out_4), .busy(tx_busy_4));

    assign host_total_score = cards[0] + cards[1] + cards[2] + cards[3] + 
                              cards[4] + cards[5] + cards[6] + cards[7] + cards[8];

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state_h          <= S_IDLE;
            backtogh_h       <= 1'b0;
            player_count     <= 3'd0;
            ai_level         <= 2'd1;
            
            shuffle_reg      <= 1'b0;
            pull_reg         <= 1'b0;
            host_card_count  <= 4'd0;
            current_player   <= 3'd1;
            deal_step        <= 2'd0;

            tx_reg_1         <= 8'b0;
            tx_reg_2         <= 8'b0;
            tx_reg_3         <= 8'b0;
            tx_reg_4         <= 8'b0;
            tx_valid_1       <= 1'b0;
            tx_valid_2       <= 1'b0;
            tx_valid_3       <= 1'b0;
            tx_valid_4       <= 1'b0;

            rx_reg_1         <= 8'b0;
            rx_reg_2         <= 8'b0;
            rx_reg_3         <= 8'b0;
            rx_reg_4         <= 8'b0;

            for (k = 0; k < 9; k = k + 1) begin
                cards[k]     <= 4'd0;
            end
        end else begin
            tx_valid_1 <= 1'b0;
            tx_valid_2 <= 1'b0;
            tx_valid_3 <= 1'b0;
            tx_valid_4 <= 1'b0;

            rx_reg_1   <= rx_wire_1;
            rx_reg_2   <= rx_wire_2;
            rx_reg_3   <= rx_wire_3;
            rx_reg_4   <= rx_wire_4;

            case (state_h)
                S_IDLE: begin
                    backtogh_h <= 1'b0;
                    if (startstartui && ishost) begin
                        state_h <= S_PLAYER;
                    end
                end

                S_PLAYER: begin
                    if (btnU) begin
                        if (player_count == 3'd4) player_count <= 3'd0;
                        else player_count <= player_count + 3'd1;
                    end
                    if (btnC) begin
                        if (player_count == 3'd0) begin
                            state_h <= S_AI;
                        end else begin
                            backtogh_h <= 1'b1; 
                            state_h    <= S_SHUFFLE; 
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
                        state_h    <= S_SHUFFLE;
                    end
                    if (btnR) begin
                        state_h <= S_PLAYER;
                    end
                end                              

                S_SHUFFLE: begin
                    if (btnD == 1'b1)
                        shuffle_reg <= 1'b1;
                    else
                        shuffle_reg <= 1'b0;
                        
                    if (btnC) begin
                        state_h <= S_HOST_TWO_CARDS;
                    end
                end

                S_HOST_TWO_CARDS: begin
                    if (cards[1] != 4'd0) begin
                        pull_reg <= 1'b0;
                        state_h  <= S_PLAYER_TWO_CARDS;
                        
                        if (cards[1] == 4'd1) begin
                            tx_reg_1 <= 8'b10000001; tx_reg_2 <= 8'b10000001;
                            tx_reg_3 <= 8'b10000001; tx_reg_4 <= 8'b10000001;
                        end else begin
                            tx_reg_1 <= 8'b10000000; tx_reg_2 <= 8'b10000000;
                            tx_reg_3 <= 8'b10000000; tx_reg_4 <= 8'b10000000;
                        end
                        tx_valid_1 <= 1'b1; tx_valid_2 <= 1'b1;
                        tx_valid_3 <= 1'b1; tx_valid_4 <= 1'b1;
                    end else begin
                        if (!pull_reg) begin
                            pull_reg <= 1'b1;
                        end else if (pull_reg) begin
                            pull_reg <= 1'b0;
                            cards[host_card_count] <= drawn_card;
                            host_card_count        <= host_card_count + 4'd1;
                        end
                    end
                end

                S_PLAYER_TWO_CARDS: begin
                    if (current_player <= {1'b0, player_count}) begin
                        case (deal_step)
                            2'd0: begin
                                if (!tx_busy_1 && !tx_valid_1 && !tx_busy_2 && !tx_valid_2 && !tx_busy_3 && !tx_valid_3 && !tx_busy_4 && !tx_valid_4) begin
                                    if (!pull_reg) begin
                                        pull_reg <= 1'b1;
                                    end else if (pull_reg) begin
                                        pull_reg <= 1'b0;
                                        case (current_player)
                                            3'd1: tx_reg_1 <= {4'b1010, drawn_card};
                                            3'd2: tx_reg_2 <= {4'b1010, drawn_card};
                                            3'd3: tx_reg_3 <= {4'b1010, drawn_card};
                                            3'd4: tx_reg_4 <= {4'b1010, drawn_card};
                                        endcase
                                        case (current_player)
                                            3'd1: tx_valid_1 <= 1'b1; 3'd2: tx_valid_2 <= 1'b1;
                                            3'd3: tx_valid_3 <= 1'b1; 3'd4: tx_valid_4 <= 1'b1;
                                        endcase
                                        deal_step <= 2'd1;
                                    end
                                end
                            end
                            2'd1: begin
                                if (!tx_busy_1 && !tx_valid_1 && !tx_busy_2 && !tx_valid_2 && !tx_busy_3 && !tx_valid_3 && !tx_busy_4 && !tx_valid_4)
                                    deal_step <= 2'd2;
                            end
                            2'd2: begin
                                if (!pull_reg) begin
                                    pull_reg <= 1'b1;
                                end else if (pull_reg) begin
                                    pull_reg <= 1'b0;
                                    case (current_player)
                                        3'd1: tx_reg_1 <= {4'b1011, drawn_card};
                                        3'd2: tx_reg_2 <= {4'b1011, drawn_card};
                                        3'd3: tx_reg_3 <= {4'b1011, drawn_card};
                                        3'd4: tx_reg_4 <= {4'b1011, drawn_card};
                                    endcase
                                    case (current_player)
                                        3'd1: tx_valid_1 <= 1'b1; 3'd2: tx_valid_2 <= 1'b1;
                                        3'd3: tx_valid_3 <= 1'b1; 3'd4: tx_valid_4 <= 1'b1;
                                    endcase
                                    deal_step <= 2'd3;
                                end
                            end
                            2'd3: begin
                                if (!tx_busy_1 && !tx_valid_1 && !tx_busy_2 && !tx_valid_2 && !tx_busy_3 && !tx_valid_3 && !tx_busy_4 && !tx_valid_4) begin
                                    deal_step      <= 2'd0;
                                    current_player <= current_player + 3'd1;
                                end
                            end
                        endcase
                    end else begin
                        current_player <= 3'd1;
                        state_h        <= S_PLAYER_TURN;
                    end
                end

                S_PLAYER_TURN: begin
                    if (current_player <= {1'b0, player_count}) begin
                        case (deal_step)
                            2'd0: begin
                                case (current_player)
                                    3'd1: begin
                                        if (rx_valid_1 && rx_wire_1 == 8'b00000001) begin 
                                            pull_reg <= 1'b1;
                                            deal_step <= 2'd1;
                                        end else if (rx_valid_1 && rx_wire_1 == 8'b00000010) begin
                                            current_player <= current_player + 3'd1;
                                        end
                                    end
                                    3'd2: begin
                                        if (rx_valid_2 && rx_wire_2 == 8'b00000001) begin 
                                            pull_reg <= 1'b1;
                                            deal_step <= 2'd1;
                                        end else if (rx_valid_2 && rx_wire_2 == 8'b00000010) begin
                                            current_player <= current_player + 3'd1;
                                        end
                                    end
                                    3'd3: begin
                                        if (rx_valid_3 && rx_wire_3 == 8'b00000001) begin 
                                            pull_reg <= 1'b1;
                                            deal_step <= 2'd1;
                                        end else if (rx_valid_3 && rx_wire_3 == 8'b00000010) begin
                                            current_player <= current_player + 3'd1;
                                        end
                                    end
                                    3'd4: begin
                                        if (rx_valid_4 && rx_wire_4 == 8'b00000001) begin 
                                            pull_reg <= 1'b1;
                                            deal_step <= 2'd1;
                                        end else if (rx_valid_4 && rx_wire_4 == 8'b00000010) begin
                                            current_player <= current_player + 3'd1;
                                        end
                                    end
                                endcase
                            end
                            2'd1: begin
                                pull_reg <= 1'b0;
                                case (current_player)
                                    3'd1: begin tx_reg_1 <= {4'b1100, drawn_card}; tx_valid_1 <= 1'b1; end
                                    3'd2: begin tx_reg_2 <= {4'b1100, drawn_card}; tx_valid_2 <= 1'b1; end
                                    3'd3: begin tx_reg_3 <= {4'b1100, drawn_card}; tx_valid_3 <= 1'b1; end
                                    3'd4: begin tx_reg_4 <= {4'b1100, drawn_card}; tx_valid_4 <= 1'b1; end
                                endcase
                                deal_step <= 2'd2;
                            end
                            2'd2: begin
                                if (!tx_busy_1 && !tx_valid_1 && !tx_busy_2 && !tx_valid_2 && !tx_busy_3 && !tx_valid_3 && !tx_busy_4 && !tx_valid_4) begin
                                    deal_step <= 2'd0;
                                end
                            end
                        endcase
                    end else begin
                        state_h <= S_HOST_TURN;
                    end
                end

                S_HOST_TURN: begin
                    if (host_total_score < 6'd17) begin
                        if (!pull_reg) begin
                            pull_reg <= 1'b1;
                        end else if (pull_reg) begin
                            pull_reg               <= 1'b0;
                            cards[host_card_count] <= drawn_card;
                            host_card_count        <= host_card_count + 4'd1;
                        end
                    end else begin
                        state_h <= S_GAME_OVER;
                    end
                end

                S_GAME_OVER: begin
                    if (!tx_busy_1 && !tx_valid_1 && !tx_busy_2 && !tx_valid_2 && !tx_busy_3 && !tx_valid_3 && !tx_busy_4 && !tx_valid_4) begin
                        tx_reg_1   <= {2'b00, host_total_score[5:0]};
                        tx_reg_2   <= {2'b00, host_total_score[5:0]};
                        tx_reg_3   <= {2'b00, host_total_score[5:0]};
                        tx_reg_4   <= {2'b00, host_total_score[5:0]};
                        
                        tx_valid_1 <= 1'b1;
                        tx_valid_2 <= 1'b1;
                        tx_valid_3 <= 1'b1;
                        tx_valid_4 <= 1'b1;
                    end

                    if (btnC_pulse) begin
                        state_h         <= S_SHUFFLE;
                        host_card_count <= 4'd0;
                        current_player  <= 3'd1;
                        deal_step       <= 2'd0;
                        for (k = 0; k < 9; k = k + 1) begin
                            cards[k] <= 4'd0;
                        end
                    end
                end

                default: state_h <= S_IDLE;
            endcase
        end
    end

endmodule