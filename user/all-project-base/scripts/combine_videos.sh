#!/usr/bin/env bash
set -euo pipefail

SLIDES_ROOT="user/project-1/slides"
OUTPUT_VIDEO="user/project-1/presentation-master.mp4"
WORK_DIR="/private/tmp/pipeline-combine"
INPUTS_FILE="$WORK_DIR/inputs.txt"

rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR"
: > "$INPUTS_FILE"

for mp4 in $(find "$SLIDES_ROOT" -maxdepth 1 -type f -name 'slide-*.mp4' ! -name '*.preview.mp4' | sort -V); do
  echo "file '$(pwd)/$mp4'" >> "$INPUTS_FILE"
done

[[ -s "$INPUTS_FILE" ]] || { echo "No slide mp4 found" >&2; exit 1; }
ffmpeg -y -f concat -safe 0 -i "$INPUTS_FILE" -c:v libx264 -preset veryfast -crf 18 -pix_fmt yuv420p -c:a aac -b:a 128k "$OUTPUT_VIDEO" -loglevel error
echo "Created $OUTPUT_VIDEO"
