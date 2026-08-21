module ram import soc_pkg::*; (
  input  logic        clk_i,
  input  logic [31:0] addr_i,
  input  logic [31:0] wdata_i,
  input  logic        we_i,
  output logic [31:0] rdata_o
);
  logic [31:0] mem [0:(RAM_SIZE_BYTES/4)-1];
  string mem_file;

  initial begin
    if ($value$plusargs("MEM_FILE=%s", mem_file)) begin
      $readmemh(mem_file, mem);
    end
  end

  // Exactly 14 bits for 16,384 words (64 KB total)
  logic [13:0] word_addr;
  assign word_addr = addr_i[15:2];

  always_ff @(posedge clk_i) begin
    if (we_i) mem[word_addr] <= wdata_i;
    rdata_o <= mem[word_addr];
  end
endmodule
