
// `default_nettype none
import types_pkg::*;

module pc (
    input  logic            clk,
    input  logic            reset,     
    input  address_t        PCNext,
    output address_t        pc
);

    always_ff @(posedge clk) begin
        if (reset)
            pc <= '0;
        else
            pc <= PCNext;
    end

endmodule
