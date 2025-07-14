# 🛠️ RISC-Duo Team Workflow Guide

This guide will help you collaborate on the **RISC-V processor project** using Git, **without any hooks or setup scripts**. Everything is **manual and beginner-friendly**.

---
## 📦 0. Naming Convention for Files
We follow a naming rule to keep the project organized:

Files that start with a capital letter (e.g., Datapath.sv, Core.sv) are top-level modules.
These modules typically instantiate smaller submodules inside them.

✅ Datapath.sv → contains instances of alu.sv, reg_file.sv, mux.sv, etc.

✅ Controller.sv → wraps main_decoder.sv and alu_control.sv

✅ Core.sv → integrates Datapath.sv and Controller.sv

🔽 Submodules use lowercase names (e.g., alu.sv, mux.sv, reg_file.sv) and are focused on one function only.

## 📦 1. Clone the Repository (First Time Only)

Open Git Bash or VS Code terminal and run:

```bash
git clone https://github.com/AshrafByte/RISC-Duo.git
cd RISC-Duo
```

---


### 🌿 2. Always Work From the `develop` Branch (When Needed)

Before starting new work, you **may** want to bring in updates from the `develop` branch.
But merging the full branch isn’t always needed — **only do it if you actually need files or changes added in `develop`.**

#### ✅ Option A: You need all updates from `develop`

```bash
git checkout develop
git pull

git checkout feature-YourBranch
git merge develop
```

> ⚠️ This brings in everything from `develop`. **Be careful** — it might cause conflicts if you don't really need all updates.

---

#### 🔍 Option B: You only need a **specific file or folder**

You can bring only what you need:

```bash
# From your feature branch
git checkout feature-YourBranch

# Bring a file (e.g., Top.sv) from develop
git checkout develop -- single_cycle/Core/Top.sv

# Or bring a whole folder (e.g., Utils)
git checkout develop -- single_cycle/Utils
```

After doing this:

```bash
git add .
git commit -m "chore: bring Top.sv from develop"
```

> ⚠️ This avoids unnecessary merges and lets you work only with what your feature needs.

---


## 🏷️ 3. Create a Feature Branch

Each teammate should use **only one feature branch** depending on their task.

| Task             | Use This Branch      |
| ---------------- | -------------------- |
| DataPath Modules | `feature-Datapath`   |
| Control Logic    | `feature-Controller` |
| Memories         | `feature-Memories`   |
| Core Integration | `feature-Core`       |

To create your feature branch:

```bash
git checkout -b feature-YourBranchName
```

Or switch to it if it already exists:

```bash
git checkout feature-YourBranchName
git pull
```

Example:

```bash
git checkout -b feature-Datapath
```

<img width="442" height="553" alt="image" src="https://github.com/user-attachments/assets/b6e12b6f-159f-4e3f-b34c-2bbc0870df69" />


---

## 📄 4. Create New `.sv` Files Manually

You can create files via terminal or your editor:

```bash
touch single_cycle/DataPath/alu.sv
```

Or just right-click and create a file in VS Code.

---

## 📌 5. Add Required Header Lines in Every `.sv` File

At the top of **every new SystemVerilog file**, you **must** manually add:

```systemverilog
`default_nettype none
import types_pkg::*;
```

These lines are **not added automatically** anymore — they are required for correctness.

---

## 💾 6. Stage and Commit Your Changes

```bash
git add .
git commit -m "feat: add ALU module"
```

---

## ⬆️ 7. Push Your Feature Branch to GitHub

```bash
git push -u origin feature-YourBranchName
```

Example:

```bash
git push -u origin feature-Datapath
```

---

## 🔁 8. Create a Pull Request (PR)

Go to your repo on GitHub. You'll see a button:

> **"Compare & pull request"**

Do this:
* Base branch → `develop`
* Title → Short description like: `feat: Add ALU module`
* Description → Mention what you worked on
* Click **Create pull request**

---

## 🔄 9. Sync Your Branch (Avoid Conflicts)

Do this **every few days**:

```bash
git checkout develop
git pull
git checkout feature-YourBranchName
git merge develop
```

---

## 🧹 10. Clean Up After Merge

Once your PR is merged, you can delete your local branch:

```bash
git branch -d feature-YourBranchName
```

---

## ✅ Final Summary

| Action                  | Command or Tool                       |
| ----------------------- | ------------------------------------- |
| Clone repo              | `git clone ...`                       |
| Switch to develop       | `git checkout develop`                |
| Create a feature branch | `git checkout -b feature-XYZ`         |
| Add `.sv` file manually | VS Code or `touch`                    |
| Insert required header  | Add 2 lines manually in each file     |
| Commit & push           | `git add . && git commit && git push` |
| Create Pull Request     | On GitHub GUI                         |
| Keep branch updated     | `git merge develop` regularly         |

---

**💡 Pro Tips:**
- Always pull the latest changes before starting work
- Write clear commit messages using conventional commits format
- Test your code before creating a pull request
- Keep your feature branches focused on a single task
- Communicate with your team about any major changes

---

**🚨 Important Reminders:**
- Never work directly on the `main` or `develop` branch
- Always add the required header lines to `.sv` files
- Regularly sync your branch to avoid merge conflicts
- Delete merged branches to keep your workspace clean

---
