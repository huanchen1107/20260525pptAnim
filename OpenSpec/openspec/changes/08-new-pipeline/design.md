## Context

The repository already has a working direction for slide processing, but the previous architecture relied on using HTML/CSS directly as the layout source of truth. This approach lacked explicit geometric structure and made systematic revision and algorithm-based layout iteration impossible. We need a single explicit product contract that replaces HTML guessing with a rigorous schema.

## Goals / Non-Goals

**Goals:**
- Define a clear slide-production pipeline that agents can follow end to end.
- Establish a strict JSON schema (`scene_layout.json`) as the absolute source of truth for all layout geometry.
- Convert HTML/CSS into a "dumb renderer" that blindly applies the JSON schema.
- Keep GSAP as the animation control layer and HyperFrames as the render layer.
- Make intermediate artifacts explicit so analysis, layout rebuilding, animation, render, and QA can be repeated independently.
- Keep the pipeline structure portable across macOS, Linux, and Windows.

**Non-Goals:**
- Redesigning the visual style system itself.
- Replacing HyperFrames or GSAP.
- Defining a new end-user UI beyond the existing file-and-script workflow.

## Decisions

1. **Strict JSON Schema as Source of Truth**
   - After experimentation, we realized that treating HTML/CSS as the layout source of truth is too brittle and hard to diff algorithmically.
   - We introduced `scene_layout.json` as the strict absolute source of truth for all layout geometry (`x, y, w, h`, etc).
   - **Strict Enforcement**: The `slide-scene-rebuild-html-skill` must ALWAYS be applied in the pipeline. Hand-crafted, relative, or custom HTML structures that bypass layout control are strictly forbidden. HTML (`custom-html.html`) acts purely as a "dumb" renderer output via the `render_html_from_layout.py` script, which maps the JSON schema coordinates directly to absolute CSS.

2. **AI Orchestrator for Visual Analysis**
   - We implemented `orchestrator.py` to use the Anthropic Vision API to automatically extract the strict JSON schema from the source slide image.
   - **Crucial constraint**: Massive high-res images (e.g., 5734x3200) cause the Anthropic API to crash with `ChunkedEncodingError`. The orchestrator MUST use `PIL` to downsample the image payload (e.g., to a 1920x1080 bounding box) before sending it to the LLM to preserve network stability.

3. **QA Diff Loop as a Required Stage**
   - Make visual QA a distinct step after rendering so layout drift, clipping, and animation regressions are visible before the pipeline is considered complete.
   - We use a pixel diff scoring loop against the generated thumbnail to systematically iterate layout changes until the diff score drops below `< 18.0`.

4. **Canonical Artifact Contract**
   - Use named intermediate artifacts (`scene_layout.json`, `custom-html.html`, `qa/qa_report.md`) instead of allowing the pipeline to collapse into one opaque output.
   - This keeps each stage debuggable and makes it obvious where a failure occurred.

5. **Portable Path Behavior**
   - Keep all artifact locations workspace-relative and consistently named so the pipeline remains predictable across platforms.
   - This avoids coupling the workflow to OS-specific path conventions.

## Risks / Trade-offs

- [Risk] AI layout extraction might guess coordinates incorrectly. → Mitigation: Downsample image to standardized 1920x1080 grid before sending, and rely on the automated QA diff loop to refine coordinates algorithmically.
- [Risk] More stages mean more files to manage. → Mitigation: Keep each stage narrow and document the artifact contract in one place.
- [Risk] Platform path differences can break scripts. → Mitigation: Keep generated outputs workspace-relative and normalize path handling in scripts and tests.

## Migration Plan

1. Establish the pipeline contract and the `slide-scene-rebuild-html-skill` guidance in the repository.
2. Align slide-generation scripts to emit `scene_layout.json` and consume it via `render_html_from_layout.py`.
3. Keep the legacy storyboard/render path available until the new scene-based flow is fully adopted.

## Open Questions

- Should the project expose one top-level pipeline script or keep the stages as separate scripts?
- Should QA be required on every render or only on explicit verification runs?
