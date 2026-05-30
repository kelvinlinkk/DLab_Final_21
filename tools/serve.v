module serve(
    input clk,
    input rst_n,
    input shuffle,
    input pull,
    output [3:0] out_card
);

  reg [3:0] cards [0:51];
  integer i;
  initial begin
    for (i = 0; i < 52; i = i + 1) begin
      cards[i] = (i % 13) + 4'd1;
    end
  end

  reg [5:0] fast_rand;
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) fast_rand <= 6'd0;
    else if (fast_rand == 6'd51) fast_rand <= 6'd0;
    else fast_rand <= fast_rand + 6'd1;
  end

  reg [15:0] shuffle_timer;
  reg [5:0]  swap_range;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      shuffle_timer <= 16'd0;
      swap_range <= 6'd0;
    end else if (shuffle) begin

      if (shuffle_timer == 16'd50000) begin
        shuffle_timer <= 16'd0;

        cards[swap_range] <= cards[fast_rand];
        cards[fast_rand]  <= cards[swap_range];

        if (swap_range == 6'd51) swap_range <= 6'd0;
        else swap_range <= swap_range + 6'd1;
      end else begin
        shuffle_timer <= shuffle_timer + 16'd1;
      end
    end else begin
      shuffle_timer <= 16'd0;
    end
  end

  reg [5:0] pull_index;
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      pull_index <= 6'd0;
    end 
    else if (pull) begin 
      if (pull_index == 6'd51)
        pull_index <= 6'd0;
      else
        pull_index <= pull_index + 6'd1;
    end
  end

  assign out_card = cards[pull_index];

endmodule