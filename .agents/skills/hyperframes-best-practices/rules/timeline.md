# Timeline Orchestration in HyperFrames

To ensure consistent and byte-identical video outputs, HyperFrames parses timing information directly from standard HTML attributes.

## HTML Timing Attributes

Use the following attributes to orchestrate scenes and elements:

| Attribute | Value | Description |
|---|---|---|
| `data-hf-timeline` | `string` | Defines the name of the main rendering timeline. |
| `data-hf-duration` | `number` | Total duration of the composition or container in **frames**. |
| `data-hf-scene` | `string` | Defines a logical segment or scene name. |
| `data-hf-start` | `number` | The frame index when the element or scene enters the stage. |
| `data-hf-end` | `number` | The frame index when the element or scene exits the stage. |
| `data-hf-sync` | `boolean` | Synchronizes native media elements (video/audio) frame-by-frame. |

---

## Designing Multi-Scene Timelines

To create a clean narrative flow (e.g., Intro → Body → Outro), segment your root container into sequential scenes:

```html
<div data-hf-timeline="video-project" data-hf-duration="180">
  
  <!-- Scene 1: Cinematic Intro (0s - 2s @ 30fps) -->
  <div data-hf-scene="intro" data-hf-start="0" data-hf-end="60" class="scene fill-screen intro-theme">
    <div class="overlay glow-particles"></div>
    <h1 class="slide-in">Awakening</h1>
  </div>

  <!-- Scene 2: Core Presentation (2s - 5s @ 30fps) -->
  <div data-hf-scene="body" data-hf-start="60" data-hf-end="150" class="scene fill-screen body-theme">
    <div class="grid-content">
      <div class="diagram-container"></div>
    </div>
  </div>

  <!-- Scene 3: Emotional Outro (5s - 6s @ 30fps) -->
  <div data-hf-scene="outro" data-hf-start="150" data-hf-end="180" class="scene fill-screen outro-theme">
    <h2 class="fade-out">Resonance</h2>
  </div>

</div>
```

---

## Layer & Layout Rules

1. **Absolute Positioning:** Use absolute layout patterns to avoid dynamic reflows during headless capture:
   ```css
   .scene {
     position: absolute;
     top: 0;
     left: 0;
     width: 1920px;
     height: 1080px;
     overflow: hidden;
   }
   ```
2. **z-index Layering:** Define layers explicitly to maintain visual depth:
   * Background layer: `z-index: 1`
   * Midground (diagrams/elements): `z-index: 10`
   * Foreground text and overlays: `z-index: 100`

---

## Audio Synchronization

Synchronize audio clips precisely by specifying their play start frames and offset within the track:

```html
<!-- Plays background music starting at frame 0 with a fade-in -->
<audio src="/public/bgm.mp3" 
       data-hf-sync="true" 
       data-hf-start="0" 
       data-hf-volume="0.5">
</audio>

<!-- Plays a voiceover track starting exactly at frame 90 (3 seconds in) -->
<audio src="/public/voiceover.mp3" 
       data-hf-sync="true" 
       data-hf-start="90" 
       data-hf-offset="0" 
       data-hf-volume="1.0">
</audio>
```
