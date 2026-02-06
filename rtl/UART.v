module uart(
input clk, //System clock
input rst, //reset
input [1:0]baud_sel, //select pin for baud rates
input tran_start, //transmitter start
input enable_baud, //enable signal for baud rate generator
input [7:0] trans_data, //data input of transmitter
input rxd, //serial input for reciever
output txd, //serial transmitted output
output tx_busy, //transmitter busy
output [7:0]o_data, //reciever output
output o_data_valid //reciever output valid
);


wire baud;
baud_sel_gen baud_generator(
.baud_sel(baud_sel),
.clk(clk),
.rst(rst),
.enable_baud(enable_baud),
.baud(baud));

transmitter tran1(
.clk(clk),
.rst(rst),
.trans_data(trans_data),
.tran_start(tran_start),
.baud(baud),
.txd(txd),
.tx_busy(tx_busy));

reciever rec1(
.clk(clk),
.rst(rst),
.rxd(rxd),
.baud_tick(baud),
.o_data(o_data),
.o_data_valid(o_data_valid));

endmodule
