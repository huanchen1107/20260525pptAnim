---
name: gsap-storyboard-animator
description: Convert storyboard YAML and strict JSON layout schemas into a deterministic GSAP timeline with labels, playback controls, and render-safe best practices.
metadata:
  tags: gsap, timeline, storyboard, animation, deterministic
---

# GSAP Storyboard Animator

Use this skill when the scene HTML/CSS is ready and needs motion design.

## Goal

Generate `scene/animation.js` from storyboard data.

## Input Artifacts

- `user/assets/slides/slide-<N>/scene_layout.json`
- `user/assets/slides/slide-<N>/custom-html.html`
- `analysis/storyboard.yaml`

## Required Output

- `scene/animation.js`

## Rules

1. Use `gsap.timeline()` instead of scattered delays.
2. Register the paused timeline on `window.__timelines`.
3. Use labels for readable sequencing.
4. Prefer `autoAlpha`, `x`, `y`, `scale`, and `rotation`.
5. Keep the animation deterministic for video rendering.
6. Avoid async setup, timers, and random values.

## Minimum Pattern

```js
import { gsap } from "gsap";

export function createTimeline() {
  const tl = gsap.timeline({ paused: true });

  tl.addLabel("intro", 0)
    .from(".main-frame", { autoAlpha: 0, scale: 0.96 }, 0)
    .from(".title", { autoAlpha: 0, y: 32 }, 0.4)
    .from(".subtitle", { autoAlpha: 0, y: 24 }, 0.8)
    .from(".progress-fill", { scaleX: 0, transformOrigin: "left center" }, 1.2);

  window.__timelines = window.__timelines || {};
  window.__timelines.slide = tl;
  return tl;
}
```
