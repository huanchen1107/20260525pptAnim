# Storyboard Generation for Slides

## Overview
This change adds a **storyboard HTML** file for each slide (`slide-<N>-storyboard.html`). The storyboard defines object visibility, easing, and camera pan/zoom based on the slide caption semantics.

## How It Works
- A Bash script `user/assets/generate_storyboard.sh` parses each slide folder, reads the caption, and creates a storyboard HTML using **GSAP** for animation timelines.
- The script integrates with **HyperFrames** (`npx hyperframes render`) to optionally render the storyboard to an MP4 video.
- The GitHub Actions workflow `.github/workflows/storyboard.yml` runs the script manually (`workflow_dispatch`). It can also render videos when the `render` input is set to `true`.

## Usage
```bash
# Make sure dependencies are installed
npm install

# Generate storyboards (creates files under user/assets/storyboards/)
./user/assets/generate_storyboard.sh
```

### Optional video rendering
```bash
# Render MP4 videos (requires hyperframes)
./user/assets/generate_storyboard.sh --render
```

## CI Workflow
- Trigger the **Storyboard Generation** workflow from the GitHub UI.
- Provide the optional `render` input (`true`/`false`).
- Artifacts are uploaded for download.

## Caption Formatting
The script looks for keywords in the slide caption to decide animation:
- `zoom in`, `focus`, `emphasize` → zoom in on the object.
- `zoom out`, `pan away` → zoom out after display.
- Any other text → default fade‑in with easing.

## Testing
Run the integration test:
```bash
./tests/storyboard.test.sh
```
It verifies that a storyboard file exists for each slide and contains required `data-hf-*` attributes.

## Bespoke Animation Requirements (Updated)
- **16:9 Format**: Video resolution has been standardized to 16:9 (1920x1080).
- **Excalidraw Diagrams**: Bespoke storyboards for each slide are designed using Excalidraw JSON layouts.
- **5-Second Dynamic Interval**: The video is no longer a static slideshow. A minimum of one animation event (e.g. object fade, pan, zoom, scale) triggers every 5 seconds.
- **Native HyperFrames Control**: Instead of pure GSAP, elements are orchestrated on the timeline using native DOM attributes (`data-hf-scene`, `data-hf-start`, `data-hf-end`).
