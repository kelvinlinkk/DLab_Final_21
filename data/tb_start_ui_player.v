`timescale 1ns / 1ps

module tb_start_ui_player();

    // Inputs
    reg clk;
    reg rst_n;
    reg host_ace;
    reg btnU;
    reg btnC;
    reg btnD;
    reg btnR;
    reg btnL;
    reg signal_in;
    reg ishost;
    reg startstartui;

    // Outputs
    wire [1:0] lose_win;
    wire insurance_yn;
    wire backtogh_p;
    wire [3:0] state;
    wire [3:0] card_0, card_1, card_2, card_3, card_4;
    wire card_left_right;
    wire signal_out;
    wire [5:0] money_you_have_thousands, money_you_have_hundreds, money_you_have_tens, money_you_have_ones;
    wire [5:0] money_you_bet_hundreds, money_you_bet_tens, money_you_bet_ones;

    // =======================================================
    // 關鍵參數設定：符合 Nexys4 100MHz 與 UART 9600 bps
    // =======================================================
    parameter CLK_PERIOD = 10; // 100 MHz
    parameter BIT_PERIOD = 104167; // 1 second / 9600 baud in nanoseconds

    // Instantiate the Unit Under Test (UUT)
    start_ui_player uut (
        .clk(clk),
        .rst_n(rst_n),
        .host_ace(host_ace),
        .btnU(btnU),
        .btnC(btnC),
        .btnD(btnD),
        .btnR(btnR),
        .btnL(btnL),
        .signal_in(signal_in),
        .ishost(ishost),
        .startstartui(startstartui),
        .lose_win(lose_win),
        .insurance_yn(insurance_yn),
        .backtogh_p(backtogh_p),
        .state(state),
        .card_0(card_0),
        .card_1(card_1),
        .card_2(card_2),
        .card_3(card_3),
        .card_4(card_4),
        .card_left_right(card_left_right),
        .signal_out(signal_out),
        .money_you_have_thousands(money_you_have_thousands),
        .money_you_have_hundreds(money_you_have_hundreds),
        .money_you_have_tens(money_you_have_tens),
        .money_you_have_ones(money_you_have_ones),
        .money_you_bet_hundreds(money_you_bet_hundreds),
        .money_you_bet_tens(money_you_bet_tens),
        .money_you_bet_ones(money_you_bet_ones)
    );

    // 產生 100 MHz 的 Clock
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // UART 發送 Task (模擬莊家發送 9600 baud 的訊號)
    task send_uart_byte(input [7:0] data);
        integer i;
        begin
            signal_in = 0; // Start bit
            #(BIT_PERIOD);
            for (i = 0; i < 8; i = i + 1) begin
                signal_in = data[i]; // Data bits
                #(BIT_PERIOD);
            end
            signal_in = 1; // Stop bit
            #(BIT_PERIOD);
            #(CLK_PERIOD * 10); // 短暫延遲
        end
    endtask

    // =======================================================
    // 模擬流程開始
    // =======================================================
    initial begin
        // 1. 初始化所有輸入訊號
        rst_n = 0;
        host_ace = 0;
        btnU = 0; btnC = 0; btnD = 0; btnR = 0; btnL = 0;
        signal_in = 1; // UART 閒置為 High
        ishost = 0;
        startstartui = 0;

        // 2. 解除 Reset
        #(CLK_PERIOD * 10);
        rst_n = 1;
        #(CLK_PERIOD * 10);

        // 3. 開啟 UI 並進入下注狀態 (S_money_p1 / State 11)
        startstartui = 1;
        #(CLK_PERIOD * 10);
        
        // 4. 下注 (按 UP 3 次，每次加 20，共下注 60)
        repeat(3) begin
            btnU = 1; #(CLK_PERIOD * 5);
            btnU = 0; #(CLK_PERIOD * 5);
        end
        
        // 5. 確認下注 (按 C)，進入 wait_start (State 0)
        btnC = 1; #(CLK_PERIOD * 5);
        btnC = 0; #(CLK_PERIOD * 5);
        #(CLK_PERIOD * 10); 
        
        // 6. 遊戲開始！(再按一次 C 觸發 init)，進入 check_host_ace (State 1)
        btnC = 1; #(CLK_PERIOD * 5);
        btnC = 0; #(CLK_PERIOD * 5);

        // -----------------------------------------------------------
        // UART 收牌與狀態機自動跳轉流程
        // -----------------------------------------------------------
        wait (state == 4'd1); // 等待確定進入 State 1
        #(CLK_PERIOD * 10); 

        // 7. 莊家確認沒有 Ace
        send_uart_byte(8'b1000_0000); 
        wait (state != 4'd1); // 等待跳轉出 State 1
        #(CLK_PERIOD * 10);
        send_uart_byte(8'b0000_0000); // 傳送 Clear Byte 歸零 rx[7]

        // 8. 莊家發 Card 0 給玩家 (值為 10)
        send_uart_byte(8'b1000_1010); 
        wait (state != 4'd3); // 等待跳轉出 card_get_0
        send_uart_byte(8'b0000_0000); // CLEAR BYTE

        // 9. 莊家發 Card 1 給玩家 (值為 9)
        send_uart_byte(8'b1000_1001); 
        wait (state != 4'd4); // 等待跳轉出 card_get_1
        send_uart_byte(8'b0000_0000); // CLEAR BYTE
        
        // 10. 莊家發 Card 2 給玩家 (因為你的程式強制收三張牌才進 card_get_3)
        send_uart_byte(8'b1000_0000); // 假設這張牌值為 0
        
        // 等待進入 card_get_3 (State 6)，此時才允許按 btnD 停牌
        wait (state == 4'd6); 
        #(CLK_PERIOD * 10); 
        
        // 玩家按下 btnD 停牌 (Stand)
        btnD = 1; #(CLK_PERIOD * 5);
        btnD = 0; #(CLK_PERIOD * 5);

        // 等待 FSM 進入 wait_host (State 8)
        wait (state == 4'd8);
        #(CLK_PERIOD * 10);

        // 11. 莊家開牌並送出最終點數總和 (18點 -> 5'd18)
        send_uart_byte(8'b0000_0000); // CLEAR BYTE
        send_uart_byte(8'b1010_0100); 

        // 12. 讓 FSM 去跑結算邏輯 (game_over1 -> game_over2)
        // 最後等待它回到下注畫面 (S_money_p1 / State 11)
        wait (state == 4'd11); 

        // 印出最終贏錢結果
        $display("==================================================");
        $display("Simulation Complete!");
        $display("Final Money: %d%d%d%d", money_you_have_thousands, money_you_have_hundreds, money_you_have_tens, money_you_have_ones);
        if (lose_win == 2'd3) $display("Result: PLAYER WINS!");
        else if (lose_win == 2'd1) $display("Result: PLAYER LOSES!");
        else $display("Result: PUSH (TIE)");
        $display("==================================================");

        $finish;
    end

endmodule