// `default_nettype none
import types_pkg::*;

module regFile (
    input  logic        clk,          // Add clock input
    input  reg_addr_t   read_reg1,    // rs1
    input  reg_addr_t   read_reg2,    // rs2
    input  reg_addr_t   write_reg,    // rd
    input  word_t       write_data,   // data to write
    input  logic        writeEnable,  // write enable
    output word_t       read_data1,   // rs1 value
    output word_t       read_data2    // rs2 value
);

    word_t registers [REG_COUNT];

    // Combinational read (always returns current register value)
    assign read_data1 = (read_reg1 == 5'd0) ? '0 : registers[read_reg1];
    assign read_data2 = (read_reg2 == 5'd0) ? '0 : registers[read_reg2];

    // Sequential write (single driver)
    always_ff @(posedge clk) begin
        if (writeEnable && write_reg != 5'd0)
            registers[write_reg] <= write_data;
    end

endmodule
