module game_host(
    input clk,
    input rst_n,
    input init,
    input host_ace,
    input btnU,
    input btnC,
    input btnD,
    input btnR,
    input btnL,
    input signal_in_1,
    input signal_in_2,
    input signal_in_3,
    input signal_in_4,
    output reg [5:0] d0,
    output reg [5:0] d1,
    output reg [5:0] d2,
    output reg [5:0] d3,
    output reg [5:0] d4,
    output reg [5:0] d5,
    output reg [5:0] d6,
    output reg [5:0] d7,
    output signal_out_1,
    output signal_out_2,
    output signal_out_3,
    output signal_out_4
  );
  // states
  reg [3:0] state = state_shuffle;
  localparam state_shuffle = 4'd0;
  localparam state_host_two_cards = 4'd1;
  localparam state_player_two_cards = 4'd2;

  // player info
  reg [3:0] cards [0:8]='{9{4'd0}};

  // reciever and transmitter
  wire [7:0] rx_wire_1;
  wire [7:0] rx_wire_2;
  wire [7:0] rx_wire_3;
  wire [7:0] rx_wire_4;

  reg [7:0] rx_reg_1 = 8'd0;
  reg [7:0] rx_reg_2 = 8'd0;
  reg [7:0] rx_reg_3 = 8'd0;
  reg [7:0] rx_reg_4 = 8'd0;

  rx rx_1 (
      .clk(clk),
      .rst_n(rst_n),
      .signal_in(signal_in_1),
      .out(rx_wire_1)
  );

  rx rx_2 (
      .clk(clk),
      .rst_n(rst_n),
      .signal_in(signal_in_2),
      .out(rx_wire_2)
  );

  rx rx_3 (
      .clk(clk),
      .rst_n(rst_n),
      .signal_in(signal_in_3),
      .out(rx_wire_3)
  );

  rx rx_4 (
      .clk(clk),
      .rst_n(rst_n),
      .signal_in(signal_in_4),
      .out(rx_wire_4)
  );
    reg [7:0] tx_reg_1 = 8'd0;
    reg [7:0] tx_reg_2 = 8'd0;
    reg [7:0] tx_reg_3 = 8'd0;
    reg [7:0] tx_reg_4 = 8'd0;

    tx tx_1 (
        .clk(clk),
        .rst_n(rst_n),
        .data_in(tx_reg_1),
        .valid(1'b1),
        .signal_out(signal_out_1),
        .busy()
    );

    tx tx_2 (
        .clk(clk),
        .rst_n(rst_n),
        .data_in(tx_reg_2),
        .valid(1'b1),
        .signal_out(signal_out_2),
        .busy()
    );

    tx tx_3 (
        .clk(clk),
        .rst_n(rst_n),
        .data_in(tx_reg_3),
        .valid(1'b1),
        .signal_out(signal_out_3),
        .busy()
    );

    tx tx_4 (
        .clk(clk),
        .rst_n(rst_n),
        .data_in(tx_reg_4),
        .valid(1'b1),
        .signal_out(signal_out_4),
        .busy()
    );

  // detect
  reg [2:0] shift = 0; 

  // serve card
  serve serve_0(
    .clk(clk),
    .rst_n(rst_n),
    .shuffle(shuffle_reg),
    .pull(pull_reg),
    .out_card(pull_card)
  );
  reg shuffle_reg=1'b0;
  reg pull_reg=1'b0;
  reg [3:0] pull_card=4'b0;

  always@(posedge clk or negedge rst_n)
  begin
    if (!rst_n) // init
    begin
      cards <='{9{4'd0}};
      state           <= state_shuffle;
      tx_reg_1              <= 8'b0;
      tx_reg_2              <= 8'b0;
      tx_reg_3              <= 8'b0;
      tx_reg_4              <= 8'b0;
      shift           <= 3'b0;
    end
    else
    begin
      tx_reg_1              <= 8'b0;
      tx_reg_2              <= 8'b0;
      tx_reg_3              <= 8'b0;
      tx_reg_4              <= 8'b0;
      rx_reg_1 <= rx_wire_1;
      rx_reg_2 <= rx_wire_2;
      rx_reg_3 <= rx_wire_3;
      rx_reg_4 <= rx_wire_4;

    case(state)
      state_shuffle:
      begin
        if(btnD==1'b1)
          shuffle_reg<=1'b1;
        else
          shuffle_reg<=1'b0;
        if(btnC)
        state<=state_host_two_cards;
      end
      state_host_two_cards:
      begin
        if(cards[1]!=4'd0) begin
          pull_reg<=1'b0;
          state<=state_player_two_cards;
          if(cards[1]==4'd1)begin
            tx_reg_1<=8'b10000001;
            tx_reg_2<=8'b10000001;
            tx_reg_3<=8'b10000001;
            tx_reg_4<=8'b10000001;
          end else begin
            tx_reg_1<=8'b10000000;
            tx_reg_2<=8'b10000000;
            tx_reg_3<=8'b10000000;
            tx_reg_4<=8'b10000000;
          end
        end
        else if(pull_reg==1'b1 && (cards[0]==4'b0)) begin
          pull_reg<=1'b0;
          cards[0]<=pull_card;
        end  
        else if(pull_reg==1'b1 && (cards[1]==4'b0)) begin
          pull_reg<=1'b0;
          cards[1]<=pull_card;
        end
        else if(pull_reg==1'b0) begin
          pull_reg<=1'b1;
        end
      end
      state_player_two_cards:
      begin
        tx_reg_1<=8'd0;
        tx_reg_1<=8'd1;
        tx_reg_1<=8'd2;
        tx_reg_1<=8'd3;
      end
      default:
      begin
        state<=state_shuffle;
      end
    endcase
    end
  end

endmodule