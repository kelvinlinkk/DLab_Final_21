module pwm_generator(
    input clk,
    input [7:0] duty,
    output reg pwm_out = 0
);

    reg [7:0] pwm_count = 0;

    always @(posedge clk)
    begin
        if (pwm_count < 8'd50) begin
            pwm_count <= pwm_count + 1;
        end else begin
            pwm_count <= 8'd0;
        end
        if(pwm_count < duty)
            pwm_out <= 1'b1;
        else
            pwm_out <= 1'b0;
    end

endmodule