module rvfi_insn_custom0 (
  input                                 rvfi_valid,
  input [`RISCV_FORMAL_ILEN   - 1 : 0]  rvfi_insn,
  input [`RISCV_FORMAL_XLEN   - 1 : 0]  rvfi_pc_rdata,
  input [`RISCV_FORMAL_XLEN   - 1 : 0]  rvfi_rs1_rdata,
  input [`RISCV_FORMAL_XLEN   - 1 : 0]  rvfi_rs2_rdata,
  input [`RISCV_FORMAL_XLEN   - 1 : 0]  rvfi_mem_rdata,
  input [`RISCV_FORMAL_XLEN   - 1 : 0]  rvfi_csr_misa_rdata,
  output                                spec_valid,
  output                                spec_trap,
  output [4 : 0]                        spec_rs1_addr,
  output [4 : 0]                        spec_rs2_addr,
  output [4 : 0]                        spec_rd_addr,
  output [`RISCV_FORMAL_XLEN   - 1 : 0] spec_rd_wdata,
  output [`RISCV_FORMAL_XLEN   - 1 : 0] spec_pc_wdata,
  output [`RISCV_FORMAL_XLEN   - 1 : 0] spec_mem_addr,
  output [`RISCV_FORMAL_XLEN/8 - 1 : 0] spec_mem_rmask,
  output [`RISCV_FORMAL_XLEN/8 - 1 : 0] spec_mem_wmask,
  output [`RISCV_FORMAL_XLEN   - 1 : 0] spec_mem_wdata,
  output [`RISCV_FORMAL_XLEN   - 1 : 0] spec_csr_misa_rmask
);
  wire [6:0] opcode = rvfi_insn[6:0];
  wire [2:0] funct3 = rvfi_insn[14:12];
  wire [6:0] funct7 = rvfi_insn[31:25];

  assign spec_valid    = rvfi_valid && opcode == 7'b0101011 && funct3 == 3'b000 && funct7 == 7'b0000000;
  assign spec_trap     = 1'b0;
  assign spec_rs1_addr = rvfi_insn[19:15];
  assign spec_rs2_addr = rvfi_insn[24:20];
  assign spec_rd_addr  = rvfi_insn[11:7];
  assign spec_rd_wdata = spec_rd_addr ? (rvfi_rs1_rdata & ~rvfi_rs2_rdata) : 0;
  assign spec_pc_wdata = rvfi_pc_rdata + 4;
  assign spec_mem_addr = 0;
  assign spec_mem_rmask = 0;
  assign spec_mem_wmask = 0;
  assign spec_mem_wdata = 0;
  assign spec_csr_misa_rmask = 0;
endmodule
