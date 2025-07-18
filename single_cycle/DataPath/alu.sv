
import types_pkg::*;

module alu (
    input  word_t   a,
    input  word_t   b,
    input  aluop_e  control,  
    output word_t   result,
    output logic    zero
);

    signed_word_t signed_a, signed_b;
    assign signed_a = a;
    assign signed_b = b;

    always_comb begin
        unique case (control)
            ALU_ADD:   result = a + b;
            ALU_SUB:   result = a - b;
            ALU_AND:   result = a & b;
            ALU_OR:    result = a | b;
            ALU_XOR:   result = a ^ b;
            ALU_SRL:   result = a >> b[SHIFT_AMOUNT-1:0];
            ALU_SRA:   result = signed_a >>> b[SHIFT_AMOUNT-1:0];
            ALU_SLL:   result = a << b[SHIFT_AMOUNT-1:0];
            ALU_SLT:   result = (signed_a < signed_b) ? 1 : 0;
            ALU_SLTU:  result = (a < b) ? 1 : 0;
            default:   result = '0;
        endcase

        zero = (result == '0);
    end

endmodule
