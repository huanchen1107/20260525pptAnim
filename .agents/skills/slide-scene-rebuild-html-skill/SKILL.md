---
name: slide-scene-rebuild-html-skill
description: Extract a strict scene layout JSON with absolute geometry from an image before rendering HTML.
metadata:
  tags: scene, layout, json, html, renderer
---

# Slide Scene Rebuild HTML Skill

Never generate HTML directly from a slide image. The HTML should act merely as a "dumb" renderer. You must always extract a strict scene layout first.

## Goal

Decouple layout geometry from HTML/CSS generation. The layout schema is the absolute source of truth.

## Rules

1. **Never guess HTML layout from an image.** Always create a layout schema first.
2. Every visual object must have explicit and exact properties:
   - `id`: Unique identifier
   - `type`: Element type (e.g., text, box)
   - `x`, `y`, `w`, `h`: Bounding box geometry
   - `zIndex`: Layer stacking order
   - `style`: Visual properties (colors, typography)
3. **HTML is only a renderer.** It should blindly apply the `x, y, w, h` as absolute positioning CSS without making layout decisions.
4. **Never bypass this skill with relative, hand-drawn, or custom HTML structures.** Always generate the intermediate `scene_layout.json` first, and compile it strictly using `render_html_from_layout.py` to produce a clean absolute-positioned `custom-html.html` layout control framework in the pipeline.

## Minimum Schema Example

```json
{
  "canvas": {
    "width": 1920,
    "height": 1080
  },
  "objects": [
    {
      "id": "main_title",
      "type": "text",
      "x": 102,
      "y": 128,
      "w": 632,
      "h": 68,
      "zIndex": 5,
      "text": "Academic Operating System",
      "style": {
        "fontSize": "30px",
        "background": "#7caeeb"
      }
    }
  ]
}
```

## Practical Use

Use this skill to convert `visual_analysis.yaml` or a raw slide image into `scene_layout.json`. Then pass `scene_layout.json` to a renderer script to output the `custom-html.html`.
