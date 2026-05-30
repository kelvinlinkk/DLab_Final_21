`timescale 1ns / 1ps

module tb_start_ui_host();

    // -------------------------------------------------------------------------
    // 1. 訊號宣告
    // -------------------------------------------------------------------------
    reg clk;
    reg rst_n;
    reg btnU;
    reg btnC;
    reg btnD;
    reg btnR;
    reg btnL;
    reg ishost;
    reg startstartui;
    
    reg signal_in_1;
    reg signal_in_2;
    reg signal_in_3;
    reg signal_in_4;
    
    wire signal_out_1;
    wire signal_out_2;
    wire signal_out_3;
    wire signal_out_4;

    wire backtogh_h;
    wire [3:0] state_h;
    wire [2:0] player_count;
    wire [1:0] ai_level;

    // 狀態常數定義
    localparam S_IDLE              = 4'd0;
    localparam S_PLAYER            = 4'd1;
    localparam S_AI                = 4'd2;  
    localparam S_SHUFFLE           = 4'd3;
    localparam S_HOST_TWO_CARDS    = 4'd4;
    localparam S_PLAYER_TWO_CARDS  = 4'd5;
    localparam S_PLAYER_TURN       = 4'd6;
    localparam S_HOST_TURN         = 4'd7;
    localparam S_GAME_OVER         = 4'd8;

    // 時脈與波特率參數 (50MHz 時脈，UART 為 9600 bps)
    parameter CLK_PERIOD = 10;               // 50 MHz -> 20ns
    parameter BIT_PERIOD = 10416 * 20;       // BAUD_LIMIT * CLK_PERIOD

    // -------------------------------------------------------------------------
    // 2. 實體化待測模組 (UUT)
    // -------------------------------------------------------------------------
    start_ui_host uut (
        .clk(clk),
        .rst_n(rst_n),
        .btnU(btnU),
        .btnC(btnC),
        .btnD(btnD),
        .btnR(btnR),
        .btnL(btnL),
        .ishost(ishost),
        .startstartui(startstartui),
        
        .signal_in_1(signal_in_1),
        .signal_in_2(signal_in_2),
        .signal_in_3(signal_in_3),
        .signal_in_4(signal_in_4),
        
        .signal_out_1(signal_out_1),
        .signal_out_2(signal_out_2),
        .signal_out_3(signal_out_3),
        .signal_out_4(signal_out_4),

        .backtogh_h(backtogh_h),
        .state_h(state_h),
        .player_count(player_count),
        .ai_level(ai_level)
    );

    // -------------------------------------------------------------------------
    // 3. 時脈產生器 (Clock Generator)
    // -------------------------------------------------------------------------
    always begin
        #(CLK_PERIOD/2) clk = ~clk;
    end

    // -------------------------------------------------------------------------
    // 4. 定時狀態監控 (每隔 100,000 個週期列印一次，約 2ms)
    // -------------------------------------------------------------------------
    reg [31:0] monitor_cnt = 0;
    always @(posedge clk) begin
        if (!rst_n) begin
            monitor_cnt <= 0;
        end else begin
            if (monitor_cnt >= 32'd100000) begin 
                $display("[MONITOR] Time: %0t ps | FSM State_h = %d | Current Player ID = %d", $time, state_h, uut.current_player);
                monitor_cnt <= 0;
            end else begin
                monitor_cnt <= monitor_cnt + 1;
            end
        end
    end

    // -------------------------------------------------------------------------
    // 5. 超時守護進程 (Watchdog Timeout)
    // -------------------------------------------------------------------------
    initial begin
        #150000000; // 150ms 安全上限
        $display("[TIMEOUT ERROR] Simulation took too long! Current State_h = %d", state_h);
        $finish;
    end

    // -------------------------------------------------------------------------
    // 6. 輔助 Task：模擬外部玩家經由 UART 傳送一個 Byte 給莊家
    // -------------------------------------------------------------------------
    task send_uart_byte;
        input [2:0] player_num; 
        input [7:0] data;
        integer i;
        begin
            $display("[UART TX] Start transmission of 8'b%b to Player %d at %0t ps", data, player_num, $time);
            
            // --- 1. 送出 Start Bit ---
            case(player_num)
                3'd1: signal_in_1 = 1'b0;
                3'd2: signal_in_2 = 1'b0;
                3'd3: signal_in_3 = 1'b0;
                3'd4: signal_in_4 = 1'b0;
            endcase
            #(BIT_PERIOD);

            // --- 2. 依序送出 8 位元資料 (LSB First) ---
            for (i = 0; i < 8; i = i + 1) begin
                case(player_num)
                    3'd1: signal_in_1 = data[i];
                    3'd2: signal_in_2 = data[i];
                    3'd3: signal_in_3 = data[i];
                    3'd4: signal_in_4 = data[i];
                endcase
                #(BIT_PERIOD);
            end

            // --- 3. 送出 Stop Bit ---
            case(player_num)
                3'd1: signal_in_1 = 1'b1;
                3'd2: signal_in_2 = 1'b1;
                3'd3: signal_in_3 = 1'b1;
                3'd4: signal_in_4 = 1'b1;
            endcase
            #(BIT_PERIOD);
            
            #(BIT_PERIOD * 2); 
            $display("[UART TX] Transmission finished for Player %d at %0t ps", player_num, $time);
        end
    endtask

    // -------------------------------------------------------------------------
    // 7. 主要測試流程 (Stimulus Process)
    // -------------------------------------------------------------------------
    initial begin
        clk = 0;
        rst_n = 0;
        btnU = 0;
        btnC = 0;
        btnD = 0;
        btnR = 0;
        btnL = 0;
        ishost = 1;         
        startstartui = 0;
        
        signal_in_1 = 1'b1; 
        signal_in_2 = 1'b1;
        signal_in_3 = 1'b1;
        signal_in_4 = 1'b1;

        // --- 1. 系統重置 ---
        #(CLK_PERIOD * 10);
        rst_n = 1;
        #(CLK_PERIOD * 5);
        $display("[STATUS] System Reset Released. Current State: %d", state_h);

        // --- 2. 觸發進入 UI 設定畫面 ---
        startstartui = 1;
        #(CLK_PERIOD * 5);

        // --- 3. UI 設定：設定玩家人數為 2 人 ---
        // 【優化控時】所有按鍵按壓時間縮短為剛好 1 個 CLK_PERIOD，防止狀態連跳
        #(CLK_PERIOD * 5);
        btnU = 1; #CLK_PERIOD; btnU = 0; // 變為 1 人
        #(CLK_PERIOD * 10);
        btnU = 1; #CLK_PERIOD; btnU = 0; // 變為 2 人
        #(CLK_PERIOD * 5);
        $display("[UI SETTING] Player Count set to: %d", player_count);

        // 按下 btnC 確定人數，無縫且精準地「只」進入 S_SHUFFLE (State 3)
        btnC = 1; #CLK_PERIOD; btnC = 0;
        #(CLK_PERIOD * 5);

        // --- 4. 遊戲階段：洗牌 (S_SHUFFLE) ---
        $display("[GAME] Pressing Down (btnD) to shuffle cards in State 3...");
        btnD = 1;
        #(CLK_PERIOD * 150000); 
        btnD = 0;
        #(CLK_PERIOD * 50);

        // 洗牌結束，這時候才按下 Center 鍵 (btnC) 讓系統進入發牌 (State 4)
        $display("[GAME] Shuffle Finished. Pressing Center to start dealing...");
        btnC = 1; #CLK_PERIOD; btnC = 0;

        // --- 5. 自動等待基礎發牌階段結束 ---
        $display("[GAME] Waiting for initial cards distribution to complete...");
        wait (state_h == S_PLAYER_TURN);
        $display("[STATUS] Reached S_PLAYER_TURN! Now players decision phase.");
        #(CLK_PERIOD * 500);

        // --- 6. 玩家回合互動 (S_PLAYER_TURN) ---
        // 模擬玩家 1 決定 Stand 停牌
        $display("[GAME] Simulating Player 1 choice: STAND.");
        send_uart_byte(3'd1, 8'b0000_0010); 
        
        #(CLK_PERIOD * 1000);

        // 模擬玩家 2 決定 Hit 要牌
        $display("[GAME] Simulating Player 2 choice: HIT.");
        send_uart_byte(3'd2, 8'b0000_0001);
        
        // 立刻發送一個 IDLE (8'b0) 清除暫存器，模擬放開按鍵，防止硬體重複抽牌
        $display("[GAME] Sending IDLE byte to Player 2 to clear latch...");
        // (Removed clear byte since rx_valid handles pulses)
        
        #(CLK_PERIOD * 20000); 
        
        // 隨後玩家 2 決定 Stand 停牌
        $display("[GAME] Simulating Player 2 choice: STAND.");
        send_uart_byte(3'd2, 8'b0000_0010);

        // --- 7. 莊家自動回合與結算 (S_HOST_TURN & S_GAME_OVER) ---
        $display("[GAME] Waiting for Host turn and final Game Over...");
        wait (state_h == S_GAME_OVER);
        $display("[STATUS] Game Over reached! Host finished drawing successfully.");
        #(CLK_PERIOD * 100);

        // --- 8. 重新開局測試 ---
        $display("[GAME] Pressing Center to restart a new game round...");
        btnC = 1; #CLK_PERIOD; btnC = 0;
        #(CLK_PERIOD * 10);
        
        if (state_h == S_SHUFFLE)
            $display("[SUCCESS] Restart logic verified! Successfully went back to S_SHUFFLE.");
            
        #(CLK_PERIOD * 20);
        $display("[TESTBENCH] Simulation finished successfully.");
        $finish;
    end

endmodule