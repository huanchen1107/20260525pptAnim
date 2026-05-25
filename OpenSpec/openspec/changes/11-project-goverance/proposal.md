## Why

The workspace now contains multiple projects under `user/`, but pipeline behavior, script locations, and output naming can drift when each project edits logic locally. We need explicit governance so all projects follow one top-down contract from `all-project-base`, reducing breakage and duplicated fixes.

## What Changes

- Define `user/all-project-base` as the single source of truth for shared pipeline logic.
- Standardize per-project structure: `source/`, flat `slides/`, `outputs/`, `docs/`.
- Require canonical flat slide naming (`slide-N.*`, `slide-N-audio.*`, etc.).
- Require all projects to invoke shared scripts/utilities from `user/all-project-base/scripts` and `user/all-project-base/utils`.
- Add governance docs that define path contracts, naming, and execution steps for multi-project operation.

## Capabilities

### New Capabilities
- `project-governance`: Enforces top-down pipeline ownership, directory contracts, and naming conventions for all `user/project-*` workspaces.

### Modified Capabilities
- `slide-pipeline`: Moves from project-local script ownership to centralized shared ownership in `all-project-base`.

## Impact

- Affects all current and future `user/project-*` directories.
- Affects docs and runbooks that previously referenced project-local scripts.
- Reduces maintenance cost by centralizing script and utility changes.
