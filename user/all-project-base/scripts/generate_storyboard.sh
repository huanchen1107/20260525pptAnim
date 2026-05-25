#!/usr/bin/env bash
set -euo pipefail

SLIDES_ROOT="${1:-user/project-1/slides}"
for image in "$SLIDES_ROOT"/slide-*.png; do
  [[ -f "$image" ]] || continue
  id=$(basename "$image" .png)
  slide_name="$id"
  audio="$SLIDES_ROOT/${id}-audio.mp3"
  out="$SLIDES_ROOT/${id}-storyboard.yaml"
  duration="5.00"
  if [[ -f "$audio" ]] && command -v ffprobe >/dev/null 2>&1; then
    duration=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$audio" | awk '{printf "%.2f", $1+0.5}')
  fi
  cat > "$out" <<YAML
duration: "$duration"
fps: 30
slide: "$slide_name"
scenes:
  - id: background_enter
    time: 0.00
  - id: title_enter
    time: 0.80
  - id: settle
    time: 2.00
YAML
  echo "Generated $out"
done
