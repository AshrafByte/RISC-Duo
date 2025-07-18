`default_nettype none
import types_pkg::*;

module pc (
    input  logic                    clk,
    input  logic                    reset,     
    input  logic [ADDR_WIDTH-1:0]   PCNext,
    output logic [ADDR_WIDTH-1:0]   pc
);

    always_ff @(posedge clk) begin
        if (reset)
            pc <= '0;
        else
            pc <= PCNext;
    end

endmodule
