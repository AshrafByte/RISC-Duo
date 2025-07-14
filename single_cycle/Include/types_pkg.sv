`default_nettype none
package types_pkg;

  // Standard word width
  parameter int XLEN = 32;

  // Convenience typedefs
  typedef logic [XLEN-1:0] word_t;
  typedef logic [4:0]      reg_addr_t;  // 32 registers

endpackage
