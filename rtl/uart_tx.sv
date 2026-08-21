module uart_tx (
  input  logic        clk_i,
  input  logic        rst_ni,
  input  logic [31:0] wdata_i,
  input  logic        we_i,
  output logic        tx_o
);
  logic [9:0] shift_reg;
  logic [3:0] bit_cnt;

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      tx_o      <= 1'b1;
      bit_cnt   <= 4'd0;
      shift_reg <= 10'h3FF;
    end else if (we_i && bit_cnt == 0) begin
      shift_reg <= {1'b1, wdata_i[7:0], 1'b0}; // Stop bit, Data, Start bit
      bit_cnt   <= 4'd10;
    end else if (bit_cnt > 0) begin
      tx_o      <= shift_reg[0];
      shift_reg <= {1'b1, shift_reg[9:1]};
      bit_cnt   <= bit_cnt - 1'b1;
    end
  end
endmodule
