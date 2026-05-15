module clock_divider(
    input clk,
    output reg clk_scan = 0,
    output reg clk_slow = 0
);
    reg [31:0] cnt_scan = 0;
    reg [31:0] cnt_slow = 0;
    always @(posedge clk)
    begin
        if(cnt_scan == 32'd50000)
        begin
            cnt_scan <= 0;
            clk_scan <= ~clk_scan;
        end
        else
            cnt_scan <= cnt_scan + 1;
    end
    always @(posedge clk)
    begin
        if(cnt_slow == 32'd500000)
        begin
            cnt_slow <= 0;
            clk_slow <= ~clk_slow;
        end
        else
            cnt_slow <= cnt_slow + 1;
    end
endmodule