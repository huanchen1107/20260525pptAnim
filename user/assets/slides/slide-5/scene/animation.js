(function () {
  function createTimeline() {
    if (!window.gsap) {
      return null;
    }

    const tl = gsap.timeline({
      paused: true,
      defaults: {
        ease: "power3.out",
        duration: 0.6
      }
    });

    tl.from(".grid-background", { autoAlpha: 0, duration: 0.2 }, 0);

    if (typeof window.applyCustomAnimation === "function") {
      window.applyCustomAnimation(tl, 5.0);
    } else {
      tl.from(".main-frame", {
        autoAlpha: 0,
        scale: 0.96,
        transformOrigin: "center center"
      }, 0.28)
        .from(".frame-label", { autoAlpha: 0, x: -30 }, 0.45)
        .from(".title", { autoAlpha: 0, y: 32 }, 0.68)
        .from(".divider", {
          scaleX: 0,
          transformOrigin: "left center"
        }, 0.92)
        .from(".subtitle", { autoAlpha: 0, y: 18 }, 1.08)
        .from(".note-box", { autoAlpha: 0, y: 18 }, 1.42)
        .fromTo(".progress-fill",
          { scaleX: 0, transformOrigin: "left center" },
          { scaleX: 1, duration: Math.max(5.0 - 1.6, 1.2), ease: "none" },
          1.25
        )
        .from(".footer-metadata", { autoAlpha: 0 }, 1.95);
    }

    return tl;
  }

  const timeline = createTimeline();
  window.createTimeline = createTimeline;
  window.__hfTimeline = timeline;
  window.__timelines = window.__timelines || {};
  window.__timelines["slide-5"] = timeline;
  window.__hf = {
    duration: 5.0,
    seek: function (time) {
      if (timeline) {
        timeline.seek(time, false);
      }
    }
  };

  window.addEventListener("hyperframes-tick", function (event) {
    if (!timeline || !event || !event.detail) {
      return;
    }
    const targetTime = event.detail.frame / event.detail.fps;
    timeline.seek(targetTime, false);
  });

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", function () {
      if (timeline) {
        timeline.pause(0);
      }
    });
  } else if (timeline) {
    timeline.pause(0);
  }
})();
