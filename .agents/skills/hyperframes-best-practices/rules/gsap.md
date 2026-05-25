# Deterministic GSAP Timelines in HyperFrames

To orchestrate complex motion paths, elastic elasticities, and premium visuals, HyperFrames integrates seamlessly with the **GreenSock Animation Platform (GSAP)**. 

To ensure identical video output during head-less rendering, GSAP animations must be configured **deterministically** to run off the Puppeteer capture ticker rather than standard browser delta-time.

---

## The GSAP Frame Sync Adapter

When creating a GSAP timeline in a HyperFrames composition, you must synchronize GSAP's ticker to the framework's custom frame loop:

```javascript
import { gsap } from "gsap";

// 1. Initialize your timeline with paused state
const tl = gsap.timeline({ paused: true });

// 2. Add animations utilizing frames rather than seconds (duration is in frames)
tl.to(".glow-title", {
  duration: 45, // 45 frames (1.5 seconds at 30fps)
  opacity: 1,
  y: -20,
  ease: "power3.out"
});

tl.to(".diagram-node", {
  duration: 30, // 30 frames
  scale: 1,
  stagger: 0.1,
  ease: "elastic.out(1, 0.3)"
}, "-=15"); // overlap by 15 frames

// 3. Register the GSAP sync event with the HyperFrames global adapter
window.addEventListener("hyperframes-tick", (event) => {
  const currentFrame = event.detail.frame;
  const fps = event.detail.fps;
  
  // Convert current frame into a deterministic second value for GSAP
  const targetTime = currentFrame / fps;
  
  // Seek the timeline directly to ensure exact frame alignment
  tl.seek(targetTime);
});
```

---

## Easing Guidelines

To create a natural, premium aesthetic, follow these professional easing curves:

* **Entry / Slide-in:** `power3.out` or `expo.out` (fast start, deceleration).
* **Exit / Slide-out:** `power3.in` or `quad.in` (slow start, acceleration).
* **Elastic reveals (Nodes, Buttons):** `elastic.out(1, 0.4)` (gives elements a bouncy, alive feedback).
* **Continuous drift / Cinematic zoom:** `none` or `linear` (smooth steady speed).

---

## CSS & DOM Animation Limits

* **No CSS Transition Rules:** Avoid mixing CSS `transition: all 0.3s ease;` on elements animated by GSAP. This creates layout fights during frame capture.
* **No `requestAnimationFrame` polling:** Do not use `setInterval` or standard `requestAnimationFrame` loop callbacks to increment positions; always tie variables directly to the `hyperframes-tick` event listener.
