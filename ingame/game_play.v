module game_player(
    input clk,
    input rst_n,
    input init,
    input host_ace,
    input btnU,
    input btnC,
    input btnD,
    input btnR,
    input btnL,
    input [7:0] rx,
    output reg [5:0] d0,
    output reg [5:0] d1,
    output reg [5:0] d2,
    output reg [5:0] d3,
    output reg [5:0] d4,
    output reg [5:0] d5,
    output reg [5:0] d6,
    output reg [5:0] d7,
    output reg [7:0] tx
);
// states
reg [3:0] state = wait_start;
localparam wait_start = 4'd0;
localparam check_host_ace = 4'd1;
localparam insurance = 4'd2;
localparam card_get_0 = 4'd3;
localparam card_get_1 = 4'd4;
localparam card_get_2 = 4'd5;
localparam card_get_3 = 4'd6;
localparam card_get_4 = 4'd7;
localparam wait_host = 4'd8;
localparam game_over = 4'd9;

// player info
reg [3:0] cards [0:5];
reg [13:0] money_you_have;
reg [9:0] money_you_bet = 10'd0;
reg [9:0] money_insurance = 10'd0;

// start detect
reg start=1'b0;
press_button init_dtct(
    .clk(clk),
    .btn(init),
    .pulse(start)
);

// ace detect
reg host_ace_reg=1'b0; // store rx[0] , ace or not
reg [2:0] shift = 0;

// host's cards
reg [4:0] host_card=5'd0;

always@(posedge clk or negedge rst_n)
begin
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
        // buy insurance
        state<=card_get_0;
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
    game_over:
    begin
        if(host_card>5'b10101/*replace with player card sum*/)
        begin
            // something to do when winning
        end
        else if(host_card==5'b10101/*replace with player card sum*/)
        begin
            // something to do when equal
        end
        else 
        begin
            // something to do when lose
        end
        if(!rst_n)
            state<=wait_start;
    end
    default:
    begin
        // system break;
    end
    endcase
end

endmodule