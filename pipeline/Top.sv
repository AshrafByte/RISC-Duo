
// `default_nettype none
import types_pkg::*;
module Top (
    input logic clk,
    input logic reset
);
 // === Internal Wires ===
   logic StallF ;
   logic StallD ;
   logic FlushD ;
   logic FlushE ;
   logic [1:0] ForwardAE, ForwardEE;
   reg_addr_t Rs1D ;
   reg_addr_t Rs2D ;
   reg_addr_t RdE  ;
   reg_addr_t Rs2E ;
   reg_addr_t Rs1E ;
   reg_addr_t RdM  ;
   reg_addr_t RdW  ;
   logic ResultSrcE0 ;
   logic RegWriteM   ;
   logic RegWriteW   ;
   logic PCSrcE      ;
//    logic MemReadE    ;

 // ===Processor===
 DataPath RISCVPipeline(
     .clk(clk),
     .reset(reset),
     .StallF(StallF),
     .StallD(StallD),
     .FlushD(FlushD),
     .FlushE(FlushE),
     .ForwardAE(ForwardAE),
     .ForwardEE(ForwardEE),
     .Rs1D(Rs1D),
     .Rs2D(Rs2D),
     .RdE(RdE),
     .Rs2E(Rs2E),
     .Rs1E(Rs1E),
     .RdM(RdM),
     .PCSrcE(PCSrcE),
     .ResultSrcE0(ResultSrcE0),
     .RegWriteM(RegWriteM),
     .RegWriteW(RegWriteW),
     .RdW(RdW)
    //  .MemReadE(MemReadE)
 );

// ===Hazard Unit===
HazardUnit Hazard_unit(
     .RegWriteM(RegWriteM),
     .RegWriteW(RegWriteW),
     .RdM(RdM),
     .RdW(RdW),
     .Rs2E(Rs2E),
     .Rs1E(Rs1E),
     .ResultSrcE0(ResultSrcE0),

     .ForwardAE(ForwardAE),
     .ForwardEE(ForwardEE),

     .clk(clk),
    //  .MemReadE(MemReadE),
     .RdE(RdE),
     .Rs1D(Rs1D),
     .Rs2D(Rs2D),

     .StallF(StallF),
     .StallD(StallD),
     .FlushE(FlushE),

     .PCSrcE(PCSrcE),

     .FlushD(FlushD)
    //  .FluchE(FlushE)
 );

endmodule




