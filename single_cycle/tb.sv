import types_pkg::*;
module tb;
    logic clk;
    logic reset;
    word_t PC;
    word_t ReadData;
    word_t Instr;

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 10ns period
    end

    always @(negedge clk) begin
        if (!reset) begin
            // [PC] Current Program Counter
            $display("[PC] Current PC: 0x%h", PC);
            
            // [INSTRMEM] Current Instruction
            $display("[INSTRMEM] Instruction: 0x%h", Instr);
            
            // [REG] Register File Information
            $display("[REG] RS1(x%0d)=0x%h, RS2(x%0d)=0x%h, RD(x%0d)=0x%h", 
                dut.RISCVSingle.DataPath_instance.rs1,
                dut.RISCVSingle.DataPath_instance.RD1,
                dut.RISCVSingle.DataPath_instance.rs2,
                dut.RISCVSingle.DataPath_instance.RD2,
                dut.RISCVSingle.DataPath_instance.rd,
                dut.RISCVSingle.DataPath_instance.Result);
            
            // [ALU] ALU Operation and Results
            case(dut.RISCVSingle.ALUControl)
                4'b0000: $display("[ALU] ADD: 0x%h + 0x%h = 0x%h, Zero=%b", 
                    dut.RISCVSingle.DataPath_instance.RD1,
                    dut.RISCVSingle.DataPath_instance.SrcB,
                    dut.RISCVSingle.DataPath_instance.ALUResult,
                    dut.RISCVSingle.DataPath_instance.Zero);
                4'b0001: $display("[ALU] SUB: 0x%h - 0x%h = 0x%h, Zero=%b", 
                    dut.RISCVSingle.DataPath_instance.RD1,
                    dut.RISCVSingle.DataPath_instance.SrcB,
                    dut.RISCVSingle.DataPath_instance.ALUResult,
                    dut.RISCVSingle.DataPath_instance.Zero);
                4'b0010: $display("[ALU] AND: 0x%h & 0x%h = 0x%h, Zero=%b", 
                    dut.RISCVSingle.DataPath_instance.RD1,
                    dut.RISCVSingle.DataPath_instance.SrcB,
                    dut.RISCVSingle.DataPath_instance.ALUResult,
                    dut.RISCVSingle.DataPath_instance.Zero);
                4'b0011: $display("[ALU] OR: 0x%h | 0x%h = 0x%h, Zero=%b", 
                    dut.RISCVSingle.DataPath_instance.RD1,
                    dut.RISCVSingle.DataPath_instance.SrcB,
                    dut.RISCVSingle.DataPath_instance.ALUResult,
                    dut.RISCVSingle.DataPath_instance.Zero);
                4'b0100: $display("[ALU] XOR: 0x%h ^ 0x%h = 0x%h, Zero=%b", 
                    dut.RISCVSingle.DataPath_instance.RD1,
                    dut.RISCVSingle.DataPath_instance.SrcB,
                    dut.RISCVSingle.DataPath_instance.ALUResult,
                    dut.RISCVSingle.DataPath_instance.Zero);
                4'b0101: $display("[ALU] SLL: 0x%h << 0x%h = 0x%h, Zero=%b", 
                    dut.RISCVSingle.DataPath_instance.RD1,
                    dut.RISCVSingle.DataPath_instance.SrcB,
                    dut.RISCVSingle.DataPath_instance.ALUResult,
                    dut.RISCVSingle.DataPath_instance.Zero);
                4'b0110: $display("[ALU] SRL: 0x%h >> 0x%h = 0x%h, Zero=%b", 
                    dut.RISCVSingle.DataPath_instance.RD1,
                    dut.RISCVSingle.DataPath_instance.SrcB,
                    dut.RISCVSingle.DataPath_instance.ALUResult,
                    dut.RISCVSingle.DataPath_instance.Zero);
                4'b0111: $display("[ALU] SRA: 0x%h >>> 0x%h = 0x%h, Zero=%b", 
                    dut.RISCVSingle.DataPath_instance.RD1,
                    dut.RISCVSingle.DataPath_instance.SrcB,
                    dut.RISCVSingle.DataPath_instance.ALUResult,
                    dut.RISCVSingle.DataPath_instance.Zero);
                4'b1000: $display("[ALU] SLT: 0x%h < 0x%h = 0x%h, Zero=%b", 
                    dut.RISCVSingle.DataPath_instance.RD1,
                    dut.RISCVSingle.DataPath_instance.SrcB,
                    dut.RISCVSingle.DataPath_instance.ALUResult,
                    dut.RISCVSingle.DataPath_instance.Zero);
                4'b1001: $display("[ALU] SLTU: 0x%h < 0x%h = 0x%h, Zero=%b", 
                    dut.RISCVSingle.DataPath_instance.RD1,
                    dut.RISCVSingle.DataPath_instance.SrcB,
                    dut.RISCVSingle.DataPath_instance.ALUResult,
                    dut.RISCVSingle.DataPath_instance.Zero);
                default: $display("[ALU] UNKNOWN: 0x%h ? 0x%h = 0x%h, Zero=%b", 
                    dut.RISCVSingle.DataPath_instance.RD1,
                    dut.RISCVSingle.DataPath_instance.SrcB,
                    dut.RISCVSingle.DataPath_instance.ALUResult,
                    dut.RISCVSingle.DataPath_instance.Zero);
            endcase
            
            // [CONTROLLER] Control Signals
            $display("[CONTROLLER] PCSrc=%b, ResultSrc=%b, MemWrite=%b, ALUSrc=%b, ImmSrc=%b, RegWrite=%b", 
                dut.RISCVSingle.cs.PCSrc,
                dut.RISCVSingle.cs.ResultSrc,
                dut.RISCVSingle.cs.MemWrite,
                dut.RISCVSingle.cs.ALUSrc,
                dut.RISCVSingle.cs.ImmSrc,
                dut.RISCVSingle.cs.RegWrite);
            
            // [DATAMEM] Data Memory Access
            if (dut.RISCVSingle.cs.MemWrite) begin
                $display("[DATAMEM] WRITE - Address: 0x%h, Data: 0x%h", 
                    dut.DataMemory.data_address,
                    dut.DataMemory.write_data);
            end else begin
                $display("[DATAMEM] READ - Address: 0x%h, Data: 0x%h", 
                    dut.DataMemory.data_address,
                    dut.DataMemory.read_data);
            end
            
            $display("==========================================================");
        end
    end
    
    // Reset and stimulus
    initial begin
        $display("=== Starting RISC-V Processor Test ===");
        
        // Initialize
        reset = 1;
        ReadData = 32'h0;
        
        // Release reset after a few cycles
        #20;
        reset = 0;
        $display("=== Reset Released - Starting Execution ===");
        
        // Let it run for several cycles
      repeat(80) begin
            @(posedge clk);
            $display("\n\n");
            
         end
        
        // Check if PC is incrementing
        $display("=== Test Complete ===");
        $display("Final PC value: 0x%h", PC);
        if (PC > 0) begin
            $display("SUCCESS: PC is incrementing!");
        end else begin
            $display("FAILED: PC stuck at 0!");
        end
        
        $finish;
    end
    
   
    // Instantiate the top module
    Top dut (
        .clk(clk),
        .reset(reset)
    );
    
    // Connect internal signals for monitoring
    assign PC = dut.PC;
    assign Instr = dut.Instr;
endmodule