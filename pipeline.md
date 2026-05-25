# Agent Skill Pack Pipeline

This repository now treats slide generation as an eight-stage agent pipeline:

1. Visual analysis
2. Template matching and layout planning
3. Semantic block extraction
4. Excalidraw-style HTML rebuild
5. GSAP storyboard animation
6. HyperFrames rendering
7. Visual QA
8. Revision loop

## Five-Layer Stack

- AI analysis: `screenshot-visual-analyzer`
- Template planning: `ppt-template-matcher`
- Semantic reconstruction: `semantic-block-extractor`
- Excalidraw-style HTML/CSS: `excalidraw-style-html-builder`
- Animation control: `gsap-storyboard-animator`
- Video export: `hyperframes-video-renderer`
- Inspection and correction: `visual-qa-checker`
- Orchestration: `project-orchestrator`

## Source Of Truth (No Thumbnail Drift)

Always start from the **full-resolution** source slide image (or a faithful vector/HTML export of it). Do not run any
"thumbnail-first" operations that change the canvas size before extracting geometry; that’s how parameters drift.

The input slide image is analysis-only; the final render must be built from DOM/object layers, not from a screenshot overlay.

The pipeline should be described and exchanged through structured artifacts:

- `analysis/visual_analysis.yaml`
- `analysis/semantic_blocks.yaml`
- `analysis/storyboard.yaml`
- `scene/index.html`
- `scene/style.css`
- `scene/animation.js`
- `qa/qa_report.md`

## HyperFrames Scene Contract (Avoid Black MP4)

Your `scene/index.html` must expose a root composition wrapper with:

- `data-composition-id="slide-1"` (stable id per slide)
- `data-width="1920"` / `data-height="1080"` (numeric pixels for the video frame)
- `data-start="0"`

And your `scene/animation.js` must register deterministic playback:

- `window.__timelines[compositionId] = timeline`
- `window.__hf = { duration, seek(tSeconds) }`

## Local Skill Pack

The repo keeps the pipeline skills in `.agents/skills/`:

- `screenshot-visual-analyzer`
- `ppt-template-matcher`
- `semantic-block-extractor`
- `excalidraw-style-html-builder`
- `gsap-storyboard-animator`
- `hyperframes-video-renderer`
- `visual-qa-checker`
- `project-orchestrator`

## Tool Stack

- Vision / OCR / manual markup for visual analysis
- HTML / CSS / SVG / Rough.js for semantic scene rebuilding
- GSAP for deterministic animation control
- HyperFrames for MP4 rendering
- Render review and artifact inspection for QA

## Operating Rule

Do not jump from screenshot to final video. Always keep the intermediate YAML and scene artifacts in place so agents can inspect, revise, and re-run the pipeline without guessing.

## Runtime Entry Points

- `./user/assets/run_pipeline.sh` runs conversion, storyboard YAML generation, animation rendering, and master video assembly.
- `./user/assets/run_pipeline.sh --mode preview` runs the same pipeline but writes smaller preview MP4s to `user/assets/slides/<slide>/preview/`.
- `./user/assets/run_pipeline.sh --mode auto user/assets/slides/slide-1` runs a single preview pass for a slide using the full-resolution source image.
- `./user/assets/render_animation.sh` renders each slide scene to `user/assets/slides/<slide>/` using the slide directory basename, for example `slide-1.mp4`.
- `./user/assets/combine_videos.sh` assembles `user/assets/presentation-master.mp4` with audio.

## Slide-1 From Scratch (Suggested Step Order)

When supervising interactively, use this order before any MP4 render:

1. Verify inputs exist: `slide-1.png`, `audio-1.mp3`, `caption-1.txt`
2. Derive `scene/index.html` (from `A2Z.tsx` page 1, or from layout JSON → HTML)
3. Add `scene/style.css` (theme + typography)
4. Add `scene/animation.js` (GSAP timeline + HyperFrames contract)
5. Render: `./user/assets/render_animation.sh user/assets/slides/slide-1`
6. QA: compare MP4 vs source slide, iterate

## A2Z Source Deck

When the source is `user/assets/A2Z.tsx`, use `user/assets/A2Z.pipeline.yaml` as the page map for the deck:

- page 1 through 13 are treated as distinct slide sources
- each page flows through the same analysis → storyboard → GSAP → HyperFrames chain
- page 3 acts as the template/navigation hub for repeated layout families
- page 13 is the final compilation slide and should keep the terminal/progress semantics during animation

## A2Z File Contract

- `user/assets/A2Z.tsx`: authored React deck and page logic
- `user/assets/A2Z.pipeline.yaml`: generated page manifest and skill map
- `analysis/visual_analysis.yaml`: page-level visual read
- `analysis/layout_plan.yaml`: repeated-template geometry plan
- `analysis/semantic_blocks.yaml`: editable block tree
- `analysis/storyboard.yaml`: animation beats and page timing
- `scene_layout.json`: strict geometry source of truth
- `scene/index.html`: rebuilt HTML scene
- `scene/style.css`: scene styling
- `scene/animation.js`: GSAP timeline and seek contract
- `user/assets/slides/slide-N/*.mp4`: rendered page outputs

## Legacy Compatibility

- `slide-<N>-storyboard.html` is now a compatibility artifact only.
- New work should treat `scene/index.html` plus the YAML files as the source of truth.
