module segment_decoder(
    input clk,
    input [5:0] d0,
    input [5:0] d1,
    input [5:0] d2,
    input [5:0] d3,
    input [5:0] d4,
    input [5:0] d5,
    input [5:0] d6,
    input [5:0] d7,
    output reg [7:0] seg,
    output reg [7:0] an
);
    reg [2:0] scan = 0;
    reg [5:0] current;
    always @(posedge clk)
    begin
        scan <= scan + 1;
    end
    always @(*)
    begin
        case(scan)
            3'd0:
            begin
                an = 8'b11111110;
                current = d0;
            end

            3'd1:
            begin
                an = 8'b11111101;
                current = d1;
            end

            3'd2:
            begin
                an = 8'b11111011;
                current = d2;
            end

            3'd3:
            begin
                an = 8'b11110111;
                current = d3;
            end
            
            3'd4:
            begin
                an = 8'b11101111;
                current = d4;
            end
            
            3'd5:
            begin
                an = 8'b11011111;
                current = d5;
            end
            
            3'd6:
            begin
                an = 8'b10111111;
                current = d6;
            end
            
            3'd7:
            begin
                an = 8'b01111111;
                current = d7;
            end

        endcase

    end
    always @(*)
    begin
        case(current)
            0: seg = 8'b11000000;//0,O
            1: seg = 8'b11111001;//1,I
            2: seg = 8'b10100100;//2
            3: seg = 8'b10110000;//3
            4: seg = 8'b10011001;//4
            5: seg = 8'b10010010;//5
            6: seg = 8'b10000010;//6
            7: seg = 8'b11011000;//7
            8: seg = 8'b10000000;//8
            9: seg = 8'b10011000;//9
            10: seg = 8'b10001000;//A            
            12: seg = 8'b11000110;//C
            14: seg = 8'b10000110;//E
            15: seg = 8'b10001110;//F
            17: seg = 8'b10001001;//H
            18: seg = 8'b11100001;//J
            19: seg = 8'b00001001;//K
            20: seg = 8'b11000111;//L
            23: seg = 8'b10001100;//P
            24: seg = 8'b01000000;//Q
            26: seg = 8'b10010010;//S
            28: seg = 8'b11000001;//U
            32: seg = 8'b10010001;//Y
            34: seg = 8'b11111111;//blank
            default:
                seg = 8'b11111111;

        endcase

    end

endmodule
