
// `default_nettype none
import types_pkg::*;

module alu_decoder (
    input  opcode_e op,
    input  aluop_type_e ALUOp,
    input  funct3_e     funct3,
    input  funct7_e     funct7,
    output aluop_e      ALUControl,
    output logic        shift // Indicates if the operation is a shift (SLL, SRL, SRA)
);

    always_comb begin
        unique case (ALUOp)
            ALUOP_LUI:            ALUControl = ALU_ADD;   // used for load/store/immediates
            ALUOP_BRANCH:         ALUControl = ALU_SUB;   // used for branch operations
            ALUOP_R_OR_I_TYPE:    ALUControl = decode_funct3();
            default:              ALUControl = ALU_ADD;
        endcase
        unique case (funct3)
            F3_SLL, F3_SRL_SRA:   shift = 1'b1; // Shift operations
            default:              shift = 1'b0; // Non-shift operations
        endcase
    end


    function automatic aluop_e decode_funct3();
        unique case (funct3)
            F3_ADD_SUB:   return (op == OP_I_TYPE_ARITH) ? ALU_ADD : decode_funct7_variant(ALU_ADD, ALU_SUB); // Handle Addi instruction
            F3_SLL:       return ALU_SLL;
            F3_SLT:       return ALU_SLT;
            F3_SLTU:      return ALU_SLTU;
            F3_XOR:       return ALU_XOR;
            F3_SRL_SRA:   return decode_funct7_variant(ALU_SRL, ALU_SRA);
            F3_OR:        return ALU_OR;
            F3_AND:       return ALU_AND;
            default:      return ALU_ADD;
        endcase
    endfunction


    function automatic aluop_e decode_funct7_variant(
        input aluop_e  op_normal,
        input aluop_e  op_alt
    );
        return (funct7[5] == 1'b0) ? op_normal : op_alt;
    endfunction


endmodule
