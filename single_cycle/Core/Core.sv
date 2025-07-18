`default_nettype none
import types_pkg::*;

module Core(
    input logic     clk,
    input logic     reset,
    input word_t    Instr,
    input word_t    ReadData,

    output word_t   PC,
    output word_t   WriteData,
    output word_t   ALUResult
);

    logic               Zero;
    decoded_instr_t     di;
    control_signals_t   cs;

    decoder decoder_instance (
        .Instr(Instr),
        .decoded_instr(di)
    );
    //////////////////////////////////////////////
    
    

    DataPath DataPath_instance (
        .clk(clk),
        .reset(reset),

        .rs1(di.rs1),
        .rs2(di.rs2),
        .rd(di.rd),

        .imm_i_raw(di.imm_i_raw),
        .imm_s_raw(di.imm_s_raw),
        .imm_b_raw(di.imm_b_raw),
        .imm_j_raw(di.imm_j_raw),

        .PCSrc(cs.PCSrc),
        .ResultSrc(cs.ResultSrc),
        .ALUControl(cs.ALUControl),
        .ALUSrc(cs.ALUSrc),
        .ImmSrc(cs.ImmSrc),
        .RegWrite(cs.RegWrite),

        .ReadData(ReadData),
        .PC(PC),
        .Zero(Zero),
        .ALUResult(ALUResult),
        .WriteData(WriteData)
    );

    Controller Controller_instance (
        .Zero(Zero),

        .funct3(di.funct3),
        .funct7(di.funct7),
        .op(di.op),
        
        .control_signals(cs)
    );

endmodule