#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="user/project-1"
SLIDE_FILTER=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --project) PROJECT_ROOT="$2"; shift 2 ;;
    --slide) SLIDE_FILTER="$2"; shift 2 ;;
    *) PROJECT_ROOT="$1"; shift ;;
  esac
done

SLIDES_DIR="$PROJECT_ROOT/slides"

if ! command -v whisper >/dev/null; then
  echo "Error: whisper CLI not found." >&2
  exit 1
fi

for audio in "$SLIDES_DIR"/slide-[0-9]*-audio.mp3; do
  [[ -f "$audio" ]] || continue
  id="$(basename "$audio" -audio.mp3)"
  [[ "$id" =~ ^slide-[0-9]+$ ]] || continue
  [[ -n "$SLIDE_FILTER" && "$id" != "slide-$SLIDE_FILTER" ]] && continue

  text_out="$SLIDES_DIR/${id}-audio.txt"
  whisper "$audio" --model tiny --output_dir "$SLIDES_DIR" --output_format txt >/dev/null 2>&1 || true
  [[ -s "$text_out" ]] || echo "# transcription unavailable" > "$text_out"
  echo "Generated $text_out"
done
