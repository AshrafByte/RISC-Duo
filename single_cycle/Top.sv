`default_nettype none
import types_pkg::*;
module Top (
    input logic clk,
    input logic reset
);
 // === Internal Wires ===
    wire [XLEN-1:0] PC;
    wire [XLEN-1:0] WriteData;
    wire [XLEN-1:0] DataAdr;
    wire [XLEN-1:0] ReadData;
    wire [XLEN-1:0] Instr;
    wire MemWrite;

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
    .AluResult(DataAdr),
    .MemWrite(MemWrite)
 );
endmodule


