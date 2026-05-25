# Multi-Project Pipeline Rules

## Project Layout
Each project must follow this structure:
- `user/<project-name>/source/` for raw inputs
- `user/<project-name>/slides/` for generated flat slide artifacts
- `user/<project-name>/outputs/` for final assembled videos
- `user/<project-name>/docs/` for project notes

Shared base:
- `user/all-project-base/scripts/` for shell pipelines
- `user/all-project-base/utils/` for Python utilities
- `user/all-project-base/docs/` for shared standards

## Required Naming (Flat in `slides/`)
For slide `N`:
- `slide-N.png`
- `slide-N-audio.mp3`
- `slide-N-audio.txt`
- `slide-N-storyboard.yml`
- `slide-N.html`
- `slide-N.mp4`
- `slide-N.preview.mp4` (preview mode)

Project-level metadata in `slides/`:
- `timestamps.json`
- `slide-metadata.yaml`

## Source Naming
Project-specific source files stay in `source/`.
If a project uses A2Z inputs, keep:
- `A2Z-original.mp4`
- `A2Z-original-audio.mp3`
- `A2ZpdfExcalidraw.pdf`
- `A2Zsrt.srt`
- `A2Z.tsx`
- `A2Z.pipeline.yaml`

## Pipeline Commands
Run from repo root with project path passed as argument when supported.
- `bash user/all-project-base/scripts/split_pages.sh`
- `bash user/all-project-base/scripts/generate_storyboard.sh`
- `bash user/all-project-base/scripts/convert_image_to_html.sh`
- `bash user/all-project-base/scripts/render_animation.sh --mode preview`
- `bash user/all-project-base/scripts/render_animation.sh --mode final`
- `bash user/all-project-base/scripts/combine_videos.sh`

## Enforcement
- Do not create `slides/slide-N/` directories.
- Keep all slide artifacts as flat files in `slides/`.
- New scripts must read/write using this contract.
- If legacy names exist, normalize to canonical names.

## Top-Down Governance Rule
- `user/all-project-base/` is the single source of truth for shared logic.
- Always use shared assets from:
  - `user/all-project-base/scripts/`
  - `user/all-project-base/utils/`
  - `user/all-project-base/skills/`
  - `user/all-project-base/docs/`
- Individual projects (for example `user/project-1/`) must consume shared logic and must not fork or duplicate core pipeline scripts/utilities unless explicitly approved.
- Project folders should contain project-specific inputs, generated artifacts, outputs, and local docs only.
- When updating pipeline behavior, update shared files in `all-project-base` first, then verify downstream projects.

## Change History
- See  to track applied corrections before further optimization.


## Dynamic Object Control Rule
- Storyboard files (`slide-N-storyboard.yml`) are not sufficient by themselves.
- Pipeline must include a storyboard-consumption step that maps storyboard object actions to DOM elements (by stable object IDs) during rendering.
- Effects such as `zoom in`, `zoom out`, `pan`, `show up`, `emphasize`, and similar motion must be implemented in this consumption step.
- If this step is skipped, render output is considered static/fallback mode, not full dynamic mode.


## Storyboard Mapper Rule
- `generate_storyboard.sh` must generate content-driven object timelines, not fixed generic timings.
- Storyboard generation must use:
  - `slide-N-audio.txt` for semantic intent detection,
  - `slide-N-scene_layout.json` for object ID targeting when available.
- Action mapping should include dynamic controls such as `zoom_in`, `zoom_out`, `pan`, `fade_in`, `emphasize` (or equivalent runtime actions).
- Storyboard output must enforce at least one animation event every 5 seconds for non-static pacing.
- Canonical output file remains `slide-N-storyboard.yml`.


## HyperFrames Recovery Rule
- When HyperFrames environment/version is inconsistent, use:
  - `user/all-project-base/scripts/setup_hyperframes_and_run.sh`
- This script is the standard recovery entrypoint for install+version check+run in one flow.
