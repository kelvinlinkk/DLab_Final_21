module sg90_4dir_pwm(
    input sys_clk,
    input sys_rst_n,
    input btn_u, // 上
    input btn_d, // 下
    input btn_l, // 左
    input btn_r, // 右
    output reg pwm
);

    reg [20:0] cnt;
    reg [20:0] duty_cycle;

    // 決定目標工作週期 (Duty Cycle)
    // 優先權順序：左 > 上 > 下 > 右 (避免同時按下的衝突)
    always @(*) begin
        if (btn_l)
            duty_cycle = 21'd50000;   // 0度 (0.5ms)
        else if (btn_u)
            duty_cycle = 21'd100000;  // 45度 (1.0ms)
        else if (btn_d)
            duty_cycle = 21'd200000;  // 135度 (2.0ms)
        else if (btn_r)
            duty_cycle = 21'd250000;  // 180度 (2.5ms)
        else
            duty_cycle = 21'd150000;  // 中間歸位 90度 (1.5ms)
    end

    // PWM 產生器
    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n) begin
            cnt <= 21'd0;
            pwm <= 1'b0;
        end else begin
            // 讓計數器背景持續運作，維持精準的 20ms 週期
            if (cnt == 21'd1999999) begin
                cnt <= 21'd0;
            end else begin
                cnt <= cnt + 21'd1;
            end
            
            // 根據當下決定的 duty_cycle 輸出對應的脈衝寬度
            if (cnt < duty_cycle) begin
                pwm <= 1'b1;
            end else begin
                pwm <= 1'b0;
            end
        end
    end

endmodule