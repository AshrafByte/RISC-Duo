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

    always @(posedge clk or posedge rst) begin
        if (rst)
            out <= '0;
        else if (enable)
            out <= in;
    end
endmodule
