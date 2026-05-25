## Why

`project-1` was migrated to the new governance model (top-down shared scripts/utilities and flat slide artifacts), but `slide-1` still contains mixed legacy artifacts and naming variants. We need a clean redo of `slide-1` to validate the new structure, naming contract, and render flow end-to-end.

## What Changes

- Regenerate `slide-1` artifacts using shared pipeline logic from `user/all-project-base/`.
- Normalize `slide-1` outputs to canonical flat names in `user/project-1/slides/`.
- Remove `slide-1` legacy/duplicate artifacts not aligned with naming rules.
- Re-render preview/final outputs for `slide-1` and confirm expected outputs.

## Capabilities

### New Capabilities
- `single-slide-redo`: Rebuilds one slide in a governed project while enforcing canonical naming and flat-output structure.

### Modified Capabilities
- `slide-pipeline`: Adds explicit single-slide normalization behavior under governance.

## Impact

- Affects `user/project-1/slides/slide-1*` artifacts.
- Validates whether current shared scripts are sufficient for clean per-slide regeneration.
- Provides a repeatable pattern for redoing any slide (`slide-N`).
