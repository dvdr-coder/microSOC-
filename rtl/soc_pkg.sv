package soc_pkg;
  parameter bit [31:0] RAM_BASE     = 32'h0000_0000;
  parameter bit [31:0] GPIO_BASE    = 32'h1000_0000;
  parameter bit [31:0] UART_BASE    = 32'h2000_0000;
  parameter bit [31:0] FINISH_BASE  = 32'h3000_0000;
  parameter int        RAM_SIZE_BYTES = 64 * 1024;
endpackage
