`timescale 1ns/1ps

module tb_uart;
  reg        clk;
  reg        rst;
  reg  [1:0] baud_sel;
  reg        tran_start;
  reg        enable_baud;
  reg  [7:0] trans_data;
  reg        rxd;
  wire       txd;
  wire       tx_busy;
  wire [7:0] o_data;
  wire       o_data_valid;

  uart dut (
    .clk(clk),
    .rst(rst),
    .baud_sel(baud_sel),
    .tran_start(tran_start),
    .enable_baud(enable_baud),
    .trans_data(trans_data),
    .rxd(rxd),
    .txd(txd),
    .tx_busy(tx_busy),
    .o_data(o_data),
    .o_data_valid(o_data_valid)
  );


  always #10 clk = ~clk;
  always @(txd) rxd = txd;

 
  initial begin
    // Init
    clk = 0;
    rst = 1;
    baud_sel = 2'b00;
    tran_start = 0;
    enable_baud = 1;
    trans_data = 8'h00;
    rxd = 1;

    #100;
    rst = 0;

    // Small delay after reset
    #200;

    trans_data = 8'hA5;
    $display("[%0t] Sending 0x%0h", $time, trans_data);
    tran_start = 1;
    #20 tran_start = 0;

  
    wait (o_data_valid == 1);
    $display("[%0t] Received 0x%0h", $time, o_data);
    if (o_data !== 8'hA5) $display("ERROR: expected 0xA5!");

    #2000;

    trans_data = 8'h3C;
    $display("[%0t] Sending 0x%0h", $time, trans_data);
    tran_start = 1;
    #20 tran_start = 0;

    wait (o_data_valid == 1);
    $display("[%0t] Received 0x%0h", $time, o_data);
    if (o_data !== 8'h3C) $display("ERROR: expected 0x3C!");

    #2000;

    $display("Test finished.");
    $finish;
  end

endmodule

