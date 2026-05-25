#!/usr/bin/env bash
set -euo pipefail

INPUT_PATH="user/project-1/slides"
RENDER_MODE="final"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --mode) RENDER_MODE="${2:-final}"; shift 2 ;;
    --mode=*) RENDER_MODE="${1#*=}"; shift ;;
    *) INPUT_PATH="$1"; shift ;;
  esac
done

for html in "$INPUT_PATH"/slide-*-slide-*.html "$INPUT_PATH"/slide-*.html; do
  [[ -f "$html" ]] || continue
  base=$(basename "$html" .html)
  slide_id=$(echo "$base" | sed -E 's/^(slide-[0-9]+).*/\1/')
  out="$INPUT_PATH/${slide_id}.mp4"
  preview="$INPUT_PATH/${slide_id}.preview.mp4"
  audio="$INPUT_PATH/${slide_id}-audio.mp3"

  npx hyperframes render "$INPUT_PATH" -c "$(basename "$html")" -o "$out"
  if [[ -f "$audio" ]]; then
    ffmpeg -y -i "$out" -i "$audio" -map 0:v:0 -map 1:a:0 -c:v copy -c:a aac -b:a 128k -shortest "$out.tmp.mp4" -loglevel error
    mv "$out.tmp.mp4" "$out"
  fi
  if [[ "$RENDER_MODE" == "preview" ]]; then
    ffmpeg -y -i "$out" -vf scale=960:540 -c:v libx264 -preset veryfast -crf 24 -c:a aac -b:a 96k "$preview" -loglevel error
  fi
  echo "Rendered $out"
done
