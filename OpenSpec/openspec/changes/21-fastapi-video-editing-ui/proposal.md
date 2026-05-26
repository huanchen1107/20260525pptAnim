## Why

The current pipeline is script-first and terminal-driven. It is hard to control each stage visually, hard to inspect per-page storyboard intent, and hard for non-shell users to iterate quickly.  
We need a FastAPI-based video editing UI that orchestrates the existing pipeline, exposes step-by-step controls, and provides per-page storyboard editing with explicit "idea input" text boxes.

## What Changes

- Add a FastAPI backend and web UI for end-to-end pipeline control.
- Expose each pipeline stage as explicit UI actions (split, convert, storyboard, render, combine, validate).
- Add per-page storyboard workspace:
  - show current storyboard content
  - free-text "idea" input box per page
  - apply/regenerate storyboard from idea
  - save manual edits
- Add run logs and status for each stage/page so users can diagnose failures from the UI.

## Capabilities

### New Capabilities
- `fastapi-pipeline-ui`: Operate the full video pipeline from a browser UI backed by FastAPI.
- `storyboard-idea-editor`: Edit storyboard development intent per page via text boxes and apply to storyboard generation.

### Modified Capabilities
- `slide-pipeline`: Adds API-driven orchestration and per-stage execution entrypoints for UI usage.
- `storyboard-generation`: Supports page-level idea overrides from UI input.

## Impact

- Affects shared scripts under `user/all-project-base/scripts/` via API wrappers.
- Adds an app layer (FastAPI routes + templates/static frontend + backend service layer).
- Improves iteration speed and visibility while keeping existing CLI pipeline as fallback.
