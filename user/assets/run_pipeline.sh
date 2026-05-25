#!/usr/bin/env bash
set -euo pipefail

SLIDES_ROOT="user/assets/slides"
PIPELINE_MODE="final"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --mode)
      PIPELINE_MODE="${2:-final}"
      shift 2
      ;;
    --mode=*)
      PIPELINE_MODE="${1#*=}"
      shift
      ;;
    *)
      SLIDES_ROOT="$1"
      shift
      ;;
  esac
done

if [[ "$PIPELINE_MODE" == "auto" ]]; then
  PIPELINE_MODE="preview"
  echo "[auto] Running a single preview pass for $SLIDES_ROOT"
fi

./user/assets/convert_image_to_html.sh "$SLIDES_ROOT"
./user/assets/generate_storyboard.sh "$SLIDES_ROOT"
./user/assets/render_animation.sh --mode "$PIPELINE_MODE" "$SLIDES_ROOT"

if [[ "$PIPELINE_MODE" != "preview" && "$(basename "$SLIDES_ROOT")" != slide-* ]]; then
  ./user/assets/combine_videos.sh
fi

echo "Pipeline complete for $SLIDES_ROOT ($PIPELINE_MODE mode)"
