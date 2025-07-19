
// `default_nettype none
import types_pkg::*;
module DataPath (
    input  logic        clk,
    input  logic        reset,

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
    decoded_instr_t di  ;
    control_signals_t cs;

    word_t InstrD       ;
    word_t PCD          ;
    reg_addr_t Rs1D     ;
    reg_addr_t Rs2D     ;
    reg_addr_t RdD      ;
    word_t RD1D         ;
    word_t RD2D         ;
    word_t ImmExtD      ;
    word_t PCPlus4D     ;

    logic RegWriteD         ;
    logic ALUSrcD           ;
    logic [1:0] ImmSrcD     ;
    logic [1:0] ResultSrcD  ;
    logic MemWriteD         ;


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
    logic ZeroE             ;

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
    reg_addr_t RdW          ;

    logic RegWriteW         ;
    logic [1:0] ResultSrcW  ;




    // ==================================================
    // Program Counter (PC) Logic + instruction fetch in Stage 1
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

    instr_mem InstructionMemory (
        .clk(clk),
        .address(PC),
        .instruction(InstrF)
    );


    // ==================================================
    // Stage 2: Instruction Decode and control signals
    // ==================================================

    decoder decoder_instance (
        .Instr(InstrD),
        .decoded_instr(di)
    );

    Controller Controller_instance (
        .Zero(ZeroE),

        .funct3(di.funct3),
        .funct7(di.funct7),
        .op(di.op),
        
        .control_signals(cs),
        .ALUControl(ALUControl)
    );

    assign Rs1D = di.rs1;
    assign Rs2D = di.rs2;
    assign RdD  = di.rd;

    assign RegWriteD = cs.RegWrite;
    assign ResultSrcD = cs.ResultSrc;
    assign MemWriteD = cs.MemWrite;
    assign ALUSrcD = cs.ALUSrc;
    assign ImmSrcD = cs.ImmSrc;

    // ==================================================
    // Sign-extension of raw immediates in Stage 2
    // ==================================================

    assign imm_mux_in[IMMSRC_I] = {{20{di.imm_i_raw[11]}}, di.imm_i_raw};
    assign imm_mux_in[IMMSRC_S] = {{20{di.imm_s_raw[11]}}, di.imm_s_raw};
    assign imm_mux_in[IMMSRC_B] = {{19{di.imm_b_raw[12]}}, di.imm_b_raw};
    assign imm_mux_in[IMMSRC_J] = {{11{di.imm_j_raw[20]}}, di.imm_j_raw};

    mux #(.SEL_WIDTH(2)) imm_mux (
        .in(imm_mux_in),
        .sel(ImmSrcD),
        .out(ImmExtD)
    );



    regFile RegisterFile (
        .clk         (clk),
        .read_reg1   (Rs1D),
        .read_reg2   (Rs2D),
        .write_reg   (RdW),
        .write_data  (ResultW),
        .writeEnable (RegWrite),
        .read_data1  (RD1D),
        .read_data2  (RD2D)
    );


    // here a mux for the forwarding
    assign WriteData = RD2E;

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
