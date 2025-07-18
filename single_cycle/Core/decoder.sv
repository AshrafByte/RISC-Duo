// decoder.sv
`default_nettype none
import types_pkg::*;

module decoder (
    input  word_t           Instr,
    
    output opcode_e         op,
    output reg_addr_t       rd,
    output reg_addr_t       rs1,
    output reg_addr_t       rs2,
    output funct3_e         funct3,
    output funct7_e         funct7,
    output imm_i_raw_t      imm_i_raw,
    output imm_s_raw_t      imm_s_raw,
    output imm_b_raw_t      imm_b_raw,
    output imm_j_raw_t      imm_j_raw
);

    always_comb begin

        // Instruction field extraction
        op = Instr[OPCODE_MSB:OPCODE_LSB];
        rd     = Instr[RD_MSB:RD_LSB];
        funct3 = Instr[FUNCT3_MSB:FUNCT3_LSB];
        rs1    = Instr[RS1_MSB:RS1_LSB];
        rs2    = Instr[RS2_MSB:RS2_LSB];
        funct7 = Instr[FUNCT7_MSB:FUNCT7_LSB];

        // Immediate raw fields (before sign-extension)
        imm_i_raw = Instr[IMM_I_MSB:IMM_I_LSB];

        imm_s_raw = {
            Instr[IMM_S_HI_MSB:IMM_S_HI_LSB],
            Instr[IMM_S_LO_MSB:IMM_S_LO_LSB]
        };

        imm_b_raw = {
            Instr[IMM_B_12_BIT],
            Instr[IMM_B_10_5_MSB:IMM_B_10_5_LSB],
            Instr[IMM_B_4_1_MSB:IMM_B_4_1_LSB],
            Instr[IMM_B_11_BIT],
            1'b0
        };

        imm_j_raw = {
            Instr[IMM_J_20_BIT],
            Instr[IMM_J_19_12_MSB:IMM_J_19_12_LSB],
            Instr[IMM_J_11_BIT],
            Instr[IMM_J_10_1_MSB:IMM_J_10_1_LSB],
            1'b0
        };
    end

endmodule
