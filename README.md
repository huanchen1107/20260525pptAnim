# test-2026.5.21remotiontest

Unified project docs:
- `README.md`: setup and workflow
- `project_initial.md`: current goals and scope
- `pipeline.md`: slide pipeline and artifact contract
- `log.md`: execution history and status

## Quick Start

```bash
./startup.sh
./ending.sh
```

## Runtime

- Default client: `codex`
- Required key: `OPENAI_API_KEY` in `.env`
- Optional Claude mode: set `AI_CLIENT=claude` and `ANTHROPIC_API_KEY`

## Current Scope

This workspace is now centered on a scene-first pipeline:
`PPT/image -> analysis YAML -> semantic blocks -> editable scene -> GSAP -> HyperFrames -> audio-backed MP4`.
Use `project_initial.md` for the current goal and `pipeline.md` for the artifact contract.

## Pipeline Tutorial

This project turns a slide image or PPT page into an editable animated scene, then exports it to audio-backed video.

One-command pipeline:

```bash
./user/assets/run_pipeline.sh
```

MP4 outputs are written next to each slide using the slide directory name, for example `user/assets/slides/slide-1/slide-1.mp4`.
For tuning, run the same pipeline in preview mode:

```bash
./user/assets/run_pipeline.sh --mode preview
```

Preview renders are smaller and land in `user/assets/slides/<slide>/preview/` as `*.preview.mp4`.
For a single-slide preview pass, run:

```bash
./user/assets/run_pipeline.sh --mode auto user/assets/slides/slide-1
```

Auto mode now runs a single preview pass with the full-resolution source image and skips the old comparison loop.

### 1. Start With The Source

Put the input slide in the workspace as an image, PDF page, or PPT export.

### 2. Extract JSON Layout Schema (AI Orchestrator)

We use `orchestrator.py` (powered by Anthropic Vision API) to automatically extract the layout from the source image.
The orchestrator sends the original image bytes to the model, records the source canvas size, and outputs a strict JSON schema: `scene_layout.json`.

Why: The `scene_layout.json` is the absolute source of truth for all geometry (`x`, `y`, `w`, `h`).

### 3. Dumb HTML Rendering

Run `render_html_from_layout.py` to translate `scene_layout.json` into `custom-html.html`.
The renderer blindly applies absolute CSS positioning based on the JSON coordinates.

Why: HTML is no longer treated as a layout source of truth; it is strictly a "dumb" visual output layer.

### 4. Scene Rebuild

Wrap `custom-html.html` into a full scene:
- `scene/index.html`
- `scene/style.css`
- `scene/animation.js`

### 5. Add GSAP Animation

Use GSAP timelines in `scene/animation.js` to animate the layout elements in a deterministic order.

Recommended pattern:
- build one paused timeline
- register it in `window.__timelines[compositionId]`
- expose `window.__hf = { duration, seek }` (required by HyperFrames; missing this can produce a black MP4)
- use labels for readable sequencing
- animate `x`, `y`, `scale`, `opacity`, or `autoAlpha`

### 6. Render To MP4

Use HyperFrames to render the HTML scene into a video file such as `user/assets/slides/slide-1/slide-1.mp4`.

### 7. QA Review

Inspect the rendered MP4 and the generated `scene_layout.json`/scene artifacts to validate geometry and hierarchy.

Why: The pipeline now keeps the source image at full size, so layout refinement happens in the structured artifacts instead of in a resized comparison pass.

## File Contract

The most important files are:

- `user/assets/slides/slide-N/scene_layout.json`
- `user/assets/slides/slide-N/custom-html.html`
- `scene/index.html`
- `scene/style.css`
- `scene/animation.js`
- `qa/qa_report.md`

Legacy `slide-<N>-storyboard.html` files and semantic YAML files are deprecated; the strict JSON schema is the layout source of truth.

## Skill Map

The repo’s local skill pack matches the tutorial:

- `project-orchestrator` coordinates the full loop
- `slide-scene-rebuild-html-skill` extracts the strict JSON layout
- `gsap-storyboard-animator` adds motion
- `hyperframes-video-renderer` exports the video
- `visual-qa-checker` reviews render quality and layout drift
- `ppt-template-matcher` reuses a stable layout family for repeated PPT slides

For the new React source deck, `user/assets/A2Z.tsx` is mapped through `user/assets/A2Z.pipeline.yaml` before the GSAP and HyperFrames stages.

## 📍 Latest Status

Last updated on **2026.05.25** via `./ending.sh`.

### Recent Commits:
- `2ad1f8a feat: Implement page animation rendering pipeline`
- `6b2d667 chore: remove deleted work dir from index and update gitignore`
