module tx(
    input clk,
    input rst_n,
    input [7:0] data_in,
    input valid,
    output reg signal_out,
    output reg busy
);
    // 使用 100MHz 產生 9600 bps 的傳輸速率
    parameter BAUD_LIMIT = 32'd10416; 
    reg [31:0] baud_cnt;

    reg [3:0] state;
    reg [7:0] data_reg;
    localparam IDLE=0, START=1, D0=2, D1=3, D2=4, D3=5, D4=6, D5=7, D6=8, D7=9, STOP=10;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            signal_out <= 1'b1; // 閒置時保持高電位
            busy <= 1'b0;
            data_reg <= 8'b0;
            baud_cnt <= 0;
        end else begin
            case (state)
                IDLE: begin
                    signal_out <= 1'b1;
                    // 因為直接吃 100MHz，所以絕對抓得到 valid 的 10ns 突波
                    if (valid && !busy) begin
                        data_reg <= data_in;
                        busy <= 1'b1;
                        state <= START;
                        baud_cnt <= 0;
                        signal_out <= 1'b0; // 立即送出 Start bit (0)
                    end else begin
                        busy <= 1'b0;
                    end
                end
                START, D0, D1, D2, D3, D4, D5, D6, D7: begin
                    if (baud_cnt == BAUD_LIMIT - 1) begin
                        baud_cnt <= 0;
                        state <= state + 1;
                        // 依照狀態送出對應的 bit
                        if (state == START) signal_out <= data_reg[0];
                        else if (state == D0) signal_out <= data_reg[1];
                        else if (state == D1) signal_out <= data_reg[2];
                        else if (state == D2) signal_out <= data_reg[3];
                        else if (state == D3) signal_out <= data_reg[4];
                        else if (state == D4) signal_out <= data_reg[5];
                        else if (state == D5) signal_out <= data_reg[6];
                        else if (state == D6) signal_out <= data_reg[7];
                        else if (state == D7) signal_out <= 1'b1; // 送出 Stop bit (1)
                    end else begin
                        baud_cnt <= baud_cnt + 1;
                    end
                end
                STOP: begin
                    if (baud_cnt == BAUD_LIMIT - 1) begin
                        baud_cnt <= 0;
                        state <= IDLE; // 傳輸完成，回到閒置
                        busy <= 1'b0;
                    end else begin
                        baud_cnt <= baud_cnt + 1;
                    end
                end
                default: state <= IDLE;
            endcase
        end
    end
endmodule