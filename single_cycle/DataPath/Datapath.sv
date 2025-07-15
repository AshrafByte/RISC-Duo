`default_nettype none
import types_pkg::*;
module DataPath (
    input logic clk,
    input logic Reset,
    // from Register file to ALU
    input logic [XLEN-1:0] read_data1,
    input logic [XLEN-1:0] read_data2,
    // from instruction memory to extension unit
    input logic [XLEN-1:0] instruction,
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
    // internal signals for PC
    logic [XLEN-1:0] PCNext;
    logic [XLEN-1:0] ImmExt;
    logic [XLEN-1:0] PCTarget;
    logic [XLEN-1:0] PCPlus4;

    // Immediate Extension , ask about the size of the immediate !!
    sign_ext #(.WIDTH_IN(16), .WIDTH_OUT(XLEN)) imm_ext (
        .in(instruction[15:0]),
        .out(ImmExt)
    );

    // PC Logic
    
    // PC target
    adder pc_target_adder (
        .a(PC),
        .b(ImmExt),
        .sum(PCTarget)
    );

    // PC Plus 4
    adder pc_adder (
        .a(PC),
        .b(4),
        .sum(PCPlus4)
    );
    // PC Mux
    word_t pc_mux_in [2];
    assign pc_mux_in[0] = PCPlus4; // PC + 4
    assign pc_mux_in[1] = PCTarget; // Target address for branch

    mux #(.SEL_WIDTH(1)) pc_mux (
        .in(pc_mux_in),
        .sel(PCSrc),
        .out(PCNext)
    );

    // PC register instance
    pc PC_reg (
        .PCNext(PCNext),
        .clk(clk),
        .pc(PC)
    );

    // ALU Mux
    word_t alu_mux_in [2];
    logic [XLEN-1:0] SrcB;
    assign alu_mux_in[0] = read_data2;
    assign alu_mux_in[1] = ImmExt;
    mux #(.SEL_WIDTH(1)) mux_b (
        .in(alu_mux_in),
        .sel(ALUSrc),
        .out(SrcB)
    );
 


    // ALU instance
    alu ALU (
        .a(read_data1),
        .b(SrcB),
        .control(ALUControl),
        .result(ALUResult),
        .zero(Zero)
    );
    
    assign WriteData = read_data2;


    




    
    
    
    
    
endmodule

