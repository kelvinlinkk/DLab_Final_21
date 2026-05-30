`timescale 1ns / 1ps

module tb_system();

    // -------------------------------------------------------------------------
    // 1. Clock and Reset Generation (Simulating Two Separate FPGAs)
    // -------------------------------------------------------------------------
    parameter CLK_PERIOD_HOST = 20;   // 50 MHz for Host
    parameter CLK_PERIOD_PLAYER = 20; // 50 MHz for Player
    parameter PHASE_SHIFT = 5;        // Phase difference to simulate separate oscillators

    reg clk_host;
    reg clk_player;
    reg rst_n_host;
    reg rst_n_player;

    initial begin
        clk_host = 0;
        forever #(CLK_PERIOD_HOST/2) clk_host = ~clk_host;
    end

    initial begin
        #(PHASE_SHIFT); // Introduce phase shift
        clk_player = 0;
        forever #(CLK_PERIOD_PLAYER/2) clk_player = ~clk_player;
    end

    initial begin
        rst_n_host = 0;
        rst_n_player = 0;
        #(100);
        rst_n_host = 1;
        rst_n_player = 1;
    end

    // -------------------------------------------------------------------------
    // 2. Signals for Host
    // -------------------------------------------------------------------------
    reg btnU_h, btnC_h, btnD_h, btnR_h, btnL_h;
    reg ishost_h;
    reg startstartui_h;
    
    wire signal_out_1, signal_out_2, signal_out_3, signal_out_4;
    wire backtogh_h;
    wire [3:0] state_h;
    wire [2:0] player_count;
    wire [1:0] ai_level;

    // -------------------------------------------------------------------------
    // 3. Signals for Player
    // -------------------------------------------------------------------------
    reg btnU_p, btnC_p, btnD_p, btnR_p, btnL_p;
    reg ishost_p;
    reg startstartui_p;

    wire [1:0] lose_win;
    wire insurance_yn;
    wire backtogh_p;
    wire [3:0] state_p;
    wire [3:0] card_0, card_1, card_2, card_3, card_4;
    wire card_left_right;
    wire signal_out_p;

    // -------------------------------------------------------------------------
    // 4. UART Connection with Simulated Noise/Delay
    // -------------------------------------------------------------------------
    wire host_tx_to_player_rx;
    wire player_tx_to_host_rx;

    // Simple delay to simulate physical wire
    assign #10 host_tx_to_player_rx = signal_out_1;
    assign #10 player_tx_to_host_rx = signal_out_p;

    // -------------------------------------------------------------------------
    // 5. Instantiation
    // -------------------------------------------------------------------------
    start_ui_host uut_host (
        .clk(clk_host),
        .rst_n(rst_n_host),
        .btnU(btnU_h), .btnC(btnC_h), .btnD(btnD_h), .btnR(btnR_h), .btnL(btnL_h),
        .ishost(ishost_h),
        .startstartui(startstartui_h),
        
        .signal_in_1(player_tx_to_host_rx), // Connect Player TX to Host RX 1
        .signal_in_2(1'b1), // Unused players tied high
        .signal_in_3(1'b1),
        .signal_in_4(1'b1),
        
        .signal_out_1(signal_out_1),
        .signal_out_2(signal_out_2),
        .signal_out_3(signal_out_3),
        .signal_out_4(signal_out_4),

        .backtogh_h(backtogh_h),
        .state_h(state_h),
        .player_count(player_count),
        .ai_level(ai_level)
    );

    start_ui_player uut_player (
        .clk(clk_player),
        .rst_n(rst_n_player),
        .host_ace(1'b0), // Not directly used in latest logic, UART gives ace info
        .btnU(btnU_p), .btnC(btnC_p), .btnD(btnD_p), .btnR(btnR_p), .btnL(btnL_p),
        .signal_in(host_tx_to_player_rx), // Connect Host TX to Player RX
        .ishost(ishost_p),
        .startstartui(startstartui_p),
        
        .lose_win(lose_win),
        .insurance_yn(insurance_yn),
        .backtogh_p(backtogh_p),
        .state(state_p),
        .card_0(card_0), .card_1(card_1), .card_2(card_2), .card_3(card_3), .card_4(card_4),
        .card_left_right(card_left_right),
        .signal_out(signal_out_p)
    );

    // -------------------------------------------------------------------------
    // 6. Test Sequence
    // -------------------------------------------------------------------------
    initial begin
        // Init Host
        btnU_h = 0; btnC_h = 0; btnD_h = 0; btnR_h = 0; btnL_h = 0;
        ishost_h = 1; startstartui_h = 0;
        
        // Init Player
        btnU_p = 0; btnC_p = 0; btnD_p = 0; btnR_p = 0; btnL_p = 0;
        ishost_p = 0; startstartui_p = 0;

        #(CLK_PERIOD_HOST * 20);

        // 1. Enter UI
        startstartui_h = 1;
        startstartui_p = 1;
        #(CLK_PERIOD_HOST * 5);
        
        // --- Player Setup ---
        // Player sets bet money (press C)
        $display("[%0t] Player sets bet and waits...", $time);
        btnC_p = 1; #(CLK_PERIOD_PLAYER); btnC_p = 0;
        #(CLK_PERIOD_PLAYER * 5);
        btnC_p = 1; #(CLK_PERIOD_PLAYER); btnC_p = 0; // Confirm bet, enter wait_start

        // --- Host Setup ---
        // Host sets player count to 1
        $display("[%0t] Host sets player count to 1...", $time);
        btnU_h = 1; #(CLK_PERIOD_HOST); btnU_h = 0;
        #(CLK_PERIOD_HOST * 5);
        btnC_h = 1; #(CLK_PERIOD_HOST); btnC_h = 0; // Confirm player count, enter SHUFFLE

        // Host shuffles
        $display("[%0t] Host shuffles...", $time);
        btnD_h = 1; #(CLK_PERIOD_HOST * 50); btnD_h = 0;
        #(CLK_PERIOD_HOST * 10);
        
        // Player must press start (btnC) to enter check_host_ace state BEFORE host sends the first byte
        $display("[%0t] Player presses Start to wait for host data...", $time);
        btnC_p = 1; #(CLK_PERIOD_PLAYER); btnC_p = 0;
        #(CLK_PERIOD_PLAYER * 10);

        btnC_h = 1; #(CLK_PERIOD_HOST); btnC_h = 0; // Confirm shuffle, start dealing

        // Now wait for Host to reach S_PLAYER_TURN (wait for UART transmission of initial cards)
        $display("[%0t] Waiting for initial cards to be dealt...", $time);
        wait (state_h == 4'd6); // S_PLAYER_TURN
        $display("[%0t] Host reached S_PLAYER_TURN.", $time);

        // Wait for Player to reach card_get_2 (meaning it received 2 cards)
        wait (state_p == 4'd5); // card_get_2
        $display("[%0t] Player received initial cards.", $time);

        #(CLK_PERIOD_HOST * 50000); // Wait a bit for UART lines to clear completely

        // --- Player Action (HIT) ---
        $display("[%0t] Player requests HIT (press U)...", $time);
        btnU_p = 1; #(CLK_PERIOD_PLAYER); btnU_p = 0;
        
        // Wait for Player to reach card_get_3
        wait (state_p == 4'd6); // card_get_3
        $display("[%0t] Player received 3rd card.", $time);
        
        #(CLK_PERIOD_HOST * 50000);

        // --- Player Action (STAND) ---
        $display("[%0t] Player requests STAND (press D)...", $time);
        btnD_p = 1; #(CLK_PERIOD_PLAYER); btnD_p = 0;

        // Wait for Host to reach S_HOST_TURN then S_GAME_OVER
        wait (state_h == 4'd8); // S_GAME_OVER
        $display("[%0t] Host reached GAME OVER.", $time);
        
        // Wait for Player to reach game_over2 or S_money_p1 (round finished)
        wait (state_p == 4'd12 || state_p == 4'd11);
        $display("[%0t] Player reached end of round. Lose_win status: %d", $time, lose_win);

        #(CLK_PERIOD_HOST * 1000);
        $display("Simulation Finished Successfully.");
        $finish;
    end

    // Timeout watchdog
    initial begin
        #(200_000_000); // 200 ms timeout
        $display("TIMEOUT ERROR");
        $finish;
    end

endmodule