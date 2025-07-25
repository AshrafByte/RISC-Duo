vlog -f src_files.f

vsim -voptargs=+acc work.tb -classdebug

add wave *
add wave dut.DataMemory.data_memory
add wave dut.InstructionMemory.instruction_memory
add wave dut.RISCVSingle.DataPath_instance.RegisterFile.registers
add wave -r *

# run -all
