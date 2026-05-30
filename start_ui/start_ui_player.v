module start_ui_player(
    input clk,
    input rst_n,
    input host_ace,
    input btnU,
    input btnC,
    input btnD,
    input btnR,
    input btnL,
    input signal_in,
    input ishost,
    input startstartui,
    output reg [1:0] lose_win = 2'd0,
    output reg insurance_yn = 1'd0,
    output reg backtogh_p = 0,
    output reg [3:0] state = 4'd10,
    output [3:0] card_0,
    output [3:0] card_1,
    output [3:0] card_2,
    output [3:0] card_3,
    output [3:0] card_4,
    output reg card_left_right = 1'd0,
    output signal_out,
    output [5:0] money_you_have_thousands,
    output [5:0] money_you_have_hundreds,
    output [5:0] money_you_have_tens,
    output [5:0] money_you_have_ones,    
    output [5:0] money_you_bet_hundreds,
    output [5:0] money_you_bet_tens,
    output [5:0] money_you_bet_ones
  );
  
  // states
  localparam wait_start      = 4'd0;
  localparam check_host_ace  = 4'd1;
  localparam insurance       = 4'd2;
  localparam card_get_0      = 4'd3;
  localparam card_get_1      = 4'd4;
  localparam card_get_2      = 4'd5;
  localparam card_get_3      = 4'd6;
  localparam card_get_4      = 4'd7;
  localparam wait_host       = 4'd8;
  localparam game_over1      = 4'd9;
  localparam game_over2      = 4'd12;
  localparam S_IDLE          = 4'd10;
  localparam S_money_p1      = 4'd11;

  reg rst_reg = 1'd0;
  
  // player info
  reg [3:0] cards [0:4];
  reg [13:0] money_you_have = 14'd1000;
  reg [9:0] money_you_bet = 10'd0;
  reg [13:0] money_after_insurance; 

  assign card_0 = cards[0];
  assign card_1 = cards[1];
  assign card_2 = cards[2];
  assign card_3 = cards[3];
  assign card_4 = cards[4];
  
  // bet and money to seven seg 
  assign money_you_have_thousands = money_you_have / 14'd1000;
  assign money_you_have_hundreds  = (money_you_have % 14'd1000) / 14'd100;
  assign money_you_have_tens      = (money_you_have % 14'd100) / 14'd10;
  assign money_you_have_ones      = money_you_have % 14'd10;
  assign money_you_bet_hundreds   = money_you_bet / 10'd100;
  assign money_you_bet_tens       = (money_you_bet % 10'd100) / 10'd10;
  assign money_you_bet_ones       = money_you_bet % 10'd10;

  // receiver and transmitter
  wire [7:0] rx_wire;
  wire rx_valid;
  reg [7:0] rx = 8'd0;
  reg rx_valid_reg = 1'b0;
  rx rx_0(
       .clk(clk),
       .rst_n(rst_n),
       .signal_in(signal_in),
       .out(rx_wire),
       .valid(rx_valid)
     );
    
  reg [7:0] tx = 8'd0;
  tx tx_0(
       .clk(clk),
       .rst_n(rst_n),
       .data_in(tx),
       .valid(1'b1),
       .signal_out(signal_out),
       .busy()
     );

  // start detect
  wire start; 
  wire init;
  assign init = btnC;

  press_button init_dtct(
                 .clk(clk),
                 .btn(init),
                 .pulse(start)
               );

  // ace detect
  reg host_ace_reg = 1'b0; 
  reg [2:0] shift = 0;

  // host's cards
  reg [4:0] host_card = 5'd0;
  reg there_is_host_ace = 1'd0;

  // 動態計算玩家手牌總和
  wire [5:0] player_sum;
  assign player_sum = cards[0] + cards[1] + cards[2] + cards[3] + cards[4];

  always @(posedge clk or negedge rst_n)
  begin
    if (!rst_n)
    begin
      state             <= S_IDLE;
      tx                <= 8'b0;
      backtogh_p        <= 1'b0;
      rst_reg           <= 1'b0;
      shift             <= 3'b0;
      host_ace_reg      <= 1'b0;
      there_is_host_ace <= 1'd0;
      host_card         <= 5'b0;
      money_you_bet     <= 10'd0;
      cards[0]          <= 4'd0;
      cards[1]          <= 4'd0;
      cards[2]          <= 4'd0;
      cards[3]          <= 4'd0;
      cards[4]          <= 4'd0;
      money_you_have    <= 14'd1000;
      money_after_insurance <= 14'd1000;
      insurance_yn      <= 1'd0;
      lose_win          <= 2'd0;
      card_left_right   <= 1'd0;
    end
    else
    begin
      if (rst_reg) begin
        money_you_bet  <= 10'd0;
        rst_reg        <= 1'b0;
        lose_win       <= 2'd0;
      end
      backtogh_p <= 1'b0;
      tx         <= 8'b0;
      rx         <= rx_wire;
      rx_valid_reg <= rx_valid;

      case(state)
        S_IDLE: begin
          if (startstartui && !ishost) begin
            state <= S_money_p1;
          end
        end

        S_money_p1: begin
          if (btnU) begin
            if ((money_you_have >= {4'd0, money_you_bet} + 14'd20) && ({4'd0, money_you_bet} + 14'd20 <= 14'd500))
              money_you_bet <= money_you_bet + 10'd20;
          end
          if (btnD) begin
            if (money_you_bet >= 10'd20)
              money_you_bet <= money_you_bet - 10'd20;
          end
          if (btnL) begin
            if (money_you_have > 0)
              money_you_bet <= (money_you_have > 14'd500) ? 10'd500 : money_you_have[9:0];
          end
          if (btnR) begin
            backtogh_p <= 1'b1;
            state      <= S_IDLE;
            rst_reg    <= 1'b1;
          end 
          if (btnC) begin
            if (money_you_bet > 0)
              state <= wait_start;                  
          end
        end

        wait_start: begin
          lose_win <= 2'd0;
          if(start) begin
            state <= check_host_ace;
          end
        end

        check_host_ace: begin
          shift <= {shift[1:0], rx[7]}; 
          if(shift[0] == 1'b1) begin
            host_ace_reg <= rx[0];
          end
          if(rx_valid_reg) begin
            if(host_ace_reg == 1'b1) begin
              there_is_host_ace <= 1'd1;
              state             <= insurance;
            end else begin
              there_is_host_ace <= 1'd0;
              state             <= card_get_0;
            end
          end
        end

        insurance: begin
          if (btnC) begin 
            insurance_yn <= 1'd1;
            state        <= card_get_0;
          end
          if (btnD) begin 
            insurance_yn <= 1'd0;
            state        <= card_get_0;
          end
        end

        card_get_0: begin
          shift <= {shift[1:0], rx[7]}; 
          if(rx_valid_reg) begin
            cards[0] <= rx[3:0];
            state    <= card_get_1;
          end
        end

        card_get_1: begin
          shift <= {shift[1:0], rx[7]}; 
          if(rx_valid_reg) begin
            cards[1] <= rx[3:0];
            state    <= card_get_2;
          end
        end

        card_get_2: begin
          if(btnU) tx <= 8'b00000001; 
          if(btnD) begin
            tx    <= 8'b00000010; 
            state <= wait_host;
          end
          shift <= {shift[1:0], rx[7]}; 
          if(rx_valid_reg) begin
            cards[2] <= rx[3:0];
            state    <= card_get_3;
          end
        end

        card_get_3: begin
          if(btnU) tx <= 8'b00000001; 
          if(btnD) begin
            tx    <= 8'b00000010; 
            state <= wait_host;
          end
          shift <= {shift[1:0], rx[7]}; 
          if(rx_valid_reg) begin
            cards[3] <= rx[3:0];
            state    <= card_get_4;
          end
        end

        card_get_4: begin
          if(btnU) tx <= 8'b00000001;
          if(btnD) begin
            tx    <= 8'b00000010;
            state <= wait_host;
          end
          if(btnL) card_left_right <= 1'd0;
          if(btnR) card_left_right <= 1'd1;

          shift <= {shift[1:0], rx[7]}; 
          if(rx_valid_reg) begin
            cards[4]        <= rx[3:0];
            card_left_right <= 1'd0;
            state           <= wait_host;
          end
        end

        wait_host: begin
          tx    <= {3'b100, player_sum[4:0]}; 
          shift <= {shift[1:0], rx[7]}; 
          if(btnL) card_left_right <= 1'd0;
          if(btnR) card_left_right <= 1'd1;
          
          if(shift[0] == 1'b1) begin
            host_card <= rx[5:1];
          end
          if(rx_valid_reg) begin
            state <= game_over1;
          end
        end

        game_over1: begin
          if (there_is_host_ace && insurance_yn) begin
              if (host_card != 5'd21) begin 
                  if (money_you_have > {5'd0, money_you_bet[9:1]})
                      money_after_insurance <= money_you_have - {5'd0, money_you_bet[9:1]};
                  else
                      money_after_insurance <= 14'd0;
              end else begin 
                  money_after_insurance <= money_you_have + {5'd0, money_you_bet[9:1]};
              end
          end else begin
              money_after_insurance <= money_you_have;
          end
          state <= game_over2;
        end
      
        game_over2: begin
          if (player_sum > 6'd21) begin 
              lose_win <= 2'd1;
              if (money_after_insurance < {4'd0, money_you_bet})
                  money_you_have <= 14'd0;
              else
                  money_you_have <= money_after_insurance - {4'd0, money_you_bet};
          end
          else if (host_card > 5'd21) begin 
              lose_win <= 2'd3;
              if ((money_after_insurance + {4'd0, money_you_bet}) > 14'd9999)
                  money_you_have <= 14'd9999;
              else
                  money_you_have <= money_after_insurance + {4'd0, money_you_bet};
          end
          else if (host_card > player_sum) begin 
              lose_win <= 2'd1;
              if (money_after_insurance < {4'd0, money_you_bet})
                  money_you_have <= 14'd0;
              else
                  money_you_have <= money_after_insurance - {4'd0, money_you_bet};
          end
          else if (host_card == player_sum) begin 
              lose_win       <= 2'd2;
              money_you_have <= money_after_insurance;
          end
          else begin 
              lose_win <= 2'd3;
              if ((money_after_insurance + {4'd0, money_you_bet}) > 14'd9999)
                  money_you_have <= 14'd9999;
              else
                  money_you_have <= money_after_insurance + {4'd0, money_you_bet};
          end

          state <= S_money_p1; 
        end

        default: begin
          state <= S_IDLE;
        end
      endcase
    end
  end

endmodule