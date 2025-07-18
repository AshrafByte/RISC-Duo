`default_nettype none
import types_pkg::*;

module instr_mem(address, instruction);
    //input address
    input logic [ADDR_WIDTH - 1 : 0] address; //9 bits to address 512 location

    //fetched instruction
    output word_t instruction;

    //internal memory, 512 location. Each location is of 32 bit width
    word_t memory [MEM_SIZE - 1 :0];

    //decoding the instruction
    always@(*)begin
        instruction = memory[address];
    end
endmodule

