
// `default_nettype none
import types_pkg::*;
module Top (
    input logic clk,
    input logic reset
);
 // === Internal Wires ===
    word_t PC;
    word_t WriteData;
    address_t DataAdr;
    word_t ReadData;
    word_t Instr;
    logic MemWrite;

 // === Memories ===
 data_mem DataMemory (
    .clk(clk),
    .write_enable(MemWrite),
    .data_address(DataAdr),
    .write_data(WriteData),
    .read_data(ReadData)
 );

 instr_mem InstructionMemory (
    .clk(clk),
    .address(PC),
    .instruction(Instr)
 );

 // ===Processor===
 Core RISCVSingle(
    .clk(clk),
    .reset(reset),
    .Instr(Instr),
    .ReadData(ReadData),

    .PC(PC),
    .WriteData(WriteData),
    .ALUResult(DataAdr),
    .MemWrite(MemWrite)
 );
endmodule


