module soc_top import soc_pkg::*; (
  input  logic        clk_i,
  input  logic        rst_ni,
  output logic [31:0] gpio_o,
  output logic        uart_tx_o,
  output logic        sim_finish_o
);
  logic [31:0] mem_addr, mem_wdata, mem_rdata;
  logic        mem_we, mem_req;

  logic ram_we, gpio_we, uart_we, finish_we;
  logic [31:0] ram_rdata;

  // Address Decoding
  assign ram_we    = mem_we && (mem_addr < RAM_BASE + RAM_SIZE_BYTES);
  assign gpio_we   = mem_we && (mem_addr == GPIO_BASE);
  assign uart_we   = mem_we && (mem_addr == UART_BASE);
  assign finish_we = mem_we && (mem_addr == FINISH_BASE);

  assign sim_finish_o = finish_we && (mem_wdata == 32'h1);
  assign mem_rdata    = ram_rdata;

  rv32i_core core (
    .clk_i(clk_i), .rst_ni(rst_ni),
    .mem_addr_o(mem_addr), .mem_wdata_o(mem_wdata),
    .mem_rdata_i(mem_rdata), .mem_we_o(mem_we), .mem_req_o(mem_req)
  );

  ram u_ram (
    .clk_i(clk_i), .addr_i(mem_addr),
    .wdata_i(mem_wdata), .we_i(ram_we), .rdata_o(ram_rdata)
  );

  gpio u_gpio (
    .clk_i(clk_i), .rst_ni(rst_ni),
    .wdata_i(mem_wdata), .we_i(gpio_we), .gpio_o(gpio_o)
  );

  uart_tx u_uart (
    .clk_i(clk_i), .rst_ni(rst_ni),
    .wdata_i(mem_wdata), .we_i(uart_we), .tx_o(uart_tx_o)
  );
endmodule
