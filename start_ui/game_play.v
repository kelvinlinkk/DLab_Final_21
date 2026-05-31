module game_player(
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
    output [5:0] money_you_bet_thousands,    
    output [5:0] money_you_bet_hundreds,
    output [5:0] money_you_bet_tens,
    output [5:0] money_you_bet_ones
  );
  // states
  localparam wait_start = 4'd0;
  localparam check_host_ace = 4'd1;
  localparam insurance = 4'd2;
  localparam card_get_0 = 4'd3;
  localparam card_get_1 = 4'd4;
  localparam card_get_2 = 4'd5;
  localparam card_get_3 = 4'd6;
  localparam card_get_4 = 4'd7;
  localparam wait_host = 4'd8;
  localparam game_over1 = 4'd9;
  localparam game_over2 = 4'd12;
  localparam S_IDLE     = 4'd10;
  localparam S_money_p1 = 4'd11;
  reg rst_reg = 1'd0;
  
  // player info
  reg double_in = 1'd0;
  reg [3:0] cards [0:5];
  reg [14:0] money_you_have = 15'd100;
  reg [14:0] money_you_bet = 15'd0;
  reg [14:0] next_money = 15'd0; // 用於計算金額的暫存變數
  assign card_0 = cards[0];
  assign card_1 = cards[1];
  assign card_2 = cards[2];
  assign card_3 = cards[3];
  assign card_4 = cards[4];
  
  //bet and money to seven seg 
    assign money_you_have_thousands = money_you_have / 15'd1000;
    assign money_you_have_hundreds  = (money_you_have % 15'd1000) / 15'd100;
    assign money_you_have_tens      = (money_you_have % 15'd100) / 15'd10;
    assign money_you_have_ones      = money_you_have % 15'd10;
    assign money_you_bet_thousands = money_you_bet / 15'd1000;
    assign money_you_bet_hundreds  = (money_you_bet % 15'd1000) / 15'd100;
    assign money_you_bet_tens      = (money_you_bet % 15'd100) / 15'd10;
    assign money_you_bet_ones      = money_you_bet % 15'd10;

  // reciever and transmitter
  wire [7:0] rx_wire;
  wire rx_valid;
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

  // start detect removed (was tied to non-existent init button)

  // ace detect
  reg host_ace_reg=1'b0; 

  // host's cards
  reg [4:0] host_card=5'd0;
  reg there_is_host_ace = 1'd0;

  // 動態計算玩家手牌總和 (取代原先的 5'b10101 預留位置)
  wire [5:0] player_sum;
  assign player_sum = cards[0] + cards[1] + cards[2] + cards[3] + cards[4];

  wire [1:0] wire_lose_win;
  assign wire_lose_win = (player_sum > 6'd21) ? 2'd1 :
                         (host_card > 5'd21) ? 2'd3 :
                         (host_card > player_sum) ? 2'd1 :
                         (host_card == player_sum) ? 2'd2 : 2'd3;


  always@(posedge clk or negedge rst_n)
  begin
    if (!rst_n) // init
    begin
      state           <= S_IDLE;
      tx              <= 8'b0;
      backtogh_p      <= 1'b0;
      rst_reg         <= 1'b0;
      host_ace_reg    <= 1'b0;
      there_is_host_ace <= 1'd0;
      host_card       <= 5'b0;
      money_you_bet   <= 15'd0;
      cards[0]        <= 4'd0;
      cards[1]        <= 4'd0;
      cards[2]        <= 4'd0;
      cards[3]        <= 4'd0;
      cards[4]        <= 4'd0;
      money_you_have  <= 15'd100;
      insurance_yn    <= 1'd0;
      lose_win <= 2'd0;
      double_in <= 1'd0;
    end
    else
    begin
      if (rst_reg) begin
                money_you_bet  <= 15'd0;
                rst_reg        <= 1'b0;
                lose_win <= 2'd0;
      end           
      backtogh_p <= 1'b0;
      tx <= 8'b0;

    case(state)
      S_IDLE: begin
                    if (startstartui) begin
                        if (!ishost) begin
                            state <= S_money_p1;
                        end
                    end
                end
                S_money_p1: begin
                    if (btnU) begin
                        if (money_you_have >= {4'd0,money_you_bet} + 15'd20)
                            money_you_bet <= money_you_bet + 15'd20;
                    end
                    if (btnD) begin
                        if (money_you_bet >= 15'd20)
                            money_you_bet <= money_you_bet - 15'd20;
                    end
                    if (btnL) begin
                        if (money_you_have > 0)
                            money_you_bet <= money_you_have;
                    end
                    if (btnR) begin
                        backtogh_p <= 1'b1;
                        state    <= S_IDLE;
                        rst_reg    <= 1'b1;
                    end 
                    if (btnC) begin
                        if (money_you_bet > 0)
                        state <= wait_start; // 設定完成，等待開始                    
                    end
                end
      wait_start:
      begin
        lose_win <= 2'd0;
        double_in <= 1'd0;
        state <= check_host_ace;
      end
      check_host_ace:
      begin
        if(rx_valid && rx_wire[7] == 1'b1)
        begin
          host_ace_reg <= rx_wire[0];
          if(rx_wire[0] == 1'b1) begin// 莊家是 Ace 則進入保險階段
            there_is_host_ace <= 1'd1;
            state <= insurance;
          end else begin
            there_is_host_ace <= 1'd0;
            state <= card_get_0;
          end
        end
      end
      insurance:
      begin
        // 搬移自 start_ui 的保險購買與否邏輯
        if (btnC) begin // 同意買保險
            insurance_yn <= 1'd1;
            state<=card_get_0;
        end
        if (btnD) begin // 拒絕買保險
            insurance_yn <= 1'd0;
            state<=card_get_0;
        end
      end
      card_get_0:
      begin
        if(rx_valid && rx_wire[7] == 1'b1)
        begin
          cards[0]<=rx_wire[3:0];
          state<=card_get_1;
        end
      end
      card_get_1:
      begin
        if(rx_valid && rx_wire[7] == 1'b1)
        begin
          cards[1]<=rx_wire[3:0];
          state<=card_get_2;
        end
      end
      card_get_2:
      begin
        if(btnU)
        begin
          tx<=8'b00000001; // Hit
        end
        if(btnD)
        begin
          tx<=8'b00000010; // Stand
          state<=wait_host;
        end
        if((btnC)&&((money_you_have/2)>=(money_you_bet)))// double in
        begin
          tx<=8'b00000001; // Hit
          double_in <= 1'd1;
          // Wait for the 3rd card, then auto-stand in card_get_3
        end
        if(rx_valid && rx_wire[7] == 1'b1)
        begin
          cards[2]<=rx_wire[3:0];
          state<=card_get_3;
        end
      end
      card_get_3:
      begin
        if (double_in) begin
            tx <= 8'b00000010; // Auto stand
            state <= wait_host;
        end else begin
            if(btnU)
            begin
              tx<=8'b00000001; // Hit
            end
            if(btnD)
            begin
              tx<=8'b00000010; // Stand
              state<=wait_host;
            end
        end
        if(rx_valid && rx_wire[7] == 1'b1 && !double_in)
        begin
          cards[3]<=rx_wire[3:0];
          state<=card_get_4;
        end
      end
      card_get_4:
      begin
        if(btnU)
        begin
          tx<=8'b00000001; // Hit
        end
        if(btnD)
        begin
          tx<=8'b00000010; // Stand
          state<=wait_host;
        end
        if(btnL)
        begin
        card_left_right <= 1'd0;
        end
        if(btnR)
        begin
        card_left_right <= 1'd1;
        end
        if(rx_valid && rx_wire[7] == 1'b1)
        begin
          cards[4]<=rx_wire[3:0];
          card_left_right <= 1'd0;
          state<=wait_host;
        end
      end
      wait_host:
      begin
        tx<={3'b100, player_sum[4:0]}; // 已填入實際手牌總和
        shift <= {shift[1:0], rx[7]}; 
        if(btnL)
        begin
        card_left_right <= 1'd0;
        end
        if(btnR)
        begin
        card_left_right <= 1'd1;
        end
        if(rx_valid && rx_wire[7] == 1'b1)
        begin
          host_card<=rx_wire[4:0];
          next_money <= money_you_have;
          state<=game_over1;
        end
      end
      game_over1:
      begin
        // A. 保險結算邏輯
        if (there_is_host_ace == 1'd1) begin
            if (host_card != 5'd21) begin // 莊家沒有21點，沒收保險金
                next_money <= money_you_have - (money_you_bet/2) - money_you_bet;
                money_you_have <= money_you_have - (money_you_bet/2) - money_you_bet;
                state <= game_over2;
            end else begin // 莊家有21點，獲得保險金理賠 (1賠2，淨得一倍保險金)
                next_money <= money_you_have + (money_you_bet/2) - money_you_bet;
                money_you_have <= money_you_have + (money_you_bet/2) - money_you_bet;
                lose_win <= 2'd1;
                state <= S_money_p1;                
            end
        end
        else begin
            next_money <= money_you_have - money_you_bet;
            money_you_have <= money_you_have - money_you_bet;
            state <= game_over2;     
        end
      end
    
      game_over2:
      begin
        // B. 主注輸贏結算邏輯
        lose_win <= wire_lose_win;

        if (wire_lose_win == 2'd1) begin
            if(double_in) begin
                if (next_money < money_you_bet*2) begin
                    next_money <= 15'd0;
                    money_you_have <= 15'd0;
                end else begin
                    next_money <= next_money - money_you_bet*2;
                    money_you_have <= next_money - money_you_bet*2;
                end
            end
            else begin
                if (next_money < money_you_bet) begin
                    next_money <= 15'd0;
                    money_you_have <= 15'd0;
                end else begin
                    next_money <= next_money - money_you_bet;
                    money_you_have <= next_money - money_you_bet;
                end
            end
        end
        else if (wire_lose_win == 2'd3) begin
            if(double_in) begin
                if (next_money + money_you_bet*2 > 15'd9999) begin
                    next_money <= 15'd9999;
                    money_you_have <= 15'd9999;
                end else begin
                    next_money <= next_money + money_you_bet*2;
                    money_you_have <= next_money + money_you_bet*2;
                end
            end
            else begin
                if (next_money + money_you_bet > 15'd9999) begin
                    next_money <= 15'd9999;
                    money_you_have <= 15'd9999;
                end else begin
                    next_money <= next_money + money_you_bet;
                    money_you_have <= next_money + money_you_bet;
                end
            end
        end
        // If tie (2'd2), next_money and money_you_have remain unchanged
        state <= S_money_p1; // 回到初始狀態等待下一局
      end
      default:
      begin
        state <= S_IDLE;
      end
    endcase
    end
  end

endmodule