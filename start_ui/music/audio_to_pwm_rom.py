import sys
import numpy as np
try:
    import librosa
except ImportError:
    print("Error: Please install librosa first by running: pip install librosa")
    sys.exit(1)
import os

def convert_audio_to_pwm(audio_path, duration=45.0):
    print(f"Loading {audio_path}...")
    try:
        # Load up to `duration` seconds, downsample to 11025 Hz, mono
        sr = 11025
        y, _ = librosa.load(audio_path, sr=sr, mono=True, duration=duration)
    except Exception as e:
        print(f"Error loading audio file: {e}")
        print("Tip: If you are trying to load an .m4a file, make sure 'ffmpeg' is installed on your system.")
        sys.exit(1)
        
    print(f"Processing {len(y)} samples at {sr} Hz...")
    
    # Normalize volume
    max_val = np.max(np.abs(y))
    if max_val > 0:
        y = y / max_val
        
    # Convert from float [-1.0, 1.0] to 8-bit unsigned integer [0, 255]
    y_8bit = np.clip((y + 1.0) * 127.5, 0, 255).astype(np.uint8)
    
    # Generate .mem file
    mem_file = "audio_data.mem"
    print(f"Writing memory file to {mem_file}...")
    with open(mem_file, 'w') as f:
        for val in y_8bit:
            f.write(f"{val:02X}\n")
            
    # Generate audio_rom.v
    rom_file = "audio_rom.v"
    addr_bits = int(np.ceil(np.log2(len(y_8bit))))
    
    print(f"Generating Verilog ROM module to {rom_file}...")
    with open(rom_file, 'w') as f:
        f.write(f"// Generated from {audio_path}\n")
        f.write(f"// Sample Rate: {sr} Hz, Total Samples: {len(y_8bit)}\n")
        f.write("module audio_rom (\n")
        f.write("    input sys_clk,\n")
        f.write(f"    input [{addr_bits-1}:0] addr,\n")
        f.write("    output reg [7:0] pcm_data\n")
        f.write(");\n\n")
        
        f.write(f"(* rom_style = \"block\" *) reg [7:0] rom_array [0:{len(y_8bit)-1}];\n\n")
        
        f.write("initial begin\n")
        f.write(f"    $readmemh(\"{mem_file}\", rom_array);\n")
        f.write("end\n\n")
        
        f.write("always @(posedge sys_clk) begin\n")
        f.write(f"    if (addr < {len(y_8bit)}) begin\n")
        f.write("        pcm_data <= rom_array[addr];\n")
        f.write("    end else begin\n")
        f.write("        pcm_data <= 8'd128; // Center value (silence)\n")
        f.write("    end\n")
        f.write("end\n\n")
        f.write("endmodule\n")

    print("Done!")
    print(f"Max Address Limit: {len(y_8bit)}")
    print(f"Address Bits: {addr_bits}")
    print("Make sure to update music_player.v with these limits if necessary!")

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Usage: python audio_to_pwm_rom.py <input_audio_file (e.g. .mp3, .m4a, .wav)>")
    else:
        in_file = sys.argv[1]
        convert_audio_to_pwm(in_file)
