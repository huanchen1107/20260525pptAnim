# Proposal for `06-create-page-animation`

## Goal
Extract and formalize the animation rendering step into its own change. In this phase, we use the `hyperframes` library to render `slide-N-animation.mp4` for each slide based on the storyboard HTML, audio, and slide HTML content.

## Scope
- Create/Refine a bash script (`user/assets/render_animation.sh`) that takes each slide's generated storyboard HTML and audio track, and renders a deterministic MP4 video using `npx hyperframes render`.
- Add an integration test `tests/render_animation.test.sh` to verify MP4 generation.
- Add or update the CI workflow (`.github/workflows/render_animation.yml`) specifically to trigger the rendering of these animations.
- Remove any overlapping animation logic from the previous `05-make-storyboard-for-each-page` workflow to keep concerns separated.
- **Update**: Adopt a formal 3-Layer Architecture for all animations:
  1. **Visual Layer**: HTML/CSS replicating Excalidraw layouts (grid, blueprint, sketched borders).
  2. **Control Layer**: GSAP Timelines executing the semantic storyboard (managing timings, states, and sequential object introductions).
  3. **Export Layer**: HyperFrames rendering the deterministic MP4.

## Benefits
- Decouples storyboard generation (HTML/GSAP logic) from video rendering (HyperFrames MP4 output).
- Allows independent testing, debugging, and iteration of the video rendering process.
- Ensures audio integration during the rendering step is clearly defined.

## Acceptance Criteria
- Running the `render_animation.sh` script produces `slide-N-animation.mp4` in each respective slide folder.
- The rendering uses the existing `slide-N-storyboard.html` as the source and `slide-N.mp3` as the audio.
- A GitHub Actions workflow `render_animation.yml` is available to trigger the render process via `workflow_dispatch`.
- `tests/render_animation.test.sh` correctly verifies the presence of MP4 outputs.
