`default_nettype none
import types_pkg::*;

module adder (
    input  word_t a,
    input  word_t b,
    output word_t sum
);
    assign sum = a + b;
endmodule
