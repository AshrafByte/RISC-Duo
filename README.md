# [![SystemVerilog](https://img.shields.io/badge/Language-SystemVerilog-blue.svg)](https://en.wikipedia.org/wiki/SystemVerilog)

# RISC-Duo: A RISC-V Processor Implementation

RISC-Duo is a SystemVerilog implementation of a RISC-V processor in two architectural styles:

- **Single-Cycle**: optimized for simplicity, modularity, and area awareness
- **Pipelined**: planned/performance-oriented version (work in progress)

This repository is mainly a learning-focused design, emphasizing clean structure, readability, and a realistic CPU datapath/control split.

---

## Project Structure

```bash
RISC-Duo/
├── single_cycle/
│   ├── Core/               # Top-level CPU core wrapper (datapath + controller)
│   ├── DataPath/           # PC, RegFile, ALU, immediate generation, etc.
│   ├── ControlUnit/        # Main decoder + ALU control logic
│   ├── Memories/           # Instruction/Data memories
│   ├── Utils/              # Small reusable blocks (Mux, Adders, Shifters, ...)
│   ├── Include/            # Shared packages / common types (types_pkg.sv)
│   ├── Top.sv              # Integration top (CPU + memories)
│   ├── program.asm         # Input assembly file
│   ├── InstructionLoader.sv
│   └── inst.mem            # Machine code memory image (auto-generated)
├── pipelined/              # Placeholder for pipeline version
└── README.md
```

---

# Single-Cycle RISC-V (Documentation)

The **single_cycle** implementation follows the classic single-cycle CPU model: **each instruction completes in one clock cycle**. This is not timing-optimal for high frequencies, but it is excellent for:

- clear datapath visibility
- control-signal correctness
- ISA bring-up and verification
- modular design practice

## Instruction Format Coverage

The design is structured around the RV32I base ISA style (32-bit, integer-only), using the common instruction format breakdown:

- **R-type** (register-register ALU ops)
- **I-type** (immediates, loads, JALR)
- **S-type** (stores)
- **B-type** (branches)
- **U-type** (LUI/AUIPC)
- **J-type** (JAL)

(Exact implemented set depends on the decoder/control tables in `single_cycle/ControlUnit/`.)

---

## High-Level Data Flow (One Instruction / One Cycle)

At every rising clock edge, the processor commits results for the current instruction. Conceptually the cycle is:

1. **Fetch**: PC reads instruction from instruction memory
2. **Decode**: opcode/funct fields are decoded and the controller generates control signals
3. **Register Read**: source registers `rs1`/`rs2` are read from the register file
4. **Execute**: ALU computes arithmetic/logical result or branch comparison
5. **Memory Access**: loads/stores access data memory (when required)
6. **Write-Back**: selected result is written into destination register `rd`
7. **Next PC**: PC is updated to `PC+4` or branch/jump target

Because everything completes in a single cycle, the critical path includes:

**instruction fetch → decode → execute → memory (optional) → write-back → PC update**

---

## Module Responsibilities (`single_cycle/`)

### 1) `Core/` — CPU Core Wrapper

Contains the main wrapper that connects the **Controller** and **Datapath**, exposing a clean interface to memories.

Typically responsible for:

- instantiating datapath + control unit
- passing instruction fields to the controller
- wiring control signals into datapath muxes / enables
- collecting status signals (e.g., ALU zero / branch compare) back into control

### 2) `DataPath/` — The Hardware Datapath

Implements the execution hardware and all major state elements:

- **PC** register and next-PC selection logic
- **Instruction field extraction** (rd/rs1/rs2/funct3/funct7/immediate)
- **Register File** (two reads, one write)
- **Immediate generation** for I/S/B/U/J formats
- **ALU** and ALU input multiplexers
- **Write-back mux** (ALU result vs load data vs PC+4, depending on instruction)
- **Branch/jump target generation**

The datapath is arranged so that the controller selects between well-defined datapath options via mux selects and enables, rather than embedding “instruction knowledge” inside datapath modules.

### 3) `ControlUnit/` — Main Decoder + ALU Control

This is the control plane of the single-cycle CPU. It converts instruction fields into control signals such as:

- `RegWrite` — enable write-back to register file
- `MemRead` / `MemWrite` — data memory control
- `ALUSrc` — choose ALU operand2 (register vs immediate)
- `ResultSrc` — select write-back source (ALU/memory/PC+4)
- `Branch` / `Jump` — control PC redirection
- `ALUControl` — ALU operation derived from opcode + funct fields

Most single-cycle controllers are split into:

- **Main decoder**: primarily opcode-based
- **ALU control**: refines ALU behavior using funct3/funct7

### 4) `Memories/` — Instruction and Data Memory

Provides memory modules used by the top integration.

Common expectations:

- instruction memory is read-only during execution
- data memory supports read/write operations controlled by load/store instructions

### 5) `Utils/` — Small Reusable Blocks

Reusable combinational modules used across the design, such as:

- multiplexers
- adders
- shifters
- sign/zero extension helpers

### 6) `Include/` — Shared Types / Packages

Holds shared definitions (e.g., `types_pkg.sv`) to keep signal widths, enums, and constants consistent across the project.

---

## Notes on Program Loading

- `program.asm` is the human-readable assembly input.
- `InstructionLoader.sv` and `inst.mem` support converting/feeding program bytes into the instruction memory model (workflow depends on your loader flow).

