## Context
We are generating presentation slide animations programmatically. Previously, the storyboard HTML generation and video rendering steps were combined in a single step (05). To improve modularity, testability, and adherence to the single-responsibility principle, we are decoupling the video rendering pipeline using the HyperFrames framework into its own dedicated step.

## Goals / Non-Goals
**Goals:**
- Decouple storyboard rendering from HTML generation.
- Utilize HyperFrames CLI (`npx hyperframes render`) to produce deterministic MP4 videos from the generated HTML storyboards.
- Automatically integrate `.mp3` audio tracks into the final MP4 output if available.
- Create automated integration tests and a dedicated CI workflow.

**Non-Goals:**
- Modifying the visual layout or animations inside the storyboard itself.
- Implementing text-to-speech for the audio tracks (assumed to be pre-existing).

## Decisions
1. **Render script separation**: We created a standalone bash script `user/assets/render_animation.sh` that iterates over slide directories. Rationale: It isolates rendering concerns, allowing users to test video output without regenerating the storyboard.
2. **Hyperframes API Compliance**: During rendering, `hyperframes` v2 requires `index.html` to be present. The script copies the `slide-N-storyboard.html` to `index.html` temporarily during the render process. Rationale: This avoids structurally changing how storyboards are named while satisfying the framework's file-naming expectations.
3. **CI Separation**: We separated the GitHub Actions workflow into `render_animation.yml`, configured to run via `workflow_dispatch` and `workflow_run` (after storyboard generation). Rationale: CI pipelines run faster and fail closer to the actual source of the problem.
4. **16:9 Resolution**: The video dimensions are explicitly set to `1920x1080`. Rationale: It better matches standard presentation aspect ratios.
6. **Three-Layer Architectural Paradigm**: We are formally adopting the following flow for converting PPTs to animations:
   - **Layer 1: Visual Stage (HTML/CSS)**: Treat HTML as the Excalidraw canvas. Rebuild PPT assets into HTML components (grid backgrounds, blueprint themes, hand-drawn borders, tags).
   - **Layer 2: Animation Control (GSAP)**: GSAP is the timeline orchestrator. It manages timing, sequences, and UI state (e.g., `playIntro()`, `playDebugMode()`). The "Storyboard" represents the semantic script (what happens when and why), while GSAP implements the exact pixel movements.
   - **Layer 3: Video Export (HyperFrames)**: HyperFrames acts purely as the camera and deterministic rendering engine, converting the HTML/GSAP state into a frame-by-frame MP4.

## Risks / Trade-offs
- **Risk**: Rendering MP4s using Puppeteer/HyperFrames is CPU-intensive.
  - **Mitigation**: Offload this process to GitHub Actions runners where possible.
- **Risk**: Out-of-sync audio or missing audio elements.
  - **Mitigation**: The storyboard generation script now embeds the `<audio>` tag explicitly so HyperFrames synchronizes and captures it perfectly.
