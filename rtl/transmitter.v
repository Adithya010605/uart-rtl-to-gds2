module transmitter(
    input           clk,
    input           rst,
    input   [7:0]   trans_data,
    input           tran_start,
    input           baud,
    output  reg     txd,
    output  reg     tx_busy
);

  // States
  localparam [1:0] IDLE = 2'b00,
                   START= 2'b01,
                   DATA = 2'b10,
                   STOP = 2'b11;

  reg [1:0] state, next_state;
  reg [7:0] tx_buffer;
  reg [2:0] counter;

  // Rising-edge detect for 'baud' to create a 1-cycle enable
  reg baud_d;
  always @(posedge clk or posedge rst) begin
    if (rst) baud_d <= 1'b0;
    else     baud_d <= baud;
  end
  wire baud_tick = baud & ~baud_d;  // 1 'clk' wide pulse

  // State & data regs
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      state     <= IDLE;
      counter   <= 3'd0;
      tx_buffer <= 8'd0;
    end else begin
      state <= next_state;

      // Latch data and reset bit counter when starting a frame
      if (state == IDLE && next_state == START) begin
        tx_buffer <= trans_data;
        counter   <= 3'd0;
      end
      // Step to next bit only on baud tick while sending data
      else if (state == DATA && baud_tick) begin
        counter <= counter + 3'd1;
      end
    end
  end

  // Next-state and outputs
  always @(*) begin
    next_state = state;
    txd        = 1'b1;                // idle line high by default
    tx_busy    = (state != IDLE);

    case (state)
      IDLE: begin
        txd     = 1'b1;
        if (tran_start) next_state = START;
      end

      START: begin                    // start bit
        txd = 1'b0;
        if (baud_tick) next_state = DATA;
      end

      DATA: begin                     // LSB-first
        txd = tx_buffer[counter];     // use [7-counter] for MSB-first
        if (baud_tick && (counter == 3'd7))
          next_state = STOP;
      end

      STOP: begin
        txd = 1'b1;
        if (baud_tick) next_state = IDLE;
      end
    endcase
  end

endmodule
