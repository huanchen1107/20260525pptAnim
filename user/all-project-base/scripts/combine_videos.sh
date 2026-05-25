#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="user/project-1"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --project) PROJECT_ROOT="$2"; shift 2 ;;
    *) PROJECT_ROOT="$1"; shift ;;
  esac
done

SLIDES_ROOT="$PROJECT_ROOT/slides"
OUTPUT_VIDEO="$PROJECT_ROOT/outputs/presentation-master.mp4"
WORK_DIR="/private/tmp/pipeline-combine"
INPUTS_FILE="$WORK_DIR/inputs.txt"
mkdir -p "$PROJECT_ROOT/outputs"
rm -rf "$WORK_DIR" && mkdir -p "$WORK_DIR"
: > "$INPUTS_FILE"

find "$SLIDES_ROOT" -maxdepth 1 -type f -name 'slide-[0-9]*.mp4' ! -name '*.preview.mp4' | sort -V | while read -r mp4; do
  echo "file '$(pwd)/$mp4'" >> "$INPUTS_FILE"
done

[[ -s "$INPUTS_FILE" ]] || { echo "No slide mp4 found" >&2; exit 1; }
ffmpeg -y -f concat -safe 0 -i "$INPUTS_FILE" -c:v libx264 -preset veryfast -crf 18 -pix_fmt yuv420p -c:a aac -b:a 128k "$OUTPUT_VIDEO" -loglevel error
echo "Created $OUTPUT_VIDEO"
