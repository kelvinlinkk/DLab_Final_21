module press_button(
    input clk,
    input btn,
    output reg pulse
);
    reg [2:0] shift = 0;
    always @(posedge clk)
    begin
        shift <= {shift[1:0], btn};
        if(shift[2:1] == 2'b01)
            pulse <= 1;
        else
            pulse <= 0;
    end
endmodule