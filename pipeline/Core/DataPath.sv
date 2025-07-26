
// `default_nettype none
import types_pkg::*;
module DataPath (
    clk,
    reset,
    StallF,
    StallD,
    FlushD,
    Rs1D,
    Rs2D,
    FlushE,
    RdE,
    Rs2E,
    Rs1E,
    PCSrcE,
    ForwardAE,
    ForwardEE,
    ResultSrcE0,
    RdM,
    RegWriteM,
    RegWriteW,
    RdW
    // MemReadE
);
    input logic clk;
    input logic reset;
    input logic StallF;
    input logic StallD;
    input logic FlushD;
    input logic FlushE;
    input logic [1:0] ForwardAE;
    input logic [1:0] ForwardEE;
    output reg_addr_t Rs1D;
    output reg_addr_t Rs2D;
    output reg_addr_t RdE;
    output reg_addr_t Rs2E;
    output reg_addr_t Rs1E;
    output reg_addr_t RdM;
    output logic PCSrcE;
    output logic ResultSrcE0;
    output logic RegWriteM;
    output logic RegWriteW;
    output reg_addr_t RdW;
    // output logic MemReadE; // to add later

    // ==================================================
    // Internal Wires
    // ==================================================
    word_t imm_mux_in    [4];
    word_t alu_mux_in    [2];
    word_t result_mux_in [4];
    word_t pc_mux_in     [2];
    address_t PC;
    address_t address;

    // ==================================================
    // Internal Wires for pipeline registers
    // ==================================================

    fetch_stage_t f;        // Stage 1: Fetch
    decoded_instr_t di  ;   // Stage 2: Decode
    control_signals_t cs;   // Control signals for Stage 2
    decoding_stage_t d;      // Stage 2: Decode 
    execute_stage_t e;      // Stage 3: Execute
    memory_stage_t m;       // Stage 4: Memory Access
    write_back_stage_t w;   // Stage 5: Write Back 

    word_t SrcAE_mux_in [3:0]  ;      //SrcAE Mux (output is SrcAE, inputs are RD1E, ResultW (WD), AluResultM and sel is ForwardAE)
    word_t WriteDataE_mux_in [3:0] ;     //WriteDataE mux(output is WriteDataE, inputs are RD2E, ResultW, AluResultM, and sel is ForwardEE)
  
    //===================================================
    //  Internal wires to handle hazard signals
    //==================================================

    logic StallD_bar;           //enable signal for stage 1
    assign StallD_bar = ~StallD;

    logic stage_enable = 1;    //enable signal for registers that are always enabled (stage2, stage3, and stage4 pipos)
    logic stage_rst = 0;       //reset signal for registers that will never reset (stage3, and stage4 pipos)

    logic StallF_bar;           //enable signal for PC register
    assign StallF_bar = ~StallF;

    assign ResultSrcE0 = e.ResultSrcE[0];

    assign RdW = w.RdW;


    //===================================================
    //    Pipelinining
    //====================================================

    //Stage 1:
    pipo #(XLEN) stage1_PC (.clk(clk), .rst(0), .enable(StallD_bar), .in(f.PCF), .out(d.PCD)) ;//FlushD
    pipo #(XLEN) stage1_PCPlus4(.clk(clk), .rst(0), .enable(StallD_bar), .in(f.PCPlus4F), .out(d.PCPlus4D));
    pipo #(XLEN) stage1_Instr(.clk(clk), .rst(0), .enable(StallD_bar), .in(f.InstrF), .out(d.InstrD));
    //pipo #(XLEN) stage1_PCNext(.clk(clk), .rst(reset), .enable(enable), .in(f.InstrF), .out()) //???

    //Stage 2:
    pipo #(XLEN) stage2_RD1 (.clk(clk), .rst(FlushE), .enable(stage_enable), .in(d.RD1D), .out(e.RD1E));
    pipo #(XLEN) stage2_RD2 (.clk(clk), .rst(FlushE), .enable(stage_enable), .in(d.RD2D), .out(e.RD2E));
    pipo #(XLEN) stage2_PC (.clk(clk), .rst(FlushE), .enable(stage_enable), .in(d.PCD), .out(e.PCE));
    pipo #(REG_ADDR_WIDTH) stage2_Rs1 (.clk(clk), .rst(FlushE), .enable(stage_enable), .in(Rs1D), .out(Rs1E));
    pipo #(REG_ADDR_WIDTH) stage2_Rs2 (.clk(clk), .rst(FlushE), .enable(stage_enable), .in(Rs2D), .out(Rs2E));
    pipo #(REG_ADDR_WIDTH) stage2_Rd (.clk(clk), .rst(FlushE), .enable(stage_enable), .in(d.RdD), .out(RdE));
    pipo #(XLEN) stage2_ImmExt (.clk(clk), .rst(FlushE), .enable(stage_enable), .in(d.ImmExtD), .out(e.ImmExtE));
    pipo #(XLEN) stage2_PCPlus4 (.clk(clk), .rst(FlushE), .enable(stage_enable), .in(d.PCPlus4D), .out(e.PCPlus4E));

    pipo #(1) stage2_RegWrite (.clk(clk), .rst(FlushE), .enable(stage_enable), .in(d.RegWriteD), .out(e.RegWriteE));
    pipo #(2) stage2_ResultSrc (.clk(clk), .rst(FlushE), .enable(stage_enable), .in(d.ResultSrcD), .out(e.ResultSrcE));
    pipo #(1) stage2_MemWrite (.clk(clk), .rst(FlushE), .enable(stage_enable), .in(d.MemWriteD), .out(e.MemWriteE));
    //pipo #(1) stage2_Jump (.clk(clk), .rst(FlushE), .enable(stage_enable), .in(d.JumpD), .out(e.JumpE));
    //pipo #(1) stage2_Branch (.clk(clk), .rst(FlushE), .enable(stage_enable), .in(d.BranchD), .out(e.BranchE));
    aluop_t ALUControl_raw;
    assign e.ALUControlE = aluop_e'(ALUControl_raw);
    pipo #(4) stage2_ALUControl (.clk(clk), .rst(FlushE), .enable(stage_enable), .in(d.ALUControlD), .out(ALUControl_raw));
    pipo #(1) stage2_ALUSrc (.clk(clk), .rst(FlushE), .enable(stage_enable), .in(d.ALUSrcD), .out(e.ALUSrcE));

    //Stage3:
    pipo #(1) stage3_RegWrite (.clk(clk), .rst(stage_rst), .enable(stage_enable), .in(e.RegWriteE), .out(RegWriteM));
    pipo #(2) stage3_ResultSrc (.clk(clk), .rst(stage_rst), .enable(stage_enable), .in(e.ResultSrcE), .out(m.ResultSrcM));
    pipo #(1) stage3_MemWrite (.clk(clk), .rst(stage_rst), .enable(stage_enable), .in(e.MemWriteE), .out(m.MemWriteM));
    pipo #(XLEN) stage3_ALUResult (.clk(clk), .rst(stage_rst), .enable(stage_enable), .in(e.ALUResultE), .out(m.ALUResultM));
    pipo #(XLEN) stage3_WriteData (.clk(clk), .rst(stage_rst), .enable(stage_enable), .in(e.WriteDataE), .out(m.WriteDataM));
    pipo #(REG_ADDR_WIDTH) stage3_Rd (.clk(clk), .rst(stage_rst), .enable(stage_enable), .in(RdE), .out(RdM) );
    pipo #(XLEN) stage3_PCPlus4 (.clk(clk), .rst(stage_rst), .enable(stage_enable), .in(e.PCPlus4E), .out(m.PCPlus4M));

    //stage4:

    pipo #(1) stage4_RegWrite (.clk(clk), .rst(stage_rst), .enable(stage_enable), .in(RegWriteM), .out(RegWriteW));
    pipo #(2) stage4_ResultSrc (.clk(clk), .rst(stage_rst), .enable(stage_enable), .in(m.ResultSrcM), .out(w.ResultSrcW));
    pipo #(XLEN) stage4_ALUResult (.clk(clk), .rst(stage_rst), .enable(stage_enable), .in(m.ALUResultM), .out(w.ALUResultW));
    pipo #(REG_ADDR_WIDTH) stage4_Rd (.clk(clk), .rst(stage_rst), .enable(stage_enable), .in(RdM), .out(w.RdW));
    pipo #(XLEN) stage4_PCPlus4 (.clk(clk), .rst(stage_rst), .enable(stage_enable), .in(m.PCPlus4M), .out(w.PCPlus4W));
    // sama to review
    pipo #(XLEN) stage4_ReadData (.clk(clk), .rst(stage_rst), .enable(stage_enable), .in(m.ReadDataM), .out(w.ReadDataW));

    // ==================================================
    // Program Counter (PC) Logic + instruction fetch in Stage 1
    // ==================================================

    // assign jump_mux_in[0] = f.InstrF; // Normal instruction fetch
    // assign jump_mux_in[1] = 1'b0;
    // PC + 4
    adder pc_adder (
        .a(f.PCF),
        .b(32'd1),
        .sum(f.PCPlus4F)
    );

    // Select next PC value
    assign pc_mux_in[0] = f.PCPlus4F;
    assign pc_mux_in[1] = e.PCTargetE;


    mux #(.SEL_WIDTH(1)) pc_mux (
        .in(pc_mux_in),
        .sel(PCSrcE),
        .out(f.PCNextF)
    );


    // PC Register
    pc PC_reg (
        .clk(clk),
        .reset(reset),
        .enable(StallF_bar),
        .PCNext(f.PCNextF[ADDR_WIDTH-1:0]), // Ensure the size matches address_t
        .pc(f.PCF[ADDR_WIDTH-1:0])
    );

    //assign f.PCF[ADDR_WIDTH-1:0] = PC;

    instr_mem InstructionMemory (
        .clk(clk),
        .address(f.PCF[ADDR_WIDTH-1:0]),
        .instruction(f.InstrF)
    );

    // mux #(.SEL_WIDTH(1)) jump_mux (
    //     .in(jump_mux_in),
    //     .sel(d.JumpD),
    //     .out(f.InstrF)
    // );


    // ==================================================
    // Stage 2: Instruction Decode and control signals
    // ==================================================

    decoder decoder_instance (
        .Instr(d.InstrD),
        .decoded_instr(di)
    );

    Controller Controller_instance (
        .Zero(e.ZeroE),

        .funct3(di.funct3),
        .funct7(di.funct7),
        .op(di.op),
        
        .control_signals(cs),
        .ALUControl(d.ALUControlD)
    );

    assign Rs1D = di.rs1;
    assign Rs2D = di.rs2;
    assign d.RdD  = di.rd;

    assign d.RegWriteD = cs.RegWrite;
    assign d.ResultSrcD = cs.ResultSrc;
    assign d.MemWriteD = cs.MemWrite;
    assign d.ALUSrcD = cs.ALUSrc;
    assign d.ImmSrcD = cs.ImmSrc;

    // ==================================================
    // Sign-extension of raw immediates in Stage 2
    // ==================================================

    assign imm_mux_in[IMMSRC_I] = {{20{di.imm_i_raw[11]}}, di.imm_i_raw};
    assign imm_mux_in[IMMSRC_S] = {{20{di.imm_s_raw[11]}}, di.imm_s_raw};
    assign imm_mux_in[IMMSRC_B] = {{19{di.imm_b_raw[12]}}, di.imm_b_raw};
    assign imm_mux_in[IMMSRC_J] = {{11{di.imm_j_raw[20]}}, di.imm_j_raw};

    mux #(.SEL_WIDTH(2)) imm_mux (
        .in(imm_mux_in),
        .sel(d.ImmSrcD),
        .out(d.ImmExtD)
    );



    regFile RegisterFile (
        .clk         (clk),
        .read_reg1   (Rs1D),
        .read_reg2   (Rs2D),
        .write_reg   (w.RdW),
        .write_data  (w.ResultW),
        .writeEnable (RegWriteW),
        .read_data1  (d.RD1D),
        .read_data2  (d.RD2D)
    );

    // ==================================================
    // Execute Stage 
    // ==================================================
    assign alu_mux_in[0] = e.WriteDataE;
    assign alu_mux_in[1] = e.ImmExtE;

    mux #(.SEL_WIDTH(1)) mux_b (
        .in (alu_mux_in),
        .sel(e.ALUSrcE),
        .out(e.SrcBE)
    );

    //3:1 mux outputs SrcAE for ALU SrcAE
    assign SrcAE_mux_in[0] = e.RD1E;
    assign SrcAE_mux_in[1] = w.ResultW;
    assign SrcAE_mux_in[2] = m.ALUResultM;

    mux #(.SEL_WIDTH(2)) SrcAE_mux(
        .in(SrcAE_mux_in),
        .sel(ForwardAE),
        .out(e.SrcAE)
    );

    //3:1 mux outputs WriteDataE for ALU SrcBE
    assign WriteDataE_mux_in[0] = e.RD2E;
    assign WriteDataE_mux_in[1] = w.ResultW;
    assign WriteDataE_mux_in[2] = m.ALUResultM;

    mux #(.SEL_WIDTH(2)) WriteDataE_mux(
        .in(WriteDataE_mux_in),
        .sel(ForwardEE),
        .out(e.WriteDataE)
    );


    alu ALU (
        .a       (e.SrcAE),
        .b       (e.SrcBE),
        .control (e.ALUControlE),
        .result  (e.ALUResultE),
        .zero    (e.ZeroE)
    );
    // PC + Immediate (for branches/jumps)
    adder pc_target_adder (
        .a(e.PCE),
        .b(e.ImmExtE),
        .sum(e.PCTargetE)
    );
    // here a mux for the forwarding
    //assign WriteDataE = e.RD2E;
    //

    // ==================================================
    // Memory Stage
    // ==================================================

    assign address = m.ALUResultM; // to match the size of the memory address
    data_mem DataMemory (
        .clk(clk),
        .write_enable(m.MemWriteM),
        .data_address(address),
        .write_data(m.WriteDataM),
        .read_data(m.ReadDataM)
    );

    // ==================================================
    // Write-Back Result MUX
    // ==================================================
    assign result_mux_in[RESULT_ALU]  = w.ALUResultW;
    assign result_mux_in[RESULT_MEM]  = w.ReadDataW;
    assign result_mux_in[RESULT_JUMP] = w.PCPlus4W;

    mux #(.SEL_WIDTH(2)) result_mux (
        .in (result_mux_in),
        .sel(w.ResultSrcW),
        .out(w.ResultW)
    );
endmodule
