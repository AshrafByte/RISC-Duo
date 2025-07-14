# RISC-Duo

A modular, from-scratch implementation of the **RISC-V** processor architecture in **SystemVerilog**.  
This project is both a design and learning exercise focused on two key hardware goals:

- **Minimizing area** via a clean **single-cycle CPU design**
- **Minimizing delay** via a **pipelined implementation**

---

## 🎯 Project Focus

This project isn't just about functionality — it's also about learning to **optimize hardware designs**.  
We explore trade-offs between:

- Area vs. delay
- Simplicity vs. performance
- Control complexity vs. datapath reuse

---

## 🧱 Directory Structure

```bash
single_cycle/
├── DataPath/            # ALU, Register File, PC logic, etc.
├── ControlUnit/         # Main Decoder, ALU Control, Control signal logic
├── Memories/            # Instruction Memory, Data Memory
├── top.sv               # Top-level integration
├── program.asm          # RISC-V program (human-readable)
├── InstructionLoader.sv # Converts asm to machine code
└── inst.mem             # Machine code to load into instr_mem
```

```bash
main/               ← Stable, tested code
develop/            ← Working development state
feature/datapath-X/ ← Submodules of datapath (e.g., ALU, PC, Register File)
feature/control-X/  ← Control logic modules
feature/memories/   ← Data & instruction memory
```
