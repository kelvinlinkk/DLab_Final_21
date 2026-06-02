module music_player (
    input sys_clk,
    input sys_rst_n,
    input play_en,
    output tone_out
);

    // Audio sample rate: 11025 Hz
    // Clock frequency: 100 MHz
    // 100,000,000 / 11,025 = 9070.29 -> 9070 cycles per sample
    reg [13:0] sample_timer;
    reg [18:0] rom_addr; // up to 496125 (fits 45 sec audio)
    wire [7:0] pcm_data;

    // Sample Clock generator & Address Counter
    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n) begin
            sample_timer <= 0;
            rom_addr <= 0;
        end else if (play_en) begin
            if (sample_timer >= 14'd9069) begin
                sample_timer <= 0;
                // Max address from python script: 496125
                if (rom_addr < 19'd496124) begin
                    rom_addr <= rom_addr + 1;
                end else begin
                    rom_addr <= 0; // Loop back
                end
            end else begin
                sample_timer <= sample_timer + 1;
            end
        end else begin
            sample_timer <= 0;
            rom_addr <= 0;
        end
    end

    // ROM instantiation
    audio_rom rom_inst (
        .sys_clk(sys_clk),
        .addr(rom_addr),
        .pcm_data(pcm_data)
    );

    // High-frequency PWM generator (100 MHz clock)
    // pcm_data is 0-255.
    // PWM period is 256 cycles = 100M / 256 = 390.6 kHz, 
    // This high frequency is completely inaudible and acts as a DAC.
    reg [7:0] pwm_counter;
    reg pwm_out;

    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n) begin
            pwm_counter <= 0;
            pwm_out <= 0;
        end else begin
            pwm_counter <= pwm_counter + 1;
            if (pwm_counter < pcm_data) begin
                pwm_out <= 1'b1;
            end else begin
                pwm_out <= 1'b0;
            end
        end
    end

    assign tone_out = (play_en) ? pwm_out : 1'b0;

endmodule
