/*
// `default_nettype none
package types_pkg;

    // =============================================================
    // Core Configuration
    // =============================================================
    parameter int XLEN              = 32;
    parameter int SHIFT_AMOUNT      = $clog2(XLEN);
    parameter int ADDR_WIDTH        = 9;
    parameter int MEM_SIZE          = 2 ** ADDR_WIDTH;
    parameter int REG_ADDR_WIDTH    = 5;
    parameter int REG_COUNT         = 2 ** REG_ADDR_WIDTH;  // 32 registers

    // =============================================================
    // Basic Typedefs
    // =============================================================
    typedef logic [XLEN-1:0]                word_t;
    typedef logic signed [XLEN-1:0]         signed_word_t;
    typedef logic [$clog2(REG_COUNT)-1:0]   reg_addr_t;
    typedef logic [ADDR_WIDTH-1:0]          address_t;

    // =============================================================
    // Pipeline Control Typedefs
    // =============================================================
    typedef logic                           enable_t;
    typedef logic                           reset_t;
    typedef logic [1:0]                     forward_sel_t;
    typedef logic [1:0]                     mux_sel_2_t;
    typedef logic                           mux_sel_1_t;

    // =============================================================
    // Instruction Bit Field Ranges (RV32I)
    // =============================================================
    localparam int OPCODE_MSB  = 6,  OPCODE_LSB  = 0;
    localparam int RD_MSB      = 11, RD_LSB      = 7;
    localparam int FUNCT3_MSB  = 14, FUNCT3_LSB  = 12;
    localparam int RS1_MSB     = 19, RS1_LSB     = 15;
    localparam int RS2_MSB     = 24, RS2_LSB     = 20;
    localparam int FUNCT7_MSB  = 31, FUNCT7_LSB  = 25;
    localparam int SIGNEXT_MSB = 31, SIGNEXT_LSB = 7;

    // =============================================================
    // Immediate Field Encodings (Before Sign-Extension)
    // =============================================================
    typedef logic [11:0] imm_i_raw_t;  // I-type: [31:20]
    typedef logic [11:0] imm_s_raw_t;  // S-type: [31:25 | 11:7]
    typedef logic [12:0] imm_b_raw_t;  // B-type: [31|7|30:25|11:8]
    typedef logic [20:0] imm_j_raw_t;  // J-type: [31|19:12|20|30:21]

    // I-type: imm[11:0] = instr[31:20]
    localparam int IMM_I_LSB = 20;
    localparam int IMM_I_MSB = 31;

    // S-type: imm[11:5] = instr[31:25], imm[4:0] = instr[11:7]
    localparam int IMM_S_HI_MSB = 31, IMM_S_HI_LSB = 25;
    localparam int IMM_S_LO_MSB = 11, IMM_S_LO_LSB = 7;

    // B-type: imm[12|10:5|4:1|11] = instr[31|30:25|11:8|7]
    localparam int IMM_B_12_BIT     = 31;
    localparam int IMM_B_11_BIT     = 7;
    localparam int IMM_B_10_5_MSB   = 30, IMM_B_10_5_LSB = 25;
    localparam int IMM_B_4_1_MSB    = 11, IMM_B_4_1_LSB  = 8;

    // J-type: imm[20|10:1|11|19:12] = instr[31|30:21|20|19:12]
    localparam int IMM_J_20_BIT     = 31;
    localparam int IMM_J_11_BIT     = 20;
    localparam int IMM_J_10_1_MSB   = 30, IMM_J_10_1_LSB = 21;
    localparam int IMM_J_19_12_MSB  = 19, IMM_J_19_12_LSB = 12;

    // =============================================================
    // Opcode & Function Field Enums
    // =============================================================

    // 7-bit Opcode
    typedef enum logic [6:0] {
        OP_I_TYPE_LOAD   = 7'b000_0011,
        OP_I_TYPE_ARITH  = 7'b001_0011,
        OP_S_TYPE        = 7'b010_0011,
        OP_R_TYPE        = 7'b011_0011,
        OP_B_TYPE        = 7'b110_0011,
        OP_JALR_TYPE     = 7'b110_0111,
        OP_JAL_TYPE      = 7'b110_1111,
        OP_RV64_TYPE     = 7'b011_1011
    } opcode_e;

    // 3-bit funct3 field
    typedef enum logic [2:0] {
        F3_ADD_SUB   = 3'b000,
        F3_SLL       = 3'b001,
        F3_SLT       = 3'b010,
        F3_SLTU      = 3'b011,
        F3_XOR       = 3'b100,
        F3_SRL_SRA   = 3'b101,
        F3_OR        = 3'b110,
        F3_AND       = 3'b111
    } funct3_e;

    // 7-bit funct7 field (just two used values)
    typedef enum logic [6:0] {
        FUNCT7_NORMAL = 7'b000_0000,  // ADD, SRL, etc.
        FUNCT7_ALT    = 7'b010_0000   // SUB, SRA, etc.
    } funct7_e;

    // =============================================================
    // ALU Control Enums
    // =============================================================

    // Specific ALU operations (output of alu_control)
    typedef enum logic [3:0] {
        ALU_ADD   = 4'b0000,
        ALU_SUB   = 4'b0001,
        ALU_AND   = 4'b0010,
        ALU_OR    = 4'b0011,
        ALU_XOR   = 4'b0100,
        ALU_SLL   = 4'b0101,
        ALU_SRL   = 4'b0110,
        ALU_SRA   = 4'b0111,
        ALU_SLT   = 4'b1000,
        ALU_SLTU  = 4'b1001
    } aluop_e;

    // Coarse ALUOp types (used between decoder and ALU control)
    typedef enum logic [1:0] {
        ALUOP_LUI         = 2'b00, // For load/store/imm (→ ADD)
        ALUOP_BRANCH      = 2'b01, // For branches (→ SUB)
        ALUOP_R_OR_I_TYPE = 2'b10, // Use funct3/funct7
        ALUOP_OTHER       = 2'b11  // Reserved
    } aluop_type_e;

    // =============================================================
    // Control Signals & Multiplexers
    // =============================================================

    // MUX: result from ALU, MEM, JUMP
    typedef enum logic [1:0] {
        RESULT_ALU   = 2'b00,
        RESULT_MEM   = 2'b01,
        RESULT_JUMP  = 2'b10
    } resultsrc_e;

    // Immediate format selector
    typedef enum logic [1:0] {
        IMMSRC_I = 2'b00,
        IMMSRC_S = 2'b01,
        IMMSRC_B = 2'b10,
        IMMSRC_J = 2'b11
    } immsrc_e;

    // Forwarding unit selectors
    typedef enum logic [1:0] {
        FORWARD_NONE = 2'b00,  // No forwarding
        FORWARD_WB   = 2'b01,  // Forward from writeback stage
        FORWARD_MEM  = 2'b10   // Forward from memory stage
    } forward_e;

    // PC source selector
    typedef enum logic [1:0] {
        PC_PLUS4  = 2'b00,     // PC + 4
        PC_TARGET = 2'b01      // Branch/Jump target
    } pcsrc_e;

    // =============================================================
    // Structs for Cleaner Interfacing
    // =============================================================

    typedef struct packed {
        opcode_e     op;
        reg_addr_t   rd;
        reg_addr_t   rs1;
        reg_addr_t   rs2;
        funct3_e     funct3;
        funct7_e     funct7;
        imm_i_raw_t  imm_i_raw;
        imm_s_raw_t  imm_s_raw;
        imm_b_raw_t  imm_b_raw;
        imm_j_raw_t  imm_j_raw;
    } decoded_instr_t;

    typedef struct packed {
        logic [1:0]  PCSrc;
        resultsrc_e  ResultSrc;
        logic        MemWrite;
        logic        ALUSrc;
        immsrc_e     ImmSrc;
        logic        RegWrite;
        logic        Jump;
        logic        Branch;
    } control_signals_t;

    // =============================================================
    // Pipeline Stage Structures
    // =============================================================

    typedef struct packed {
        word_t PCF;    
        word_t PCNextF; 
        word_t InstrF;
        word_t PCPlus4F;
    } fetch_stage_t;

    typedef struct packed {
        word_t       InstrD;
        word_t       PCD;
        reg_addr_t   RdD;
        word_t       RD1D;
        word_t       RD2D;
        word_t       ImmExtD;
        word_t       PCPlus4D;
        aluop_e      ALUControlD;
        logic        RegWriteD;
        logic        ALUSrcD;
        logic [1:0]  ImmSrcD;
        logic [1:0]  ResultSrcD;
        logic        MemWriteD;
        logic        JumpD;
        logic        BranchD;
    } decode_stage_t;

    typedef struct packed {
        logic        RegWriteE;
        logic [1:0]  ResultSrcE;
        logic        MemWriteE;
        logic        ALUSrcE;
        logic        JumpE;
        logic        BranchE;
        logic        ZeroE;
        aluop_e      ALUControlE;
        word_t       RD1E;
        word_t       RD2E;
        word_t       PCE;
        word_t       ImmExtE;
        word_t       PCPlus4E;
        word_t       PCTargetE;
        word_t       SrcAE;
        word_t       SrcBE;
        word_t       ALUResultE;
        word_t       WriteDataE;
        reg_addr_t   RdE;
        reg_addr_t   Rs1E;
        reg_addr_t   Rs2E;
    } execute_stage_t;

    typedef struct packed {
        word_t       ALUResultM;
        word_t       WriteDataM;
        word_t       PCPlus4M;
        word_t       ReadDataM;
        logic [1:0]  ResultSrcM;
        logic        MemWriteM;
        logic        RegWriteM;
        reg_addr_t   RdM;
    } memory_stage_t;

    typedef struct packed {
        word_t       ALUResultW;
        word_t       ReadDataW;
        word_t       PCPlus4W;
        word_t       ResultW;
        reg_addr_t   RdW;
        logic [1:0]  ResultSrcW;
        logic        RegWriteW;
    } writeback_stage_t;

    // =============================================================
    // Hazard Detection and Forwarding Structures
    // =============================================================

    typedef struct packed {
        logic        stall_f;
        logic        stall_d;
        logic        flush_d;
        logic        flush_e;
    } hazard_control_t;

    typedef struct packed {
        forward_sel_t forward_a_e;
        forward_sel_t forward_b_e;
        logic         result_src_e0;
        logic         pcsrc_e;
    } forwarding_control_t;

    // =============================================================
    // Interface Structures for Better Organization
    // =============================================================

    typedef struct packed {
        reg_addr_t   rs1_d;
        reg_addr_t   rs2_d;
        reg_addr_t   rd_e;
        reg_addr_t   rs1_e;
        reg_addr_t   rs2_e;
        reg_addr_t   rd_m;
        reg_addr_t   rd_w;
    } register_addresses_t;

    typedef struct packed {
        logic        reg_write_m;
        logic        reg_write_w;
        logic        result_src_e0;
        logic        pcsrc_e;
    } control_outputs_t;

endpackage

import types_pkg::*;
module PipelinePath (
    input  logic                clk,
    input  logic                reset,

    input  hazard_control_t     hazard_ctrl,
    input  forwarding_control_t forward_ctrl,
    
    output register_addresses_t reg_addrs,                          // Register Address Outputs (for hazard detection)
    output control_outputs_t    ctrl_outputs
);

    // =============================================================
    // Pipeline Stage Registers
    // =============================================================
    fetch_stage_t       F;  // Fetch stage signals
    decode_stage_t      D;  // Decode stage signals  
    execute_stage_t     E;  // Execute stage signals
    memory_stage_t      M;  // Memory stage signals
    writeback_stage_t   W;  // Writeback stage signals
    
    // =============================================================
    // Decode Stage Support Signals
    // =============================================================
    decoded_instr_t     decoded_instr;
    control_signals_t   control_signals;
    
    // =============================================================
    // Internal Control Signals
    // =============================================================
    logic enable_f, enable_d;
    logic reset_d, reset_e;
    
    // Generate internal control signals
    assign enable_f = ~ hazard_ctrl.stall_f;
    assign enable_d = ~ hazard_ctrl.stall_d;
    assign reset_d  =   hazard_ctrl.flush_d;
    assign reset_e  =   hazard_ctrl.flush_e;
    
    // =============================================================
    // Output Assignments
    // =============================================================
    
    // Control outputs
    assign ctrl_outputs.pcsrc_e       = (E.BranchE & E.ZeroE) | E.JumpE;
    assign ctrl_outputs.result_src_e0 = E.ResultSrcE[0];
    assign ctrl_outputs.reg_write_m   = M.RegWriteM;
    assign ctrl_outputs.reg_write_w   = W.RegWriteW;
    
    // Register address outputs for hazard detection
    assign reg_addrs.rs1_d = decoded_instr.rs1;
    assign reg_addrs.rs2_d = decoded_instr.rs2;
    assign reg_addrs.rd_e  = E.RdE;
    assign reg_addrs.rs1_e = E.Rs1E;
    assign reg_addrs.rs2_e = E.Rs2E;
    assign reg_addrs.rd_m  = M.RdM;
    assign reg_addrs.rd_w  = W.RdW;

    // =============================================================
    // FETCH STAGE
    // =============================================================
    
    pc PC_register (
        .clk    (clk),
        .reset  (reset),
        .enable (enable_f),
        .PCNext (F.PCNextF),
        .pc     (F.PCF)
    );
    
    adder pc_plus4_adder (
        .a   (F.PCF),
        .b   (32'd4),
        .sum (F.PCPlus4F)
    );
    
    instr_mem instruction_memory (
        .clk         (clk),
        .address     (F.PCF),
        .instruction (F.InstrF)
    );
    
    // PC Source Multiplexer (PC+4 vs Branch/Jump target)
    word_t pc_mux_inputs[2];
    assign pc_mux_inputs[0] = F.PCPlus4F;      // Normal: PC + 4
    assign pc_mux_inputs[1] = E.PCTargetE;     // Branch/Jump target
    
    mux #(.SEL_WIDTH(1)) pc_source_mux (
        .in  (pc_mux_inputs),
        .sel (ctrl_outputs.pcsrc_e),
        .out (F.PCNextF)
    );

    // =============================================================
    // FETCH → DECODE PIPELINE REGISTERS
    // =============================================================
    
    pipo #(.WIDTH(XLEN))    fd_pc           (.clk(clk), .rst(reset_d), .enable(enable_d), .in(F.PCF),       .out(D.PCD));
    pipo #(.WIDTH(XLEN))    fd_pc_plus4     (.clk(clk), .rst(reset_d), .enable(enable_d), .in(F.PCPlus4F),  .out(D.PCPlus4D));
    pipo #(.WIDTH(XLEN))    fd_instruction  (.clk(clk), .rst(reset_d), .enable(enable_d), .in(F.InstrF),    .out(D.InstrD));

    // =============================================================
    // DECODE STAGE
    // =============================================================
    

    decoder instruction_decoder (
        .Instr          (D.InstrD),
        .decoded_instr  (decoded_instr)
    );
    

    Controller main_controller (
        .Zero           (E.ZeroE),                                   // From execute stage for branch decisions
        .funct3         (decoded_instr.funct3),
        .funct7         (decoded_instr.funct7),
        .op             (decoded_instr.op),
        .control_signals(control_signals),
        .ALUControl     (D.ALUControlD)
    );
    
    // Assign control signals to decode stage
    assign D.RegWriteD  = control_signals.RegWrite;
    assign D.ResultSrcD = control_signals.ResultSrc;
    assign D.MemWriteD  = control_signals.MemWrite;
    assign D.ALUSrcD    = control_signals.ALUSrc;
    assign D.ImmSrcD    = control_signals.ImmSrc;
    assign D.JumpD      = control_signals.Jump;
    assign D.BranchD    = control_signals.Branch;
    assign D.RdD        = decoded_instr.rd;
    
   
    regFile register_file (
        .clk         (clk),
        .read_reg1   (decoded_instr.rs1),
        .read_reg2   (decoded_instr.rs2),
        .write_reg   (W.RdW),
        .write_data  (W.ResultW),
        .writeEnable (W.RegWriteW),
        .read_data1  (D.RD1D),
        .read_data2  (D.RD2D)
    );
    
    // Immediate Extension Logic
    word_t imm_mux_inputs[4];
    assign imm_mux_inputs[IMMSRC_I] = {{20{decoded_instr.imm_i_raw[11]}}, decoded_instr.imm_i_raw};
    assign imm_mux_inputs[IMMSRC_S] = {{20{decoded_instr.imm_s_raw[11]}}, decoded_instr.imm_s_raw};
    assign imm_mux_inputs[IMMSRC_B] = {{19{decoded_instr.imm_b_raw[12]}}, decoded_instr.imm_b_raw};
    assign imm_mux_inputs[IMMSRC_J] = {{11{decoded_instr.imm_j_raw[20]}}, decoded_instr.imm_j_raw};
    
    mux #(.SEL_WIDTH(2)) immediate_mux (
        .in  (imm_mux_inputs),
        .sel (D.ImmSrcD),
        .out (D.ImmExtD)
    );

    // =============================================================
    // DECODE → EXECUTE PIPELINE REGISTERS
    // =============================================================
    
    // Data Path Registers
    pipo #(.WIDTH(XLEN))            de_rd1          (.clk(clk), .rst(reset_e), .enable(1'b1), .in(D.RD1D),             .out(E.RD1E));
    pipo #(.WIDTH(XLEN))            de_rd2          (.clk(clk), .rst(reset_e), .enable(1'b1), .in(D.RD2D),             .out(E.RD2E));
    pipo #(.WIDTH(XLEN))            de_pc           (.clk(clk), .rst(reset_e), .enable(1'b1), .in(D.PCD),              .out(E.PCE));
    pipo #(.WIDTH(XLEN))            de_imm_ext      (.clk(clk), .rst(reset_e), .enable(1'b1), .in(D.ImmExtD),          .out(E.ImmExtE));
    pipo #(.WIDTH(XLEN))            de_pc_plus4     (.clk(clk), .rst(reset_e), .enable(1'b1), .in(D.PCPlus4D),         .out(E.PCPlus4E));
    
    // Register Address Registers
    pipo #(.WIDTH(REG_ADDR_WIDTH))  de_rs1          (.clk(clk), .rst(reset_e), .enable(1'b1), .in(decoded_instr.rs1),  .out(E.Rs1E));
    pipo #(.WIDTH(REG_ADDR_WIDTH))  de_rs2          (.clk(clk), .rst(reset_e), .enable(1'b1), .in(decoded_instr.rs2),  .out(E.Rs2E));
    pipo #(.WIDTH(REG_ADDR_WIDTH))  de_rd           (.clk(clk), .rst(reset_e), .enable(1'b1), .in(D.RdD),              .out(E.RdE));
    
    // Control Signal Registers
    pipo #(.WIDTH(1))               de_reg_write    (.clk(clk), .rst(reset_e), .enable(1'b1), .in(D.RegWriteD),        .out(E.RegWriteE));
    pipo #(.WIDTH(2))               de_result_src   (.clk(clk), .rst(reset_e), .enable(1'b1), .in(D.ResultSrcD),       .out(E.ResultSrcE));
    pipo #(.WIDTH(1))               de_mem_write    (.clk(clk), .rst(reset_e), .enable(1'b1), .in(D.MemWriteD),        .out(E.MemWriteE));
    pipo #(.WIDTH(1))               de_alu_src      (.clk(clk), .rst(reset_e), .enable(1'b1), .in(D.ALUSrcD),          .out(E.ALUSrcE));
    pipo #(.WIDTH(1))               de_branch       (.clk(clk), .rst(reset_e), .enable(1'b1), .in(D.BranchD),          .out(E.BranchE));
    pipo #(.WIDTH(1))               de_jump         (.clk(clk), .rst(reset_e), .enable(1'b1), .in(D.JumpD),            .out(E.JumpE));
    pipo #(.WIDTH(4))               de_alu_control  (.clk(clk), .rst(reset_e), .enable(1'b1), .in(D.ALUControlD),      .out(logic'(E.ALUControlE)));

    // =============================================================
    // EXECUTE STAGE
    // =============================================================
    
    // Forwarding Logic for ALU Source A
    word_t src_a_mux_inputs[4];
    assign src_a_mux_inputs[FORWARD_NONE] = E.RD1E;           // No forwarding
    assign src_a_mux_inputs[FORWARD_WB]   = W.ResultW;        // Forward from writeback
    assign src_a_mux_inputs[FORWARD_MEM]  = M.ALUResultM;     // Forward from memory
    assign src_a_mux_inputs[3]            = 32'b0;            // Unused
    
    mux #(.SEL_WIDTH(2)) src_a_forward_mux (
        .in  (src_a_mux_inputs),
        .sel (forward_ctrl.forward_a_e),
        .out (E.SrcAE)
    );
    
    // Forwarding Logic for Write Data (used for ALU Source B and memory write data)
    word_t write_data_mux_inputs[4];
    assign write_data_mux_inputs[FORWARD_NONE] = E.RD2E;     
    assign write_data_mux_inputs[FORWARD_WB]   = W.ResultW;   
    assign write_data_mux_inputs[FORWARD_MEM]  = M.ALUResultM;
    assign write_data_mux_inputs[3]            = 32'b0;     
    
    mux #(.SEL_WIDTH(2)) write_data_forward_mux (
        .in  (write_data_mux_inputs),
        .sel (forward_ctrl.forward_b_e),
        .out (E.WriteDataE)
    );
    
    // ALU Source B Multiplexer (Register vs Immediate)
    word_t alu_src_b_inputs[2];
    assign alu_src_b_inputs[0] = E.WriteDataE;  // Use register data (with forwarding)
    assign alu_src_b_inputs[1] = E.ImmExtE;     // Use immediate
    
    mux #(.SEL_WIDTH(1)) alu_src_b_mux (
        .in  (alu_src_b_inputs),
        .sel (E.ALUSrcE),
        .out (E.SrcBE)
    );
    
    alu arithmetic_logic_unit (
        .a       (E.SrcAE),
        .b       (E.SrcBE),
        .control (E.ALUControlE),
        .result  (E.ALUResultE),
        .zero    (E.ZeroE)
    );
    
    // PC Target Calculation (for branches and jumps)
    adder pc_target_adder (
        .a   (E.PCE),
        .b   (E.ImmExtE),
        .sum (E.PCTargetE)
    );

    // =============================================================
    // EXECUTE → MEMORY PIPELINE REGISTERS
    // =============================================================
    
    pipo #(.WIDTH(1))               em_reg_write    (.clk(clk), .rst(1'b0), .enable(1'b1), .in(E.RegWriteE),  .out(M.RegWriteM));
    pipo #(.WIDTH(2))               em_result_src   (.clk(clk), .rst(1'b0), .enable(1'b1), .in(E.ResultSrcE), .out(M.ResultSrcM));
    pipo #(.WIDTH(1))               em_mem_write    (.clk(clk), .rst(1'b0), .enable(1'b1), .in(E.MemWriteE),  .out(M.MemWriteM));
    pipo #(.WIDTH(XLEN))            em_alu_result   (.clk(clk), .rst(1'b0), .enable(1'b1), .in(E.ALUResultE), .out(M.ALUResultM));
    pipo #(.WIDTH(XLEN))            em_write_data   (.clk(clk), .rst(1'b0), .enable(1'b1), .in(E.WriteDataE), .out(M.WriteDataM));
    pipo #(.WIDTH(REG_ADDR_WIDTH))  em_rd           (.clk(clk), .rst(1'b0), .enable(1'b1), .in(E.RdE),        .out(M.RdM));
    pipo #(.WIDTH(XLEN))            em_pc_plus4     (.clk(clk), .rst(1'b0), .enable(1'b1), .in(E.PCPlus4E),   .out(M.PCPlus4M));

    // =============================================================
    // MEMORY STAGE
    // =============================================================
    
    data_mem data_memory (
        .clk          (clk),
        .write_enable (M.MemWriteM),
        .data_address (M.ALUResultM),
        .write_data   (M.WriteDataM),
        .read_data    (M.ReadDataM)
    );

    // =============================================================
    // MEMORY → WRITEBACK PIPELINE REGISTERS
    // =============================================================
    
    pipo #(.WIDTH(1))               mw_reg_write    (.clk(clk), .rst(1'b0), .enable(1'b1), .in(M.RegWriteM),  .out(W.RegWriteW));
    pipo #(.WIDTH(2))               mw_result_src   (.clk(clk), .rst(1'b0), .enable(1'b1), .in(M.ResultSrcM), .out(W.ResultSrcW));
    pipo #(.WIDTH(XLEN))            mw_alu_result   (.clk(clk), .rst(1'b0), .enable(1'b1), .in(M.ALUResultM), .out(W.ALUResultW));
    pipo #(.WIDTH(XLEN))            mw_read_data    (.clk(clk), .rst(1'b0), .enable(1'b1), .in(M.ReadDataM),  .out(W.ReadDataW));
    pipo #(.WIDTH(REG_ADDR_WIDTH))  mw_rd           (.clk(clk), .rst(1'b0), .enable(1'b1), .in(M.RdM),        .out(W.RdW));
    pipo #(.WIDTH(XLEN))            mw_pc_plus4     (.clk(clk), .rst(1'b0), .enable(1'b1), .in(M.PCPlus4M),   .out(W.PCPlus4W));

    // =============================================================
    // WRITEBACK STAGE
    // =============================================================
    
    // Result Source Multiplexer
    word_t result_mux_inputs[4];
    assign result_mux_inputs[RESULT_ALU]  = W.ALUResultW;    // ALU result
    assign result_mux_inputs[RESULT_MEM]  = W.ReadDataW;     // Memory read data
    assign result_mux_inputs[RESULT_JUMP] = W.PCPlus4W;      // PC+4 for JAL/JALR
    
    mux #(.SEL_WIDTH(2)) result_source_mux (
        .in  (result_mux_inputs),
        .sel (W.ResultSrcW),
        .out (W.ResultW)
    );

endmodule


*/