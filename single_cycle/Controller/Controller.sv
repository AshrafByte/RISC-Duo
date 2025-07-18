`default_nettype none
import types_pkg::*;

module Controller (
    input  logic        Zero,
    input funct3_e     funct3,
    input funct7_e     funct7,
    input opcode_e     op,

    output logic        PCSrc,
    output resultsrc_e  ResultSrc,
    output logic        MemWrite,
    output logic        ALUSrc,
    output immsrc_e     ImmSrc,
    output logic        RegWrite,
    output aluop_e      ALUControl
);

    // Internal decoded field
    aluop_type_e ALUOp;

    main_decoder main_decoder_instance (
        .Zero(Zero),
        .op(op),
        .PCSrc(PCSrc),
        .ResultSrc(ResultSrc),
        .MemWrite(MemWrite),
        .ALUSrc(ALUSrc),
        .ImmSrc(ImmSrc),
        .RegWrite(RegWrite),
        .ALUOp(ALUOp)
    );
     
    alu_decoder alu_decoder_instance (
        .ALUOp(ALUOp),
        .funct3(funct3),
        .funct7(funct7),
        .ALUControl(ALUControl)
    );
    
endmodule
