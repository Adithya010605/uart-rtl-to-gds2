

`timescale 1ns / 1ps

module tb_uart_rx;


    localparam CLK_FREQ      = 100_000_000; 
    localparam BAUD_RATE     = 9600;        
    localparam DATA_BITS     = 8;

    localparam CLK_PERIOD_NS = 1_000_000_000 / CLK_FREQ;
    localparam BAUD_PERIOD_NS = 1_000_000_000 / BAUD_RATE;
    localparam CLKS_PER_BAUD = CLK_FREQ / BAUD_RATE;

    reg                      i_clk;
    reg                      i_rst;
    reg                      i_rxd;
    reg                      i_baud_tick;
    wire [7:0]     o_data;
    wire                     o_data_valid;

    reciever dut (
        .clk(i_clk),
        .rst(i_rst),
        .rxd(i_rxd),
        .baud_tick(i_baud_tick),
        .o_data(o_data),
        .o_data_valid(o_data_valid)
    );

    always #((CLK_PERIOD_NS / 2)) i_clk = ~i_clk;

    always begin
        i_baud_tick = 1'b0;

        #(BAUD_PERIOD_NS / 2); 
        i_baud_tick = 1'b1;
        #(CLK_PERIOD_NS);
        i_baud_tick = 1'b0;

        #(BAUD_PERIOD_NS - (BAUD_PERIOD_NS / 2) - CLK_PERIOD_NS); 
    end

    initial begin

        i_clk = 0;
        i_rst = 1;
        i_rxd = 1; 
        #100;
        i_rst = 0;
        #100;

        send_byte(8'hA5);
        send_byte(8'h5A);

        send_byte(8'hFF);

        send_byte(8'h00);
        i_rxd = 1'b0;
        #(BAUD_PERIOD_NS);
        repeat (8) begin
            i_rxd = $urandom_range(0,1);
            #(BAUD_PERIOD_NS);
        end
        i_rxd = 1'b0;
        #(BAUD_PERIOD_NS);
        i_rxd = 1'b1;
        #(BAUD_PERIOD_NS * 2); 
    end

task send_byte (input [7:0] data_in);
    integer i;
    begin

        i_rxd = 1'b0;
        #(BAUD_PERIOD_NS);


        for (i = 0; i < 8; i = i + 1) begin 
            i_rxd = data_in[i];
            #(BAUD_PERIOD_NS);
        end

        i_rxd = 1'b1;
        #(BAUD_PERIOD_NS);
        
        #(BAUD_PERIOD_NS * 2);
    end
endtask


endmodule
