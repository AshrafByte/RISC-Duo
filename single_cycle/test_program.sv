import types_pkg::*;

program test_program (
    input logic clk,
    ref logic reset          
);
    
    import types_pkg::*;
    
    word_t PC;
    word_t ReadData;
    word_t Instr;
    
    assign PC = $root.tb.dut.PC;
    assign Instr = $root.tb.dut.Instr;

    
  	 int count = 0;
    initial begin
        $display("=== Starting RISC-V Processor Test ===");
        
        // Initialize - DRIVING reset signal
        reset = 1;
        ReadData = 32'h0;
        
        // Release reset after a few cycles
        repeat(4) @(posedge clk);
        reset = 0;
        $display("=== Reset Released - Starting Execution ===");
        
       
      repeat(40) begin
        @(negedge clk);
            count++;
          	$display("[COUNT] Coun: %0d", count);
            // [PC] Current Program Counter
        $display("[PC] Current PC: 0x%h", PC);
            
            // [INSTRMEM] Current Instruction
        $display("[INSTRMEM] Instruction: 0x%h", Instr);
            
            // [REG] Register File Information
        $display("[REG] RS1(x%0d)=%0d, RS2(x%0d)=%0d, RD(x%0d)=%0d PCTarget= 0x%h", 
                $root.tb.dut.RISCVSingle.DataPath_instance.rs1,
                $root.tb.dut.RISCVSingle.DataPath_instance.RD1,
                $root.tb.dut.RISCVSingle.DataPath_instance.rs2,
                $root.tb.dut.RISCVSingle.DataPath_instance.RD2,
                $root.tb.dut.RISCVSingle.DataPath_instance.rd,
                $root.tb.dut.RISCVSingle.DataPath_instance.Result,
                    $root.tb.dut.RISCVSingle.DataPath_instance.PCTarget);
            
            // [ALU] ALU Operation and Results
            case($root.tb.dut.RISCVSingle.ALUControl)
                4'b0000: $display("[ALU] ADD: %0d + %0d = %0d, Zero=%b", 
                    $root.tb.dut.RISCVSingle.DataPath_instance.RD1,
                    $root.tb.dut.RISCVSingle.DataPath_instance.SrcB,
                    $root.tb.dut.RISCVSingle.DataPath_instance.ALUResult,
                    $root.tb.dut.RISCVSingle.DataPath_instance.Zero);
                4'b0001: $display("[ALU] SUB: %0d - %0d = %0d, Zero=%b", 
                    $root.tb.dut.RISCVSingle.DataPath_instance.RD1,
                    $root.tb.dut.RISCVSingle.DataPath_instance.SrcB,
                    $root.tb.dut.RISCVSingle.DataPath_instance.ALUResult,
                    $root.tb.dut.RISCVSingle.DataPath_instance.Zero);
                4'b0010: $display("[ALU] AND: %0d & %0d = %0d, Zero=%b", 
                    $root.tb.dut.RISCVSingle.DataPath_instance.RD1,
                    $root.tb.dut.RISCVSingle.DataPath_instance.SrcB,
                    $root.tb.dut.RISCVSingle.DataPath_instance.ALUResult,
                    $root.tb.dut.RISCVSingle.DataPath_instance.Zero);
                4'b0011: $display("[ALU] OR: %0d | %0d = %0d, Zero=%b", 
                    $root.tb.dut.RISCVSingle.DataPath_instance.RD1,
                    $root.tb.dut.RISCVSingle.DataPath_instance.SrcB,
                    $root.tb.dut.RISCVSingle.DataPath_instance.ALUResult,
                    $root.tb.dut.RISCVSingle.DataPath_instance.Zero);
                4'b0100: $display("[ALU] XOR: %0d ^ %0d = %0d, Zero=%b", 
                    $root.tb.dut.RISCVSingle.DataPath_instance.RD1,
                    $root.tb.dut.RISCVSingle.DataPath_instance.SrcB,
                    $root.tb.dut.RISCVSingle.DataPath_instance.ALUResult,
                    $root.tb.dut.RISCVSingle.DataPath_instance.Zero);
                4'b0101: $display("[ALU] SLL: %0d << %0d = %0d, Zero=%b", 
                    $root.tb.dut.RISCVSingle.DataPath_instance.RD1,
                    $root.tb.dut.RISCVSingle.DataPath_instance.SrcB,
                    $root.tb.dut.RISCVSingle.DataPath_instance.ALUResult,
                    $root.tb.dut.RISCVSingle.DataPath_instance.Zero);
                4'b0110: $display("[ALU] SRL: %0d >> %0d = %0d, Zero=%b", 
                    $root.tb.dut.RISCVSingle.DataPath_instance.RD1,
                    $root.tb.dut.RISCVSingle.DataPath_instance.SrcB,
                    $root.tb.dut.RISCVSingle.DataPath_instance.ALUResult,
                    $root.tb.dut.RISCVSingle.DataPath_instance.Zero);
                4'b0111: $display("[ALU] SRA: %0d >>> %0d = %0d, Zero=%b", 
                    $root.tb.dut.RISCVSingle.DataPath_instance.RD1,
                    $root.tb.dut.RISCVSingle.DataPath_instance.SrcB,
                    $root.tb.dut.RISCVSingle.DataPath_instance.ALUResult,
                    $root.tb.dut.RISCVSingle.DataPath_instance.Zero);
                4'b1000: $display("[ALU] SLT: %0d < %0d = %0d, Zero=%b", 
                    $root.tb.dut.RISCVSingle.DataPath_instance.RD1,
                    $root.tb.dut.RISCVSingle.DataPath_instance.SrcB,
                    $root.tb.dut.RISCVSingle.DataPath_instance.ALUResult,
                    $root.tb.dut.RISCVSingle.DataPath_instance.Zero);
                4'b1001: $display("[ALU] SLTU: %0d < %0d = %0d, Zero=%b", 
                    $root.tb.dut.RISCVSingle.DataPath_instance.RD1,
                    $root.tb.dut.RISCVSingle.DataPath_instance.SrcB,
                    $root.tb.dut.RISCVSingle.DataPath_instance.ALUResult,
                    $root.tb.dut.RISCVSingle.DataPath_instance.Zero);
                default: $display("[ALU] UNKNOWN: %0d ? %0d = %0d, Zero=%b", 
                    $root.tb.dut.RISCVSingle.DataPath_instance.RD1,
                    $root.tb.dut.RISCVSingle.DataPath_instance.SrcB,
                    $root.tb.dut.RISCVSingle.DataPath_instance.ALUResult,
                    $root.tb.dut.RISCVSingle.DataPath_instance.Zero);
            endcase
            
            // [CONTROLLER] Control Signals
            $display("[CONTROLLER] PCSrc=%b, ResultSrc=%b, MemWrite=%b, ALUSrc=%b, ImmSrc=%b, RegWrite=%b", 
                $root.tb.dut.RISCVSingle.cs.PCSrc,
                $root.tb.dut.RISCVSingle.cs.ResultSrc,
                $root.tb.dut.RISCVSingle.cs.MemWrite,
                $root.tb.dut.RISCVSingle.cs.ALUSrc,
                $root.tb.dut.RISCVSingle.cs.ImmSrc,
                $root.tb.dut.RISCVSingle.cs.RegWrite);
            
            // [DATAPATH] DataPath signals
            $display("[DATAPATH] imm_i_raw=%0d, imm_s_raw=%0d, imm_b_raw=%0d, imm_j_raw=%0d, ImmExt=%0d", 
                    $root.tb.dut.RISCVSingle.DataPath_instance.imm_i_raw,
                    $root.tb.dut.RISCVSingle.DataPath_instance.imm_s_raw,
                    $root.tb.dut.RISCVSingle.DataPath_instance.imm_b_raw,
                    $root.tb.dut.RISCVSingle.DataPath_instance.imm_j_raw,
                    $root.tb.dut.RISCVSingle.DataPath_instance.ImmExt);

            // [DATAMEM] Data Memory Access
            if ($root.tb.dut.RISCVSingle.cs.MemWrite) begin
                $display("[DATAMEM] WRITE - Address: %0d, Data: %0d", 
                    $root.tb.dut.DataMemory.data_address,
                    $root.tb.dut.DataMemory.write_data);
            end else begin
                $display("[DATAMEM] READ - Address: %0d, Data: %0d", 
                    $root.tb.dut.DataMemory.data_address,
                    $root.tb.dut.DataMemory.read_data);
            end

            $display("[DATAMEM] Memory output data - Address: %0d, Data: %0d",
                    $root.tb.dut.DataMemory.data_address,
                    $root.tb.dut.DataMemory.read_data);
            
            $display("==========================================================\n");
        end
        
        // Check if PC is incrementing
        $display("=== Test Complete ===");
        $display("Final PC value: %0d", PC);
        if (PC > 0) begin
            $display("SUCCESS: PC is incrementing!");
        end else begin
            $display("FAILED: PC stuck at 0!");
        end
        
        $finish;
    end
    
endprogram
