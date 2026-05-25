# Pipeline Corrections Log

This log records structural and pipeline corrections so future optimization can build on stable decisions.

## 2026-05-25: Governance and Structure Corrections

### 1) Top-Down Ownership
- Established `user/all-project-base/` as the single source of truth.
- Shared logic locations:
  - `user/all-project-base/scripts/`
  - `user/all-project-base/utils/`
  - `user/all-project-base/docs/`

### 2) Project Layout Standard
- Standardized each project under `user/<project-name>/` with:
  - `source/`
  - `slides/`
  - `outputs/`
  - `docs/`

### 3) Flat Slides Contract
- Removed legacy per-slide directories (`slides/slide-N/`).
- Enforced flat artifacts in `slides/`:
  - `slide-N.png`
  - `slide-N-audio.mp3`
  - `slide-N-caption.txt`
  - `slide-N-storyboard.yaml`
  - `slide-N.html`
  - `slide-N.mp4`
  - `slide-N.preview.mp4`

### 4) Shared Script Refactor
- Refactored core scripts for flat artifacts and multi-project usage:
  - `convert_image_to_html.sh`
  - `generate_storyboard.sh`
  - `render_animation.sh`
  - `combine_videos.sh`
  - `run_pipeline.sh`

### 5) Unified CLI Interface
- Added common flags:
  - `--project user/project-N`
  - `--slide N` (single-slide)
- `run_pipeline.sh` supports:
  - `--mode auto|preview|final`

### 6) Storyboard Duration Confirmation
- Added per-slide duration prompt in `generate_storyboard.sh`.
- Added `--no-prompt` for automation.

### 7) Dependency/Runtime Guardrails
- `convert_image_to_html.sh` now checks Python `requests` availability before calling `orchestrator.py`.
- Falls back safely if AI extraction dependency is missing.

## Known Runtime Limitation (Environment-Specific)
- HyperFrames render can fail in restricted runtime with:
  - `Error: listen EPERM ... 0.0.0.0`
- This is an execution-environment permission issue, not a path-contract issue.

## Optimization Backlog
- Normalize all legacy duplicate names to canonical single-output naming.
- Add preflight checker script for contract validation (paths, required files, naming).
- Add `--project` support to any remaining auxiliary scripts not yet unified.
- Add optional batch orchestrator for `project-1`, `project-2`, `project-3` sequential execution.

## 2026-05-25: Canonical Text Artifact Update

### Decision
- Use `slide-N-audio.txt` as the canonical per-slide text artifact.
- Deprecate `slide-N-caption.txt` variants.

### Implementation
- Updated `split_pages.sh` to generate `slide-N-audio.txt`.
- Updated `convert_image_to_html.sh` to read `slide-N-audio.txt` first.
- Kept temporary fallback support for `slide-N-caption.txt` for compatibility.
- Added cleanup behavior to remove duplicate legacy text variants during regeneration.

### Optimization Note
- Future cleanup can remove fallback caption handling once all projects are normalized.

## 2026-05-25: Source Role Detection Update

### Decision
- Preflight validates source files by role, not fixed filenames:
  - video input: any `*.mp4`
  - page source: any `*.pdf`
  - page HTML/logic source: any `*.tsx` (warning if absent)

### Notes
- MP3 per-slide files are derived artifacts extracted from video.
- Page images are derived artifacts extracted from PDF.
- `A2Z.tsx` is treated as the source HTML/page logic representation.
