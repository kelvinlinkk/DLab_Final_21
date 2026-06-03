module color_fsm(
    input slow_clk,
    input [3:0] rgb1_state,
    output rgb1_r,
    output rgb1_g,
    output rgb1_b
);
    reg [3:0] state = 4'd6;
    reg [7:0] r = 0;
    reg [7:0] g = 0;
    reg [7:0] b = 0;
    pwm_generator rgb1r(
        .clk(slow_clk),
        .duty(r),
        .pwm_out(rgb1_r)
    );
    pwm_generator rgb1g(
        .clk(slow_clk),
        .duty(g),
        .pwm_out(rgb1_g)
    );
    pwm_generator rgb1b(
        .clk(slow_clk),
        .duty(b),
        .pwm_out(rgb1_b)
    );
    reg restart = 1'd0;   
    always @(posedge slow_clk)
    begin
        if(rgb1_state == 4'd6) begin
            state <= 4'd6;
            restart <= 1'd0;
        end 
        else if(rgb1_state == 4'd7)
            state <= 4'd7;
        else if(rgb1_state == 4'd8)
            state <= 4'd8;
        else if(rgb1_state == 4'd9)
            state <= 4'd9;
        else if((rgb1_state == 4'd0)&&(restart == 1'd0)) begin
            state <= 4'd11;
            restart <=1'd1;
        end
        else // default
            state <= 4'd6;
        case(state)
        
        // (0,0,0) -> (50,0,0)
        11:
        begin
            if(r < 50)
            begin
                r <= r + 1;
            end
            else begin
                state <=0;
            end
        end
        // (50,0,0) -> (25,25,0)
        0:
        begin
            if(r > 25)
            begin
                r <= r - 1;
                g <= g + 1;
            end
            else
                state <= 1;
        end

        // (25,25,0) -> (0,50,0)
        1:
        begin
            if(r > 0)
            begin
                r <= r - 1;
                g <= g + 1;
            end
            else
                state <= 2;
        end

        // (0,50,0) -> (0,25,25)
        2:
        begin
            if(g > 25)
            begin
                g <= g - 1;
                b <= b + 1;
            end
            else
                state <= 3;
        end

        // (0,25,25) -> (0,0,50)
        3:
        begin
            if(g > 0)
            begin
                g <= g - 1;
                b <= b + 1;
            end
            else
                state <= 4;
        end

        // (0,0,50) -> (25,0,25)
        4:
        begin
            if(b > 25)
            begin
                r <= r + 1;
                b <= b - 1;
            end
            else
                state <= 5;
        end

        // (25,0,25) -> (50,0,0)
        5:
        begin
            if(b > 0)
            begin
                r <= r + 1;
                b <= b - 1;
            end
            else
                state <= 0;
        end
        
        6: // no rgb
        begin
            r <= 0;
            g <= 0;
            b <= 0;
        end
        7: // red
        begin
            r <= 50;
            g <= 0;
            b <= 0;
        end
        8: // yellow
        begin
            r <= 50;
            g <= 50;
            b <= 0;
        end
        9: // green
        begin
            r <= 0;
            g <= 50;
            b <= 0;
        end
        endcase
    end

endmodule
