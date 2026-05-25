---
name: visual-qa-checker
description: Compare the source slide and rendered output to detect layout drift, missing blocks, text clipping, animation problems, and render regressions.
metadata:
  tags: qa, diff, review, render, screenshot
---

# Visual QA Checker

Use this skill after HTML generation or video rendering.

## Goal

Catch drift before the final export.

## Inputs

- original slide image or screenshot
- rendered screenshot or video preview
- `analysis/semantic_blocks.yaml`
- `analysis/storyboard.yaml`

## Required Output

- `qa/qa_report.md`

## Check Categories

1. Layout accuracy
2. Text correctness
3. Visual hierarchy
4. Color consistency
5. Animation readability
6. Render safety

## Rules

1. Identify at least three issues or improvement opportunities.
2. Separate factual mistakes from style preferences.
3. Preserve the semantic block structure when proposing fixes.
4. Never declare success without checking the rendered output.
