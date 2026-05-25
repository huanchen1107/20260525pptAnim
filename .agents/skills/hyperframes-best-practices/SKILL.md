---
name: hyperframes-best-practices
description: Best practices for HyperFrames - Deterministic HTML-to-video rendering framework
metadata:
  tags: hyperframes, video, html, css, animation, gsap
---

## When to use

Use this skill whenever you are dealing with HyperFrames codebase or rendering animated HTML templates into high-fidelity videos (MP4) using Puppeteer and FFmpeg.

## Core Architecture

HyperFrames is an **AI-first, HTML-native video rendering framework** developed by HeyGen. Unlike systems relying on React or heavy timelines, it treats standard HTML/CSS as the single source of truth.

* **Deterministic Rendering:** Compositions are rendered frame-by-frame using Puppeteer. Every animation must be absolute, deterministic, and timeline-bound.
* **No CSS Keyframes/Transitions:** Standard CSS transitions and `@keyframes` are **FORBIDDEN** because they run on browser layout cycles and are non-deterministic, causing dropped frames during Puppeteer rendering.
* **GSAP/Lottie Animation:** Standard CSS animations should be handled via the `@hyperframes/cli` or GSAP timelines tied to frames.

## New Project Setup

Scaffold a clean HyperFrames project using:

```bash
npx hyperframes init my-hyper-video
```

## Composition Timing & Orchestration

Orchestrate the timeline using the `data-hf-timeline` and `data-hf-duration` attributes directly in your HTML:

```html
<!-- Main timeline container lasting 300 frames (10 seconds at 30fps) -->
<div data-hf-timeline="main" data-hf-duration="300" class="stage">
  <!-- Title enters at frame 0, stays for 90 frames (3 seconds) -->
  <div data-hf-scene="intro" data-hf-start="0" data-hf-end="90">
    <h1 class="glow-title">Luminous Motion</h1>
  </div>
</div>
```

## Adding Assets

Place your image, audio, and video assets in the `public/` directory at the project root and reference them using standard paths:

```html
<!-- Display images cleanly -->
<img src="/public/assets/character.png" alt="Anime Character" class="cinematic-portrait" />

<!-- Add deterministic video layer -->
<video src="/public/assets/background_loop.mp4" data-hf-sync="true" muted></video>

<!-- Synchronize background audio -->
<audio src="/public/assets/audio_track.mp3" data-hf-audio-start="0" data-hf-volume="0.8"></audio>
```

---

## Technical Sub-Rules

For advanced rendering, timeline controls, or animation libraries, load the relevant sub-rule file:

1. **Timeline Orchestration:** See [rules/timeline.md](rules/timeline.md) for complex scene transitions, layering, and timeline syncing.
2. **Local Previewing & CLI:** See [rules/rendering.md](rules/rendering.md) for command lines, frame exports, and custom resolutions.
3. **GSAP Integration:** See [rules/gsap.md](rules/gsap.md) for building deterministic web animation timelines synchronized with the headless rendering engine.
