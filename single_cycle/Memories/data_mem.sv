
// `default_nettype none
import types_pkg::*;

module data_mem(
        input logic clk, write_enable,
        input address_t data_address,
        input word_t write_data,
        
        output word_t read_data
    );


    word_t data_memory [MEM_SIZE];

    always_ff@(posedge clk)begin
        if(write_enable) data_memory[data_address] <= write_data;
        read_data <= data_memory[data_address];
    end

endmodule
