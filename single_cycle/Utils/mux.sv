//
import types_pkg::*;

module mux #(
    parameter int SEL_WIDTH = 2  // 2^2 = 4-input mux
) (
    input  word_t in [2**SEL_WIDTH],
    input  logic [SEL_WIDTH-1:0] sel,
    output word_t out
);
    assign out = in[sel];
endmodule
