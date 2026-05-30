module top(
    input CLK100MHZ,
    input [15:0] SW,
    input BTNC,
    input pmod_rx,
    output pmod_tx,
    output [7:0] seg,
    output [7:0] an
);

    // SW[0] 作為 Reset (Active Low)
    wire rst_n = ~SW[0];
    
    // 使用 SW[15:8] 作為欲發送的 8-bit 資料
    wire [7:0] tx_data = SW[15:8];
    wire [7:0] rx_data;
    wire tx_valid;
    wire tx_busy;

    // ----------------------------------------------------
    // 按鈕邊緣偵測 (避免按住 BTNC 時重複發送資料)
    // ----------------------------------------------------
    reg btnc_d1, btnc_d2;
    always @(posedge CLK100MHZ or negedge rst_n) begin
        if (!rst_n) begin
            btnc_d1 <= 1'b0;
            btnc_d2 <= 1'b0;
        end else begin
            btnc_d1 <= BTNC;
            btnc_d2 <= btnc_d1;
        end
    end
    assign tx_valid = btnc_d1 & ~btnc_d2; // 偵測上升緣

    // ----------------------------------------------------
    // TX 模組實體化
    // ----------------------------------------------------
    tx tx_inst(
        .clk(CLK100MHZ),
        .rst_n(rst_n),
        .data_in(tx_data),
        .valid(tx_valid),
        .signal_out(pmod_tx),
        .busy(tx_busy)
    );

    // ----------------------------------------------------
    // RX 模組實體化
    // ----------------------------------------------------
    rx rx_inst(
        .clk(CLK100MHZ),
        .rst_n(rst_n),
        .signal_in(pmod_rx),
        .out(rx_data)
    );

    // ----------------------------------------------------
    // 顯示解碼器實體化
    // ----------------------------------------------------
    // 將 8-bit 資料切成兩個 4-bit，並補足為 6-bit 配合你的 decoder 輸入格式
    wire [5:0] disp_tx_high = {2'b0, tx_data[7:4]};
    wire [5:0] disp_tx_low  = {2'b0, tx_data[3:0]};
    wire [5:0] disp_rx_high = {2'b0, rx_data[7:4]};
    wire [5:0] disp_rx_low  = {2'b0, rx_data[3:0]};

    segment_decoder seg_inst(
        .clk(CLK100MHZ),
        .rst_n(rst_n),
        .d0(disp_rx_low),   // 最右側：顯示 RX 低位
        .d1(disp_rx_high),  // 顯示 RX 高位
        .d2(6'd34),         // 空白
        .d3(6'd34),         // 空白
        .d4(6'd34),         // 空白
        .d5(6'd34),         // 空白
        .d6(disp_tx_low),   // 顯示 TX 低位
        .d7(disp_tx_high),  // 最左側：顯示 TX 高位
        .seg(seg),
        .an(an)
    );

endmodule