// Code your testbench here
// or browse Examples
module tb;
    logic clk;
    logic reset;


    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns period
    end

    /*  initial begin
    $readmemh("DataMemory.dat", dut.DataMemory.data_memory);
    $readmemh("InstructionData.dat", dut.InstructionMemory.instruction_memory);
    $readmemh("RegisterData.dat", dut.RISCVSingle.DataPath_instance.RegisterFile.registers);
end*/

    Top dut (
        .clk(clk),
        .reset(reset)
    );

    test_program test_prog (
        .clk(clk),
        .reset(reset)
    );

endmodule

