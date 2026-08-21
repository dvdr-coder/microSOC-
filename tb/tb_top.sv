import uvm_lite_pkg::*;

module tb_top (
  input logic clk,
  input logic rst_n
);
  soc_if vif(clk, rst_n);

  soc_top dut (
    .clk_i       (vif.clk),
    .rst_ni      (vif.rst_n),
    .gpio_o      (vif.gpio),
    .uart_tx_o   (vif.uart_tx),
    .sim_finish_o(vif.sim_finish)
  );

  uvm_lite_env env;

  initial begin
    env = new(vif);
    env.run();
  end

  always @(posedge clk) begin
    if (vif.sim_finish) begin
      $display("\n[TB] SIMULATION PASSED (GPIO: 0x%08h)", vif.gpio);
      $finish;
    end
  end
endmodule
