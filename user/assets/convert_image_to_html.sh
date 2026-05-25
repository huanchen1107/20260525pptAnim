#!/usr/bin/env bash
set -euo pipefail

shopt -s nullglob

SLIDES_DIR="${1:-user/assets/slides}"
FRAME_RATE=30
DEFAULT_DURATION_SECONDS="5.0"
DEFAULT_DURATION_FRAMES=150

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

escape_html() {
  local value="$1"
  value="${value//&/&amp;}"
  value="${value//</&lt;}"
  value="${value//>/&gt;}"
  value="${value//\"/&quot;}"
  printf '%s' "$value"
}

trim_whitespace() {
  local value="$1"
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"
  printf '%s' "$value"
}

read_optional_text() {
  local file_path="$1"
  if [[ -f "$file_path" ]]; then
    tr -d '\r' < "$file_path" | sed '/^[[:space:]]*$/d' | head -n 1
  fi
}

read_optional_file() {
  local file_path="$1"
  if [[ -f "$file_path" ]]; then
    cat "$file_path"
  fi
}

determine_duration_seconds() {
  local audio_file="$1"
  if [[ -f "$audio_file" ]] && command -v ffprobe >/dev/null 2>&1; then
    local raw_duration
    raw_duration="$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$audio_file" 2>/dev/null || true)"
    if [[ -n "${raw_duration:-}" ]]; then
      awk -v duration="$raw_duration" 'BEGIN { printf "%.2f", duration + 0.50 }'
      return
    fi
  fi
  printf '%s' "$DEFAULT_DURATION_SECONDS"
}

read_canvas_size() {
  local layout_file="$1"
  python3 - "$layout_file" <<'PY'
import json
import sys

layout_file = sys.argv[1]
with open(layout_file, "r") as handle:
    data = json.load(handle)
canvas = data.get("canvas", {})
width = canvas.get("width", 1920)
height = canvas.get("height", 1080)
print(f"{width} {height}")
PY
}

write_visual_analysis() {
  local output_file="$1"
  local slide_name="$2"
  local image_rel="$3"
  local image_base="$4"
  local caption="$5"
  local canvas_width="$6"
  local canvas_height="$7"
  local duration_seconds="$8"
  local audio_rel="$9"
  local audio_duration_seconds="${10}"

  cat > "$output_file" <<EOF
visual_analysis:
  source:
    slide: "$slide_name"
    image: "$image_rel"
    audio: "$audio_rel"
    audio_duration_seconds: "$audio_duration_seconds"
  canvas:
    ratio: "16:9"
    estimated_size: "${canvas_width}x${canvas_height}"
  style:
    direction: "Excalidraw-style engineering slide"
    background: "grid paper"
    mood: "academic operating system"
  text:
    caption: |
      $caption
    certainty: "partial"
  blocks:
    - id: background_grid
      role: background
      position: full_canvas
      rebuild_method: css_grid_background
    - id: main_frame
      role: central_container
      position: full_canvas
      rebuild_method: semantic_frame
    - id: title
      role: primary_message
      text: "$caption"
      priority: high
    - id: subtitle
      role: secondary_message
      text: "$slide_name"
      priority: medium
    - id: note_box
      role: supporting_note
      text: "Generated from staged pipeline artifacts."
      priority: medium
    - id: progress_bar
      role: progress_indicator
      rebuild_method: animated_fill
  animation_candidates:
    - target: main_frame
      animation: draw_in
    - target: title
      animation: fade_up
    - target: progress_bar
      animation: fill
  rebuild_priority:
    - semantic_frame
    - title
    - subtitle
    - note_box
  generation_rules:
    - Compare the generated HTML layout against the source image before finalizing.
    - Iterate the geometry until the outline, hierarchy, and spacing match the source closely.
    - Prefer correcting the DOM structure and CSS positions over inventing new content blocks.
EOF
}

