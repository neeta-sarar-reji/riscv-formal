module rvfi_wrapper (
	input         clock,
	input         reset,
	`RVFI_OUTPUTS
);
	(* keep *) wire trap;

	(* keep *) `rvformal_rand_reg mem_ready_rand;
	(* keep *) wire mem_ready;
	(* keep *) `rvformal_rand_reg [31:0] mem_rdata;

	(* keep *) wire        mem_valid;
	(* keep *) wire        mem_instr;
	(* keep *) wire [31:0] mem_addr;
	(* keep *) wire [31:0] mem_wdata;
	(* keep *) wire [3:0]  mem_wstrb;

	(* keep *) wire        pcpi_valid;
	(* keep *) wire [31:0] pcpi_insn, pcpi_rs1, pcpi_rs2;
	(* keep *) wire        pcpi_wr, pcpi_wait, pcpi_ready;
	(* keep *) wire [31:0] pcpi_rd;

	picorv32 #(
		.COMPRESSED_ISA(1),
		.ENABLE_PCPI(1),
		.ENABLE_FAST_MUL(1),
		.ENABLE_DIV(1),
		.BARREL_SHIFTER(1)
	) uut (
		.clk       (clock    ),
		.resetn    (!reset   ),
		.trap      (trap     ),

		.mem_valid (mem_valid),
		.mem_instr (mem_instr),
		.mem_ready (mem_ready),
		.mem_addr  (mem_addr ),
		.mem_wdata (mem_wdata),
		.mem_wstrb (mem_wstrb),
		.mem_rdata (mem_rdata),

		.pcpi_valid(pcpi_valid),
		.pcpi_insn (pcpi_insn ),
		.pcpi_rs1  (pcpi_rs1  ),
		.pcpi_rs2  (pcpi_rs2  ),
		.pcpi_wr   (pcpi_wr   ),
		.pcpi_rd   (pcpi_rd   ),
		.pcpi_wait (pcpi_wait ),
		.pcpi_ready(pcpi_ready),

		`RVFI_CONN
	);

	pcpi_custom0 custom0_i (
		.clk       (clock     ),
		.resetn    (!reset    ),
		.pcpi_valid(pcpi_valid),
		.pcpi_insn (pcpi_insn ),
		.pcpi_rs1  (pcpi_rs1  ),
		.pcpi_rs2  (pcpi_rs2  ),
		.pcpi_wr   (pcpi_wr   ),
		.pcpi_rd   (pcpi_rd   ),
		.pcpi_wait (pcpi_wait ),
		.pcpi_ready(pcpi_ready)
	);

`ifdef PICORV32_FAIRNESS
	reg [2:0] mem_wait = 0;
	always @(posedge clock)
		mem_wait <= {mem_wait, mem_valid && !mem_ready};
	assign mem_ready = mem_ready_rand || (&mem_wait[1:0]);
`else
	assign mem_ready = mem_ready_rand;
`endif

`ifdef PICORV32_CSR_RESTRICT
	always @* begin
		if (rvfi_valid && rvfi_insn[6:0] == 7'b1110011) begin
			if (rvfi_insn[14:12] == 3'b010) begin
				assume (rvfi_insn[31:20] == 12'hC00 || rvfi_insn[31:20] == 12'hC01 || rvfi_insn[31:20] == 12'hC02 ||
						rvfi_insn[31:20] == 12'hC80 || rvfi_insn[31:20] == 12'hC81 || rvfi_insn[31:20] == 12'hC82);
				assume (rvfi_insn[19:15] == 0);
			end
			assume (rvfi_insn[14:12] != 3'b001);
			assume (rvfi_insn[14:12] != 3'b011);
			assume (rvfi_insn[14:12] != 3'b101);
			assume (rvfi_insn[14:12] != 3'b110);
			assume (rvfi_insn[14:12] != 3'b111);
		end
	end
`endif
endmodule

