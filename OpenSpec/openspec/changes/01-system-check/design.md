# Design – System Check

## Numbering Rule

All OpenSpec change directories must follow the **two‑digit numeric prefix** naming convention (`<NN>-<short-name>`). For a change like `01-system-check`, the associated artifacts must be placed inside the same directory and follow the same naming pattern:

- `README.md` – overview and usage instructions.
- `design.md` – this technical design document (including the numbering rule itself).
- `proposal.md` – detailed description of the change, goals, and verification plan.
- `tasks.md` – checklist of implementation steps.

### System‑Setup Overview

The purpose of this change is to verify that the development environment is ready for the project:

1. **OpenSpec CLI** – installed, builds without errors, and reports the correct version.
2. **HyperFrame framework** – required packages are present and importable.
3. **Excalidraw‑control & hyperframes‑best‑practices skills** – folder structures exist and contain a valid `SKILL.md`.
4. **Git configuration** – remote `origin` points to the correct GitHub repository.
5. **Node/Yarn environment** – dependencies are installed (`npm install`) and the project can be built (`npm run build`).

### Guidelines
1. **Sequential ordering** – Increment the numeric prefix by 1 for each new change.
2. **Consistency** – Every change directory contains the four core artifacts listed above.
3. **Version control** – The numeric prefix aids reviewers in understanding the evolution of the project.
4. **Renumbering** – If a change is removed, update subsequent prefixes to maintain a continuous sequence.

### Example Structure for `01-system-check`
```
OpenSpec/changes/01-system-check/
├─ README.md
├─ design.md   ← (this file)
├─ proposal.md
└─ tasks.md
```

Follow this rule for all future changes to keep the repository organized and the OpenSpec workflow predictable.
