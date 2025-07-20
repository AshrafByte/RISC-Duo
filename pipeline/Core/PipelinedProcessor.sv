
// `default_nettype none
import types_pkg::*;
module DataPath (
    input  logic        clk,
    input  logic        reset,
    input  logic StallF,
    input  logic StallD,
    input  logic FlushD,
    output Rs1D,
    output Rs2D,
    input  logic FlushE,
    output RdE,
    output Rs2E,
    output Rs1E,
    output PCSrcE,
    input  logic [1:0] ForwardAE,
    input  logic [1:0]ForwardEE,
    output logic ResultSrcE0,
    output RdM,
    output RegWriteM,
    output RegWriteW
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
    aluop_e  ALUControlD;


    logic RegWriteD         ;
    logic ALUSrcD           ;
    logic [1:0] ImmSrcD     ;
    logic [1:0] ResultSrcD  ;
    logic MemWriteD         ;
    logic JumpD             ; //Was missing
    logic BranchD           ; //was missing


    // Stage 3: Execute
    logic RegWriteE         ;
    logic [1:0] ResultSrcE  ;
    logic MemWriteE         ;
    logic ALUSrcE           ;
    logic JumpE             ;
    logic BranchE           ;
    logic [1:0] ALUOpE      ;
    logic PCSrcE            ;
    logic ZeroE             ;
    aluop_e  ALUControlE    ;


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

    word_t SrcAE_mux_in [3:0]  ;      //SrcAE Mux (output is SrcAE, inputs are RD1E, ResultW (WD), AluResultM and sel is ForwardAE)
    word_t WriteDataE_mux_in [3:0] ;     //WriteDataE mux(output is WriteDataE, inputs are RD2E, ResultW, AluResultM, and sel is ForwardEE)
  

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

    //===================================================
    //  Internal wires to handle hazard signals
    //==================================================

    logic StallD_bar;           //enable signal for stage 1
    assign StallD_bar = ~StallD;

    logic stage_enable = 1;    //enable signal for registers that are always enabled (stage2, stage3, and stage4 pipos)
    logic stage_rst = 0;       //reset signal for registers that will never reset (stage3, and stage4 pipos)

    logic StallF_bar;           //enable signal for PC register
    assign StallF_bar = ~StallF;

    assign ResultSrcE0 = ResultSrcE[0];



    //===================================================
    //    Pipelinining
    //====================================================

    //Stage 1:
    pipo #(XLEN) stage1_PC (.clk(clk), .rst(FlushD), .enable(!StallD_bar), .in(PCF), .out(PCD)) ;
    pipo #(XLEN) stage1_PCPlus4(.clk(clk), .rst(FlushD), .enable(!StallD_bar), .in(PCPlus4F), .out(PCPlus4D));
    pipo #(XLEN) stage1_Instr(.clk(clk), .rst(FlushD), .enable(!StallD_bar), .in(InstrF), .out(InstrD));
    //pipo #(XLEN) stage1_PCNext(.clk(clk), .rst(reset), .enable(enable), .in(InstrF), .out()) //???

    //Stage 2:
    pipo #(XLEN) stage2_RD1 (.clk(clk), .rst(FlushE), .enable(stage_enable), .in(RD1D), .out(RD1E));
    pipo #(XLEN) stage2_RD1 (.clk(clk), .rst(FlushE), .enable(stage_enable), .in(RD2D), .out(RD2E));
    pipo #(XLEN) stage2_PC (.clk(clk), .rst(FlushE), .enable(stage_enable), .in(PCD), .out(PCE));
    pipo #(REG_ADDR_WIDTH) stage2_Rs1 (.clk(clk), .rst(FlushE), .enable(stage_enable), .in(Rs1D), .out(Rs1E));
    pipo #(REG_ADDR_WIDTH) stage2_Rs2 (.clk(clk), .rst(FlushE), .enable(stage_enable), .in(Rs2D), .out(Rs2E));
    pipo #(REG_ADDR_WIDTH) stage2_Rd (.clk(clk), .rst(FlushE), .enable(stage_enable), .in(RdD), .out(RdE));
    pipo #(REG_ADDR_WIDTH) stage2_ImmExt (.clk(clk), .rst(FlushE), .enable(stage_enable), .in(ImmExtD), .out(ImmExtE));
    pipo #(XLEN) stage2_PCPlus4 (.clk(clk), .rst(FlushE), .enable(stage_enable), .in(PCPlus4D), .out(PCPlus4E));

    pipo #(1) stage2_RegWrite (.clk(clk), .rst(FlushE), .enable(stage_enable), .in(RegWriteD), .out(RegWriteE));
    pipo #(2) stage2_ResultSrc (.clk(clk), .rst(FlushE), .enable(stage_enable), .in(ResultSrcD), .out(ResultSrcE));
    pipo #(1) stage2_MemWrite (.clk(clk), .rst(FlushE), .enable(stage_enable), .in(MemWriteD), .out(MemWriteE));
    //pipo #(1) stage2_Jump (.clk(clk), .rst(FlushE), .enable(stage_enable), .in(JumpD), .out(JumpE));
    pipo #(1) stage2_Branch (.clk(clk), .rst(FlushE), .enable(stage_enable), .in(BranchD), .out(BranchE));
    pipo #(4) stage2_ALUControl (.clk(clk), .rst(FlushE), .enable(stage_enable), .in(ALUControlD), .out(ALUControlE));
    pipo #(1) stage2_ALUSrc (.clk(clk), .rst(FlushE), .enable(stage_enable), .in(ALUSrcD), .out(ALUSrcE));

    //Stage3:
    pipo #(1) stage3_RegWrite (.clk(clk), .rst(stage_rst), .enable(stage_enable), in(RegWriteE), out(RegWriteM));
    pipo #(2) stage3_ResultSrc (.clk(clk), .rst(stage_rst), .enable(stage_enable), in(ResultSrcE), out(ResultSrcM));
    pipo #(1) stage3_MemWrite (.clk(clk), .rst(stage_rst), .enable(stage_enable), in(MemWriteE), out(MemWriteM));
    pipo #(XLEN) stage3_ALUResult (.clk(clk), .rst(stage_rst), .enable(stage_enable), in(ALUResultE), out(ALUResultM));
    pipo #(XLEN) stage3_WriteData (.clk(clk), .rst(stage_rst), .enable(stage_enable), in(WriteDataE), out(WriteDataM));
    pipo #(REG_ADDR_WIDTH) stage3_Rd (.clk(clk), .rst(stage_rst), .enable(stage_enable), .in(RdE), out(RdM) );
    pipo #(XLEN) stage3_PCPlus4 (.clk(clk), .rst(stage_rst), .enable(stage_enable), .in(PCPlus4E), out(PCPlus4M));

    //stage4:

    pipo #(1) stage4_RegWrite (.clk(clk), .rst(stage_rst), .enable(stage_enable), .in(RegWriteM), .out(RegWriteW));
    pipo #(2) stage4_ResultSrc (.clk(clk), .rst(stage_rst), .enable(stage_enable), .in(ResultSrcM), .out(ResultSrc));
    pipo #(XLEN) stage4_ALUResult (.clk(clk), .rst(stage_rst), .enable(stage_enable), .in(ALUResultM), .out(ALUResultW));
    pipo #(REG_ADDR_WIDTH) stage4_Rd (.clk(clk), .rst(stage_rst), .enable(stage_enable), .in(RdM), .out(RdW));
    pipo #(XLEN) stage4_PCPlus4 (.clk(clk), .rst(stage_rst), .enable(stage_enable), .in(PCPlus4M), .out(PCPlus4W));

    // ==================================================
    // Program Counter (PC) Logic + instruction fetch in Stage 1
    // ==================================================

    // PC + 4
    adder pc_adder (
        .a(PCReg),
        .b(32'd1),
        .sum(PCPlus4F)
    );

    // Select next PC value
    assign pc_mux_in[0] = PCPlus4F;
    assign pc_mux_in[1] = PCTargetE;

    mux #(.SEL_WIDTH(1)) pc_mux (
        .in(pc_mux_in),
        .sel(PCSrcE),
        .out(PCNextF)
    );


    // PC Register
    pc PC_reg (
        .clk(clk),
        .reset(reset),
        .enable(StallF_bar),
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

    // ==================================================
    // Execute Stage 
    // ==================================================
    assign alu_mux_in[0] = WriteDataE;
    assign alu_mux_in[1] = ImmExtE;

    mux #(.SEL_WIDTH(1)) mux_b (
        .in (alu_mux_in),
        .sel(ALUSrcE),
        .out(SrcBE)
    );

    //3:1 mux outputs SrcAE for ALU SrcAE
    assign SrcAE_mux_in[0] = RD1E;
    assign SrcAE_mux_in[1] = ResultW;
    assign SrcAE_mux_in[2] = AluResultM;

    mux #(.SEL_WIDTH(2)) SrcAE_mix(
        .in(SrcAE_mux_in),
        .sel(ForwardAE),
        .out(SrcAE)
    );

    //3:1 mux outputs WriteDataE for ALU SrcBE
    assign WriteDataE_mux_in[0] = RD2E;
    assign WriteDataE_mux_in[1] = ResultW;
    assign WriteDataE_mux_in[2] = AluResultM;

    mux #(.SEL_WIDTH(2)) SrcAE_mix(
        .in(WriteDataE_mux_in),
        .sel(ForwardEE),
        .out(WriteDataE)
    );


    alu ALU (
        .a       (SrcAE),
        .b       (SrcBE),
        .control (ALUControlE),
        .result  (ALUResultE),
        .zero    (ZeroE)
    );
    // PC + Immediate (for branches/jumps)
    adder pc_target_adder (
        .a(PCE),
        .b(ImmExtE),
        .sum(PCTargetE)
    );
    // here a mux for the forwarding
    //assign WriteDataE = RD2E;
    //

    // ==================================================
    // Write-Back Result MUX
    // ==================================================
    assign result_mux_in[RESULT_ALU]  = ALUResultM;
    assign result_mux_in[RESULT_MEM]  = ReadDataM;
    assign result_mux_in[RESULT_JUMP] = PCPlus4M;

    mux #(.SEL_WIDTH(2)) result_mux (
        .in (result_mux_in),
        .sel(ResultSrc),
        .out(Result)
    );
endmodule
