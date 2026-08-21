module gpio (
  input  logic        clk_i,
  input  logic        rst_ni,
  input  logic [31:0] wdata_i,
  input  logic        we_i,
  output logic [31:0] gpio_o
);
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) gpio_o <= 32'h0;
    else if (we_i) gpio_o <= wdata_i;
  end
endmodule
