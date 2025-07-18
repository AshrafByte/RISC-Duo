`default_nettype none
import types_pkg::*;

module pc(PCNext, clk, pc);
    input clk;
    input [ADDR_WIDTH - 1 :0] PCNext;
    output reg [ADDR_WIDTH - 1 :0] pc;

    always@(posedge clk)begin
        pc <= PCNext;
    end

endmodule
