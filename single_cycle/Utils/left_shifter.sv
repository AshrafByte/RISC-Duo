`default_nettype none
import types_pkg::*;

module left_shifter #(
    parameter int SHIFT = 1
) (
    input  word_t in,
    output word_t out
);
    assign out = in << SHIFT;
endmodule
