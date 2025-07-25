`include "Top.sv"
// `default_nettype none

module testbench;
bit clk;
reg reset;

Top dut
(
    .*
);

localparam CLK_PERIOD = 10;
always #(CLK_PERIOD/2) clk=~clk;

// initial begin
//     $dumpfile("tb_Top.vcd");
//     $dumpvars(0, tb_Top);
// end

initial begin
    $readmemh("DataMemory.dat", dut.RISCVPipeline.DataMemory.data_memory);
    $readmemh("pipelineInstructionData.dat", dut.RISCVPipeline.InstructionMemory.instruction_memory);
    $readmemh("RegisterData.dat", dut.RISCVPipeline.RegisterFile.registers);
end
    // add wave dut.DataMemory.data_memory
    // add wave dut.InstructionMemory.instruction_memory
    // add wave dut.RISCVSingle.DataPath_instance.RegisterFile.registers
initial begin
    #1 reset<=1'b1;
    repeat(5) @(posedge clk);
    #(CLK_PERIOD*3)
    reset<=0;
    @(posedge clk);
    repeat(60) @(posedge clk);
    $stop(2);
end

endmodule
// `default_nettype wire