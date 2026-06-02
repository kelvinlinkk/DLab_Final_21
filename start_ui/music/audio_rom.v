// Generated from /home/kelvinlinkk/Documents/Final/start_ui/music/Weibertandmengbert.m4a
// Sample Rate: 11025 Hz, Total Samples: 80384
module audio_rom (
    input sys_clk,
    input [16:0] addr,
    output reg [7:0] pcm_data
);

(* rom_style = "block" *) reg [7:0] rom_array [0:80383];

initial begin
    $readmemh("audio_data.mem", rom_array);
end

always @(posedge sys_clk) begin
    if (addr < 80384) begin
        pcm_data <= rom_array[addr];
    end else begin
        pcm_data <= 8'd128; // Center value (silence)
    end
end

endmodule
