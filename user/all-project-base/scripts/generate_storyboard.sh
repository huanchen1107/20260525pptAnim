#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="user/project-1"
SLIDE_FILTER=""
NO_PROMPT="false"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --project) PROJECT_ROOT="$2"; shift 2 ;;
    --slide) SLIDE_FILTER="$2"; shift 2 ;;
    --no-prompt) NO_PROMPT="true"; shift ;;
    *) PROJECT_ROOT="$1"; shift ;;
  esac
done

SLIDES_ROOT="$PROJECT_ROOT/slides"

for image in "$SLIDES_ROOT"/slide-[0-9]*.png; do
  [[ -f "$image" ]] || continue
  id="$(basename "$image" .png)"
  [[ "$id" =~ ^slide-[0-9]+$ ]] || continue
  [[ -n "$SLIDE_FILTER" && "$id" != "slide-$SLIDE_FILTER" ]] && continue

  audio="$SLIDES_ROOT/${id}-audio.mp3"
  text_file="$SLIDES_ROOT/${id}-audio.txt"
  layout_json="$SLIDES_ROOT/${id}-scene_layout.json"
  out="$SLIDES_ROOT/${id}-storyboard.yml"

  duration="5.00"
  if [[ -f "$audio" ]] && command -v ffprobe >/dev/null 2>&1; then
    duration=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$audio" | awk '{printf "%.2f", $1+0.5}')
  fi

  if [[ "$NO_PROMPT" != "true" && -t 0 ]]; then
    read -r -p "Duration for ${id} in seconds [${duration}]: " input_duration
    if [[ -n "${input_duration:-}" && "$input_duration" =~ ^[0-9]+([.][0-9]+)?$ ]]; then
      duration="$input_duration"
    fi
  fi

  caption=""
  [[ -f "$text_file" ]] && caption="$(tr -d '\r' < "$text_file" | sed '/^[[:space:]]*$/d' | head -n 1)"
  caption_safe="${caption//\"/}"

  object_yaml=""
  if [[ -f "$layout_json" ]]; then
    object_yaml="$(python3 - "$layout_json" "$duration" <<'PY'
import json, sys
path = sys.argv[1]
duration = float(sys.argv[2])
with open(path, 'r', encoding='utf-8') as f:
    data = json.load(f)
objects = data.get('objects', []) if isinstance(data, dict) else []
if not isinstance(objects, list):
    objects = []
core = []
for obj in objects[:8]:
    oid = obj.get('id') or obj.get('name') or obj.get('type') or 'object'
    core.append(str(oid).replace('\n',' ').strip())
if not core:
    core = ['title','subtitle','progress_fill']
step = max(0.8, min(5.0, duration / max(1, len(core))))
t = 0.6
actions = ['fade_in', 'fade_up', 'draw_in', 'slide_in_left', 'slide_in_right', 'pulse']
for i, oid in enumerate(core):
    action = actions[i % len(actions)]
    d = 0.45 if action != 'pulse' else 0.8
    print(f'  - id: {oid}\n    at: {t:.2f}\n    action: {action}\n    duration: {d:.2f}')
    t += step
if duration > 5.0:
    checkpoints = int(duration // 5)
    for c in range(1, checkpoints + 1):
      at = min(duration - 0.5, c * 5.0)
      print(f'  - id: global\n    at: {at:.2f}\n    action: micro_emphasis\n    duration: 0.40')
PY
)"
  else
    object_yaml="  - id: title
    at: 0.80
    action: fade_in
    duration: 0.50
  - id: subtitle
    at: 1.40
    action: fade_up
    duration: 0.50
  - id: progress_fill
    at: 2.00
    action: scale_x
    duration: 2.50"
  fi

  cat > "$out" <<YML
slide: "$id"
duration: "$duration"
fps: 30
caption: "$caption_safe"
scenes:
  - id: intro
    start: 0.00
    end: 1.20
  - id: content
    start: 1.20
    end: 4.20
  - id: outro
    start: 4.20
    end: $duration
objects:
$object_yaml
YML

  echo "Generated $out"
done
