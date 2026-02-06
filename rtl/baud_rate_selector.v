module baud_sel_gen(input  [1:0]baud_sel,input clk,input rst,input enable_baud,output baud);

reg [23:0] accumulator;


reg baud_reg;
//BAUD RATE SELECTION CALCULATION:
//baudrate*2^24/clockfreq = M
// CLK FREQ = 50Mhz
// M = 3221 for 9600
// M = 6442 for 19200
// M = 12885 for 38400
// M = 19327 for 57600

reg [23:0]m;

always @(baud_sel)
begin
    case(baud_sel)
        2'b00: m = 24'b000000000000110010010101;
        2'b01: m = 24'b000000000001100100101010;
        2'b10: m = 24'b000000000011001001010101;
        2'b11: m = 24'b000000000100101101111111;
        default : m = 24'b0;
endcase
end

always @(posedge clk) begin
    if (rst) begin
        // On reset, clear BOTH the accumulator and the output
        accumulator <= 24'd0;
        baud_reg        <= 1'b0;
    end
    else if (enable_baud) begin
        // The new accumulator value is the sum of the old value and M
        accumulator <= accumulator + m;
        
        // The baud tick is generated ONLY when the sum overflows.
        // This is the most reliable way to detect the carry-out (wrap-around).
        if ( (accumulator + m) >= 2**24 ) begin
              baud_reg <= 1'b1;
        end else begin
              baud_reg <= 1'b0;
        end
    end
    else begin

        baud_reg <= 1'b0;
    end
end

assign baud = baud_reg;

endmodule
