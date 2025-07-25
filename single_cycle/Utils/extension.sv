//
// `default_nettype none
import types_pkg::*;
module extension #(
    parameter int WIDTI_IN = 16,
    parameter int WIDTI_OUT = 32
)(
    input  logic [WIDTI_IN-1:0] in,
    input  logic shift,
    output logic [WIDTI_OUT-1:0] out
);

    always_comb begin
        if(shift)
            out = {{(WIDTI_OUT-WIDTI_IN){1'b0}}, in};
        else
            out = {{(WIDTI_OUT-WIDTI_IN){in[WIDTI_IN-1]}}, in};
    end
endmodule