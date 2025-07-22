
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
    word_t result_mux_in [4];
    word_t pc_mux_in     [2];

    // ==================================================
    // Internal Wires for pipeline registers
    // ==================================================

    // Stage 1: Instruction Fetch
    word_t PCF      ;    
    word_t PCNextF  ; 
    word_t InstrF   ;
    word_t PCPlus4F ;

    // Stage 2: Instruction Decode
    word_t InstrD       ;
    word_t PCD          ;
    reg_addr_t Rs1D     ;
    reg_addr_t Rs2D     ;
    reg_addr_t RdD      ;
    word_t ImmExtD      ;
    word_t PCPlus4D     ;

    logic RegWriteD         ;
    logic [1:0] ALUOpD      ;
    logic ALUSrcD           ;
    logic [1:0] ImmSrcD     ;
    logic [1:0] ResultSrcD  ;
    logic MemWriteD         ;
    logic JumpD             ;
    logic BranchD           ;

    // Stage 3: Execute
    logic RegWriteE         ;
    logic [1:0] ResultSrcE  ;
    logic MemWriteE         ;
    logic ALUSrcE           ;
    logic JumpE             ;
    logic BranchE           ;
    logic [1:0] ALUOpE      ;
    logic ALUSrcE           ;
    logic PCSrcE            ;

    word_t RD1E             ;
    word_t RD2E             ;
    word_t PCE              ;
    word_t ImmExtE          ;
    reg_addr_t Rs1E         ;
    reg_addr_t Rs2E         ;
    reg_addr_t RdE          ;
    word_t PCPlus4E         ;
    word_t PCTargetE        ;
    word_t SrcAE            ;
    word_t SrcBE            ;
    word_t ALUResultE       ;
    word_t WriteDataE       ;

    // Stage 4: Memory Access
    word_t ALUResultM       ;
    word_t WriteDataM       ;
    reg_addr_t RdM          ;
    word_t PCPlus4M         ;
    word_t ReadDataM        ;

    logic RegWriteM         ;
    logic [1:0] ResultSrcM  ;
    logic MemWriteM         ;

    // Stage 5: Write Back
    word_t ALUResultW       ;
    word_t ReadDataW        ;
    word_t PCPlus4W         ;
    word_t ResultW          ;
    reg_addr_t ReadDataW    ;

    logic RegWriteW         ;
    logic [1:0] ResultSrcW  ;



    // ==================================================
    // Sign-extension of raw immediates in Stage 2
    // ==================================================
    assign imm_mux_in[IMMSRC_I] = {{20{imm_i_raw[11]}}, imm_i_raw};
    assign imm_mux_in[IMMSRC_S] = {{20{imm_s_raw[11]}}, imm_s_raw};
    assign imm_mux_in[IMMSRC_B] = {{19{imm_b_raw[12]}}, imm_b_raw};
    assign imm_mux_in[IMMSRC_J] = {{11{imm_j_raw[20]}}, imm_j_raw};

    mux #(.SEL_WIDTH(2)) imm_mux (
        .in(imm_mux_in),
        .sel(ImmSrcD),
        .out(ImmExtD)
    );

    // ==================================================
    // Program Counter (PC) Logic in Stage 1
    // ==================================================

    // PC + 4
    adder pc_adder (
        .a(PCReg),
        .b(32'd1),
        .sum(PCPlus4F)
    );

    // PC + Immediate (for branches/jumps)
    adder pc_target_adder (
        .a(PCReg),
        .b(ImmExt),
        .sum(PCTarget)
    );

    // Select next PC value
    assign pc_mux_in[0] = PCPlus4F;
    assign pc_mux_in[1] = PCTargetE;

    mux #(.SEL_WIDTH(1)) pc_mux (
        .in(pc_mux_in),
        .sel(PCSrcE),
        .out(PCNext)
    );

    // PC Register
    pc PC_reg (
        .clk(clk),
        .reset(reset),
        .PCNext(PCNextF),
        .pc(PCF)
    );

    assign PC = PCF;

    // ==================================================
    // Register File
    // ==================================================
    word_t RD1, RD2;

    regFile RegisterFile (
        .clk         (clk),
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
    assign alu_mux_in[0] = RD2E;
    assign alu_mux_in[1] = ImmExtE;

    mux #(.SEL_WIDTH(1)) mux_b (
        .in (alu_mux_in),
        .sel(ALUSrc),
        .out(SrcB)
    );

    alu ALU (
        .a       (RD1E),
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