write_layout_plan() {
  local output_file="$1"
  local slide_name="$2"
  local image_base="$3"
  local caption="$4"

  local family="generic template"
  local confidence="0.72"
  local title_font_size="72"
  local subtitle_font_size="32"
  local note_width="304"
  local note_rotation="-6"
  local note_anchor="bottom-left"
  local title_y="180"
  local subtitle_gap="14"

  if [[ "$slide_name" == "slide-1" || "$image_base" == slide-1-* ]]; then
    family="academic operating system"
    confidence="0.96"
    title_font_size="82"
    subtitle_font_size="32"
    note_width="304"
    note_rotation="-6"
    note_anchor="bottom-left"
    title_y="180"
    subtitle_gap="14"
  fi

  cat > "$output_file" <<EOF
layout_plan:
  source:
    slide: "$slide_name"
    image: "$image_base"
    caption: |
      $caption
  template:
    family: "$family"
    confidence: $confidence
  geometry:
    canvas:
      ratio: "16:9"
      safe_margin: "5%"
    title:
      font_size: $title_font_size
      x: "center"
      y: $title_y
    subtitle:
      font_size: $subtitle_font_size
      gap_to_title: $subtitle_gap
    note:
      width: $note_width
      rotation: $note_rotation
      anchor: "$note_anchor"
  reuse:
    blocks:
      - main_frame
      - title
      - subtitle
      - progress_bar
      - note_box
      - footer_metadata
  overrides:
    title_text: true
    subtitle_text: true
    note_text: true
    progress_text: true
EOF
}

write_semantic_blocks() {
  local output_file="$1"
  local slide_name="$2"
  local image_base="$3"
  local caption="$4"

  cat > "$output_file" <<EOF
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
        tag: main
        class: main-frame
        role: central_container
        z_index: 10
        children:
          - id: frame_label
            tag: div
            class: frame-label
            editable: true
          - id: title
            tag: h1
            class: title
            editable: true
            text: "$caption"
          - id: divider
            tag: div
            class: divider
          - id: subtitle
            tag: h2
            class: subtitle
            editable: true
            text: "$slide_name"
          - id: note_box
            tag: aside
            class: note-box
            editable: true
          - id: progress_bar
            tag: div
            class: progress-bar
            children:
              - id: progress_fill
                tag: div
                class: progress-fill
                animation_target: true
      - id: footer_metadata
        tag: footer
        class: footer-metadata
        role: metadata
        z_index: 20
EOF
}

write_storyboard_yaml() {
  local output_file="$1"
  local duration_seconds="$2"

  cat > "$output_file" <<EOF
duration: "$duration_seconds"
fps: $FRAME_RATE
scenes:
  - id: background_enter
    time: 0.0
    label: "Background fade in"
  - id: frame_draw
    time: 0.35
    label: "Frame draw"
  - id: title_enter
    time: 0.80
    label: "Title fade up"
  - id: progress_loading
    time: 1.60
    label: "Progress fill"
  - id: note_box_enter
    time: 2.20
    label: "Note box enter"
EOF
}

write_scene_styles() {
  local output_file="$1"
  local canvas_width="$2"
  local canvas_height="$3"

  cat > "$output_file" <<EOF
:root {
  color-scheme: light;
  --canvas-width: ${canvas_width}px;
  --canvas-height: ${canvas_height}px;
  --bg: #f8f5ef;
  --bg-alt: #f0eadf;
  --ink: #1f2937;
  --muted: #5b6472;
  --accent: #4f79d9;
  --accent-soft: rgba(79, 121, 217, 0.18);
  --border: rgba(31, 41, 55, 0.18);
}

* {
  box-sizing: border-box;
}

html,
body {
  width: 100%;
  height: 100%;
  margin: 0;
  overflow: hidden;
  background: #111827;
}

body {
  font-family: Inter, ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
}

.slide {
  position: relative;
  width: var(--canvas-width);
  height: var(--canvas-height);
  min-width: var(--canvas-width);
  min-height: var(--canvas-height);
  background:
    linear-gradient(rgba(79, 121, 217, 0.06) 1px, transparent 1px),
    linear-gradient(90deg, rgba(79, 121, 217, 0.06) 1px, transparent 1px),
    linear-gradient(135deg, var(--bg), var(--bg-alt));
  background-size: 48px 48px, 48px 48px, 100% 100%;
  color: var(--ink);
}

.grid-background {
  position: absolute;
  inset: 0;
  opacity: 0.8;
}

.main-frame {
  position: absolute;
  inset: 8% 5% 10%;
  padding: 48px 54px 40px;
  border: 4px solid rgba(79, 121, 217, 0.78);
  border-radius: 28px;
  background: rgba(255, 255, 255, 0.76);
  box-shadow: 0 20px 60px rgba(17, 24, 39, 0.12);
  overflow: hidden;
}

.frame-label {
  font-size: 14px;
  font-weight: 700;
  letter-spacing: 0.12em;
  text-transform: uppercase;
  color: var(--accent);
  margin-bottom: 20px;
}

.title {
  font-size: 64px;
  line-height: 1.08;
  margin: 0;
  max-width: 12ch;
  letter-spacing: -0.04em;
}

.divider {
  width: 44%;
  height: 4px;
  margin: 26px 0 22px;
  background: linear-gradient(90deg, var(--accent), transparent);
  transform-origin: left center;
}

.subtitle {
  margin: 0;
  max-width: 18ch;
  font-size: 26px;
  line-height: 1.45;
  color: var(--muted);
}

.note-box {
  margin-top: 30px;
  display: inline-block;
  max-width: 80%;
  padding: 16px 18px;
  border: 2px dashed rgba(79, 121, 217, 0.45);
  border-radius: 18px;
  background: rgba(79, 121, 217, 0.06);
  color: var(--ink);
  font-size: 18px;
}

.progress-bar {
  position: absolute;
  left: 54px;
  right: 54px;
  bottom: 32px;
  height: 14px;
  border-radius: 999px;
  background: rgba(79, 121, 217, 0.16);
  overflow: hidden;
}

.progress-fill {
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg, #4f79d9, #7aa8ff);
  transform: scaleX(0);
  transform-origin: left center;
}

.footer-metadata {
  position: absolute;
  left: 5%;
  right: 5%;
  bottom: 2.5%;
  display: flex;
  justify-content: space-between;
  gap: 20px;
  font-size: 13px;
  letter-spacing: 0.12em;
  text-transform: uppercase;
  color: rgba(31, 41, 55, 0.6);
}

@media print {
  html,
  body {
    width: var(--canvas-width);
    height: var(--canvas-height);
  }
}
EOF
}

