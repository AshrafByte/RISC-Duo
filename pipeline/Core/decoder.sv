// decoder.sv
// `default_nettype none
import types_pkg::*;

module decoder (
    input  word_t           Instr,
    output decoded_instr_t  decoded_instr 
);

    always_comb begin

        // Instruction field extraction
        decoded_instr.op     = opcode_e'(Instr[OPCODE_MSB:OPCODE_LSB]);
        decoded_instr.rd     = Instr[RD_MSB:RD_LSB];
        decoded_instr.funct3 = funct3_e'(Instr[FUNCT3_MSB:FUNCT3_LSB]);
        decoded_instr.rs1    = Instr[RS1_MSB:RS1_LSB];
        decoded_instr.rs2    = Instr[RS2_MSB:RS2_LSB];
        decoded_instr.funct7 = funct7_e'(Instr[FUNCT7_MSB:FUNCT7_LSB]);


        // Immediate raw fields (before sign-extension)
        decoded_instr.imm_i_raw = Instr[IMM_I_MSB:IMM_I_LSB];

        decoded_instr.imm_s_raw = {
            Instr[IMM_S_HI_MSB:IMM_S_HI_LSB],
            Instr[IMM_S_LO_MSB:IMM_S_LO_LSB]
        };

        decoded_instr.imm_b_raw = {
            Instr[IMM_B_12_BIT],
            Instr[IMM_B_11_BIT],
            Instr[IMM_B_10_5_MSB:IMM_B_10_5_LSB],
            Instr[IMM_B_4_1_MSB:IMM_B_4_1_LSB],
            1'b0
        };

        decoded_instr.imm_j_raw = {
            Instr[IMM_J_20_BIT],
            Instr[IMM_J_19_12_MSB:IMM_J_19_12_LSB],
            Instr[IMM_J_11_BIT],
            Instr[IMM_J_10_1_MSB:IMM_J_10_1_LSB],
            1'b0
        };
    end

endmodule
