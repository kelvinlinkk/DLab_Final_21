module tone(
    input clk,
    input rst_n,
    input tone_signal,
    input [3:0] tone_sel,
    output tone_out
);

    parameter IDLE  = 3'd0;
    parameter NOTE1 = 3'd1;
    parameter NOTE2 = 3'd2;
    parameter NOTE3 = 3'd3;
    parameter NOTE4 = 3'd4;
    parameter NOTE5 = 3'd5;

    reg [2:0] state;
    reg [31:0] note_timer;
    reg [3:0] sel_reg;

    reg [19:0] current_period;
    reg [31:0] current_duration;
    
    // Play trigger
    wire play_tone = tone_signal;

    // Frequencies (Periods)
    localparam P_0 = 20'd0;
    localparam P_G2 = 20'd1020408;
    localparam P_C3 = 20'd769230;
    localparam P_EB3 = 20'd645161;
    localparam P_A3 = 20'd454545;
    localparam P_BB3 = 20'd429184;
    localparam P_B3 = 20'd404858;
    localparam P_C4 = 20'd381679;
    localparam P_E4 = 20'd303030;
    localparam P_G4 = 20'd255102;
    localparam P_A4 = 20'd227272;
    localparam P_C5 = 20'd191204;
    localparam P_E5 = 20'd151745;
    localparam P_G5 = 20'd127551;
    localparam P_B5 = 20'd101214;
    localparam P_C6 = 20'd95510;
    localparam P_E6 = 20'd75815;

    localparam D_VS = 32'd7_500_000;  // 0.075s
    localparam D_S  = 32'd15_000_000; // 0.15s
    localparam D_M  = 32'd30_000_000; // 0.3s
    localparam D_L  = 32'd45_000_000; // 0.45s
    localparam D_0  = 32'd0;

    always @(*) begin
        current_period = P_0;
        current_duration = D_0;
        case (sel_reg)
            4'd0: begin // WIN (4 notes)
                case(state)
                    NOTE1: begin current_period = P_C5; current_duration = D_S; end
                    NOTE2: begin current_period = P_E5; current_duration = D_S; end
                    NOTE3: begin current_period = P_G5; current_duration = D_S; end
                    NOTE4: begin current_period = P_C6; current_duration = D_L; end
                    default: begin current_period = P_0; current_duration = D_0; end
                endcase
            end
            4'd1: begin // LOSE (4 notes)
                case(state)
                    NOTE1: begin current_period = P_C4; current_duration = D_S; end
                    NOTE2: begin current_period = P_B3; current_duration = D_S; end
                    NOTE3: begin current_period = P_BB3; current_duration = D_S; end
                    NOTE4: begin current_period = P_A3; current_duration = D_L; end
                    default: begin current_period = P_0; current_duration = D_0; end
                endcase
            end
            4'd2: begin // CTRL (1 note)
                case(state)
                    NOTE1: begin current_period = P_A4; current_duration = D_VS; end
                    default: begin current_period = P_0; current_duration = D_0; end
                endcase
            end
            4'd3: begin // TIE (3 notes)
                case(state)
                    NOTE1: begin current_period = P_C4; current_duration = D_S; end
                    NOTE2: begin current_period = P_E4; current_duration = D_S; end
                    NOTE3: begin current_period = P_G4; current_duration = D_M; end
                    default: begin current_period = P_0; current_duration = D_0; end
                endcase
            end
            4'd4: begin // DEAL (1 very short note)
                case(state)
                    NOTE1: begin current_period = P_C6; current_duration = D_VS; end
                    default: begin current_period = P_0; current_duration = D_0; end
                endcase
            end
            4'd5: begin // BET (2 fast notes - coin sound)
                case(state)
                    NOTE1: begin current_period = P_B5; current_duration = D_VS; end
                    NOTE2: begin current_period = P_E6; current_duration = D_M; end
                    default: begin current_period = P_0; current_duration = D_0; end
                endcase
            end
            4'd6: begin // BUST (2 long sad notes)
                case(state)
                    NOTE1: begin current_period = P_EB3; current_duration = D_M; end
                    NOTE2: begin current_period = P_C3; current_duration = D_L; end
                    default: begin current_period = P_0; current_duration = D_0; end
                endcase
            end
            4'd7: begin // ERROR (1 low note)
                case(state)
                    NOTE1: begin current_period = P_G2; current_duration = D_M; end
                    default: begin current_period = P_0; current_duration = D_0; end
                endcase
            end
            4'd8: begin // BLACKJACK (5 notes special win)
                case(state)
                    NOTE1: begin current_period = P_C5; current_duration = D_VS; end
                    NOTE2: begin current_period = P_E5; current_duration = D_VS; end
                    NOTE3: begin current_period = P_G5; current_duration = D_VS; end
                    NOTE4: begin current_period = P_C6; current_duration = D_VS; end
                    NOTE5: begin current_period = P_E6; current_duration = D_L; end
                    default: begin current_period = P_0; current_duration = D_0; end
                endcase
            end
            default: begin
                current_period = P_0; 
                current_duration = D_0;
            end
        endcase
    end

    // FSM
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            note_timer <= 32'd0;
            sel_reg <= 4'd0;
        end 
        else begin
            if (play_tone) begin
                state <= NOTE1;
                note_timer <= 32'd0;
                sel_reg <= tone_sel;
            end 
            else if (state != IDLE) begin
                if (current_period == P_0) begin
                    state <= IDLE;
                    note_timer <= 32'd0;
                end
                else if (note_timer >= current_duration) begin
                    note_timer <= 32'd0;
                    case (state)
                        NOTE1: state <= NOTE2;
                        NOTE2: state <= NOTE3;
                        NOTE3: state <= NOTE4;
                        NOTE4: state <= NOTE5;
                        NOTE5: state <= IDLE;
                        default: state <= IDLE;
                    endcase
                end 
                else begin
                    note_timer <= note_timer + 32'd1;
                end
            end
        end
    end

    // Tone Generator
    reg [19:0] tone_cnt;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            tone_cnt <= 20'd0;
        end
        else if (play_tone) begin
            tone_cnt <= 20'd0;
        end
        else if (state != IDLE && current_period != P_0) begin
            if (tone_cnt >= (current_period - 1)) begin
                tone_cnt <= 20'd0;
            end
            else begin
                tone_cnt <= tone_cnt + 20'd1;
            end
        end
        else begin
            tone_cnt <= 20'd0;
        end
    end

    assign tone_out = (state != IDLE && current_period != P_0 && tone_cnt < {1'b0, current_period[19:1]}) ? 1'b1 : 1'b0;

endmodule