---
name: excalidraw-style-html-builder
description: Rebuild semantic blocks as editable Excalidraw-style HTML and CSS with grid-paper backgrounds, rough borders, SVG accents, and animation-ready class names.
metadata:
  tags: html, css, svg, roughjs, excalidraw, scene
---

# Excalidraw-Style HTML Builder

Use this skill when the semantic blocks are ready and the next step is a clean scene implementation.

## Goal

Create editable HTML/CSS, not a flat screenshot.

## Expected Files

- `scene/index.html`
- `scene/style.css`
- `scene/animation.js`
- optional `scene/rough-shapes.js`

## Rules

1. Keep text editable in the DOM.
2. Use CSS variables for spacing and color.
3. Use SVG or Rough.js for hand-drawn lines and shapes.
4. Keep class names stable for GSAP targets.
5. Preserve hierarchy over pixel-perfect tracing.
6. Avoid absolute positioning for the whole layout container.

## Visual Direction

- Excalidraw-inspired
- engineering notebook feel
- grid-paper background
- slightly imperfect borders
- strong typography hierarchy

## Minimum HTML Pattern

```html
<section class="slide">
  <div class="grid-background"></div>

  <header class="top-metadata-bar">...</header>

  <main class="main-frame">
    <div class="frame-label"></div>
    <h1 class="title"></h1>
    <div class="divider"></div>
    <h2 class="subtitle"></h2>
    <div class="progress-bar"><div class="progress-fill"></div></div>
  </main>

  <aside class="note-box"></aside>
  <footer class="footer-metadata"></footer>
</section>
```
