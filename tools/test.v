module top( 
    input  wire        CLK100MHZ,
    input  wire [15:0] SW,       // 使用 SW[0] 作為 Reset 開關
    input  wire        BTNC,     // 中間按鈕：抽牌 (pull)
    input  wire        BTNU,     // 上方按鈕：洗牌 (shuffle)

    output wire [7:0]  seg,      // 七段顯示器段選
    output wire [7:0]  an        // 七段顯示器位選
);

    // ==========================================
    // 1. 系統重置訊號
    // ==========================================
    // 當 SW[0] 往上撥時為 1 (正常運作)，往下撥時為 0 (Reset)
    wire rst_n = SW[0];

    // ==========================================
    // 2. 按鈕防彈跳 (Debouncer) + 單脈衝 (One-Pulse)
    // ==========================================
    reg [19:0] debounce_cnt;
    reg btnc_stable;

    // 10ms 防彈跳邏輯 (100MHz * 10ms = 1,000,000)
    always @(posedge CLK100MHZ or negedge rst_n) begin
        if (!rst_n) begin
            debounce_cnt <= 20'd0;
            btnc_stable  <= 1'b0;
        end else begin
            if (BTNC == btnc_stable) begin
                debounce_cnt <= 20'd0; // 狀態沒變，計數器歸零
            end else begin
                debounce_cnt <= debounce_cnt + 20'd1;
                if (debounce_cnt == 20'd1_000_000) begin // 狀態穩定維持 10ms
                    btnc_stable <= BTNC;
                    debounce_cnt <= 20'd0;
                end
            end
        end
    end

    // 將穩定後的按鈕訊號轉換為一個 Clock 寬度的單脈衝
    reg pull_d1;
    always @(posedge CLK100MHZ or negedge rst_n) begin
        if (!rst_n) pull_d1 <= 1'b0;
        else pull_d1 <= btnc_stable;
    end
    
    wire pull_pulse = btnc_stable & ~pull_d1;

    // ==========================================
    // 3. 例示化發牌模組
    // ==========================================
    wire [3:0] current_card; // 抽出來的牌 (1~13)

    serve serve_inst(
        .clk(CLK100MHZ),
        .rst_n(rst_n),
        .shuffle(BTNU),       // 按住 BTNU 進行洗牌
        .pull(pull_pulse),    // 傳入安全的單脈衝
        .out_card(current_card)
    );

    // ==========================================
    // 4. 輔助計數器 (記錄目前抽到第 1 ~ 52 張)
    // ==========================================
    reg [5:0] card_count;
    always @(posedge CLK100MHZ or negedge rst_n) begin
        if (!rst_n) begin
            card_count <= 6'd1;
        end else if (pull_pulse) begin
            if (card_count == 6'd52) 
                card_count <= 6'd1; // 發完 52 張循環
            else 
                card_count <= card_count + 6'd1;
        end
    end

    // ==========================================
    // 5. 數值轉換 (轉為十位數與個位數)
    // ==========================================
    // 右側顯示點數 (1~13)
    wire [5:0] card_tens = (current_card >= 10) ? 6'd1 : 6'd34; // 0 不亮
    wire [5:0] card_ones = (current_card >= 10) ? {2'b00, (current_card - 4'd10)} : {2'b00, current_card};

    // 左側顯示進度 (1~52)
    wire [5:0] actual_count_tens = (card_count >= 50) ? 6'd5 :
                                   (card_count >= 40) ? 6'd4 :
                                   (card_count >= 30) ? 6'd3 :
                                   (card_count >= 20) ? 6'd2 :
                                   (card_count >= 10) ? 6'd1 : 6'd0;
                                   
    wire [5:0] count_tens = (actual_count_tens == 0) ? 6'd34 : actual_count_tens; // 0 不亮
    wire [5:0] count_ones = card_count - (actual_count_tens * 10);

    // ==========================================
    // 6. 七段顯示器掃描除頻器 (100MHz -> 1kHz)
    // ==========================================
    reg [16:0] div_cnt;
    reg clk_1kHz;

    always @(posedge CLK100MHZ or negedge rst_n) begin
        if (!rst_n) begin
            div_cnt <= 17'd0;
            clk_1kHz <= 1'b0;
        end else if (div_cnt == 17'd49999) begin
            div_cnt <= 17'd0;
            clk_1kHz <= ~clk_1kHz;
        end else begin
            div_cnt <= div_cnt + 17'd1;
        end
    end

    // ==========================================
    // 7. 例示化七段顯示器解碼器
    // ==========================================
    segment_decoder seg_inst(
        .clk(clk_1kHz),
        .rst_n(rst_n),
        .d0(card_ones),     // 最右側：點數個位
        .d1(card_tens),     // 點數十位
        .d2(6'd34),
        .d3(6'd34),
        .d4(6'd34),
        .d5(6'd34),
        .d6(count_ones),    // 倒數第二位：進度個位
        .d7(count_tens),    // 最左側：進度十位
        .seg(seg),
        .an(an)
    );

endmodule