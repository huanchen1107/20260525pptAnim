/* global gsap */

function registerTimeline(compositionId, timeline) {
  window.__timelines = window.__timelines || {};
  window.__timelines[compositionId] = timeline;
  window.__hf = {
    duration: timeline.duration(),
    seek: (time) => {
      timeline.pause();
      timeline.time(Number.isFinite(time) ? time : 0, false);
    },
  };
  window.addEventListener("hf-seek", (event) => {
    window.__hf.seek(event?.detail?.time ?? 0);
  });
}

const tl = gsap.timeline({ defaults: { ease: "power2.out" } });

gsap.set([
  "#top-module-badge",
  "#top-status",
  "#window-frame",
  "#window-title",
  "#window-controls",
  "#title",
  "#subtitle",
  "#sticky-note",
  "#status-copy",
  "#progress-box",
  "#footer-left",
  "#footer-right",
], { opacity: 0 });

tl.fromTo("#top-module-badge", { y: -8 }, { opacity: 1, y: 0, duration: 0.35 }, 0)
  .fromTo("#top-status", { y: -8 }, { opacity: 1, y: 0, duration: 0.35 }, 0)
  .fromTo("#window-frame", { scale: 0.985, transformOrigin: "center center" }, { opacity: 1, scale: 1, duration: 0.55 }, 0.05)
  .fromTo("#window-title", { x: -40 }, { opacity: 1, x: 0, duration: 0.5 }, 0.15)
  .fromTo("#window-controls", { x: 24 }, { opacity: 1, x: 0, duration: 0.35 }, 0.18)
  .fromTo("#title", { y: 24, opacity: 0 }, { opacity: 1, y: 0, duration: 0.65 }, 0.4)
  .fromTo("#subtitle", { y: 18, opacity: 0 }, { opacity: 1, y: 0, duration: 0.55 }, 0.56)
  .fromTo("#sticky-note", { x: -60, y: 28, rotation: -10, opacity: 0 }, { opacity: 1, x: 0, y: 0, rotation: -6, duration: 0.6 }, 0.72)
  .fromTo("#status-copy", { opacity: 0 }, { opacity: 1, duration: 0.3 }, 0.9)
  .fromTo("#progress-box", { y: 8, opacity: 0 }, { opacity: 1, y: 0, duration: 0.4 }, 0.96)
  .fromTo("#progress-fill", { scaleX: 0.18 }, { scaleX: 1, duration: 2.2, ease: "none" }, 1.02)
  .fromTo("#footer-left", { y: 10, opacity: 0 }, { opacity: 1, y: 0, duration: 0.35 }, 1.1)
  .fromTo("#footer-right", { y: 10, opacity: 0 }, { opacity: 1, y: 0, duration: 0.35 }, 1.1)
  .to({}, { duration: 2.2 });

registerTimeline("slide-1", tl);

