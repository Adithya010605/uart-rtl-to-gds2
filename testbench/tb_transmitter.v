`timescale 1ns/1ps

module tb_transmitter;

  reg clk;
  reg rst;
  reg [7:0] trans_data;
  reg tran_start;
  reg baud;         


  wire txd;
  wire tx_busy;

  // Clock period (100 MHz = 10 ns)
  parameter CLK_PERIOD = 10;


  transmitter dut (
    .clk(clk),
    .rst(rst),
    .trans_data(trans_data),
    .tran_start(tran_start),
    .baud(baud),
    .txd(txd),
    .tx_busy(tx_busy)
  );


  initial clk = 0;
  always #(CLK_PERIOD/2) clk = ~clk;

  initial baud = 0;
  always #160 baud = ~baud;


  initial begin


    rst = 1;
    tran_start = 0;
    trans_data = 8'h00;
    #(10*CLK_PERIOD);
    rst = 0;

    #(20*CLK_PERIOD);

    @(negedge clk);
    trans_data = 8'hA5;
    tran_start = 1;
    @(negedge clk);
    tran_start = 0;   


    #(10*320*CLK_PERIOD);


    @(negedge clk);
    trans_data = 8'h3C;
    tran_start = 1;
    @(negedge clk);
    tran_start = 0;

    #(10*320*CLK_PERIOD);

  end

endmodule

