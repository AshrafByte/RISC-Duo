//
import types_pkg::*;

module instr_mem(
    input logic     clk,
    input address_t address, // 9 bits to address 512 location
    output word_t   instruction
);
    
    

    //internal memory, 512 location. Each location is of 32 bit width
    word_t memory [MEM_SIZE];

    // Initialize memory from file
    initial begin
        $readmemh("inst.mem", memory);
    end

    //decoding the instruction
    always_ff@(posedge clk)begin
        instruction <= memory[address];
    end
endmodule

