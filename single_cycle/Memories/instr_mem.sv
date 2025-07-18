`default_nettype none
import types_pkg::*;

module instr_mem(address, instruction);
    //input address
    input address_t address; //9 bits to address 512 location

    //fetched instruction
    output word_t instruction;

    //internal memory, 512 location. Each location is of 32 bit width
    word_t memory [MEM_SIZE];

    //decoding the instruction
    always_comb@(*)begin
        instruction = memory[address];
    end
endmodule

