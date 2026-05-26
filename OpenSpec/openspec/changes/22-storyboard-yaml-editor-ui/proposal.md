## Why

The current FastAPI UI (change 21) can store per-slide storyboard ideas and trigger regeneration, but it lacks:

- direct YAML editing with save/validate
- a clear preview loop for a single page after edits
- visibility into what changed (diff) when regenerating from ideas/defaults

We need a focused follow-up change that upgrades the storyboard UX without destabilizing pipeline execution controls.

## What Changes

- Add a storyboard YAML editor per slide (textarea + save).
- Add regen diff view:
  - show generated YAML vs existing YAML
  - allow accept/merge workflow
- Add a "single-slide render" loop from UI for quick verification.

## Capabilities

### New Capabilities
- `storyboard-yaml-editor`: Edit and persist storyboard YAML from the UI.
- `storyboard-diff-review`: Compare regenerated YAML against current YAML and approve changes.

### Modified Capabilities
- `fastapi-pipeline-ui`: Adds richer storyboard workflow screens and validation.

