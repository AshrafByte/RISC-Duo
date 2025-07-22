// Code your testbench here
// or browse Examples
module tb;
    logic clk;
    logic reset;
    
    
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 10ns period
    end
  
    Top dut (
        .clk(clk),
        .reset(reset)
    );
    
    test_program test_prog (
        .clk(clk),
        .reset(reset)
    );
  
endmodule

