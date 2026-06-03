module audio_ctl(
    input clk,
    input rst_n,
    input play_sound,       // 播放觸發訊號 (pulse)
    input [3:0] sound_id,   // 音效編號 (0~8)
    output audio_out        // 輸出至蜂鳴器/喇叭 (ja1)
);

    // 實例化音效產生器
    tone_top u_tone_top(
        .clk(clk),
        .rst_n(rst_n),
        .tone_signal(play_sound),
        .tone_sel(sound_id),
        .tone_out(audio_out)
    );

endmodule