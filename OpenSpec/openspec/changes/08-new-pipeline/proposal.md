## Why

The previous slide workflow attempted to use HTML/CSS directly as the source of truth for layout, which resulted in brittle components that were difficult to diff algorithmically or refine systematically. We need a single, explicit pipeline contract built on a strict, platform-agnostic schema so agents can move from source slides to editable components, animation, MP4 export, and QA without relying on manual HTML guessing.

## What Changes

- Introduce a strict JSON layout schema (`scene_layout.json`) as the absolute source of truth for all layout geometry (e.g., `x`, `y`, `w`, `h`, `zIndex`).
- Introduce `render_html_from_layout.py` as a "dumb" HTML renderer that blindly maps the JSON schema coordinates to absolute CSS, fully replacing the manual HTML layout approach.
- Implement an AI Orchestrator (`orchestrator.py`) utilizing the Anthropic Vision API to automatically extract the precise JSON layout schema from source slides.
  - *Note: Incorporates PIL-based image downsampling to prevent `ChunkedEncodingError` API crashes on massive inputs.*
- Define a consistent agent skill stack (`slide-scene-rebuild-html-skill`) to enforce this strict separation of concerns, clearly communicating to agents that HTML is never the source of truth.
- Institute a pixel-diff validation loop against generated thumbnails to systematically iterate the JSON layout until the visual match reaches a `< 18.0` score threshold.
- Keep the pipeline usable across platforms by treating generated paths as stable workspace-relative artifacts.

## Capabilities

### New Capabilities
- `slide-pipeline`: Orchestrates the end-to-end slide production workflow from source slide input through analysis, schema generation, dumb rendering, animation, HyperFrames render, and QA.

### Modified Capabilities

- Removed reliance on direct Excalidraw-style HTML generation for initial layout extraction.

## Impact

- Affects the slide-processing docs and workflow guidance in the repository.
- Deeply integrates the `slide-scene-rebuild-html-skill` local agent skill pack.
- Affects pipeline scripts that emit or consume layout schemas and `custom-html.html` artifacts.
- Modifies tests and documentation that assert how the slide layout workflow is structured.
