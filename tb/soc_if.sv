interface soc_if (input logic clk, input logic rst_n);
  logic [31:0] gpio;
  logic        uart_tx;
  logic        sim_finish;
endinterface
