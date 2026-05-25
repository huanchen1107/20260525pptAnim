---
name: screenshot-visual-analyzer
description: Analyze a slide, screenshot, PDF page, or image and extract layout zones, visual hierarchy, text blocks, graphic elements, color palette, typography hints, and animation candidates.
metadata:
  tags: ppt, screenshot, analysis, vision, layout, yaml
---

# Screenshot Visual Analyzer

Use this skill when the input is an image, screenshot, slide export, or PDF page and the next step is to rebuild it as Excalidraw-style HTML or a video scene.

## Goal

Understand the visual structure before writing HTML.

## Required Output

Produce `analysis/visual_analysis.yaml` with:

- canvas ratio and estimated size
- background type and mood
- layout zones
- text hierarchy
- graphic elements
- color palette
- typography guess
- semantic block candidates
- animation candidates
- rebuild priority

## Rules

1. Identify the canvas ratio first.
2. Split the slide into meaningful zones.
3. Prefer semantic interpretation over pixel tracing.
4. Mark uncertain text or shapes as `uncertain`.
5. Keep the output stable enough for downstream YAML consumers.

## Minimum YAML Shape

```yaml
visual_analysis:
  canvas:
    ratio: "16:9"
    estimated_size: "1920x1080"
  style:
    direction: "Excalidraw-style engineering slide"
    background: "grid paper"
  blocks:
    - id: background_grid
      role: background
      position: full_canvas
    - id: main_frame
      role: central_container
      position: center
    - id: title
      role: primary_message
      priority: high
    - id: subtitle
      role: secondary_message
      priority: high
```
