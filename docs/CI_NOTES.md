# CI Notes (Design + Contracts)

This document captures the intended behavior of the pipeline + Pipeline UI so CI and future sessions have a stable reference.

## Canonical Logs

- Development log: `log.md`
- Pipeline contract: `pipeline.md`

## Pipeline UI (FastAPI)

Location:
- `apps/pipeline_ui/`

Purpose:
- Provide a browser UI to run the pipeline step-by-step and manage storyboard inputs per slide.

Key UX rules:
- Default pipeline mode is `final` unless explicitly requested otherwise.
- Each slide row shows:
  - left: slide thumbnail (`slide-N.png`)
  - right-top: caption (from `slide-N-audio.txt`)
  - right-bottom: animation design idea textbox (stored as a file)
- Left thumbnail panel can toggle to show the rendered result video in-place (uses the same box).
- Project panel includes a stepper UI to run each pipeline step and reflect status.

APIs (core):
- `GET /api/projects`
- `GET /api/projects/{project}/slides`
- `POST /api/pipeline/run` (full pipeline)
- `POST /api/pipeline/step/{split|convert|storyboard|render|combine|validate}`
- `GET /api/runs/{run_id}` (status + tailed log)
- `GET/PUT /api/storyboard/{project}/{slide}/idea`
- `POST /api/storyboard/{project}/{slide}/regenerate`
- `GET /api/thumb/{project}/{slide}` (PNG)
- `GET /api/caption/{project}/{slide}` (audio text first line)
- `GET /api/result/{project}/{slide}` (MP4)
- `GET /api/pipeline/status?project_id=...&slide=...` (stepper status)

## Storyboard Idea Storage

Per-slide idea file:
- `user/<project>/slides/slide-N-storyboard-idea.txt`

Default behavior:
- If missing or empty, the UI auto-initializes a default idea template (human-editable guidance).

## Storyboard Generation

Generator:
- `user/all-project-base/scripts/generate_storyboard.sh`

Behavior:
- Reads `slide-N-storyboard-idea.txt` if present and writes `idea:` into `slide-N-storyboard.yml` for traceability.

## Storyboard Consumption (Object Animation)

Problem:
- A storyboard file alone does nothing unless the renderer consumes it.

Implementation (current):
- `user/all-project-base/scripts/render_animation.sh` copies `slide-N-storyboard.yml` into the HyperFrames temp dir.
- If the HTML lacks `window.__hf`, the renderer injects an `hf_shim.js` that:
  - parses `objects:` actions from storyboard YAML
  - exposes `window.__hf = { duration, seek }`
  - applies actions deterministically during `seek(t)`

Fallback HTML targets:
- `user/all-project-base/scripts/convert_image_to_html.sh` ensures fallback HTML includes stable ids:
  - `title`, `subtitle`, `progress_fill`

## Minimal PR CI

Workflow:
- `.github/workflows/minimal-ci.yml`

Checks:
- `bash -n` syntax validation for key scripts
- smoke: single-slide pipeline (ffmpeg renderer, `final`)

## Startup Defaults

- `./startup.sh` starts the Pipeline UI by default.
- Disable UI auto-start: `PIPELINE_UI=0 ./startup.sh`
