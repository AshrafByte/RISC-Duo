import types_pkg::*;

module pipo #(
    parameter WIDTH = 1
)(
    input logic clk,
    input logic rst,
    input logic enable,
    input logic [WIDTH-1:0] in,
    output logic [WIDTH-1:0] out
);

    always_ff @(posedge clk or posedge rst) begin      //should be synchronous?
        if (rst)
            out <= '0;
        else if (enable)
            out <= in;
    end
endmodule
