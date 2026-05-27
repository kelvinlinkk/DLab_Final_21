module game_player(
    input clk,
    input rst_n,
    input host_ace,
    input btnU,
    input btnC,
    input btnD,
    input btnR,
    input btnL,
    input [7:0] rx,
    input finish_cal,
    input start,
    output reg [7:0] tx,
    output reg endgame = 1'b0,
    output reg [2:0] win_or_lose = 3'd0,
    output reg insurance_y_n = 0,
    output reg host_have_21 = 0,
    output reg is_there_insurance = 0
);
// states
localparam wait_start = 4'd0;
reg [3:0] state = wait_start;
localparam check_host_ace = 4'd1;
localparam insurance = 4'd2;
localparam card_get_0 = 4'd3;
localparam card_get_1 = 4'd4;
localparam card_get_2 = 4'd5;
localparam card_get_3 = 4'd6;
localparam card_get_4 = 4'd7;
localparam wait_host = 4'd8;
localparam game_over = 4'd9;
localparam idle = 3'd0;
localparam lose = 3'd1;
localparam equal = 3'd2;
localparam win = 3'd3;
reg result_latched; 
// player info
reg [3:0] cards [0:5];

// ace detect
reg host_ace_reg=1'b0; // store rx[0] , ace or not
reg [2:0] shift = 0;

// host's cards
reg [4:0] host_card=5'd0;

always@(posedge clk or negedge rst_n)
begin
    if (!rst_n) begin
        state              <= wait_start;
        win_or_lose        <= idle;
        endgame            <= 1'b0;
        result_latched     <= 1'b0;
        insurance_y_n      <= 0;
        host_have_21       <= 0;
        is_there_insurance <= 0;
        tx                 <= 8'd0;
        host_card          <= 5'd0;
    end else begin  
    case(state)
    wait_start:
    begin
        if(start)
        begin
            state<=check_host_ace;
        end
    end
    check_host_ace:
    begin
        shift <= {shift[1:0], rx[7]}; // rx[7] detect signal
        if(shift[0] == 1'b1)
        begin
            host_ace_reg<=rx[0];
        end
        if(shift[2:1] == 2'b01)
        begin
            if(host_ace_reg==1'b0)
                state<=insurance;
            else    
                state<=card_get_0;
        end
    end
    insurance:
    begin
        is_there_insurance <= 1'b1;       
        if(btnU) begin
            insurance_y_n <= 1'b1; 
        end
        if(btnD) begin
            insurance_y_n <= 1'b0; 
        end
        shift <= {shift[1:0], rx[7]};// idk how you know if its 21 from host, so feel free to change how this works
        if(shift[0] == 1'b1) begin
            host_have_21 <= rx[1]; 
        end
        if(shift[2:1] == 2'b01) begin
            if(host_have_21) begin
                state <= game_over; 
            end else begin
                state <= card_get_0; 
            end
        end
    end
    card_get_0:
    begin
        shift <= {shift[1:0], rx[7]}; // rx[7] detect signal
        if(shift[2:1] == 2'b01)
        begin
            cards[0]<=rx[3:0];
            state<=card_get_1;
        end
    end
    card_get_1:
    begin
        shift <= {shift[1:0], rx[7]}; // rx[7] detect signal
        if(shift[2:1] == 2'b01)
        begin
            cards[1]<=rx[3:0];
            state<=card_get_2;
        end
    end
    card_get_2:
    begin
        shift <= {shift[1:0], rx[7]}; // rx[7] detect signal
        if(shift[2:1] == 2'b01)
        begin
            cards[2]<=rx[3:0];
            state<=card_get_3;
        end
    end
    card_get_3:
    begin
        if(btnU)
        begin
            tx<=8'b10000011; // ask for card
        end
        if(btnD)
        begin
            tx<=8'b10000010; // reject a card
            state<=wait_host;
        end
        shift <= {shift[1:0], rx[7]}; // rx[7] detect signal
        if(shift[2:1] == 2'b01)
        begin
            cards[3]<=rx[3:0];
            state<=card_get_4;
        end
    end
    card_get_4:
    begin
        if(btnU)
        begin
            tx<=8'b10000011;
        end
        if(btnD)
        begin
            tx<=8'b10000010;
            state<=wait_host;
        end
        shift <= {shift[1:0], rx[7]}; // rx[7] detect signal
        if(shift[2:1] == 2'b01)
        begin
            cards[4]<=rx[3:0];
            state<=wait_host;
        end
    end
    wait_host:
    begin
        tx<={3'b100, 5'b10101/*replace with player card sum*/}; // output sum of cards
        shift <= {shift[1:0], rx[7]}; // rx[7] detect signal
        if(shift[0] == 1'b1)
        begin
            host_card<=rx[5:1];
        end
        if(shift[2:1] == 2'b01)
        begin
            state<=game_over;
        end
    end
    game_over: begin
        if (!result_latched) begin
            endgame        <= 1'b1;
            result_latched <= 1'b1;           
            if(host_card > 5'b10101/*||(host_card < player card sum)&&(player card sum =< 5'b10101)*/) begin
                win_or_lose <= win;
                endgame <= 1'b1;
            end
            else if(host_card == 5'b10101/*replace with player card sum*/) begin
                win_or_lose <= equal;
                endgame <= 1'b1;
            end
            else begin
                win_or_lose <= lose;
                endgame <= 1'b1;
            end
        end
        if (finish_cal) begin
            endgame        <= 1'b0;
            win_or_lose    <= idle;
            result_latched <= 1'b0;
            insurance_y_n <= 0;
            host_have_21 <= 0;
            is_there_insurance <= 0;
            state <= wait_start;
        end
    end
    default:
    begin
        // system break;
    end
    endcase
    end
end

endmodule