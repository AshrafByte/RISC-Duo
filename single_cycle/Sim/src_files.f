// ./Include:
../Include/types_pkg.sv

// ./Controller:
../Controller/alu_decoder.sv
../Controller/Controller.sv
../Controller/main_decoder.sv

// ./Core:
../Core/Core.sv
../Core/decoder.sv

// ./DataPath:
../DataPath/alu.sv
../DataPath/Datapath.sv
../DataPath/pc.sv
../DataPath/regFile.sv

// ./Memories:
../Memories/data_mem.sv
../Memories/instr_mem.sv

// ./Utils:
../Utils/adder.sv
../Utils/left_shifter.sv
../Utils/mux.sv
#../Utils/sign_ext.sv
#../Utils/zero_ext.sv
../Utils/ext.sv

../InstructionLoader.sv
../testbench.sv
../tb.sv
../test_program.sv
../Top.sv
