`default_nettype none
import types_pkg::*;

module data_mem(clk, write_enable, data_address, write_data, read_data);

    input logic clk, write_enable;
    input logic [ADDR_WIDTH - 1 :0] data_address;
    input word_t write_data;

    output word_t read_data;

    word_t data_memory [MEM_SIZE - 1 :0];

    always@(posedge clk)begin
        if(write_enable) data_memory[data_address] <= write_data;
        read_data <= data_memory[data_address];
    end

endmodule
