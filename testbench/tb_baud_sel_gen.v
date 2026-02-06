`timescale 1ns / 1ps

module tb_baud_sel_gen;

    reg clk;
    reg rst;
    reg enable_baud;
    reg [1:0] baud_sel;

    wire baud;


    parameter CLK_PERIOD = 2;

    baud_sel_gen dut (baud_sel,clk,rst,enable_baud,baud);


    initial clk = 0;
    always #(CLK_PERIOD / 2) clk = ~clk;



    initial begin
        $display("Starting testbench...");
        // 1. Initialize and Reset the DUT
        rst = 1; // Assert reset
        enable_baud = 0;
        baud_sel = 2'b00;
        #(CLK_PERIOD * 5); 
        
        rst = 0; // De-assert reset
        #(CLK_PERIOD * 2);


        enable_baud = 1;
        baud_sel = 2'b00;
        #600000;

        // Test 19200 Baud
        baud_sel = 2'b01;

        #600000;

        // Test 38400 Baud
        baud_sel = 2'b10;

        #600000;

        // Test 57600 Baud
        baud_sel = 2'b11;

        #600000;

        // 4. End the simulation

        $finish;
    end
    

    always @(posedge baud) begin
        $display(">>> Baud Tick Received at time %t ns <<<", $time);
    end

endmodule
