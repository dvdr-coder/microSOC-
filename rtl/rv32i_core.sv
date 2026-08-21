module rv32i_core (
  input  logic        clk_i,
  input  logic        rst_ni,
  output logic [31:0] mem_addr_o,
  output logic [31:0] mem_wdata_o,
  input  logic [31:0] mem_rdata_i,
  output logic        mem_we_o,
  output logic        mem_req_o
);
  logic [31:0] pc, next_pc;
  logic [31:0] rf [0:31];
  logic [31:0] instr;

  assign mem_addr_o = (mem_req_o && mem_we_o) ? alu_res : pc;
  assign instr      = mem_rdata_i;

  // Decoding
  logic [6:0]  opcode; assign opcode = instr[6:0];
  logic [4:0]  rd;     assign rd     = instr[11:7];
  logic [4:0]  rs1;    assign rs1    = instr[19:15];
  logic [4:0]  rs2;    assign rs2    = instr[24:20];
  logic [2:0]  funct3; assign funct3 = instr[14:12];

  logic [31:0] imm_i, imm_s, imm_b, imm_u, imm_j;
  assign imm_i = {{20{instr[31]}}, instr[31:20]};
  assign imm_s = {{20{instr[31]}}, instr[31:25], instr[11:7]};
  assign imm_b = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
  assign imm_u = {instr[31:12], 12'b0};
  assign imm_j = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};

  logic [31:0] src1, src2, alu_res;
  assign src1 = (rs1 == 0) ? 0 : rf[rs1];
  assign src2 = (rs2 == 0) ? 0 : rf[rs2];

  // Execution & Next PC
  always_comb begin
    alu_res   = 32'b0;
    next_pc   = pc + 4;
    mem_we_o  = 1'b0;
    mem_req_o = 1'b1;

    case (opcode)
      7'b0110111: alu_res = imm_u;                          // LUI
      7'b0010111: alu_res = pc + imm_u;                     // AUIPC
      7'b1101111: begin alu_res = pc + 4; next_pc = pc + imm_j; end // JAL
      7'b1100111: begin alu_res = pc + 4; next_pc = (src1 + imm_i) & ~32'h1; end // JALR
      7'b1100011: begin                                    // Branches
        case (funct3)
          3'b000: if (src1 == src2) next_pc = pc + imm_b;  // BEQ
          3'b001: if (src1 != src2) next_pc = pc + imm_b;  // BNE
          default: ;
        endcase
      end
      7'b0000011: alu_res = src1 + imm_i;                  // LW
      7'b0100011: begin                                    // SW
        alu_res  = src1 + imm_s;
        mem_we_o = 1'b1;
      end
      7'b0010011: begin                                    // OP-IMM
        if (funct3 == 3'b000) alu_res = src1 + imm_i;       // ADDI
      end
      7'b0110011: begin                                    // OP
        if (funct3 == 3'b000) alu_res = src1 + src2;        // ADD
      end
      default: ;
    endcase
  end

  assign mem_wdata_o = src2;

  // Single-cycle sequential state update
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      pc <= 32'h0;
    end else begin
      pc <= next_pc;
      if (rd != 0 && !mem_we_o && (opcode == 7'b0110111 || opcode == 7'b0010111 || 
          opcode == 7'b1101111 || opcode == 7'b1100111 || opcode == 7'b0010011 || 
          opcode == 7'b0110011 || opcode == 7'b0000011)) begin
        rf[rd] <= (opcode == 7'b0000011) ? mem_rdata_i : alu_res;
      end
    end
  end
endmodule
