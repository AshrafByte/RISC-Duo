`default_nettype none
import types_pkg::*;
module alu (
    input logic [XLEN-1:0] a,
    input  logic [XLEN-1:0] b,
    input  alu_control_t     control,
    output logic [XLEN-1:0] result,
    output logic            zero
);

    logic signed [XLEN-1:0] signed_a, signed_b;
    // Convert inputs to signed for SRA and SLT operations
    assign signed_a = a ;
    assign signed_b = b ;

    always_comb begin
        case (control)
            ADD: result = a + b;
            SUB: result = a - b;
            AND: result = a & b;
            OR : result = a | b;
            XOR: result = a ^ b;
            SRL: result = a >> b[4:0];
            SRA: result = signed_a >>> b[SHIFT_AMOUNT-1:0];
            SLL: result = a << b[SHIFT_AMOUNT-1:0];
            SLT: result = (signed_a < signed_b) ? 1 : 0; // Set less than
            SLTU: result = (a < b) ? 1 : 0;              // Set less than unsigned
            default: result = '0; 
        endcase
        zero = (result == '0);
    end
endmodule