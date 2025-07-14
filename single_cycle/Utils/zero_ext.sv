`default_nettype none
import types_pkg::*;
module zero_ext #(parameter int WIDTI_IN = 16, 
                   parameter int WIDTI_OUT = 32) (
    input  logic [WIDTI_IN-1:0] in,
    output logic [WIDTI_OUT-1:0] out
    );
    assign out = {{(WIDTI_OUT-WIDTI_IN){1'b0}}, in};
endmodule