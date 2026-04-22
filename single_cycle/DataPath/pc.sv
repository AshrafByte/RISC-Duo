
// `default_nettype none
import types_pkg::*;

module pc (
    input  logic            clk,
    input  logic            reset,     
    input  word_t           PCNext,    // Change to word_t to match datapath
    output word_t           pc         // Change to word_t to match datapath
);

    always_ff @(posedge clk) begin
        if (reset) 
            pc <= '0;
          
         else 
            pc <= PCNext;
    end

endmodule
