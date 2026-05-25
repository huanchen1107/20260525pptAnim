#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="user/project-1"
RENDER_MODE="final"
SLIDE_FILTER=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --project) PROJECT_ROOT="$2"; shift 2 ;;
    --slide) SLIDE_FILTER="$2"; shift 2 ;;
    --mode) RENDER_MODE="${2:-final}"; shift 2 ;;
    --mode=*) RENDER_MODE="${1#*=}"; shift ;;
    *) PROJECT_ROOT="$1"; shift ;;
  esac
done

INPUT_PATH="$PROJECT_ROOT/slides"

for html in "$INPUT_PATH"/slide-[0-9]*.html; do
  [[ -f "$html" ]] || continue
  slide_id="$(basename "$html" .html)"
  [[ -n "$SLIDE_FILTER" && "$slide_id" != "slide-$SLIDE_FILTER" ]] && continue
  out="$INPUT_PATH/${slide_id}.mp4"
  preview="$INPUT_PATH/${slide_id}.preview.mp4"
  audio="$INPUT_PATH/${slide_id}-audio.mp3"
  tmpdir="$INPUT_PATH/.render-${slide_id}"

  rm -rf "$tmpdir" && mkdir -p "$tmpdir"
  cp "$html" "$tmpdir/index.html"
  cp "$INPUT_PATH/${slide_id}.png" "$tmpdir/${slide_id}.png" 2>/dev/null || true

  HOST=127.0.0.1 PORT=4173 npx hyperframes render "$tmpdir" -c index.html -o "$out" --quiet --workers 1 || {
    rm -rf "$tmpdir"
    echo "Render failed for $slide_id"
    exit 1
  }

  if [[ -f "$audio" ]]; then
    ffmpeg -y -i "$out" -i "$audio" -map 0:v:0 -map 1:a:0 -c:v copy -c:a aac -b:a 128k -shortest "$out.tmp.mp4" -loglevel error
    mv "$out.tmp.mp4" "$out"
  fi
  if [[ "$RENDER_MODE" == "preview" ]]; then
    ffmpeg -y -i "$out" -vf scale=960:540 -c:v libx264 -preset veryfast -crf 24 -c:a aac -b:a 96k "$preview" -loglevel error
  fi
  rm -rf "$tmpdir"
  echo "Rendered $out"
done
