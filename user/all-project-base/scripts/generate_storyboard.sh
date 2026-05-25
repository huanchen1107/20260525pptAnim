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
  if [[ -n "$SLIDE_FILTER" && "$id" != "slide-$SLIDE_FILTER" ]]; then
    continue
  fi

  audio="$SLIDES_ROOT/${id}-audio.mp3"
  out="$SLIDES_ROOT/${id}-storyboard.yaml"

  duration="5.00"
  if [[ -f "$audio" ]] && command -v ffprobe >/dev/null 2>&1; then
    duration=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$audio" | awk '{printf "%.2f", $1+0.5}')
  fi

  if [[ "$NO_PROMPT" != "true" && -t 0 ]]; then
    read -r -p "Duration for ${id} in seconds [${duration}]: " input_duration
    if [[ -n "${input_duration:-}" ]]; then
      if [[ "$input_duration" =~ ^[0-9]+([.][0-9]+)?$ ]]; then
        duration="$input_duration"
      else
        echo "Invalid duration '${input_duration}', keeping default ${duration}."
      fi
    fi
  fi

  cat > "$out" <<YAML
duration: "$duration"
fps: 30
slide: "$id"
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
