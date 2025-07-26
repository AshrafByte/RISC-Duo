vlog -f src_files.f

vsim -voptargs=+acc work.testbench -classdebug

add wave *
add wave dut.RISCVPipeline.DataMemory.data_memory
add wave dut.RISCVPipeline.InstructionMemory.instruction_memory
add wave dut.RISCVPipeline.RegisterFile.registers
add wave -r *

# run -all
