# 🧠 RISC-Duo: A RISC-V Processor Implementation

Welcome to **RISC-Duo**, a SystemVerilog-based implementation of both **Single-Cycle** and **Pipelined** RISC-V processors.  
This project focuses on practicing architectural tradeoffs:
- ⏱️ Delay vs ⛓️ Area
- 🧼 Clean modular design
- ✅ Collaboration using Git

---

## 📁 Project Structure

```bash
RISC-Duo/
├── single_cycle/
│   ├── Core/               # Wraps Datapath & Controller
│   ├── DataPath/           # ALU, RegFile, PC, etc.
│   ├── ControlUnit/        # Main decoder & ALU control
│   ├── Memories/           # instr_mem, data_mem
│   ├── Utils/              # Mux, Adder, Shifter
│   ├── Include/            # Shared types_pkg.sv
│   ├── Top.sv              # Top-level module
│   ├── program.asm         # Input assembly file
│   ├── InstructionLoader.sv
│   └── inst.mem            # Machine code memory (auto-gen)
├── pipelined/              # Placeholder for pipeline version
├── .gitignore
└── README.md               # ← You're here
```

