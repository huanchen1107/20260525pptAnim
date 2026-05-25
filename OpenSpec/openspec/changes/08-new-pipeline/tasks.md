## 1. Pipeline Contract

- [x] 1.1 Define the slide pipeline artifact contract in repo documentation (Strict JSON Source of Truth)
- [x] 1.2 Document the required intermediate outputs for AI orchestration, dumb HTML rendering, animation, and QA loop
- [x] 1.3 Confirm the pipeline naming and directory structure are stable across platforms

## 2. Skill Pack Guidance

- [x] 2.1 Add the local skill guidance for visual extraction to strict JSON (`slide-scene-rebuild-html-skill`)
- [x] 2.2 Add or update the local skill guidance for HyperFrames rendering and GSAP animation

## 3. Pipeline Implementation

- [x] 3.1 Create `orchestrator.py` to extract `scene_layout.json` via Anthropic Vision API (incorporating PIL downsampling for large files)
- [x] 3.2 Create `render_html_from_layout.py` to act as a "dumb" HTML renderer, blindly applying `scene_layout.json` to absolute CSS
- [x] 3.3 Hook `scene_layout.json` into the `render_animation.sh` rendering pipeline
- [x] 3.4 Provide valid API key to validate `orchestrator.py` bulk processing

## 4. Verification

- [x] 4.1 Update `generate_thumbnail_previews.sh` to capture layout thumbnails
- [x] 4.2 Establish the iterative pixel-diff loop to score rendering accuracy (Target `< 18.0`)
- [x] 4.3 Add or update tests for cross-platform path stability

## 5. Documentation

- [x] 5.1 Update the main README and project goals to reference the JSON-first pipeline
- [x] 5.2 Update all `08-new-pipeline` OpenSpec documentation to reflect the architectural shift away from HTML as the source of truth
