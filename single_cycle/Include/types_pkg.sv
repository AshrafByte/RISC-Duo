`default_nettype none
package types_pkg;

    // =============================================================
    // Core Configuration
    // =============================================================
    parameter int XLEN         = 32;
    parameter int SHIFT_AMOUNT = $clog2(XLEN);
    parameter int ADDR_WIDTH   = 9;
    parameter int MEM_SIZE     = 2 ** ADDR_WIDTH;
    parameter int REG_COUNT    = 32;

    // =============================================================
    // Basic Typedefs
    // =============================================================
    typedef logic [XLEN-1:0]                word_t;
    typedef logic signed [XLEN-1:0]         signed_word_t;
    typedef logic [$clog2(REG_COUNT)-1:0]   reg_addr_t;

    // =============================================================
    // Instruction Bit Field Ranges (RV32I)
    // =============================================================
    localparam int OPCODE_MSB  = 6,  OPCODE_LSB  = 0;
    localparam int RD_MSB      = 11, RD_LSB      = 7;
    localparam int FUNCT3_MSB  = 14, FUNCT3_LSB  = 12;
    localparam int RS1_MSB     = 19, RS1_LSB     = 15;
    localparam int RS2_MSB     = 24, RS2_LSB     = 20;
    localparam int FUNCT7_MSB  = 31, FUNCT7_LSB  = 25;
    localparam int SIGNEXT_MSB = 31, SIGNEXT_LSB = 7;

    // =============================================================
    // Immediate Field Encodings (Before Sign-Extension)
    // =============================================================
    typedef logic [11:0] imm_i_raw_t;  // I-type: [31:20]
    typedef logic [11:0] imm_s_raw_t;  // S-type: [31:25 | 11:7]
    typedef logic [12:0] imm_b_raw_t;  // B-type: [31|7|30:25|11:8]
    typedef logic [20:0] imm_j_raw_t;  // J-type: [31|19:12|20|30:21]

    // I-type: imm[11:0] = instr[31:20]
    localparam int IMM_I_LSB = 20;
    localparam int IMM_I_MSB = 31;

    // S-type: imm[11:5] = instr[31:25], imm[4:0] = instr[11:7]
    localparam int IMM_S_HI_MSB = 31, IMM_S_HI_LSB = 25;
    localparam int IMM_S_LO_MSB = 11, IMM_S_LO_LSB = 7;

    // B-type: imm[12|10:5|4:1|11] = instr[31|30:25|11:8|7]
    localparam int IMM_B_12_BIT     = 31;
    localparam int IMM_B_11_BIT     = 7;
    localparam int IMM_B_10_5_MSB   = 30, IMM_B_10_5_LSB = 25;
    localparam int IMM_B_4_1_MSB    = 11, IMM_B_4_1_LSB  = 8;

    // J-type: imm[20|10:1|11|19:12] = instr[31|30:21|20|19:12]
    localparam int IMM_J_20_BIT     = 31;
    localparam int IMM_J_11_BIT     = 20;
    localparam int IMM_J_10_1_MSB   = 30, IMM_J_10_1_LSB = 21;
    localparam int IMM_J_19_12_MSB  = 19, IMM_J_19_12_LSB = 12;

    // =============================================================
    // Opcode & Function Field Enums
    // =============================================================
    
    // 7-bit Opcode
    typedef enum logic [6:0] {
        OP_I_TYPE_LOAD   = 7'b000_0011,
        OP_I_TYPE_ARITH  = 7'b001_0011,
        OP_S_TYPE        = 7'b010_0011,
        OP_R_TYPE        = 7'b011_0011,
        OP_B_TYPE        = 7'b110_0011,
        OP_J_TYPE        = 7'b110_1111,
        OP_RV64_TYPE     = 7'b011_1011
    } opcode_e;

    // 3-bit funct3 field
    typedef enum logic [2:0] {
        F3_ADD_SUB   = 3'b000,
        F3_SLL       = 3'b001,
        F3_SLT       = 3'b010,
        F3_SLTU      = 3'b011,
        F3_XOR       = 3'b100,
        F3_SRL_SRA   = 3'b101,
        F3_OR        = 3'b110,
        F3_AND       = 3'b111
    } funct3_e;
    
    // 7-bit funct7 field (just two used values)
    typedef enum logic [6:0] {
        FUNCT7_NORMAL = 7'b000_0000,  // ADD, SRL, etc.
        FUNCT7_ALT    = 7'b010_0000   // SUB, SRA, etc.
    } funct7_e;

    // =============================================================
    // ALU Control Enums
    // =============================================================

    // Specific ALU operations (output of alu_control)
    typedef enum logic [3:0] {
        ALU_ADD   = 4'b0000,
        ALU_SUB   = 4'b0001,
        ALU_AND   = 4'b0010,
        ALU_OR    = 4'b0011,
        ALU_XOR   = 4'b0100,
        ALU_SLL   = 4'b0101,
        ALU_SRL   = 4'b0110,
        ALU_SRA   = 4'b0111,
        ALU_SLT   = 4'b1000,
        ALU_SLTU  = 4'b1001
    } aluop_e;
    
    // Coarse ALUOp types (used between decoder and ALU control)
    typedef enum logic [1:0] {
        ALUOP_LUI         = 2'b00, // For load/store/imm (→ ADD)
        ALUOP_BRANCH      = 2'b01, // For branches (→ SUB)
        ALUOP_R_OR_I_TYPE = 2'b10, // Use funct3/funct7
        ALUOP_OTHER       = 2'b11  // Reserved
    } aluop_type_e;

    // =============================================================
    // Control Signals & Multiplexers
    // =============================================================
    
    // MUX: result from ALU, MEM, JUMP
    typedef enum logic [1:0] {
        RESULT_ALU   = 2'b00,
        RESULT_MEM   = 2'b01,
        RESULT_JUMP  = 2'b10
    } resultsrc_e;

    // Immediate format selector
    typedef enum logic [1:0] {
        IMMSRC_I = 2'b00,
        IMMSRC_S = 2'b01,
        IMMSRC_B = 2'b10,
        IMMSRC_J = 2'b11
    } immsrc_e;

    // =============================================================
    // Structs for Cleaner Interfacing
    // =============================================================

    typedef struct packed {
        opcode_e     op;
        reg_addr_t   rd;
        reg_addr_t   rs1;
        reg_addr_t   rs2;
        funct3_e     funct3;
        funct7_e     funct7;
        imm_i_raw_t  imm_i_raw;
        imm_s_raw_t  imm_s_raw;
        imm_b_raw_t  imm_b_raw;
        imm_j_raw_t  imm_j_raw;
    } decoded_instr_t;

    typedef struct packed {
        logic        PCSrc;
        resultsrc_e  ResultSrc;
        logic        MemWrite;
        logic        ALUSrc;
        immsrc_e     ImmSrc;
        logic        RegWrite;
        aluop_e      ALUControl;
    } control_signals_t;

endpackage
