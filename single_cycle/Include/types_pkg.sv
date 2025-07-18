`default_nettype none
package types_pkg;

  // ============================================================
  // Core Configuration
  // ============================================================
  parameter int XLEN = 32;
  parameter int SHIFT_AMOUNT = $clog2(XLEN);
  
  parameter int ADDR_WIDTH = 9;
  parameter int MEM_SIZE = 2**ADDR_WIDTH;
  // ============================================================
  // Common Typedefs
  // ============================================================
  typedef logic [XLEN-1:0] word_t;       // Full data word
  typedef logic [4:0]      reg_addr_t;   // Register file address (32 regs)

  // ============================================================
  // Instruction Field Enums
  // ============================================================

  // 7-bit Opcode Field
  typedef enum logic [6:0] {
      OP_I_TYPE_LOAD    = 7'b000_0011,
      OP_I_TYPE_ARITH   = 7'b001_0011,
      OP_S_TYPE         = 7'b010_0011,
      OP_R_TYPE         = 7'b011_0011,
      OP_B_TYPE         = 7'b110_0011,
      OP_J_TYPE         = 7'b110_1111,
      OP_RV64_TYPE      = 7'b011_1011
  } opcode_e;

  // 3-bit Funct3 Field (ALU op selector)
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

  // 7-bit Funct7 Field (used to distinguish ops like ADD/SUB, SRL/SRA)
  typedef enum logic [6:0] {
      FUNCT7_NORMAL = 7'b000_0000, // ADD, SRL, etc.
      FUNCT7_ALT    = 7'b010_0000  // SUB, SRA, etc.
  } funct7_e;

  // ============================================================
  // ALU Control
  // ============================================================

  // 4-bit ALU operation signals (output of alu_control)
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

  // Coarse ALU operation types (from control_unit to alu_control)
  typedef enum logic [1:0] {
      ALUOP_LUI          = 2'b00, // Load/store → ADD
      ALUOP_BRANCH       = 2'b01, // Branches   → SUB
      ALUOP_R_OR_I_TYPE  = 2'b10, // R-type OR I-type    → Use funct3/funct7
      ALUOP_OTHER        = 2'b11  // Default / illegal
  } aluop_type_e;

  // ============================================================
  // Control Signal Enums (MUX selectors etc.)
  // ============================================================

  // ALU/MEM/JUMP result MUX control
  typedef enum logic [1:0] {
      RESULT_ALU   = 2'b00,
      RESULT_MEM   = 2'b01,
      RESULT_JUMP  = 2'b10
  } resultsrc_e;

  // Immediate decoder source selector
  typedef enum logic [1:0] {
      IMM_I        = 2'b00,
      IMM_S        = 2'b01,
      IMM_B        = 2'b10,
      IMM_J        = 2'b11
  } immsrc_e;

endpackage
