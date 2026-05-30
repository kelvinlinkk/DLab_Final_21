module rng( // random number generator
    input clk,
    input rst_n,
    input pull,
    input [5:0] range,
    output reg [5:0] out
);

wire [5:0] cnt_out;

cntr_6bit #(.CNT_1S_MAX(30'd1000)) cntr_6bit(
    .sys_clk(clk),
    .sys_rst_n(rst_n),
    .isUP(1'b1),
    .target_val(range),
    .div_1s(),
    .out(cnt_out)
);


reg pull_d1;
reg pull_d2;
wire pull_pos_edge;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        pull_d1 <= 1'b0;
        pull_d2 <= 1'b0;
    end else begin
        pull_d1 <= pull;
        pull_d2 <= pull_d1;
    end
end

assign pull_pos_edge = pull_d1 & ~pull_d2;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        out <= 6'd0;
    end else if (pull_pos_edge) begin
        out <= cnt_out;
    end
end

endmodule