`default_nettype none
import types_pkg::*;
module DataPath (
    input logic clk,
    input logic Reset,
    // from instruction memory to ALU
    input logic [XLEN-1:0] read_data1,
    input logic [XLEN-1:0] read_data2,
    // Control signals
    input logic PCSrc,
    input logic ResultSrc,
    input logic [3:0] ALUControl,
    input logic ALUSrc,
    input logic [1:0]ImmSrc,
    input logic RegWrite,
    input logic RegSrc,
    output logic [XLEN-1:0] PC,
    output logic Zero,
    output logic [XLEN-1:0] ALUResult,
    output logic [XLEN-1:0] WriteData
    );
    logic [XLEN-1:0] PCNext;

    word_t alu_mux_in [2];
    logic [XLEN-1:0] SrcB , ImmExt;
    assign read_data2 = alu_mux_in[0];
    assign ImmExt = alu_mux_in[1];

    mux #(.SEL_WIDTH(1)) mux_b (
        .in(alu_mux_in),
        .sel(ALUSrc),
        .out(SrcB)
    )
    // PC instance 


    // ALU instance
    alu ALU (
        .a(read_data1),
        .b(SrcB),
        .control(ALUControl),
        .result(ALUResult),
        .zero(Zero)
    )
    
    assign WriteData = read_data2;
    




    
    
    
    
    
endmodule

