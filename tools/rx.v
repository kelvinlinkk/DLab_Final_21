module rx(
    input clk,
    input rst_n,
    input signal_in,
    output reg [7:0] out,
    output reg valid

);
    parameter BAUD_LIMIT = 32'd10416; // 9600 bps
    parameter HALF_BAUD = 32'd5208;   // 確保在資料的正中間取樣

    reg [31:0] baud_cnt;
    reg [3:0] state;
    reg [7:0] data_reg;

    // 兩級暫存器消除亞穩態 (Metastability)，確保外部訊號進 FPGA 內部不會出錯
    reg rx_d1, rx_d2;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            valid <= 1'b0;
            rx_d1 <= 1'b1;
            rx_d2 <= 1'b1;
        end else begin
            rx_d1 <= signal_in;
            rx_d2 <= rx_d1;
        end
    end

    localparam IDLE=0, START=1, D0=2, D1=3, D2=4, D3=5, D4=6, D5=7, D6=8, D7=9, STOP=10;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            valid <= 1'b0;
            state <= IDLE;
            out <= 8'b0;
            valid <= 1'b0;
            baud_cnt <= 0;
            data_reg <= 8'b0;
        end else begin
            valid <= 1'b0;
            case (state)
                IDLE: begin
                    if (rx_d2 == 1'b0) begin // 偵測到線路被拉低 (Start bit)
                        state <= START;
                        baud_cnt <= 0;
                    end
                end
                START: begin
                    if (baud_cnt == HALF_BAUD) begin
                        if (rx_d2 == 1'b0) begin // 數到一半再次確認真的是 Start bit (濾除雜訊)
                            state <= D0;
                            baud_cnt <= 0;
                        end else begin
                            state <= IDLE; 
                        end
                    end else begin
                        baud_cnt <= baud_cnt + 1;
                    end
                end
                D0, D1, D2, D3, D4, D5, D6, D7: begin
                    if (baud_cnt == BAUD_LIMIT - 1) begin
                        baud_cnt <= 0;
                        data_reg[state - 2] <= rx_d2; // 取樣資料
                        state <= state + 1;
                    end else begin
                        baud_cnt <= baud_cnt + 1;
                    end
                end
                STOP: begin
                    if (baud_cnt == BAUD_LIMIT - 1) begin
                        baud_cnt <= 0;
                        state <= IDLE;
                        out <= data_reg;
                        valid <= 1'b1; // Pulse valid
                    end else begin
                        baud_cnt <= baud_cnt + 1;
                    end
                end
                default: state <= IDLE;
            endcase
        end
    end
endmodule