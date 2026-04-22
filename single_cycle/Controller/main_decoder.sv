
// `default_nettype none
import types_pkg::*;


module main_decoder (
    input  logic             Zero,
    input  opcode_e          op,

    output aluop_type_e      ALUOp,
    output control_signals_t control_signals 
);
    always_comb begin
        
        setControlSignals(
            .pcsrc(0),
            .resultsrc(RESULT_ALU),
            .memwrite(0),
            .alusrc(0),
            .immsrc(IMMSRC_I),
            .regwrite(0),
            .aluop(ALUOP_OTHER)
        );

        unique case (op)
            OP_S_TYPE: setControlSignals(
                .pcsrc(0),
                .resultsrc(RESULT_ALU),
                .memwrite(1),
                .alusrc(1),
                .immsrc(IMMSRC_S),
                .regwrite(0),
                .aluop(ALUOP_LUI)
            );

            OP_B_TYPE: setControlSignals(
                .pcsrc(Zero),
                .resultsrc(RESULT_ALU),
                .memwrite(0),
                .alusrc(0),
                .immsrc(IMMSRC_B),
                .regwrite(0),
                .aluop(ALUOP_BRANCH)
            );

           OP_JAL_TYPE: setControlSignals(
             .pcsrc(1),
                .resultsrc(RESULT_JUMP),
                .memwrite(0),
                .alusrc(1),
                .immsrc(IMMSRC_J),
                .regwrite(1),
                .aluop(ALUOP_LUI)
            );

            OP_JALR_TYPE: setControlSignals(
              .pcsrc(2),
                .resultsrc(RESULT_JUMP),
                .memwrite(0),
                .alusrc(1),
                .immsrc(IMMSRC_I),
                .regwrite(1),
                .aluop(ALUOP_LUI)
            );

            OP_R_TYPE: setControlSignals(
                .pcsrc(0),
                .resultsrc(RESULT_ALU),
                .memwrite(0),
                .alusrc(0),
                .immsrc(IMMSRC_I),
                .regwrite(1),
                .aluop(ALUOP_R_OR_I_TYPE)
            );

            OP_I_TYPE_ARITH : setControlSignals(
                .pcsrc(0),
                .resultsrc(RESULT_ALU),
                .memwrite(0),
                .alusrc(1),
                .immsrc(IMMSRC_I),
                .regwrite(1),
                .aluop(ALUOP_R_OR_I_TYPE)      
            );

            OP_I_TYPE_LOAD : setControlSignals(
                .pcsrc(0),
                .resultsrc(RESULT_MEM),
                .memwrite(0),
                .alusrc(1),
                .immsrc(IMMSRC_I),
                .regwrite(1),
                .aluop(ALUOP_LUI)
            );

            default: ; // Do nothing
        endcase

    end


    function automatic void setControlSignals(
      input logic [1:0]        pcsrc,
            input resultsrc_e  resultsrc,
            input logic        memwrite,
            input logic        alusrc,
            input immsrc_e     immsrc,
            input logic        regwrite,
            input aluop_type_e aluop
        );

        control_signals.PCSrc      = pcsrc;
        control_signals.ResultSrc  = resultsrc;
        control_signals.MemWrite   = memwrite;
        control_signals.ALUSrc     = alusrc;
        control_signals.ImmSrc     = immsrc;
        control_signals.RegWrite   = regwrite;
        ALUOp                      = aluop;
        
    endfunction : setControlSignals 

endmodule
