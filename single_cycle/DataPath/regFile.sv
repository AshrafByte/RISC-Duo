import types_pkg::*;
// parameter XLEN = 32;
module regFile (
    // input logic clk,             // not needed in single cycle
    input logic [4:0] read_reg1,    // rs
    input logic [4:0] read_reg2,    // rt
    input logic [4:0] write_reg,    // rd or rt
    input logic [31:0] write_data,  //din
    input logic writeEnable,        //we
    output logic [31:0] read_data1,
    output logic [31:0] read_data2
);

    reg [XLEN:0] registers [31:0];

    // Write logic
    always @(*) begin
        if (writeEnable && write_reg != 5'b0) begin
            registers[write_reg] = write_data;
        end
        else if (!writeEnable) begin
            read_data1 = registers[read_reg1];
            read_data2 = registers[read_reg2];
        end
    end

endmodule