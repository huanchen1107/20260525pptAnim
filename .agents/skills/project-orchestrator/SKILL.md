---
name: project-orchestrator
description: Orchestrate the full PPT/image to Excalidraw-style HTML, GSAP, HyperFrames, and QA workflow using the shared intermediate artifacts.
metadata:
  tags: orchestration, pipeline, skills, workflow, multi-stage
---

# Project Orchestrator

Use this skill for the complete slide pipeline.

## Pipeline

```text
Input PPT/image
-> screenshot-visual-analyzer
-> semantic-block-extractor
-> excalidraw-style-html-builder
-> gsap-storyboard-animator
-> hyperframes-video-renderer
-> visual-qa-checker
-> revision loop
```

## Main Rule

Do not jump directly from screenshot to final code or video. Always preserve the intermediate YAML and scene artifacts.

## Required Artifacts

- `analysis/visual_analysis.yaml`
- `analysis/semantic_blocks.yaml`
- `analysis/storyboard.yaml`
- `scene/index.html`
- `scene/style.css`
- `scene/animation.js`
- `qa/qa_report.md`

## Delivery Standard

The final result should be:

- editable
- semantic
- animation-ready
- Excalidraw-inspired
- renderable to video
- QA-corrected
