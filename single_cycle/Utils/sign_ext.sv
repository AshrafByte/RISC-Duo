`default_nettype none
import types_pkg::*;
module sign_ext #(parameter int WIDTI_IN = 16, 
                   parameter int WIDTI_OUT = 32) (
    input  logic [WIDTI_IN-1:0] in,
    output logic [WIDTI_OUT-1:0] out
    );
    assign out = {{(WIDTI_OUT-WIDTI_IN){in[WIDTI_IN-1]}}, in};
endmodule