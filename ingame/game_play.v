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
    input signal_in,
    input endgame,  
    input [2:0] win_or_lose,
    input insurance_y_n, 
    input host_have_21, 
    input is_there_insurance, 
    output reg [5:0] d0,
    output reg [5:0] d1,
    output reg [5:0] d2,
    output reg [5:0] d3,
    output reg [5:0] d4,
    output reg [5:0] d5,
    output reg [5:0] d6,
    output reg [5:0] d7,
    output signal_out,
    output reg finish_cal = 1'b0
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
  reg [13:0] next_money; // 用於計算金額的暫存變數

  // reciever and transmitter
  wire [7:0] rx_wire;
  reg [7:0] rx=8'd0;
  rx rx_0(
       .clk(clk),
       .rst_n(rst_n),
       .signal_in(signal_in),
       .out(rx_wire)
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
  reg start=1'b0;
  press_button init_dtct(
                 .clk(clk),
                 .btn(init),
                 .pulse(start)
               );

  // ace detect
  reg host_ace_reg=1'b0; 
  reg [2:0] shift = 0; 

  // host's cards
  reg [4:0] host_card=5'd0;

  // 動態計算玩家手牌總和 (取代原先的 5'b10101 預留位置)
  wire [5:0] player_sum;
  assign player_sum = cards[0] + cards[1] + cards[2] + cards[3] + cards[4];

  always@(posedge clk or negedge rst_n)
  begin
    if (!rst_n) // init
    begin
      state           <= wait_start;
      tx              <= 8'b0;
      shift           <= 3'b0;
      host_ace_reg    <= 1'b0;
      host_card       <= 5'b0;
      money_you_bet   <= 10'd0;
      money_insurance <= 10'd0;
      cards[0]        <= 4'd0;
      cards[1]        <= 4'd0;
      cards[2]        <= 4'd0;
      cards[3]        <= 4'd0;
      cards[4]        <= 4'd0;
      money_you_have  <= 14'd1000; // 初始金額 1000
    end
    else
    begin
      tx <= 8'b0;
      rx <= rx_wire;

    case(state)
      wait_start:
      begin
        // 搬移自 start_ui 的下注調整邏輯
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
        
        if(start)
        begin
          state<=check_host_ace;
        end
      end
      check_host_ace:
      begin
        shift <= {shift[1:0], rx[7]}; 
        if(shift[0] == 1'b1)
        begin
          host_ace_reg<=rx[0];
        end
        if(shift[2:1] == 2'b01)
        begin
          if(host_ace_reg==1'b1) // 修正邏輯：莊家是 Ace 則進入保險階段
            state<=insurance;
          else
            state<=card_get_0;
        end
      end
      insurance:
      begin
        // 搬移自 start_ui 的保險購買與否邏輯
        if (btnC) begin // 同意買保險
            money_insurance <= money_you_bet >> 1; // 壓注的一半
            state<=card_get_0;
        end
        if (btnD) begin // 拒絕買保險
            money_insurance <= 10'd0;
            state<=card_get_0;
        end
      end
      card_get_0:
      begin
        shift <= {shift[1:0], rx[7]}; 
        if(shift[2:1] == 2'b01)
        begin
          cards[0]<=rx[3:0];
          state<=card_get_1;
        end
      end
      card_get_1:
      begin
        shift <= {shift[1:0], rx[7]}; 
        if(shift[2:1] == 2'b01)
        begin
          cards[1]<=rx[3:0];
          state<=card_get_2;
        end
      end
      card_get_2:
      begin
        shift <= {shift[1:0], rx[7]}; 
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
          tx<=8'b10000011; 
        end
        if(btnD)
        begin
          tx<=8'b10000010; 
          state<=wait_host;
        end
        shift <= {shift[1:0], rx[7]}; 
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
        shift <= {shift[1:0], rx[7]}; 
        if(shift[2:1] == 2'b01)
        begin
          cards[4]<=rx[3:0];
          state<=wait_host;
        end
      end
      wait_host:
      begin
        tx<={3'b100, player_sum[4:0]}; // 已填入實際手牌總和
        shift <= {shift[1:0], rx[7]}; 
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
        next_money = money_you_have;

        // A. 保險結算邏輯
        if (money_insurance > 10'd0) begin
            if (host_card != 5'd21) begin // 莊家沒有21點，沒收保險金
                if (next_money > money_insurance)
                    next_money = next_money - money_insurance;
                else
                    next_money = 14'd0;
            end else begin // 莊家有21點，獲得保險金理賠 (1賠2，淨得一倍保險金)
                next_money = next_money + money_insurance;
            end
        end

        // B. 主注輸贏結算邏輯
        if (player_sum > 6'd21) begin // 玩家爆牌必輸
            if (next_money < money_you_bet)
                next_money = 14'd0;
            else
                next_money = next_money - money_you_bet;
        end
        else if (host_card > 5'd21) begin // 莊家爆牌，玩家贏
            if ((next_money + money_you_bet) > 14'd9999)
                next_money = 14'd9999;
            else
                next_money = next_money + money_you_bet;
        end
        else if (host_card > player_sum) begin // 莊家點數大，玩家輸
            if (next_money < money_you_bet)
                next_money = 14'd0;
            else
                next_money = next_money - money_you_bet;
        end
        else if (host_card == player_sum) begin // 平手
            // 金額保持不變
        end
        else begin // 玩家點數大，玩家贏
            if ((next_money + money_you_bet) > 14'd9999)
                next_money = 14'd9999;
            else
                next_money = next_money + money_you_bet;
        end

        money_you_have <= next_money;
        state          <= wait_start; // 回到初始狀態等待下一局
      end
      default:
      begin
        state<=wait_start;
      end
    endcase
    end
  end

endmodule