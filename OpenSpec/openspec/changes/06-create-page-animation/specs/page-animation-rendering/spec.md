## ADDED Requirements

### Requirement: HyperFrames MP4 Rendering
The system SHALL provide a script-driven mechanism to render deterministic MP4 video animations from slide storyboard HTML files and associated MP3 audio tracks using HyperFrames.

2. **Storyboard Transformation**:
   - The user provides PPT slides and transcripts.
   - We design a semantic **Storyboard** (e.g., `time: 0s-1s, action: fade in grid, meaning: System Startup`).
   - We implement the **Visuals** via HTML/CSS (Excalidraw styling, grids, tags).
   - We implement the **Animation** using GSAP (`tl.from(...)`) within `custom-html.html` or a dedicated JS hook (`window.applyCustomAnimation`).
3. **MP4 Render Phase**:
   - The bash script runs `npx hyperframes render user/assets/slides/slide-<N> -o user/assets/slides/slide-<N>/slide-<N>-animation.mp4`
   - HyperFrames deterministic rendering captures the GSAP states frame-by-frame perfectly synced with the `<audio>` tag.

#### Scenario: Dedicated CI Workflow triggering
- **WHEN** the "Storyboard Generation" workflow completes successfully on GitHub Actions
- **THEN** the `render_animation.yml` workflow is automatically triggered to generate and upload the resulting MP4 artifacts.