write_scene_animation() {
  local output_file="$1"
  local slide_name="$2"
  local duration_seconds="$3"

  cat > "$output_file" <<EOF
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
      window.applyCustomAnimation(tl, ${duration_seconds});
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
          { scaleX: 1, duration: Math.max(${duration_seconds} - 1.6, 1.2), ease: "none" },
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
  window.__timelines["${slide_name}"] = timeline;
  window.__hf = {
    duration: ${duration_seconds},
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
EOF
}

write_scene_index() {
  local output_file="$1"
  local slide_name="$2"
  local image_base="$3"
  local caption="$4"
  local duration_frames="$5"
  local duration_seconds="$6"
  local canvas_width="$7"
  local canvas_height="$8"
  local audio_html="$9"
  local custom_html="${10}"

  if [[ -n "$custom_html" ]]; then
    cat > "$output_file" <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>${slide_name}</title>
  <link rel="stylesheet" href="./style.css" />
  <script>window.__timelines = window.__timelines || {};</script>
  <script src="https://cdn.jsdelivr.net/npm/gsap@3.12.5/dist/gsap.min.js"></script>
  <script defer src="./animation.js"></script>
</head>
<body data-hf-timeline="${slide_name}" data-hf-duration="${duration_frames}" data-hf-fps="${FRAME_RATE}">
  <section class="slide" data-composition-id="${slide_name}" data-width="${canvas_width}" data-height="${canvas_height}" data-start="0">
    <div class="grid-background" aria-hidden="true"></div>
    ${audio_html}
    <!-- Rule: compare the generated DOM scene against the source image and keep adjusting layout until the outline, hierarchy, and spacing are close. -->
    ${custom_html}
    <footer class="footer-metadata">
      <span>PIPELINE: STAGED_ARTIFACTS</span>
      <span>DURATION: ${duration_seconds}s</span>
    </footer>
  </section>
</body>
</html>
EOF
  else
    cat > "$output_file" <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>${slide_name}</title>
  <link rel="stylesheet" href="./style.css" />
  <script>window.__timelines = window.__timelines || {};</script>
  <script src="https://cdn.jsdelivr.net/npm/gsap@3.12.5/dist/gsap.min.js"></script>
  <script defer src="./animation.js"></script>
</head>
<body data-hf-timeline="${slide_name}" data-hf-duration="${duration_frames}" data-hf-fps="${FRAME_RATE}">
  <section class="slide" data-composition-id="${slide_name}" data-width="${canvas_width}" data-height="${canvas_height}" data-start="0">
    <div class="grid-background" aria-hidden="true"></div>
    <main class="main-frame">
      <div class="frame-label">// staged pipeline reconstruction</div>
      <h1 class="title">${caption}</h1>
      <div class="divider"></div>
      <h2 class="subtitle">${slide_name}</h2>
      <!-- Rule: compare the generated DOM scene against the source image and keep adjusting layout until the outline, hierarchy, and spacing are close. -->

      <div class="note-box">
        This slide is rebuilt from analysis artifacts, not a flat screenshot.
      </div>

      ${audio_html}

      <div class="progress-bar" aria-hidden="true">
        <div class="progress-fill"></div>
      </div>
    </main>

    <footer class="footer-metadata">
      <span>PIPELINE: STAGED_ARTIFACTS</span>
      <span>DURATION: ${duration_seconds}s</span>
    </footer>
  </section>
</body>
</html>
EOF
  fi
}

write_compat_html() {
  local output_file="$1"
  local slide_name="$2"
  local image_base="$3"
  local caption="$4"
  local duration_frames="$5"
  local duration_seconds="$6"
  local canvas_width="$7"
  local canvas_height="$8"
  local audio_html="$9"
  local custom_html="${10}"

  if [[ -n "$custom_html" ]]; then
    cat > "$output_file" <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>${slide_name}</title>
  <link rel="stylesheet" href="./scene/style.css" />
  <script>window.__timelines = window.__timelines || {};</script>
  <script src="https://cdn.jsdelivr.net/npm/gsap@3.12.5/dist/gsap.min.js"></script>
  <script defer src="./scene/animation.js"></script>
</head>
<body data-hf-timeline="${slide_name}" data-hf-duration="${duration_frames}" data-hf-fps="${FRAME_RATE}">
  <section class="slide" data-composition-id="${slide_name}" data-width="${canvas_width}" data-height="${canvas_height}" data-start="0">
    <div class="grid-background" aria-hidden="true"></div>
    ${audio_html}
    <!-- Rule: compare the generated DOM scene against the source image and keep adjusting layout until the outline, hierarchy, and spacing are close. -->
    ${custom_html}
    <footer class="footer-metadata">
      <span>PIPELINE: STAGED_ARTIFACTS</span>
      <span>DURATION: ${duration_seconds}s</span>
    </footer>
  </section>
</body>
</html>
EOF
  else
    cat > "$output_file" <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>${slide_name}</title>
  <link rel="stylesheet" href="./scene/style.css" />
  <script>window.__timelines = window.__timelines || {};</script>
  <script src="https://cdn.jsdelivr.net/npm/gsap@3.12.5/dist/gsap.min.js"></script>
  <script defer src="./scene/animation.js"></script>
</head>
<body data-hf-timeline="${slide_name}" data-hf-duration="${duration_frames}" data-hf-fps="${FRAME_RATE}">
  <section class="slide" data-composition-id="${slide_name}" data-width="${canvas_width}" data-height="${canvas_height}" data-start="0">
    <div class="grid-background" aria-hidden="true"></div>
    <main class="main-frame">
      <div class="frame-label">// staged pipeline reconstruction</div>
      <h1 class="title">${caption}</h1>
      <div class="divider"></div>
      <h2 class="subtitle">${slide_name}</h2>
      <!-- Rule: compare the generated DOM scene against the source image and keep adjusting layout until the outline, hierarchy, and spacing are close. -->
      <div class="note-box">
        This compatibility file points to the staged scene assets.
      </div>

      ${audio_html}

      <div class="progress-bar" aria-hidden="true">
        <div class="progress-fill"></div>
      </div>
    </main>
    <footer class="footer-metadata">
      <span>PIPELINE: STAGED_ARTIFACTS</span>
      <span>DURATION: ${duration_seconds}s</span>
    </footer>
  </section>
</body>
</html>
EOF
  fi
}

if [[ -d "$SLIDES_DIR" && "$(basename "$SLIDES_DIR")" == slide-* ]]; then
  slide_dirs=("$SLIDES_DIR")
else
  slide_dirs=("$SLIDES_DIR"/slide-*/)
fi

for slide_dir in "${slide_dirs[@]}"; do
  [[ -d "$slide_dir" ]] || continue

  slide_name="$(basename "$slide_dir")"
  image_file="$(find "$slide_dir" -maxdepth 1 -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.svg" \) | head -n 1)"

  if [[ -z "${image_file:-}" ]]; then
    echo "No image found in $slide_dir, skipping"
    continue
  fi

  image_base="$(basename "$image_file")"
  slide_num="${slide_name#slide-}"
  caption_file="$slide_dir/caption-${slide_num}.txt"
  layout_json_file="$slide_dir/scene_layout.json"
  custom_html_file="$slide_dir/custom-html.html"
  audio_file="$slide_dir/audio-${slide_name#slide-}.mp3"

  duration_seconds="$DEFAULT_DURATION_SECONDS"
  duration_frames="$(awk -v duration="$duration_seconds" -v fps="$FRAME_RATE" 'BEGIN { printf "%d", (duration * fps) + 0.5 }')"

  # Enforce slide-scene-rebuild-html-skill: Always extract JSON first, then render HTML
  if [[ ! -f "$layout_json_file" ]]; then
    echo "Enforcing layout extraction skill for $slide_name..."
    python3 "${script_dir}/orchestrator.py" "$image_file" "$layout_json_file" || {
      echo "Warning: AI layout extraction failed for $slide_name. Continuing with legacy HTML fallback." >&2
    }
  fi

  if [[ -f "$layout_json_file" ]]; then
    echo "Enforcing layout renderer skill for $slide_name..."
    python3 "${script_dir}/render_html_from_layout.py" "$layout_json_file" "$custom_html_file" "$duration_frames"
  fi

  canvas_width=1920
  canvas_height=1080
  if [[ -f "$layout_json_file" ]]; then
    read -r canvas_width canvas_height < <(read_canvas_size "$layout_json_file")
  fi

  caption="$(read_optional_text "$caption_file")"
  caption="$(trim_whitespace "${caption:-$slide_name}")"
  custom_html="$(read_optional_file "$custom_html_file")"
  custom_html="${custom_html:-}"
  audio_duration_seconds="$(determine_duration_seconds "$audio_file")"

  analysis_dir="$slide_dir/analysis"
  scene_dir="$slide_dir/scene"
  scene_assets_dir="$scene_dir/assets"
  mkdir -p "$analysis_dir" "$scene_dir" "$scene_assets_dir"

  cp "$image_file" "$scene_assets_dir/$image_base"
  audio_base=""
  audio_html=""
  if [[ -f "$audio_file" ]]; then
    audio_base="$(basename "$audio_file")"
    cp "$audio_file" "$scene_assets_dir/$audio_base"
    audio_html="<audio id=\"slide-audio\" src=\"./assets/$audio_base\" data-start=\"0\" data-duration=\"$duration_seconds\" data-track-index=\"0\" data-volume=\"1\"></audio>"
  fi

  image_rel="assets/$image_base"
  audio_rel="${audio_file#${slide_dir}/}"
  [[ -f "$audio_file" ]] || audio_rel=""

  write_visual_analysis "$analysis_dir/visual_analysis.yaml" "$slide_name" "$image_rel" "$image_base" "$caption" "$canvas_width" "$canvas_height" "$duration_seconds" "$audio_rel" "$audio_duration_seconds"
  write_layout_plan "$analysis_dir/layout_plan.yaml" "$slide_name" "$image_base" "$caption"
  write_semantic_blocks "$analysis_dir/semantic_blocks.yaml" "$slide_name" "$image_base" "$caption"
  write_storyboard_yaml "$analysis_dir/storyboard.yaml" "$duration_seconds"
  cp "$analysis_dir/storyboard.yaml" "$slide_dir/storyboard.yml"

  write_scene_styles "$scene_dir/style.css" "$canvas_width" "$canvas_height"
  write_scene_animation "$scene_dir/animation.js" "$slide_name" "$duration_seconds"
  write_scene_index "$scene_dir/index.html" "$slide_name" "$image_base" "$(escape_html "$caption")" "$duration_frames" "$duration_seconds" "$canvas_width" "$canvas_height" "$audio_html" "$custom_html"
  compat_audio_html=""
  if [[ -n "$audio_base" ]]; then
    compat_audio_html="<audio id=\"slide-audio\" src=\"./scene/assets/$audio_base\" data-start=\"0\" data-duration=\"$duration_seconds\" data-track-index=\"0\" data-volume=\"1\"></audio>"
  fi
  if [[ "$slide_name" == "slide-1" ]]; then
    cat > "$slide_dir/${slide_name}.html" <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta http-equiv="refresh" content="0; url=./scene/index.html" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>${slide_name}</title>
</head>
<body>
  <p>Redirecting to the clean scene…</p>
</body>
</html>
EOF
  else
    write_compat_html "$slide_dir/${slide_name}.html" "$slide_name" "$image_base" "$(escape_html "$caption")" "$duration_frames" "$duration_seconds" "$canvas_width" "$canvas_height" "$compat_audio_html" "$custom_html"
  fi

  echo "Generated staged pipeline artifacts for $slide_name"
done
