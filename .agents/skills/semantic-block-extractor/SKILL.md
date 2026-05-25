---
name: semantic-block-extractor
description: Convert visual analysis into a semantic HTML block tree with stable class names, editable text fields, z-index layers, and animation targets.
metadata:
  tags: semantic, html, yaml, blocks, layout
---

# Semantic Block Extractor

Use this skill after visual analysis and before writing HTML or CSS.

## Goal

Turn a visual read into a clean component tree.

## Required Output

Produce `analysis/semantic_blocks.yaml`.

## Rules

1. Each visual zone becomes a named block.
2. Use stable kebab-case class names.
3. Separate editable text from decorative shapes.
4. Avoid unnamed absolute-position containers.
5. Define z-index layers explicitly.
6. Mark animation targets.

## Suggested Class Set

- `slide`
- `grid-background`
- `top-metadata-bar`
- `main-frame`
- `frame-label`
- `title`
- `divider`
- `subtitle`
- `progress-bar`
- `progress-fill`
- `note-box`
- `footer-metadata`

## Minimum YAML Shape

```yaml
semantic_blocks:
  root:
    id: slide
    tag: section
    class: slide
    children:
      - id: grid_background
        tag: div
        class: grid-background
        role: background
        z_index: 0
      - id: main_frame
        tag: div
        class: main-frame
        role: central_container
        z_index: 20
        children:
          - id: title
            tag: h1
            class: title
            editable: true
          - id: subtitle
            tag: h2
            class: subtitle
            editable: true
```
