`default_nettype none
package types_pkg;

  // Standard word width
  parameter int XLEN = 32;

  // Convenience typedefs
  typedef logic [XLEN-1:0] word_t;
  typedef logic [4:0]      reg_addr_t;  // 32 registers

  // ALU control signals
  typedef enum logic [3:0] {
    ADD = 4'b0000,
    SUB = 4'b0001,
    AND = 4'b0010,
    OR  = 4'b0011,
    XOR = 4'b0100,
    SRL = 4'b0110,
    SRA = 4'b0111,
    SLL = 4'b0101,
    SLT = 4'b1000,
    SLTU = 4'b1001
  } alu_control_t;

endpackage
