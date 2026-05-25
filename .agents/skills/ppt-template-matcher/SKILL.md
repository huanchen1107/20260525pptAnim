---
name: ppt-template-matcher
description: Detect the slide family or reusable layout template from a source slide image, then emit a layout plan that minimizes HTML/CSS iteration by reusing known typography, spacing, and block geometry.
metadata:
  tags: ppt, template, layout, planning, yaml, html
---

# PPT Template Matcher

Use this skill after visual analysis and before semantic block extraction when the deck has repeated slide families.

## Goal

Do not rebuild each slide from scratch if it matches a known template.
Find the slide family first, then generate a reusable layout plan.

## Required Output

Produce `analysis/layout_plan.yaml` with:

- template family or closest match
- canvas ratio and safe margins
- title, subtitle, note, footer, and frame geometry
- typography profile
- spacing profile
- reusable block roles
- slide-specific overrides

## Rules

1. Prefer template reuse over fresh reconstruction.
2. Normalize the slide into reusable regions before generating HTML.
3. Capture stable geometry once and reuse it across similar slides.
4. Separate template-level rules from slide-specific content.
5. If the slide does not match a known family, fall back to a new template profile.

## Minimum YAML Shape

```yaml
layout_plan:
  source:
    slide: "slide-1"
    image: "slide-1-01.png"
  template:
    family: "academic operating system"
    confidence: 0.92
  geometry:
    canvas:
      ratio: "16:9"
      safe_margin: "5%"
    title:
      font_size: 82
      x: "center"
      y: 180
    subtitle:
      font_size: 32
      gap_to_title: 14
    note:
      width: 304
      rotation: -6
      anchor: "bottom-left"
  reuse:
    blocks:
      - main_frame
      - title
      - subtitle
      - progress_bar
      - note_box
      - footer_metadata
  overrides:
    note_text: true
    title_text: true
```

## Practical Use

When this skill succeeds, pass `analysis/layout_plan.yaml` to the semantic extractor and HTML builder so the generated scene reuses a proven layout instead of discovering it again.
