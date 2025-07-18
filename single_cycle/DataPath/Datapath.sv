
// `default_nettype none
import types_pkg::*;
module DataPath (
    input  logic        clk,
    input  logic        reset,

    // === Register Addresses ===
    input  reg_addr_t   rs1,
    input  reg_addr_t   rs2,
    input  reg_addr_t   rd,

    // === Immediate Inputs (Raw) ===
    input  imm_i_raw_t  imm_i_raw,
    input  imm_s_raw_t  imm_s_raw,
    input  imm_b_raw_t  imm_b_raw,
    input  imm_j_raw_t  imm_j_raw,

    // === Control Signals ===
    input  logic        PCSrc,
    input  resultsrc_e  ResultSrc,
    input  aluop_e      ALUControl,
    input  logic        ALUSrc,
    input  immsrc_e     ImmSrc,
    input  logic        RegWrite,

    // === Memory Interface ===
    input  word_t       ReadData,

    // === Outputs ===
    output word_t       PC,
    output logic        Zero,
    output word_t       ALUResult,
    output word_t       WriteData
);

    // ==================================================
    // Internal Wires
    // ==================================================
    word_t PCNext, ImmExt, PCTarget, PCPlus4, Result, SrcB, PCReg;
    word_t imm_mux_in    [4];
    word_t alu_mux_in    [2];
    word_t result_mux_in [3];
    word_t pc_mux_in     [2];

    // ==================================================
    // Sign-extension of raw immediates
    // ==================================================
    assign imm_mux_in[IMMSRC_I] = {{20{imm_i_raw[11]}}, imm_i_raw};
    assign imm_mux_in[IMMSRC_S] = {{20{imm_s_raw[11]}}, imm_s_raw};
    assign imm_mux_in[IMMSRC_B] = {{19{imm_b_raw[12]}}, imm_b_raw};
    assign imm_mux_in[IMMSRC_J] = {{11{imm_j_raw[20]}}, imm_j_raw};

    mux #(.SEL_WIDTH(2)) imm_mux (
        .in(imm_mux_in),
        .sel(ImmSrc),
        .out(ImmExt)
    );

    // ==================================================
    // Program Counter (PC) Logic
    // ==================================================

    // PC + 4
    adder pc_adder (
        .a(PCReg),
        .b(32'd4),
        .sum(PCPlus4)
    );

    // PC + Immediate (for branches/jumps)
    adder pc_target_adder (
        .a(PCReg),
        .b(ImmExt),
        .sum(PCTarget)
    );

    // Select next PC value
    assign pc_mux_in[0] = PCPlus4;
    assign pc_mux_in[1] = PCTarget;

    mux #(.SEL_WIDTH(1)) pc_mux (
        .in(pc_mux_in),
        .sel(PCSrc),
        .out(PCNext)
    );

    // PC Register
    pc PC_reg (
        .clk(clk),
        .reset(reset),
        .PCNext(PCNext),
        .pc(PCReg)
    );

    assign PC = PCReg;

    // ==================================================
    // Register File
    // ==================================================
    word_t RD1, RD2;

    regFile RegisterFile (
        .read_reg1   (rs1),
        .read_reg2   (rs2),
        .write_reg   (rd),
        .write_data  (Result),
        .writeEnable (RegWrite),
        .read_data1  (RD1),
        .read_data2  (RD2)
    );

    assign WriteData = RD2;

    // ==================================================
    // ALU and Operand MUX
    // ==================================================
    assign alu_mux_in[0] = RD2;
    assign alu_mux_in[1] = ImmExt;

    mux #(.SEL_WIDTH(1)) mux_b (
        .in (alu_mux_in),
        .sel(ALUSrc),
        .out(SrcB)
    );

    alu ALU (
        .a       (RD1),
        .b       (SrcB),
        .control (ALUControl),
        .result  (ALUResult),
        .zero    (Zero)
    );

    // ==================================================
    // Write-Back Result MUX
    // ==================================================
    assign result_mux_in[RESULT_ALU]  = ALUResult;
    assign result_mux_in[RESULT_MEM]  = ReadData;
    assign result_mux_in[RESULT_JUMP] = PCPlus4;

    mux #(.SEL_WIDTH(2)) result_mux (
        .in (result_mux_in),
        .sel(ResultSrc),
        .out(Result)
    );
endmodule
