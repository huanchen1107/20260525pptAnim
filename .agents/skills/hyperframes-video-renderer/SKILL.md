---
name: hyperframes-video-renderer
description: Render the HTML/CSS/JS scene into MP4 with HyperFrames using deterministic playback, local assets, and stable render parameters.
metadata:
  tags: hyperframes, render, mp4, video, deterministic
---

# HyperFrames Video Renderer

Use this skill when the scene is ready and the goal is a finished video export.

## Goal

Render the HTML composition into MP4.

## Input Artifacts

- `user/assets/slides/slide-<N>/scene_layout.json`
- `user/assets/slides/slide-<N>/custom-html.html`
- `scene/index.html` (wrapper)
- `scene/style.css`
- `scene/animation.js`
- optional audio tracks
- optional poster frame

## Required Output

- `slide-<N>-animation.mp4`
- optional `poster.png`

## Rules

1. Keep rendering deterministic.
2. Avoid browser interactions during render.
3. Ensure fonts and assets are local or preloaded.
4. Use the timeline progress as the source of truth.
5. Keep the final frame stable.

## Default Render Target

```yaml
render:
  width: 1920
  height: 1080
  fps: 30
  duration: 8
  output: output.mp4
```
