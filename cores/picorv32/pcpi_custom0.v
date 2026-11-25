module pcpi_custom0 (
  input clk, resetn,
  input pcpi_valid,
  input [31:0] pcpi_insn, pcpi_rs1, pcpi_rs2,
  output reg pcpi_wr,
  output reg [31:0] pcpi_rd,
  output reg pcpi_wait,
  output reg pcpi_ready
);
  wire match = pcpi_valid &&
               pcpi_insn[6:0]   == 7'b0101011 &&
               pcpi_insn[14:12] == 3'b000 &&
               pcpi_insn[31:25] == 7'b0000000;
  always @(posedge clk) begin
    pcpi_wr <= 0; pcpi_ready <= 0; pcpi_wait <= 0;
    if (!resetn) begin
      pcpi_rd <= 0;
    end else if (match && !pcpi_ready) begin
      pcpi_wr    <= 1;
      pcpi_ready <= 1;
      pcpi_rd    <= pcpi_rs1 & ~pcpi_rs2;
    end
  end
endmodule
