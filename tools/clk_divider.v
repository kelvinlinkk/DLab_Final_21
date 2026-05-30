module clk_divider(
    input clk,
    input rst_n,
    output reg clk_div = 1'b0
);
    parameter  CNT_MAX =  32'd50000;
    reg [31:0] cnt_div = 32'd0;
    always @(posedge clk or negedge rst_n)
    begin
        if(!rst_n)
        begin
            clk_div<=1'b0;
            cnt_div<=32'd0;
        end
        else if(cnt_div == CNT_MAX)
        begin
            cnt_div <= 32'd0;
            clk_div <= ~clk_div;
        end
        else
            cnt_div <= cnt_div + 32'd1;
    end
endmodule