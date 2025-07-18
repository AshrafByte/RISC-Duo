
// `default_nettype none
import types_pkg::*;

module Controller (
    input  logic             Zero,
    input funct3_e           funct3,
    input funct7_e           funct7,
    input opcode_e           op,

    output control_signals_t control_signals
);

    // Internal decoded field
    aluop_type_e ALUOp;

    main_decoder main_decoder_instance (
        .Zero(Zero),
        .op(op),

        .ALUOp(ALUOp),
        .control_signals(control_signals)
    );
     
    alu_decoder alu_decoder_instance (
        .ALUOp(ALUOp),
        .funct3(funct3),
        .funct7(funct7),
        
        .ALUControl(control_signals.ALUControl)
    );
    
endmodule
