module reciever(
    input wire clk,
    input wire rst,
    input wire rxd,
    input wire baud_tick,     
    output reg [7:0] o_data,
    output reg                 o_data_valid
);


    localparam [2:0] STATE_IDLE      = 3'b000;
    localparam [2:0] STATE_START_BIT = 3'b001;
    localparam [2:0] STATE_DATA_BITS = 3'b010;
    localparam [2:0] STATE_STOP_BIT  = 3'b011;
    localparam [2:0] STATE_CLEANUP   = 3'b100;

    reg [2:0] r_state;
    reg [2:0] r_bit_count;
    reg [7:0] r_data_buffer;

    always @(posedge clk or posedge rst) begin
        if (rst) begin

            r_state       <= STATE_IDLE;
            r_bit_count   <= 0;
            r_data_buffer <= 0;
            o_data        <= 0;
            o_data_valid  <= 1'b0;
        end else begin
            if (o_data_valid) begin
                o_data_valid <= 1'b0;
            end

            case (r_state)
                STATE_IDLE: begin
 
                    if (rxd == 1'b0) begin

                        if (baud_tick) begin
                            r_state <= STATE_DATA_BITS;
                            r_bit_count <= 0;
                        end
                    end else begin
                        r_state <= STATE_IDLE;
                    end
                end

                STATE_DATA_BITS: begin
                    if (baud_tick) begin

                        r_data_buffer[r_bit_count] <= rxd;

                        if (r_bit_count < 7) begin
                            r_bit_count <= r_bit_count + 1;
                            r_state     <= STATE_DATA_BITS;
                        end else begin
                            r_bit_count <= 0; 
                            r_state     <= STATE_STOP_BIT;
                        end
                    end
                end

                STATE_STOP_BIT: begin
                    if (baud_tick) begin
                        // A valid frame should have a high stop bit.
                        // We don't check for framing errors here for simplicity,
                        // but you could add that logic.
                        if (rxd == 1'b1) begin
                            r_state <= STATE_CLEANUP;
                        end else begin
                            // Framing Error! Return to IDLE.
                            r_state <= STATE_IDLE;
                        end
                    end
                end

                STATE_CLEANUP: begin
                    // Assign received data to output and set valid flag
                    o_data       <= r_data_buffer;
                    o_data_valid <= 1'b1;
                    r_state      <= STATE_IDLE;
                end

                default: begin
                    r_state <= STATE_IDLE;
                end
            endcase
        end
    end

endmodule
